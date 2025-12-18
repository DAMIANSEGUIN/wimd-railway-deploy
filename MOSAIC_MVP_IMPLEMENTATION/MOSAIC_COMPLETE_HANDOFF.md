# MOSAIC PROJECT - COMPLETE SELF-CONTAINED HANDOFF

**All Information Embedded - No External Files Required**

**Date**: 2025-12-01
**For**: Claude Opus (Desktop) - Senior Implementation Engineer
**From**: Claude Code (Sonnet 4.5) - System Diagnostics & Preparation
**Project**: Mosaic Career Transition Platform
**Status**: Phase 4 DEPLOYED - Testing & Completion Required

---

## 🚨 CRITICAL: START HERE

This document is **100% self-contained**. All critical information from external files is embedded below. You do NOT need access to the repository to begin work.

**Your Mission**: Complete Mosaic platform overhaul, test Phase 4 features, implement missing components.

**Constraints**:

- GitHub access may be limited in Claude Desktop
- Work from local directory (provided below)
- Production system is LIVE - changes must be safe
- Follow all safety protocols (embedded in this document)

---

## 📍 PROJECT LOCATION

**Primary Working Directory**:

```
/Users/damianseguin/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My Drive/WIMD-Railway-Deploy-Project
```

**How to Access** (if Google Drive path is difficult):

```bash
# Alternative: Ask user to create a symlink or copy to easier path
# For now, navigate using full path or tab completion
cd ~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My\ Drive/WIMD-Railway-Deploy-Project
```

**GitHub Repository** (reference only):

```
https://github.com/DAMIANSEGUIN/wimd-railway-deploy
```

---

## 🎯 PROJECT OVERVIEW

**What Is Mosaic?**

- **Mosaic**: Career transition platform helping users find jobs using AI/LLM
- **Foundation**: Safety & evidence layer (planned integration)
- **Stack**: FastAPI backend (Railway) + Vanilla JS frontend (Netlify) + PostgreSQL

**Production URLs**:

- Main site: <https://whatismydelta.com>
- Backend API: <https://what-is-my-delta-site-production.up.railway.app>
- Netlify: Site ID `resonant-crostata-90b706`

**Architecture**:

```
User Browser
    ↓
Netlify (Frontend - Vanilla JavaScript ES6+)
    ↓ (Proxy)
Railway (Backend - FastAPI + Python)
    ↓
PostgreSQL Database (Railway managed)
    ↓
OpenAI API (GPT-4, embeddings) + Anthropic API (Claude)
```

---

## 📊 CURRENT STATE (Phase 4 COMPLETE - Oct 2025)

### ✅ **What's Working (DEPLOYED & OPERATIONAL)**

**Frontend**:

- ✅ UI fully deployed and functional
- ✅ All navigation buttons working (explore, find, apply, chat, guide, upload)
- ✅ 5-minute trial mode for unauthenticated users
- ✅ Trial timer persists across page refreshes (localStorage)
- ✅ Vanilla JavaScript ES6+ with IIFE pattern
- ✅ Event listeners use null checks to prevent crashes

**Backend API**:

- ✅ FastAPI on Railway - operational
- ✅ Authentication: login, register, password reset flows
- ✅ Chat/Coach interface operational
- ✅ File upload functional (resume/document handling)
- ✅ PostgreSQL database connected (NOT SQLite fallback)
- ✅ Context manager pattern: `with get_conn() as conn:`

**Phase 1-3** (Completed):

- ✅ Migration framework from SQLite → PostgreSQL
- ✅ CSV→AI fallback system
- ✅ Feature flags implemented
- ✅ Experiment engine backend (flag disabled)
- ✅ Self-efficacy metrics + UI toggle
- ✅ Coach escalation system
- ✅ Focus Stack UI

**Phase 4** (Deployed Oct 2025):

- ✅ RAG baseline (OpenAI embeddings - NO fallback)
- ✅ 12 job sources implemented:
  - **6 Direct API sources** (production-ready):
    - RemoteOK, WeWorkRemotely, HackerNews, Greenhouse, Indeed, Reddit
  - **6 Web Scraping sources** (deployed, UNTESTED):
    - LinkedIn, Glassdoor, Dice, Monster, ZipRecruiter, CareerBuilder
- ✅ Competitive intelligence (company analysis, positioning, resume targeting)
- ✅ Cost controls (usage tracking, daily/monthly limits)
- ✅ OSINT integration
- ✅ Domain-adjacent search

