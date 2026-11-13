#!/usr/bin/env python3
"""
Database migration script from SQLite to PostgreSQL.
Usage: python migrate_to_postgres.py <sqlite_db_path> <postgresql_url>

Example:
    python migrate_to_postgres.py formula_requests.db postgresql://user:pass@host:port/dbname
"""

import sys
import sqlite3
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker


def migrate_database(sqlite_path: str, postgres_url: str) -> None:
    """Migrate data from SQLite to PostgreSQL."""
    
    print(f"Connecting to SQLite database: {sqlite_path}")
    sqlite_conn = sqlite3.connect(sqlite_path)
    sqlite_conn.row_factory = sqlite3.Row
    sqlite_cursor = sqlite_conn.cursor()
    
    print(f"Connecting to PostgreSQL database...")
    postgres_engine = create_engine(postgres_url)
    
    # Get list of tables from SQLite
    sqlite_cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table' "
        "AND name NOT LIKE 'sqlite_%'"
    )
    tables = [row[0] for row in sqlite_cursor.fetchall()]
    
    print(f"Found {len(tables)} tables to migrate: {', '.join(tables)}")
    
    with postgres_engine.begin() as pg_conn:
        for table_name in tables:
            print(f"\nMigrating table: {table_name}")
            
            # Get all rows from SQLite
            sqlite_cursor.execute(f"SELECT * FROM {table_name}")
            rows = sqlite_cursor.fetchall()
            
            if not rows:
                print(f"  No data in {table_name}, skipping...")
                continue
            
            # Get column names
            column_names = [description[0] for description in sqlite_cursor.description]
            
            print(f"  Found {len(rows)} rows")
            
            # Prepare insert statement
            columns_str = ", ".join(column_names)
            placeholders = ", ".join([f":{col}" for col in column_names])
            insert_sql = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"
            
            # Insert rows
            for row in rows:
                row_dict = dict(zip(column_names, row))
                try:
                    pg_conn.execute(text(insert_sql), row_dict)
                except Exception as e:
                    print(f"  Error inserting row: {e}")
                    print(f"  Row data: {row_dict}")
                    raise
            
            print(f"  ✓ Migrated {len(rows)} rows")
    
    sqlite_conn.close()
    print("\n✅ Migration completed successfully!")
    print("\nNext steps:")
    print("1. Verify data in PostgreSQL")
    print("2. Update DATABASE_URL in your Vercel environment variables")
    print("3. Test the application with the new database")
    print("4. Back up your SQLite database before removing it")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python migrate_to_postgres.py <sqlite_db_path> <postgresql_url>")
        print("\nExample:")
        print("  python migrate_to_postgres.py formula_requests.db postgresql://user:pass@host:port/dbname")
        sys.exit(1)
    
    sqlite_path = sys.argv[1]
    postgres_url = sys.argv[2]
    
    try:
        migrate_database(sqlite_path, postgres_url)
    except Exception as e:
        print(f"\n❌ Migration failed: {e}")
        sys.exit(1)
