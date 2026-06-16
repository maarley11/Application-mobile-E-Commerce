const express = require('express');
const dashboardController = require('../controllers/dashboardController');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

// Endpoints J9 & J10
router.get('/pro', authMiddleware, dashboardController.getProDashboard);

// Endpoints J10 (Phase 3)
const isProMember = require('../middlewares/isProMember');
router.get('/stats', authMiddleware, isProMember, dashboardController.getDashboardStats);

module.exports = router;
