const { Order, OrderItem, Product, Notification, sequelize } = require('../models');
const { sendPushNotification } = require('../services/fcmService');

// Méthodes de paiement autorisées
const VALID_PAYMENT_METHODS = ['WAVE', 'ORANGE_MONEY', 'MOBILE_MONEY', 'CASH', 'CASH_ON_DELIVERY', 'mobile_money', 'cash', 'À la livraison'];

exports.createOrder = async (req, res) => {
  const { paymentMethod, items, latitude, longitude } = req.body;

  // Validation du panier
  if (!items || items.length === 0) {
    return res.status(400).json({ message: 'Le panier est vide' });
  }

  // Validation de la méthode de paiement
  if (!paymentMethod || !VALID_PAYMENT_METHODS.includes(paymentMethod)) {
    return res.status(400).json({
      message: `Méthode de paiement invalide. Valeurs acceptées : ${VALID_PAYMENT_METHODS.join(', ')}`
    });
  }

  const t = await sequelize.transaction();

  try {
    let totalAmount = 0;
    const orderItemsData = [];

    // 1. Parcours des items et vérifications de stock et de prix
    for (const item of items) {
      // ✅ FIX Bug #1 (CRITIQUE) : Verrouillage pessimiste de la ligne produit
      // SELECT ... FOR UPDATE empêche deux commandes simultanées de lire le même stock.
      // Sans ce lock, une race condition permettrait de vendre plus que le stock disponible.
      const product = await Product.findByPk(item.productId, {
        transaction: t,
        lock: t.LOCK.UPDATE
      });

      if (!product) {
        throw new Error(`Produit introuvable (ID: ${item.productId})`);
      }

      if (product.stock < item.quantity) {
        throw new Error(`Stock insuffisant pour le produit : ${product.name}`);
      }

      // Prix selon le profil de l'utilisateur (Pro ou non)
      // Les prix sont TOUJOURS lus depuis la BDD, jamais depuis le client
      const unitPrice = req.user.isPro ? product.proPrice : product.publicPrice;
      totalAmount += unitPrice * item.quantity;

      // Décrémente le stock
      product.stock -= item.quantity;
      await product.save({ transaction: t });

      orderItemsData.push({
        productId: product.id,
        quantity: item.quantity,
        unitPrice: unitPrice
      });
    }

    // Générer le orderNumber format #SDP-XXXXX
    const randomCode = Math.floor(10000 + Math.random() * 90000); // 5 digits
    const orderNumber = `#SDP-${randomCode}`;

    // 2. Création de la commande
    const order = await Order.create({
      userId: req.user.userId,
      orderNumber,
      paymentMethod,
      totalAmount,
      status: 'PAID', // On assume que le paiement est validé pour l'exercice
      timeline: [
        {
          status: 'PAID',
          date: new Date().toISOString(),
          description: 'Commande confirmée et paiement reçu'
        }
      ],
      deliveryLatitude: latitude || null,
      deliveryLongitude: longitude || null
    }, { transaction: t });

    // 3. ✅ FIX Bug #2 : Utilisation de bulkCreate au lieu d'une boucle for
    // Plus performant pour insérer N lignes en une seule requête SQL
    const orderItemsWithOrderId = orderItemsData.map(data => ({
      orderId: order.id,
      productId: data.productId,
      quantity: data.quantity,
      unitPrice: data.unitPrice
    }));

    await OrderItem.bulkCreate(orderItemsWithOrderId, { transaction: t });

    // 4. Commit de la transaction
    await t.commit();

    return res.status(201).json({
      message: 'Commande créée avec succès',
      order: {
        id: order.id,
        orderNumber: order.orderNumber,
        totalAmount: order.totalAmount,
        status: order.status
      }
    });

  } catch (error) {
    await t.rollback();
    return res.status(400).json({ message: error.message });
  }
};

