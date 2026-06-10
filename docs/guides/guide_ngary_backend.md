# 🔵 GUIDE AVANCÉ : NGARY — Développeur Backend Node.js

Bienvenue dans ton guide d'exécution optimisé pour la **Phase 2 (Développement)**.
Tu développes l'API REST robuste qui alimentera l'application Baana. Ton travail sera revu chaque jour par Mouhamed (Architecte).

L'outil **Antigravity avec Gemini 3.1 Pro** va t'aider. Ce guide utilise les principes d'optimisation de prompts pour s'assurer que l'IA génère un code sécurisé, performant et prêt pour la production.

> [!NOTE]
> **A propos des fichiers du projet :** Tu trouveras à la racine le document `CahierDesCharges SDP.docx`. Utilise-le uniquement si tu as besoin de comprendre une règle métier précise (ex: fonctionnement de l'OTP, règles de livraison). Les gros dossiers de maquettes UI (Stitch) ou la charte graphique n'ont volontairement pas été poussés sur Git pour ne pas polluer ton espace de travail. Concentre-toi 100% sur l'API !

---

## 🧱 Standards d'Architecture Backend
Avant d'utiliser un prompt, l'IA doit comprendre ces fondations :
- **Architecture :** Pattern Modèle-Route-Contrôleur (MVC). Logique métier séparée des routes.
- **Sécurité :** Tous les mots de passe hashés avec `bcryptjs`. Les routes privées protégées par JWT (`jsonwebtoken`). En-têtes sécurisés avec `helmet`.
- **Base de données :** `Sequelize` ORM avec PostgreSQL. Indexation sur les clés étrangères et les champs de recherche fréquents.
- **Robustesse :** Validation stricte des entrées utilisateur via `express-validator`. Gestion globale des erreurs avec un middleware `errorHandler`.
- **Règles métier :** Les prix sont **toujours** en entiers (INTEGER) pour les FCFA. Le backend calcule toujours le total d'un panier, il ne fait jamais confiance au montant envoyé par le client.

## 🌿 Workflow Git & GitHub (Tu es le Merge Master !)

L'équipe utilise GitHub. Comme tu as créé le dépôt, **tu es responsable des Merges sur la branche `main`**. Mais attention : pas de push direct sur `main` ! Voici les prompts pour te faire assister par Antigravity :

1. **Créer ta branche :**
   > *Prompt Antigravity :* "Assure-toi que je suis sur `main` et à jour, puis crée une nouvelle branche nommée `feat/back-[nom-feature]`."
2. **Générer & Commiter :**
   Une fois le code écrit par l'IA :
   > *Prompt Antigravity :* "Ajoute tous mes fichiers modifiés et fais un commit avec un message propre (format conventional commits : `feat(back): ...` ou `fix(back): ...`)."
3. **Pousser et préparer la PR :**
   > *Prompt Antigravity :* "Pousse cette branche sur origin et rédige-moi un résumé Markdown clair pour ma Pull Request GitHub expliquant l'architecture implémentée."
4. **Revue Obligatoire :**
   Tu **dois** demander à Mouhamed (l'Architecte) de faire une Code Review de ta PR. S'il demande des corrections, demande à Antigravity de les appliquer sur la même branche et refais le point 2.
5. **Le MERGE :**
   Une fois que Mouhamed a approuvé ta PR (et SEULEMENT à ce moment-là), **c'est à toi de cliquer sur le bouton "Merge Pull Request"** sur GitHub pour intégrer le code dans `main`. Tu feras pareil pour les PR de Mouhamed une fois qu'elles seront prêtes.

---

## 🚀 PROMPTS NODE.JS OPTIMISÉS (Phase 2)

Utilise ces prompts stricts dans Antigravity. Ils définissent le quoi, le comment, la sécurité et les limites.

### 📅 J2 : Modèles Sequelize & Seeders
```text
Génère les modèles Sequelize pour le projet e-commerce Baana et un script de seeding.

Contexte Technique :
- Node.js, Express, Sequelize, PostgreSQL.

Exigences :
1. Modèle `User` : phone (String, unique), name (String), isPro (Boolean, default: false), otpCode (String, nullable).
2. Modèle `Category` : name (String, unique).
3. Modèle `Product` : name, description, publicPrice (INTEGER), proPrice (INTEGER), stock (INTEGER), categoryId (Foreign Key).
4. Relations : Category a plusieurs Products (1:N).

Workflow :
1. Crée les fichiers dans `src/models/`.
2. Définis les associations dans un fichier d'index des modèles.
3. Crée un script `src/seeders/init_seed.js` qui vide la DB et insère 3 catégories et 10 produits locaux du Sénégal.

Critères d'acceptation :
- Les clés étrangères doivent avoir `onDelete: 'CASCADE'`.
- Les prix DOIVENT être de type INTEGER (pas de Float pour les FCFA).
- Le script de seed doit utiliser `await` correctement et s'exécuter sans erreur.
```

### 📅 J3 & J4 : Authentification (OTP & JWT) & Validation
```text
Implémente le module d'authentification sécurisé de l'API.

Contexte Technique :
- Node.js, Sequelize (modèle User existant). Packages : `jsonwebtoken`, `express-validator`.

Exigences :
1. Route POST `/api/auth/register` :
   - Reçoit `phone` et `name`.
   - Utilise `express-validator` pour s'assurer que le téléphone commence par +221 et fait 13 caractères.
   - Si valide, génère un OTP à 4 chiffres (ex: "1234" en mode dev), l'enregistre en base et renvoie un succès (SANS renvoyer l'OTP dans le JSON).
2. Route POST `/api/auth/verify-otp` :
   - Vérifie la correspondance du téléphone et du code OTP.
   - Si succès, vide le champ otpCode en DB, et signe un token JWT contenant `userId` et `isPro`.
3. Middleware `src/middlewares/auth.js` : Vérifie la présence du token Bearer, le décode, et injecte l'utilisateur dans `req.user`.

Sécurité & Gestion d'erreur :
- Ne jamais stocker de token JWT en base (stateless).
- Retourner des codes HTTP stricts : 400 Bad Request (validation), 401 Unauthorized, 404 Not Found.

Ne pas faire :
- Ne pas implémenter de mot de passe classique, Baana est 100% OTP.
```

### 📅 J7 & J8 : Création de Commandes & Transaction DB
```text
Implémente la création de commande avec calcul côté serveur et transactions PostgreSQL.

Contexte Technique :
- Node.js, Sequelize. Modèles : Order, OrderItem, Product.
- Middleware auth JWT activé sur la route.

Exigences (POST /api/orders) :
- Le body reçoit `paymentMethod` (WAVE ou ORANGE_MONEY) et `items` (tableau d'objets { productId, quantity }).
- Logique métier STRICTE :
  1. Utilise une Transaction Sequelize (`sequelize.transaction()`).
  2. Parcours les `items`, trouve le `Product` en base.
  3. Vérifie que le stock est suffisant (sinon rollback et erreur 400).
  4. Détermine le prix unitaire : si `req.user.isPro` est vrai, utilise `proPrice`, sinon `publicPrice`.
  5. Calcule le montant total en backend.
  6. Décrémente le stock du produit.
  7. Crée la ligne Order et les lignes OrderItem.
  8. Commit la transaction.

Critères d'acceptation :
- Impossible d'acheter un produit en rupture de stock.
- La transaction assure que si un produit pose problème, aucune donnée n'est sauvée.
- Le prix total est garanti mathématiquement par le serveur, indifférent à ce qu'envoie le client frontend.
```

### 📅 J9 & J10 : Dashboard Pro & Requêtes Complexes
```text
Développe les endpoints analytiques pour le Dashboard des abonnés Pro.

Contexte Technique :
- Node.js, requêtes Sequelize complexes (`sequelize.fn`, `sequelize.col`).

Exigences (GET /api/dashboard/pro) :
- Protégé par middleware auth. Vérifie que `req.user.isPro` est true (sinon erreur 403 Forbidden).
- Calcule et retourne 4 KPIs pour l'utilisateur connecté :
  1. `totalOrders` : Nombre total de commandes.
  2. `totalSpent` : Somme du montant de toutes ses commandes.
  3. `savings` : Somme de (publicPrice - proPrice) * quantity pour tous ses achats.
  4. `freeDeliveriesLeft` : Chiffre fixe (ex: 3) moins le nombre de commandes passées cette semaine.

Critères d'acceptation :
- Utilise l'agrégation SQL (GROUP BY, SUM) au lieu de ramener toutes les lignes en mémoire RAM de Node.js.
- Le temps de réponse doit être inférieur à 100ms.
```
