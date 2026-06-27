# 🟢 GUIDE FINAL : NGARY — Finalisation Backend + Tests E2E (Phase 6)

> **Date :** 27 juin 2026
> **De :** Mouhamed Youssouf Dioum (Architecte / Chef de projet)
> **Pour :** Ngary Diop (Développeur Backend)
> **Branche :** `main` — **Pull avant de commencer !**

---

Salut Ngary ! 👋

J'ai finalisé l'intégration complète du frontend Flutter avec ton backend Node.js. J'ai poussé un **gros commit** sur `main` qui inclut tous les correctifs d'intégration nécessaires pour que le frontend et le backend communiquent sans erreur.

Ce guide a **3 objectifs** :
1. ✅ Te permettre de **pull, lancer et tester** l'application complète
2. 🔧 Te donner les **innovations du CDC** à finaliser côté backend
3. 🧪 Te fournir un **scénario de test E2E** pour valider que tout marche

---

## 📥 ÉTAPE 1 : Récupérer et Lancer le Projet

### 1.1 — Pull le code

```bash
cd Application-mobile-E-Commerce
git pull origin main
```

### 1.2 — Installer les dépendances Backend

```bash
# À la racine du projet (là où se trouve src/app.js)
npm install
```

### 1.3 — Configurer le fichier `.env`

Un fichier `.env` existe déjà à la racine. **Vérifie qu'il correspond à ta config PostgreSQL locale :**

```env
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=baana_db
DB_USER=postgres
DB_PASSWORD=ton_mot_de_passe_postgres
JWT_SECRET=baana_super_secret_key_2026
JWT_EXPIRES_IN=30d
SMS_API_KEY=dummy_sms_api_key
ALLOWED_ORIGINS=http://localhost:3001,http://localhost:8080,http://localhost:5000
```

> ⚠️ **Modifie `DB_PASSWORD`** pour qu'il corresponde à ton mot de passe PostgreSQL local.

### 1.4 — Préparer la base de données

```bash
# Option A : Si tu veux repartir de zéro (recommandé pour tester)
psql -U postgres -c "DROP DATABASE IF EXISTS baana_db;"
psql -U postgres -c "CREATE DATABASE baana_db;"

# Lancer le seed (crée les tables + injecte les données de test)
node src/seeders/init_seed.js
```

Le seed va créer :
- ✅ 5 catégories (Alimentaire, Ménager, Cosmétique, Textile, Électronique)
- ✅ 17+ produits réalistes du marché sénégalais avec **double tarification** (`publicPrice` + `proPrice`)
- ✅ Un utilisateur de test : **+221770000000** avec le code OTP **1234**
- ✅ 2 plans d'abonnement (Hebdo 2500 FCFA / Mensuel 7500 FCFA)

### 1.5 — Démarrer le serveur backend

```bash
node src/server.js
```

Tu devrais voir :
```
Database connected
Database schema synced
Serveur démarré sur le port 3000
```

### 1.6 — Lancer le Frontend Flutter

Ouvre un **second terminal** :

```bash
cd baana_app
flutter pub get
flutter run -d chrome
```

> **Alternative :** Si tu as un émulateur Android configuré :
> ```bash
> flutter run
> ```

---

## 🧪 ÉTAPE 2 : Scénario de Test E2E Complet

Lance le backend (`node src/server.js`) et le frontend (`flutter run -d chrome`) en parallèle, puis suis ce parcours :

### Test 1 : Authentification
1. Sur l'écran d'accueil, appuie sur **"Commencer"**
2. Passe les 3 slides d'onboarding
3. Sur l'écran d'inscription, saisis le numéro : **`770000000`** (le +221 est ajouté automatiquement)
4. Appuie sur **"Recevoir le code"**
5. Sur l'écran OTP, saisis : **`1234`**
6. ✅ **Résultat attendu :** Tu es redirigé vers la page d'accueil avec les produits réels du catalogue

### Test 2 : Catalogue & Navigation
7. Vérifie que les **produits** sont chargés depuis la base de données (Riz Brisé, Huile Niinal, etc.)
8. Appuie sur les **filtres de catégorie** (Alimentaire, Ménager, etc.) → Les produits se filtrent
9. Appuie sur l'**icône de filtre** (tri) → Un BottomSheet s'affiche avec Prix ↑, Prix ↓, Nom A-Z
10. Appuie sur un **produit** → La fiche produit détaillée s'affiche
11. ✅ **Résultat attendu :** Navigation fluide, produits réels, filtres fonctionnels

