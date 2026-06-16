const { User } = require('../models');

exports.renewSubscription = async (req, res) => {
  try {
    const userId = req.user.userId;

    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur introuvable' });
    }

    // Ajoute 30 jours à la date d'expiration
    const now = new Date();
    let newExpiryDate = new Date(now);

    // Si l'abonnement est déjà actif, on ajoute 30 jours à la date d'expiration actuelle
    if (user.subscriptionExpiresAt && user.subscriptionExpiresAt > now) {
      newExpiryDate = new Date(user.subscriptionExpiresAt);
    }
    newExpiryDate.setDate(newExpiryDate.getDate() + 30);

    user.isPro = true;
    user.subscriptionExpiresAt = newExpiryDate;
    await user.save();

    return res.status(200).json({
      message: 'Abonnement Pro renouvelé avec succès',
      expiresAt: user.subscriptionExpiresAt
    });

  } catch (error) {
    console.error('Erreur lors du renouvellement de l\\'abonnement:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
