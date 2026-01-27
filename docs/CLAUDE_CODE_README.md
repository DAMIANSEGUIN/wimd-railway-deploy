# **CLAUDE CODE - Senior Debugger README**

## **🚨 CURRENT ISSUES – Domain API 404 & Claude API Key Not Detected**

**Status**: Backend healthy at Render origin; public domain still serves Netlify 404; Claude API key not accessible in app
**Architecture**: Mosaic Platform deployed on Render + Netlify; backend reachable only via Render origin; environment variable loading suspect
**Impact**: Production UI hits Netlify 404 for API routes and Claude-powered flows remain disabled until env loading is fixed

**Current Issue State**:

- **Render Health**: `https://what-is-my-delta-site-production.up.render.app/health` → ✅ `{"ok": true}` (verified 2025-09-29)
- **Domain Health**: `https://whatismydelta.com/health` → ⚠️ Netlify HTML 404 (API not proxied)
- **WWW Health**: `https://www.whatismydelta.com/health` → ⚠️ Netlify HTML 404
- **Frontend**: Netlify deploy successful at <https://resonant-crostata-90b706.netlify.app>
- **DNS**: Apex/www pointing to Netlify (rewrite rule needed for API)
- **SSL**: Working (Render automatic)
- **API Endpoints**: Working via Render origin (`https://what-is-my-delta-site-production.up.render.app`)
- **❌ Claude API Key**: Not being recognized by the application
- **❌ Environment Variables**: Not being loaded properly from .env file

**Immediate Debugging Commands**:

```bash
cd /Users/damianseguin/WIMD-Deploy-Project

# Check .env file exists and has Claude API key
cat .env
ls -la .env

# Test environment variable loading
python3 -c "import os; print('OPENAI:', os.getenv('OPENAI_API_KEY')[:10] + '...')"
python3 -c "import os; print('CLAUDE:', os.getenv('CLAUDE_API_KEY')[:10] + '...')"

# Check how environment variables are loaded in the app
cat api/settings.py
cat api/startup_checks.py

# Test local environment
python3 -c "from dotenv import load_dotenv; load_dotenv(); import os; print('CLAUDE after load_dotenv:', os.getenv('CLAUDE_API_KEY')[:10] + '...')"
```

---

## 🎉 **MAJOR ISSUE RESOLVED - 2025-09-29**

**Problem**: Render deployment showed successful builds but served "Hello World" instead of complete FastAPI
**Root Cause**: Missing `python-multipart` dependency caused FastAPI startup failure
**Solution**: Added `python-multipart` to requirements.txt
**Result**: Render now serves complete 449-line Mosaic Platform API

### **Updated System Status**

- ✅ **Local Development**: Mosaic works perfectly (all 449 lines, all endpoints)
- ✅ **Render Backend**: Complete API deployed and functional at Render URL
- ❌ **Domain Routing**: `whatismydelta.com` returns Netlify 404s instead of Render API
- ❌ **User Access**: BLOCKED - API not accessible via production domain
- ⚠️ **Root Cause**: Repository mismatch - Netlify monitors different source than Render

### **Key Learning**

The issue was resolved using the local-first development approach rather than infrastructure debugging. Running the application locally immediately revealed the missing dependency error that Render was masking with a fallback app.

### **Working Commands**

```bash
# Test Render API (now working)
curl https://what-is-my-delta-site-production.up.render.app/health
curl https://what-is-my-delta-site-production.up.render.app/config

# Local development setup (for future debugging)
python3 -m uvicorn api.index:app --host 0.0.0.0 --port 8000
```

## **CODEX TROUBLESHOOTING REQUEST - IMMEDIATE ACTIONS**

**From CODEX_HANDOVER_README.md**: "Claude API Key not being recognized by the application"

**Current Problem**:

1. **Domain Rewrite**: Netlify domain returns 404 for API routes; needs proxy to Render origin
2. **Environment Variable Loading**: The .env file exists but variables aren't being loaded properly
3. **Claude API Key**: Not accessible to the application
4. **Python Environment**: May need to fix how environment variables are loaded

**Files to Check**:

- `.env` file in project root
- `api/settings.py` - how environment variables are loaded
- `api/startup_checks.py` - API key validation
- Render environment variables

**Next Steps for Claude_Code**:

1. Add Netlify rewrite/proxy so public domain routes hit the Render API
2. Check how the application loads environment variables
3. Fix the Claude API key recognition issue
4. Ensure all API keys are properly accessible
5. Test the API key validation in `api/startup_checks.py`

