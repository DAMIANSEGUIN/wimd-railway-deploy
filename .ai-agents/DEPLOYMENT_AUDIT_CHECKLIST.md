# Deployment Audit Checklist

**Purpose:** Ensure documentation matches actual deployment process
**Created:** 2025-11-18
**Mandatory:** Run after EVERY deployment

---

## Why This Exists

**Problem identified 2025-11-18:**
- Documentation said "push to railway-origin" (wrong)
- Actual deploys used "origin + Netlify CLI" (correct)
- Mismatch blocked deployment for hours
- Process changes implemented faster than doc updates

**Solution:**
- Mandatory audit after each deploy
- Block "deployment complete" until docs match reality
- Evidence-based documentation updates

---

## Checklist (Run After Every Deploy)

### Step 1: Compare Documentation vs. Reality

**What actually happened in this deployment?**

□ **Git operations:**
  - Which remote(s) did we push to?
  - Which branch(es)?
  - Any new tags created?

□ **Deployment commands:**
  - What scripts were run?
  - What tools were used (Netlify CLI, Railway CLI, etc.)?
  - Any manual steps required?

□ **Verification steps:**
  - What verification scripts ran?
  - What health checks were performed?
  - Any post-deploy actions?

### Step 2: Review Core Documentation

**Check these files match what happened:**

□ **CLAUDE.md** (lines 27-72: Deployment Commands)
  - Do deployment commands match what we ran?
  - Are git remotes correctly described?
  - Are deployment tools accurate?

□ **SESSION_START_PROTOCOL.md** (Step 6: Operating Rules)
  - Rule 9: Deployment wrapper script usage
  - Are forbidden commands still forbidden?
  - Are required commands still required?

□ **COMMUNICATION_PROTOCOL.md** (Deployment workflow)
  - Does workflow match actual process?
  - Are escalation procedures accurate?
  - Emergency override process correct?

□ **docs/DEPLOYMENT_VERIFICATION_CHECKLIST.md**
  - Are verification steps current?
  - Do health checks match reality?
  - Any new checks to add?

### Step 3: Check Agent Handoff Documents

**Search for deployment references:**

```bash
grep -r "railway-origin\|netlify deploy\|deployment process" .ai-agents/*.md | grep -v DEPLOYMENT_AUDIT
```

□ **Update any outdated references:**
  - Legacy remote mentions
  - Old deployment commands
  - Superseded workflows

□ **Common files to check:**
  - HANDOFF_*.md files
  - CURSOR_REVIEW_*.md files
  - DEPLOYMENT_*.md files
  - TEAM_NOTE_*.md files

### Step 4: Document What Changed

**If process differs from docs:**

□ **Create deploy log entry:**
  - What changed in process?
  - Why did it change?
  - When did it change (commit reference)?

□ **Update affected docs:**
  - List all files updated
  - Explain what was wrong
  - Document correct process

□ **Mark legacy components:**
  - If old remotes/tools no longer used
  - Add "LEGACY" or "DEPRECATED" markers
  - Explain historical context

### Step 5: Evidence & Commit

□ **Capture evidence:**
  - Screenshot/copy of actual commands run
  - Deploy log output
  - Verification results

□ **Commit doc updates:**
  - Use commit message format: "DOCS: Update deployment process to match reality"
  - Reference deploy log in commit
  - Include "Post-deploy audit" marker

□ **Update deploy log:**
  - Add "Documentation Audit" section
  - List files updated
  - Explain changes made

---

## Red Flags (Stop and Investigate)

**If you see these, deployment process may have changed:**

🚩 **Authentication failures** on git remote that worked before
  → May indicate remote is no longer used

🚩 **New tools/commands** not in documentation
  → Process evolved, docs didn't update

🚩 **Skipped steps** from documented workflow
  → Steps may be obsolete

🚩 **Manual workarounds** required
  → Documentation incomplete or wrong

🚩 **"It works but docs say X"**
  → Classic symptom of drift

---

## Quick Audit Script

**Run after every deploy:**

