const express = require('express');
const dashboardController = require('../controllers/dashboardController');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

router.get('/pro', authMiddleware, dashboardController.getProDashboard);

module.exports = router;
