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
    // ✅ FIX Bug #5 : parseFloat au lieu de parseInt pour conserver les décimales
    // Les montants financiers (CFA) peuvent avoir des centimes
    const totalSpent = parseFloat(orderStats.totalSpent) || 0;

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

    // ✅ FIX Bug #5 : parseFloat pour les économies également
    const savings = parseFloat(savingsResult.totalSavings) || 0;

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

    // ✅ FIX Bug #7 : Ajout des loyaltyPoints (attendu par le Flutter DashboardProvider)
    // Règle métier : 1 point par commande complétée
    const loyaltyPoints = totalOrders;

    return res.status(200).json({
      totalOrders,
      totalSpent,
      savings,
      freeDeliveriesLeft,
      loyaltyPoints
    });

  } catch (error) {
    console.error('Erreur Dashboard:', error);
    return res.status(500).json({ message: 'Erreur lors de la génération du dashboard analytique.' });
  }
};

exports.getDashboardStats = async (req, res) => {
  try {
    const userId = req.user.userId;
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    // 1. Dépenses et nb de commandes ce mois-ci
    const currentMonthStats = await Order.findOne({
      where: {
        userId,
        createdAt: {
          [Op.gte]: startOfMonth
        }
      },
      attributes: [
        [sequelize.fn('COUNT', sequelize.col('id')), 'ordersCount'],
        [sequelize.fn('SUM', sequelize.col('totalAmount')), 'totalSpentThisMonth']
      ],
      raw: true
    });

    const ordersCount = parseInt(currentMonthStats.ordersCount, 10) || 0;
    const totalSpentThisMonth = parseInt(currentMonthStats.totalSpentThisMonth, 10) || 0;

    // 2. Savings realized ce mois-ci
    const quote = sequelize.getDialect() === 'postgres' ? '"' : '`';
    const savingsResult = await OrderItem.findOne({
      attributes: [
        [
          sequelize.fn('SUM', sequelize.literal(`(${quote}Product${quote}.${quote}publicPrice${quote} - ${quote}OrderItem${quote}.${quote}unitPrice${quote}) * ${quote}OrderItem${quote}.${quote}quantity${quote}`)),
          'savingsRealized'
        ]
      ],
      include: [
        {
          model: Order,
          attributes: [],
          where: {
            userId,
            createdAt: {
              [Op.gte]: startOfMonth
            }
          }
        },
        {
          model: Product,
          attributes: []
        }
      ],
      raw: true
    });

    const savingsRealized = parseInt(savingsResult.savingsRealized, 10) || 0;

    // 3. Achats mensuels sur les 6 derniers mois
    const startOf6MonthsAgo = new Date(now.getFullYear(), now.getMonth() - 5, 1);
    
    // Extrait l'année et le mois (compatible Postgres / Sqlite / MySQL)
    // Pour assurer une large compatibilité et simplicité avec Sequelize,
    // On peut utiliser des fonctions dialect-specific ou un fallback
    const monthExtract = sequelize.getDialect() === 'postgres'
      ? sequelize.fn('TO_CHAR', sequelize.col('createdAt'), 'YYYY-MM')
      : sequelize.fn('strftime', '%Y-%m', sequelize.col('createdAt')); // SQLite par défaut ou test

    const monthlyPurchasesResult = await Order.findAll({
      where: {
        userId,
        createdAt: {
          [Op.gte]: startOf6MonthsAgo
        }
      },
      attributes: [
        [monthExtract, 'month'],
        [sequelize.fn('SUM', sequelize.col('totalAmount')), 'spent']
      ],
      group: ['month'],
      order: [[sequelize.literal('month'), 'ASC']],
      raw: true
    });

    // Optionnel : remplir les mois vides avec 0 si non présents dans le résultat
    // (Pour simplifier, on renvoie les données agrégées trouvées)

    return res.status(200).json({
      totalSpentThisMonth,
      ordersCount,
      savingsRealized,
      monthlyPurchases: monthlyPurchasesResult
    });

  } catch (error) {
    console.error('Erreur getDashboardStats:', error);
    return res.status(500).json({ message: 'Erreur lors de la récupération des statistiques.' });
  }
};

