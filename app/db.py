# db.py
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os

load_dotenv()  # loads .env in the project root

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "dbmsmini"),
}

def get_connection():
    """Create and return a new MySQL connection."""
    return mysql.connector.connect(**DB_CONFIG)

def query(sql, params=None, fetchone=False, commit=False):
    """
    Execute a parameterized SQL query safely.
    - params: tuple/list of parameters for placeholders.
    - fetchone: return one row if True; else return all rows.
    - commit: commit after executing if True (for INSERT/UPDATE/DELETE).
    """
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(sql, params or [])
        result = None
        if commit:
            conn.commit()
        else:
            # Only SELECT-like statements will produce results
            result = cursor.fetchone() if fetchone else cursor.fetchall()
        return result
    except Error as e:
        # For learning, raise so you see the error in the console
        raise
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
