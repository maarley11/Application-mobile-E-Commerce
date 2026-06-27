const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const authMiddleware = require('../middlewares/auth');

// GET /api/products → Recherche avancée (publique, sans JWT requis pour la consultation)
router.get('/', productController.getProducts);

// GET /api/products/:id → Récupération d'un produit par ID
router.get('/:id', productController.getProductById);

// POST /api/products/:id/images → Upload d'image avec compression (admin)
router.post('/:id/images', authMiddleware, productController.upload.single('image'), productController.uploadProductImage);

module.exports = router;
