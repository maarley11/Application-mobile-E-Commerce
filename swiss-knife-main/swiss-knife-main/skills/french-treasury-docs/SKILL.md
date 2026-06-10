---
name: Documentation Française - Système Trésorerie
description: Skill for generating comprehensive French technical documentation for the Treasury Management System (backend, ETL, back-office, front-office, AI agents)
---

# Documentation Française - Système Trésorerie

Ce skill permet de générer une documentation technique complète en français pour l'ensemble du Système de Gestion de Trésorerie (SGT), couvrant tous les composants du projet.

## Composants Couverts

- **Backend** (`i-sib-tresorerie-service`) - API REST Spring Boot
- **ETL** (Treasury Data Hub) - Pipelines de données
- **Back-office** (`sib-back-office`) - Interface d'administration
- **Front-office** (futur) - Interface client
- **AI Agents** (futur) - Agents intelligents

## Types de Documentation

### 1. Architecture Technique

Documentation de l'architecture globale du système:
- Vue d'ensemble du système
- Diagrammes d'architecture (C4 model, flux de données)
- Stack technologique
- Intégrations et dépendances
- Patterns et bonnes pratiques

**Template**: `templates/architecture.md`

### 2. Documentation API

Documentation des APIs REST:
- Endpoints par module (Trésorerie, Paiements, Rapprochement, etc.)
- Requêtes/Réponses avec exemples
- Codes d'erreur et gestion des exceptions
- Authentification et autorisation
- Rate limiting et quotas

**Template**: `templates/api.md`

### 3. Guide Utilisateur

Documentation pour les utilisateurs finaux:
- Guide de démarrage rapide
- Fonctionnalités par module
- Workflows métier
- Captures d'écran et vidéos
- FAQ et dépannage

**Template**: `templates/user_guide.md`

### 4. Guide Développeur

Documentation pour les développeurs:
- Setup environnement de développement
- Structure du projet
- Conventions de code
- Tests (unitaires, intégration, E2E)
- Contribution et workflow Git

**Template**: `templates/developer_guide.md`

### 5. Guide Déploiement

Documentation de déploiement et opérations:
- Prérequis infrastructure
- Configuration environnements (dev, staging, prod)
- Procédures de déploiement (Docker, Kubernetes, etc.)
- Monitoring et logs
- Backup et disaster recovery

**Template**: `templates/deployment.md`

### 6. Documentation Base de Données

Documentation des schémas et données:
- Modèle de données (ERD)
- Description des tables et relations
- Scripts de migration
- Procédures stockées et triggers
- Data seeding

**Template**: `templates/database.md`

---

## Utilisation du Skill

### Commande de Base

Pour générer de la documentation, l'agent doit:

1. **Identifier le composant** à documenter (backend, ETL, back-office, etc.)
2. **Choisir le type de documentation** (architecture, API, guide utilisateur, etc.)
3. **Utiliser le template approprié** du dossier `templates/`
4. **Remplir avec les informations du projet**
5. **Respecter les conventions de terminologie** (voir `glossary.md`)

### Exemple de Commande Utilisateur

> "Generate French API documentation for the Treasury backend reconciliation module"

### Workflow de l'Agent

1. Lire le template `templates/api.md`
2. Analyser le code du module Rapprochement (`ReconciliationController`, `ReconciliationService`)
3. Extraire les endpoints, DTOs, et logique métier
4. Générer la documentation en français en suivant le template
5. Inclure des exemples de requêtes/réponses
6. Ajouter les termes du glossaire

---

## Structure des Templates

Tous les templates suivent cette structure:

```markdown
---
module: [Nom du Module]
composant: [Backend/ETL/Back-office/etc.]
version: [Version]
date: [Date de génération]
---

# [Titre du Document]

## Introduction
[Contexte et objectif du document]

## [Section Principale 1]
[Contenu technique détaillé]

## [Section Principale 2]
[Contenu technique détaillé]

## Glossaire
[Termes techniques avec définitions]

## Références
[Liens vers autres documents, code source, etc.]
```

---

## Conventions et Bonnes Pratiques

### Langue et Style

- **Français formel** pour la documentation technique
- **Vocabulaire métier bancaire** précis (voir `glossary.md`)
- **Exemples concrets** pour illustrer les concepts
- **Code snippets** avec commentaires en français
- **Diagrammes** avec légendes en français

