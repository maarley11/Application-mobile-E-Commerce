# 🚀 Guide Ngary : Phase 7 - Finalisation, Innovations CDC et Tests de bout en bout

Salut Ngary, excellent travail sur la Phase 6 ! La timeline, le suivi GPS et les points de fidélité ont été intégrés avec succès côté Flutter (poussé sur le repo GitHub). 

Pour finaliser le projet et livrer un produit complet répondant au cahier des charges (CDC) avec toutes les innovations prévues, voici les dernières étapes (Phase 7).

---

## 🌟 1. Nouvelles Innovations (Cahier des Charges)

### A. Notifications Push (Firebase Cloud Messaging - FCM)
Pour tenir le client informé en temps réel, nous devons envoyer des notifications Push lorsqu'une commande change de statut.
- **Action Backend :** Intégrer `firebase-admin` dans Node.js.
- **Logique :** À chaque `PUT /api/orders/:id/status`, si le statut change (ex: `PREPARING` -> `SHIPPING`), envoyer une notification via FCM au `fcmToken` de l'utilisateur.
- **Modèle User :** Ajouter un champ `fcmToken` (String) au modèle Utilisateur.

### B. Génération de Factures PDF
Les clients (surtout les Pros) ont besoin de télécharger leurs factures.
- **Action Backend :** Créer une route `GET /api/orders/:id/invoice`.
- **Logique :** Utiliser une librairie comme `pdfkit` ou `puppeteer` pour générer un beau PDF (avec le logo Baana, le NINEA du client Pro, et le détail de la commande). Retourner le buffer PDF.

### C. Webhooks de Paiement (Mobile Money)
Pour le moment, le paiement "mobile_money" est simulé.
- **Action Backend :** Préparer les endpoints pour recevoir les webhooks des agrégateurs de paiement (ex: PayDunya, Wave API, ou Orange Money).
- **Logique :** Créer `POST /api/payments/webhook`. Lorsqu'un paiement est confirmé par l'API tierce, mettre la commande à `paymentStatus = 'PAID'` et `status = 'CONFIRMED'`.

---

## 🧪 2. Guide de Test de l'Application (End-to-End)

Pour vérifier que tout fonctionne parfaitement ensemble (Backend + Flutter), voici comment procéder :

### Étape 1 : Lancer l'environnement
1. **Backend :** 
   - Assure-toi que PostgreSQL est lancé.
   - Démarre le serveur Node.js : `npm run dev`.
   - L'API tourne sur `http://localhost:5000`.
2. **Flutter (Frontend) :**
   - Connecte ton téléphone Android (avec le mode développeur activé) ou lance un émulateur.
   - Dans le dossier `baana_app`, lance : `flutter run`.

### Étape 2 : Test du Flux Utilisateur
1. **Inscription / Connexion :** 
   - Entre un numéro de téléphone dans l'app Flutter.
   - Regarde les logs de ton backend Node.js pour voir l'OTP généré.
   - Saisis l'OTP dans l'app pour te connecter.
2. **Catalogue et Panier :**
   - Ajoute des produits au panier depuis l'écran principal.
   - Vérifie dans Postman ou dans ta DB (`SELECT * FROM "CartItems"`) que le panier est bien synchronisé avec l'API.
3. **Commande et Google Maps :**
   - Va dans le panier, clique sur "Commander".
   - Sur l'écran de paiement, clique sur l'icône de carte et sélectionne une adresse (cela va renseigner `deliveryLatitude` et `deliveryLongitude`).
   - Valide la commande.
   - **Vérification Backend :** Vérifie que la commande est créée en DB, avec le statut `PENDING` et que la `timeline` possède une entrée initiale.

### Étape 3 : Test du Tracking et des Points de fidélité
1. **Simulation du Livreur (Via Postman) :**
   - Fais un `PUT /api/orders/:id/status` avec `status: "SHIPPING"`, `deliveryPersonName: "Ngary"`, `deliveryPersonPhone: "77 000 00 00"`.
   - **Côté Flutter :** Retourne sur l'écran "Suivi de commande", tu devrais voir la Timeline se mettre à jour dynamiquement et afficher les infos du livreur !
2. **Livraison et Fidélité :**
   - Fais un `PUT /api/orders/:id/status` avec `status: "DELIVERED"`. (Dans ta logique backend, cela doit déclencher l'ajout des points de fidélité au client).
   - **Côté Flutter :** Va dans "Mon Profil". Tu devrais voir tes points de fidélité augmenter.

---

## 🚀 3. Guide de Déploiement (Mise en Production)

Une fois tous les tests validés en local, l'application doit être déployée pour être accessible au public. Voici la marche à suivre complète :

### A. Déploiement du Backend (Node.js / Express / PostgreSQL)
Le backend doit être hébergé sur un serveur distant (VPS, Heroku, Render, AWS, etc.).

**1. Préparation de la Base de Données (PostgreSQL)**
- Utilise un service managé (comme Supabase, AWS RDS, ou Render PostgreSQL) pour héberger ta base de données de production.
- Exécute tes scripts de migration (`npx sequelize-cli db:migrate`) sur cette base distante pour recréer la structure.

**2. Configuration des Variables d'Environnement (.env)**
Sur ton serveur de production, tu devras configurer les variables suivantes :
```env
PORT=5000
NODE_ENV=production
DATABASE_URL=postgres://user:password@hôte:5432/nom_bdd
JWT_SECRET=un_secret_tres_long_et_complexe_en_production
FIREBASE_SERVER_KEY=ta_cle_secrete_firebase_pour_les_notifications
```

**3. Déploiement sur un VPS (Exemple avec Ubuntu)**
- Connecte-toi en SSH à ton serveur.
- Clone le dépôt GitHub : `git clone https://github.com/maarley11/Application-mobile-E-Commerce.git`
- Installe les dépendances : `npm install --production`
- Utilise **PM2** pour faire tourner Node.js en arrière-plan et le redémarrer en cas de crash :
  ```bash
  npm install -g pm2
  pm2 start src/server.js --name "baana-api"
  pm2 startup
  pm2 save
  ```
- **Nginx & SSL :** Configure Nginx comme Reverse Proxy pour rediriger le port 80/443 vers le port 5000. Utilise **Certbot (Let's Encrypt)** pour générer un certificat SSL/HTTPS gratuit. L'application mobile *doit* communiquer avec une API en HTTPS.

### B. Déploiement de l'Application Mobile (Flutter)

Une fois le backend en ligne et l'URL de base (ex: `https://api.baana.sn/api`) mise à jour dans le code Flutter (`api_client.dart`), Mouhamed (ou toi) pourra compiler l'application.

**1. Android (Google Play Store)**
- Assure-toi que les clés d'API Google Maps et Firebase sont configurées pour la production (SHA-1 release).
- Signe l'application en générant un `keystore`.
- Compile le build final : 
  ```bash
  flutter build appbundle --release
  ```
- Soumets le fichier `.aab` généré sur la Google Play Console.

**2. iOS (App Store)**
- Nécessite un Mac avec Xcode.
- Configure les certificats de distribution et le Provisioning Profile via un compte Apple Developer.
- Compile le build :
  ```bash
  flutter build ipa --release
  ```
- Utilise Transporter pour uploader le `.ipa` sur App Store Connect et soumets-le pour validation.

---

## 🏁 Conclusion

Dès que tu as implémenté les notifications FCM et la génération PDF, nous serons à 100% du cahier des charges !
N'oublie pas de faire un `git pull` de la branche `main` pour récupérer le code Flutter (intégration Google Maps, Timeline, Points) que nous venons juste de pusher.

Bon code et bons tests ! 🚀
