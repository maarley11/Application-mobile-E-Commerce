const express = require('express');
const authMiddleware = require('../middlewares/auth');
const { User } = require('../models');

const router = express.Router();

// PUT /api/users/profile -> Met à jour les informations professionnelles de l'utilisateur
router.put('/profile', authMiddleware, async (req, res) => {
  const { businessName, ninea, address } = req.body;

  try {
    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    // Mise à jour des informations
    user.businessName = businessName !== undefined ? businessName : user.businessName;
    user.ninea = ninea !== undefined ? ninea : user.ninea;
    user.address = address !== undefined ? address : user.address;
    user.isPro = true; // On active le mode Pro dès que le profil entreprise est rempli
    
    await user.save();

    return res.status(200).json({
      message: 'Profil professionnel mis à jour avec succès',
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        isPro: user.isPro,
        businessName: user.businessName,
        ninea: user.ninea,
        address: user.address
      }
    });
  } catch (error) {
    console.error('Erreur updateBusinessProfile:', error);
    return res.status(500).json({ message: 'Erreur serveur lors de la mise à jour du profil.' });
  }
});

// GET /api/users/loyalty -> Récupère les points de fidélité et l'historique
router.get('/loyalty', authMiddleware, async (req, res) => {
  try {
    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    // Dans une version plus avancée, on pourrait interroger une table LoyaltyHistory
    // Pour l'instant, on retourne juste les points
    return res.status(200).json({
      points: user.loyaltyPoints || 0,
      history: []
    });
  } catch (error) {
    console.error('Erreur getLoyalty:', error);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

// PUT /api/users/location -> Met à jour la position GPS
router.put('/location', authMiddleware, async (req, res) => {
  const { latitude, longitude } = req.body;
  try {
    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    if (latitude) user.gpsLatitude = latitude;
    if (longitude) user.gpsLongitude = longitude;
    
    await user.save();

    return res.status(200).json({ message: 'Position mise à jour' });
  } catch (error) {
    console.error('Erreur updateLocation:', error);
    return res.status(500).json({ message: 'Erreur serveur.' });
  }
});

module.exports = router;
