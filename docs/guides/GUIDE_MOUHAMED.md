# 📱 GUIDE OFFICIEL : MOUHAMED (Architecte & Lead Mobile Flutter)

Ce document centralise ton rôle, tes responsabilités, les standards techniques que tu as fixés pour l'application Baana, ainsi que l'état d'avancement de ton travail. Il inclut également **des prompts exacts** que tu peux me fournir (à moi, ton assistant Antigravity) pour accomplir les prochaines étapes.

## 🎯 Ton Rôle
Tu es le **cerveau de l'application**. Tu portes deux casquettes majeures :
1. **Architecte Système** : Tu décides des choix technologiques, de la structure des données et tu valides (Code Review) le travail du backend (Ngary) pour t'assurer que les calculs financiers (Checkout) et la sécurité sont impeccables.
2. **Lead Developer Mobile (Flutter)** : Tu conçois l'intégralité de l'application mobile. Tu as la lourde tâche de fournir une expérience utilisateur (UX) ultra-premium et réactive.

---

## 🏗️ Standards Techniques Flutter (Tels que tu les as définis)

### 1. Architecture & State Management
- **Gestion d'État** : Utilisation exclusive de `Provider` (ex: `AuthProvider`, `CartProvider`, `OrderProvider`, `ProductProvider`).
- **Navigation** : `GoRouter` pour une gestion fluide des routes et du deep linking (notamment pour WhatsApp).
- **Séparation des responsabilités** : Les appels API sont gérés dans des `Services` (`AuthService`), tandis que l'état et la logique métier résident dans les `Providers`.

### 2. Réseau & Sécurité
- **Client HTTP** : `Dio` avec une configuration centralisée (`api_client.dart`).
- **Intercepteurs** : Un intercepteur ajoute automatiquement le `Bearer Token` JWT à chaque requête sortante vers le backend de Ngary.
- **Stockage Sécurisé** : Le token JWT est stocké de manière chiffrée avec `flutter_secure_storage`.

### 3. Design System & UI/UX (Le point fort de Baana)
- **Thème Premium** : Tu refuses le design basique. L'application utilise des palettes harmonieuses (`BaanaColors`), des polices modernes (`BaanaTypography`), du Glassmorphism, et des dégradés subtils.
- **Micro-animations** : Les composants interactifs (boutons, cartes produits) intègrent des animations de survol et de clic.
- **Widgets Réutilisables** : Tout est modularisé (`BaanaInput`, `BaanaButton`, `ProductCard`).

---

## 📊 État d'Avancement (Mobile)

**Statut Global : 90% Terminé** 🟢

Tu as réalisé un travail colossal. L'intégration de toutes les phases (A à F) est achevée côté Front :
- L'UI de tous les écrans est prête.
- Le flux d'authentification inclut désormais l'onboarding complet exigé par le Cahier des Charges (saisie du NINEA, du nom de la boutique et de l'adresse pour les Pros).
- Le panier distingue dynamiquement les `publicPrice` et `proPrice`.
- Le Dashboard Pro affiche les économies, les livraisons gratuites et les points de fidélité.

---

## 🚀 Tes Prochaines Étapes (La Feuille de Route Détaillée)

Voici exactement ce que tu dois faire pour finaliser ton côté. **Tu peux fournir ces prompts directement à moi (Antigravity) pour que j'exécute ces tâches pour toi.**

### ÉTAPE 1 : Configuration de Firebase (FCM)
*Actuellement, au lancement de Flutter Web, une erreur Firebase (`FirebaseOptions cannot be null`) s'affiche car le projet Firebase n'est pas initialisé.*

> **PROMPT À ME DONNER :**
> "Antigravity, agis en tant que développeur Flutter. Nous devons régler l'erreur d'initialisation de Firebase.
> 
> **Instructions strictes :**
> 1. Explique-moi d'abord comment utiliser Firebase CLI (`firebase login`) et FlutterFire CLI (`flutterfire configure`) pour lier mon application à un projet Firebase existant.
> 2. Une fois que j'aurai généré le fichier `firebase_options.dart`, modifie le fichier `lib/main.dart` pour initialiser correctement Firebase avec ces options (`await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`).
> 3. Mets à jour le fichier `lib/services/push_notification_service.dart` pour qu'il utilise cette configuration officielle au lieu de l'initialisation fallback actuelle."

### ÉTAPE 2 : Revue de Code Backend (Validation de l'Architecture)
*En tant qu'Architecte, tu dois vérifier que Ngary a bien respecté les standards de sécurité, particulièrement sur les commandes (Transactions SQL).*

> **PROMPT À ME DONNER :**
> "Antigravity, agis en tant qu'Architecte Logiciel. Je dois faire une revue de code du travail de Ngary sur la route de Checkout (`POST /api/orders`) et le Dashboard Pro (`GET /api/dashboard/pro`).
> 
> **Instructions strictes :**
> 1. Lis les fichiers `src/controllers/order.controller.js` et `src/controllers/dashboard.controller.js` (si Ngary les a créés).
> 2. Vérifie qu'il utilise bien `sequelize.transaction()` pour le checkout. Si le stock n'est pas décrémenté dans la transaction, ou si les prix (`proPrice`/`publicPrice`) ne sont pas récupérés depuis la base de données, signale-le comme un bug critique.
> 3. Vérifie que le Dashboard Pro utilise bien l'agrégation SQL (par exemple `SUM()`, `COUNT()`) plutôt que de ramener des tableaux d'objets en mémoire Node.js.
> 4. S'il y a des failles, propose le code exact pour corriger le backend de Ngary."

### ÉTAPE 3 : Tests End-to-End (E2E)
*Une fois que Ngary aura finalisé le backend complet (avec PostgreSQL), il faudra tester tout le parcours métier dans l'application mobile.*

> **PROMPT À ME DONNER :**
> "Antigravity, le backend complet de Ngary est maintenant en place. Nous devons tester le parcours utilisateur complet en Flutter.
> 
> **Instructions strictes :**
> 1. Rédige un plan de test manuel précis (Inscription -> OTP -> Connexion -> Ajout produit -> Panier -> Checkout avec paiement Mobile Money).
> 2. Alternativement, utilise tes outils pour créer un test d'intégration Flutter dans `integration_test/app_test.dart` qui simule ces étapes avec la vraie API.
> 3. Assure-toi que les appels réseau (Dio) réussissent bien et que les erreurs renvoyées par le backend (ex: stock insuffisant) s'affichent correctement sous forme de SnackBar dans l'application."
