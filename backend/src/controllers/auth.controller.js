const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Génère un OTP (1234 en mode dev)
const generateOtp = () => {
  return '1234'; // Simplifié pour le développement
};

exports.register = async (req, res) => {
  try {
    const { phone, name, businessName, ninea, address } = req.body;

    // Vérifier si l'utilisateur existe déjà
    let user = await User.findOne({ where: { phone } });
    if (user) {
      return res.status(400).json({ message: 'Ce numéro de téléphone est déjà utilisé.' });
    }

    const otpCode = generateOtp();

    // Créer le nouvel utilisateur
    user = await User.create({
      phone,
      name,
      businessName,
      ninea,
      address,
      otpCode,
    });

    return res.status(201).json({ message: 'Code OTP envoyé', phone });
  } catch (error) {
    console.error('Register error:', error);
    return res.status(500).json({ message: 'Erreur lors de l\'inscription', error: error.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { phone } = req.body;

    const user = await User.findOne({ where: { phone } });
    if (!user) {
      return res.status(404).json({ message: 'Aucun compte trouvé avec ce numéro.' });
    }

    // Mettre à jour l'OTP
    const otpCode = generateOtp();
    user.otpCode = otpCode;
    await user.save();

    return res.status(200).json({ message: 'Code OTP envoyé', phone });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ message: 'Erreur lors de la connexion' });
  }
};

exports.verifyOtp = async (req, res) => {
  try {
    const { phone, otpCode } = req.body;

    const user = await User.findOne({ where: { phone, otpCode } });

    if (!user) {
      return res.status(400).json({ message: 'Code OTP incorrect ou expiré' });
    }

    // Réinitialiser le code OTP
    user.otpCode = null;
    await user.save();

    // Générer le JWT
    const token = jwt.sign(
      { userId: user.id, isPro: user.isPro },
      process.env.JWT_SECRET || 'baana_super_secret_key_2026',
      { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
    );

    return res.status(200).json({
      message: 'Authentification réussie',
      token,
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        isPro: user.isPro,
        businessName: user.businessName,
        ninea: user.ninea,
        address: user.address,
        loyaltyPoints: user.loyaltyPoints,
      },
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    return res.status(500).json({ message: 'Erreur lors de la vérification OTP' });
  }
};

exports.updateBusinessProfile = async (req, res) => {
  try {
    const { businessName, ninea, address } = req.body;
    const userId = req.user.userId;

    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur introuvable' });
    }

    user.businessName = businessName;
    user.ninea = ninea;
    user.address = address;
    user.isPro = true; // On le passe en mode pro dès qu'il a un profil entreprise
    await user.save();

    return res.status(200).json({
      message: 'Profil pro mis à jour',
      user: {
        isPro: user.isPro,
        businessName: user.businessName,
        ninea: user.ninea,
        address: user.address,
      },
    });
  } catch (error) {
    console.error('Update Business Profile error:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