**Monitoring & Health**:

- ✅ Railway health checks configured (`railway.toml`)
- ✅ Multi-layer monitoring (`/health`, `/health/comprehensive`, `/health/recover`)
- ✅ Automatic recovery on failure
- ✅ Health logging to `prompt_health_log` table

### ❌ **What's Broken / NEEDS WORK**

**CRITICAL** (Must fix immediately):

1. ⚠️ **Job Sources UNTESTED**: All 12 sources deployed but NOT tested in production
   - Web scraping sources may need CSS selector adjustments
   - Need to verify real job data returns from each source
   - Could be failing silently right now

2. ⚠️ **Email Service**: Password reset sends placeholder message only
   - Needs SendGrid OR AWS SES integration
   - Code exists but no SMTP service configured

3. ⚠️ **CSV→AI Fallback**: Recently enabled but may have bugs
   - Cache was cleared, flag enabled
   - Needs validation testing

**HIGH PRIORITY** (Should fix soon):
4. ⚠️ **No Automated Testing**: No test pipeline, golden dataset, or regression tests
5. ⚠️ **No Staging Environment**: Direct to production deployment (risky)
6. ⚠️ **API Key Rotation**: Keys stored in Railway but never rotated

### 📋 **What Exists in Code But NOT Deployed**

- `EXPERIMENTS_ENABLED`: Feature flag disabled (experiment engine implemented)
- Advanced RAG reranker: CrossEncoder model mocked (not loaded)
- Email templates: Code exists but no service configured

---

## 🔥 CRITICAL CODE PATTERNS (MUST FOLLOW)

### **Pattern 1: Database Context Manager** (SACRED RULE)

**✅ ALWAYS USE THIS**:

```python
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    result = cursor.fetchone()
```

**❌ NEVER DO THIS** (Will cause AttributeError):

```python
conn = get_conn()
cursor = conn.execute(...)  # WRONG - crashes in PostgreSQL
```

**Why**: PostgreSQL connection pool returns a context manager. Direct assignment breaks the pattern.

---

### **Pattern 2: PostgreSQL Syntax** (NOT SQLite)

**✅ CORRECT PostgreSQL**:

```python
# Use %s for parameters (NOT ?)
cursor.execute("INSERT INTO table VALUES (%s, %s)", (val1, val2))

# Use SERIAL for auto-increment (NOT AUTOINCREMENT)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    ...
)

# Always get cursor first
cursor = conn.cursor()
cursor.execute(...)
result = cursor.fetchone()
```

**❌ WRONG SQLite syntax**:

```python
# Don't use ?
cursor.execute("SELECT * FROM users WHERE email = ?", (email,))

# Don't use AUTOINCREMENT
CREATE TABLE users (id INTEGER AUTOINCREMENT PRIMARY KEY, ...)
```

---

### **Pattern 3: Error Handling** (NO SILENT FAILURES)

**✅ CORRECT**:

```python
import logging
logger = logging.getLogger(__name__)

try:
    result = risky_operation()
except SpecificException as e:
    logger.error(f"Operation failed: {e}")
    # Explicit fallback or re-raise
    raise
```

**❌ WRONG**:

```python
try:
    risky_operation()
except:
    pass  # Silent failure - NEVER DO THIS
```

---

### **Pattern 4: Idempotent Operations**

**✅ CORRECT**:

```python
# Use ON CONFLICT for idempotency
cursor.execute("""
    INSERT INTO users (id, email, password_hash)
    VALUES (%s, %s, %s)
    ON CONFLICT (email) DO NOTHING
    RETURNING id
""", (user_id, email, password_hash))
```

**❌ WRONG**:

```python
# Will fail on duplicate
cursor.execute("INSERT INTO users VALUES (%s, %s)", (email, password))
```

---

## 🔧 ENVIRONMENT CONFIGURATION

### **Required Environment Variables (Railway)**

```bash
# API Keys
OPENAI_API_KEY=sk-xxx
CLAUDE_API_KEY=sk-ant-xxx  # For Anthropic

# URLs
PUBLIC_SITE_ORIGIN=https://whatismydelta.com
PUBLIC_API_BASE=https://what-is-my-delta-site-production.up.railway.app

# Database (MUST contain railway.internal)
DATABASE_URL=postgresql://user:pass@host.railway.internal:5432/railway

# Optional
SENTRY_DSN=  # Error tracking
APP_SCHEMA_VERSION=v1
```

