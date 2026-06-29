const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favoriteController');
const authMiddleware = require('../middlewares/auth');

// GET /api/favorites — Liste des favoris
router.get('/', authMiddleware, favoriteController.getFavorites);

// POST /api/favorites — Ajouter un favori
router.post('/', authMiddleware, favoriteController.addFavorite);

// DELETE /api/favorites/:productId — Retirer un favori
router.delete('/:productId', authMiddleware, favoriteController.removeFavorite);

module.exports = router;
