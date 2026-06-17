# 🧠 Mémoire du Projet Baana (E-Commerce Premium Sénégal)

Ce document sert de mémoire à long terme pour le projet Baana. Il doit être lu par tout agent IA reprenant le projet pour s'assurer que les directives, l'architecture et les choix de design sont respectés.

## 1. Vision & Design (CRITIQUE)
- **Positionnement** : Application E-Commerce B2C et B2B orientée marché sénégalais (Alimentaire, Gros & Détail).
- **Style** : **PREMIUM, LUXE, RAFFINÉ**. L'application ne doit ABSOLUMENT PAS avoir une "vibe coding" (pas de couleurs basiques `Colors.red`, pas de designs plats et simplistes). 
- **Éléments visuels obligatoires** :
  - **Glassmorphism** : Utilisation de `BackdropFilter` (flou) sur les app bars et les éléments superposés.
  - **Textures & Dégradés** : Utilisation de motifs (ex: motif Manjak ou wax subtil), de Mesh Gradients dynamiques (comme le `AnimatedReactiveBackground` dans le catalogue).
  - **Typographie** : Typographies Google Fonts très propres (`Outfit` ou `Inter` pour les titres, `Plus Jakarta Sans` ou `Roboto` pour le corps).
  - **Micro-animations** : Tout doit être fluide (boutons qui réagissent, éléments qui glissent au scroll).

## 2. Architecture Technique (Flutter)
Nous suivons rigoureusement le guide de Mouhamed (Architecte Flutter) :
- **State Management** : `Provider` (`ChangeNotifier`). Nous avons `AuthProvider`, `ProductProvider`, et `CartProvider`.
- **Navigation** : `GoRouter` avec un système de `ShellRoute` pour le `MainLayoutScreen` (BottomNavigationBar).
- **Réseau / Backend** : Serveur Node.js (dossier `backend/` ou `src/`). Communication via `Dio`.
- **Performances** : Utilisation de `Sliver` (CustomScrollView, SliverAppBar, SliverGrid) pour les listes.
- **Chargement** : Utilisation de `Shimmer` pour les skeletons de chargement. PAS de simples `CircularProgressIndicator` au milieu de l'écran pour les listes.

## 3. État d'avancement (Ce qui est fait)
- **J1-J3 (Fondations & Auth)** : SplashScreen animé, Onboarding (3 pages avec animations Lottie/Images), Register (capture du nom), Login.
- **J4-J5 (Accueil & Navigation)** : `MainLayoutScreen` avec bottom nav. `HomeScreen` premium avec carrousels, grilles de catégories, et bonjour dynamique.
- **J5.5 (Catalogue)** : `CatalogScreen` avec background animé réactif au scroll, filtres (Chips), SliverGrid.
- **J6-J7 (Tunnel de Commande)** : 
  - `CartProvider` et `CartScreen` (gestion de quantité, swipe-to-delete).
  - `CheckoutScreen` (Résumé et choix de paiement).
  - `PaymentMobileMoneyScreen` (Écran complet très premium façon carte Baana Pay).
  - `ConfirmationScreen` (Succès et vidage du panier).

## 4. Prochaines Étapes (À faire)
- **J8 : Profil & Dashboard Pro** :
  - Interface Utilisateur classique (`ProfileScreen`).
  - Interface Dashboard "Pro" (B2B) avec des graphiques d'analyse des KPIs (utiliser `fl_chart` ou similaire).
- **J9-J10 : Abonnements & Historique** :
  - Système d'abonnement / fidélité.
  - Historique des commandes avec une UI de "Timeline" (Suivi de commande façon Uber Eats/Glovo).

## 5. Notes Techniques Actuelles
- L'application tourne sur le web (`flutter run -d chrome`).
- Le serveur Node local (`node src/server.js`) gère l'authentification et les produits mockés.
- Toujours penser à vérifier le `flutter pub add` si l'on ajoute un package (ex: `go_router`, `provider`, `shared_preferences`).
- Les logos et assets sont dans `assets/images/logo/baana_logo.png`.

---
*Ce fichier garantit que nous ne perdrons jamais le fil, même lors d'une nouvelle session de travail.*
