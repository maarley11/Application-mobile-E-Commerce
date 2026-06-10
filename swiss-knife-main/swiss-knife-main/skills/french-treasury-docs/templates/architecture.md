---
module: [Nom du Système/Module]
composant: [Backend/ETL/Back-office/etc.]
version: 1.0.0
date: [Date de génération]
---

# Architecture - [Nom du Système]

## Introduction

Ce document décrit l'architecture du **[Nom du Système/Module]**, partie intégrante du Système de Gestion de Trésorerie (SGT).

### Objectifs

- Objectif 1
- Objectif 2
- Objectif 3

### Portée

Ce document couvre:
- Composant A
- Composant B
- Intégrations C

---

## Vue d'Ensemble

### Contexte

[Description du contexte métier et des besoins]

### Diagramme de Contexte (C4 Level 1)

```mermaid
C4Context
    title Diagramme de Contexte - Système de Trésorerie
    
    Person(user, "Trésorier", "Utilisateur du système")
    System(sgt, "Système de Gestion de Trésorerie", "Gestion complète de la trésorerie")
    System_Ext(bank, "Systèmes Bancaires", "Swift, MT940")
    System_Ext(gl, "Système Comptable", "Sage 100")
    
    Rel(user, sgt, "Utilise", "HTTPS")
    Rel(sgt, bank, "Échange des flux", "SFTP/API")
    Rel(sgt, gl, "Importe écritures", "Fichiers CSV")
```

---

## Architecture Globale

### Diagramme de Conteneurs (C4 Level 2)

```mermaid
C4Container
    title Architecture - Système de Trésorerie
    
    Container(web, "Back-office Web", "Next.js/React", "Interface utilisateur")
    Container(api, "API Backend", "Spring Boot", "Services métier")
    Container(etl, "ETL Pipeline", "Python", "Traitement des données")
    Container(db, "Base de Données", "PostgreSQL", "Stockage")
    Container(cache, "Cache", "Redis", "Cache distribué")
    
    Rel(web, api, "Appels API", "REST/JSON")
    Rel(api, db, "Lecture/Écriture", "JDBC")
    Rel(api, cache, "Cache", "Redis Protocol")
    Rel(etl, db, "Charge données", "SQL")
```

### Composants Principaux

| Composant | Technologie | Responsabilité |
|-----------|-------------|----------------|
| **Frontend** | Next.js 14, React 18, TypeScript | Interface utilisateur responsive |
| **Backend** | Spring Boot 3.2, Java 17 | API REST, logique métier |
| **ETL** | Python 3.11, Pandas | Extraction et transformation de données |
| **Base de Données** | PostgreSQL 15 | Persistance des données |
| **Cache** | Redis 7 | Cache distribué, sessions |
| **Message Queue** | RabbitMQ | Traitement asynchrone |

---

## Architecture Backend

### Architecture en Couches

```mermaid
graph TB
    subgraph "Couche Présentation"
        Controller[Controllers REST]
    end
    
    subgraph "Couche Métier"
        Service[Services]
        Security[Sécurité]
    end
    
    subgraph "Couche Accès Données"
        Repository[Repositories]
        Entity[Entités JPA]
    end
    
    subgraph "Infrastructure"
        DB[(PostgreSQL)]
        Cache[(Redis)]
    end
    
    Controller --> Service
    Service --> Repository
    Repository --> Entity
    Entity --> DB
    Service --> Cache
```

### Modules Backend

```
backend/
├── controller/         # Endpoints REST
│   ├── DealController
│   ├── PositionController
│   └── ReconciliationController
├── service/           # Logique métier
│   ├── DealService
│   └── PositionService
├── repository/        # Accès données
│   ├── DealRepository
│   └── PositionRepository
├── domain/           # Entités JPA
│   ├── Deal
│   ├── Position
│   └── NostroAccount
├── dto/              # Objets de transfert
│   ├── DealRequest
│   └── PositionResponse
├── config/           # Configuration
│   ├── SecurityConfig
│   └── DatabaseConfig
└── integration/      # Intégrations externes
    ├── gl/
    └── swift/
```

### Patterns Utilisés

