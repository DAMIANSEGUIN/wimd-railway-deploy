# Handoff to Codex Terminal (CIT) — Model Update & Role Clarification

**From:** Claude Code CLI (Sonnet 4.5)
**To:** Codex Terminal (CIT) - GPT-5.1-Codex-Mini
**Date:** 2025-11-18T10:30Z
**Purpose:** Model upgrade + Role clarification
**Status:** Ready for CIT restart with GPT-5.1-Codex-Mini

---

## Quick Context: What Just Happened

### 1. Role Optimization Approved by CIC ✅

**Problem identified:**
- CIT and Claude Code CLI had overlapping terminal/troubleshooting roles
- Role confusion between two terminal agents

**Solution implemented:**
- **CIT (you):** Active troubleshooting specialist - GPT-based fast diagnostics
- **Claude Code CLI:** Documentation steward + systems verification - Claude-based thorough review

**Approval:** CIC reviewed and approved via message 2025-11-18T09:30Z

**Key insight:** Keep AI system diversity (GPT vs Claude) for complementary strengths

---

### 2. Model Upgrade for Your Role

**Your new model:** **GPT-5.1-Codex-Mini**

**Why GPT-5.1-Codex-Mini for CIT:**
- Latest OpenAI model (released Nov 2025)
- Optimized for agentic coding tasks
- 4x more usage than full GPT-5.1-Codex (cost-efficient)
- Fast iteration for diagnostic loops
- Perfect for active troubleshooting role

**How to start with this model:**
```bash
codex --model gpt-5.1-codex-mini
```

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

## Your Role Definition

### Codex Terminal (CIT) - Active Troubleshooting Specialist

**Model:** GPT-5.1-Codex-Mini (OpenAI)

**Primary Responsibilities:**
- Active debugging and diagnosis during production incidents
- Real-time evidence capture (console logs, network traces, screenshots)
- Hands-on problem resolution and fix execution
- Fast iteration diagnostic loops
- Technical investigation of live issues
- Emergency response and rapid troubleshooting

**Key Strengths (with GPT-5.1-Codex-Mini):**
- Fast agentic coding for troubleshooting
- Cost-efficient high-frequency operations
- Rapid problem isolation and fixes
- 4x more usage capacity for extended sessions

**When you're needed:**
- Production incidents requiring immediate diagnosis
- Active debugging sessions
- Evidence gathering during failures
- Real-time troubleshooting
- Emergency response situations

**Handoff protocol:**
- **To Claude Code CLI:** After fix deployed, pass context for documentation audit
- **To CIC:** Escalate if code changes needed beyond config/hotfixes

---

## Your Counterpart: Claude Code CLI

**Model:** Sonnet 4.5 (Anthropic Claude)

**Role:** Documentation Steward + Systems Engineer

**Focus:**
- Post-deploy verification and audits
- Documentation quality enforcement
- Cross-document consistency checks
- Session protocol maintenance
- Natural language polish for handoffs
- Infrastructure verification

**Why two different AI systems:**
- GPT (you) = Fast, agentic troubleshooting approach
- Claude = Thorough, natural language documentation
- **Complementary strengths, not overlap**

---

## How to Start with GPT-5.1-Codex-Mini

### Step 1: Start Codex with New Model

**In your regular terminal (zsh):**
```bash
codex --model gpt-5.1-codex-mini
```

This starts Codex Terminal with GPT-5.1-Codex-Mini.

---

### Step 2: Provide Context to New Session

When Codex starts, give it this handoff document:

**Say to Codex:**
```
Read this handoff document: .ai-agents/HANDOFF_TO_CIT_GPT51_CODEX_MINI_2025-11-18.md
```

---

### Step 3: Verify Model

**Ask Codex:**
```
What model are you running?
```

**Expected response:**
- Should confirm GPT-5.1-Codex-Mini

---

### Optional: Make GPT-5.1-Codex-Mini Default

To avoid specifying `--model` every time:

1. **Create config file:**
```bash
mkdir -p ~/.config/codex
nano ~/.config/codex/config.toml
```

2. **Add this line:**
```toml
model = "gpt-5.1-codex-mini"
```

3. **Save and exit** (Ctrl+X, then Y, then Enter)

4. **Test default:**
```bash
codex  # Should start with gpt-5.1-codex-mini automatically
```

---

## Documentation Updates Completed

### Files Updated by Claude Code CLI:

1. ✅ **`.ai-agents/SESSION_START_PROTOCOL.md`**
   - Added Agent Roles section (lines 13-36)
   - Defines CIT (GPT-based), Claude Code CLI (Claude-based), and CIC roles

