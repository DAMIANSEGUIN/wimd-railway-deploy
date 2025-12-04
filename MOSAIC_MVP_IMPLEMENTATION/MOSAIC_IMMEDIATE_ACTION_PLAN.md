# MOSAIC - IMMEDIATE ACTION PLAN
**Date:** December 1, 2025  
**Status:** Opus Analysis Complete + Claude Code Ready  
**Timeline:** 3-Day MVP Sprint

---

## EXECUTIVE SUMMARY

**Opus has defined the MVP nucleus:** PS101 completion → Context extraction → Context-aware coaching focused on experiment design.

**Claude Code has the codebase ready:** Authentication works, PS101 flow exists, chat interface functional, database connected.

**The gap is simple:** Context extraction pipeline + context injection into coaching.

**Timeline:** 3 days to shippable MVP.

---

## WHAT OPUS DETERMINED

### MVP Nucleus (Irreducible Core)
1. **PS101 Completion Flow** (EXISTS - needs verification)
2. **Context Extraction Pipeline** (MISSING - build this)
3. **Context-Aware Coaching** (MISSING - inject context into chat)

### Defer to Post-MVP
- Full 608-prompt library (use Experimentation category only)
- Experiment tracking engine (code exists but disabled)
- Reflection & Learning phase
- Resume Rewriting
- Job Search function (eliminate)
- Multi-tier pricing

### 3-Day Build Sequence
- **Day 1:** Context extraction endpoint
- **Day 2:** Context injection into chat + completion gate
- **Day 3:** Experiment-focused coaching + beta prep

---

## WHAT CLAUDE CODE KNOWS

From the handoff document Claude Code created:

### What's Working ✅
- Authentication (login/register/password reset)
- PS101 flow exists
- Chat interface functional
- Database connected (PostgreSQL)
- Backend API deployed on Railway
- Frontend deployed on Netlify

### What Needs Building
1. Context extraction from PS101 responses
2. Context injection into coaching system prompt
3. Experiment-focused coaching refinement

### Critical Patterns to Follow
- Database context manager pattern (with get_conn())
- PostgreSQL syntax (%s, SERIAL, not SQLite)
- Explicit error logging
- Pre-deploy safety checks

---

## IMMEDIATE ACTIONS (DO NOW)

### Action 1: Give This Analysis to Claude Code

**In Terminal:**
```bash
cd ~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My\ Drive/WIMD-Railway-Deploy-Project

claude_code

# First message to Claude Code:
"Read MOSAIC_HANDOFF_TO_OPUS.md and WIMD_MVP_Analysis_Complete.md.

Opus has defined the MVP: PS101 → Context Extraction → Context-Aware Coaching.

Your task: Build the 3-day sprint from Opus analysis.

Day 1 priority: 
1. Verify PS101 data persistence
2. Build context extraction endpoint using Claude API
3. Test extraction produces structured JSON

Follow all safety protocols from TROUBLESHOOTING_CHECKLIST.md.

Start with repository audit, then begin implementation."
```

### Action 2: Monitor Progress

**Check-ins:**
- End of Day 1: Context extraction working?
- End of Day 2: Chat shows personalized responses?
- End of Day 3: Ready for beta users?

---

## DETAILED 3-DAY PLAN (FROM OPUS)

### Day 1: Foundation + Context Extraction

**Morning (2-3 hrs):**
- Audit PS101 flow (verify all 10 questions save correctly)
- Locate chat system prompt in codebase
- Document current state

**Afternoon (3-4 hrs):**
- Build `/api/ps101/extract-context` endpoint
- Use Claude API to extract:
  - `problem_definition` (string)
  - `passions` (array)
  - `skills` (array)
  - `secret_powers` (array)
  - `proposed_experiments` (array)
  - `internal_obstacles` (array)
  - `external_obstacles` (array)
  - `key_quotes` (array)
- Test with sample PS101 responses
- Store structured context in database

**Deliverable:** Context extraction works for any PS101 completion

---

### Day 2: Context Injection + Completion Flow