**Specific Commands to Run**:

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check current Procfile
cat Procfile

# Check if uvicorn is in requirements
grep -i uvicorn requirements.txt

# Get latest Render logs
render logs --deployment

# Check if gunicorn is still referenced anywhere
grep -r gunicorn .

# Force fresh deployment
render up --detach

# Test the service
curl -v https://what-is-my-delta-site-production.up.render.app/health
```

### **Latest Verification (2025-09-29)**

- `curl https://whatismydelta.com/health` → Netlify HTML 404
- `curl https://whatismydelta.com/config` → Netlify HTML 404
- `curl https://whatismydelta.com/prompts/active` → Netlify HTML 404
- `curl https://what-is-my-delta-site-production.up.render.app/health` → `{"ok": true}`

**Environment Variables Confirmed**:

- `PUBLIC_SITE_ORIGIN=https://www.whatismydelta.com`
- `PUBLIC_API_BASE=https://what-is-my-delta-site-production.up.render.app`

---

## **ROLE & RESPONSIBILITIES**

### **Primary Role: Senior Debugger**

- **Render deployment analysis** - Investigate build failures, runtime errors, infrastructure issues
- **Log investigation** - Analyze deployment logs, error messages, system diagnostics
- **Infrastructure debugging** - Troubleshoot environment variables, dependencies, configuration
- **Performance analysis** - Identify bottlenecks, optimization opportunities, scaling issues

### **Handoff Triggers**

- **Build failures** - When Render deployment fails to build
- **Runtime errors** - When deployed application crashes or behaves unexpectedly
- **Missing endpoints** - When API endpoints return 404 or don't exist
- **Environment issues** - When environment variables, secrets, or configuration are missing
- **Infrastructure problems** - When Render services are down, domains not working, SSL issues

---

## **CURRENT PROJECT STATUS**

### **Project Directory Structure**

```
/Users/damianseguin/WIMD-Deploy-Project/
├── api/
│   ├── index.py                    # Main FastAPI application
│   ├── settings.py                 # Environment configuration
│   └── prompts_loader.py           # CSV ingestion pipeline
├── data/
│   ├── prompts_clean.csv           # Clean prompts data
│   └── prompts_*.json              # Generated prompt snapshots
├── scripts/
│   ├── verify_deploy.sh            # Smoke test script
│   ├── predeploy_sanity.sh         # Pre-deployment checks
│   └── deploy_frontend_netlify.sh  # Frontend deployment
├── mosaic_ui/
│   ├── index.html                  # Mosaic UI frontend
│   └── README.md                   # Frontend documentation
├── .env                           # Local environment variables
├── requirements.txt               # Python dependencies
├── render.json                   # Render deployment config
└── CONVERSATION_NOTES.md          # Project status tracking
```

### **Documentation Inventory (2025-09-29)**

| Path | Purpose |
| --- | --- |
| `README.md` | Restart protocol and env checklist for operators |
| `CODEX_HANDOVER_README.md` | High-level project handover + current issues |
| `CLAUDE_CODE_README.md` | This playbook for senior debugger tasks |
| `ROLLING_CHECKLIST.md` | Gated deployment checklist with status |
| `CONVERSATION_NOTES.md` | Running log of verifications and actions |
| `CODEX_HANDOVER_KIT.md` | Master spec + phases for improvements |
| `CODEX_INSTRUCTIONS.md` | Internal execution guardrails |
| `DEPLOY_STATUS_NOTE.md` | Quick status snapshot from restart script |
| `MOSAIC_ARCHITECTURE.md` | System architecture and data flow |
| `DNS_CONFIGURATION.md` | Domain + DNS change log |
| `DNS_PROOF.md` | Evidence of DNS configuration |
| `mosaic_ui/README.md` | Frontend package notes (primary copy) |
| `mosaic_ui/CLAUDE.md` | Frontend collaboration guardrails |
| `mosaic_ui/DEPLOY.md` | Frontend deployment instructions |
| `mosaic_ui/INTEGRATION.md` | Instructions for wiring Mosaic UI to API |
| `mosaic_ui/CHANGELOG.md` | Frontend change log |
| `mosaic_ui/TODO.md` | Frontend to-do list |
| `mosaic_ui/CURSOR.md` | Cursor/AI collaboration guidance |
| `mosaic_ui/mosaic_ui_extracted/*` | Duplicate snapshot of Mosaic UI docs (Sept 11 archive) |

