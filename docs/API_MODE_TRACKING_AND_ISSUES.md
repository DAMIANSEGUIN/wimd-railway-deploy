# API Mode Tracking and Known Issues
**Documentation for Mosaic Project AI Agent Sessions**

Last Updated: 2025-12-06

---

## PURPOSE

This document tracks API usage for cost management and documents known issues when switching between API mode and web interface accounts (Claude Pro/Plus, ChatGPT Plus) that can create disconnects in following project protocols and guidelines.

---

## 1. API MODE DETECTION AND TRACKING

### 1.1 How to Detect API Mode vs Web Interface

**Claude (Anthropic):**
- **API Mode (Claude Code CLI):** Tool invocations available (Bash, Read, Write, etc.), local filesystem access, terminal-based interaction
- **Web Interface (claude.ai):** Browser-based, no local file system access, conversational interface only
- **Detection:** If you can invoke tools and access `/Users/damianseguin/`, you are in API mode

**ChatGPT (OpenAI):**
- **API Mode:** Direct API calls via terminal, Python scripts, or third-party tools
- **Web Interface (chat.openai.com):** Browser-based, ChatGPT Plus subscription
- **Detection:** Check if environment variable `OPENAI_API_KEY` is set

### 1.2 Usage Tracking Requirements

**When Operating in API Mode, Agents MUST:**

1. **Declare API mode status at session start** in INIT mode
2. **Track token usage** throughout the session
3. **Log cumulative costs** for the session
4. **Alert user** when approaching cost thresholds

**Implementation:**
```python
# Example tracking structure
API_SESSION_LOG = {
    "session_id": "2025-12-06-claude-code",
    "mode": "API",
    "provider": "Anthropic Claude API",
    "model": "claude-sonnet-4-5",
    "start_time": "2025-12-06T12:00:00Z",
    "token_usage": {
        "input_tokens": 50500,
        "output_tokens": 12000,
        "cached_tokens": 0
    },
    "estimated_cost_usd": 0.195,  # $3/M input + $15/M output
    "reason_for_api_use": "Hit weekly limit on Claude Pro account"
}
```

### 1.3 Cost Thresholds and Alerts

**Alert Levels:**
- **Info:** Every 50K tokens consumed
- **Warning:** Session cost > $1.00
- **Critical:** Session cost > $5.00 (request user confirmation to continue)

### 1.4 Proactive Session Boundary Management (NEW - 2025-12-06)

**Purpose:** Prevent forced mid-task interruptions by identifying safe stopping points before limits are reached.

**Agent Proactive Responsibilities:**
1. **Task Estimation:** Before starting any task, estimate token usage and declare if safe to proceed
2. **Safe Stopping Points:** Identify logical checkpoints where work can pause cleanly
3. **Automatic Checkpoints:** Offer to save state every 20 minutes (web) or 100K tokens (API)
4. **Task Decomposition:** Break large tasks into bounded subtasks when approaching limits

**Safe Stopping Point Criteria:**
- ✅ Current subtask complete
- ✅ No uncommitted code or clearly documented
- ✅ No broken state (tests passing)
- ✅ Clear "next action" documented

**User Commands:**
- "Save checkpoint" - Agent immediately saves current state
- "Estimate remaining capacity" - Agent reports tokens/messages left in session

---

## 2. DOCUMENTED ISSUES: API vs WEB INTERFACE

### 2.1 Claude-Specific Issues (Anthropic)

#### Issue #1: Authentication Switching Requires Logout
**Problem:** Cannot seamlessly switch between Claude Pro subscription and API credits
- **Impact:** Context loss, session disruption
- **User Reports:** GitHub Issue #2271, #3835
- **Severity:** HIGH

**Symptoms:**
- Must logout and re-login to switch authentication methods
- API Error 400: "authentication style incompatible with long context beta header"
- Environment variable `ANTHROPIC_API_KEY` overrides subscription usage

**Workaround:**
1. Unset `ANTHROPIC_API_KEY` environment variable to use Pro subscription
2. Set `ANTHROPIC_API_KEY` only when intentionally using API credits
3. Track which mode you're in at session start

#### Issue #2: Context Loss Between Sessions
**Problem:** Claude Code loses context when terminal closes
- **Impact:** Must re-establish project context, architecture, protocols
- **User Reports:** GitHub Issue #2954
- **Severity:** CRITICAL for Mosaic (protocol-heavy project)

