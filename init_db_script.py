import sys
import os

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath('.'))

from api.storage import init_db
from api.settings import get_settings

# Load environment variables for local testing
from dotenv import load_dotenv
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