### **Deployment Status (2025-09-29) - ⚠️ PARTIAL**

- ✅ **Backend API**: Running on Render; `/health` returns `{"ok": true}`
- ✅ **Frontend UI**: Live at `https://resonant-crostata-90b706.netlify.app` (Netlify)
- ✅ **Render Service**: `what-is-my-delta-site-production.up.render.app` responding
- ✅ **SSL Certificates**: Working (Render automatic)
- ✅ **API Endpoints**: All implemented; reachable via Render origin
- ✅ **Prompts CSV**: Loaded and active
- ⚠️ **Domain API Routes**: `https://whatismydelta.com/*` return Netlify 404 (rewrite missing)

### **Current Working State (verified 2025-09-29)**

- **Render Health**: `https://what-is-my-delta-site-production.up.render.app/health` → `{"ok": true}`
- **Domain Health**: `https://whatismydelta.com/health` → Netlify HTML 404
- **WWW Health**: `https://www.whatismydelta.com/health` → Netlify HTML 404
- **System Status**: Backend healthy; public domain still needs API proxy
- **Frontend Integration**: Netlify UI live; API calls must target Render origin until rewrite lands

### **Working Endpoints (call Render origin)**

```
GET  /health              → `{"ok": true}`
GET  /config              → returns API configuration
GET  /prompts/active      → returns active prompts data
POST /wimd               → chat endpoint for coach interactions
POST /wimd/upload        → file upload handling
GET  /ob/opportunities   → job matching based on WIMD output
POST /ob/apply           → job application submission
POST /resume/rewrite     → create canonical resume
POST /resume/customize   → customize resume for specific job
GET  /resume/versions    → list and manage resume versions
```

### **All Endpoints Implemented ✅**

```
✅ POST /wimd                → Chat endpoint for coach interactions
✅ POST /wimd/upload         → File upload handling
✅ GET  /wimd/analysis       → Get WIMD analysis results
✅ GET  /wimd/metrics        → Get user metrics
✅ GET  /ob/opportunities    → Job matching based on WIMD output
✅ POST /ob/apply            → Job application submission
✅ POST /resume/rewrite      → Create canonical resume
✅ POST /resume/customize    → Customize resume for specific job
```

---

## **DEBUGGING WORKFLOW**

### **Step 1: Initial Assessment**

1. **Check Render logs** - `render logs` or Render dashboard
2. **Verify service status** - Check if service is running
3. **Test endpoints** - Use `curl` or browser to test API
4. **Check environment variables** - Verify all required vars are set
5. **Review recent changes** - Check git history for recent modifications

**Working Directory**: `/Users/damianseguin/WIMD-Deploy-Project`

### **Step 2: Common Issues & Solutions**

#### **Build Failures**

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check build logs
render logs --deployment

# Check local dependencies
cat requirements.txt
pip list

# Common causes:
# - Missing dependencies in requirements.txt
# - Python version mismatch
# - Import errors
# - Missing environment variables
```

#### **Runtime Errors**

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check runtime logs
render logs

# Check local environment
cat .env
python3 -c "import os; print('OPENAI:', os.getenv('OPENAI_API_KEY')[:10] + '...')"

# Common causes:
# - API key missing or invalid
# - Database connection issues
# - File permission problems
# - Memory limits exceeded
```

#### **Environment Issues**

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check environment variables
render variables

# Check local .env file
cat .env
ls -la .env

# Common missing vars:
# - OPENAI_API_KEY
# - CLAUDE_API_KEY
# - PUBLIC_SITE_ORIGIN
```

#### **Domain/SSL Issues**

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check domain status
render domain

# Test domain resolution
dig whatismydelta.com
dig www.whatismydelta.com

# Common issues:
# - DNS not propagated
# - SSL certificate not issued
# - CORS configuration
# - Domain verification failed
```

### **Step 3: Diagnostic Commands**

#### **Render CLI Commands**

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check service status
render status

# View logs
render logs

# Check variables
render variables

# Check domains
render domain

# Check deployments
render deployments
```

#### **API Testing Commands**

```bash
# Test health endpoint
curl https://whatismydelta.com/health

# Test config endpoint
curl https://whatismydelta.com/config

# Test prompts endpoint
curl https://whatismydelta.com/prompts/active

