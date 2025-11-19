# Handoff to Codex Terminal (CIT) — Model Switch & Role Update

**From:** Claude Code CLI (Sonnet 4.5)
**To:** Codex Terminal (CIT)
**Date:** 2025-11-18T10:00Z
**Purpose:** Model optimization + Role clarification
**Status:** Ready for CIT model switch to Haiku 4.5

---

## Quick Context: What Just Happened

### 1. Role Optimization Approved by CIC ✅

**Problem identified:**
- CIT and Claude Code CLI had overlapping terminal/troubleshooting roles
- Role confusion between two terminal agents

**Solution implemented:**
- **CIT:** Active troubleshooting specialist (fast diagnostics)
- **Claude Code CLI:** Documentation steward + systems verification (thorough review)

**Approval:** CIC reviewed and approved via message 2025-11-18T09:30Z

---

### 2. Model Optimization for Your Role

**Recommendation:** Switch CIT to **Haiku 4.5** for speed advantage

**Why Haiku 4.5 for CIT:**
- Fast iteration for diagnostic loops
- Low latency for troubleshooting
- Cost-efficient for high-frequency operations
- Perfect fit for active debugging role

**Your current model:** (Unknown - check with `/model`)

**Proposed model:** claude-haiku-4-5-20251001

---

### 3. Current Build Status

**Latest Production Deploy:**
- **Date:** 2025-11-18T03:05Z
- **Deploy ID:** `691be4fae7190d5046657c09`
- **Commit:** `31d099cc21a03d221bfb66381a0b8e4445b04efc`
- **Features:** PS101 QA Mode + CodexCapture docs
- **Status:** ✅ LIVE and verified

**Production Tag (pending):**
- Tag name: `prod-2025-11-18`
- Commit: `31d099c`
- **Action needed:** Push tag to origin (see below)

**Latest Backup:**
- `backups/site-backup_20251118_033032Z.zip`

**Health Status:**
- Frontend (Netlify): ✅ Operational
- Backend (Railway): ✅ Operational
- Authentication: ✅ Working
- PS101 flow: ✅ Working
- Chat/Coach: ✅ Working

---

## Your New Role Definition

### Codex Terminal (CIT) - Troubleshooting Specialist

**Model:** Haiku 4.5 (claude-haiku-4-5-20251001)

**Primary Responsibilities:**
- Active debugging and diagnosis during incidents
- Real-time evidence capture (console logs, network traces, screenshots)
- Hands-on problem resolution and fix execution
- Fast iteration diagnostic loops
- Technical investigation of production issues

**Key Strengths (with Haiku 4.5):**
- Low latency for rapid troubleshooting
- Fast responses for quick diagnostic iteration
- Efficient problem isolation

**When you're needed:**
- Production incidents requiring immediate diagnosis
- Active debugging sessions
- Evidence gathering during failures
- Real-time troubleshooting

**Handoff protocol:**
- **To Claude Code CLI:** After fix deployed, pass context for documentation audit
- **To CIC:** Escalate if code changes needed beyond config fixes

---

## How to Start CIT with Haiku 4.5

**IMPORTANT:** You cannot switch AI agents mid-session. CIT must be restarted as a new session.

### Method: Start Fresh CIT Session with Haiku 4.5

**In your terminal (not inside Claude Code):**

```bash
claude --model claude-haiku-4-5-20251001
```

This starts a NEW Codex Terminal session running Haiku 4.5.

**To provide context to the new CIT session:**
- Give CIT this handoff document to read: `.ai-agents/HANDOFF_TO_CIT_MODEL_SWITCH_2025-11-18.md`
- CIT will read it and have full context

---

### Make Haiku 4.5 Default for All Future CIT Sessions (Recommended)

So you don't have to specify `--model` every time:

1. Add this to your shell profile (`~/.zshrc` or `~/.bashrc`):
   ```bash
   export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-haiku-4-5-20251001
   ```

2. Reload shell:
   ```bash
   source ~/.zshrc
   ```

3. All future `claude` commands will use Haiku 4.5 by default

**Test it:**
```bash
claude  # Should now start with Haiku 4.5 automatically
```

---

### What About `/model` Command?

The `/model` command **only switches between models for the SAME AI agent** (e.g., switching one Claude instance from Sonnet to Haiku).

It does **NOT** switch between different AI agent personalities (CIT vs Claude Code CLI).

**Bottom line:** CIT needs a fresh restart to use Haiku 4.5.

---

## Documentation Updates Completed

### Files Updated:
1. ✅ **`.ai-agents/SESSION_START_PROTOCOL.md`**
   - Added Agent Roles section (lines 13-36)
   - Defines CIT, Claude Code CLI, and CIC roles
   - Includes model assignments

2. ✅ **`.ai-agents/AGENT_ROLES.md`** (NEW)
   - Comprehensive role definitions
   - Handoff protocols and triggers
   - Model selection rationale
   - Escalation paths

3. ✅ **`.ai-agents/TEAM_NOTE_ROLE_OPTIMIZATION_2025-11-18.md`**
   - Full proposal with rationale
   - Evidence from recent work
   - CIC approval documented

---

## Pending Actions

