# .ai-agents Directory - AI Agent Workspace

**Purpose:** Central hub for AI agent communication, handoffs, session logs, and critical alerts

---

## 🚀 QUICKSTART FOR AI AGENTS

**First time in this project? Read files in this order:**

1. **START_HERE.md** ← Read this FIRST (updated after every major event)
2. **SESSION_START_PROTOCOL.md** ← Mandatory session initialization steps
3. **Latest handoff file** ← Check `ls -t handoff_*.json | head -1`
4. **Latest status file** ← Check `ls -t FINAL_STATUS_* CRITICAL_ISSUE_* | head -1`

---

## 📁 Directory Structure

### Core Files (Always Read)

- **START_HERE.md** - Single source of truth for latest status
- **SESSION_START_PROTOCOL.md** - Mandatory session initialization checklist
- **RESTART_INSTRUCTIONS.md** - Recovery procedures

### Session Management

- **handoff_YYYYMMDD_HHMMSS.json** - Agent-to-agent handoff manifests
- **session_log.txt** - Timestamped session start/end log
- **handoff_log.txt** - Handoff receipt acknowledgments

### Status Reports (Date-Stamped)

- **FINAL_STATUS_YYYY-MM-DD_*.md** - End-of-day status summaries
- **CRITICAL_ISSUE_*.md** - Critical incident documentation
- **SESSION_SUMMARY_YYYY-MM-DD.md** - Daily session summaries
- **DEPLOYMENT_SNAPSHOT_*.md** - Deployment state snapshots

### Team Communication

- **TEAM_NOTE_*.md** - Cross-agent team notifications
- **STAGE*_*.md** - Multi-stage project coordination
- **WELCOME_BACK_MESSAGE.md** - User return notifications

### Captures & Evidence

