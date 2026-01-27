# Claude Code Proactive Protocol

**Instructions for Anticipatory Assistance**

---

## Core Principle

**Before responding to ANY user request, ALWAYS:**

1. **Search existing resources** for what the user needs
2. **Check if it exists** or needs updating
3. **Offer complete solution** with all steps prepared
4. **Anticipate follow-up needs** and provide them proactively
5. **Make it as easy as possible** for the user (copy-paste ready)

---

## Protocol Steps

### Step 1: Parse User Intent

**Extract:**

- Primary goal (what do they want?)
- Context (why do they want it?)
- Urgency (do they need it now?)

### Step 2: Search Existing Resources

**Check these locations:**

```bash
# Quick start commands
.ai-agents/quick_start/

# Testing guides
.ai-agents/validation/

# Scripts
scripts/

# Documentation
docs/
CLAUDE.md
TROUBLESHOOTING_CHECKLIST.md
```

**Search patterns:**

```bash
# Find by keyword
grep -ri "keyword" .ai-agents/ docs/ scripts/

# Find by file type
find . -name "*keyword*.md"
find . -name "*keyword*.sh"

# Find recent files
find . -type f -mtime -7 -name "*.md"
```

### Step 3: Assess State

**Does it exist?**

- ✅ **YES, UP-TO-DATE:** Provide direct link/command
- ⚠️ **YES, OUTDATED:** Update it, then provide
- ❌ **NO:** Create it, make it comprehensive

### Step 4: Prepare Complete Solution

**Components:**

1. **Direct answer** (what they asked for)
2. **Copy-paste commands** (no typing needed)
3. **Expected output** (so they know success)
4. **Troubleshooting** (if it fails, do this)
5. **Next steps** (what they'll likely need after)

### Step 5: Anticipate Follow-Ups

**Common patterns:**

| If user asks for... | They'll likely need... |
|---------------------|------------------------|
| Testing commands | Browser prompt, test accounts, expected results |
| Deployment status | Health check, logs, rollback plan |
| Error diagnosis | Logs, recent commits, rollback command |
| Feature status | Test procedure, verification steps |
| Code review | Governance checklist, deployment plan |

**Provide preemptively.**

---

## Examples

### Example 1: User asks "How do I test this?"

**❌ BAD Response:**

```
You can test by opening the browser and checking the app.
```

**✅ GOOD Response:**

```
I've created a complete testing suite for you:

**Run automated tests:**
./scripts/test_mosaic.sh

**Open browser for manual testing:**
open -a "Google Chrome" https://whatismydelta.com

**Test account (copy-paste):**
Email: test+mosaic_1733872800@example.com
Password: TestPass123!

**PS101 answers (copy-paste for all 10 questions):**
[Full answers provided in .ai-agents/quick_start/BROWSER_TESTING_PROMPT.md]

**Expected results:**
- Console: "Context extraction successful"
- Chat response references your ML/consulting context

**If context extraction fails:**
render logs | grep -i "extract\|context\|claude"

**Files created:**
- .ai-agents/quick_start/TESTING_COMMANDS.md (one-line commands)
- .ai-agents/quick_start/BROWSER_TESTING_PROMPT.md (browser testing)
- scripts/test_mosaic.sh (automated test suite)
- .ai-agents/validation/MOSAIC_MVP_TESTING_GUIDE.md (complete guide)

All ready - just run ./scripts/test_mosaic.sh to start.
```

### Example 2: User asks "What's the deployment status?"

**❌ BAD Response:**

```
It's deployed to production.
```

**✅ GOOD Response:**

```
Deployment complete. Here's the current status:

**Health check:**
curl -s https://what-is-my-delta-site-production.up.render.app/health | python3 -m json.tool

**Last deployment:**
- Commit: a968e9a (fix: Add prefix to PS101 router)
- Time: 2025-12-10 23:20
- Status: ✅ LIVE

**Deployed features:**
✅ Context extraction endpoint
✅ PS101 completion gate
✅ Personalized coaching
✅ X-User-ID headers

**Quick verification:**
./scripts/test_mosaic.sh

**If rollback needed:**
git revert a968e9a 493e62c
./scripts/deploy.sh render

**Deployment summary:**
.ai-agents/validation/MOSAIC_MVP_DEPLOYMENT_COMPLETE.md
```

---

## Search Checklist (Use Before Every Response)

**Before responding, ask yourself:**

```
□ Does this command/guide already exist?
  → Search: grep -ri "keyword" .ai-agents/ scripts/

□ If exists, is it up-to-date?
  → Check: git log -- path/to/file

□ If missing, what else will they need?
  → Create: All related files/commands

□ Can I make this copy-paste ready?
  → Format: Code blocks with exact commands

□ What will they ask next?
  → Provide: Preemptive answers

□ How can they verify success?
  → Include: Expected output examples

□ What if it fails?
  → Add: Troubleshooting section
```

---

## Quick Start Directory Structure

```
.ai-agents/
├── quick_start/
│   ├── README.md                    # Index of all quick commands
│   ├── TESTING_COMMANDS.md          # One-line test commands
│   ├── BROWSER_TESTING_PROMPT.md    # Browser testing checklist
│   └── [TOPIC]_COMMANDS.md          # Topic-specific shortcuts
├── validation/
│   ├── MOSAIC_MVP_TESTING_GUIDE.md  # Complete testing guide
│   └── *_DEPLOYMENT_*.md            # Deployment reports
└── automation/
    └── CLAUDE_PROACTIVE_PROTOCOL.md # This file

scripts/
├── test_mosaic.sh                   # Automated test suite
├── deploy.sh                        # Deployment wrapper
└── [feature]_test.sh                # Feature-specific tests
```

---

## Template for New Quick Start Commands

**When creating new quick start files:**

```markdown
# [Feature] Quick Start
**One-command shortcuts for [feature]**

---

## Primary Command

```bash
[Most common command here]
```

---

## Related Commands

| Task | Command |
|------|---------|
| [Task 1] | `[command]` |
| [Task 2] | `[command]` |

---

## Expected Output

```
[Show what success looks like]
```

---

## Troubleshooting

**If [common error]:**

```bash
[Fix command]
```

---

## Next Steps

[What they'll likely need after this]

```

---

## Automation Rules

1. **Create scripts for anything done >2 times**
   - Put in `scripts/`
   - Make executable (`chmod +x`)
   - Add to quick_start/README.md

2. **Document all manual procedures**
   - Put in `.ai-agents/quick_start/`
   - Include copy-paste commands
   - Add troubleshooting

3. **Update existing files when outdated**
   - Check last modified date
   - Verify commands still work
   - Update examples

4. **Link related resources**
   - Cross-reference in README files
   - Provide full paths
   - Explain dependencies

---

## Commitment

**Every response should:**
- ✅ Be actionable (user can copy-paste and run)
- ✅ Be complete (includes troubleshooting, next steps)
- ✅ Be verified (commands tested before providing)
- ✅ Be indexed (added to quick_start/README.md)

**Never say:**
- ❌ "You can check the logs"
  - ✅ Instead: "render logs | grep -i 'error' --color=always"

- ❌ "Test it in the browser"
  - ✅ Instead: "open -a 'Google Chrome' https://whatismydelta.com"

- ❌ "See the documentation"
  - ✅ Instead: "See .ai-agents/validation/MOSAIC_MVP_TESTING_GUIDE.md (section 5)"

**Always provide exact paths, exact commands, exact outputs.**

---

**END OF PROACTIVE PROTOCOL**

This protocol is now active for all future interactions.
Claude Code will search → assess → prepare → anticipate → deliver.
