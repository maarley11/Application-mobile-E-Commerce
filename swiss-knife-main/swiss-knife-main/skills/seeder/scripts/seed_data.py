import argparse
import psycopg2
import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()

def connect_db(args):
    try:
        conn = psycopg2.connect(
            host=args.host,
            port=args.port,
            database=args.db,
            user=args.user,
            password=args.password
        )
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None

def clear_tables(cur):
    print("Cleaning existing data...")
    tables = ['reserve_requirements', 'macro_accounts', 'deals', 'risk_limits', 'positions', 'forecasts', 'payments', 'treasury_alerts', 'nostro_accounts', 'market_rates', 'gl_entries', 'bank_transactions', 'risk_score_history', 'recent_activities']
    for table in tables:
        cur.execute(f"TRUNCATE TABLE {table} CASCADE;")
    print("Tables truncated.")

def ensure_schema(cur):
    print("Verifying schema...")
    # Check/Add 'type' column to payments
    cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name='payments' AND column_name='type';")
    if not cur.fetchone():
        print("Adding missing column 'type' to 'payments'...")
        cur.execute("ALTER TABLE payments ADD COLUMN type VARCHAR(10) DEFAULT 'DEBIT';")
    
    # Check/Add 'category' column to nostro_accounts
    cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name='nostro_accounts' AND column_name='category';")
    if not cur.fetchone():
        print("Adding missing column 'category' to 'nostro_accounts'...")
        cur.execute("ALTER TABLE nostro_accounts ADD COLUMN category VARCHAR(50);")
    
    # Check/Create macro_accounts table if it doesn't exist
    cur.execute("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'macro_accounts');")
    if not cur.fetchone()[0]:
        print("Creating 'macro_accounts' table...")
        cur.execute("""
            CREATE TABLE macro_accounts (
                id BIGSERIAL PRIMARY KEY,
                classification VARCHAR(50) NOT NULL,
                category VARCHAR(100) NOT NULL,
                currency VARCHAR(3) DEFAULT 'XOF',
                balance NUMERIC(19, 2) NOT NULL,
                trend VARCHAR(20) DEFAULT 'stable',
                change_pct NUMERIC(5, 2) DEFAULT 0.00
            );
        """)
    
    # Check/Create reserve_requirements table if it doesn't exist
    cur.execute("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'reserve_requirements');")
    if not cur.fetchone()[0]:
        print("Creating 'reserve_requirements' table...")
        cur.execute("""
            CREATE TABLE reserve_requirements (
                id BIGSERIAL PRIMARY KEY,
                amount NUMERIC(19, 2) NOT NULL,
                currency VARCHAR(3) NOT NULL DEFAULT 'XOF',
                compliance BOOLEAN NOT NULL DEFAULT TRUE,
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)

    # Check/Add 'tab' column to market_rates
    cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name='market_rates' AND column_name='tab';")
    if not cur.fetchone():
        print("Adding missing column 'tab' to 'market_rates'...")
        cur.execute("ALTER TABLE market_rates ADD COLUMN tab VARCHAR(50) DEFAULT 'rates';")

    # Check/Create recent_activities table
    cur.execute("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'recent_activities');")
    if not cur.fetchone()[0]:
        print("Creating 'recent_activities' table...")
        cur.execute("""
            CREATE TABLE recent_activities (
                id BIGSERIAL PRIMARY KEY,
                title VARCHAR(100) NOT NULL,
                description TEXT,
                amount_str VARCHAR(50),
                initiated_by VARCHAR(100),
                approved_by VARCHAR(100),
                activity_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                status VARCHAR(50),
                risk_level VARCHAR(50),
                activity_type VARCHAR(50)
            );
        """)
    
    print("Schema verified.")

def seed_nostro_accounts(cur, count=16):
    print(f"Seeding {count} Nostro Accounts...")
    banks = [
        'SG', 'CBAO', 'Ecobank', 'BOA', 'UBA',
        'BNP Paribas', 'Barclays', 'Deutsche Bank', 'Santander',
        'JPMorgan Chase', 'Bank of America', 'Citi',
        'DBS Bank', 'Mitsubishi UFJ', 'HSBC', 'Standard Chartered'
    ]
    currencies = ['XOF', 'USD', 'EUR', 'GBP', 'CNY', 'JPY']
    categories = ['Banque Centrale', 'Banques Commerciales (Locales)', 'Banques Étrangères (Nostro)', 'Caisse']
    
    for _ in range(count):
        account_id = fake.bothify(text='NAS-###')
        bank_name = random.choice(banks)
        currency = random.choice(currencies)
        category = random.choice(categories)
        account_number = fake.iban()
        ledger_balance = random.uniform(1000000, 500000000)
        available_balance = ledger_balance * 0.95
        uncleared_funds = ledger_balance - available_balance
        status = 'ACTIVE'
        last_updated = datetime.now()

        cur.execute("""
            INSERT INTO nostro_accounts (id, bank_name, category, currency, account_number, ledger_balance, available_balance, uncleared_funds, status, last_updated)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (account_id, bank_name, category, currency, account_number, ledger_balance, available_balance, uncleared_funds, status, last_updated))
    print("Nostro Accounts seeded.")

