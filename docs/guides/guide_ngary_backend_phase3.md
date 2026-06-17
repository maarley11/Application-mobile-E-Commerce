# 🟢 GUIDE AVANCÉ : NGARY — Développeur Backend Node.js (PHASE 3)

Félicitations pour avoir complété les fondations de l'API (Jours 1 à 7) !
Ta base de données, tes modèles (User, Product, Order) et tes routes CRUD sont opérationnels.

Nous entrons maintenant dans la **Phase 3 : Intégrations Avancées & Logique Métier Complexe**. 
En tant que Lead Backend, ton objectif est de rendre l'API "intelligente" et connectée au monde extérieur (Paiements, Notifications).

L'outil **Antigravity** (ou Gemini) va t'aider à générer ce code, mais voici les directives strictes pour tes prompts.

---

## 🏗️ Standards d'Architecture Backend (Rappel)
- **Sécurité :** Vérification stricte des JWT et des permissions (rôle `PRO` vs `USER`).
- **Validation :** Continue d'utiliser `express-validator` pour TOUTES les entrées.
- **Transactions :** Pour les paiements et abonnements, utilise obligatoirement les **Transactions Sequelize** (rollback en cas d'erreur).

---

## 🚀 PROMPTS NODE.JS OPTIMISÉS (Phase 3)

### 📅 J8 : Webhooks de Paiement Mobile Money
Tu dois créer un point de terminaison pour écouter la confirmation de paiement des agrégateurs (ex: PayDunya, Wave, TouchPay).

```text
Développe un contrôleur de Webhook pour valider les paiements Mobile Money dans l'API Node.js/Express.

⚠️ INSTRUCTION CRITIQUE : Analyse les modèles `Order` et `User` existants dans le code avant de commencer. 
Le webhook doit être hyper sécurisé.

Exigences :
1. Route : `POST /api/webhooks/payment`
2. Logique :
   - Le webhook reçoit un `transaction_id`, un `status` (SUCCESS/FAILED) et un `order_id`.
   - Utilise une Transaction Sequelize : si `status == SUCCESS`, passe le statut de la commande à 'PAID'.
   - Si la commande est payée, vide le panier de l'utilisateur (si géré côté DB).
3. Sécurité :
   - Vérifie la signature cryptographique de la requête (simule un check de hash envoyé dans les headers par l'agrégateur).
   - Protège la route contre le replay attack (vérifie si l'order n'est pas DÉJÀ payé).
```

### 📅 J9 : Logique d'Abonnement "Membre Pro"
C'est le cœur du projet Baana : la gestion des commerçants payants.

```text
Développe le système d'abonnement "Membre Pro" pour l'API Express de Baana.

⚠️ INSTRUCTION CRITIQUE : Analyse les modèles existants. Un utilisateur a un champ `role` ('USER' ou 'PRO') et nous devons ajouter une gestion de quota.

Exigences :
1. Mise à jour du modèle `User` (via une migration si nécessaire) pour ajouter :
   - `subscriptionExpiresAt` (Date)
   - `freeDeliveriesUsedThisWeek` (Integer, par défaut 0)
2. Route `POST /api/subscriptions/renew` :
   - Permet de renouveler l'abonnement d'un mois. Ajoute 30 jours à `subscriptionExpiresAt` et passe le rôle à 'PRO'.
3. CRON JOB ou logique métier :
   - Écris une fonction utilitaire (ou un script `node-cron`) qui remet `freeDeliveriesUsedThisWeek` à 0 tous les lundis à minuit.
4. Middleware de permission :
   - Crée un `isProMember` middleware qui vérifie si `role === 'PRO'` ET que `subscriptionExpiresAt` n'est pas dépassé.
```

### 📅 J10 : Endpoints Analytiques pour le Dashboard Pro
Mouhamed a besoin de données agrégées pour afficher de beaux graphiques dans l'application Flutter.

```text
Développe le contrôleur d'analytique (`dashboardController.js`) pour fournir les données du Dashboard B2B.

⚠️ INSTRUCTION CRITIQUE : Utilise les fonctions d'agrégation de Sequelize (`fn`, `col`, `sum`, `count`) pour ne pas surcharger la mémoire du serveur Node. Ne ramène pas toutes les lignes en mémoire !

Exigences (Route `GET /api/dashboard/stats`) :
1. L'endpoint doit retourner en JSON :
   - `totalSpentThisMonth` : Somme de toutes les commandes de ce mois.
   - `ordersCount` : Nombre de commandes ce mois-ci.
   - `savingsRealized` : Calcul de l'économie réalisée (différence entre prix public et prix pro * quantité) sur ce mois.
   - `monthlyPurchases` : Un tableau des dépenses groupées par mois pour les 6 derniers mois (pour le graphique Flutter).
2. L'endpoint est protégé : l'utilisateur ne peut voir que SES statistiques.
```

---

## 🔍 Ta Checklist Quotidienne
1. **Tester avec Postman :** Ne pousse pas ton code si tu n'as pas validé la route via Postman ou cURL.
2. **Créer la Pull Request :** Une fois fini, crée une branche `feat/back-[nom]` et ouvre une PR.
3. **Revue :** Attends que Mouhamed approuve ta PR avant de faire le MERGE sur la branche `main`.