**CRITICAL**: `DATABASE_URL` must contain `railway.internal` (NOT `railway.app`) or database connection will fail.

---

### **Feature Flags (Current State)**

```python
# In Railway environment or api/config.py
RAG_BASELINE = True                     # ✅ ENABLED
JOB_SOURCES_STUBBED_ENABLED = True      # ✅ ENABLED
AI_FALLBACK_ENABLED = True              # ✅ ENABLED
EXPERIMENTS_ENABLED = False             # ❌ DISABLED
```

---

### **Dependencies (requirements.txt)**

```
fastapi
uvicorn
gunicorn
httpx
pydantic
pydantic-settings
python-multipart   # CRITICAL for file uploads
psycopg2-binary    # PostgreSQL driver
requests           # For HTTP requests
beautifulsoup4     # For web scraping
```

**Note**: `python-multipart` is MANDATORY for file upload endpoints. Without it, FastAPI crashes on startup with cryptic "Hello World" fallback.

---

## 🚀 LOCAL DEVELOPMENT SETUP

### **Test Before Deploying** (MANDATORY)

```bash
# 1. Navigate to project
cd ~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My\ Drive/WIMD-Railway-Deploy-Project

# 2. Set environment variables
export OPENAI_API_KEY="your_key_here"
export CLAUDE_API_KEY="your_key_here"
export PUBLIC_SITE_ORIGIN="https://whatismydelta.com"
export APP_SCHEMA_VERSION="v1"

# 3. Install dependencies
pip3 install --user -r requirements.txt

# 4. Start local server
python3 -m uvicorn api.index:app --host 0.0.0.0 --port 8000

# 5. Test endpoints in another terminal
curl http://localhost:8000/health
curl http://localhost:8000/config
curl http://localhost:8000/prompts/active
```

**If local test fails**: Fix the issue BEFORE deploying. Never deploy untested code.

---

## 📋 API ENDPOINTS (Complete List)

### **Health & Config**

- `GET /health` - Basic health check
- `GET /health/comprehensive` - Detailed health with metrics
- `GET /health/recover` - Manual recovery endpoint
- `GET /health/prompts` - Prompt system health
- `GET /health/rag` - RAG engine health
- `GET /health/experiments` - Experiment engine health
- `GET /config` - Returns `{apiBase, schemaVersion}`

### **Prompts & WIMD**

- `GET /prompts/active` - Active prompt (may be null)
- `POST /wimd/ask` - Chat/coach interface
- `POST /wimd/upload` - File upload
- `/wimd/*` - Other WIMD endpoints

### **Jobs (Phase 4)**

- `POST /jobs/search` - Job search (traditional)
- `POST /jobs/search/rag` - Job search (RAG-powered)
- `GET /jobs/{job_id}` - Get specific job

### **Resume**

- `POST /resume/rewrite` - Rewrite resume
- `POST /resume/customize` - Customize for job
- `POST /resume/feedback` - Get feedback
- `GET /resume/versions` - List versions

### **Authentication**

- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /auth/me` - Current user
- `POST /auth/reset-password` - Password reset (placeholder email)

### **RAG Engine**

- `POST /rag/embed` - Generate embedding
- `POST /rag/batch-embed` - Batch embeddings
- `POST /rag/retrieve` - Retrieve similar docs
- `POST /rag/query` - RAG query
- `POST /rag/domain-adjacent` - Domain-adjacent search

### **Intelligence & OSINT**

- `GET /intelligence/company/{company_name}` - Company analysis
- `POST /intelligence/positioning` - Positioning advice
- `POST /intelligence/resume-targeting` - Resume targeting
- `GET /intelligence/ai-prompts` - AI prompt suggestions
- `POST /osint/analyze-company` - OSINT company analysis
- `GET /osint/health` - OSINT service health

### **Sources & Cost**

- `POST /sources/discover` - Dynamic source discovery
- `GET /sources/analytics` - Source analytics
- `GET /cost/analytics` - Cost analytics
- `GET /cost/limits` - Cost limits status

### **Domain Adjacent**

- `POST /domain-adjacent/discover` - Discover adjacent roles
- `GET /domain-adjacent/health` - Service health

---

## 🧪 TESTING & DEPLOYMENT PROTOCOL

### **BEFORE EVERY CODE CHANGE** (Pre-Flight Checklist)

```
ARCHITECTURE AWARENESS:
□ Do I understand what layer this touches? (DB / API / LLM / UI)
□ Have I checked for similar code patterns in the codebase?
□ Do I know what happens if this component fails?