2. ✅ **`.ai-agents/AGENT_ROLES.md`** (NEW)
   - Comprehensive role definitions
   - Handoff protocols and triggers
   - Model selection rationale
   - Escalation paths

3. ✅ **`.ai-agents/TEAM_NOTE_ROLE_OPTIMIZATION_2025-11-18.md`**
   - Full proposal with rationale
   - Evidence from recent work
   - CIC approval documented

**Note:** These docs reference the role split but not specific GPT model (you're the first to use GPT-5.1-Codex-Mini in CIT role)

---

## Pending Actions

### For You (CIT):
1. **Start with GPT-5.1-Codex-Mini** (command above)
2. **Read updated docs:**
   - `.ai-agents/AGENT_ROLES.md` (your role definition)
   - `.ai-agents/SESSION_START_PROTOCOL.md` (updated with roles)
   - This handoff document (you're reading it now)
3. **Acknowledge role update** in session log
4. **Test GPT-5.1-Codex-Mini** on next troubleshooting task

### For Team:
1. ⏳ **Push production tag:**
   ```bash
   git tag -a prod-2025-11-18 -m "PS101 QA Mode + CodexCapture docs deployment"
   git push origin prod-2025-11-18
   ```
2. ⏳ **Update COLLABORATION_PROTOCOL.md** with handoff triggers (Claude Code CLI task)

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
1. Diagnose issue (fast iteration with GPT-5.1-Codex-Mini)
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

**If model switch fails:** Check Codex CLI installation or API access

**If need code changes:** Escalate to CIC

**If need doc review:** Handoff to Claude Code CLI

---

## Success Criteria

**You'll know this is working when:**
- ✅ Faster diagnostic iterations (GPT-5.1-Codex-Mini speed)
- ✅ Clear handoff to Claude Code CLI after fixes
- ✅ No role confusion with terminal agents
- ✅ Smooth escalation to CIC when needed
- ✅ Extended session capacity (4x usage vs full GPT-5.1-Codex)

---

## Context Summary for CIT Restart

**In one sentence:**
CIC approved role split (2025-11-18) with CIT (GPT-5.1-Codex-Mini for fast troubleshooting) and Claude Code CLI (Sonnet 4.5 for documentation steward), latest build is prod-2025-11-18 (PS101 QA Mode) deployed and verified, pending production tag push.

**Key facts:**
- Your role: Active troubleshooting specialist (GPT-based)
- Model: GPT-5.1-Codex-Mini (latest OpenAI, Nov 2025)
- Latest deploy: 2025-11-18 PS101 QA Mode ✅ LIVE
- Documentation: Updated by Claude Code CLI
- Tag pending: `prod-2025-11-18` needs push
- Counterpart: Claude Code CLI (Sonnet 4.5) for docs

---

## Why GPT vs Claude Split Works

**Your strengths (GPT-5.1-Codex-Mini):**
- Agentic coding approach
- Fast troubleshooting iterations
- Cost-efficient extended sessions
- Different problem-solving style from Claude

**Claude Code CLI strengths (Sonnet 4.5):**
- Natural language summarization
- Cross-document consistency
- Documentation polish
- Different reasoning approach from GPT

**Result:** Complementary AI systems = better team outcomes

---

## Ready to Start?

1. **Start Codex with GPT-5.1-Codex-Mini:**
   ```bash
   codex --model gpt-5.1-codex-mini
   ```

2. **Give Codex this file to read:**
   ```
   Read: .ai-agents/HANDOFF_TO_CIT_GPT51_CODEX_MINI_2025-11-18.md
   ```

3. **Verify role understanding:**
   ```
   What is your role and what model are you running?
   ```

4. **Check system health:**
   ```bash
   ./scripts/verify_critical_features.sh
   ```

5. **Acknowledge handoff in session log:**
   ```bash
   echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] CIT session start with GPT-5.1-Codex-Mini" >> .ai-agents/session_log.txt
   ```

6. **Ready for troubleshooting tasks**

---

**Handoff complete. Welcome to optimized CIT role with GPT-5.1-Codex-Mini!** 🚀

---

**END OF HANDOFF**

**Prepared by:** Claude Code CLI (Documentation Steward, Sonnet 4.5)
**Date:** 2025-11-18T10:35Z
**Status:** Ready for CIT restart with GPT-5.1-Codex-Mini
**Model:** GPT-5.1-Codex-Mini (OpenAI, November 2025 release)