### Test 3 : Panier & Commande
12. Sur une fiche produit, appuie sur **"Ajouter au panier"**
13. Navigue vers le **panier** (icône en haut à droite)
14. Modifie la **quantité** avec les boutons +/-
15. Appuie sur **"Commander"** → L'écran de checkout s'affiche
16. Appuie sur le **crayon** à côté de l'adresse → Une boîte de dialogue s'ouvre pour modifier l'adresse
17. Choisis un **mode de paiement** (Mobile Money ou Cash)
18. Appuie sur **"Confirmer & Payer"**
19. ✅ **Résultat attendu :** La commande est créée dans la base de données

### Test 4 : Historique des Commandes
20. Navigue vers l'onglet **"Commandes"** (barre de navigation en bas)
21. ✅ **Résultat attendu :** La commande que tu viens de passer apparaît dans l'historique

### Test 5 : Profil & Abonnement
22. Navigue vers l'onglet **"Profil"**
23. Appuie sur **"Devenir Pro"** ou **"Mon Abonnement"**
24. Appuie sur **"S'abonner"** (Mensuel à 7 500 FCFA)
25. ✅ **Résultat attendu :** L'abonnement est activé, les prix Pro s'affichent dans le catalogue

### Test 6 : Dashboard Pro
26. Sur le profil, appuie sur **"Mon Dashboard Pro"**
27. ✅ **Résultat attendu :** Les KPIs s'affichent (Total dépensé, Économies, Livraisons gratuites restantes, Points de fidélité)

### Test 7 : Support & Paramètres
28. Sur le profil, appuie sur **"Support & Aide"** → L'écran d'aide s'affiche
29. Appuie sur **"Paramètres"** → L'écran des réglages s'affiche
30. ✅ **Résultat attendu :** Navigation vers tous les écrans fonctionnelle, aucun bouton "mort"

---

## 🔧 ÉTAPE 3 : Innovations du CDC à Finaliser

Voici les fonctionnalités du Cahier des Charges qui nécessitent encore du travail côté backend. Ce sont les **innovations** qui différencient Baana d'une simple boutique en ligne.

---

### 🚀 Innovation 1 : Panier Serveur (Cart API)

**Problème actuel :** Le panier est géré uniquement côté Flutter (en mémoire). Si l'utilisateur change d'appareil ou ferme l'app, le panier est perdu.

**Ce qu'il faut implémenter :**

Le CDC prévoit un panier serveur. Tu dois créer les modèles `Cart` et `CartItem` et les routes suivantes :

```
Prompt Gemini :
---
Génère le code complet pour l'API Panier (Cart) de Baana.

Stack : Node.js + Express + Sequelize + PostgreSQL

MODÈLES À CRÉER :

Cart :
- id (UUID, primary key)
- userId (FK → User, unique) — chaque user a UN seul panier
- createdAt, updatedAt

CartItem :
- id (UUID, primary key)
- cartId (FK → Cart)
- productId (FK → Product)
- quantity (Integer, min 1)

ENDPOINTS (tous protégés par middleware auth JWT) :

GET /api/cart
- Retourne le panier de l'utilisateur connecté
- Inclut chaque produit avec : id, name, image, publicPrice, proPrice
- Calcule dynamiquement : subtotal, deliveryFee (0 si Pro + livraisons restantes, sinon 1500 FCFA), total
- Si le panier n'existe pas, le créer automatiquement (vide)

POST /api/cart
- Body : { productId, quantity }
- Si le produit est déjà dans le panier → additionner la quantité
- Sinon → créer un nouveau CartItem
- Vérifier que le stock du produit est suffisant
- Retourne le panier mis à jour

PUT /api/cart/:itemId
- Body : { quantity }
- Met à jour la quantité (minimum 1, maximum = stock disponible)
- Retourne le panier mis à jour

DELETE /api/cart/:itemId
- Supprime l'item du panier
- Retourne le panier mis à jour

IMPORTANT :
- Les prix retournés doivent être adaptés au rôle de l'utilisateur (publicPrice pour visiteur, proPrice pour pro)
- Calcul livraison : si user.role === 'PRO' et livraisons gratuites restantes > 0, deliveryFee = 0
- Sinon deliveryFee = 1500 (FCFA)
- Déclarer les routes sous /api/cart dans un fichier src/routes/cartRoutes.js
- Monter les routes dans src/app.js

Code commenté en français. Gestion d'erreurs avec try/catch.
---
```

**Fichiers à créer :**
- `src/models/Cart.js`
- `src/models/CartItem.js`
- `src/controllers/cartController.js`
- `src/routes/cartRoutes.js`
- Mettre à jour `src/models/index.js` (associations)
- Mettre à jour `src/app.js` (montage route `/api/cart`)

---

### 🚀 Innovation 2 : Suivi de Commande en Temps Réel (Timeline)

**Problème actuel :** Les commandes ont un `status` mais pas de timeline détaillée.

**Ce qu'il faut implémenter :**

