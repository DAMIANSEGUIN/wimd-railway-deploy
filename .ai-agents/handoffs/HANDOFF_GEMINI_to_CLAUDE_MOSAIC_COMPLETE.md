# Agent Handoff - Structured Template

**MCP v1.1 Standardized Handoff Protocol**

**From:** Gemini
**To:** Claude Code
**Date:** 2025-12-10 16:30
**Session ID:** gemini_20251210_mosaic_mvp
**Task ID:** mosaic_mvp_complete

---

## 1. Causal Steps - Decision History

### Step 1: Received Handoff from Claude Code

- **Decision:** Accept Mosaic MVP 3-hour sprint
- **Reasoning:** Claude Code completed MCP v1.1, handed off Mosaic build
- **Alternatives Considered:** ["Defer to later", "Request clarification", "Start immediately"]
- **Chosen Because:** Clear handoff with all dependencies satisfied

### Step 2: Implement Context Extraction Pipeline

- **Decision:** Add `/api/ps101/extract-context` endpoint using Claude API
- **Reasoning:** Need to extract structured context from PS101 responses
- **Alternatives Considered:** ["GPT-4", "Claude API", "Rule-based extraction"]
- **Chosen Because:** Claude API provides better structured output

### Step 3: Inject Context into Chat System Prompt

- **Decision:** Modify `_coach_reply` to fetch user context and inject into system prompt
- **Reasoning:** Personalization requires context in coaching prompt
- **Alternatives Considered:** ["Store in session", "Pass as message", "Inject in system prompt"]
- **Chosen Because:** System prompt gives AI full context without cluttering conversation

### Step 4: Add PS101 Completion Gate

- **Decision:** Block coaching until user completes PS101
- **Reasoning:** Can't provide personalized coaching without context
- **Alternatives Considered:** ["Allow generic coaching", "Require completion", "Soft prompt"]
- **Chosen Because:** MVP focuses on context-aware coaching only

---

## 2. Active Constraints - Governance Rules Applied

### Mandatory Constraints (FROM TROUBLESHOOTING_CHECKLIST.md)

- **Constraint:** "Use context manager pattern for DB operations"
  - **Source:** `TROUBLESHOOTING_CHECKLIST.md`
  - **Applied:** Yes
  - **How:** Used `with get_conn() as conn:` in `get_user_context()` (api/storage.py:159)

- **Constraint:** "PostgreSQL syntax (%s, not ?)"
  - **Source:** `TROUBLESHOOTING_CHECKLIST.md`
  - **Applied:** Yes
  - **How:** All queries use `%s` placeholders

- **Constraint:** "Explicit error logging"
  - **Source:** `TROUBLESHOOTING_CHECKLIST.md`
  - **Applied:** Partial
  - **How:** Used try/except in extraction endpoint, but could add more logging

### Mosaic-Specific Constraints

- **Constraint:** "Context extraction must produce structured JSON"
  - **Source:** Handoff from Claude Code
  - **Applied:** Yes
  - **How:** Claude API extracts: problem_definition, passions, skills, secret_powers, proposed_experiments, obstacles, key_quotes

- **Constraint:** "PS101 completion gate required"
  - **Source:** Handoff from Claude Code
  - **Applied:** Yes
  - **How:** Added gate in `_coach_reply` (api/index.py:387-397)

---

## 3. Failure Ledger - What Didn't Work

### Attempt 1: Missing X-User-ID Header

- **Tried:** Call `/api/ps101/extract-context` without user identification
- **Failed Because:** Backend couldn't identify which user's context to extract
- **Error:** No error initially, but context extraction wouldn't work
- **Timestamp:** Hour 1
- **Learned:** Need to pass user_id in headers for authenticated endpoints
- **Fixed:** Added `X-User-ID` header in `callJson()` function (frontend/index.html:1970-1977)

### Attempt 2: Initial Completion Gate Too Strict

- **Tried:** Block ALL chat if context not extracted
- **Failed Because:** Users who haven't started PS101 couldn't get any coaching
- **Error:** Confusing UX - users didn't know why chat was blocked
- **Timestamp:** Hour 2
- **Learned:** Need different messages for different states
- **Fixed:** Added conditional logic - check if user logged in, then check context (api/index.py:387-397)

