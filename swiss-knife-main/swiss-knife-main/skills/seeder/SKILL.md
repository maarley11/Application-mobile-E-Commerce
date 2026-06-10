---
name: Database Seeder
description: Tools and instructions for seeding the Treasury Service PostgreSQL database with test data based on API requirements.
---

# Database Seeder Skill

This skill provides a Python-based seeding mechanism for the Treasury Service database. It is designed to populate the database with realistic test data that aligns with the `api_registry.md` requirements, ensuring that all key endpoints return meaningful data.

## Locations

- **Script**: `.agent/skills/seeder/scripts/seed_data.py`
- **Requirements**: `.agent/skills/seeder/scripts/requirements.txt`

## Prerequisites

- Python 3.8+
- Network access to the PostgreSQL database (default port: 5469)

## Setup & usage

1.  **Install Dependencies**
    From the root of `i-sib-tresorerie-service`, run:
    ```bash
    pip install -r .agent/skills/seeder/scripts/requirements.txt
    ```

2.  **Run the Seeder**
    To seed the database with default settings (localhost:5432, user: postgres, db: sib_treasury):
    ```bash
    python .agent/skills/seeder/scripts/seed_data.py --clean
    ```

    **Arguments:**
    - `--host`: Database host (default: `localhost`)
    - `--port`: Database port (default: `5432`)
    - `--db`: Database name (default: `sib_treasury`)
    - `--user`: Database user (default: `postgres`)
    - `--password`: Database password (default: `password`)
    - `--clean`: **Destructive**. Truncates tables before inserting new data. Use with caution.

## Entities Seeded

The script populates the following tables, mapped to `api_registry.md` features:

| Entity | Table | Relevant API Endpoint |
| :--- | :--- | :--- |
| **NostroAccount** | `nostro_accounts` | `GET /api/treasury/accounts/nostro` |
| **Payment** | `payments` | `GET /api/treasury/payments/pending`, `GET /api/treasury/payments/history` |
| **TreasuryAlert** | `treasury_alerts` | `GET /api/treasury/alerts` |
| **Forecast** | `forecasts` | `GET /api/treasury/forecasts` |
| **Position** | `positions` | `GET /api/treasury/positions` |
| **RiskLimit** | `risk_limits` | `GET /api/treasury/limits/utilization` |
| **Deal** | `deals` | `GET /api/treasury/deals` |

## Troubleshooting

- **Connection Refused**: Ensure the backend container or local PostgreSQL service is running.
- **Permission Denied**: Check the database user credentials.
- **Missing Tables**: The application must be started at least once to allow Hibernate/JPA to create the schema (ddl-auto=update).