### Structure et Format

- **Markdown** avec support Mermaid pour les diagrammes
- **Table des matières** pour les documents longs
- **Liens internes** entre documents liés
- **Badges** pour versions, statuts, etc.
- **Alerts/Callouts** pour informations importantes

### Terminologie

Utiliser systématiquement les termes français du domaine:

| English | Français |
|---------|----------|
| Treasury | Trésorerie |
| Cash Flow | Flux de Trésorerie |
| Reconciliation | Rapprochement (Bancaire) |
| Payment | Paiement |
| Deal | Opération / Transaction |
| Position | Position (de Change) |
| Risk Limit | Limite de Risque |
| Nostro Account | Compte Nostro |
| GL Entry | Écriture Comptable |

Voir `glossary.md` pour la liste complète.

---

## Exemples de Génération

### Exemple 1: API Endpoint Documentation

**Input**: Documenter l'endpoint `POST /api/treasury/reconciliation/match`

**Output** (extrait):

```markdown
## POST /reconciliation/match

### Description
Effectue le rapprochement manuel entre une écriture comptable et une transaction bancaire.

### URL
`POST /api/treasury/reconciliation/match`

### Corps de la Requête
```json
{
  "glId": "GL-1234",
  "bankId": "BK-5678"
}
```

### Paramètres

| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| `glId` | string | Oui | Identifiant de l'écriture GL (préfixe GL-) |
| `bankId` | string | Oui | Identifiant de la transaction bancaire (préfixe BK-) |

### Réponse

**Code 200**: Rapprochement effectué avec succès

**Code 400**: Erreur de validation (montants incompatibles)

**Code 404**: Écriture ou transaction non trouvée
```

### Exemple 2: Architecture Component

**Input**: Documenter l'architecture du module ETL

**Output** (extrait):

```markdown
## Architecture ETL - Treasury Data Hub

### Vue d'Ensemble

Le Treasury Data Hub est responsable de l'extraction, transformation et chargement (ETL) des données de trésorerie depuis multiples sources (fichiers bancaires, systèmes GL, etc.) vers la base de données centralisée.

### Composants

#### 1. Extracteurs (Extractors)
- `GlFileParser`: Parse les fichiers export Sage 100
- `BankStatementParser`: Parse les relevés bancaires (MT940, CAMT.053)
- `DealImporter`: Importe les opérations de marché

#### 2. Transformateurs (Transformers)
- `CurrencyNormalizer`: Normalisation des devises
- `AmountConverter`: Conversion des montants
- `DateStandardizer`: Standardisation des dates

#### 3. Chargeurs (Loaders)
- `DatabaseLoader`: Insertion dans PostgreSQL
- `CacheUpdater`: Mise à jour du cache Redis
```

---

## Maintenance du Skill

### Mise à Jour des Templates

Lorsque de nouveaux modules sont ajoutés au système:
1. Mettre à jour le template concerné
2. Ajouter les nouveaux termes au `glossary.md`
3. Créer un exemple de documentation dans `examples/`

### Versioning

Les documents générés doivent inclure:
- Version du composant documenté
- Date de génération
- Auteur/Générateur (Agent AI)

---

## Ressources

- **Templates**: `./templates/` - Modèles de documentation
- **Exemples**: `./examples/` - Documentation exemple complète
- **Glossaire**: `./glossary.md` - Terminologie française du domaine
- **Diagrammes**: `./diagrams/` - Diagrammes réutilisables (architecture, flux)

---

## Notes pour l'Agent

### Analyse du Code

Avant de générer la documentation, l'agent doit:
1. Lire le code source du composant
2. Identifier les patterns (controllers, services, repositories)
3. Extraire les DTOs et modèles de données
4. Comprendre les flux métier
5. Noter les dépendances et intégrations

### Qualité de la Documentation

La documentation générée doit:
- **Être à jour** avec le code actuel
- **Être complète** (tous les endpoints/fonctionnalités documentés)
- **Être claire** (exemples concrets, cas d'usage)
- **Être précise** (pas d'informations obsolètes ou incorrectes)
- **Être structurée** (sections logiques, navigation facile)

### Validation

Après génération, l'agent doit:
1. Vérifier que tous les liens fonctionnent
2. Valider les exemples de code
3. S'assurer de la cohérence terminologique
4. Proposer le document à l'utilisateur pour review
