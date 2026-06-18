// src/controllers/dashboard.controller.js
const { User, Product, Order } = require('../models');

/**
 * GET /api/dashboard/stats
 * Returns basic statistics for the admin dashboard.
 */
exports.getStats = async (req, res) => {
  try {
    const [totalUsers, totalProducts, totalOrders, totalRevenue] = await Promise.all([
      User.count(),
      Product.count(),
      Order.count(),
      Order.sum('totalAmount'),
    ]);

    return res.status(200).json({
      totalUsers: totalUsers || 0,
      totalProducts: totalProducts || 0,
      totalOrders: totalOrders || 0,
      totalRevenue: totalRevenue || 0,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Failed to fetch stats' });
  }
};