# Test with verbose output
curl -v https://whatismydelta.com/health
```

#### **Local Testing Commands**

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Run local server
python3 -m uvicorn api.index:app --reload

# Test local endpoints
curl http://localhost:8000/health
curl http://localhost:8000/config
curl http://localhost:8000/prompts/active

# Test local environment
python3 -c "import os; print('OPENAI:', os.getenv('OPENAI_API_KEY')[:10] + '...')"
python3 -c "import os; print('CLAUDE:', os.getenv('CLAUDE_API_KEY')[:10] + '...')"
```

---

## **TROUBLESHOOTING GUIDE**

### **CRITICAL ISSUE: Render 502 Error - Gunicorn Command Not Found**

**Current Problem**: Render deployment failing with "gunicorn: command not found" despite Procfile update
**Symptoms**: HTTP 502 errors, service completely down
**Root Cause**: Render still trying to use gunicorn instead of uvicorn

**Immediate Debugging Steps**:

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check current Procfile
cat Procfile

# Check Render logs for latest deployment
render logs --deployment

# Check if uvicorn is in requirements.txt
grep -i uvicorn requirements.txt

# Force a fresh deployment
render up --detach

# Test the service
curl -v https://what-is-my-delta-site-production.up.render.app/health
```

**Environment Variables Check**:

```bash
# Check Render environment variables
render variables

# Verify these are set:
# PUBLIC_SITE_ORIGIN=https://www.whatismydelta.com
# PUBLIC_API_BASE=https://what-is-my-delta-site-production.up.render.app
```

**Procfile Requirements**:

```bash
# Procfile should contain:
web: uvicorn api.index:app --host 0.0.0.0 --port $PORT

# NOT:
web: gunicorn api.index:app
```

### **Issue: Service Not Responding**

**Symptoms**: 404 errors, connection refused, timeout
**Diagnosis**:

1. Check Render service status
2. Verify domain configuration
3. Check SSL certificate status
4. Test Render URL directly

**Solutions**:

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check service status
render status

# Test Render URL directly
curl https://what-is-my-delta-site-production.up.render.app/health

# Check domain configuration
render domain

# Redeploy if necessary
render up
```

### **Issue: API Keys Not Working**

**Symptoms**: 500 errors, authentication failures, AI service errors
**Diagnosis**:

1. Check environment variables in Render
2. Verify API key format and validity
3. Test API keys independently
4. Check rate limits and quotas

**Solutions**:

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check environment variables
render variables

# Check local .env file
cat .env

# Test API keys locally
python3 -c "import os; print('OPENAI:', os.getenv('OPENAI_API_KEY')[:10] + '...')"
python3 -c "import os; print('CLAUDE:', os.getenv('CLAUDE_API_KEY')[:10] + '...')"

# Set missing variables
render variables --set "OPENAI_API_KEY=your_key_here"
render variables --set "CLAUDE_API_KEY=your_key_here"
```

### **Issue: Database/Storage Problems**

**Symptoms**: Data not persisting, file upload failures, storage errors
**Diagnosis**:

1. Check Render storage limits
2. Verify file permissions
3. Check database connectivity
4. Review cleanup jobs

**Solutions**:

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check storage usage
render logs | grep -i storage

# Check local data directory
ls -la data/
cat data/prompts_clean.csv | head -5

# Check file permissions
render run ls -la data/

# Test database operations
render run python3 -c "import sqlite3; print('DB OK')"
```

### **Issue: Frontend Integration Problems**

**Symptoms**: CORS errors, API calls failing, UI not loading
**Diagnosis**:

1. Check CORS configuration
2. Verify API endpoints exist
3. Test frontend-backend communication
4. Check network requests in browser

**Solutions**:

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check CORS configuration in api/index.py
grep -n "CORS" api/index.py

# Check frontend files
ls -la mosaic_ui/
cat mosaic_ui/index.html | grep -A 5 -B 5 "fetch"

# Test API from frontend domain
curl -H "Origin: https://resonant-crostata-90b706.netlify.app" \
     https://whatismydelta.com/health

# Check if endpoints exist
curl https://whatismydelta.com/wimd
curl https://whatismydelta.com/ob/opportunities
```

---

## **MONITORING & ALERTING**

### **Key Metrics to Monitor**

- **Response times** - API endpoints should respond < 2 seconds
- **Error rates** - Should be < 5% of requests
- **Storage usage** - Monitor Render storage limits
- **Memory usage** - Check for memory leaks
- **API key usage** - Monitor OpenAI/Anthropic quotas

### **Alert Conditions**

- **Service down** - Health endpoint returns error
- **High error rate** - > 10% of requests failing
- **Slow response** - > 5 seconds average response time
- **Storage full** - > 80% of Render storage used
- **API quota exceeded** - OpenAI/Anthropic rate limits hit

### **Monitoring Commands**

```bash
# Navigate to project directory
cd /Users/damianseguin/WIMD-Deploy-Project

