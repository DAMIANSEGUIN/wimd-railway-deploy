# Scripts Directory - AI Agent Session Management

## For AI Agents: Two Scripts You Need to Know

### Session Start (MANDATORY)
```bash
./scripts/status.sh
```

**Run this FIRST when starting any session.** It will show you:
- Current production health (live)
- What's deployed
- Latest instructions (auto-finds most recent file)
- Active warnings
- Exactly what to do next

### Session End (MANDATORY)
```bash
./scripts/session_end.sh
```

**Run this when ending your session.** It will:
- Show what you changed
- Create a descriptive commit message
- Check production health for next agent
- Guide you through committing and pushing

---

## Other Scripts in This Directory

### Deployment Scripts
- **`deploy.sh`** - Deploy to Netlify/Railway (ALWAYS use this, never raw commands)
  - Usage: `./scripts/deploy.sh netlify|railway|all`

- **`push.sh`** - Git push with verification (ALWAYS use this, never raw git push)
  - Usage: `./scripts/push.sh railway-origin main`

### Verification Scripts
- **`verify_critical_features.sh`** - Check that auth, PS101, etc. are present
  - Run before ANY deployment

- **`verify_deployment_improved.sh`** - Check deployed site health
  - Note: Has Playwright bug with hidden elements (use verify_critical_features.sh instead)

### Legacy Scripts
- **`predeploy_sanity.sh`** - Old pre-deployment checks
- **`verify_deploy.sh`** - Old deployment verification
- **`one_shot_new_deploy.sh`** - Create new Railway project
- **`create_handoff_manifest.sh`** - Old handoff system (deprecated)

---

## Quick Reference

**Starting a session:**
```bash
./scripts/status.sh
```

**Ending a session:**
```bash
./scripts/session_end.sh
```

**Before deploying:**
```bash
./scripts/verify_critical_features.sh
./scripts/deploy.sh netlify  # or railway, or all
```

**If stuck:**
```bash
./scripts/status.sh  # Always shows current state
```

---

## For Humans: How This System Works

The new session management system (as of 2025-11-24) replaces the old multi-file documentation approach with two executable scripts:

1. **`status.sh`** - Single source of truth for current state
   - Reads live production health
   - Auto-finds most recent instruction files
   - Shows git status and uncommitted changes
   - Detects warnings (rollbacks, incomplete features, etc.)
   - Provides clear "what to do next" guidance

2. **`session_end.sh`** - Standardized session handoff
   - Creates structured commit messages
   - Records session summary
   - Checks production health for next agent
   - Includes warnings in commit message
   - Makes git history more useful

### Why This Works Better

**Old system problems:**
- ❌ Multiple dated files (which one is current?)
- ❌ Long markdown docs (AI skims and misses things)
- ❌ Static info (gets stale within hours)
- ❌ No enforcement (AI could skip reading)

**New system advantages:**
- ✅ One command per phase (start/end)
- ✅ Always current (reads live system)
- ✅ Can't be skipped (it's the protocol)
- ✅ Clear output (can't be misinterpreted)
- ✅ Works for all AI agents (Gemini, ChatGPT, Claude Code, Cursor)

### File Locations

All AI session documentation is now in:
- `/scripts/status.sh` - Session start (single source of truth)
- `/scripts/session_end.sh` - Session end (structured handoff)
- `/.ai-agents/SESSION_START_PROTOCOL.md` - Full protocol documentation
- `/AI_START_HERE.txt` - Quick start for new AI agents

Legacy documentation (for reference only):
- `/.ai-agents/START_HERE.md` - Old protocol (deprecated)
- `/.ai-agents/*_YYYY-MM-DD.md` - Historical incident reports
- `/CLAUDE.md` - Architecture overview (still valid)

---

## Troubleshooting

**Script not executable:**
```bash
chmod +x scripts/status.sh scripts/session_end.sh
```

**Script not found:**
```bash
# Make sure you're in project root
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project
./scripts/status.sh
```

**Production health check fails:**
- This is intentional - the script will warn you
- Do NOT proceed with changes if production is unhealthy
- Focus on diagnosis and recovery first

**No recent instruction file found:**
- This is normal if no new work has been planned
- Ask the user: "What should I work on?"
- Check legacy docs (CLAUDE.md, AI_START_HERE.txt) for context

---

Last updated: 2025-11-24
System version: 2.0 (script-based)
