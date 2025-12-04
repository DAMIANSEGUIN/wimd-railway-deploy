# MOSAIC MVP Implementation - Documentation Package for Gemini Review

**Date:** December 2, 2025
**Purpose:** Complete documentation package for Gemini to review the Mosaic MVP rewrite plan

---

## Overview

This folder contains the complete implementation plan for rewriting the Mosaic platform into a focused MVP:

**MVP Nucleus:** PS101 completion → Context extraction → Context-aware coaching → Experiment design

**Timeline:** 3-day sprint to shippable MVP

**Goal:** Transform generic career coaching into personalized coaching that references the user's specific situation from their PS101 self-reflection.

---

## Documents in This Package

### 1. **IMPLEMENTATION_REFINEMENT_Claude-Gemini.md** ⭐ **START HERE**
**What it is:** Comprehensive synthesis of Claude Code + Gemini collaborative review
**Contains:**
- Gemini's complete review findings (architecture, code, risks)
- Claude's technical analysis (database gaps, current state)
- Answered questions vs outstanding decisions needed
- Refined 3-day implementation plan with Gemini's enhancements
- Risk mitigation strategies
- Pre-implementation checklist
- Outstanding blocking questions (6 critical decisions needed)

**Read this FIRST** - This is the living implementation plan after Gemini's review.

---

### 2. MOSAIC_COMPLETE_HANDOFF.md (1,241 lines)
**What it is:** Complete self-contained handoff document with zero external dependencies
**Contains:**
- Full architecture overview (FastAPI backend, Vanilla JS frontend, PostgreSQL database)
- All critical code patterns with examples (context manager, PostgreSQL syntax, error handling)
- Complete API endpoint documentation (40+ endpoints)
- Testing protocols and checklists
- Error classification dashboard
- Emergency procedures
- Current production state

**Read this second** - It's the foundation that explains what exists today.

---

### 3. WIMD_MVP_Analysis_Complete.md (530 lines)
**What it is:** Opus 4.5's comprehensive 6-phase MVP analysis
**Contains:**
- User purpose analysis (why generic coaching fails)
- Phase-by-phase evaluation of current 7-phase plan
- The "Aha" moment: AI already knows user context from PS101
- MVP nucleus definition (4 irreducible components)
- What to defer post-MVP (full prompt library, experiment tracking, resume rewriting, job search)
- Architectural gaps (context extraction, context injection, completion gate)
- 3-day build sequence with time blocks
- Success criteria (70%+ personalization, 70%+ experiments)
- Risk assessment and mitigation

**Read this second** - It explains WHY we're rewriting and WHAT the MVP should be.

---

### 4. MOSAIC_IMMEDIATE_ACTION_PLAN.md (429 lines)
**What it is:** Tactical 3-day sprint plan for Claude Code (ORIGINAL - see Refinement doc for UPDATED plan)
**Contains:**
- Executive summary of MVP nucleus
- What Opus determined (keep/defer decisions)
- What Claude Code knows (current working state)
- Immediate actions (coordination protocol)
- Detailed 3-day plan with hour-by-hour breakdown
- Success criteria checklist
- Technical implementation code examples
- Files Claude Code needs to read
- Token budget management

**Note:** This is the original plan from Opus. The **IMPLEMENTATION_REFINEMENT** document contains the updated plan after Gemini's review.

---

### 5. mosaic_context_bridge.py (282 lines)
**What it is:** Production-ready Python implementation
**Contains:**
- `extract_ps101_context()` - Transforms PS101 responses into structured JSON using Claude API
- `build_coaching_system_prompt()` - Injects context into coaching system prompt
- Complete extraction prompt with rules
- Fallback prompt for pre-PS101 users
- FastAPI integration examples
- Test harness with sample PS101 responses

**This is executable code** - Copy/paste ready for implementation.

---

## The Big Picture

### Current State (What Works)
✅ Authentication (login/register/password reset)
✅ PS101 flow (10 questions exist)
✅ Chat interface (functional)
✅ PostgreSQL database (connected on Railway)
✅ Backend API deployed (Railway)
✅ Frontend deployed (Netlify)

