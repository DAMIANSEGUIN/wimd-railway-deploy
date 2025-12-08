#!/bin/bash
# Auto-update "Last Updated" metadata field
# Usage: ./scripts/update_metadata.sh <file_path> <agent_name>

set -e

FILE=$1
AGENT=${2:-"Claude Code"}
DATE=$(date +%Y-%m-%d)

if [ -z "$FILE" ]; then
    echo "Usage: ./scripts/update_metadata.sh <file_path> [agent_name]"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE"
    exit 1
fi

# Check if file has metadata header
if ! grep -q "**Document Metadata:**" "$FILE"; then
    echo "Error: $FILE missing metadata header"
    exit 1
fi

# Update Last Updated field
sed -i '' "s/- Last Updated: .*$/- Last Updated: $DATE by $AGENT/" "$FILE"

echo "✅ Updated metadata in $FILE"
echo "   Last Updated: $DATE by $AGENT"
