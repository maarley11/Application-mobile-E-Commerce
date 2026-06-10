---
module: [Nom du Module]
composant: Backend
version: 1.0.0
date: [Date de génération]
---

# Documentation API - [Nom du Module]

## Introduction

Cette documentation décrit les API REST du module **[Nom du Module]** du Système de Gestion de Trésorerie (SGT).

**Base URL**: `http://api.example.com/api/treasury`

**Authentification**: Bearer Token (JWT)

**Format**: JSON

---

## Vue d'Ensemble

[Description brève du module et de ses responsabilités]

### Fonctionnalités Principales

- Fonctionnalité 1
- Fonctionnalité 2
- Fonctionnalité 3

---

## Endpoints

### 1. [Nom de l'Endpoint]

#### GET /endpoint-path

**Description**: [Description de ce que fait l'endpoint]

**Authentification**: Requise

**Permissions**: `ROLE_TREASURY_USER`

#### Paramètres de Requête

| Paramètre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| `param1` | string | Non | Description du paramètre |
| `param2` | integer | Non | Description du paramètre |

#### Exemple de Requête

```bash
GET /api/treasury/positions?currency=USD&date=2026-02-12
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Réponse Succès (200)

```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "field1": "value1",
      "field2": 100.50
    }
  ],
  "metadata": {
    "total": 1,
    "page": 1
  }
}
```

#### Réponses d'Erreur

**400 Bad Request** - Paramètres invalides

```json
{
  "status": "error",
  "message": "Le paramètre 'currency' est invalide",
  "code": "INVALID_CURRENCY"
}
```

**401 Unauthorized** - Token manquant ou invalide

```json
{
  "status": "error",
  "message": "Authentification requise",
  "code": "UNAUTHORIZED"
}
```

**404 Not Found** - Ressource non trouvée

```json
{
  "status": "error",
  "message": "Position non trouvée",
  "code": "NOT_FOUND"
}
```

**500 Internal Server Error** - Erreur serveur

```json
{
  "status": "error",
  "message": "Erreur interne du serveur",
  "code": "INTERNAL_ERROR"
}
```

---

### 2. [Autre Endpoint]

#### POST /endpoint-path

**Description**: [Description]

**Authentification**: Requise

**Permissions**: `ROLE_TREASURY_ADMIN`

#### Corps de la Requête

```json
{
  "field1": "value",
  "field2": 123,
  "field3": {
    "nested": "value"
  }
}
```

#### Paramètres du Corps

| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| `field1` | string | Oui | Description |
| `field2` | number | Oui | Description |
| `field3` | object | Non | Description |

#### Validation

- `field1`: 3-50 caractères
- `field2`: > 0
- `field3.nested`: Format email

#### Exemple de Requête

```bash
POST /api/treasury/deals
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "dealType": "FX_SPOT",
  "buyCurrency": "EUR",
  "sellCurrency": "USD",
  "amount": 100000,
  "rate": 1.0850
}
```

#### Réponse Succès (201 Created)

```json
{
  "status": "success",
  "data": {
    "id": 42,
    "dealType": "FX_SPOT",
    "status": "PENDING",
    "createdAt": "2026-02-12T15:30:00Z"
  }
}
```

---

## Modèles de Données

### Position

```typescript
{
  id: number
  currency: string          // Code ISO 4217
  amount: number            // Montant en devise
  valueDate: string         // Format ISO 8601
  accountId: number         // ID du compte Nostro
  status: "ACTIVE" | "CLOSED"
}
```

### Deal

```typescript
{
  id: number
  dealType: "FX_SPOT" | "FX_FORWARD" | "MM_DEPOSIT"
  buyCurrency: string
  sellCurrency: string
  amount: number
  rate: number
  tradeDate: string
  valueDate: string
  maturityDate?: string     // Pour les forwards et MM
  status: "PENDING" | "APPROVED" | "SETTLED"
}
```

---

## Codes d'Erreur

| Code | Description | Action Recommandée |
|------|-------------|--------------------|
| `INVALID_CURRENCY` | Code devise invalide | Vérifier le format ISO 4217 |
| `INSUFFICIENT_BALANCE` | Solde insuffisant | Vérifier le solde disponible |
| `LIMIT_EXCEEDED` | Limite dépassée | Contacter l'administrateur |
| `DUPLICATE_REFERENCE` | Référence en double | Utiliser une référence unique |
| `UNAUTHORIZED` | Non autorisé | Vérifier le token d'authentification |
| `FORBIDDEN` | Accès interdit | Vérifier les permissions utilisateur |

---

## Rate Limiting

- **Limite**: 1000 requêtes / heure par utilisateur
- **Header de réponse**: `X-RateLimit-Remaining`, `X-RateLimit-Reset`
- **Code HTTP si dépassement**: 429 Too Many Requests

---

## Pagination

Pour les endpoints retournant des listes:

**Paramètres de pagination**:
- `page`: Numéro de page (défaut: 1)
- `size`: Taille de page (défaut: 20, max: 100)
- `sort`: Champ de tri (ex: `createdAt,desc`)

**Réponse avec métadonnées**:

```json
{
  "data": [...],
  "metadata": {
    "page": 1,
    "size": 20,
    "total": 156,
    "totalPages": 8
  }
}
```

---

## Webhooks

Le système peut envoyer des notifications webhook pour certains événements:

### Événements Disponibles

- `deal.created` - Nouvelle opération créée
- `deal.approved` - Opération approuvée
- `deal.settled` - Opération dénouée
- `payment.completed` - Paiement exécuté
- `reconciliation.matched` - Rapprochement effectué

### Format du Payload

```json
{
  "event": "deal.created",
  "timestamp": "2026-02-12T15:30:00Z",
  "data": {
    // Objet de l'événement
  }
}
```

---

## Exemples d'Utilisation

### Créer une Position FX

```javascript
// JavaScript/Node.js
const response = await fetch('http://api.example.com/api/treasury/positions', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + token
  },
  body: JSON.stringify({
    currency: 'USD',
    amount: 50000,
    valueDate: '2026-02-15'
  })
});

const data = await response.json();
console.log(data);
```

```python
# Python
import requests

response = requests.post(
    'http://api.example.com/api/treasury/positions',
    headers={
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    },
    json={
        'currency': 'USD',
        'amount': 50000,
        'valueDate': '2026-02-15'
    }
)

data = response.json()
print(data)
```

---

## Glossaire

Voir [glossary.md](../glossary.md) pour la terminologie complète.

**Termes clés**:
- **Position**: Solde en devises étrangères
- **Deal**: Transaction financière (change, placement)
- **Rapprochement**: Vérification GL/Banque

---

## Support

- **Documentation complète**: [Lien vers docs]
- **Support technique**: support@example.com
- **Environnement de test**: https://sandbox.example.com

---

## Historique des Versions

| Version | Date | Changements |
|---------|------|-------------|
| 1.0.0 | 2026-02-12 | Version initiale |
