#!/bin/bash
# Backup Railway PostgreSQL Database

echo "🔄 Backing up Railway PostgreSQL database..."

# Get DATABASE_URL from Railway
DB_URL=$(railway variables | grep DATABASE_URL | awk -F '│' '{print $3}' | tr -d ' ' | head -1)

if [ -z "$DB_URL" ]; then
    echo "❌ Could not retrieve DATABASE_URL from Railway"
    echo "Please run: railway variables | grep DATABASE_URL"
    exit 1
fi

# Create backup directory
mkdir -p backups

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backups/railway_db_backup_${TIMESTAMP}.sql"

echo "📦 Creating backup: $BACKUP_FILE"

# Dump database
pg_dump "$DB_URL" > "$BACKUP_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Backup successful: $BACKUP_FILE"
    ls -lh "$BACKUP_FILE"
else
    echo "❌ Backup failed. Check if pg_dump is installed:"
    echo "   brew install postgresql (macOS)"
    echo "   or: apt-get install postgresql-client (Linux)"
    exit 1
fi

echo ""
echo "✅ Database backup complete"
echo "📁 File: $BACKUP_FILE"
echo ""
echo "Next: Create Render account at https://render.com"
