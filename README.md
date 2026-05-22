# Application de Caisse - SEN DIGITAL PULSE (Groupe 1)

![CI Status](https://github.com/caisse-sdp-groupe1/actions/workflows/ci.yml/badge.svg)

## 📋 Contexte du Projet
Projet de stage (Mai - Juin 2026) au sein de **SEN DIGITAL PULSE**.
L'objectif est de concevoir et développer une application de caisse enregistreuse (point de vente) de niveau professionnel.

### 👥 L'Équipe
* **Ngary DIOP** : Architecte Logiciel & Développeur Full-Stack
* **Mouhamed Youssouf DIOUM** : Développeur Full-Stack
* **Mame Saye FALL** : Développeur Front-End & QA

## 🛠️ Stack Technologique
* **Frontend** : React.js
* **Backend** : Node.js / Express
* **Base de données** : MySQL / PostgreSQL

## 📏 Conventions & Standards de Qualité

### 📝 Commit Convention (Conventional Commits)
Format : `type(scope): description`
* `feat:` : Nouvelle fonctionnalité
* `fix:` : Correction de bug
* `docs:` : Documentation
* `test:` : Ajout/Modification de tests
* `refactor:` : Refactorisation de code

### 🌿 Nommage des branches
* `main` : Code en production
* `develop` : Code en développement
* `feat/nom-fonctionnalite` : Nouvelle fonctionnalité
* `fix/nom-bug` : Correction de bug
* `hotfix/nom-hotfix` : Correction urgente en production

### 🔍 Code Review & Qualité
* Toute Pull Request (PR) doit être approuvée par au moins 1 membre avant merge.
* Couverture minimale de 60% requise sur les modules critiques.
* Sécurité maximale : validation stricte des entrées et pas de secrets en clair.
* Temps de réponse API cible : < 500ms.
