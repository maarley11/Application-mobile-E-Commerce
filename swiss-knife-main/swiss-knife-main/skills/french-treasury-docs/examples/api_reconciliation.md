---
module: Rapprochement Bancaire
composant: Backend API
version: 1.0.0
date: 2026-02-12
auteur: Agent AI - Documentation Skill
---

# API Rapprochement Bancaire - Documentation

## Introduction

Cette documentation décrit les API REST du module **Rapprochement Bancaire** du Système de Gestion de Trésorerie (SGT). Le rapprochement bancaire permet de vérifier la cohérence entre les écritures comptables (GL) et les transactions bancaires.

**Base URL**: `http://localhost:8080/api/treasury`

**Authentification**: Bearer Token (JWT)

**Format**: JSON

---

## Vue d'Ensemble

Le module de rapprochement bancaire gère:
- La récupération des écritures non rapprochées (GL et bancaires)
- Le rapprochement manuel entre GL et transactions bancaires
- L'annulation de rapprochements
- La création d'ajustements comptables

---

## Endpoints

### 1. Récupérer les Éléments Non Rapprochés

#### GET /reconciliation/unmatched

**Description**: Récupère la liste combinée des écritures GL et transactions bancaires qui n'ont pas encore été rapprochées.

**Authentification**: Requise

**Permissions**: `ROLE_TREASURY_USER`

#### Paramètres de Requête

| Paramètre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| `currency` | string | Non | Filtrer par devise (code ISO 4217) |
| `dateFrom` | string | Non | Date de début (format: YYYY-MM-DD) |
| `dateTo` | string | Non | Date de fin (format: YYYY-MM-DD) |

#### Exemple de Requête

```bash
GET /api/treasury/reconciliation/unmatched?currency=USD&dateFrom=2026-02-01
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Réponse Succès (200)

```json
{
  "status": "success",
  "data": [
    {
      "id": "GL-1234",
      "type": "GL",
      "accountNumber": "512000",
      "amount": 50000.00,
      "currency": "USD",
      "date": "2026-02-10",
      "reference": "INV-2024-001",
      "narrative": "Paiement fournisseur ABC",
      "status": "UNMATCHED"
    },
    {
      "id": "BK-5678",
      "type": "BANK",
      "nostroAccount": "USD-JPM-001",
      "amount": -50000.00,
      "currency": "USD",
      "transactionDate": "2026-02-12",
      "valueDate": "2026-02-12",
      "reference": "TRF20260212001",
      "description": "Wire transfer to ABC Corp",
      "status": "UNMATCHED"
    }
  ],
  "metadata": {
    "total": 2,
    "glCount": 1,
    "bankCount": 1
  }
}
```

#### Réponses d'Erreur

**401 Unauthorized** - Token manquant ou invalide

```json
{
  "status": "error",
  "message": "Authentification requise",
  "code": "UNAUTHORIZED"
}
```

---

### 2. Rapprocher des Éléments

#### POST /reconciliation/match

**Description**: Effectue le rapprochement manuel entre une écriture GL et une transaction bancaire. Crée un enregistrement de rapprochement et met à jour les statuts des deux éléments.

**Authentification**: Requise

**Permissions**: `ROLE_TREASURY_USER`

#### Corps de la Requête

```json
{
  "glId": "GL-1234",
  "bankId": "BK-5678"
}
```

#### Paramètres du Corps

| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| `glId` | string | Oui | Identifiant de l'écriture GL (préfixe GL-) |
| `bankId` | string | Oui | Identifiant de la transaction bancaire (préfixe BK-) |

#### Validation

- Les deux éléments doivent exister dans la base
- Les montants doivent être cohérents (opposés en signe)
- Les devises doivent correspondre
- Les deux éléments doivent avoir le statut UNMATCHED

#### Exemple de Requête

```bash
POST /api/treasury/reconciliation/match
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "glId": "GL-1234",
  "bankId": "BK-5678"
}
```

#### Réponse Succès (200)

```json
{
  "status": "success",
  "message": "Rapprochement effectué avec succès",
  "data": {
    "reconciliationId": 42,
    "glId": "GL-1234",
    "bankId": "BK-5678",
    "amount": 50000.00,
    "matchDate": "2026-02-12T15:30:00Z",
    "status": "MATCHED"
  }
}
```

#### Réponses d'Erreur

**400 Bad Request** - Validation échouée

```json
{
  "status": "error",
  "message": "Les montants ne correspondent pas: GL=50000, Bank=-48000",
  "code": "AMOUNT_MISMATCH"
}
```

**404 Not Found** - Élément non trouvé

```json
{
  "status": "error",
  "message": "Écriture GL non trouvée: GL-1234",
  "code": "GL_NOT_FOUND"
}
```

---

### 3. Annuler un Rapprochement

#### POST /reconciliation/unmatch

**Description**: Annule un rapprochement existant. Supprime l'enregistrement de rapprochement et réinitialise les statuts des éléments à UNMATCHED.

**Authentification**: Requise

**Permissions**: `ROLE_TREASURY_ADMIN`

#### Corps de la Requête

```json
{
  "reconciliationId": 42
}
```

#### Paramètres du Corps

| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| `reconciliationId` | integer | Oui | ID du rapprochement à annuler |

#### Exemple de Requête

```bash
POST /api/treasury/reconciliation/unmatch
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "reconciliationId": 42
}
```

#### Réponse Succès (200)

```json
{
  "status": "success",
  "message": "Rapprochement annulé avec succès"
}
```

---

### 4. Créer un Ajustement

#### POST /reconciliation/adjust

**Description**: Crée une écriture GL d'ajustement pour une transaction bancaire qui n'a pas d'écriture GL correspondante.

**Authentification**: Requise

**Permissions**: `ROLE_TREASURY_ADMIN`

#### Corps de la Requête

```json
{
  "bankId": "BK-9999",
  "accountNumber": "512000",
  "narrative": "Ajustement pour frais bancaires"
}
```

#### Paramètres du Corps

| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| `bankId` | string | Oui | ID de la transaction bancaire (préfixe BK-) |
| `accountNumber` | string | Oui | Compte GL pour l'ajustement |
| `narrative` | string | Non | Description de l'ajustement |

#### Exemple de Requête

```bash
POST /api/treasury/reconciliation/adjust
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "bankId": "BK-9999",
  "accountNumber": "512000",
  "narrative": "Ajustement pour frais bancaires non comptabilisés"
}
```

#### Réponse Succès (201 Created)

```json
{
  "status": "success",
  "message": "Ajustement créé et rapproché",
  "data": {
    "glEntryId": 1001,
    "reconciliationId": 43,
    "amount": -25.50,
    "currency": "USD",
    "createdAt": "2026-02-12T15:45:00Z"
  }
}
```

---

### 5. Récupérer les Écritures GL (avec Filtres)

#### GET /reconciliation/gl-entries

**Description**: Récupère les écritures GL avec filtrage avancé.

**Authentification**: Requise

#### Paramètres de Requête

| Paramètre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| `journalCode` | string | Non | Code journal (ex: BQ, OD) |
| `status` | string | Non | Statut (MATCHED, UNMATCHED) |
| `dateFrom` | string | Non | Date de début |
| `dateTo` | string | Non | Date de fin |

#### Exemple de Requête

```bash
GET /api/treasury/reconciliation/gl-entries?journalCode=BQ&status=UNMATCHED
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Réponse Succès (200)

