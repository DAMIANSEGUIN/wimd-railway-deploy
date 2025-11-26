# AI Agent Context System - How It Works

**Created:** 2025-11-23
**Purpose:** Solve the "AI can't find latest info" problem

---

## The Problem We're Solving

**Before this system:**
- AI agents ask "where should I start?" every session
- User has to explain project history repeatedly
- Important context buried in old files
- No single source of truth for "what happened last?"
- Documentation gets stale and misleading

**After this system:**
- AI runs ONE command → gets complete context in <3 minutes
- Latest status always in predictable location
- Automatic discovery of recent files
- Self-updating documentation
- Clear reading order

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  AI AGENT STARTS SESSION                                    │
└────────────────┬────────────────────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: Run Discovery Script                              │
│  $ ./scripts/show_latest_context.sh                        │
│                                                              │
│  Output:                                                     │
│  • Latest START_HERE.md (with freshness check)             │
│  • Latest status files (last 5, with dates)                │
│  • Latest handoff (if exists)                              │
│  • Recent git commits (last 5)                             │
│  • Urgent files (if any)                                   │
│  • System health (Railway + domain)                        │
│  • Recommended reading order                               │
└────────────────┬────────────────────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: Read Files in Order                               │
│                                                              │
│  1. .ai-agents/START_HERE.md                               │
│     ├─ Latest critical event                               │
│     ├─ Current system status                               │
│     ├─ Links to relevant docs                              │
│     └─ Critical warnings                                   │
│                                                              │
│  2. .ai-agents/SESSION_START_PROTOCOL.md                   │
│     ├─ Mandatory verification steps                        │
│     ├─ Operating rules                                     │
│     └─ Emergency procedures                                │
│                                                              │
│  3. Latest status file (from script output)                │
│     ├─ FINAL_STATUS_YYYY-MM-DD_CONTEXT.md                 │
│     ├─ CRITICAL_ISSUE_NAME_YYYY-MM-DD.md                  │
│     └─ SESSION_SUMMARY_YYYY-MM-DD.md                      │
│                                                              │
│  4. Latest handoff (if exists)                             │
│     └─ handoff_YYYYMMDD_HHMMSS.json                       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: Run Verification                                  │
│  $ ./scripts/verify_critical_features.sh                   │
│                                                              │
│  Checks:                                                     │
│  ✅ Authentication UI present                              │
│  ✅ PS101 flow present                                     │
│  ✅ API_BASE configured                                    │
│  ✅ Build ID alignment                                     │
└────────────────┬────────────────────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────────────────────┐
│  READY TO WORK                                              │
│  • Full context loaded                                      │
│  • System verified                                          │
│  • Critical alerts acknowledged                             │
│  • Ready for user instructions                              │
└─────────────────────────────────────────────────────────────┘
```

---

## File Roles & Responsibilities

### Core Files (in .ai-agents/)

| File | Role | Updated When | Read When |
|------|------|--------------|-----------|
| **START_HERE.md** | Single source of truth for latest status | After major events, every 3 days minimum | Every session start (FIRST) |
| **SESSION_START_PROTOCOL.md** | Mandatory checklist for session init | When process changes, critical alerts | Every session start (SECOND) |
| **README.md** | Directory guide and file conventions | When structure changes | When confused about .ai-agents/ |
| **RESTART_INSTRUCTIONS.md** | Recovery procedures | When recovery process changes | When system broken |

### Status Files (dated, in .ai-agents/)

| Pattern | Purpose | Created When |
|---------|---------|--------------|
| `FINAL_STATUS_YYYY-MM-DD_CONTEXT.md` | End-of-session summary | Session ends after major work |
| `CRITICAL_ISSUE_NAME_YYYY-MM-DD.md` | Incident documentation | Critical failure occurs |
| `SESSION_SUMMARY_YYYY-MM-DD.md` | Daily work log | Daily session activity |
| `DEPLOYMENT_SNAPSHOT_YYYY-MM-DD.md` | Deployment state capture | After deployments |

### Handoff Files (timestamped, in .ai-agents/)

| Pattern | Purpose | Created When |
|---------|---------|--------------|
| `handoff_YYYYMMDD_HHMMSS.json` | Agent-to-agent transition | Session ends with handoff request |

### Scripts (in scripts/)

| Script | Purpose |
|--------|---------|
| `show_latest_context.sh` | Automatic discovery of latest files |
| `verify_critical_features.sh` | Pre/post deployment verification |
| `create_handoff_manifest.sh` | Generate handoff JSON |

---

## Update Protocol

### When START_HERE.md MUST be updated:

1. **After critical incidents**
   - Production down
   - Emergency rollback
   - Feature removal
   - Data loss
   - Security issue

2. **After major milestones**
   - Phase completion
   - Major feature deployment
   - Architecture changes
   - New agent onboarding

3. **Scheduled maintenance**
   - File >3 days old
   - Beginning of new work sprint
   - After user reports "AI confused"

### How to update START_HERE.md:

```markdown
# Update these sections:

1. "Last Updated" timestamp at top
2. "Latest Critical Event" - what happened most recently
3. "Read These Files IN ORDER" - update links to latest files
4. "Current State" bullets - what's working/broken now
5. Add new warnings in "Critical Warnings" if needed
```

### Commit message format:
```bash
git commit -m "Update START_HERE.md - [brief event description]"

# Examples:
# "Update START_HERE.md - Phase 1 rollback complete"
# "Update START_HERE.md - Deployment successful"
# "Update START_HERE.md - Weekly refresh"
```

---

## Discovery Logic

### How `show_latest_context.sh` works:

```bash
# 1. Check START_HERE.md exists and show age
ls -la .ai-agents/START_HERE.md
# Warn if >3 days old

# 2. Find latest status files
find .ai-agents -name "FINAL_STATUS_*.md" -o -name "CRITICAL_ISSUE_*.md" | xargs ls -t | head -5
# Show most recent 5 files with dates

# 3. Find latest handoff
ls -t .ai-agents/handoff_*.json | head -1
# Show most recent handoff file

# 4. Show recent git activity
git log -5 --oneline
# Last 5 commits for context

# 5. Check for urgent files
ls -1 URGENT_* FOR_*_AGENT*.md 2>/dev/null
# Files that need immediate attention

# 6. Health check
curl -s https://whatismydelta.com/health
# Quick system status
```

**Result:** AI agent gets complete picture in one command.

---

## Success Metrics

### This system is working if:

✅ **AI Productivity**
- New AI session productive in <5 minutes
- No "where do I start?" questions
- Finds critical context automatically
- Reads correct files in correct order

✅ **Information Quality**
- START_HERE.md updated within 3 days
- Status files match reality
- Links point to existing files
- No conflicting information

✅ **User Experience**
- Doesn't have to explain project history
- Can paste one command to onboard AI
- Trusts AI has full context
- Documentation stays current

### This system needs improvement if:

❌ **AI Confusion**
- Repeated questions about project state
- Reading outdated documentation
- Can't find latest incident reports
- Asks about resolved issues

❌ **Staleness**
- START_HERE.md >7 days old
- Status files don't reflect current state
- Broken links to moved/deleted files
- Git history contradicts docs

❌ **User Friction**
- Has to manually guide AI to files
- Explains same context every session
- AI misses critical recent events
- Documentation conflicts cause delays

---

## Comparison: Before vs After

### Before This System

```
User: "Help me with the deployment"

AI: "Sure! Where should I start? What's the current status?"

User: "Read CLAUDE.md"

AI: [reads CLAUDE.md from Oct 7]
     "I see the last update was October 7. Has anything changed since?"

User: "Yes, we had a rollback on November 21. Read that file."

AI: "Which file? I see several..."

User: "The FINAL_STATUS one from Nov 21"

AI: [reads file]
     "Okay, I understand now. What about the current state?"

User: [explains current state manually]

⏱️ TIME TO PRODUCTIVE: 10-15 minutes
😤 USER EFFORT: High
📚 CONTEXT QUALITY: Medium (might miss files)
```

### After This System

```
User: [Pastes from COPY_PASTE_FOR_AI.txt]
      "cd /Users/.../WIMD-Railway-Deploy-Project && ./scripts/show_latest_context.sh"

AI: [runs script, sees output]
    "I can see:
     - START_HERE.md updated Nov 23
     - Latest critical event: Phase 1 rollback (Nov 21)
     - Status: ✅ STABLE
     - Latest incident: FINAL_STATUS_2025-11-21_EVENING.md

     Reading START_HERE.md now..."

AI: [reads 4 files in order]
    "✅ Context loaded. I understand:
     - Website is working (rollback complete)
     - Phase 1 work saved in branch 'phase1-incomplete'
     - DO NOT deploy Phase 1 without integration

     Running verification..."