DATABASE CHANGES:
□ Am I using context manager? (with get_conn() as conn:)
□ Am I using PostgreSQL syntax? (%s not ?, SERIAL not AUTOINCREMENT)
□ Am I getting cursor first? (cursor = conn.cursor())
□ Is this operation idempotent? (ON CONFLICT, check before insert)

ERROR HANDLING:
□ Am I logging errors explicitly? (not swallowing exceptions)
□ Will this fail gracefully? (fallback behavior defined)
□ Can I diagnose this from logs alone? (enough context logged)

DEPLOYMENT SAFETY:
□ Can I rollback this change? (git revert path clear)
□ Is there a feature flag? (can disable without deploy)
□ Have I tested locally? (golden dataset, manual test)
□ Did I check for breaking changes? (API contracts, schema)
```

---

### **BEFORE EVERY DEPLOYMENT** (Mandatory Checks)

```bash
# 1. Test locally first
python3 -m uvicorn api.index:app --host 0.0.0.0 --port 8000
# Open another terminal:
curl http://localhost:8000/health

# 2. Check environment variables
python3 -c "
import os
required = ['DATABASE_URL', 'OPENAI_API_KEY', 'CLAUDE_API_KEY']
missing = [k for k in required if not os.getenv(k)]
if missing:
    print(f'❌ Missing: {missing}')
    exit(1)
else:
    print('✅ All env vars set')
"

# 3. Verify database connection
python3 -c "
from api.storage import get_conn
with get_conn() as conn:
    print('✅ Database connection OK')
"