- **CodexCapture_*/** - Browser DevTools captures (network, console, screenshots)

---

## 🔄 File Lifecycle

### 1. Session Start

```bash
# AI agent starts session
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Session start: [AGENT_NAME]" >> session_log.txt

# Read latest handoff
LATEST_HANDOFF=$(ls -t handoff_*.json 2>/dev/null | head -1)
if [ -n "$LATEST_HANDOFF" ]; then
  cat "$LATEST_HANDOFF"
  echo "[$(date)] Handoff received from: $LATEST_HANDOFF" >> handoff_log.txt
fi
```

### 2. During Session

- Create status files as needed (CRITICAL_ISSUE_*, SESSION_SUMMARY_*)
- Update START_HERE.md if major events occur
- Log significant decisions in session_log.txt

### 3. Session End

```bash
# Create handoff manifest (if requested)
./scripts/create_handoff_manifest.sh > .ai-agents/handoff_$(date +%Y%m%d_%H%M%S).json

# Log session end
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Session end: [AGENT_NAME]" >> session_log.txt
```

---

## 📋 File Naming Conventions

### Status Reports

- **FINAL_STATUS_YYYY-MM-DD_[CONTEXT].md** - End-of-session summaries
  - Example: `FINAL_STATUS_2025-11-21_EVENING.md`

- **CRITICAL_ISSUE_[DESCRIPTION]_YYYY-MM-DD.md** - Incident reports
  - Example: `CRITICAL_ISSUE_PHASE1_BREAKS_UI_2025-11-21.md`

### Session Files

- **SESSION_SUMMARY_YYYY-MM-DD.md** - Daily work summaries
  - Example: `SESSION_SUMMARY_2025-11-13.md`

- **DEPLOYMENT_SNAPSHOT_YYYY-MM-DD.md** - Deployment state
  - Example: `DEPLOYMENT_SNAPSHOT_2025-11-11.md`

### Handoffs

- **handoff_YYYYMMDD_HHMMSS.json** - JSON handoff manifests
  - Example: `handoff_20251121_173338.json`

### Team Notes

- **TEAM_NOTE_[TOPIC]_YYYY-MM-DD.md** - Cross-agent coordination
  - Example: `TEAM_NOTE_PS101_BUILD_CONTINUITY_2025-11-13.md`

---

## 🔍 Finding Information

### Most Recent Status

```bash
# Latest status file
ls -t .ai-agents/FINAL_STATUS_* .ai-agents/CRITICAL_ISSUE_* 2>/dev/null | head -1

# Files from last 24 hours
find .ai-agents -name "*.md" -mtime -1 -exec ls -lht {} \;

# Latest handoff
ls -t .ai-agents/handoff_*.json 2>/dev/null | head -1
```

### Specific Events

```bash
# Files mentioning "Phase 1"
grep -l "Phase 1" .ai-agents/*.md

# Files from specific date
ls -1 .ai-agents/*2025-11-21*

# Recent critical issues
ls -t .ai-agents/CRITICAL_ISSUE_*.md
```

### Session History

```bash
# View session log
cat .ai-agents/session_log.txt

# View handoff log
cat .ai-agents/handoff_log.txt

# Recent sessions
tail -20 .ai-agents/session_log.txt
```

---

## ⚠️ Critical Alerts System

### How to Create Alert

1. Update **START_HERE.md** "Latest Critical Event" section
2. Create **CRITICAL_ISSUE_[NAME]_YYYY-MM-DD.md** with details
3. Add alert to top of **SESSION_START_PROTOCOL.md** (if blocking)
4. Create **TEAM_NOTE** if multiple agents need coordination

### How to Clear Alert

1. Verify issue is resolved
2. Update START_HERE.md status from ⚠️ to ✅
3. Move alert from "Current" to "Resolved" section in SESSION_START_PROTOCOL
4. Document resolution in FINAL_STATUS or SESSION_SUMMARY

---

## 📊 Health Check

**This directory is healthy if:**

- ✅ START_HERE.md updated within last 3 days
- ✅ Latest handoff file exists (if multi-agent session)
- ✅ session_log.txt has recent entries
- ✅ No CRITICAL_ISSUE files with unresolved status

**This directory needs attention if:**

- ❌ START_HERE.md >7 days old
- ❌ Multiple conflicting status files
- ❌ Critical issues with no resolution documented
- ❌ Handoff files missing for multi-session work

---

## 🤝 Multi-Agent Coordination

### Handoff Protocol

**Outgoing agent:**

```bash
# Create handoff manifest
./scripts/create_handoff_manifest.sh > .ai-agents/handoff_$(date +%Y%m%d_%H%M%S).json

# Update START_HERE.md with latest status
# Document any WIP or blockers
```

**Incoming agent:**

```bash
# Read latest handoff
cat $(ls -t .ai-agents/handoff_*.json | head -1)

# Acknowledge handoff
echo "[$(date)] Received handoff from [AGENT]" >> .ai-agents/handoff_log.txt

# Read START_HERE.md for latest context
```

### Team Notes

Create TEAM_NOTE when:

- Multiple agents working on same feature
- Cross-agent coordination needed
- Critical information affects all agents
- Shared decision needs tracking

Format:

```markdown
# TEAM_NOTE_[TOPIC]_YYYY-MM-DD.md

**For:** [Agent names or ALL]
**Priority:** [HIGH/MEDIUM/LOW]
**Context:** [Brief description]

## Information
[Details here]

## Actions Required
- [ ] Agent 1: [Task]
- [ ] Agent 2: [Task]

## Acknowledgments
- Agent 1: ✅ Read [timestamp]
- Agent 2: ⏳ Pending
```

---

## 🧹 Maintenance

### Weekly Cleanup

```bash
# Archive files older than 30 days
find .ai-agents -name "*.md" -mtime +30 -exec mv {} .ai-agents/archive/ \;

# Keep last 10 handoffs, archive rest
ls -t .ai-agents/handoff_*.json | tail -n +11 | xargs -I {} mv {} .ai-agents/archive/
```

### Monthly Review

- Verify START_HERE.md is current
- Clear resolved alerts from SESSION_START_PROTOCOL
- Archive CodexCapture folders >30 days
- Compress session_log.txt if >1MB

---

## 📖 Reference Documents

**In Parent Directory:**

- `../CLAUDE.md` - Architecture and feature status
- `../TROUBLESHOOTING_CHECKLIST.md` - Pre-flight checks
- `../SELF_DIAGNOSTIC_FRAMEWORK.md` - Error handling patterns
- `../README.md` - Restart protocol and environment setup

**In This Directory:**

- `START_HERE.md` - Latest status and onboarding
- `SESSION_START_PROTOCOL.md` - Mandatory session checklist
- `RESTART_INSTRUCTIONS.md` - Recovery procedures

---

## 🎯 Success Metrics

**This system is working if:**

- ✅ New AI agents can start productive work in <5 minutes
- ✅ No repeated questions about project history
- ✅ Critical information surfaces automatically
- ✅ Agent handoffs happen smoothly
- ✅ Incidents are documented and don't repeat

**This system needs improvement if:**

- ❌ AI agents ask "where do I start?"
- ❌ Same incidents happen repeatedly
- ❌ Handoffs missing critical context
- ❌ Files >7 days old with no updates
- ❌ User has to explain project every session

---

**Last Updated:** 2025-11-23
**Maintained By:** All AI agents (update as needed)