```
Prompt Gemini :
---
Ajoute la fonctionnalité de suivi de commande avec timeline à l'API Baana.

MODIFICATIONS du modèle Order :
1. Ajoute un champ `timeline` de type JSON (tableau d'objets)
   - Chaque entrée : { status: string, date: string (ISO), description: string }
   - Exemple : [
       { "status": "confirmed", "date": "2026-06-27T14:30:00Z", "description": "Commande confirmée" },
       { "status": "preparing", "date": "2026-06-27T15:00:00Z", "description": "Préparation en cours" }
     ]

2. Ajoute un champ `deliveryPersonName` (String, nullable) — nom du livreur
3. Ajoute un champ `deliveryPersonPhone` (String, nullable) — téléphone du livreur
4. Ajoute un champ `estimatedDeliveryAt` (Date, nullable) — estimation de livraison

MODIFICATION du contrôleur createOrder :
- Lors de la création, initialiser la timeline avec :
  [{ status: "confirmed", date: new Date().toISOString(), description: "Commande confirmée et paiement reçu" }]

NOUVEL ENDPOINT :
PUT /api/orders/:id/status (protégé admin/système)
- Body : { status, description }
- Ajoute une entrée à la timeline
- Met à jour le champ `status` de la commande
- Si status === 'delivering', accepter aussi deliveryPersonName et deliveryPersonPhone
- Si status === 'delivered', calculer et ajouter les points de fidélité (1 point par 1000 FCFA)
- Envoie une notification automatique à l'utilisateur

Code commenté en français.
---
```

**Fichiers à modifier :**
- `src/models/Order.js` — ajouter les champs timeline, deliveryPerson, estimatedDelivery
- `src/controllers/orderController.js` — ajouter `updateOrderStatus` et modifier `createOrder`
- `src/routes/orderRoutes.js` — ajouter `PUT /:id/status`

---

### 🚀 Innovation 3 : Système de Points de Fidélité

**Problème actuel :** Le champ `loyaltyPoints` existe dans le modèle User mais rien ne l'incrémente.

**Ce qu'il faut implémenter :**

```
Prompt Gemini :
---
Implémente le système de points de fidélité pour Baana.

RÈGLE : 1 point par tranche de 1000 FCFA dépensés (arrondi à l'entier inférieur).
Exemple : commande de 12 500 FCFA → +12 points

MODIFICATIONS :
1. Dans le contrôleur orderController.js, quand le status d'une commande passe à 'delivered' :
   - Calculer les points : Math.floor(order.totalAmount / 1000)
   - Incrémenter user.loyaltyPoints += points
   - Sauvegarder l'utilisateur
   - Créer une notification : "Vous avez gagné X points de fidélité !"

2. Créer un nouvel endpoint GET /api/users/loyalty :
   - Retourne { points: user.loyaltyPoints, history: [...] }
   - L'historique des dernières 20 transactions de points

Le système est simple pour la V1. Pas de rédemption de points pour l'instant.
Code commenté en français.
---
```

---

### 🚀 Innovation 4 : Géolocalisation des Livraisons

**Problème actuel :** L'adresse de livraison est un simple texte. Le CDC prévoit la géolocalisation.

**Ce qu'il faut implémenter :**

```
Prompt Gemini :
---
Ajoute le support de la géolocalisation pour les livraisons Baana.

MODIFICATIONS du modèle Order :
1. Ajoute `deliveryLatitude` (DECIMAL, nullable)
2. Ajoute `deliveryLongitude` (DECIMAL, nullable)

MODIFICATIONS du contrôleur createOrder :
- Accepter les champs optionnels `latitude` et `longitude` dans le body
- Les stocker dans la commande

MODIFICATION du modèle User (déjà fait en partie) :
- Les champs `gpsLatitude` et `gpsLongitude` existent déjà
- Ajouter un endpoint PUT /api/users/location pour mettre à jour la position GPS :
  Body : { latitude, longitude }

Code commenté en français.
---
```

---

### 🚀 Innovation 5 : Cache Produits pour Mode Hors-Ligne Partiel

**Exigence CDC :** *"Mode offline partiel — catalogue consultable sans connexion"*

**Ce qu'il faut implémenter côté backend :**

```
Prompt Gemini :
---
Ajoute les en-têtes de cache HTTP pour le catalogue produits de Baana.

OBJECTIF : Permettre au frontend Flutter de mettre en cache les produits pour une consultation hors-ligne.

MODIFICATIONS sur le contrôleur productController.js :

1. Sur GET /api/products, ajouter les en-têtes :
   - Cache-Control: public, max-age=300 (5 minutes)
   - ETag: basé sur le hash MD5 de la réponse JSON

2. Sur GET /api/products/:id, ajouter :
   - Cache-Control: public, max-age=600 (10 minutes)

3. Sur GET /api/categories, ajouter :
   - Cache-Control: public, max-age=3600 (1 heure — les catégories changent rarement)

4. Gérer le If-None-Match (ETag) pour retourner 304 Not Modified si le contenu n'a pas changé.

Code commenté en français.
---
```