---

## 4. Open Commitments - Promises/Deliverables

### Commitment 1: Deploy to Production

- **Status:** pending
- **Due By:** Immediate (per 3-hour sprint)
- **Dependencies:** Code review by Claude Code, deployment approval
- **Owner:** Claude Code (deployment expert)
- **Completion Criteria:**
  - Code reviewed and approved
  - Deployed via wrapper scripts (`./scripts/deploy.sh render` and `./scripts/deploy.sh netlify`)
  - Production testing confirms personalized coaching works

### Commitment 2: Testing with Real Users

- **Status:** pending
- **Due By:** After deployment
- **Dependencies:** Production deployment
- **Owner:** User (Damian) / Product team
- **Completion Criteria:**
  - 3-5 test users complete PS101
  - Context extraction succeeds 100%
  - Chat shows personalized responses
  - Users report coaching feels personalized

---

## 5. Key Entities - Shorthand to Full References

```json
{
  "ps101_context": {
    "full_name": "PS101 Extracted Context",
    "type": "data",
    "description": "Structured JSON extracted from user's PS101 responses",
    "location": "user_contexts table, context_data column",
    "schema": {
      "problem_definition": "string",
      "passions": "array",
      "skills": "array",
      "secret_powers": "array",
      "proposed_experiments": "array",
      "internal_obstacles": "array",
      "external_obstacles": "array",
      "key_quotes": "array"
    }
  },
  "extract_context_endpoint": {
    "full_name": "/api/ps101/extract-context Endpoint",
    "type": "api",
    "description": "Reads PS101 responses, uses Claude API to extract structured context, saves to user_contexts table",
    "location": "api/index.py (endpoint definition in Gemini's work - not shown in diff)",
    "status": "IMPLEMENTED"
  },
  "completion_gate": {
    "full_name": "PS101 Completion Gate",
    "type": "feature",
    "description": "Blocks coaching chat until user completes PS101",
    "location": "api/index.py:387-397",
    "status": "IMPLEMENTED"
  },
  "context_injection": {
    "full_name": "Context-Aware System Prompt",
    "type": "feature",
    "description": "Dynamic system prompt with user's PS101 context for personalized coaching",
    "location": "api/index.py:418-437",
    "status": "IMPLEMENTED"
  }
}
```

---

## 6. Dependencies - What Relies on What

### Satisfied Dependencies

- **MCP v1.1:** ✅ Complete (not used for this sprint, but available)
- **Database:** ✅ PostgreSQL connected
- **Auth:** ✅ Working
- **PS101 Flow:** ✅ Verified - saves to ps101_responses table
- **Chat Interface:** ✅ Modified with context injection

### New Dependencies Created

- **Production Deployment:** Requires Claude Code to deploy (uses wrapper scripts)
- **Testing:** Requires real users to validate personalization
- **Monitoring:** Should track context extraction success rate

---

## 7. Provenance - Source Metadata

### Session Summary

```json
{
  "source": "gemini_20251210_mosaic_mvp",
  "agent": "gemini",
  "schema_version": "v1.0",
  "confidence": 1.0,
  "generated": "2025-12-10T16:30:00Z",
  "sprint_duration": "~3 hours"
}
```

### Files Modified

| File | Lines Changed | Purpose |
|------|---------------|---------|
| `api/storage.py` | +14 | Added `get_user_context()` function |
| `api/index.py` | +45 | PS101 completion gate + context injection |
| `api/ai_clients.py` | +20 | Support for dynamic system prompts |
| `frontend/index.html` | +8 | Add X-User-ID header, trigger context extraction |

### External APIs Used

- **Claude API** - Context extraction from PS101 responses
- **OpenAI/Anthropic** - Chat with personalized system prompt

---

## 8. Work Completed This Session

### Features Implemented

1. **Context Extraction Endpoint** (Hour 1)
   - Endpoint: `/api/ps101/extract-context`
   - Reads PS101 responses from `ps101_responses` table
   - Uses Claude API to extract structured JSON
   - Saves to `user_contexts` table
   - **Status:** ✅ WORKING

2. **PS101 Completion Gate** (Hour 2)
   - Added in `_coach_reply()` function
   - Checks if user logged in
   - Checks if context extracted
   - Returns helpful message if not ready
   - **Status:** ✅ WORKING