```json
{
  "status": "success",
  "data": [
    {
      "id": 1234,
      "accountNumber": "512000",
      "amount": 50000.00,
      "currency": "XOF",
      "entryDate": "2026-02-10",
      "reference": "INV-001",
      "narrative": "Paiement fournisseur",
      "journalCode": "BQ",
      "letteringCode": null,
      "status": "UNMATCHED"
    }
  ]
}
```

---

## Modèles de Données

### ReconRecordDTO

```typescript
{
  id: string               // "GL-123" ou "BK-456"
  type: "GL" | "BANK"      // Type d'enregistrement
  amount: number           // Montant
  currency: string         // Code ISO devise
  date: string             // Date (ISO 8601)
  reference: string        // Référence unique
  status: "MATCHED" | "UNMATCHED"
  
  // Champs spécifiques GL
  accountNumber?: string
  narrative?: string
  journalCode?: string
  
  // Champs spécifiques BANK
  nostroAccount?: string
  transactionDate?: string
  valueDate?: string
  description?: string
}
```

### MatchRequest

```typescript
{
  glId: string            // ID de l'écriture GL (ex: "GL-1234")
  bankId: string          // ID de la transaction bancaire (ex: "BK-5678")
}
```

### AdjustmentRequest

```typescript
{
  bankId: string          // ID de la transaction bancaire
  accountNumber: string   // Compte GL pour l'ajustement
  narrative?: string      // Description (optionnel)
}
```

---

## Codes d'Erreur

| Code | Description | Action Recommandée |
|------|-------------|--------------------|
| `GL_NOT_FOUND` | Écriture GL introuvable | Vérifier l'ID fourni |
| `BANK_NOT_FOUND` | Transaction bancaire introuvable | Vérifier l'ID fourni |
| `AMOUNT_MISMATCH` | Montants incompatibles | Vérifier la cohérence des montants |
| `CURRENCY_MISMATCH` | Devises différentes | Vérifier les devises |
| `ALREADY_MATCHED` | Élément déjà rapproché | Annuler le rapprochement existant d'abord |
| `RECONCILIATION_NOT_FOUND` | Rapprochement introuvable | Vérifier l'ID du rapprochement |