// PATCH /api/orders/:id/status
// Réservé aux ADMIN. Met à jour le statut d'une commande et notifie l'utilisateur.
exports.updateOrderStatus = async (req, res) => {
  // Vérification du rôle Admin
  if (!req.user || !req.user.isAdmin) {
    return res.status(403).json({ message: 'Accès interdit. Réservé aux administrateurs.' });
  }

  const { status, description, deliveryPersonName, deliveryPersonPhone } = req.body;
  const validStatuses = ['PENDING', 'PREPARING', 'SHIPPING', 'DELIVERED'];

  if (!validStatuses.includes(status)) {
    return res.status(400).json({
      message: `Statut invalide. Les valeurs acceptées sont : ${validStatuses.join(', ')}`,
    });
  }

  try {
    const order = await Order.findByPk(req.params.id);
    if (!order) {
      return res.status(404).json({ message: 'Commande introuvable' });
    }

    const oldStatus = order.status;
    order.status = status;
    
    // Update timeline
    const timeline = order.timeline || [];
    timeline.push({
      status,
      date: new Date().toISOString(),
      description: description || `Mise à jour du statut: ${status}`
    });
    order.timeline = timeline;

    if (status === 'SHIPPING' || status === 'DELIVERED') {
       if (deliveryPersonName) order.deliveryPersonName = deliveryPersonName;
       if (deliveryPersonPhone) order.deliveryPersonPhone = deliveryPersonPhone;
    }
    
    await order.save();

    // Ajouter des points de fidélité si la commande est livrée
    if (status === 'DELIVERED') {
      const { User } = require('../models');
      const user = await User.findByPk(order.userId);
      if (user) {
        const points = Math.floor(order.totalAmount / 1000);
        user.loyaltyPoints = (user.loyaltyPoints || 0) + points;
        await user.save();
        
        await Notification.create({
          userId: user.id,
          title: 'Points de fidélité ajoutés ! 🎉',
          message: `Vous avez gagné ${points} points de fidélité grâce à votre dernière commande.`,
          type: 'LOYALTY',
        });
      }
    }

    // Messages de notification selon le statut
    const statusMessages = {
      PREPARING: `Votre commande #${order.id} est en cours de préparation. 🍳`,
      SHIPPING:  `Votre commande #${order.id} est en cours de livraison ! 🚚`,
      DELIVERED: `Votre commande #${order.id} a été livrée avec succès. ✅ Merci pour votre confiance !`,
      PENDING:   `Votre commande #${order.id} est en attente de traitement.`,
    };

    // Création automatique de la notification pour l'utilisateur
    const notifMessage = statusMessages[status] || `Votre commande ${order.orderNumber || order.id} a changé de statut : ${status}`;
    await Notification.create({
      userId: order.userId,
      title: 'Mise à jour de votre commande',
      message: notifMessage,
      type: 'ORDER',
    });

    // Envoi de la notification Push FCM
    try {
      const { User } = require('../models');
      const userForFcm = await User.findByPk(order.userId, { attributes: ['fcmToken'] });
      if (userForFcm && userForFcm.fcmToken) {
        await sendPushNotification(
          userForFcm.fcmToken,
          'Mise à jour de votre commande 📦',
          notifMessage,
          { orderId: String(order.id), status }
        );
      }
    } catch (fcmErr) {
      console.warn('FCM non bloquant :', fcmErr.message);
    }

    return res.status(200).json({
      message: `Statut mis à jour : ${oldStatus} → ${status}`,
      order: { id: order.id, status: order.status },
    });

  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/orders
// Historique des commandes de l'utilisateur
exports.getUserOrders = async (req, res) => {
  try {
    const orders = await Order.findAll({
      where: { userId: req.user.userId },
      include: [
        {
          model: OrderItem,
          include: [{ model: Product, attributes: ['name', 'imageUrl'] }]
        }
      ],
      order: [['createdAt', 'DESC']]
    });
    return res.status(200).json(orders);
  } catch (error) {
    console.error('Erreur getUserOrders:', error);
    return res.status(500).json({ message: 'Erreur serveur lors de la récupération de l\'historique.' });
  }
};

// GET /api/orders/:id
// Suivi détaillé d'une commande spécifique
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findOne({
      where: { id: req.params.id, userId: req.user.userId },
      include: [
        {
          model: OrderItem,
          include: [{ model: Product, attributes: ['name', 'imageUrl', 'publicPrice', 'proPrice'] }]
        }
      ]
    });

    if (!order) {
      return res.status(404).json({ message: 'Commande introuvable ou accès refusé.' });
    }

    return res.status(200).json(order);
  } catch (error) {
    console.error('Erreur getOrderById:', error);
    return res.status(500).json({ message: 'Erreur serveur lors de la récupération de la commande.' });
  }
};
