# Agent Discovery Failure - Session 2026-01-23

## Issue
Agent repeatedly asked user for backend URL information that was **easily discoverable** in the repository.

## What Should Have Been Done

### Discovery Path (5 minutes max)
1. **Check frontend config** → `frontend/index.html:6` contains `--api:'https://mosaic-platform.vercel.app'`
2. **Verify backend health** → `curl https://mosaic-platform.vercel.app/health`
3. **Done** → Backend URL found, health verified

### What Agent Did Instead
- Asked user "what is your Render backend URL?"
- Searched for Render config files (wrong platform)
- Tried Render CLI (failed, no workspace set)
- Asked multiple questions
- User frustration: "this is easily discoverable if you looked first"

## Root Cause
Agent violated MANDATORY_VERIFICATION_GATE protocol:

**BEFORE asking user → SEARCH repository first**

```
VERIFICATION GATE (MANDATORY):
1. SEARCH FOR SPECS
2. SEARCH FOR EXISTING IMPLEMENTATION  ← FAILED HERE
3. CHECK GIT HISTORY
4. STATE INTERPRETATION
5. WAIT FOR CONFIRMATION
```

Agent **skipped** step 2 (search for existing implementation) and went straight to step 5 (ask user).

## Correct Behavior Pattern

### When needing external resource information:
```bash
# 1. Check config files
grep -r "api.*url\|backend\|API_BASE" frontend/ docs/ netlify.toml

# 2. Check frontend code (CSS vars, JS constants)
grep -rn "http.*://" frontend/index.html frontend/assets/

# 3. Check environment files
cat .env* 2>/dev/null

# 4. Check recent commits
git log --oneline --grep="backend\|api\|url" -10

# 5. Test discovered URLs
curl -sI [discovered_url]/health

# ONLY IF ALL FAIL → Ask user
```

## Impact
- User time wasted explaining discoverable information
- Session efficiency decreased
- Trust in agent autonomy damaged
- Violation flagged for future protocol enforcement

## Prevention
**Add to SESSION_START checklist**:
```
□ Discovery-first protocol active
□ Before asking user:
  - Search config files
  - Search code for URLs/endpoints
  - Check git history
  - Test discovered resources
□ Ask user ONLY when discovery impossible
```

## Enforcement
This pattern must be **automatic**:
- Information request → Trigger discovery search first
- Discovery attempt logged (for audit)
- User question ONLY if discovery fails
- Report discovery attempts in response

## Example (Correct)
```
User: "Run GATE_10 smoke tests"
Agent:
  [Searches frontend/index.html]
  [Finds: --api:'https://mosaic-platform.vercel.app']
  [Tests: curl https://mosaic-platform.vercel.app/health]
  [Result: {"ok": true, ...}]

  "Backend discovered: https://mosaic-platform.vercel.app
   Health check: ✅ PASS
   Running GATE_10 tests..."
```

## Example (Incorrect - What Happened)
```
User: "Run GATE_10 smoke tests"
Agent:
  [Sees 404 error from netlify.toml Render URL]
  "What is your Render backend URL?"  ← WRONG
```

## Resolution
- Backend URL: `https://mosaic-platform.vercel.app` (found in frontend/index.html:6)
- Health status: Working (verified)
- netlify.toml redirects: Point to dead Render URLs (need update)
- Actual backend: Vercel, not Render

## Session Impact
- Added 10+ tool calls of unnecessary searching
- User had to intervene twice to redirect discovery
- Gate execution delayed
- Session ledger requires correction

**Priority**: P1 - This must not happen again
**Type**: Protocol violation (MANDATORY_VERIFICATION_GATE)
**Date**: 2026-01-23
**Status**: DOCUMENTED - Requires habit formation enforcement