---

## Flux de Travail

### Scénario 1: Rapprochement Manuel Standard

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant Backend
    participant Database
    
    User->>Frontend: Recherche éléments non rapprochés
    Frontend->>Backend: GET /reconciliation/unmatched
    Backend->>Database: SELECT GL & Bank UNMATCHED
    Database-->>Backend: Liste des éléments
    Backend-->>Frontend: ReconRecordDTO[]
    Frontend-->>User: Affichage liste
    
    User->>Frontend: Sélectionne GL + Bank
    Frontend->>Backend: POST /reconciliation/match
    Backend->>Database: BEGIN Transaction
    Backend->>Database: INSERT Reconciliation
    Backend->>Database: UPDATE GL status=MATCHED
    Backend->>Database: UPDATE Bank status=MATCHED
    Backend->>Database: COMMIT
    Database-->>Backend: Success
    Backend-->>Frontend: 200 OK
    Frontend-->>User: Confirmation
```

### Scénario 2: Ajustement pour Transaction Bancaire Orpheline

```mermaid
sequenceDiagram
    participant User
    participant Backend
    participant Database
    
    User->>Backend: POST /reconciliation/adjust
    Backend->>Database: BEGIN Transaction
    Backend->>Database: INSERT GL Entry (adjustment)
    Backend->>Database: INSERT Reconciliation
    Backend->>Database: UPDATE statuses
    Backend->>Database: COMMIT
    Database-->>Backend: GL + Recon IDs
    Backend-->>User: 201 Created
```

---

## Exemples d'Utilisation

### JavaScript/TypeScript

```typescript
// Service de rapprochement
class ReconciliationService {
  private baseUrl = 'http://localhost:8080/api/treasury/reconciliation';
  
  async getUnmatched(filters?: {
    currency?: string;
    dateFrom?: string;
    dateTo?: string;
  }): Promise<ReconRecord[]> {
    const params = new URLSearchParams(filters as any);
    const response = await fetch(`${this.baseUrl}/unmatched?${params}`, {
      headers: {
        'Authorization': `Bearer ${this.getToken()}`
      }
    });
    
    if (!response.ok) throw new Error('Failed to fetch unmatched items');
    
    const data = await response.json();
    return data.data;
  }
  
  async match(glId: string, bankId: string): Promise<void> {
    const response = await fetch(`${this.baseUrl}/match`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.getToken()}`
      },
      body: JSON.stringify({ glId, bankId })
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message);
    }
  }
}
```

### Python

```python
import requests
from typing import List, Dict

class ReconciliationClient:
    def __init__(self, base_url: str, token: str):
        self.base_url = f"{base_url}/api/treasury/reconciliation"
        self.token = token
    
    def get_unmatched(self, currency: str = None) -> List[Dict]:
        params = {}
        if currency:
            params['currency'] = currency
        
        response = requests.get(
            f"{self.base_url}/unmatched",
            params=params,
            headers={"Authorization": f"Bearer {self.token}"}
        )
        
        response.raise_for_status()
        return response.json()['data']
    
    def match(self, gl_id: str, bank_id: str) -> Dict:
        response = requests.post(
            f"{self.base_url}/match",
            json={"glId": gl_id, "bankId": bank_id},
            headers={
                "Authorization": f"Bearer {self.token}",
                "Content-Type": "application/json"
            }
        )
        
        response.raise_for_status()
        return response.json()['data']
```

---

## Glossaire

**Rapprochement Bancaire**: Processus de vérification de la cohérence entre les écritures comptables (GL) et les transactions bancaires.

**Écriture GL**: Enregistrement dans le Grand Livre comptable (General Ledger).

**Transaction Bancaire**: Mouvement enregistré sur un relevé bancaire.

**Compte Nostro**: Compte bancaire de l'entreprise tenu par une banque correspondante.

**Ajustement**: Écriture comptable créée manuellement pour corriger une différence.

**Code Journal**: Code identifiant le type de journal comptable (BQ=Banque, OD=Opérations Diverses).

**Lettrage**: Association d'écritures comptables qui s'équilibrent.

---

## Références

- [Architecture Backend](../templates/architecture.md)
- [Guide de Déploiement](../templates/deployment.md)
- [Glossaire Complet](../glossary.md)
- [Code Source](https://github.com/organization/i-sib-tresorerie-service)

---

## Support

- **Documentation**: https://docs.treasury.example.com
- **Support**: support@example.com
- **Environnement de test**: https://sandbox.treasury.example.com

---

## Historique des Versions

| Version | Date | Changements |
|---------|------|-------------|
| 1.0.0 | 2026-02-12 | Documentation initiale du module Rapprochement |
