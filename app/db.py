import os
from dotenv import load_dotenv
import mysql.connector

# Force load .env even if Flask doesn't
env_path = os.path.join(os.path.dirname(__file__), ".env")
load_dotenv(env_path)

def get_db():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )
