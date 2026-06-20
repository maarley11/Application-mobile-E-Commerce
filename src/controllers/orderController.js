const { Order, OrderItem, Product, Notification, sequelize } = require('../models');

exports.createOrder = async (req, res) => {
  const { paymentMethod, items } = req.body;

  if (!items || items.length === 0) {
    return res.status(400).json({ message: 'Le panier est vide' });
  }

  const t = await sequelize.transaction();

  try {
    let totalAmount = 0;
    const orderItemsData = [];

    // 1. Parcours des items et vérifications de stock et de prix
    for (const item of items) {
      const product = await Product.findByPk(item.productId, { transaction: t });

      if (!product) {
        throw new Error(`Produit introuvable (ID: ${item.productId})`);
      }

      if (product.stock < item.quantity) {
        throw new Error(`Stock insuffisant pour le produit : ${product.name}`);
      }

      // Prix selon le profil de l'utilisateur (Pro ou non)
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

    // 2. Création de la commande
    const order = await Order.create({
      userId: req.user.userId,
      paymentMethod,
      totalAmount,
      status: 'PAID' // On assume que le paiement est validé pour l'exercice
    }, { transaction: t });

    // 3. Création des lignes de la commande
    for (const data of orderItemsData) {
      await OrderItem.create({
        orderId: order.id,
        productId: data.productId,
        quantity: data.quantity,
        unitPrice: data.unitPrice
      }, { transaction: t });
    }

    // 4. Commit de la transaction
    await t.commit();

    return res.status(201).json({
      message: 'Commande créée avec succès',
      order: {
        id: order.id,
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

  const { status } = req.body;
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
    await order.save();

    // Messages de notification selon le statut
    const statusMessages = {
      PREPARING: `Votre commande #${order.id} est en cours de préparation. 🍳`,
      SHIPPING:  `Votre commande #${order.id} est en cours de livraison ! 🚚`,
      DELIVERED: `Votre commande #${order.id} a été livrée avec succès. ✅ Merci pour votre confiance !`,
      PENDING:   `Votre commande #${order.id} est en attente de traitement.`,
    };

    // Création automatique de la notification pour l'utilisateur
    await Notification.create({
      userId: order.userId,
      title: 'Mise à jour de votre commande',
      message: statusMessages[status] || `Votre commande #${order.id} a changé de statut : ${status}`,
      type: 'ORDER',
    });

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