AI: [runs verification script]
    "✅ All critical features verified. Ready to help with deployment."

⏱️ TIME TO PRODUCTIVE: 2-3 minutes
😊 USER EFFORT: Minimal (one paste)
📚 CONTEXT QUALITY: High (finds all files automatically)
```

---

## Maintenance

### Weekly Tasks
```bash
# Check if START_HERE.md needs update
ls -l .ai-agents/START_HERE.md
# If >7 days old, update it

# Archive old status files (>30 days)
find .ai-agents -name "*.md" -mtime +30 -exec mv {} .ai-agents/archive/ \;

# Keep last 10 handoffs, archive rest
ls -t .ai-agents/handoff_*.json | tail -n +11 | xargs -I {} mv {} .ai-agents/archive/
```

### Monthly Tasks
```bash
# Review and clean up
- Remove resolved alerts from SESSION_START_PROTOCOL.md
- Archive CodexCapture folders >30 days
- Verify all links in START_HERE.md still work
- Update documentation if patterns change
```

---

## Troubleshooting

### "Script not found"
```bash
# Make sure you're in project root
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project

# Make script executable if needed
chmod +x ./scripts/show_latest_context.sh
```

### "START_HERE.md outdated"
```bash
# AI agent should update it:
# 1. Read recent files to understand current state
# 2. Update START_HERE.md with latest info
# 3. Commit: git commit -m "Update START_HERE.md - [reason]"
```

### "Conflicting information"
```bash
# Newest file wins:
# 1. Check dates: ls -lt .ai-agents/*.md
# 2. Read most recent file
# 3. Update START_HERE.md to match
# 4. Mark old info as outdated in old file
```

### "User says file is wrong"
```bash
# User is always right:
# 1. Ask: "Should I update START_HERE.md with current info?"
# 2. Get user's latest status
# 3. Update START_HERE.md
# 4. Commit update
```

---

## Key Design Principles

### 1. Single Command Discovery
**Why:** AI shouldn't hunt for files
**How:** `show_latest_context.sh` finds everything automatically

### 2. Predictable Locations
**Why:** Consistency reduces confusion
**How:** All agent files in `.ai-agents/`, all scripts in `scripts/`

### 3. Date-Based Freshness
**Why:** Recent files more likely correct
**How:** Filenames include dates, scripts sort by modification time

### 4. Self-Updating Documentation
**Why:** Outdated docs worse than no docs
**How:** Agents required to update START_HERE.md after major events

### 5. Fail-Fast Verification
**Why:** Catch problems before they spread
**How:** Verification scripts run before any deployment

### 6. Clear Reading Order
**Why:** Context builds on context
**How:** Numbered reading order in all onboarding docs

---

## Evolution & Improvements

### Future Enhancements

1. **Automated Staleness Detection**
   ```bash
   # Script runs daily, alerts if START_HERE.md >7 days old
   # Could integrate with git hooks
   ```

2. **Smart File Recommendations**
   ```bash
   # AI detects user intent, recommends specific files
   # "You mentioned deployment → read DEPLOYMENT_SNAPSHOT_2025-11-21.md"
   ```

3. **Interactive Onboarding**
   ```bash
   # Script asks questions, customizes reading list
   # "What are you working on? [deployment/bugfix/feature]"
   ```

4. **Health Dashboard**
   ```bash
   # Visual status of documentation freshness
   # Color-coded file ages, broken link detection
   ```

5. **Auto-Generate Summaries**
   ```bash
   # AI summarizes git commits → updates START_HERE.md
   # Reduces manual update burden
   ```

---

## Success Stories

### Problem Solved: AI Can't Find Latest Context
**Before:** AI reads CLAUDE_CODE_README.md from Sept 29, thinks there are unresolved CORS issues
**After:** AI runs script, sees Nov 21 rollback, reads correct status file, understands current state

### Problem Solved: User Repeats History Every Session
**Before:** User explains "Phase 1 was rolled back" every new AI session
**After:** User pastes one command, AI reads START_HERE.md, already knows about rollback

### Problem Solved: Documentation Gets Stale
**Before:** Multiple README files with contradictory information
**After:** START_HERE.md is single source of truth, updated after every major event

---

**Last Updated:** 2025-11-23 by Claude Code
**Maintained By:** All AI agents (update when system changes)