---

### 🚀 Innovation 6 : Compression des Images

**Exigence CDC :** *"Compression images + chargement progressif"*

```
Prompt Gemini :
---
Ajoute un endpoint d'upload d'images produits avec compression automatique.

Stack : Node.js + Express + multer + sharp

ENDPOINT :
POST /api/products/:id/images (protégé admin)
- Accepte un fichier image (jpg, png, webp)
- Compresse l'image avec sharp :
  - Redimensionner à max 800x800 pixels
  - Convertir en WebP (format optimal pour le mobile)
  - Qualité 80%
  - Générer aussi une miniature 200x200 pour le catalogue
- Stocker dans un dossier uploads/ avec un nom unique
- Retourner les URLs des images (originale compressée + miniature)

Installer les dépendances : npm install multer sharp uuid

Code commenté en français.
---
```

---

## 📋 CHECKLIST DE VALIDATION FINALE

Avant de considérer le projet comme prêt pour la présentation, vérifie chaque point :

### Backend ✅
- [ ] `npm install` sans erreurs
- [ ] `node src/seeders/init_seed.js` crée les tables et données sans erreur
- [ ] `node src/server.js` démarre correctement
- [ ] `POST /api/auth/register` → retourne "OTP envoyé"
- [ ] `POST /api/auth/verify-otp` avec code 1234 → retourne un token JWT
- [ ] `GET /api/products` → retourne les produits avec `publicPrice` et `proPrice`
- [ ] `GET /api/categories` → retourne les 5 catégories
- [ ] `POST /api/orders` → crée une commande avec `orderNumber` au format `#SDP-XXXXX`
- [ ] `GET /api/orders/history` → retourne l'historique de l'utilisateur
- [ ] `GET /api/dashboard/stats` → retourne les KPIs Pro
- [ ] `POST /api/subscriptions/renew` → active l'abonnement Pro
- [ ] `GET /api/notifications` → retourne les notifications

### Frontend ✅
- [ ] `flutter pub get` sans erreurs
- [ ] `flutter run -d chrome` ou émulateur lance l'application
- [ ] Parcours complet Inscription → OTP → Home → Catalogue → Panier → Commande
- [ ] Les catégories se chargent dynamiquement depuis la base de données
- [ ] Les produits se filtrent et se trient correctement
- [ ] Le checkout permet de modifier l'adresse de livraison
- [ ] L'historique des commandes se charge depuis la BDD
- [ ] Tous les boutons de navigation fonctionnent (aucun bouton "mort")

---

## 🚨 CORRECTIFS QUE J'AI FAITS (Pour ta compréhension)

Voici les bugs d'intégration que j'ai corrigés pour que tu comprennes les changements dans le code :

| Fichier | Problème | Correction |
|---|---|---|
| `src/models/Order.js` | `paymentMethod` était un ENUM restrictif (`WAVE`, `ORANGE_MONEY`) | Changé en `DataTypes.STRING` pour accepter `mobile_money`, `cash`, etc. |
| `src/models/User.js` | Champs manquants `businessName`, `ninea`, `address` | Ajoutés au schéma Sequelize |
| `src/seeders/init_seed.js` | OTP test `1234` haché avec bcrypt | Stocké en clair (le contrôleur fait une comparaison string directe) |
| `src/controllers/authController.js` | Pas de route `POST /login` | Créé le contrôleur et la route |
| `src/routes/orderRoutes.js` | Pas de route `GET /history` | Ajouté un mapping vers `getUserOrders` |
| `src/controllers/orderController.js` | Validation trop stricte des paiements | Élargi la liste des méthodes acceptées |
| `src/controllers/categoryController.js` | N'existait pas | Créé pour servir `GET /api/categories` |
| `src/routes/userRoutes.js` | N'existait pas | Créé pour `PUT /api/users/profile` |

---

## 📞 Communication

- **Si tu es bloqué** → Contacte-moi immédiatement sur WhatsApp
- **Quand tu as fini une innovation** → Push sur `main` et préviens-moi
- **Pour tester les endpoints** → Utilise Postman avec le token JWT récupéré via `/api/auth/verify-otp`

> **Rappel Postman :** Après avoir récupéré le token via verify-otp, ajoute-le dans l'onglet "Authorization" → Type "Bearer Token" → Colle le token.

---

**Bon courage Ngary ! On est dans la dernière ligne droite. 💪🚀**
