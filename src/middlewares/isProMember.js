const { User } = require('../models');

const isProMember = async (req, res, next) => {
  try {
    // req.user est défini par le middleware auth
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ message: 'Non autorisé' });
    }

    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    const now = new Date();

    if (!user.isPro || !user.subscriptionExpiresAt || user.subscriptionExpiresAt < now) {
      return res.status(403).json({ message: 'Accès interdit. Abonnement Pro expiré ou inactif.' });
    }

    // On peut injecter l'utilisateur complet ou à jour si besoin, mais next suffit
    next();
  } catch (error) {
    console.error('Erreur isProMember:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = isProMember;