**Morning (3 hrs):**
- Modify chat endpoint to fetch user's extracted context
- Inject context into system prompt:
  ```
  You are coaching {user_name} who has completed PS101.
  
  Their situation:
  - Problem: {problem_definition}
  - Passions: {passions}
  - Skills: {skills}
  - Secret Powers: {secret_powers}
  - Proposed Experiments: {proposed_experiments}
  - Internal Obstacles: {internal_obstacles}
  - External Obstacles: {external_obstacles}
  
  Reference their specific context in your responses.
  Focus on helping them design small experiments.
  ```
- Test chat references user's actual data

**Afternoon (3 hrs):**
- Add PS101 completion gate (only access coaching after completing all 10)
- Create transition screen: "PS101 Complete → Begin Coaching"
- Show context summary on transition screen

**Evening (2 hrs):**
- End-to-end test with 3 sample users
- Verify personalization is obvious
- Fix any issues

**Deliverable:** User completes PS101 → sees personalized coaching

---

### Day 3: Experiment Focus + Beta Launch

**Morning (3 hrs):**
- Refine system prompt to emphasize experiment design:
  - "Multiple small experiments > one big pivot"
  - "Help them design safe-to-try tests"
  - "Make experiments concrete and time-bound"
- Test coaching produces actionable experiments

**Afternoon (2 hrs):**
- Add simple feedback collection:
  - "Did the coaching feel personalized?" (yes/no)
  - "Did you leave with a concrete experiment?" (yes/no)
  - Open text feedback
- Or use Typeform link

**Evening (2 hrs):**
- Beta user outreach (email/LinkedIn)
- Update landing page messaging
- Prepare 10-15 users to test

**Deliverable:** MVP ready for beta users

---

## SUCCESS CRITERIA (FROM OPUS)

### Must Work Before Beta Launch
- [ ] User can create account
- [ ] User can complete all 10 PS101 questions
- [ ] PS101 data persists across sessions
- [ ] Context extraction produces structured JSON (100% success rate)
- [ ] Chat interface shows context-aware responses
- [ ] Coaching guides toward experiment design

### Quality Thresholds
- PS101 completion time: < 45 minutes
- Context extraction: 100% success rate (no failures)
- Coaching personalization: Obvious in first 2 exchanges
- Experiment output: Concrete plan in 80% of sessions

### Beta Validation Targets
- 10-15 beta users complete full flow
- "Did coaching feel personalized?" → 70%+ yes
- "Did you leave with a concrete experiment?" → 70%+ yes
- Would recommend → 50%+ yes

---

## TECHNICAL IMPLEMENTATION NOTES

### Context Extraction Endpoint

**File:** `api/ps101.py` (or create)

```python
from anthropic import Anthropic
import json

@app.post("/api/ps101/extract-context")
async def extract_context(user_id: str):
    """Extract structured context from PS101 responses using Claude API"""
    
    # 1. Fetch PS101 responses from database
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT question_num, answer FROM ps101_responses WHERE user_id = %s ORDER BY question_num",
            (user_id,)
        )
        responses = cursor.fetchall()
    
    # 2. Build extraction prompt
    ps101_text = "\n\n".join([f"Q{q}: {a}" for q, a in responses])
    
    prompt = f"""Extract structured context from these PS101 responses:

{ps101_text}

Return JSON with these fields:
{{
  "problem_definition": "string - main career challenge",
  "passions": ["array", "of", "strings"],
  "skills": ["array", "of", "strings"],
  "secret_powers": ["array", "of", "strings"],
  "proposed_experiments": ["array", "of", "strings"],
  "internal_obstacles": ["array", "of", "strings"],
  "external_obstacles": ["array", "of", "strings"],
  "key_quotes": ["array", "of", "notable", "quotes"]
}}

Extract specific, concrete items. Be generous - include anything that might be relevant."""
    
    # 3. Call Claude API
    client = Anthropic(api_key=os.getenv("CLAUDE_API_KEY"))
    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=2000,
        messages=[{"role": "user", "content": prompt}]
    )
    
    # 4. Parse and store
    context = json.loads(response.content[0].text)
    
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(
            """INSERT INTO user_contexts (user_id, context_data, extracted_at)
               VALUES (%s, %s, NOW())
               ON CONFLICT (user_id) DO UPDATE SET context_data = %s, extracted_at = NOW()""",
            (user_id, json.dumps(context), json.dumps(context))
        )
        conn.commit()
    
    return {"success": True, "context": context}
```