def seed_payments(cur, count=20):
    print(f"Seeding {count} Payments...")
    statuses = ['PENDING', 'APPROVED', 'REJECTED', 'PROCESSED']
    currencies = ['XOF', 'USD', 'EUR']
    categories = ['Supplier', 'Tax', 'Salary', 'Operational', 'Interbank', 'Collection', 'FX Operation', 'Fees']
    types = ['DEBIT', 'CREDIT']

    for _ in range(count):
        beneficiary = fake.company()
        amount = random.uniform(50000, 15000000)
        currency = random.choice(currencies)
        category = random.choice(categories)
        payment_type = random.choice(types)
        
        # Adjust category based on type for realism
        if payment_type == 'CREDIT':
            category = random.choice(['Collection', 'FX Operation', 'Interest', 'Interbank Transfer'])
        else:
            category = random.choice(['Supplier', 'Tax', 'Salary', 'Operational', 'Fees'])

        reference = fake.bothify(text='PAY-####-????')
        description = fake.sentence(nb_words=6)
        status = random.choice(statuses)
        value_date = fake.date_between(start_date='-30d', end_date='+30d')
        created_at = fake.date_time_between(start_date='-60d', end_date='now')
        updated_at = datetime.now()

        cur.execute("""
            INSERT INTO payments (beneficiary, amount, currency, category, type, reference, description, status, value_date, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (beneficiary, amount, currency, category, payment_type, reference, description, status, value_date, created_at, updated_at))
    print("Payments seeded.")

def seed_alerts(cur, count=5):
    print(f"Seeding {count} Treasury Alerts...")
    
    alert_templates = {
        'CRITICAL': [
            "Solde du compte Nostro SG XOF en dessous du seuil critique (5M XOF)",
            "Limite de contrepartie JPMorgan Chase dépassée (95% utilisée)",
            "Position de change USD non couverte supérieure à 10M USD",
            "Échec de réconciliation bancaire - Écart de 2.5M XOF détecté",
            "Paiement urgent en attente d'approbation depuis 48h"
        ],
        'WARNING': [
            "Solde disponible CBAO EUR approchant le minimum opérationnel",
            "Taux de change EUR/USD volatil - Variation de 2% en 24h",
            "3 paiements en attente d'approbation depuis plus de 24h",
            "Utilisation de la limite pays Sénégal à 75%",
            "Prévision de trésorerie négative dans 5 jours"
        ],
        'INFO': [
            "Nouveau deal FX traité - EUR/USD 1.5M",
            "Réconciliation bancaire complétée avec succès",
            "Rapport de position quotidien généré",
            "Mise à jour des taux de change effectuée",
            "Dépôt à terme arrivant à échéance dans 7 jours"
        ]
    }
    
    for _ in range(count):
        alert_id = fake.bothify(text='ALT-####')
        level = random.choice(['CRITICAL', 'WARNING', 'INFO'])
        message = random.choice(alert_templates[level])
        action_url = "/treasury/dashboard"
        created_at = datetime.now()

        cur.execute("""
            INSERT INTO treasury_alerts (id, level, message, action_url, created_at)
            VALUES (%s, %s, %s, %s, %s)
        """, (alert_id, level, message, action_url, created_at))
    print("Treasury Alerts seeded.")

def seed_forecasts(cur, count=30):
    print(f"Seeding {count} Forecasts...")
    horizons = ['SHORT', 'MEDIUM']
    
    for i in range(count):
        date = datetime.now().date() + timedelta(days=i)
        amount = random.uniform(50000000, 200000000)
        confidence_low = amount * 0.85
        confidence_high = amount * 1.15
        horizon = random.choice(horizons)

        cur.execute("""
            INSERT INTO forecasts (date, amount, confidence_low, confidence_high, horizon)
            VALUES (%s, %s, %s, %s, %s)
        """, (date, amount, confidence_low, confidence_high, horizon))
    print("Forecasts seeded.")

def seed_positions(cur, count=10):
    print(f"Seeding {count} Positions...")
    currencies = ['USD', 'EUR', 'GBP', 'CNY', 'JPY', 'XOF']
    
    for _ in range(count):
        currency = random.choice(currencies)
        amount = random.uniform(-10000000, 10000000)  # Can be negative for short positions
        date = fake.date_between(start_date='-30d', end_date='today')
        account_number = fake.iban()

        cur.execute("""
            INSERT INTO positions (currency, amount, date, account_number)
            VALUES (%s, %s, %s, %s)
        """, (currency, amount, date, account_number))
    print("Positions seeded.")

def seed_risk_limits(cur, count=15):
    print(f"Seeding {count} Risk Limits...")
    limit_types = ['COUNTERPARTY', 'COUNTRY', 'CURRENCY', 'FX_POSITION']
    counterparties = ['JPMorgan Chase', 'Citi', 'HSBC', 'BNP Paribas', 'Deutsche Bank']
    countries = ['SN', 'US', 'FR', 'GB', 'CN', 'JP']
    currencies = ['USD', 'EUR', 'GBP', 'CNY', 'JPY', 'XOF']
    
    for _ in range(count):
        limit_type = random.choice(limit_types)
        
        if limit_type == 'COUNTERPARTY':
            entity = random.choice(counterparties)
        elif limit_type == 'COUNTRY':
            entity = random.choice(countries)
        else:  # CURRENCY
            entity = random.choice(currencies)
        
        limit_amount = random.uniform(10000000, 100000000)
        utilized_amount = random.uniform(0, limit_amount * 0.9)

        cur.execute("""
            INSERT INTO risk_limits (limit_type, entity, limit_amount, utilized_amount)
            VALUES (%s, %s, %s, %s)
        """, (limit_type, entity, limit_amount, utilized_amount))
    print("Risk Limits seeded.")

def seed_deals(cur, count=25):
    print(f"Seeding {count} Deals...")
    deal_types = ['SPOT', 'FORWARD', 'DEPOSIT']
    currency_pairs = ['EUR/USD', 'USD/JPY', 'GBP/USD', 'EUR/GBP', 'USD/CNY']
    currencies = ['USD', 'EUR', 'GBP', 'XOF']
    counterparties = ['JPMorgan Chase', 'Citi', 'HSBC', 'BNP Paribas', 'Deutsche Bank', 'Standard Chartered']
    tenors = ['1M', '3M', '6M', '1Y', '2Y']
    
    for _ in range(count):
        deal_type = random.choice(deal_types)
        counterparty = random.choice(counterparties)
        reference = fake.bothify(text='DEAL-####-????')
        trade_date = fake.date_between(start_date='-60d', end_date='today')
        value_date = trade_date + timedelta(days=random.randint(0, 2))
        
        # Spread created_at across the last 60 days for realistic activity ordering
        created_at = fake.date_time_between(start_date='-60d', end_date='now')
        updated_at = created_at + timedelta(hours=random.randint(0, 48))
        
        if deal_type in ['SPOT', 'FORWARD']:
            # FX Deal
            currency_pair = random.choice(currency_pairs)
            amount_vector = random.uniform(100000, 10000000)
            rate = random.uniform(0.8, 1.5)
            tenor = random.choice(tenors) if deal_type == 'FORWARD' else None
            maturity_date = value_date + timedelta(days=random.randint(30, 730)) if deal_type == 'FORWARD' else None
            
            cur.execute("""
                INSERT INTO deals (type, currency_pair, amount_vector, rate, tenor, trade_date, value_date, maturity_date, counterparty, reference, created_at, updated_at, is_derivative)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (deal_type, currency_pair, amount_vector, rate, tenor, trade_date, value_date, maturity_date, counterparty, reference, created_at, updated_at, False))
        else:
            # Money Market Deal (DEPOSIT)
            currency = random.choice(currencies)
            principal = random.uniform(1000000, 50000000)
            rate = random.uniform(1.5, 5.5)
            tenor = random.choice(tenors)
            maturity_date = value_date + timedelta(days=random.randint(30, 365))
            
            cur.execute("""
                INSERT INTO deals (type, currency, principal, rate, tenor, trade_date, value_date, maturity_date, counterparty, reference, created_at, updated_at, is_derivative)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (deal_type, currency, principal, rate, tenor, trade_date, value_date, maturity_date, counterparty, reference, created_at, updated_at, False))
    print("Deals seeded.")


def seed_market_rates(cur, count=80):
    print(f"Seeding {count} Market Rates...")
    sources = ['BLOOMBERG', 'REUTERS', 'ECB']
    
    # Pre-defined categories
    market_items = [
        {'name': 'US 10Y Treasury', 'tab': 'rates', 'base': 4.23},
        {'name': 'Fed Funds Rate', 'tab': 'rates', 'base': 5.50},
        {'name': 'US 2Y Treasury', 'tab': 'rates', 'base': 4.89},
        {'name': 'LIBOR 3M', 'tab': 'rates', 'base': 5.32},
        {'name': 'EUR/USD', 'tab': 'currencies', 'base': 1.0945},
        {'name': 'USD/XOF', 'tab': 'currencies', 'base': 600.0},
        {'name': 'EUR/XOF', 'tab': 'currencies', 'base': 655.957},
        {'name': 'GBP/USD', 'tab': 'currencies', 'base': 1.2630},
        {'name': 'USD/JPY', 'tab': 'currencies', 'base': 148.20},
        {'name': 'Or (Gold)', 'tab': 'commodities', 'base': 2045.50},
        {'name': 'Pétrole (WTI)', 'tab': 'commodities', 'base': 78.20},
        {'name': 'S&P 500', 'tab': 'indices', 'base': 4950.20},
        {'name': 'NASDAQ', 'tab': 'indices', 'base': 15620.40},
        {'name': 'CAC 40', 'tab': 'indices', 'base': 7640.80},
    ]
    
    for _ in range(count):
        item = random.choice(market_items)
        pair = item['name']
        tab = item['tab']
        base_bid = float(item['base'])
        
        bid = base_bid * random.uniform(0.95, 1.05)
        ask = bid * random.uniform(1.0001, 1.0005)
        timestamp = fake.date_time_between(start_date='-30d', end_date='now')
        source = random.choice(sources)

        cur.execute("""
            INSERT INTO market_rates (currency_pair, bid, ask, timestamp, source, tab)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (pair, bid, ask, timestamp, source, tab))
    print("Market Rates seeded.")

