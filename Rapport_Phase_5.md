# CHAPITRE X : MIGRATION POSTGRESQL ET INTÉGRATION FRONT-END (PHASE 5)

## 1. Introduction et Contexte de la Phase 5

L'application **Baana (by SEN DIGITAL PULSE)** a franchi une étape décisive lors de cette cinquième phase. Après avoir développé l'architecture de base, la logique métier et l'application mobile en Flutter (réalisée par mon binôme "Héritage Signature Premium"), il était impératif de connecter les deux environnements.

Mon objectif principal était d'abandonner la base de données légère (SQLite) utilisée en développement, pour la remplacer par un Système de Gestion de Base de Données Relationnelle (SGBDR) robuste, taillé pour la production : **PostgreSQL**. Cette transition était indispensable pour garantir la sécurité des transactions e-commerce, l'intégrité des données financières et supporter une charge utilisateurs élevée.


<br><br><br>


## 2. Déploiement de PostgreSQL et Configuration de l'Environnement

Le passage de SQLite à PostgreSQL a nécessité une refonte de la couche de connexion de notre ORM (Object-Relational Mapping), Sequelize. J'ai configuré les variables d'environnement de manière sécurisée via un fichier `.env` afin d'isoler les identifiants de la base de données. 

J'ai également ajusté nos modèles de données (notamment le modèle `Product`) pour intégrer de nouveaux champs requis par le design du Front-end, tels que les liens d'images (`imageUrl`) et les étiquettes promotionnelles (`badge`).

<br>

> **[INSÉRER ICI LA CAPTURE D'ÉCRAN DE LA BASE DE DONNÉES DANS TABLEPLUS OU DU CODE DE CONNEXION POSTGRESQL]**
> *(Légende : Fig. 1 - Configuration du pool de connexion PostgreSQL via Sequelize)*

<br><br><br>


## 3. Sécurisation des Accès : Implémentation du standard JWT

L'application mobile (Flutter) nécessitant une API "Stateless" (sans état mémorisé sur le serveur), j'ai mis en place un système d'authentification basé sur les **JSON Web Tokens (JWT)**. 

Lorsqu'un utilisateur vérifie son code OTP (One-Time Password), le backend génère un token crypté contenant son identifiant et son statut (ex: `isPro`). Ce token agit comme un passeport numérique, garantissant la sécurité de toutes les requêtes ultérieures sans avoir à interroger la base de données à chaque vérification.

<br>

> **[INSÉRER ICI LA CAPTURE : Capture_1_Authentification_JWT.png]**
> *(Légende : Fig. 2 - Génération du Token JWT suite à une vérification OTP réussie)*

<br><br><br>


## 4. Initialisation du Catalogue Sénégalais (Seeders)

Pour que mon binôme puisse tester son application mobile dans des conditions réelles, j'ai développé un script d'initialisation (`init_seed.js`). Ce script peuple automatiquement la base de données PostgreSQL avec un catalogue de produits 100% adapté au marché local sénégalais (Huile d'arachide, Riz brisé, Bouillon cube, etc.).

Ce script génère également des catégories cohérentes (Alimentaire, Cosmétique, Ménager) et un compte utilisateur de test ayant le statut "Abonné Pro", permettant de valider les réductions exclusives sur les prix de gros.

<br>

> **[INSÉRER ICI LA CAPTURE : Capture_2_Catalogue_PostgreSQL.png]**
> *(Légende : Fig. 3 - Liste des produits locaux récupérée depuis PostgreSQL via l'API)*

<br><br><br>


## 5. Gestion des Commandes et Intégrité Transactionnelle

Le cœur du système e-commerce réside dans le tunnel d'achat (Checkout). J'ai implémenté l'endpoint `POST /api/orders` en utilisant le mécanisme des **Transactions SQL** offertes par PostgreSQL. 

Cette approche garantit le principe ACID (Atomicité, Cohérence, Isolation, Durabilité). Si une erreur survient lors de la déduction du stock ou de l'enregistrement du paiement (ex: WAVE), l'ensemble de la transaction est annulé (Rollback), empêchant ainsi les commandes fantômes ou les incohérences de stock. Le système vérifie également si l'utilisateur est un abonné Pro pour lui appliquer automatiquement les tarifs réduits (`proPrice`).

<br>

> **[INSÉRER ICI LA CAPTURE : Capture_3_Creation_Commande.png]**
> *(Légende : Fig. 4 - Validation d'une commande avec application automatique du tarif Pro)*

<br>

Pour assurer un suivi complet, j'ai également développé des endpoints permettant à l'application mobile de récupérer l'historique complet des commandes d'un utilisateur, avec le détail précis de chaque article acheté.

<br>

> **[INSÉRER ICI LA CAPTURE : Capture_5_Historique_Commandes.png]**
> *(Légende : Fig. 5 - Historique détaillé des commandes renvoyé à l'application mobile)*

<br><br><br>


## 6. Algorithmique Avancée : Le Dashboard Analytique

L'une des fonctionnalités phares de Baana est de démontrer aux commerçants la rentabilité de leur abonnement Pro. J'ai conçu un contrôleur (`dashboardController.js`) qui effectue des calculs d'agrégation complexes directement sur le backend.

L'endpoint renvoie en temps réel des "Key Performance Indicators" (KPIs) : le total dépensé par le commerçant, le nombre de livraisons gratuites restantes, et surtout, les **économies réalisées** grâce à la différence entre le prix public et le prix de gros.

<br>

> **[INSÉRER ICI LA CAPTURE : Capture_4_Dashboard_Analytics.png]**
> *(Légende : Fig. 6 - Retour des statistiques analytiques démontrant les économies du client)*

<br><br><br>


## 7. Conclusion de la Phase 5

Cette phase marque l'aboutissement du développement Backend. La migration réussie vers PostgreSQL, couplée à la sécurisation JWT et à la gestion transactionnelle des commandes, a permis de fournir à mon binôme une API RESTful parfaitement documentée, stable et performante. 

L'application Front-end Flutter est désormais entièrement "branchée" et fonctionnelle, ouvrant la voie à la Phase 6 (Déploiement Cloud et Hébergement).