### The Gap (What's Missing)
❌ Context extraction from PS101 responses
❌ Context injection into coaching system prompt
❌ PS101 completion gate (can't chat until PS101 done)
❌ Experiment-focused coaching refinement

### The Solution (3-Day Sprint)

**Day 1: Context Extraction Foundation**
- Verify PS101 data persistence
- Build `/api/ps101/extract-context` endpoint
- Use Claude API to extract structured context:
  - `problem_definition` (string)
  - `passions` (array)
  - `skills` (array)
  - `secret_powers` (array)
  - `proposed_experiments` (array with smallest_version)
  - `internal_obstacles` (array)
  - `external_obstacles` (array)
  - `key_quotes` (array)
- Test extraction produces valid JSON
- Store context in database

**Day 2: Context Injection + Completion Flow**
- Modify `/api/chat/message` to fetch user context
- Inject context into system prompt
- Add PS101 completion gate (redirect to PS101 if incomplete)
- Create transition screen: "PS101 Complete → Begin Coaching"
- End-to-end test with 3 sample users

**Day 3: Experiment Focus + Beta Launch**
- Refine system prompt to emphasize experiment design
- Add simple feedback collection (personalization?, concrete experiment?)
- Beta user outreach (10-15 users)
- Update landing page messaging

---

## Key Technical Patterns (Critical)

### 1. Database Context Manager Pattern
```python
# ✅ CORRECT
with get_conn() as conn:
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    result = cursor.fetchone()

# ❌ WRONG (causes AttributeError)
conn = get_conn()
cursor = conn.execute(...)  # CRASHES
```

### 2. PostgreSQL Syntax (NOT SQLite)
```python
# ✅ Use %s placeholders
cursor.execute("INSERT INTO users VALUES (%s, %s)", (val1, val2))

# ✅ Use SERIAL for auto-increment
CREATE TABLE users (id SERIAL PRIMARY KEY, ...)

# ❌ Don't use ? placeholders (that's SQLite)
# ❌ Don't use AUTOINCREMENT (that's SQLite)
```

### 3. Idempotent Operations
```python
cursor.execute("""
    INSERT INTO user_contexts (user_id, context_data, extracted_at)
    VALUES (%s, %s, NOW())
    ON CONFLICT (user_id) DO UPDATE SET context_data = %s, extracted_at = NOW()
""", (user_id, json.dumps(context), json.dumps(context)))
```

---

## Success Criteria

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

## What to Review (Gemini's Tasks)

1. **Architectural Soundness**
   - Does the 3-day plan make sense given current infrastructure?
   - Are there architectural risks not addressed?
   - Is the context extraction approach sound?

2. **Implementation Completeness**
   - Does `mosaic_context_bridge.py` cover all needed functionality?
   - Are the code examples in MOSAIC_IMMEDIATE_ACTION_PLAN.md correct?
   - Are there missing components?

3. **Safety & Rollback**
   - Is there a clear rollback path if things go wrong?
   - Are the safety protocols adequate?
   - What's the backup strategy?

4. **Success Metrics**
   - Are the 70%+ thresholds realistic?
   - Are we measuring the right things?
   - What's missing from validation?

5. **Timeline Feasibility**
   - Is 3 days realistic for Claude Code?
   - Which day has the highest risk?
   - What could cause delays?

---

## Questions for Gemini

1. **Scope Validation:** Does the MVP nucleus feel right? Are we cutting too much or too little?

2. **Technical Review:** Any red flags in the `mosaic_context_bridge.py` implementation?

3. **Risk Assessment:** What's the biggest risk to the 3-day timeline?

4. **Database Schema:** Do we need to create new tables (e.g., `user_contexts`, `ps101_responses`)? Are they defined anywhere?

5. **Testing Strategy:** Is the golden dataset approach sufficient for validation?

6. **Backup Strategy:** What's the recommended approach to ensure we can rollback safely?

7. **Coordination:** How should Claude Code and Gemini coordinate during the 3-day sprint?

---

## Next Steps After Review

1. Gemini provides feedback on this plan
2. Address any concerns or gaps identified
3. Create safe backup of current codebase
4. Claude Code begins Day 1 implementation
5. Daily check-ins for coordination
6. Beta launch at end of Day 3

---

## File Locations

**All files in this folder:**
```
~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My Drive/MOSAIC_MVP_IMPLEMENTATION/

├── README_FOR_GEMINI.md (this file)
├── MOSAIC_COMPLETE_HANDOFF.md (foundation)
├── WIMD_MVP_Analysis_Complete.md (strategy)
├── MOSAIC_IMMEDIATE_ACTION_PLAN.md (tactics)
└── mosaic_context_bridge.py (code)
```

**Production codebase:**
```
~/Library/CloudStorage/GoogleDrive-damian.seguin@gmail.com/My Drive/WIMD-Railway-Deploy-Project/
```

---

**Ready for Gemini review. Awaiting feedback before Claude Code begins implementation.**