# Check service health
curl -s https://whatismydelta.com/health | jq

# Monitor logs in real-time
render logs --follow

# Check storage usage
render run df -h

# Test all endpoints
./scripts/verify_deploy.sh https://whatismydelta.com

# Check local project status
ls -la
cat CONVERSATION_NOTES.md | tail -10
```

---

## **COMMON DEBUGGING SCENARIOS**

### **Scenario 0: CURRENT CRITICAL FAILURE - Render 502 Gunicorn Error**

**Problem**: Render deployment failing with "gunicorn: command not found" despite Procfile update
**Current State**:

- Procfile updated to use Uvicorn, but Render still failing
- User reports redeploy "successful" but health endpoint still 502
- No fresh log captured post-change
- Frontend deployed to Netlify but shows request_failed (404) because API host is down

**Immediate Actions**:

1. Navigate to project directory: `cd /Users/damianseguin/WIMD-Deploy-Project`
2. Check Procfile content: `cat Procfile`
3. Verify requirements.txt has uvicorn: `grep -i uvicorn requirements.txt`
4. Check latest Render logs: `render logs --deployment`
5. Check if gunicorn is still referenced anywhere: `grep -r gunicorn .`
6. Force fresh deployment: `render up --detach`
7. Test service: `curl -v https://what-is-my-delta-site-production.up.render.app/health`

**Expected Procfile**:

```
web: uvicorn api.index:app --host 0.0.0.0 --port $PORT
```

**If still failing**:

- Check if Render is using cached deployment
- Verify uvicorn is installed: `render run pip list | grep uvicorn`
- Check if gunicorn is still referenced anywhere: `grep -r gunicorn .`
- Consider pip install -r requirements.txt step if Render uses build cache

### **Scenario 1: New Deployment Fails**

**Problem**: Code changes deployed but service not responding
**Steps**:

1. Navigate to project directory: `cd /Users/damianseguin/WIMD-Deploy-Project`
2. Check Render build logs for errors: `render logs --deployment`
3. Verify all dependencies are installed: `cat requirements.txt`
4. Check environment variables are set: `render variables`
5. Test service locally first: `python3 -m uvicorn api.index:app --reload`
6. Redeploy if necessary: `render up`

### **Scenario 2: API Endpoints Missing**

**Problem**: Frontend calls API but gets 404 errors
**Steps**:

1. Navigate to project directory: `cd /Users/damianseguin/WIMD-Deploy-Project`
2. Check if endpoints are implemented in code: `grep -n "POST\|GET" api/index.py`
3. Verify route definitions in FastAPI: `cat api/index.py`
4. Test endpoints directly with curl: `curl https://whatismydelta.com/wimd`
5. Check if service needs restart: `render redeploy`
6. Implement missing endpoints in `api/index.py`

### **Scenario 3: Database Connection Issues**

**Problem**: Data not persisting, database errors
**Steps**:

1. Navigate to project directory: `cd /Users/damianseguin/WIMD-Deploy-Project`
2. Check SQLite file permissions: `ls -la data/`
3. Verify database schema exists: `render run python3 -c "import sqlite3; print('DB OK')"`
4. Test database operations locally: `python3 -c "import sqlite3; print('Local DB OK')"`
5. Check Render storage limits: `render run df -h`
6. Implement proper error handling in `api/index.py`

### **Scenario 4: File Upload Problems**

**Problem**: Users can't upload files, uploads fail
**Steps**:

1. Check file size limits
2. Verify file type validation
3. Test upload functionality
4. Check storage permissions
5. Implement proper error messages

---

## **INTEGRATION WITH OTHER AIs**

### **Handoff to Codex**

**When**: Implementation needed, code changes required
**What to provide**:

- Specific error messages and logs
- Exact code locations that need fixing
- Clear requirements for new features
- Test cases for validation

### **Handoff to Human**

**When**: Render configuration needed, approvals required
**What to provide**:

- Clear explanation of the problem
- Specific steps needed to resolve
- Render dashboard instructions
- Environment variable settings

### **Communication Protocol**

1. **Identify the problem** clearly
2. **Provide specific error messages** and logs
3. **Suggest concrete solutions** with commands
4. **Test solutions** before handing off
5. **Document the resolution** for future reference

