/**
 * Service FCM — Firebase Cloud Messaging
 * Envoie des notifications Push aux appareils mobiles des utilisateurs.
 *
 * Note : Pour que ce service fonctionne en production, tu dois :
 * 1. Télécharger le fichier JSON de clé de compte de service Firebase
 *    (Console Firebase → Paramètres du projet → Comptes de service → Générer une clé)
 * 2. Le placer dans : src/config/firebase-service-account.json
 * 3. Définir FIREBASE_PROJECT_ID dans ton fichier .env
 *
 * En mode développement (sans le fichier de clé), les notifications sont simulées.
 */

let firebaseAdmin = null;

// Tentative d'initialisation de firebase-admin
// Graceful degradation si firebase-admin n'est pas installé
try {
  const admin = require('firebase-admin');
  const fs = require('fs');
  const path = require('path');

  const serviceAccountPath = path.join(__dirname, '../config/firebase-service-account.json');

  if (fs.existsSync(serviceAccountPath) && !admin.apps.length) {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    firebaseAdmin = admin;
    console.log('✅ Firebase Admin initialisé avec succès.');
  } else if (!admin.apps.length) {
    console.warn('⚠️  FCM : firebase-service-account.json introuvable. Les notifications Push seront simulées en console.');
  }
} catch (e) {
  console.warn('⚠️  FCM : firebase-admin non installé. Les notifications Push seront simulées en console.');
}

/**
 * Envoie une notification Push via FCM.
 * @param {string} fcmToken - Le token FCM de l'appareil cible (stocké dans User.fcmToken)
 * @param {string} title    - Titre de la notification (ex: "Commande en cours de livraison")
 * @param {string} body     - Corps du message (ex: "Votre commande #SDP-12345 est en route !")
 * @param {object} data     - (optionnel) Données supplémentaires envoyées à l'app (ex: { orderId: '...' })
 * @returns {Promise<void>}
 */
async function sendPushNotification(fcmToken, title, body, data = {}) {
  // Si pas de token FCM, on ne peut pas envoyer
  if (!fcmToken) {
    console.log(`📵 FCM : Aucun token FCM pour cet utilisateur. Notification ignorée : "${title}"`);
    return;
  }

  // Mode simulation (firebase-admin non configuré)
  if (!firebaseAdmin) {
    console.log('─────────────────────────────────────────────────');
    console.log('📲 [SIMULATION FCM] Notification Push envoyée :');
    console.log(`   Token: ${fcmToken.slice(0, 20)}...`);
    console.log(`   Titre: ${title}`);
    console.log(`   Corps: ${body}`);
    if (Object.keys(data).length) console.log(`   Data:  ${JSON.stringify(data)}`);
    console.log('─────────────────────────────────────────────────');
    return;
  }

  // Envoi réel via Firebase
  try {
    const message = {
      notification: { title, body },
      data: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
      token: fcmToken,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'baana_orders',
        },
      },
      apns: {
        payload: {
          aps: { sound: 'default', badge: 1 },
        },
      },
    };

    const response = await firebaseAdmin.messaging().send(message);
    console.log(`✅ Notification FCM envoyée : ${response}`);
  } catch (error) {
    // Ne pas faire planter le serveur si FCM échoue
    console.error(`❌ Erreur FCM : ${error.message}`);
  }
}

module.exports = { sendPushNotification };