1. **Repository Pattern**: Abstraction de l'accès aux données
2. **Service Layer Pattern**: Encapsulation de la logique métier
3. **DTO Pattern**: Séparation entités/API
4. **Dependency Injection**: Inversion de contrôle avec Spring
5. **Transaction Management**: Transactions JPA pour la cohérence

---

## Architecture ETL

### Pipeline de Données

```mermaid
flowchart LR
    subgraph Sources
        Bank[Relevés\nBancaires]
        GL[Fichiers\nGL]
        Market[Données\nMarché]
    end
    
    subgraph Extract
        BankParser[Parser\nBancaire]
        GLParser[Parser\nGL]
        MarketAPI[API\nMarché]
    end
    
    subgraph Transform
        Normalize[Normalisation]
        Validate[Validation]
        Enrich[Enrichissement]
    end
    
    subgraph Load
        DB[(PostgreSQL)]
    end
    
    Bank --> BankParser
    GL --> GLParser
    Market --> MarketAPI
    
    BankParser --> Normalize
    GLParser --> Normalize
    MarketAPI --> Normalize
    
    Normalize --> Validate
    Validate --> Enrich
    Enrich --> DB
```

### Extracteurs (Parsers)

- **GlFileParser**: Parse les exports Sage 100 (CSV)
- **BankStatementParser**: Parse les relevés MT940/CAMT.053
- **DealImporter**: Importe les opérations de marché

### Transformateurs

- **CurrencyNormalizer**: Normalisation des codes devises
- **AmountConverter**: Conversion entre formats numériques
- **DateStandardizer**: Standardisation des dates (ISO 8601)

### Chargeurs

- **DatabaseLoader**: Insertion bulk dans PostgreSQL
- **CacheUpdater**: Mise à jour du cache Redis

---

## Modèle de Données

### Diagramme Entités-Relations

```mermaid
erDiagram
    NOSTRO_ACCOUNT ||--o{ POSITION : contains
    NOSTRO_ACCOUNT ||--o{ BANK_TRANSACTION : has
    NOSTRO_ACCOUNT {
        bigint id PK
        string accountNumber
        string currency
        string bankCode
        string status
    }
    
    POSITION {
        bigint id PK
        bigint nostroAccountId FK
        string currency
        decimal amount
        date valueDate
    }
    
    DEAL ||--o{ POSITION : affects
    DEAL {
        bigint id PK
        string dealType
        string buyCurrency
        string sellCurrency
        decimal amount
        decimal rate
        date tradeDate
        date maturityDate
    }
    
    RECONCILIATION ||--|| GL_ENTRY : links
    RECONCILIATION ||--|| BANK_TRANSACTION : links
    RECONCILIATION {
        bigint id PK
        decimal amount
        date matchDate
        string status
    }
    
    GL_ENTRY {
        bigint id PK
        string accountNumber
        decimal amount
        date entryDate
        string status
    }
    
    BANK_TRANSACTION {
        bigint id PK
        bigint nostroAccountId FK
        decimal amount
        date transactionDate
        string reference
        string status
    }
```

### Entités Principales

1. **NostroAccount**: Comptes bancaires
2. **Position**: Positions de change
3. **Deal**: Transactions financières
4. **GlEntry**: Écritures comptables
5. **BankTransaction**: Mouvements bancaires
6. **Reconciliation**: Rapprochements

---

## Flux de Données

### Flux: Création d'une Opération de Change

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant Backend
    participant DB
    participant Cache
    
    User->>Frontend: Saisie opération FX
    Frontend->>Backend: POST /api/deals
    Backend->>Backend: Validation
    Backend->>DB: INSERT deal
    DB-->>Backend: Deal créé
    Backend->>Cache: Invalidate positions cache
    Backend-->>Frontend: 201 Created
    Frontend-->>User: Confirmation
```

### Flux: Rapprochement Bancaire

```mermaid
sequenceDiagram
    participant ETL
    participant Backend
    participant DB
    
    ETL->>Backend: Import relevé bancaire
    Backend->>DB: INSERT bank_transactions
    Backend->>Backend: Matching automatique
    Backend->>DB: SELECT unmatched GL entries
    Backend->>Backend: Algorithme de matching
    Backend->>DB: INSERT reconciliations
    Backend->>DB: UPDATE statuses
