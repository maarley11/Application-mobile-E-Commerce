const express = require('express');
const dashboardController = require('../controllers/dashboardController');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

// GET /api/dashboard/stats -> KPI pour le front-end
router.get('/stats', authMiddleware, dashboardController.getProDashboard);

// GET /api/dashboard/sales-chart -> Graphe pour le front-end (à créer si manquant)
router.get('/sales-chart', authMiddleware, dashboardController.getDashboardStats);

module.exports = router;
