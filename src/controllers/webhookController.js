/**
 * Contrôleur de Webhooks de Paiement Mobile Money
 * POST /api/payments/webhook
 *
 * Reçoit les notifications de paiement des agrégateurs tiers :
 * - PayDunya, Wave, Orange Money, etc.
 *
 * Sécurité : validation du secret partagé via l'en-tête x-webhook-secret
 * La commande est mise à jour dès confirmation du paiement côté opérateur.
 */

const { Order, OrderItem, Notification, User, sequelize } = require('../models');
const { sendPushNotification } = require('../services/fcmService');

/**
 * POST /api/payments/webhook
 * Body attendu : { event_type, order_id, transaction_id, amount, operator }
 * Header attendu : x-webhook-secret: <WEBHOOK_SECRET du .env>
 *
 * event_type supportés :
 *   - "payment.success" → commande confirmée, statut → PREPARING
 *   - "payment.failed"  → commande échouée,   statut → FAILED
 */
exports.paymentWebhook = async (req, res) => {
  // ── 1. Validation du secret de sécurité ────────────────────────────
  const secretHeader   = req.headers['x-webhook-secret'];
  const expectedSecret = process.env.WEBHOOK_SECRET;

  // Retourner 200 immédiatement pour éviter le timeout côté agrégateur
  // La réponse est envoyée avant le traitement complet (pattern "fire and forget")
  if (!secretHeader || secretHeader !== expectedSecret) {
    return res.status(401).json({ error: 'Secret webhook invalide.' });
  }

  // ── 2. Extraction du payload ────────────────────────────────────────
  const { event_type, order_id, transaction_id, amount, operator } = req.body;

  if (!event_type || !order_id) {
    return res.status(400).json({ message: 'Données manquantes : event_type et order_id sont obligatoires.' });
  }

  // Répondre 200 immédiatement (les agrégateurs ont des timeouts courts)
  res.status(200).json({ received: true });

  // ── 3. Traitement asynchrone ────────────────────────────────────────
  const t = await sequelize.transaction();
  try {
    // Chercher la commande par id ou orderNumber
    const order = await Order.findOne({
      where: { id: order_id },
      transaction: t,
    });

    if (!order) {
      await t.rollback();
      console.warn(`Webhook : Commande ${order_id} introuvable.`);
      return;
    }

    // Protection contre les replays (idempotence)
    if (['PREPARING', 'SHIPPING', 'DELIVERED'].includes(order.status) && event_type === 'payment.success') {
      await t.rollback();
      console.log(`Webhook : Commande ${order_id} déjà confirmée. Ignoré.`);
      return;
    }

    const timeline = order.timeline || [];
    let notifTitle, notifMessage;

    if (event_type === 'payment.success') {
      // ── Paiement confirmé ────────────────────────────────────────────
      order.status = 'PREPARING';
      timeline.push({
        status: 'PREPARING',
        date: new Date().toISOString(),
        description: `Paiement ${operator || 'Mobile Money'} confirmé (réf. ${transaction_id || 'N/A'}). Commande en préparation.`,
      });
      order.timeline = timeline;

      notifTitle   = '✅ Paiement confirmé !';
      notifMessage = `Votre paiement pour la commande ${order.orderNumber || order.id} a été reçu. Nous préparons votre commande !`;

    } else if (event_type === 'payment.failed') {
      // ── Paiement échoué ──────────────────────────────────────────────
      order.status = 'FAILED';
      timeline.push({
        status: 'FAILED',
        date: new Date().toISOString(),
        description: `Paiement ${operator || 'Mobile Money'} échoué. Veuillez réessayer.`,
      });
      order.timeline = timeline;

      notifTitle   = '❌ Paiement échoué';
      notifMessage = `Votre paiement pour la commande ${order.orderNumber || order.id} a échoué. Veuillez réessayer depuis l'application.`;

    } else {
      // Événement inconnu → on ignore
      await t.rollback();
      console.log(`Webhook : event_type inconnu "${event_type}". Ignoré.`);
      return;
    }

    await order.save({ transaction: t });

    // ── Notification en base de données ──────────────────────────────
    await Notification.create({
      userId: order.userId,
      title:  notifTitle,
      message: notifMessage,
      type:   'PAYMENT',
    }, { transaction: t });

    await t.commit();

    // ── Notification Push FCM (hors transaction, non bloquant) ────────
    try {
      const user = await User.findByPk(order.userId, { attributes: ['fcmToken'] });
      if (user && user.fcmToken) {
        await sendPushNotification(
          user.fcmToken,
          notifTitle,
          notifMessage,
          { orderId: String(order.id), event: event_type }
        );
      }
    } catch (fcmErr) {
      console.warn('Webhook FCM non bloquant :', fcmErr.message);
    }

    console.log(`✅ Webhook traité : ${event_type} pour la commande ${order_id}`);

  } catch (error) {
    await t.rollback();
    console.error('Erreur lors du traitement du webhook de paiement :', error.message);
  }
};