```

---

## Sécurité

### Authentification et Autorisation

- **JWT (JSON Web Token)** pour l'authentification
- **Spring Security** pour le contrôle d'accès
- **RBAC (Role-Based Access Control)** pour les permissions

### Rôles

| Rôle | Permissions |
|------|-------------|
| `TREASURY_USER` | Consultation, création opérations |
| `TREASURY_ADMIN` | Approbation, configuration |
| `TREASURY_VIEWER` | Consultation seule |

### Sécurité des Données

- **Encryption at rest**: AES-256 pour les données sensibles
- **Encryption in transit**: TLS 1.3 pour toutes les communications
- **Audit**: Enregistrement de toutes les opérations critiques

---

## Performance et Scalabilité

### Stratégies de Cache

- **Application Cache**: Redis pour les taux de change, positions
- **Database Cache**: Query cache PostgreSQL
- **HTTP Cache**: ETags pour les ressources statiques

### Optimisations

1. **Pagination**: Toutes les listes sont paginées
2. **Lazy Loading**: Chargement différé des relations JPA
3. **Connection Pooling**: HikariCP pour les connexions DB
4. **Index Database**: Index sur les colonnes fréquemment requêtées

### Limites

- **Max transactions/seconde**: 100
- **Max positions simultanées**: 10,000
- **Max deals/jour**: 5,000

---

## Déploiement

### Architecture de Déploiement

```mermaid
flowchart TB
    subgraph "Production"
        LB[Load Balancer]
        
        subgraph "App Tier"
            API1[Backend Instance 1]
            API2[Backend Instance 2]
        end
        
        subgraph "Data Tier"
            DB[(PostgreSQL\nPrimary)]
            DBR[(PostgreSQL\nReplica)]
            Redis[(Redis\nCluster)]
        end
    end
    
    LB --> API1
    LB --> API2
    API1 --> DB
    API2 --> DB
    DB --> DBR
    API1 --> Redis
    API2 --> Redis
```

### Environnements

| Environnement | URL | Base de Données |
|---------------|-----|-----------------|
| **Développement** | localhost:8080 | Local PostgreSQL |
| **Staging** | staging.example.com | Staging DB |
| **Production** | api.example.com | Production DB (HA) |

---

## Monitoring et Logging

### Métriques

- **APM**: Application Performance Monitoring avec Spring Actuator
- **Logs**: Centralisés avec ELK Stack (Elasticsearch, Logstash, Kibana)
- **Alertes**: Prometheus + Grafana

### KPIs

- Temps de réponse API (p95 < 200ms)
- Taux d'erreur (< 0.1%)
- Disponibilité (> 99.9%)

---

## Intégrations

### Systèmes Externes

| Système | Protocole | Direction | Données |
|---------|-----------|-----------|---------|
| **Sage 100** | SFTP/CSV | Importation | Écritures GL |
| **Swift Network** | MT940 | Importation | Relevés bancaires |
| **Bloomberg** | API REST | Importation | Taux de marché |
| **BCEAO** | CAMT.053 | Importation | Mouvements compte central |

---

## Glossaire

Voir [glossary.md](../glossary.md) pour la terminologie complète.

---

## Références

- [Documentation API](./api.md)
- [Guide Développeur](./developer_guide.md)
- [Guide Déploiement](./deployment.md)

---

## Annexes

### Technologies et Frameworks

- **Backend**: Spring Boot 3.2, Spring Security, Spring Data JPA
- **Frontend**: Next.js 14, React 18, TypeScript, Tailwind CSS
- **ETL**: Python 3.11, Pandas, SQLAlchemy
- **Database**: PostgreSQL 15, Hibernate ORM
- **Cache**: Redis 7
- **Build**: Maven 3.9, npm/pnpm
- **Testing**: JUnit 5, Mockito, Jest, Playwright

### Standards et Conventions

- **Coding Style**: Google Java Style Guide
- **API Design**: RESTful principles, OpenAPI 3.0
- **Database**: Naming conventions snake_case
- **Versioning**: Semantic Versioning (SemVer)