```bash
#!/bin/bash
# Quick documentation audit

echo "=== Documentation Audit ==="
echo ""

# 1. Check what we actually did
echo "1. What git remotes were pushed to?"
git log -1 --format="%s" | grep -o "push.*" || echo "Check git log manually"
echo ""

# 2. Check deployment method
echo "2. What deployment commands were run?"
tail -20 .verification_audit.log | grep "deploy\|netlify\|railway" || echo "Check logs manually"
echo ""

# 3. Find potentially outdated doc references
echo "3. Docs referencing 'railway-origin':"
grep -l "railway-origin" CLAUDE.md .ai-agents/SESSION_START_PROTOCOL.md 2>/dev/null
echo ""

# 4. Find deployment workflow docs
echo "4. Deployment workflow docs to review:"
ls -1 .ai-agents/DEPLOYMENT*.md docs/DEPLOYMENT*.md 2>/dev/null
echo ""

echo "=== Review these files and update if needed ==="
```

---

## Documentation Update Template

**When updating docs after drift is found:**

### Commit Message Format
```
DOCS: Update [file] deployment process to match reality

**What was wrong:**
- Documentation said: [old process]
- Reality is: [actual process]
- Evidence: [deploy log reference]

**What changed:**
- [List of file changes]

**Why it changed:**
- [Explanation of process evolution]

**When it changed:**
- [Commit/date when process actually changed]

Post-deploy audit: [deploy log file]
```

### Deploy Log Section
```markdown
## Documentation Audit (Post-Deploy)

**Drift Detected:**
- CLAUDE.md said: "push to railway-origin"
- Actual process: "push to origin only"
- Last 3 deploys (Nov 9, 11, 14) used origin-only

**Root Cause:**
- railway-origin is legacy remote (no write access)
- Netlify CLI became primary deployment method
- Docs never updated when process changed

**Files Updated:**
- CLAUDE.md (lines 27-48: removed railway-origin)
- SESSION_START_PROTOCOL.md (Rule 9: updated)
- COMMUNICATION_PROTOCOL.md (workflow section)
- [List all updated files]

**Evidence:**
- deploy_logs/2025-11-14_prod-2025-11-12.md (origin only)
- deploy_logs/2025-11-09_deployment-success.md (Netlify CLI)
- .ai-agents/URGENT_DEPLOYMENT_PROCESS_AMBIGUITY_2025-11-18.md
```

---

## Enforcement

**This checklist is MANDATORY:**

- ✅ Run after EVERY deployment
- ✅ Block "deployment complete" status until audit done
- ✅ Commit doc updates before closing deployment
- ✅ Reference audit in deploy log
- ✅ Update handoff manifest with doc changes

**Pre-commit hook (future):**
- Detect deployment-related commits
- Require DEPLOYMENT_AUDIT_CHECKLIST checkbox
- Ensure deploy log references audit

**Session start (future):**
- Check if last deployment has audit section
- Flag if deploy log missing audit
- Require audit before new deployments

---

## Success Criteria

**Audit is complete when:**

1. ✅ Actual deployment process documented
2. ✅ All core docs reviewed and updated
3. ✅ Agent handoff docs corrected
4. ✅ Legacy components marked
5. ✅ Evidence captured
6. ✅ Changes committed
7. ✅ Deploy log has audit section

**Result:** Next deployment won't face same ambiguity

---

## Example: Nov 18, 2025 Audit

**Problem Found:**
- CLAUDE.md, SESSION_START_PROTOCOL.md, and 8 agent docs said "push to railway-origin"
- Actual deploys (Nov 9, 11, 14, 18) only pushed to origin
- railway-origin is legacy remote with no write access

**Files Updated:**
- CLAUDE.md (deployment commands section)
- SESSION_START_PROTOCOL.md (Rule 9)
- COMMUNICATION_PROTOCOL.md (deployment workflow)
- 6 agent handoff docs

**Changes:**
- Removed railway-origin as required step
- Documented origin + Netlify/Railway CLI as actual process
- Marked railway-origin as legacy
- Added documentation audit requirement

**Evidence:**
- deploy_logs/2025-11-18_ps101-qa-mode.md
- .ai-agents/URGENT_DEPLOYMENT_PROCESS_AMBIGUITY_2025-11-18.md

---

**Remember:** If docs and reality don't match, **reality is correct**. Update docs to match what actually works.

---

**END OF CHECKLIST**
