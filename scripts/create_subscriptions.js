const { sequelize, User, Subscription } = require('../src/models');

async function run() {
  try {
    await sequelize.authenticate();
    console.log('✅ Connexion à la base de données établie');

    // S’assurer que toutes les tables existent (au cas où)
    await sequelize.sync();

    // Récupérer tous les utilisateurs
    const users = await User.findAll();

    for (const user of users) {
      // Date d’expiration : +30 jours à partir d’aujourd’hui
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 30);

      await Subscription.upsert({
        userId:   user.id,
        plan:     'basic',   // valeur obligatoire (ENUM)
        status:   'active',  // valeur obligatoire (ENUM)
        startedAt: new Date(),
        expiresAt,
      });

      console.log(`💡 Subscription créée/mise à jour → userId=${user.id}`);
    }

    console.log('✅ Tous les abonnements ont été créés/mis à jour.');
    process.exit(0);
  } catch (err) {
    console.error('❌ Erreur :', err);
    process.exit(1);
  }
}

run();
