const express = require('express');
const router = express.Router();
const addressController = require('../controllers/addressController');
const authMiddleware = require('../middlewares/auth');

// GET /api/addresses — Liste des adresses
router.get('/', authMiddleware, addressController.getAddresses);

// POST /api/addresses — Créer une adresse
router.post('/', authMiddleware, addressController.createAddress);

// PUT /api/addresses/:id — Modifier une adresse
router.put('/:id', authMiddleware, addressController.updateAddress);

// DELETE /api/addresses/:id — Supprimer une adresse
router.delete('/:id', authMiddleware, addressController.deleteAddress);

module.exports = router;
