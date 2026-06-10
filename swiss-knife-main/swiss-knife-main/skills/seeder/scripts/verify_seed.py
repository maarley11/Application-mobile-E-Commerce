import argparse
import psycopg2

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

def verify_data(cur):
    tables = ['nostro_accounts', 'payments', 'treasury_alerts']
    print("Verification Results:")
    print("-" * 20)
    for table in tables:
        cur.execute(f"SELECT COUNT(*) FROM {table}")
        count = cur.fetchone()[0]
        print(f"{table}: {count} records")

def main():
    parser = argparse.ArgumentParser(description='Verify Treasury Database Data')
    parser.add_argument('--host', default='localhost', help='Database host')
    parser.add_argument('--port', default='5469', help='Database port') # Default to dev port
    parser.add_argument('--db', default='sib_treasury_db', help='Database name')
    parser.add_argument('--user', default='treasurer', help='Database user')
    parser.add_argument('--password', default='treasurer', help='Database password')
    
    args = parser.parse_args()

    conn = connect_db(args)
    if conn:
        cur = conn.cursor()
        try:
            verify_data(cur)
        finally:
            cur.close()
            conn.close()

if __name__ == '__main__':
    main()