def seed_gl_entries(cur, count=30):
    print(f"Seeding {count} GL Entries...")
    currencies = ['XOF', 'EUR', 'USD']
    journal_codes = ['BAN', 'OD', 'ACH']
    
    for _ in range(count):
        account_number = fake.iban()
        currency = random.choice(currencies)
        amount = random.uniform(-5000000, 5000000)
        entry_date = fake.date_between(start_date='-60d', end_date='today')
        reference = fake.bothify(text='GL-####-????')
        narrative = fake.sentence(nb_words=4)
        journal_code = random.choice(journal_codes)
        lettering_code = fake.bothify(text='LET-###') if random.random() > 0.5 else None
        status = 'UNMATCHED'

        cur.execute("""
            INSERT INTO gl_entries (account_number, currency, amount, entry_date, reference, narrative, journal_code, lettering_code, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (account_number, currency, amount, entry_date, reference, narrative, journal_code, lettering_code, status))
    print("GL Entries seeded.")

def seed_bank_transactions(cur, count=30):
    print(f"Seeding {count} Bank Transactions...")
    currencies = ['XOF', 'EUR', 'USD']
    
    # Need existing nostro accounts to link?
    cur.execute("SELECT id FROM nostro_accounts")
    nostro_ids = [row[0] for row in cur.fetchall()]
    
    if not nostro_ids:
        print("No Nostro Accounts found. Skipping Bank Transactions.")
        return

    for _ in range(count):
        nostro_id = random.choice(nostro_ids)
        transaction_date = fake.date_between(start_date='-60d', end_date='today')
        value_date = transaction_date
        amount = random.uniform(-5000000, 5000000)
        currency = random.choice(currencies)
        reference = fake.bothify(text='BK-####-????')
        description = fake.sentence(nb_words=5)
        status = 'UNMATCHED'

        cur.execute("""
            INSERT INTO bank_transactions (nostro_account_id, transaction_date, value_date, amount, currency, reference, description, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (nostro_id, transaction_date, value_date, amount, currency, reference, description, status))
    print("Bank Transactions seeded.")

def seed_macro_accounts(cur):
    print("Seeding Macro Accounts...")
    accounts = [
        # ACTIFS BANCAIRES
        ('ACTIF BANCAIRE', 'Caisse', 25000000.00, 'up', 1.5),
        ('ACTIF BANCAIRE', 'Dépôts à la Banque Centrale', 450000000.00, 'stable', 0.2),
        ('ACTIF BANCAIRE', 'Banques et Autres Correspondants bancaires', 120000000.00, 'down', -2.1),

        # CLIENTELE ACTIF
        ('CLIENTELE ACTIF', 'Crédits Promoteurs y compris Locatif', 350000000.00, 'up', 4.5),
        ('CLIENTELE ACTIF', 'PPO', 85000000.00, 'stable', 0.0),
        ('CLIENTELE ACTIF', 'Crédits IMMO aux Particuliers', 650000000.00, 'up', 2.3),
        ('CLIENTELE ACTIF', 'Découverts aux Particuliers', 45000000.00, 'down', -1.2),
        ('CLIENTELE ACTIF', 'Créances impayées', 15000000.00, 'stable', 0.5),
        ('CLIENTELE ACTIF', 'Créances douteuses nettes', 5000000.00, 'down', -0.5),

        # AUTRES ACTIFS
        ('AUTRES ACTIFS', 'Autres Actifs (compte d''ordre, débiteurs divers, etc.)', 22000000.00, 'stable', 0.1),
        ('AUTRES ACTIFS', 'Titres de Placement', 180000000.00, 'up', 5.2),
        ('AUTRES ACTIFS', 'Titres de Participation', 240000000.00, 'stable', 0.0),
        ('AUTRES ACTIFS', 'Immobilisations nettes', 95000000.00, 'down', -0.8),

        # PASSIFS BANCAIRES
        ('PASSIFS BANCAIRES', 'Banques et Autres Correspondants bancaires', 55000000.00, 'stable', 0.4),
        ('PASSIFS BANCAIRES', 'Dépôts à terme Ets Crédits', 150000000.00, 'up', 1.2),

        # CLIENTELE PASSIF
        ('CLIENTELE PASSIF', 'Comptes créditeurs clientèle (CC, autres dépôts, etc.)', 1250000000.00, 'up', 3.4),
        ('CLIENTELE PASSIF', 'Comptes CEL', 45000000.00, 'stable', 0.2),
        ('CLIENTELE PASSIF', 'Dépôts à terme clientèle', 320000000.00, 'up', 1.8),
        ('CLIENTELE PASSIF', 'Autres comptes épargne (PEL+LEL)', 180000000.00, 'down', -0.4)
    ]
    
    # First ensure we don't duplicate on multiple runs if we aren't using --clean
    cur.execute("TRUNCATE TABLE macro_accounts RESTART IDENTITY;")
    
    for account in accounts:
        cur.execute("""
            INSERT INTO macro_accounts (classification, category, balance, trend, change_pct)
            VALUES (%s, %s, %s, %s, %s)
        """, account)
    print("Macro Accounts seeded.")

def seed_reserve_requirements(cur):
    print("Seeding Reserve Requirements...")
    cur.execute("TRUNCATE TABLE reserve_requirements RESTART IDENTITY;")
    
    requirements = [
        (456200000.00, 'XOF', True, datetime.now()),
        (420000000.00, 'XOF', True, datetime.now() - timedelta(days=30)),
        (380000000.00, 'XOF', False, datetime.now() - timedelta(days=60)),
    ]
    
    for req in requirements:
        cur.execute("""
            INSERT INTO reserve_requirements (amount, currency, compliance, last_updated)
            VALUES (%s, %s, %s, %s)
        """, req)
    print("Reserve Requirements seeded.")

def seed_recent_activities(cur, count=20):
    print(f"Seeding {count} Recent Activities...")
    types = ['investment', 'transfer', 'approval']
    statuses = ['Complété', 'En attente', 'Approuvé', 'Rejeté']
    risks = ['Faible', 'Moyen', 'Élevé']
    
    for _ in range(count):
        activity_type = random.choice(types)
        
        if activity_type == 'investment':
            title = fake.catch_phrase()
            description = f"Acquisition: {fake.company()}"
            amount_str = f"${random.randint(10, 500)},000,000"
        elif activity_type == 'transfer':
            title = "Transfert Interbancaire"
            description = f"Vers {fake.company()}"
            amount_str = f"€{random.randint(1, 50)},000,000"
        else:
            title = "Ajustement de Limite"
            description = "Approbation de nouvelle limite de risque"
            amount_str = f"¥{random.randint(100, 900)},000,000"
            
        initiated_by = fake.name()
        approved_by = fake.name() if random.random() > 0.3 else "-"
        activity_time = fake.date_time_between(start_date='-7d', end_date='now')
        status = random.choice(statuses)
        risk_level = random.choice(risks)
        
        cur.execute("""
            INSERT INTO recent_activities (title, description, amount_str, initiated_by, approved_by, activity_time, status, risk_level, activity_type)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (title, description, amount_str, initiated_by, approved_by, activity_time, status, risk_level, activity_type))
    print("Recent Activities seeded.")

def seed_risk_score_history(cur, months=6):
    print(f"Seeding {months} months of Risk Score History...")
    cur.execute("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'risk_score_history');")
    if not cur.fetchone()[0]:
        print("Creating 'risk_score_history' table...")
        cur.execute("""
            CREATE TABLE risk_score_history (
                id BIGSERIAL PRIMARY KEY,
                record_date DATE NOT NULL,
                overall_score INTEGER NOT NULL,
                credit_score INTEGER,
                market_score INTEGER,
                liquidity_score INTEGER,
                operational_score INTEGER
            );
        """)
    
    cur.execute("TRUNCATE TABLE risk_score_history RESTART IDENTITY;")
    
    for i in range(months, 0, -1):
        record_date = (datetime.now() - timedelta(days=30 * i)).date().replace(day=1)
        credit_score = random.randint(20, 80)
        market_score = random.randint(20, 80)
        liquidity_score = random.randint(20, 80)
        operational_score = random.randint(20, 80)
        overall_score = int((credit_score + market_score + liquidity_score + operational_score) / 4)

        cur.execute("""
            INSERT INTO risk_score_history (record_date, overall_score, credit_score, market_score, liquidity_score, operational_score)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (record_date, overall_score, credit_score, market_score, liquidity_score, operational_score))
    print("Risk Score History seeded.")

def main():
    parser = argparse.ArgumentParser(description='Seed the Treasury Database')
    parser.add_argument('--host', default='localhost', help='Database host')
    parser.add_argument('--port', default='5469', help='Database port')
    parser.add_argument('--db', default='sib_treasury_db', help='Database name')
    parser.add_argument('--user', default='treasurer', help='Database user')
    parser.add_argument('--password', default='treasurer', help='Database password')
    parser.add_argument('--clean', action='store_true', help='Clean existing data before seeding')
    
    args = parser.parse_args()

    conn = connect_db(args)
    if conn:
        cur = conn.cursor()
        try:
            ensure_schema(cur)
            
            if args.clean:
                clear_tables(cur)
            
            seed_nostro_accounts(cur)
            seed_payments(cur)
            seed_alerts(cur)
            seed_forecasts(cur)
            seed_positions(cur)
            seed_risk_limits(cur)
            seed_deals(cur)
            
            # New seeding functions
            seed_market_rates(cur)
            seed_gl_entries(cur)
            seed_bank_transactions(cur)
            seed_macro_accounts(cur)
            seed_reserve_requirements(cur)
            seed_risk_score_history(cur)
            seed_recent_activities(cur)
            
            conn.commit()
            print("Database seeding completed successfully!")
        except Exception as e:
            print(f"Error during seeding: {e}")
            conn.rollback()
        finally:
            cur.close()
            conn.close()

if __name__ == '__main__':
    main()
