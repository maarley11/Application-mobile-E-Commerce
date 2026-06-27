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

module.exports = router;
