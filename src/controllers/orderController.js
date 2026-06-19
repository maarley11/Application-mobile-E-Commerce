const { Order, OrderItem, Product, sequelize } = require('../models');

// Méthodes de paiement autorisées
const VALID_PAYMENT_METHODS = ['MOBILE_MONEY', 'CARD', 'CASH_ON_DELIVERY'];

exports.createOrder = async (req, res) => {
  const { paymentMethod, items } = req.body;

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

    // 2. Création de la commande
    const order = await Order.create({
      userId: req.user.userId,
      paymentMethod,
      totalAmount,
      status: 'PAID' // On assume que le paiement est validé pour l'exercice
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
        totalAmount: order.totalAmount,
        status: order.status
      }
    });

  } catch (error) {
    await t.rollback();
    return res.status(400).json({ message: error.message });
  }
};
