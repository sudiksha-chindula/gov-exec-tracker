# app/db.py
import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv, find_dotenv

# Defensive: also load here in case someone imports db before app factory runs
load_dotenv(find_dotenv())

def get_db():
    """Return a new MySQL connection using .env values."""
    try:
        conn = mysql.connector.connect(
            host=os.getenv("DB_HOST", "127.0.0.1"),
            port=int(os.getenv("DB_PORT", "3306")),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            database=os.getenv("DB_NAME"),
            autocommit=True,
        )
        return conn
    except Error as e:
        # Let Flask show a 500 with the real reason in console
        raise

def query(sql, params=None, fetch=False, many=False):
    """Run a read/write query; return rows for fetch=True."""
    conn = get_db()
    try:
        cur = conn.cursor(dictionary=True)
        if many and isinstance(params, list):
            cur.executemany(sql, params)
        else:
            cur.execute(sql, params or ())
        if fetch:
            rows = cur.fetchall()
            cur.close()
            conn.close()
            return rows
        conn.commit()
        cur.close()
        conn.close()
    except:
        try:
            conn.rollback()
        except:
            pass
        raise
