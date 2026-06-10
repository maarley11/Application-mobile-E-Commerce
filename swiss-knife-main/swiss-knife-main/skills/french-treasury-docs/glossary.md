# Glossaire - Système de Gestion de Trésorerie

## Terminologie Bancaire et Financière

| Terme Anglais | Terme Français | Définition |
|---------------|----------------|------------|
| Treasury | Trésorerie | Gestion des flux financiers et de la liquidité de l'entreprise |
| Cash Management | Gestion de Trésorerie | Optimisation des flux de trésorerie |
| Cash Flow | Flux de Trésorerie | Mouvement d'entrée et de sortie de liquidités |
| Reconciliation | Rapprochement (Bancaire) | Processus de vérification de la cohérence entre comptes bancaires et comptables |
| Payment | Paiement | Transfert de fonds |
| Deal | Opération / Transaction | Transaction financière (change, placement, etc.) |
| Position | Position (de Change) | Solde en devises étrangères |
| Risk Limit | Limite de Risque | Seuil maximal d'exposition au risque |
| Nostro Account | Compte Nostro | Compte bancaire de l'entreprise tenu par une banque correspondante |
| GL Entry | Écriture Comptable | Enregistrement dans le grand livre comptable |
| Bank Statement | Relevé Bancaire | Document listant les mouvements sur un compte bancaire |
| Valuation | Valorisation / Évaluation | Calcul de la valeur d'une position ou d'un actif |
| Mark-to-Market (MtM) | Valorisation au Prix du Marché | Évaluation d'un actif à sa valeur de marché actuelle |
| FX (Foreign Exchange) | Change / Opérations de Change | Achat/vente de devises |
| Spot | Au Comptant | Transaction avec règlement immédiat |
| Forward | À Terme | Transaction avec règlement différé |
| Spread | Écart / Marge | Différence entre prix d'achat et de vente |
| Counterparty | Contrepartie | Partie avec laquelle on effectue une transaction |
| Settlement | Règlement / Dénouement | Exécution finale d'une transaction |
| Maturity | Échéance / Maturité | Date de fin d'un placement ou d'un emprunt |
| Yield | Rendement | Retour sur investissement |
| Principal | Principal / Capital | Montant initial d'un placement |
| Interest | Intérêt | Rémunération du capital |
| Rate | Taux | Prix ou pourcentage (taux d'intérêt, taux de change) |

## Terminologie Technique

| Terme Anglais | Terme Français | Définition |
|---------------|----------------|------------|
| Backend | Backend / Serveur | Partie serveur de l'application |
| Front-office | Front-office | Interface pour les opérateurs de marché |
| Back-office | Back-office | Interface pour la gestion administrative |
| ETL | ETL (Extract-Transform-Load) | Processus d'extraction, transformation et chargement de données |
| API | API (Interface de Programmation) | Interface permettant la communication entre systèmes |
| Endpoint | Point de terminaison / Endpoint | URL d'accès à une ressource API |
| Repository | Dépôt / Repository | Couche d'accès aux données |
| Service Layer | Couche Service | Couche contenant la logique métier |
| DTO (Data Transfer Object) | DTO / Objet de Transfert | Objet utilisé pour transférer des données entre couches |
| Entity | Entité | Représentation d'un objet métier en base de données  |
| Controller | Contrôleur | Composant gérant les requêtes HTTP |
| Middleware | Middleware / Intergiciel | Logiciel intermédiaire entre systèmes |
| Database | Base de Données | Système de stockage structuré de données |
| Schema | Schéma | Structure de la base de données |
| Migration | Migration | Script de modification de schéma |
| Seeder | Seeder / Générateur de Données | Script pour peupler la base avec des données de test |
| Audit | Audit / Traçabilité | Enregistrement des modifications de données |
| Transaction | Transaction (base de données) | Ensemble d'opérations atomiques |
| Rollback | Annulation / Rollback | Retour en arrière d'une transaction |

## Modules du Système

| Module (EN) | Module (FR) | Description |
|-------------|-------------|-------------|
| Nostro Management | Gestion des Comptes Nostro | Suivi des comptes bancaires |
| Payment Management | Gestion des Paiements | Traitement des paiements sortants |
| Reconciliation | Rapprochement Bancaire | Rapprochement GL/Banque |
| Investments | Investissements / Placements | Gestion des DAT et titres |
| Market & Risk | Marché & Risques | Suivi des positions et limites |
| Compliance | Conformité | Contrôle des limites réglementaires |
| Reporting | Reporting / Tableaux de Bord | Génération de rapports |
| Analytics | Analytique | Analyses et statistiques |

## Statuts et États

| Statut (EN) | Statut (FR) | Description |
|-------------|-------------|-------------|
| PENDING | EN ATTENTE | En cours de traitement |
| APPROVED | APPROUVÉ | Validé |
| REJECTED | REJETÉ | Refusé |
| COMPLETED | TERMINÉ | Traitement achevé |
| FAILED | ÉCHOUÉ | Erreur de traitement |
| MATCHED | RAPPROCHÉ | Rapprochement effectué |
| UNMATCHED | NON RAPPROCHÉ | En attente de rapprochement |
| ACTIVE | ACTIF | En cours de validité |
| EXPIRED | EXPIRÉ | Échu |
| CANCELLED | ANNULÉ | Annulé |

## Codes et Formats

| Code | Description | Exemple |
|------|-------------|---------|
| ISO 4217 | Code devise (3 lettres) | USD, EUR, XOF |
| SWIFT/BIC | Code bancaire international | BCEAOSND |
| IBAN | Numéro de compte bancaire international | SN08 SN001 01013 049506600189 32 |
| MT940 | Format de relevé bancaire électronique | Message SWIFT |
| CAMT.053 | Format XML de relevé bancaire | Standard ISO 20022 |

## Abréviations Courantes

| Abréviation | Signification | Français |
|-------------|---------------|----------|
| DAT | Dépôt À Terme | Placement à échéance fixe |
| GL | General Ledger | Grand Livre (comptable) |
| P&L | Profit & Loss | Profits & Pertes |
| KYC | Know Your Customer | Connaissance du Client |
| AML | Anti-Money Laundering | Lutte Anti-Blanchiment |
| STP | Straight-Through Processing | Traitement Automatisé |
| T+0, T+1, T+2 | Trade Date + jours | Jour de transaction + délai de règlement |