### For You (CIT):
1. **Switch to Haiku 4.5** (use method above)
2. **Read updated docs:**
   - `.ai-agents/AGENT_ROLES.md` (your role definition)
   - `.ai-agents/SESSION_START_PROTOCOL.md` (updated with roles)
3. **Acknowledge role update** in session log
4. **Test Haiku 4.5 performance** on next troubleshooting task

### For Team:
1. ⏳ **Push production tag:**
   ```bash
   git tag -a prod-2025-11-18 -m "PS101 QA Mode + CodexCapture docs deployment"
   git push origin prod-2025-11-18
   ```
2. ⏳ **Update COLLABORATION_PROTOCOL.md** with handoff triggers (Claude Code CLI task)

---

## What Claude Code CLI is Now Doing

### Expanded Role: Documentation Steward + Systems Engineer

**Focus areas:**
- Infrastructure verification (health checks, deployment audits)
- Documentation quality enforcement
- Post-deploy reconciliation
- Session protocol maintenance
- Evidence-based doc updates
- Cross-document consistency checks

**Model:** Sonnet 4.5 (leverages natural language strength)

**Recent work example:**
- 2025-11-18: Identified railway-origin deployment ambiguity
- Synchronized 4+ documents (CLAUDE.md, SESSION_START_PROTOCOL.md, etc.)
- Created DEPLOYMENT_AUDIT_CHECKLIST.md
- **Pattern:** Natural language cross-referencing across multiple docs

---

## Current System State

### Repository
- **Branch:** `restore-chat-auth-20251112`
- **Latest commit:** `daf197c` (session end summary)
- **Working tree:** Clean
- **Remote:** origin (wimd-railway-deploy)

### Deployment
- **Frontend:** Netlify (resonant-crostata-90b706)
- **Backend:** Railway (what-is-my-delta-site-production.up.railway.app)
- **Domain:** https://whatismydelta.com ✅

### Critical Scripts
- `./scripts/verify_critical_features.sh` - Pre-deploy checks
- `./scripts/verify_live_deployment.sh` - Post-deploy verification
- `./scripts/deploy.sh netlify` - Frontend deploy
- `./scripts/deploy.sh railway` - Backend deploy

---

## Quick Reference: Your Workflow

### At Session Start:
1. Run session start protocol (`.ai-agents/SESSION_START_PROTOCOL.md`)
2. Check for handoff manifests (`ls -t .ai-agents/handoff_*.json | head -1`)
3. Review latest deploy log (`deploy_logs/2025-11-18_ps101-qa-mode.md`)
4. Verify backup exists for today

### During Troubleshooting:
1. Diagnose issue (fast iteration with Haiku 4.5)
2. Capture evidence (logs, screenshots, traces)
3. Execute fix
4. Verify fix works
5. **Handoff to Claude Code CLI** for documentation

### At Session End:
1. Create handoff manifest if needed
2. Log session activity in `.ai-agents/session_log.txt`
3. Update relevant Stage/Team notes

---

## Documentation to Read First

**Priority 1 (Must Read):**
1. `.ai-agents/AGENT_ROLES.md` - Your role definition
2. `.ai-agents/SESSION_START_PROTOCOL.md` - Updated with roles
3. This handoff document

**Priority 2 (Reference):**
1. `.ai-agents/TEAM_NOTE_ROLE_OPTIMIZATION_2025-11-18.md` - Full rationale
2. `deploy_logs/2025-11-18_ps101-qa-mode.md` - Latest deploy details
3. `.ai-agents/DEPLOYMENT_AUDIT_CHECKLIST.md` - Deploy procedures

---

## Questions or Issues?

**If unclear about role:** Read `.ai-agents/AGENT_ROLES.md` handoff triggers section

**If model switch fails:** Use Option C (fresh start with `--model` flag)

**If need code changes:** Escalate to CIC

**If need doc review:** Handoff to Claude Code CLI

---

## Success Criteria

**You'll know this is working when:**
- ✅ Faster diagnostic iterations (Haiku 4.5 speed)
- ✅ Clear handoff to Claude Code CLI after fixes
- ✅ No role confusion with terminal agents
- ✅ Smooth escalation to CIC when needed

---

## Context Summary for CIT Restart

**In one sentence:**
CIC approved role optimization (2025-11-18) splitting CIT (Haiku 4.5 for fast troubleshooting) from Claude Code CLI (Sonnet 4.5 for documentation steward), latest build is prod-2025-11-18 (PS101 QA Mode) deployed and verified, pending production tag push.

**Key facts:**
- Your role: Active troubleshooting specialist
- Model change: Switch to Haiku 4.5 for speed
- Latest deploy: 2025-11-18 PS101 QA Mode ✅ LIVE
- Documentation: Updated by Claude Code CLI
- Tag pending: `prod-2025-11-18` needs push

---

## Ready to Start?

1. **Switch model** (use method above)
2. **Read AGENT_ROLES.md** (3 min)
3. **Check current system health** (`./scripts/verify_critical_features.sh`)
4. **Acknowledge handoff** in session log
5. **Ready for next troubleshooting task**

---

**Handoff complete. Welcome to optimized CIT role!** 🚀

---

**END OF HANDOFF**

**Prepared by:** Claude Code CLI (Documentation Steward)
**Date:** 2025-11-18T10:05Z
**Status:** Ready for CIT model switch
