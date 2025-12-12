#!/bin/bash
# Test script to verify enforcement system
# This is a test file with intentional issues

# BAD: Relative path
./scripts/deploy.sh

# BAD: Nonexistent file
/tmp/nonexistent.sh

# GOOD: Absolute path with error handling
/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/scripts/deploy.sh || echo "ERROR: Deploy failed"
