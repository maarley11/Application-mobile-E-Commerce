const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authenticateJWT = require('../middlewares/auth');

// Toutes les routes sont protégées par JWT
router.use(authenticateJWT);

// GET  /api/notifications         → 20 dernières notifications
router.get('/', notificationController.getNotifications);

// PATCH /api/notifications/read-all → Marquer tout comme lu (AVANT /:id/read pour éviter conflit de route)
router.patch('/read-all', notificationController.markAllAsRead);

// PATCH /api/notifications/:id/read → Marquer une notification spécifique comme lue
router.patch('/:id/read', notificationController.markAsRead);

module.exports = router;
