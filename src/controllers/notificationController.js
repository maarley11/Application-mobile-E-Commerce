const { Notification } = require('../models');

// GET /api/notifications
// Retourne les 20 dernières notifications de l'utilisateur connecté
exports.getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.findAll({
      where: { userId: req.user.userId },
      order: [['createdAt', 'DESC']],
      limit: 20,
    });
    return res.status(200).json(notifications);
  } catch (error) {
    console.error('Erreur getNotifications:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PATCH /api/notifications/:id/read
// Marque une notification spécifique comme lue
exports.markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findOne({
      where: { id: req.params.id, userId: req.user.userId },
    });

    if (!notification) {
      return res.status(404).json({ message: 'Notification introuvable' });
    }

    notification.isRead = true;
    await notification.save();

    return res.status(200).json({ message: 'Notification marquée comme lue', notification });
  } catch (error) {
    console.error('Erreur markAsRead:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PATCH /api/notifications/read-all
// Marque TOUTES les notifications de l'utilisateur comme lues
exports.markAllAsRead = async (req, res) => {
  try {
    await Notification.update(
      { isRead: true },
      { where: { userId: req.user.userId, isRead: false } }
    );
    return res.status(200).json({ message: 'Toutes les notifications ont été marquées comme lues' });
  } catch (error) {
    console.error('Erreur markAllAsRead:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
