# 🟢 GUIDE FINAL : NGARY — Lead Backend Node.js (PHASE 4)

Félicitations pour avoir accompli la Phase 3 (Abonnements, Analytics, Webhooks) !
C'est la dernière ligne droite pour finaliser l'API et la préparer pour la mise en production.

Dans cette Phase 4, tu vas gérer les notifications, le moteur de recherche avancé, la mise à jour des statuts de livraison pour alimenter la Timeline Frontend, et la sécurisation finale.

---

## 🏗️ Standards de Sécurité Finaux (Rappel)
- **CORS :** Il est impératif de configurer proprement les CORS pour n'accepter que les requêtes venant du Frontend (Flutter Web) et des Webhooks des opérateurs.
- **Rate Limiting :** Protéger les routes sensibles (Login, OTP, Webhook) contre les attaques par force brute.
- **Nettoyage :** Retirer tous les `console.log` inutiles avant de déployer.

---

## 🚀 PROMPTS NODE.JS OPTIMISÉS (Phase 4)

Copie-colle ces blocs dans ton assistant Antigravity pour générer la suite de ton code.

### 📅 J11 : Système de Notifications in-app
```text
Développe un système de notifications in-app pour l'API Express.

⚠️ INSTRUCTION CRITIQUE : Utilise les modèles existants et crée une nouvelle migration/modèle pour `Notification`.

Exigences :
1. Modèle `Notification` :
   - `id` (UUID), `userId` (FK), `title` (String), `message` (Text), `type` (Enum: 'ORDER', 'PROMO', 'SYSTEM'), `isRead` (Boolean, default: false).
2. Routes (Contrôleur `notificationController.js`) :
   - `GET /api/notifications` : Retourne les 20 dernières notifications de l'utilisateur connecté, triées par date décroissante.
   - `PATCH /api/notifications/:id/read` : Marque une notification spécifique comme lue.
   - `PATCH /api/notifications/read-all` : Marque TOUTES les notifications de l'utilisateur comme lues.
3. Logique :
   - Protège ces routes avec le middleware JWT existant.
```

### 📅 J12 : Moteur de Recherche Avancé
```text
Améliore le contrôleur des Produits (`productController.js`) pour y ajouter de la recherche et du filtrage.

⚠️ INSTRUCTION CRITIQUE : Utilise les opérateurs avancés de Sequelize (`[Op.like]`, `[Op.iLike]` si PostgreSQL, `[Op.between]`) pour optimiser la recherche sans récupérer toute la base en mémoire.

Exigences (`GET /api/products`) :
1. Recherche Full-Text : Gérer un query parameter `?search=chocolat` pour chercher dans le titre ou la description.
2. Filtre par Catégorie : Gérer `?category=Epicerie`.
3. Filtre par Prix : Gérer `?minPrice=1000&maxPrice=5000`.
4. Pagination : Implémenter le couple `?page=1&limit=20`. Renvoyer le total de pages et de produits (utiliser `findAndCountAll` de Sequelize).
```

### 📅 J13 : Statuts de Livraison (Timeline)
```text
Développe la logique de mise à jour des statuts de commandes pour le tracking.

⚠️ INSTRUCTION CRITIQUE : Le statut d'une commande impacte le Frontend (qui affiche une timeline). Assure-toi que la liste des statuts correspond parfaitement au modèle.

Exigences :
1. Vérifier que le modèle `Order` contient une enum `status` avec au moins : `PENDING`, `PREPARING`, `SHIPPING`, `DELIVERED`.
2. Route `PATCH /api/orders/:id/status` (Protégée pour l'ADMIN ou script interne) :
   - Permet de faire avancer le statut d'une commande.
3. Création automatique de notification :
   - Dans le contrôleur, dès qu'une commande change de statut, créer une entrée dans la table `Notification` (ex: "Votre commande CMD-XX est en cours de livraison !").
```

### 📅 J14 : Sécurité et Préparation au Déploiement
```text
Sécurise l'API Express pour un passage en production.

⚠️ INSTRUCTION CRITIQUE : Cette étape garantit que l'application ne sera pas hackée.

Exigences :
1. Installe et configure le package `helmet` pour sécuriser les headers HTTP.
2. Installe et configure le package `cors` :
   - N'autorise que les domaines spécifiques (ton domaine frontend Flutter Web).
3. Installe et configure `express-rate-limit` :
   - Max 5 tentatives par minute sur `/api/auth/register` et `/api/auth/verify-otp`.
4. Centralise la gestion d'erreur dans un middleware `errorHandler.js` pour ne jamais exposer les stacktraces (erreurs Sequelize) à l'utilisateur final en mode `NODE_ENV=production`.
```

---

## 🔍 Validation Finale
Avant de clore le backend :
- Vérifie que **toutes** tes PR ont été mergées sur `main`.
- Fais un test complet (Postman ou ThunderClient) de la route d'inscription, d'achat, de passage au rôle PRO, et de consultation des notifications.
- La balle sera dans le camp de Mouhamed pour brancher le Frontend Flutter sur tes superbes APIs !
