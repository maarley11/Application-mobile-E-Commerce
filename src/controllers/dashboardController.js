const { Order, OrderItem, Product, sequelize } = require('../models');
const { Op } = require('sequelize');

exports.getProDashboard = async (req, res) => {
  // 1. Vérification stricte du rôle Pro
  if (!req.user || !req.user.isPro) {
    return res.status(403).json({ message: 'Accès interdit. Réservé aux abonnés Pro.' });
  }

  const userId = req.user.userId;

  try {
    // KPI 1 & 2 : totalOrders et totalSpent (Agrégation)
    const orderStats = await Order.findOne({
      where: { userId },
      attributes: [
        [sequelize.fn('COUNT', sequelize.col('id')), 'totalOrders'],
        [sequelize.fn('SUM', sequelize.col('totalAmount')), 'totalSpent']
      ],
      raw: true
    });

    const totalOrders = parseInt(orderStats.totalOrders, 10) || 0;
    const totalSpent = parseInt(orderStats.totalSpent, 10) || 0;

    // KPI 3 : savings (Économies réalisées)
    // On calcule la différence entre le prix public et le prix unitaire payé (qui était le prix pro)
    // Multiplié par la quantité, en une seule agrégation SQL.
    // L'échappement des colonnes dépend du dialecte, on utilise une approche compatible.
    const quote = sequelize.getDialect() === 'postgres' ? '"' : '`';
    
    const savingsResult = await OrderItem.findOne({
      attributes: [
        [
          sequelize.fn('SUM', sequelize.literal(`(${quote}Product${quote}.${quote}publicPrice${quote} - ${quote}OrderItem${quote}.${quote}unitPrice${quote}) * ${quote}OrderItem${quote}.${quote}quantity${quote}`)),
          'totalSavings'
        ]
      ],
      include: [
        {
          model: Order,
          attributes: [],
          where: { userId }
        },
        {
          model: Product,
          attributes: []
        }
      ],
      raw: true
    });

    const savings = parseInt(savingsResult.totalSavings, 10) || 0;

    // KPI 4 : freeDeliveriesLeft
    // Calcul des commandes passées cette semaine
    const startOfWeek = new Date();
    startOfWeek.setHours(0, 0, 0, 0);
    startOfWeek.setDate(startOfWeek.getDate() - (startOfWeek.getDay() || 7) + 1); // Lundi comme début de semaine

    const ordersThisWeek = await Order.count({
      where: {
        userId,
        createdAt: {
          [Op.gte]: startOfWeek
        }
      }
    });

    const freeDeliveriesLeft = Math.max(0, 3 - ordersThisWeek);

    return res.status(200).json({
      totalOrders,
      totalSpent,
      savings,
      freeDeliveriesLeft
    });

  } catch (error) {
    console.error('Erreur Dashboard:', error);
    return res.status(500).json({ message: 'Erreur lors de la génération du dashboard analytique.' });
  }
};
