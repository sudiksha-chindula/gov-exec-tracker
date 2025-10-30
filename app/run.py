

from dotenv import load_dotenv
import os
load_dotenv()
print("Host:", os.getenv("DB_HOST"))
print("User:", os.getenv("DB_USER"))
print("Password:", os.getenv("DB_PASSWORD"))
print("DB:", os.getenv("DB_NAME"))