**Symptoms:**
- Agent forgets governance rules between sessions
- Must reload TEAM_PLAYBOOK_v2, Governance Core, NEXT_TASK
- Previous conversation history not accessible

**Solution for Mosaic:**
- **MANDATORY:** Always run SESSION_START_v2 protocol in INIT mode
- Load last-known-state summary
- Re-read governance files at every session start
- Use file-based state tracking (TEAM_STATUS.json, CURRENT_WORK.json)

#### Issue #3: Model Switching During Session
**Problem:** Switching models (e.g., Sonnet to Opus) mid-session causes errors
- **Impact:** Session termination, protocol adherence failure
- **User Reports:** GitHub Issue #9940
- **Severity:** MEDIUM

**Workaround:**
- Complete current task before switching models
- Enter HANDOFF mode, save state
- Start new session with new model

### 2.2 ChatGPT-Specific Issues (OpenAI)

#### Issue #1: Different Response Behavior
**Problem:** API version more restrictive than web interface
- **Impact:** Protocol adherence may be weaker in API mode
- **User Reports:** OpenAI Community Forums (2023-2025)
- **Severity:** MEDIUM

**Symptoms:**
- API outputs more concise, less detailed
- Same prompt gives different results (API vs web)
- API lacks hidden system prompts that web interface uses

**Solution:**
- Use explicit, detailed system prompts in API mode
- Include all governance rules in system message
- Test protocol adherence explicitly in API sessions

#### Issue #2: Performance Differences
**Problem:** API significantly slower than web interface for same query
- **Impact:** Longer wait times, potential timeouts
- **User Reports:** OpenAI Community (GPT Plus vs API)
- **Severity:** LOW (annoying but not blocking)

**Measured Differences:**
- Web interface (ChatGPT Plus): 10 seconds
- API: 50 seconds (5x slower for same response)

#### Issue #3: Feature Parity Gaps
**Problem:** Web interface has capabilities not in raw API
- **Impact:** Cannot perform certain operations in API mode
- **User Reports:** Stack Overflow, OpenAI Community
- **Severity:** MEDIUM

**Examples:**
- API cannot answer "what date is it today" (web can)
- Code formatting differs between API and web Playground
- Web has post-processing features not in API

### 2.3 Cross-Platform Pattern: Architecture Differences

**Root Cause Analysis:**
- **Web interfaces** have hidden system prompts, UI enhancements, post-processing
- **APIs** provide raw model output with full developer control
- **Result:** Same model, different behavior

**Impact on Mosaic:**
- Protocol adherence may weaken in API mode
- Governance rules may be forgotten between sessions
- Agent behavior less consistent when switching modes

---

## 3. MITIGATION STRATEGIES FOR MOSAIC

### 3.1 Session Start Protocol Enhancement

**Add to SESSION_START_v2.md:**

```markdown
## API MODE DETECTION (New Section)

At session start, agent MUST:
1. Detect if in API mode or web interface
2. Declare mode explicitly to user
3. If API mode:
   - Enable token usage tracking
   - Log session for cost monitoring
   - Emphasize governance file reloading (context loss risk)
4. If web interface:
   - Note that usage covered by subscription
   - Confirm user is not hitting rate limits
```

### 3.2 Enhanced INIT Mode Checklist

**When in API Mode, INIT MUST Include:**
- [ ] Declare "Operating in API mode - tracking usage"
- [ ] Load Mosaic Governance Core v1
- [ ] Load TEAM_PLAYBOOK_v2
- [ ] Load SESSION_START_v2
- [ ] Load last-known-state from file (not from conversation history)
- [ ] Confirm NEXT_TASK from file
- [ ] Initialize token counter
- [ ] Set cost alert thresholds

### 3.3 HANDOFF Mode Enhancement

**When ending API session, agent MUST:**
1. Report total token usage
2. Report estimated cost
3. Save full session state to file (for next session)
4. Explicitly state "Context will be lost - state saved to disk"

### 3.4 File-Based State Persistence

**Critical for API Mode:**
Mosaic MUST use file-based state, not conversation memory:

