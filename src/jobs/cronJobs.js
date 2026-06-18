const cron = require('node-cron');
const { User } = require('../models');

const startCronJobs = () => {
  // Exécuté tous les lundis à 00:00 (minuit)
  cron.schedule('0 0 * * 1', async () => {
    console.log('Exécution du CRON: Réinitialisation des freeDeliveriesUsedThisWeek');
    try {
      await User.update(
        { freeDeliveriesUsedThisWeek: 0 },
        { where: {} } // Met à jour tous les utilisateurs
      );
      console.log('CRON terminé avec succès.');
    } catch (error) {
      console.error('Erreur lors de l\'exécution du CRON:', error);
    }
  });
};

module.exports = startCronJobs;
