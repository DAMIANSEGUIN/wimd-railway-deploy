import os
import sys

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath("."))

# Load environment variables for local testing
from dotenv import load_dotenv

from api.settings import get_settings
from api.storage import init_db

load_dotenv()

# Ensure settings are loaded for DATABASE_URL
settings = get_settings()

print("Attempting to initialize database...")
try:
    init_db()
    print("Database initialized successfully.")
except Exception as e:
    print(f"Error initializing database: {e}")
    sys.exit(1)
