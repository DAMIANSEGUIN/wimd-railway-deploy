#!/bin/bash
# scripts/diagnose_deployment.sh - Quick deployment failure diagnosis

set -euo pipefail

echo "🔍 RENDER DEPLOYMENT FAILURE DIAGNOSIS"
echo "========================================"
echo ""

# 1. Check backend health
echo "📋 Step 1: Checking backend health endpoint..."
HEALTH_URL="https://mosaic-backend-tpog.onrender.com/health"
if curl -s --max-time 10 "$HEALTH_URL" > /dev/null 2>&1; then
    HEALTH_RESPONSE=$(curl -s "$HEALTH_URL")
    echo "✅ Backend is responding"
    echo "   Response: $HEALTH_RESPONSE"
else
    echo "❌ Backend is NOT responding (this is the problem)"
fi
echo ""

# 2. Check recent commits
echo "📋 Step 2: Recent commits that triggered deployment..."
git log --oneline -3
echo ""

# 3. Check render.yaml syntax
echo "📋 Step 3: Validating render.yaml..."
if python3 -c "import yaml; yaml.safe_load(open('render.yaml'))" 2>/dev/null; then
    echo "✅ render.yaml is valid YAML"
else
    echo "❌ render.yaml has YAML syntax errors"
fi
echo ""

# 4. Check backend requirements
echo "📋 Step 4: Checking backend/requirements.txt..."
if [ -f "backend/requirements.txt" ]; then
    echo "✅ backend/requirements.txt exists"
    echo "   Total dependencies: $(wc -l < backend/requirements.txt)"
else
    echo "❌ backend/requirements.txt missing"
fi
echo ""

# 5. Check for Python syntax errors
echo "📋 Step 5: Checking for Python syntax errors in backend/api/..."
if python3 -m py_compile backend/api/*.py 2>/dev/null; then
    echo "✅ No Python syntax errors found"
else
    echo "❌ Python syntax errors detected:"
    python3 -m py_compile backend/api/*.py 2>&1 | head -10
fi
echo ""

# 6. Check GitHub Actions status
echo "📋 Step 6: Latest GitHub Actions workflow status..."
echo "   View at: https://github.com/DAMIANSEGUIN/wimd-railway-deploy/actions"
echo ""

# 7. Check Render dashboard
echo "📋 Step 7: Render deployment logs location..."
echo "   Dashboard: https://dashboard.render.com"
echo "   Service: mosaic-backend (srv-d5e4j0qli9vc73esori0)"
echo "   Go to: Dashboard → mosaic-backend → Events → Click latest deploy → View Logs"
echo ""

# 8. Common failure patterns
echo "📋 Step 8: Common Render deployment failures..."
echo ""
echo "   🔴 Build failure:"
echo "      - Missing dependency in requirements.txt"
echo "      - Python syntax error"
echo "      - Import error"
echo "      → Check build logs in Render dashboard"
echo ""
echo "   🔴 Runtime failure:"
echo "      - Environment variable missing (OPENAI_API_KEY, CLAUDE_API_KEY, DATABASE_URL)"
echo "      - Port binding issue"
echo "      - Database connection failure"
echo "      → Check deploy logs in Render dashboard"
echo ""
echo "   🔴 Health check failure:"
echo "      - /health endpoint not responding within timeout"
echo "      - Service crashed on startup"
echo "      → Check service logs in Render dashboard"
echo ""

# 9. Quick fix commands
echo "📋 Step 9: Quick rollback if needed..."
echo ""
echo "   To rollback to last working commit (f52b98b):"
echo "   $ git revert HEAD --no-edit"
echo "   $ git push origin main"
echo ""

# 10. Next steps
echo "========================================"
echo "🎯 NEXT STEPS:"
echo ""
echo "1. Go to Render dashboard and check deploy logs:"
echo "   https://dashboard.render.com/web/srv-d5e4j0qli9vc73esori0/deploys"
echo ""
echo "2. Look for the FIRST error message in build/deploy logs"
echo ""
echo "3. Common error searches:"
echo "   - 'ERROR'"
echo "   - 'FAILED'"
echo "   - 'ModuleNotFoundError'"
echo "   - 'ImportError'"
echo "   - 'SyntaxError'"
echo ""
echo "4. Share the error message for specific fix"
echo ""