- `TEAM_STATUS.json` - Current tasks and assignments
- `CURRENT_WORK.json` - Active work state
- `NEXT_TASK.txt` - Explicit next objective
- `SESSION_HANDOFF_YYYY-MM-DD.md` - Detailed session summary
- `API_USAGE_LOG.json` - Token and cost tracking

**Never rely on conversation history for critical project state.**

---

## 4. COST MANAGEMENT GUIDELINES

### 4.1 When to Use API vs Subscription

**Use Subscription (Claude Pro/Plus, ChatGPT Plus):**
- Default for all Mosaic work
- Included usage, no per-token costs
- Better for long sessions
- More stable context (web interface)

**Use API Only When:**
- Hit weekly/daily limit on subscription
- Need specific API-only features
- Running automated scripts/batch jobs
- Subscription temporarily unavailable

### 4.2 API Pricing (as of 2025-12-06)

**Claude API (Anthropic):**
- Input tokens: $3 per million tokens
- Output tokens: $15 per million tokens
- Cache hits: $0.30 per million tokens

**Example Session Cost:**
- 50K input tokens: $0.15
- 12K output tokens: $0.18
- **Total: $0.33 for medium session**

**ChatGPT API (OpenAI - GPT-4):**
- Input tokens: $30 per million tokens (10x Claude)
- Output tokens: $60 per million tokens
- **Higher cost, use sparingly**

### 4.3 Budget Recommendations

**Monthly Budget:**
- Light API usage (backup only): $5-10/month
- Moderate usage (1-2 sessions/week): $20-30/month
- Heavy usage (primary mode): Consider upgrading subscription instead

**Session Budgets:**
- Small task (< 30 min): $0.50 target
- Medium task (1-2 hours): $2.00 target
- Large task (full session): $5.00 maximum (alert user)

---

## 5. PROTOCOL ADHERENCE VERIFICATION

### 5.1 API Mode Testing Checklist

**After completing work in API mode, verify:**
- [ ] Did agent load all governance files?
- [ ] Did agent follow TEAM_PLAYBOOK_v2 modes?
- [ ] Did agent stop on ambiguity?
- [ ] Did agent verify paths before use?
- [ ] Did agent avoid ghost fragments?
- [ ] Was NEXT_TASK confirmed at start?
- [ ] Was state saved to files for next session?

### 5.2 Red Flags for Protocol Drift

**Watch for these signs in API sessions:**
- Agent skips INIT mode or governance file loading
- Agent makes assumptions without verification
- Agent doesn't track token usage
- Agent doesn't save state at end of session
- Agent generates code without preflight checks
- Agent ignores Stop-On-Ambiguity rule

**If detected: STOP, re-read governance, restart session properly**

---

## 6. RECOMMENDATIONS FOR USER

### 6.1 Subscription Strategy

**Optimal Setup:**
1. **Primary:** Claude Pro or ChatGPT Plus subscription
2. **Backup:** API credits for both providers ($10-20 preloaded)
3. **Usage Pattern:** Use subscription until limit, then switch to API

**Cost Comparison:**
- Claude Pro: $20/month (unlimited usage up to rate limits)
- Claude API: Pay-per-use (cheaper for light usage, expensive for heavy)
- **Break-even:** ~15-20 hours of usage per month

### 6.2 Context Continuity Strategy

**To minimize context loss when switching:**
1. Complete current task before switching modes
2. Run HANDOFF mode, save state to files
3. When resuming, run full INIT protocol
4. Verify agent reloaded all governance files
5. Confirm NEXT_TASK matches saved state

### 6.3 Cost Tracking Tools

**Recommended Setup:**
- Create `API_USAGE_LOG.json` in project root
- Log every API session with token counts and costs
- Review monthly to optimize subscription vs API balance
- Set up alerts for unexpected cost spikes

---

## 7. INTEGRATION WITH EXISTING GOVERNANCE

### 7.1 Updates Required to Core Documents

**Mosaic_Governance_Core_v1.md:**
- Add section 2.1.1: "API Mode Detection" under INIT mode
- Add section 3.6: "No Reliance on Conversation History" under Execution Integrity

**TEAM_PLAYBOOK_v2.md:**
- Add section 3.1.5: "API Mode Initialization" under Session Flow
- Add section 6.6: "File-Based State Rule" under Safety Rules

**SESSION_START_v2.md:**
- Add section 3.1: "API Mode Detection and Declaration"
- Add section 8.1: "Token Usage Tracking Initialization"

