# ⚙️ GUIDE OFFICIEL : NGARY (Architecte Backend & Base de Données)

Salut Ngary,

Le Front-end de l'application mobile Baana (Flutter) est désormais **100% validé et intégré** selon les maquettes "Héritage Signature Premium".
Toutes les pages sont prêtes, le design est finalisé (un fond uni très épuré, avec notre couleur de marque Vert Émeraude Profond `#006C49`), et **tous les boutons de l'interface attendent désormais tes données pour s'animer**.

Ton rôle est critique : tu dois développer l'API REST (Node.js/Express) et la base de données (PostgreSQL) pour que **chaque bouton de l'application réagisse et mène bien quelque part**. L'application Front-end est actuellement "branchée dans le vide" et attend tes endpoints.

Voici la feuille de route exhaustive, ainsi que les **prompts exacts** que tu pourras utiliser avec l'IA pour générer ton code à la vitesse de l'éclair.

---

## 🎯 1. Standards Techniques Exigés

- **Stack** : Node.js, Express.js.
- **Base de données** : **PostgreSQL** via l'ORM **Sequelize**. (*Note : Le SQLite actuel doit être remplacé par Postgres dès ton premier commit*).
- **Sécurité** : JWT (JSON Web Tokens) pour les sessions stateless. Validation rigoureuse des inputs (ex: `express-validator`).
- **Fiabilité** : Les prix doivent **toujours** être calculés par ton serveur. Le front-end t'enverra juste des IDs de produits, c'est à toi de vérifier la base de données pour le calcul du total de la commande. Les devises (FCFA) doivent être stockées en type `INTEGER`.

---

## 🔗 2. Les Routes API à Créer (Pour connecter le Front-end)

### 🔐 A. Authentification & Profil Utilisateur (OTP)
* **`POST /api/auth/register`** : Inscription (nom, téléphone).
* **`POST /api/auth/verify-otp`** : Vérifie l'OTP (hardcodé à "1234" pour le dev) et retourne le JWT.
* **`POST /api/auth/login`** : Connexion via téléphone.
* **`POST /api/auth/business-profile`** : Mise à jour des infos pro (NINEA, nom d'entreprise).
* **`GET /api/auth/me`** : Retourne les infos de l'utilisateur connecté (`isPro`, `name`, `phone`, etc.).

### 🛍️ B. Catalogue & Produits
* **`GET /api/categories`** : Retourne la liste des catégories (Alimentaire, Ménager, etc.).
* **`GET /api/products`** : Retourne le catalogue. Structure attendue par le Front :
  `{ "id": "1", "categoryId": "2", "name": "Huile", "publicPrice": 12500, "proPrice": 10500, "imageUrl": "...", "stock": 50, "badge": "PROMO" }`

### 🛒 C. Panier & Commandes (Checkout Sécurisé)
* **`POST /api/orders`** : Confirme la commande. Body: `{ paymentMethod, items: [{productId, quantity}] }`. *Transaction PostgreSQL obligatoire*. Applique `proPrice` si `user.isPro`.
* **`GET /api/orders`** : Historique des commandes.
* **`GET /api/orders/:id`** : Détails (statut, livreur) pour la page "Suivi de Commande".

### 📈 D. Dashboard "Baana Pro"
* **`GET /api/dashboard/stats`** : Retourne `totalOrders`, `totalSpent`, `savings`.
* **`GET /api/dashboard/sales-chart`** : Historique des achats pour affichage graphe.

### ⭐ E. Abonnements Premium
* **`POST /api/subscription/upgrade`** : Passe l'utilisateur en `isPro = true` et crée une ligne dans `Subscriptions`.

---

## 🤖 3. Prompts Prêts à l'Emploi pour l'IA (Ton Workflow)

Pour avancer très vite, copie-colle ces prompts directement à l'assistant IA (Antigravity / Gemini) dans ton environnement de développement. L'IA écrira et testera le code pour toi.

### ÉTAPE 1 : Rétablir PostgreSQL & Virer SQLite
> **PROMPT À DONNER À L'IA :**
> *"Je dois configurer mon backend Node.js. Désinstalle le package `sqlite3` et configure `src/config/database.js` pour utiliser **PostgreSQL** via l'ORM Sequelize. Lis les variables du fichier `.env` (DB_NAME, DB_USER, DB_PASSWORD). Supprime définitivement l'ancien fichier `database.sqlite`. Confirme que la connexion à Postgres réussit avec `npm run dev`."*

### ÉTAPE 2 : Modèles Catalogue & Seeders
> **PROMPT À DONNER À L'IA :**
> *"Crée les modèles Sequelize `Category` (name) et `Product` (name, description, publicPrice INTEGER, proPrice INTEGER, stock INTEGER, imageUrl, badge, categoryId). Configure les relations 1:N dans `src/models/index.js` (avec onDelete: CASCADE). Ensuite, écris et exécute un script `src/seeders/init_seed.js` qui vide la DB et insère 3 catégories et 10 produits locaux du Sénégal. Assure-toi de créer la route GET `/api/products` qui renvoie ce JSON au client."*

### ÉTAPE 3 : Système de Commande Ultra-Sécurisé (Checkout)
> **PROMPT À DONNER À L'IA :**
> *"Crée les modèles `Order` et `OrderItem`. Développe la route POST `/api/orders` protégée par le middleware JWT. Cette route reçoit `paymentMethod` et `items` [{productId, quantity}]. Tu DOIS utiliser une transaction Sequelize (`sequelize.transaction()`). Pour chaque item, vérifie si le stock est suffisant (sinon rollback complet et erreur 400). Détermine le prix unitaire selon si `req.user.isPro` est true ou false (publicPrice vs proPrice). Calcule le total en backend, décrémente le stock, sauvegarde la commande et commit la transaction."*

### ÉTAPE 4 : Dashboard Pro & Analytique
> **PROMPT À DONNER À L'IA :**
> *"Développe la route GET `/api/dashboard/stats` protégée par JWT. L'utilisateur doit être `isPro`. Utilise l'agrégation SQL (Sequelize fn et col) pour calculer et retourner pour le mois en cours : `totalOrders` (nombre de commandes), `totalSpent` (somme dépensée), et `savings` (économie réalisée grâce à la différence entre publicPrice et proPrice). Optimise la requête pour qu'elle réponde en moins de 100ms."*

### ÉTAPE 5 : Suivi de Commande & Historique
> **PROMPT À DONNER À L'IA :**
> *"Crée les routes GET `/api/orders` (pour lister les commandes de l'utilisateur) et GET `/api/orders/:id` (pour voir le suivi d'une commande spécifique). Pour le suivi, ajoute un champ `status` à la table Order (Confirmée, En préparation, En route, Livrée) et renvoie-le au client pour que l'UI Flutter puisse animer la timeline."*

L'objectif final est simple : **Quand on appuie sur un bouton de l'app mobile, ça doit déclencher une de ces routes, et l'interface doit se mettre à jour en temps réel.**

Bon courage Ngary, on compte sur toi pour un backend solide comme un roc !
