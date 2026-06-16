const { Order, User, sequelize } = require('../models');

exports.paymentWebhook = async (req, res) => {
  // Simule la vérification d'un hash envoyé par l'agrégateur (ex: Wave, PayDunya)
  // Dans la réalité, on compare req.headers['x-webhook-signature'] avec un hash HMAC de req.body
  const signature = req.headers['x-webhook-signature'];
  if (!signature || signature !== 'secret_valid_signature') {
    return res.status(401).json({ message: 'Signature invalide' });
  }

  const { transaction_id, status, order_id } = req.body;

  if (!order_id || !status) {
    return res.status(400).json({ message: 'Données manquantes' });
  }

  const t = await sequelize.transaction();

  try {
    const order = await Order.findByPk(order_id, { transaction: t });

    if (!order) {
      await t.rollback();
      return res.status(404).json({ message: 'Commande introuvable' });
    }

    // Protection contre le replay attack
    if (order.status === 'PAID') {
      await t.rollback();
      return res.status(200).json({ message: 'Commande déjà payée' });
    }

    if (status === 'SUCCESS') {
      order.status = 'PAID';
      // Dans un cas complet, on pourrait enregistrer le transaction_id
      await order.save({ transaction: t });

      // Optionnel : Vider le panier de l'utilisateur s'il existe une table Cart.
      // (Non défini dans notre modèle actuel, on l'omet)
    } else {
      order.status = 'FAILED';
      await order.save({ transaction: t });
    }

    await t.commit();
    return res.status(200).json({ message: 'Webhook traité avec succès' });

  } catch (error) {
    await t.rollback();
    console.error('Erreur webhook de paiement:', error);
    return res.status(500).json({ message: 'Erreur serveur interne' });
  }
};
