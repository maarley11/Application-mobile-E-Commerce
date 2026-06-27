# 🔵 GUIDE AVANCÉ : MOUHAMED — Architecte Flutter (PHASE 5)

Salut Mouhamed ! Ton UI est impeccable et 100% adaptée au Cahier des Charges (CDC). Ngary a également complété sa Phase 4 (Firebase Push, PDFs, OTP Réel).
Nous entrons maintenant dans la phase cruciale pour le Frontend : la **Phase 5 (Intégration API & Temps Réel)**.

Ton objectif est d'abandonner les "Mocks" locaux (données en dur) et de faire communiquer l'application Flutter avec l'API Node.js que Ngary est en train d'adapter au CDC.

---

## 🚀 LES MISSIONS FLUTTER (Phase 5)

### 📅 J14 : Client HTTP & Authentification Réelle
Il faut remplacer tes listes codées en dur par des requêtes HTTP sécurisées.

**Objectifs :**
1. **Client Dio / HTTP** : Configurer un `api_client.dart` avec des intercepteurs pour injecter automatiquement le token JWT du `User` dans le Header `Authorization: Bearer <token>`.
2. **`AuthProvider`** :
   - Connecter l'écran `login_screen.dart` au `POST /api/auth/request-otp` (qui enverra un vrai SMS via le backend).
   - Connecter `otp_screen.dart` au `POST /api/auth/verify-otp`.
   - Stocker le JWT reçu de manière sécurisée via `flutter_secure_storage`.
3. **`BusinessProfileScreen`** :
   - Envoyer le Ninea, le nom et l'adresse à `POST /api/users/profile`.

### 📅 J15 : Raccordement du Catalogue & des Commandes
Le cœur du E-Commerce doit être dynamique.

**Objectifs :**
1. **`ProductProvider`** :
   - Câbler `GET /api/products` pour charger le catalogue.
   - S'assurer que le modèle local `Product` "parse" bien le JSON retourné par le backend (`publicPrice`, `proPrice`, etc.).
2. **`CartProvider` & Paiements (Webhook Phase 4 Ngary)** :
   - Lors de la validation dans `checkout_screen`, faire un `POST /api/orders`.
   - L'API renverra une URL de paiement (agrégateur). L'application Flutter doit ouvrir cette URL dans un WebView.
3. **`OrderProvider`** :
   - Faire un `GET /api/orders/history` pour l'écran Historique.

### 📅 J16 : Push Notifications (Firebase) & Dashboard Analytics
Réceptionner les événements créés par Ngary dans sa Phase 4 et afficher le dashboard.

**Objectifs :**
1. **Firebase Cloud Messaging (FCM)** :
   - Installer `firebase_core` et `firebase_messaging`.
   - Générer le token FCM sur le téléphone et l'envoyer au backend via `PUT /api/users/fcm-token`.
   - Écouter les notifications entrantes (ex: Commande Expédiée) et les ajouter au `NotificationsProvider`.
2. **`DashboardProScreen`** :
   - Faire un `GET /api/dashboard/stats` pour récupérer les vraies économies réalisées et le compte de livraisons restantes.

---

## 🛠️ Méthode de Travail avec l'IA
Puisque nous collaborons ensemble, nous allons suivre le plan d'implémentation (Implementation Plan) et attaquer l'intégration API écran par écran. Prépare-toi à faire chauffer le package `dio` !
