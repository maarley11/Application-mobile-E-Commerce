// make_pro_and_subscription.js
/**
 * make_pro_and_subscription.js
 *
 * - Passe tous les utilisateurs en mode Pro (isPro = true)
 * - Crée ou met à jour une ligne Subscription pour chaque utilisateur
 *   avec un plan « basic », status « active », et une date d’expiration
 *   30 jours après la création.
 */

const { sequelize, User, Subscription } = require('../src/models');

async function run() {
  try {
    await sequelize.authenticate();
    // Synchroniser les modèles (crée les tables si elles n'existent pas)
    await sequelize.sync();
    console.log('✅ Connexion à la base de données établie');

    // 1️⃣ Mettre tous les utilisateurs en Pro
    const [updatedCount] = await User.update(
      { isPro: true },
      { where: {} }                 // aucun filtre → tous les utilisateurs
    );
    console.log(`✅ User ${updatedCount} mis à jour : isPro = true`);

    // 2️⃣ Créer / mettre à jour l’abonnement pour chaque utilisateur
    const users = await User.findAll();

    for (const user of users) {
      // Date d’expiration : aujourd’hui + 30 jours
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 30);

      await Subscription.upsert({
        userId: user.id,
        plan: 'premium',               // valeur obligatoire
        status: 'active',
        startedAt: new Date(),
        expiresAt,                  // valeur obligatoire
      });

      console.log(`💡 Subscription créée/mise à jour pour l'utilisateur id=${user.id}`);
await user.update({ subscriptionExpiresAt: expiresAt });
    }

    console.log('✅ Opération terminée.');
    process.exit(0);
  } catch (err) {
    console.error('❌ Erreur pendant l\'exécution du script :', err);
    process.exit(1);
  }
}

run();