### 7.2 New Monitoring Requirements

**For API Sessions, Add to Health Checks:**
- Token usage within expected range for task
- Cost not exceeding budget thresholds
- State successfully saved to files
- Governance files reloaded (not assumed from memory)

---

## 8. KNOWN ISSUE REGISTRY

| Issue ID | Provider | Severity | Status | Workaround Available |
|----------|----------|----------|--------|---------------------|
| CLAUDE-001 | Anthropic | HIGH | Open | Yes (manual logout) |
| CLAUDE-002 | Anthropic | CRITICAL | Open | Yes (file-based state) |
| CLAUDE-003 | Anthropic | MEDIUM | Open | Yes (separate sessions) |
| GPT-001 | OpenAI | MEDIUM | Open | Yes (explicit prompts) |
| GPT-002 | OpenAI | LOW | Open | No (accept slower) |
| GPT-003 | OpenAI | MEDIUM | Open | Partial (web fallback) |

**Update Frequency:** Check monthly for resolution status

**Issue Sources:**
- GitHub: anthropics/claude-code issues
- OpenAI Community Forums
- Stack Overflow
- User reports

---

## 9. EMERGENCY PROCEDURES

### 9.1 If API Costs Spike Unexpectedly

**Immediate Actions:**
1. Check current session token usage
2. If > $5, ask user to confirm before continuing
3. Review last actions for runaway loops
4. Consider switching to web interface
5. Save state, pause session if necessary

### 9.2 If Protocol Adherence Breaks Down

**Recovery Steps:**
1. STOP current work immediately
2. Verify which mode you're operating in
3. Re-run INIT mode completely
4. Reload all governance files explicitly
5. Confirm NEXT_TASK from file, not memory
6. Restart work only after governance confirmed

### 9.3 If Context Loss Occurs Mid-Session

**Symptoms:**
- Agent forgets project identity
- Agent doesn't follow governance rules
- Agent makes unverified assumptions

**Recovery:**
1. User says "Stop - Re-initialize"
2. Agent enters INIT mode
3. Agent reloads all Tier-1 governance files
4. Agent restates project, NEXT_TASK, mode
5. User confirms before resuming work

---

## 10. FUTURE IMPROVEMENTS

### 10.1 Requested Features (Community)

**From GitHub Issues:**
- Seamless API/subscription switching without logout
- Context persistence across terminal sessions
- Built-in token usage tracking in Claude Code
- Automatic fallback to API when subscription limit hit

**Status:** Feature requests submitted, no ETA from Anthropic/OpenAI

### 10.2 Mosaic-Specific Enhancements

**Planned:**
- Automated token usage dashboard
- Cost prediction based on task complexity
- Session state auto-save every 15 minutes
- Governance file hash verification (detect if files changed)

### 10.3 Monitoring Improvements

**Next Steps:**
- Integrate API usage logging into `scripts/status.sh`
- Add cost tracking to session handoff reports
- Create weekly usage summary script
- Alert user when nearing monthly API budget

---

## APPENDIX A: RESEARCH SOURCES

### A.1 Claude API Issues
- GitHub Issue #2271: "Use subscription and fallback to credits"
- GitHub Issue #2944: "API Fallback for Pro/Max Subscriptions"
- GitHub Issue #2954: "Context persistence across sessions"
- GitHub Issue #3835: "Allow switch from Max to API w/o logout"
- GitHub Issue #9940: "Pro account switching to sonnet throws 400 error"

### A.2 ChatGPT API Issues
- OpenAI Community: "LLM Output Differences: ChatGPT Plus vs API"
- Stack Overflow: "Different answers from chatgpt-api and web interface"
- Medium: "API vs ChatGPT Plus: The Tug-of-War"
- LinkedIn: "Decoding ChatGPT: API vs Plus and Their Top Features"

### A.3 Industry Analysis
- eval.16x.engineer: "Claude, Claude API, and Claude Code: What's the Difference?"
- apidog.com: "Claude Code vs Claude API Coding Efficiency"
- DEV Community: "How I Solved Claude Code's Context Loss Problem"

**Last Research Date:** 2025-12-06
**Next Review Date:** 2026-01-06

---

**END OF API MODE TRACKING AND ISSUES DOCUMENTATION**
