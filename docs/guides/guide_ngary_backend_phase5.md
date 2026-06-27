# 🟢 GUIDE AVANCÉ : NGARY — Développeur Backend Node.js (PHASE 5)

Salut Ngary ! Félicitations pour avoir accompli la **Phase 4** avec brio (Intégration Firebase pour les notifications Push, Génération des PDF de facture et l'OTP réel). Le backend est devenu extrêmement robuste.

Cependant, pendant que tu travaillais sur la Phase 4, le Frontend a beaucoup évolué pour s'adapter au Cahier des Charges (CDC) exact. L'application Flutter utilise actuellement des données "mockées" avec de nouveaux champs qui n'existent pas encore dans ta base de données. 

**Ta mission pour la Phase 5** est de faire une mise à jour critique des modèles de données (Database Schema) et des contrôleurs pour s'aligner sur ce que l'application mobile attend.

---

## 🚀 PROMPTS NODE.JS OPTIMISÉS (Phase 5 — Alignement CDC)

### 📅 J14 : Refonte du Modèle `Product` et `User` (Pricing & Abonnements)
Le cœur du système repose sur la distinction entre le prix public et le prix pro, ainsi que sur les avantages abonnés.

```text
Développe les migrations et mises à jour des modèles Sequelize pour `Product` et `User`.

Exigences Modèle `Product` :
1. Supprime le champ `price`.
2. Ajoute `publicPrice` (Integer) et `proPrice` (Integer).
3. Modifie tes routes GET `/api/products` pour retourner ces deux champs.

Exigences Modèle `User` :
1. Assure-toi que les champs suivants existent : `role` (ENUM: 'USER', 'PRO'), `proPlan` (ENUM: 'HEBDO', 'MENSUEL', null).
2. Ajoute `freeDeliveriesUsed` (Integer, défaut 0). Rappel : Les utilisateurs 'PRO' ont droit à 3 livraisons gratuites par semaine.
3. Ajoute `loyaltyPoints` (Integer, défaut 0) si ce n'est pas déjà fait à la phase précédente.
4. Ajoute `businessName`, `ninea` et `address` (String, nullable) pour les profils entreprise.
```

### 📅 J15 : Refonte du Modèle `Order` et Calcul des Frais
Le panier Flutter va t'envoyer des commandes avec une structure précise.

```text
Développe la mise à jour du modèle `Order` et du contrôleur de création de commande.

Exigences Modèle `Order` :
1. Ajoute `orderNumber` (String, unique, format généré: `#SDP-XXXXX`).
2. Ajoute `paymentStatus` (ENUM: 'PENDING', 'PAID', 'FAILED', par défaut 'PENDING').
3. Met à jour `status` pour correspondre à : 'CONFIRMED', 'PREPARING', 'DELIVERING', 'DELIVERED', 'CANCELLED'.

Exigences `POST /api/orders` (Création) :
1. Le backend doit calculer les frais de livraison. Si `user.role == 'PRO'` et `user.freeDeliveriesUsed < 3`, les frais de livraison = 0 FCFA et on incrémente `freeDeliveriesUsed`. Sinon, frais de livraison = 1500 FCFA.
2. Le total doit être recalculé côté backend en utilisant `publicPrice` ou `proPrice` selon le `user.role` (ne fais jamais confiance au total envoyé par le frontend).
```

### 📅 J16 : Mise à jour du Dashboard Analytics
Les KPIs demandés dans le CDC par Mouhamed (Frontend) ont changé.

```text
Met à jour la route `GET /api/dashboard/stats` pour le profil PRO.

Exigences de retour JSON :
- `totalSpent` : Dépenses du mois en cours.
- `savingsRealized` : Économies réalisées (différence entre publicPrice et proPrice * quantité) sur toutes les commandes du mois.
- `freeDeliveriesLeft` : 3 - `user.freeDeliveriesUsed`.
- `loyaltyPoints` : Points actuels.
```

---

## 🔍 Ta Checklist Quotidienne
1. **Migrations Sequelize :** N'oublie pas d'utiliser `sequelize-cli` pour créer des fichiers de migration propres afin de ne pas perdre les données existantes.
2. **Synchronisation :** Préviens Mouhamed quand les routes sont prêtes pour qu'il puisse brancher l'application Flutter.
3. **Revue :** Prépare ta Pull Request `feat/back-phase5-cdc`.
