# AI Agent Session Start Protocol

**MANDATORY: Every AI agent MUST run this at session start**

---

## 🎯 THE ONE COMMAND YOU MUST RUN FIRST

**DO THIS NOW - BEFORE ANYTHING ELSE:**

```bash
./scripts/status.sh
```

**This single command will tell you:**
- ✅ Current production health (live check)
- ✅ What's deployed (git status)
- ✅ Latest instructions (auto-finds most recent file)
- ✅ Active warnings and blockers
- ✅ Exactly what to do next

**After running status.sh, follow the "WHAT TO DO NEXT" section in its output.**

---

## Step-by-Step Protocol (Simplified)

### Step 1: Identify Yourself & Run Status

```
I am [AGENT_NAME] starting session at [TIMESTAMP]

Running session start protocol...
```

Then immediately run:
```bash
./scripts/status.sh
```

### Step 2: Follow Status Script Output

The status script will tell you:

1. **If production is unhealthy** → STOP and fix that first
2. **If there's a recent instruction file** → Read it and follow it
3. **If no clear instructions** → Ask user what to work on

### Step 3: Verify Critical Features (If Making Changes)

Before making ANY code changes or deployments:

```bash
./scripts/verify_critical_features.sh
```

**If verification FAILS:**
- ❌ STOP immediately
- Report to user: "Critical feature missing - verification failed"
- Wait for user to resolve

---

## Operating Rules (Always Follow These)

**Throughout this session, I will:**

1. ✅ Run `./scripts/status.sh` at session start (MANDATORY)
2. ✅ Run `./scripts/verify_critical_features.sh` BEFORE any deployment
3. ✅ Never remove authentication without explicit approval
4. ✅ Never replace files without checking for feature loss
5. ✅ **NEVER use raw `git push` or `netlify deploy` commands - use wrapper scripts:**
   - Use `./scripts/push.sh railway-origin main` instead of `git push railway-origin main`
   - Use `./scripts/deploy.sh netlify` instead of `netlify deploy --prod`
   - Use `./scripts/deploy.sh railway` to deploy backend
   - Use `./scripts/deploy.sh all` to deploy both frontend and backend

**If production is unhealthy:**
- ❌ DO NOT make any changes
- ❌ DO NOT deploy anything
- ✅ Focus on diagnosis and recovery only

---

## Quick Reference Card

**Session Start (DO THIS EVERY TIME):**
```
□ Run ./scripts/status.sh
□ Read the instruction file it shows (if any)
□ Follow the "WHAT TO DO NEXT" section
□ If unclear, ask user
```

**Before Every Deployment:**
```
□ Run ./scripts/verify_critical_features.sh
□ Use wrapper scripts (./scripts/deploy.sh)
□ Monitor post-deploy for 5 minutes
```

**If Things Go Wrong:**
```
□ Run ./scripts/status.sh to check current state
□ Check production health first
□ Look for recent rollback/revert in git log
□ Read incident files in .ai-agents/
```

---

## Emergency Override

**Only use with explicit user approval:**

If user says "EMERGENCY OVERRIDE: [reason]", I may bypass verification ONCE, but must:
1. Document override reason in commit message
2. Add tag: [EMERGENCY-OVERRIDE]
3. Run full verification immediately after override action
4. Create recovery plan if verification fails

---

## Why This New System Exists

**Previous system problems:**
- ❌ Too many documentation files (which one is current?)
- ❌ Files with dates in names (confusing timeline)
- ❌ Long protocols AI agents skip/skim
- ❌ Static info that gets stale

**New system benefits:**
- ✅ ONE command: `./scripts/status.sh`
- ✅ Always current (reads live system)
- ✅ Auto-finds latest instructions
- ✅ Clear output (can't be misinterpreted)
- ✅ Works for all AI agents (Gemini, ChatGPT, Claude Code, Cursor)

---

## Session End Protocol

**When ending your session, run this ONE command:**

```bash
./scripts/session_end.sh
```

**This script will:**
- ✅ Show what you changed this session
- ✅ Create a descriptive commit message
- ✅ Check production health for the next agent
- ✅ Add warnings if any exist
- ✅ Guide you through committing and pushing

**Manual alternative (if script doesn't work):**
1. Commit changes: `git add -A && git commit -m "Session: [summary]"`
2. Run status check: `./scripts/status.sh`
3. Push if appropriate: `git push origin main`

---

## Legacy Information (For Reference Only)

The following files contain historical context but are **NOT** required reading at session start:

- `AI_START_HERE.txt` - Static overview (may be outdated)
- `.ai-agents/START_HERE.md` - Previous protocol (deprecated)
- Dated files in `.ai-agents/` - Historical incident reports

**Instead:** Just run `./scripts/status.sh` - it will find and show the most recent relevant files automatically.

---

**END OF SESSION START PROTOCOL**
