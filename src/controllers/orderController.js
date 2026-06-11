const { Order, OrderItem, Product, sequelize } = require('../models');

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