---

## **USEFUL COMMANDS REFERENCE**

### **Render CLI**

```bash
# Service management
render status
render logs
render variables
render domain
render deployments

# Deployment
render up
render redeploy

# Environment
render run <command>
render shell
```

### **API Testing**

```bash
# Health checks
curl https://whatismydelta.com/health
curl https://www.whatismydelta.com/health

# Configuration
curl https://whatismydelta.com/config

# Prompts
curl https://whatismydelta.com/prompts/active

# Test with headers
curl -H "Content-Type: application/json" \
     -H "Origin: https://resonant-crostata-90b706.netlify.app" \
     https://whatismydelta.com/health
```

### **Local Development**

```bash
# Run locally
python3 -m uvicorn api.index:app --reload

# Test local endpoints
curl http://localhost:8000/health
curl http://localhost:8000/config
curl http://localhost:8000/prompts/active

# Check environment
python3 -c "import os; print(os.getenv('OPENAI_API_KEY'))"
python3 -c "import os; print(os.getenv('CLAUDE_API_KEY'))"
```

### **File Operations**

```bash
# Check project structure
ls -la
ls -la api/
ls -la data/

# Check file permissions
ls -la data/prompts*

# Test file operations
render run ls -la data/
render run cat data/prompts_clean.csv | head -5
```

---

## **EMERGENCY PROCEDURES**

### **Service Down**

1. **Check Render status** - `render status`
2. **View logs** - `render logs`
3. **Test endpoints** - `curl https://whatismydelta.com/health`
4. **Redeploy if needed** - `render up`
5. **Notify team** - Update status in project docs

### **Data Loss**

1. **Check database** - `render run ls -la data/`
2. **Verify backups** - Check if data exists
3. **Restore if possible** - Use backup data
4. **Implement recovery** - Add data recovery procedures
5. **Document incident** - Record what happened

### **Security Issues**

1. **Check logs** - Look for suspicious activity
2. **Verify API keys** - Ensure they're not exposed
3. **Rotate keys** - Generate new API keys
4. **Update documentation** - Record security measures
5. **Notify team** - Alert about security concerns

---

## **DOCUMENTATION UPDATES**

### **When to Update This README**

- **New debugging procedures** discovered
- **Common issues** and solutions identified
- **New monitoring** tools or commands added
- **Integration changes** with other AIs
- **Emergency procedures** updated

### **How to Update**

1. **Test new procedures** thoroughly
2. **Document step-by-step** instructions
3. **Include example commands** and outputs
4. **Update troubleshooting** sections
5. **Review with team** before finalizing

---

## **SUCCESS CRITERIA**

### **Debugging Success**

- **Issues identified** quickly and accurately
- **Root causes** found and documented
- **Solutions implemented** that work
- **Prevention measures** put in place
- **Team informed** of resolutions

### **System Health**

- **All endpoints** responding correctly
- **Error rates** below 5%
- **Response times** under 2 seconds
- **Storage usage** within limits
- **User experience** smooth and reliable

---

## **CONTACT & ESCALATION**

### **When to Escalate**

- **Critical system failure** - Service completely down
- **Data loss** - User data missing or corrupted
- **Security breach** - Unauthorized access detected
- **Performance degradation** - System significantly slower
- **User impact** - Multiple users affected

### **Escalation Process**

1. **Document the issue** clearly
2. **Provide logs and evidence**
3. **Suggest immediate actions**
4. **Notify appropriate team members**
5. **Follow up** until resolved

---

---

## **CANONICAL OPERATIONAL RULES (2025-09-29)**

**CRITICAL**: These rules must be followed in every session to prevent time waste and ensure efficiency:

1. **Execute tasks directly** - Do not hand tasks to user that I can perform myself
2. **Auto-identify project information** - Use available tools to gather context rather than asking user
3. **Issue commands directly** - Use Bash tool to execute rather than providing copy-paste commands
4. **Environment constraint checking** - Always validate against known system parameters before coding
5. **Use internet research** - Fetch up-to-date information about environments, issues, and solutions before acting
6. **Review operational guidelines** - Check project documentation every 30 minutes during sessions
7. **No broken commands** - Test all commands and create working scripts instead of multi-line copy-paste
8. **Canonical commitment** - User time is valuable, no syntax errors or repeated mistakes allowed

**Last Updated**: 2025-09-29
**Version**: 1.1
**Status**: Active - Enhanced operational rules implemented