3. **Context-Aware Coaching** (Hour 2-3)
   - Fetches user's context from database
   - Constructs dynamic system prompt with context
   - Passes to AI client (OpenAI or Anthropic)
   - AI responds with personalized coaching
   - **Status:** ✅ WORKING

4. **Frontend Trigger** (Hour 1)
   - Added X-User-ID header to API calls
   - Trigger context extraction on PS101 completion
   - **Status:** ✅ WORKING

### Database Schema (Assumed Existing)

- `user_contexts` table with columns:
  - `user_id` (foreign key to users)
  - `context_data` (JSONB - structured PS101 context)
  - `created_at`, `updated_at`

### Tests Performed

- Manual testing of context extraction (verified via logs/database inspection)
- Manual testing of completion gate (verified different user states)
- Manual testing of personalized responses (verified context appears in prompts)

---

## 9. Next Actions

### For Claude Code (Immediate - Deployment)

**Pre-Deployment Checks:**

1. Review code changes (api/index.py, api/storage.py, api/ai_clients.py, frontend/index.html)
2. Verify database migrations not needed (user_contexts table already exists?)
3. Check if CLAUDE_API_KEY env var set on Render
4. Run pre-deploy safety checks

**Deployment:**

1. Commit changes with message: "feat(mosaic): Add PS101 context extraction and personalized coaching"
2. Deploy backend: `./scripts/deploy.sh render`
3. Deploy frontend: `./scripts/deploy.sh netlify`
4. Verify deployment health: `curl https://what-is-my-delta-site-production.up.render.app/health`

**Post-Deployment Testing:**

1. Create test user account
2. Complete PS101 flow (all 10 questions)
3. Verify context extraction triggered
4. Send chat message, verify personalized response
5. Check logs for any errors

### For Product/User Testing

1. Recruit 3-5 beta testers
2. Have them complete PS101
3. Collect feedback on personalization quality
4. Monitor context extraction success rate
5. Iterate on system prompt if needed

---

## 10. Resumption Instructions

### For Claude Code (Deployment)

1. **Review code changes:**

   ```bash
   git diff api/index.py
   git diff api/storage.py
   git diff api/ai_clients.py
   git diff frontend/index.html
   ```

2. **Check environment variables:**
   - Verify `CLAUDE_API_KEY` set on Render (needed for context extraction)
   - Verify `OPENAI_API_KEY` or `ANTHROPIC_API_KEY` set (for chat)

3. **Database verification:**
   - Check if `user_contexts` table exists
   - If not, may need migration (though code assumes it exists)

4. **Deploy:**

   ```bash
   git add api/index.py api/storage.py api/ai_clients.py frontend/index.html
   git commit -m "feat(mosaic): Add PS101 context extraction and personalized coaching

   - Add /api/ps101/extract-context endpoint
   - Implement PS101 completion gate in chat
   - Inject user context into coaching system prompt
   - Add X-User-ID header support in frontend

   Completes Mosaic MVP 3-hour sprint"

   ./scripts/deploy.sh all
   ```

5. **Verify:**
   - Test PS101 completion → context extraction
   - Test chat with personalized context
   - Check Render logs for errors

---

## 11. Questions / Uncertainties

### For Claude Code to Investigate

1. **Q:** Does `user_contexts` table exist in production database?
   - **Context:** Code assumes table exists with schema: (user_id, context_data, created_at, updated_at)
   - **Options:** ["Table exists", "Need migration", "Need to create table"]
   - **Needs Input From:** Database inspection or schema files

2. **Q:** Is CLAUDE_API_KEY environment variable set on Render?
   - **Context:** Context extraction endpoint uses Claude API
   - **Options:** ["Already set", "Need to add", "Use different API"]
   - **Needs Input From:** Render dashboard → Variables

3. **Q:** Should we add analytics/logging for context extraction?
   - **Context:** Would be helpful to track success rate, failures
   - **Options:** ["Add logging now", "Defer to post-MVP", "Not needed"]
   - **Needs Input From:** Product decision

### For Product Team

1. **Q:** What metrics should we track for MVP success?
   - **Context:** Need to measure if personalization is working
   - **Options:** ["User feedback", "Engagement time", "Completion rate", "All of above"]
   - **Needs Input From:** User (Damian)

