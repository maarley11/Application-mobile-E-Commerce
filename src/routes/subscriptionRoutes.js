const express = require('express');
const subscriptionController = require('../controllers/subscriptionController');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

// Route protégée pour les utilisateurs authentifiés
router.get('/', authMiddleware, subscriptionController.getSubscriptions);
router.post('/renew', authMiddleware, subscriptionController.renewSubscription);

module.exports = router;