### Context Injection into Chat

**File:** `api/chat.py` (modify existing)

```python
@app.post("/api/chat/message")
async def send_message(user_id: str, message: str):
    """Send message with user context injected"""
    
    # 1. Fetch user context
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT context_data FROM user_contexts WHERE user_id = %s",
            (user_id,)
        )
        result = cursor.fetchone()
        context = result[0] if result else None
    
    # 2. Build context-aware system prompt
    if context:
        system_prompt = f"""You are a career coach for a user who has completed PS101 self-reflection.

Their situation:
- Problem: {context['problem_definition']}
- Passions: {', '.join(context['passions'])}
- Skills: {', '.join(context['skills'])}
- Secret Powers: {', '.join(context['secret_powers'])}
- Proposed Experiments: {', '.join(context['proposed_experiments'])}
- Internal Obstacles: {', '.join(context['internal_obstacles'])}
- External Obstacles: {', '.join(context['external_obstacles'])}

Guidelines:
- Reference their specific context in your responses
- Help them design multiple SMALL experiments (not one big pivot)
- Make experiments concrete, time-bound, and safe-to-try
- Act as a witnessing coach, not an advice-giver"""
    else:
        system_prompt = "You are a career coach. The user has not completed PS101 yet."
    
    # 3. Call LLM with context
    # [existing chat logic continues...]
```

---

## FILES CLAUDE CODE NEEDS

All files are in:
```
~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My Drive/WIMD-Railway-Deploy-Project
```

**Read first:**
1. MOSAIC_HANDOFF_TO_OPUS.md (safety protocols, patterns)
2. WIMD_MVP_Analysis_Complete.md (this Opus analysis)
3. CLAUDE.md (current architecture)
4. TROUBLESHOOTING_CHECKLIST.md (pre-flight checks)

---

## COORDINATION PROTOCOL

### Daily Check-ins
**End of each day, Claude Code should report:**
- What was completed
- What's blocked
- What's next

**You report back here** with updates, I coordinate any issues.

### If Blocked
**Common blockers:**
- API rate limits → Add retry logic
- Database schema missing → Create migration
- Unclear requirements → Ask here for clarification

### Testing Protocol
**Before each deployment:**
- Run local tests first
- Check `/health` endpoint
- Verify PostgreSQL connected (not SQLite fallback)
- Deploy to Railway
- Monitor logs for 5 minutes

---

## TOKEN BUDGET MANAGEMENT

**Current status:** 160K/190K used (84%), 30K remaining

**For this coordination:**
- This document: ~10K tokens
- Future check-ins: ~2-3K tokens each
- Total remaining: ~15K tokens for coordination

**Recommendation:**
- Let Claude Code work independently for Day 1
- Check in tomorrow with progress report
- Use remaining tokens for strategic guidance only

---

## WHAT TO TELL CLAUDE CODE NOW

Copy this to Claude Code in terminal:

```
MISSION: Build WIMD MVP in 3 days based on Opus analysis.

MVP NUCLEUS: PS101 completion → Context extraction → Context-aware coaching

READ FIRST:
1. MOSAIC_HANDOFF_TO_OPUS.md (you created this)
2. WIMD_MVP_Analysis_Complete.md (Opus analysis)
3. CLAUDE.md (current state)

DAY 1 TASKS:
1. Verify PS101 flow saves all 10 responses correctly
2. Build /api/ps101/extract-context endpoint (use Claude API)
3. Test extraction produces structured JSON
4. Store context in database

CRITICAL PATTERNS:
- Use context manager: with get_conn() as conn
- PostgreSQL syntax: %s not ?
- SERIAL not AUTOINCREMENT
- Explicit error logging
- Test locally before deploying

START: Repository audit, then build context extraction.

Report EOD: What worked, what's blocked, what's next.
```

---

**END OF ACTION PLAN**

**Next Steps:**
1. Give this + Opus analysis to Claude Code
2. Let Claude Code work Day 1
3. Check in tomorrow evening with progress
4. Use remaining tokens for strategic coordination only

**Token: 169K/190K (89%), 21K remaining**
