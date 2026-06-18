const { validationResult } = require('express-validator');
const { User } = require('../models');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { phone, name } = req.body;

  try {
    let user = await User.findOne({ where: { phone } });
    
    // Générer OTP (ex: "1234" en mode dev)
    const otpCode = process.env.NODE_ENV === 'production' 
      ? Math.floor(1000 + Math.random() * 9000).toString() 
      : '1234';

    if (!user) {
      user = await User.create({ phone, name, otpCode });
    } else {
      user.otpCode = otpCode;
      await user.save();
    }

    // Dans un cas réel, on envoie le SMS ici via une API (Twilio, InfoBip, etc.)
    
    return res.status(200).json({ 
      message: 'OTP envoyé avec succès', 
      // OTP non renvoyé en JSON pour des raisons de sécurité
    });

  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Erreur lors de l\'enregistrement' });
  }
};

exports.verifyOtp = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { phone, otpCode } = req.body;

  try {
    const user = await User.findOne({ where: { phone } });

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    if (user.otpCode !== otpCode) {
      return res.status(400).json({ message: 'Code OTP invalide' });
    }

    // Succès: vider le champ otpCode
    user.otpCode = null;
    await user.save();

    const token = jwt.sign(
      { userId: user.id, isPro: user.isPro, isAdmin: user.isAdmin },
      process.env.JWT_SECRET || 'secret_dev_key',
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      message: 'Authentification réussie',
      token,
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        isPro: user.isPro,
        isAdmin: user.isAdmin
      }
    });

  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Erreur lors de la vérification' });
  }
};
