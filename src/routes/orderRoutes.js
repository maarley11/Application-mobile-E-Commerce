const express = require('express');
const { body } = require('express-validator');
const orderController = require('../controllers/orderController');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

router.post(
  '/',
  authMiddleware,
  [
    body('paymentMethod').isIn(['WAVE', 'ORANGE_MONEY']).withMessage('Méthode de paiement invalide'),
    body('items').isArray().withMessage('Items doit être un tableau'),
    body('items.*.productId').isInt().withMessage('Product ID manquant ou invalide'),
    body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantité invalide')
  ],
  (req, res, next) => {
    const { validationResult } = require('express-validator');
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
  orderController.createOrder
);

// PATCH /api/orders/:id/status → Mise à jour du statut (Admin seulement, valide via isAdmin dans le JWT)
router.patch(
  '/:id/status',
  authMiddleware,
  [
    body('status')
      .isIn(['PENDING', 'PREPARING', 'SHIPPING', 'DELIVERED'])
      .withMessage('Statut invalide'),
  ],
  (req, res, next) => {
    const { validationResult } = require('express-validator');
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
  orderController.updateOrderStatus
);

// GET /api/orders → Historique de l'utilisateur connecté
router.get('/', authMiddleware, orderController.getUserOrders);

// GET /api/orders/:id → Détails et suivi de commande
router.get('/:id', authMiddleware, orderController.getOrderById);

module.exports = router;