# 4. Check for context manager violations
grep -rn "conn = get_conn()" api/*.py
# Should return NOTHING

# 5. Check for SQLite syntax
grep -rn "?" api/*.py | grep execute
# Review results - should use %s for parameters
```

---

### **DEPLOYMENT TO RAILWAY**

```bash
# 1. Navigate to project
cd ~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My\ Drive/WIMD-Railway-Deploy-Project

# 2. Make sure you're on correct branch
git status
git log --oneline -3

# 3. Commit changes
git add .
git commit -m "Clear description of what changed and why"

# 4. Push to Railway
git push railway-origin main

# 5. Monitor deployment (Railway dashboard)
# - Watch Build Logs
# - Watch Deploy Logs
# - Look for [STORAGE] messages
# - Look for exceptions

# 6. Verify deployment
curl https://what-is-my-delta-site-production.up.railway.app/health
curl https://what-is-my-delta-site-production.up.railway.app/config

# 7. Check frontend
# Open browser: https://whatismydelta.com
# Verify no console errors, features work
```

---

### **AFTER EVERY DEPLOYMENT** (Post-Deploy Checks)

```
□ Monitor Railway logs for 5 minutes
□ Check /health endpoint - verify ok: true
□ Verify PostgreSQL connected (database.type: "postgresql", NOT "sqlite")
□ Test the specific feature/fix that was deployed
□ No new errors in logs?
□ Frontend still working? (check https://whatismydelta.com)
```

---

### **ROLLBACK PROCEDURE** (If Something Breaks)

```bash
# Immediate rollback to previous commit
git revert HEAD
git push railway-origin main --force

# Wait 2 minutes for deployment
sleep 120

# Verify health
curl https://what-is-my-delta-site-production.up.railway.app/health

# Or rollback to specific commit
git log --oneline -10  # Find good commit hash
git checkout <commit-hash>
git push railway-origin HEAD:main --force
```

---

## 🚨 ERROR CLASSIFICATION & DEBUGGING

### **Error Categories**

| Category | Examples | First Action |
|----------|----------|--------------|
| **INFRA** | Railway deploy failed, PostgreSQL connection failed, env var missing | Check Railway logs, DATABASE_URL format |
| **DATA** | Session orphaned, PS101 state corrupt, schema drift | Check database schema, foreign keys |
| **MODEL** | OpenAI rate limit, API key invalid, context overflow | Check API keys, retry with backoff |
| **PROMPT** | JSON parse error, CSV corrupt | Validate JSON/CSV files |
| **INTEGRATION** | Job source API down, web scraper blocked | Check external API status, CSS selectors |

---

### **Common Errors & Solutions**

| Error | Symptom | Solution |
|-------|---------|----------|
| `CONTEXT_MANAGER_BUG` | AttributeError: 'object has no attribute execute' | Fix to `with get_conn() as conn:` |
| `SQLITE_FALLBACK_ACTIVE` | Data wiped on deploy | Fix DATABASE_URL (ensure railway.internal) |
| `PG_CONNECTION_FAILED` | App crashes on startup | Check PostgreSQL service status in Railway |
| `OPENAI_RATE_LIMIT` | 429 errors | Add retry with exponential backoff |
| `PYTHON_MULTIPART_MISSING` | File upload crashes | Add `python-multipart` to requirements.txt |

---

### **Debugging Workflow**

**Step 1: Classify the Issue**

```
When did it start? (recent deploy? always?)
Who is affected? (all users? one user? specific action?)
What's the error? (exception? wrong behavior? slow?)
Where is it? (frontend? API? database? LLM?)
```

**Step 2: Gather Context**

```
□ Railway deployment logs (last 200 lines)
□ Health endpoint response (/health)
□ Recent git commits (git log -5)
□ Environment variables (railway variables)
□ PostgreSQL service status
□ Error message (full traceback)
```

**Step 3: Form Hypothesis**

```
If INFRA error → Check DATABASE_URL, PostgreSQL status
If DATA error → Check schema, foreign keys
If MODEL error → Check API keys, rate limits
If PROMPT error → Validate JSON/CSV files
If INTEGRATION error → Check external API status
```

**Step 4: Test Hypothesis**

```
□ Can I reproduce locally?
□ Does the log match the hypothesis?
□ Does a simple fix resolve it?
```

**Step 5: Implement Fix**

```
□ Check pre-flight checklist
□ Test locally first
□ Deploy with clear commit message
□ Monitor logs for 5 minutes
□ Verify health endpoint
```

---

## 📞 HEALTH CHECK INTERPRETATION

**Good Health Response**:

```json
{
  "ok": true,
  "timestamp": "2025-12-01T...",
  "database": {
    "connected": true,
    "type": "postgresql",  // ✅ Good (NOT sqlite)
    "fallback_active": false  // ✅ Good
  },
  "ai": {
    "openai_available": true,
    "anthropic_available": true
  },
  "metrics": {
    "error_rate": 0.0,  // ✅ Good (< 0.05)
    "p95_latency_ms": 150  // ✅ Good (< 500)
  }
}
```

**Bad Health Response**:

```json
{
  "ok": false,  // ❌ BAD
  "database": {
    "connected": false,  // ❌ BAD
    "type": "sqlite",  // ❌ BAD (using fallback)
    "fallback_active": true  // ❌ BAD (data will not persist)
  },
  "metrics": {
    "error_rate": 0.15,  // ❌ BAD (> 0.05)
    "p95_latency_ms": 2500  // ❌ BAD (> 500ms)
  }
}
```

**If SQLite fallback active**:

1. DATABASE_URL is wrong or missing
2. PostgreSQL service is down
3. Network routing issue (using railway.app instead of railway.internal)

---

## 🎯 IMMEDIATE PRIORITIES (Your To-Do List)

### **CRITICAL - Do First**

**1. Test All 12 Job Sources** (HIGHEST PRIORITY)

```bash
# Create test script for each job source
# File: tests/test_job_sources.py

import pytest
from api.job_sources import (
    remoteok, weworkremotely, hackernews, greenhouse,
    indeed, reddit, linkedin, glassdoor, dice,
    monster, ziprecruiter, careerbuilder
)

@pytest.mark.parametrize("source", [
    remoteok, weworkremotely, hackernews, greenhouse,
    indeed, reddit, linkedin, glassdoor, dice,
    monster, ziprecruiter, careerbuilder
])
def test_job_source(source):
    """Test each job source returns real data"""
    jobs = source.search("software engineer", location="remote")

    assert len(jobs) > 0, f"{source.__name__} returned no jobs"

    for job in jobs[:5]:  # Check first 5 jobs
        assert "title" in job
        assert "company" in job
        assert "url" in job or "link" in job

        print(f"✅ {source.__name__}: {job['title']} at {job['company']}")
```

**Why Critical**: All 12 sources are deployed but UNTESTED. They could be failing silently right now. Web scraping sources especially likely to need CSS selector adjustments.

---

**2. Integrate Email Service** (HIGH PRIORITY)

```bash
# Options:
# A. SendGrid (easier)
# B. AWS SES (more control)

# Add to requirements.txt:
sendgrid  # if using SendGrid

# Add to Railway env vars:
SENDGRID_API_KEY=xxx
FROM_EMAIL=noreply@whatismydelta.com

# Update api/auth.py password reset function
# Replace placeholder with actual email sending
```

---

**3. Verify CSV→AI Fallback** (HIGH PRIORITY)

```bash
# Test prompt selector with various inputs
# Confirm cache cleared and flag enabled
# File: tests/test_fallback.py

def test_csv_fallback():
    """Test CSV→AI fallback system"""
    from api.prompt_selector import select_prompt

    # Test with known prompt
    result = select_prompt("career advice")
    assert result is not None

    # Test with unknown prompt (should fallback to AI)
    result = select_prompt("something very obscure that won't be in CSV")
    assert result is not None  # Should get AI-generated fallback
```

---

### **HIGH PRIORITY - Do Soon**

**4. Implement Automated Testing**

- Golden dataset tests (see embedded code below)
- Persona cloning framework
- Regression tests for prompts

**5. Set Up Staging Environment**

- Duplicate Railway project for testing
- Configure separate DATABASE_URL
- Test deployments before production

**6. Monitor Cost Controls**

- Verify usage tracking working
- Check daily/monthly limits
- Set up alerts for quota exceeded

---

### **MEDIUM PRIORITY - Nice to Have**

7. API Key Rotation Strategy
8. A/B Testing for RAG vs. Traditional Search
9. CSS Selector Monitoring for Web Scrapers

---

## 📝 EMBEDDED CODE SNIPPETS

### **Golden Dataset Test** (Copy this to tests/test_golden_dataset.py)

```python
import pytest
from api.index import app
from fastapi.testclient import TestClient

GOLDEN_DATASET = [
    {
        "input": "I feel stuck in my career...",
        "expected_contains": ["PS101", "step", "question"],
        "expected_json_valid": True,
    },
    {
        "input": "Help me find a job",
        "expected_contains": ["job", "search"],
        "expected_no_contains": ["error", "failed"],
    },
    {
        "input": "Rewrite my resume for software engineer role",
        "expected_contains": ["resume", "rewrite"],
        "expected_no_contains": ["error", "failed"],
    },
]

@pytest.mark.golden
def test_golden_dataset():
    """Run golden dataset on every deploy"""
    client = TestClient(app)

    for case in GOLDEN_DATASET:
        response = client.post("/wimd/ask", json={"prompt": case["input"]})

        assert response.status_code == 200
        data = response.json()

        if case.get("expected_json_valid"):
            assert isinstance(data, dict)

        for expected in case.get("expected_contains", []):
            assert expected.lower() in str(data).lower(), \
                f"Expected '{expected}' not found in response"

        for not_expected in case.get("expected_no_contains", []):
            assert not_expected.lower() not in str(data).lower(), \
                f"Unexpected '{not_expected}' found in response"

    print("✅ All golden dataset tests passed")
```

---

### **Retry with Exponential Backoff** (For OpenAI rate limits)

```python
# api/retry_utils.py

import time
import random
from functools import wraps

def retry_with_exponential_backoff(
    max_retries=3,
    base_delay=1,
    max_delay=60,
    jitter=True
):
    """Retry decorator with exponential backoff and jitter"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_retries:
                        raise

                    # Only retry on 429 or 5xx errors
                    if "429" in str(e) or "5" in str(getattr(e, 'status_code', '')):
                        delay = min(base_delay * (2 ** attempt), max_delay)
                        if jitter:
                            delay *= (0.5 + random.random())

                        print(f"[RETRY] Attempt {attempt + 1} failed, retrying in {delay:.2f}s")
                        time.sleep(delay)
                    else:
                        raise  # Don't retry non-retriable errors
        return wrapper
    return decorator

# Usage:
@retry_with_exponential_backoff(max_retries=3)
def call_openai_api(prompt: str):
    # OpenAI API call here
    pass
```

---

## 🔍 QUICK REFERENCE

### **File Locations (Key Files)**

```
api/
├── index.py              # Main FastAPI app
├── storage.py            # Database schema & operations
├── prompt_selector.py    # CSV→AI fallback
├── rag_engine.py         # RAG implementation
├── ai_clients.py         # OpenAI/Anthropic clients
├── auth.py               # Authentication
├── job_sources/          # 12 job source integrations
│   ├── remoteok.py
│   ├── linkedin.py
│   └── ...
└── db_utils.py           # Database utilities

prompts/
├── prompts.csv           # Prompt library
└── ps101_steps.json      # 10-step coaching flow

frontend/ or mosaic_ui/
├── index.html            # Main frontend
├── js/                   # JavaScript modules
└── css/                  # Styles

scripts/
├── predeploy_sanity.sh   # Pre-deployment checks
├── verify_deploy.sh      # Post-deployment verification
└── one_shot_new_deploy.sh # Fresh Railway deployment

requirements.txt          # Python dependencies
railway.toml              # Railway config
netlify.toml              # Netlify config (if exists)
```

---

### **Quick Commands**

```bash
# Navigate to project
cd ~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My\ Drive/WIMD-Railway-Deploy-Project

# Check git status
git status
git log --oneline -5

# Test locally
python3 -m uvicorn api.index:app --host 0.0.0.0 --port 8000
curl http://localhost:8000/health

# Deploy to Railway
git add .
git commit -m "Description"
git push railway-origin main

# Check production health
curl https://what-is-my-delta-site-production.up.railway.app/health

# Rollback
git revert HEAD && git push railway-origin main --force
```

---

## 🆘 EMERGENCY PROCEDURES

### **🚨 Production is Down**

```
IMMEDIATE:
1. Check Railway dashboard - is service running?
2. If crashed: Check deploy logs for exception
3. If context manager bug: Rollback immediately
4. If PostgreSQL down: Check DATABASE_URL, PostgreSQL service

ROLLBACK:
git revert HEAD
git push railway-origin main --force
# Wait 2 minutes
curl /health
```

---

### **🔥 Data Loss Detected**

```
ASSESS:
1. Check logs for [STORAGE] messages
2. If "SQLite fallback": All data lost on last deploy
3. If PostgreSQL: Check if table dropped

RECOVER:
- If SQLite fallback: No recovery (ephemeral)
- If PostgreSQL: Check Railway backups
- Last resort: Restore from git history

PREVENT:
- Ensure DATABASE_URL uses railway.internal
- Verify PostgreSQL service active before deploy
```

---

### **⚡ Performance Degradation**

```
DIAGNOSE:
1. Check /health - p95_latency_ms value?
2. Check Railway metrics - CPU/Memory usage?
3. Check logs - slow queries? API timeouts?

IMMEDIATE FIX:
- If OpenAI timeout: Add retry with backoff
- If DB slow: Add indexes, optimize queries
- If memory: Restart service, investigate leak
```

---

## 📚 KNOWLEDGE BASE (Everything You Need)

### **Database Schema (Key Tables)**

```sql
-- Users table
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Sessions table
CREATE TABLE sessions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) REFERENCES users(id),
    user_data JSONB,
    ps101_state JSONB,  -- Problem Solving 101 state
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP
);

-- Uploads table
CREATE TABLE uploads (
    id VARCHAR(36) PRIMARY KEY,
    session_id VARCHAR(36) REFERENCES sessions(id),
    file_path VARCHAR(500),
    file_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Prompts table (synced from CSV)
CREATE TABLE prompts (
    id SERIAL PRIMARY KEY,
    prompt TEXT,
    response TEXT,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- RAG embeddings table
CREATE TABLE rag_embeddings (
    id VARCHAR(36) PRIMARY KEY,
    document_id VARCHAR(36),
    embedding VECTOR(1536),  -- OpenAI embedding dimension
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

### **Feature Flags (How to Use)**

```python
# In api/config.py or api/feature_flags.py

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Feature flags
    RAG_BASELINE: bool = True
    JOB_SOURCES_STUBBED_ENABLED: bool = True
    AI_FALLBACK_ENABLED: bool = True
    EXPERIMENTS_ENABLED: bool = False

    # API keys
    OPENAI_API_KEY: str
    CLAUDE_API_KEY: str

    # URLs
    PUBLIC_SITE_ORIGIN: str
    PUBLIC_API_BASE: str

    # Database
    DATABASE_URL: str

    class Config:
        env_file = ".env"

settings = Settings()

# Usage in code:
if settings.EXPERIMENTS_ENABLED:
    # Run experiment engine
    pass
else:
    # Skip experiments
    pass
```

---

### **Nate's Solution Ladder (Decision Matrix)**

Use this to decide what technology to use:

1. **Data ingestion & cleaning** → Data Ops (pandas, CSV, SQL)
2. **Storage & retrieval** → Data Ops (+RAG if semantic search needed)
3. **Scoring/Ranking** → Classical ML (scikit-learn, not LLM)
4. **Generation (resumes/prompts)** → LLM with Evidence Bridge
5. **Workflow automation** → Thin Agents (simple logic, not agentic frameworks)
6. **UI** → Data Ops (+typed contracts for API)
7. **API** → Data Ops (+typed contracts, Pydantic models)
8. **Observability & Governance** → Data Ops (+eval traces)
9. **Safety & Evidence (Foundation)** → Data Ops + LLM

**Translation**: Use simple data operations first. Only use LLMs for generation. Don't over-engineer.

---

## 🎬 YOUR FIRST ACTIONS (Step-by-Step)

### **Action 1: Verify Current State** (5 minutes)

```bash
# Check production health
curl https://what-is-my-delta-site-production.up.railway.app/health | python3 -m json.tool

# Navigate to project
cd ~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My\ Drive/WIMD-Railway-Deploy-Project

# Check git status
git status
git log --oneline -10

# List key files
ls -la api/
ls -la prompts/
cat requirements.txt
```

---

### **Action 2: Create REPO_AUDIT.md** (15 minutes)

```bash
# Generate comprehensive audit
cat > REPO_AUDIT.md << 'EOF'
# MOSAIC REPOSITORY AUDIT
**Date**: 2025-12-01
**Auditor**: Claude Opus

## File Structure
$(tree -L 3 -I '__pycache__|*.pyc|.git')

## Git Status
$(git status)
$(git log --oneline -10)

## What's Implemented (Working)
- Frontend: All UI operational
- Backend: FastAPI on Railway
- Database: PostgreSQL connected
- Phase 1-3: All features deployed
- Phase 4: 12 job sources deployed

## What's TODO (Needs Work)
1. CRITICAL: Test all 12 job sources
2. HIGH: Integrate email service (SendGrid/AWS SES)
3. HIGH: Verify CSV→AI fallback
4. MEDIUM: Implement automated testing
5. MEDIUM: Set up staging environment

## API Endpoints (All Implemented)
$(curl https://what-is-my-delta-site-production.up.railway.app/health | python3 -m json.tool)

## Current Issues
- Job sources untested in production
- Email service placeholder only
- No automated test pipeline
EOF
```

---

### **Action 3: Test Job Sources** (30-60 minutes)

Create `tests/test_job_sources.py` with code from "IMMEDIATE PRIORITIES" section above, then run:

```bash
# Install pytest if needed
pip3 install pytest

# Run job source tests
pytest tests/test_job_sources.py -v

# Review results - which sources work? which need CSS selector fixes?
```

---

### **Action 4: Report to User** (5 minutes)

```
I've completed initial audit and testing. Here's what I found:

✅ WORKING:
- Production site operational
- PostgreSQL connected (no SQLite fallback)
- Frontend functional
- Authentication working

❌ NEEDS WORK:
- [List job sources that failed testing]
- Email service not configured
- [Other issues found]

📋 NEXT STEPS:
- Fix failed job sources (CSS selectors)
- Integrate SendGrid for email
- Implement golden dataset tests

Ready to proceed with fixes?
```

---

## 📌 FINAL NOTES & REMINDERS

**This is a PRODUCTION system**:

- Live at <https://whatismydelta.com>
- Real users depend on it
- Changes must be tested locally first
- Always have rollback plan

**Your mission**:

1. Complete job source testing & fixes
2. Integrate email service
3. Implement automated testing
4. Document everything clearly

**Remember**:

- Context manager pattern is SACRED
- PostgreSQL syntax, not SQLite
- Explicit error logging, never silent
- Local testing FIRST, always

**Communication**:

- Update user on progress
- Report blockers early
- Be transparent about challenges
- Ask questions if unclear

---

## ✅ HANDOFF COMPLETE

**Date**: 2025-12-01
**From**: Claude Code (Sonnet 4.5)
**To**: Claude Opus (Desktop)
**Status**: Ready for implementation

**You now have EVERYTHING you need** to complete the Mosaic overhaul without accessing external files. This document is 100% self-contained.

**Good luck, Senior Implementation Engineer. The project is yours.**

---

**END OF COMPLETE HANDOFF DOCUMENT**
