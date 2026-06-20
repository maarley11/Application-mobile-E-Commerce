const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const authMiddleware = require('../middlewares/auth');

// GET /api/products → Recherche avancée (publique, sans JWT requis pour la consultation)
router.get('/', productController.getProducts);

module.exports = router;