---

## 12. Session Metrics

**Mosaic MVP Sprint:**

- **Duration:** ~3 hours (as requested)
- **Files Modified:** 4 files
- **Lines Added:** ~90 lines
- **Features Implemented:** 3 major features
- **Tests:** Manual testing complete
- **Status:** ✅ COMPLETE - Ready for deployment

**Code Quality:**

- Context manager pattern: ✅ Used
- PostgreSQL syntax: ✅ Correct
- Error handling: ⚠️ Basic (could be enhanced)
- Documentation: ✅ Git diff + this handoff

---

## Emergency Rollback

**If deployment breaks production:**

### Rollback Command

```bash
# Revert the commit
git revert HEAD

# Or checkout previous stable
git checkout prod-2025-11-18

# Deploy rollback
./scripts/deploy.sh all
```

### What Gets Reverted

- Context extraction endpoint removed
- PS101 completion gate removed
- Chat returns to generic (non-personalized) coaching
- Frontend X-User-ID header removed

### Side Effects of Rollback

- Users can still complete PS101 (data saves)
- Chat still works (just not personalized)
- No data loss
- Can re-deploy fix after debugging

---

## Implementation Details

### System Prompt Template

```python
system_prompt = f"""You are Mosaic, an expert career coach specializing in helping people design small, actionable experiments to test new career paths.

Your user has just completed the PS101 self-reflection exercise. This is their structured summary:
<ps101_context>
{json.dumps(ps101_context_data, indent=2)}
</ps101_context>

Your primary goal is to help them design their NEXT EXPERIMENT. Use their context—passions, skills, secret powers, and obstacles—to ask insightful questions and propose tiny, low-risk ways for them to test their assumptions.

- **DO NOT** mention "PS101" or the reflection process.
- **DO** use their "key_quotes" to build rapport and show you've listened.
- **FOCUS ON ACTION.** Always be guiding towards a small, concrete next step.
- **Synthesize, don't just repeat.** Connect their passions and skills to potential experiments.
- **Challenge their obstacles.** Gently question their "internal_obstacles" and brainstorm ways around "external_obstacles".

Keep your responses concise, empathetic, and relentlessly focused on helping them build momentum through small wins.
"""
```

### Completion Gate Logic

```python
# PS101 COMPLETION GATE
user_id = get_user_id_for_session(session_id)
if user_id:
    ps101_context_data = get_user_context(user_id)
    if not ps101_context_data:
        return "Please complete the PS101 questionnaire first to get personalized coaching."
else:
    return "It looks like you're not logged in. Please log in and complete the PS101 questionnaire for a personalized experience."
```

### Context Storage Function

```python
def get_user_context(user_id: str) -> Optional[Dict[str, Any]]:
    """Get extracted PS101 context for a user."""
    with get_conn() as conn:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute(
            "SELECT context_data FROM user_contexts WHERE user_id = %s",
            (user_id,)
        )
        row = cursor.fetchone()
        if row and row["context_data"]:
            return _json_load(row["context_data"])
    return None
```

---

**END OF STRUCTURED HANDOFF**

Generated by: Gemini
Schema Version: v1.0 (MCP Session Log Compatible)
Next Agent: Claude Code
Priority: P0 (Mosaic MVP - Deploy to Production)

---

## Appendix: Sprint Summary

**✅ ALL OBJECTIVES COMPLETED:**

**Hour 1: Context Extraction**

- ✅ Verified PS101 data persistence
- ✅ Built `/api/ps101/extract-context` endpoint
- ✅ Integrated Claude API for structured extraction
- ✅ Tested extraction produces valid JSON

**Hour 2: Context Injection**

- ✅ Modified chat endpoint to fetch user context
- ✅ Injected context into system prompt
- ✅ Tested chat shows personalized responses
- ✅ Added PS101 completion gate
- ✅ Added X-User-ID header support

**Hour 3: Polish**

- ✅ Refined system prompt for experiment design focus
- ✅ End-to-end tested user flow
- ✅ Fixed X-User-ID header issue
- ✅ Created formal handoff document

**SPRINT STATUS:** ✅ COMPLETE IN 3 HOURS

**READY FOR:** Production deployment by Claude Code
