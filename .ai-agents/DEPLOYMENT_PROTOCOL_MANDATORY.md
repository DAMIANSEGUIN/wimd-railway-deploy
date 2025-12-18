# MANDATORY DEPLOYMENT PROTOCOL - Prevents Today's Disaster

**Created:** 2025-11-27T18:40:00Z
**Status:** MANDATORY - No exceptions
**Applies to:** ALL AI agents (Gemini, Claude, Codex)

---

## What Went Wrong Today

1. **No testing before restore** - Claude restored backup without verifying it worked
2. **No rollback verification** - Declared "fixed" without user testing
3. **No systematic approach** - Random restore attempts, hoping something works
4. **No working baseline** - Don't know what "working" looks like
5. **No single source of truth** - Conflicting backup names/states

---

## MANDATORY PROTOCOL - Never Skip These Steps

### PHASE 1: BEFORE ANY CHANGE

**1.1 Create Timestamped Backup**

```bash
TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)Z
BACKUP_DIR="backups/pre-${CHANGE_NAME}_${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"
cp mosaic_ui/index.html "$BACKUP_DIR/mosaic_ui_index.html"
cp frontend/index.html "$BACKUP_DIR/frontend_index.html"
```

**1.2 Create BACKUP_MANIFEST.md**

```markdown
# Backup: Pre-[CHANGE_NAME]
**Created:** [TIMESTAMP]
**Agent:** [Your Name]
**Reason:** Before [specific change description]

## Current State
**WORKING:**
- [ ] Login works
- [ ] Chat works
- [ ] PS101 works (or note what fails)

**KNOWN ISSUES:**
- List any bugs

## Files
- mosaic_ui_index.html - [description of state]
- frontend_index.html - [description of state]

## To Restore
```bash
cp "$BACKUP_DIR/mosaic_ui_index.html" mosaic_ui/index.html
```

## Verification Command

```bash
# Test this backup works BEFORE using it
cp "$BACKUP_DIR/mosaic_ui_index.html" /tmp/test_index.html
# Start test server on /tmp
# Verify login, chat, PS101 all work
```

```

**1.3 Test Current State**
```bash
# Verify what's working NOW before changing anything
./test_current_state.sh > pre-change-test.log

# Must test:
- Login flow
- Chat interface
- PS101 advancement
- Any feature being changed
```

**1.4 Git Commit Current State**

```bash
git add -A
git commit -m "Pre-${CHANGE_NAME}: Working state before changes"
# DO NOT PUSH - just local safety
```

---

### PHASE 2: MAKE THE CHANGE

**2.1 ONE Change at a Time**

- Edit ONE file
- OR restore ONE backup
- OR apply ONE fix
- **NEVER multiple changes simultaneously**

**2.2 Document What Changed**

```bash
# Create change log
echo "Changed: [specific line numbers or files]" > .ai-agents/CHANGE_LOG_${TIMESTAMP}.md
echo "Reason: [why]" >> .ai-agents/CHANGE_LOG_${TIMESTAMP}.md
echo "Expected result: [what should work after]" >> .ai-agents/CHANGE_LOG_${TIMESTAMP}.md
```

**2.3 Verify File Integrity**

```bash
# Check no broken references
grep -n "src=\".*\.js\"" mosaic_ui/index.html
# Verify each file exists

# Check PS101 objects present (if needed)
grep -c "PS101_STEPS\|PS101State\|PROMPT_HINTS" mosaic_ui/index.html
# Should return 3 (or expected number)
```

---

### PHASE 3: TEST THE CHANGE (MANDATORY - NO EXCEPTIONS)

**3.1 Restart Server**

```bash
# Kill old server
pkill -f local_dev_server

# Start fresh
python3 local_dev_server.py &
sleep 3

# Verify running
curl -I http://localhost:3000/
```

**3.2 Launch Test Browser**

```bash
# Kill old Chromium
killall Chromium 2>/dev/null

# Launch with CodexCapture
bash ~/Desktop/start_chromium_local.sh
```

**3.3 Test ALL Core Functions**

```
Manual Test Checklist:
[ ] Page loads without console errors
[ ] Login interface appears
[ ] Can attempt login (even if fails - interface works)
[ ] Chat interface visible
[ ] PS101 can be started
[ ] PS101 advances past step 1
[ ] [Any other feature being changed]

Capture with Command+Shift+Y at EACH step
```

**3.4 Analyze CodexCapture**

```bash
LATEST=$(ls -t ~/Downloads/CodexAgentCaptures/ | head -1)
echo "Latest capture: $LATEST"

# Check for errors
cat ~/Downloads/CodexAgentCaptures/$LATEST/console.json | jq -r '.[] | select(.level == "error")'

# Check for 404s
cat ~/Downloads/CodexAgentCaptures/$LATEST/network.json | jq -r '.[] | select(.responseStatus == 404) | .name'

# If ANY errors: STOP, ROLLBACK, DIAGNOSE
```

---

### PHASE 4: USER VERIFICATION (MANDATORY)

**4.1 Report to User**

```
"Change applied: [description]

Test results:
✅ Login: [working/not working]
✅ Chat: [working/not working]
✅ PS101: [working/not working - specific step]

CodexCapture shows: [no errors / X errors]

Ready for you to test: http://localhost:3000

Please verify before I proceed."
```

**4.2 Wait for User Confirmation**

- **DO NOT** proceed without user confirmation
- **DO NOT** declare "fixed"
- **DO NOT** make more changes
- **WAIT** for user to test

**4.3 If User Reports Issues**

```bash
# IMMEDIATE ROLLBACK
cp "$BACKUP_DIR/mosaic_ui_index.html" mosaic_ui/index.html

# Restart server
pkill -f local_dev_server
python3 local_dev_server.py &

# Inform user
echo "Rolled back. System restored to pre-change state."

# THEN diagnose what went wrong
```

---

### PHASE 5: ONLY IF USER CONFIRMS WORKING

**5.1 Create Success Backup**

```bash
BACKUP_DIR="backups/working-${CHANGE_NAME}_${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"
cp mosaic_ui/index.html "$BACKUP_DIR/mosaic_ui_index.html"

# Create manifest marking it WORKING
cat > "$BACKUP_DIR/BACKUP_MANIFEST.md" << EOF
# WORKING BACKUP
**Verified working by user:** $(date)
**Change:** ${CHANGE_NAME}

## User Confirmed Working:
✅ Login
✅ Chat
✅ PS101

## Use This For Future Rollbacks
EOF
```

**5.2 Git Commit**

```bash
git add -A
git commit -m "${CHANGE_NAME}: User verified working

- Login: working
- Chat: working
- PS101: working
- Backup: $BACKUP_DIR"
```

**5.3 Apply to frontend/index.html (if needed)**

```bash
# Only if change needs to go to frontend too
cp mosaic_ui/index.html frontend/index.html
# Test frontend separately
# Get user confirmation again
```

**5.4 Deploy to Production**

```bash
# Only after BOTH mosaic_ui AND frontend verified by user
./scripts/deploy.sh netlify

# Monitor deployment
# Get user to test production
# Have rollback plan ready
```

---

## BACKUP NAMING CONVENTION (MANDATORY)

**Format:** `backups/[STATUS]-[DESCRIPTION]_[TIMESTAMP]/`

**STATUS must be ONE of:**

- `working-` = User verified everything works
- `pre-` = Before attempting change (unknown if works)
- `broken-` = Known to be broken
- `test-` = Experimental, not verified

**Examples:**

```
✅ GOOD:
backups/working-ps101-full-flow_20251127_183000Z/
backups/pre-scope-fix_20251126_233100Z/
backups/broken-missing-login_20251127_120000Z/

❌ BAD:
backups/backup1/
backups/latest/
backups/good_one/
```

---

## RESTORE PROTOCOL (MANDATORY)

**NEVER restore directly to production. ALWAYS test in isolation first.**

### Step 1: Verify Backup

```bash
BACKUP="backups/[backup-name]"

# Read manifest
cat "$BACKUP/BACKUP_MANIFEST.md"

# Check for known issues
grep -i "broken\|error\|fails\|issue" "$BACKUP/BACKUP_MANIFEST.md"

# Verify file integrity
ls -lh "$BACKUP/"
```

### Step 2: Test in Isolation

```bash
# Copy to /tmp
cp "$BACKUP/mosaic_ui_index.html" /tmp/test_index.html

# Start test server in /tmp
cd /tmp
python3 -m http.server 3001 &

# Test at http://localhost:3001/test_index.html
# Verify login, chat, PS101 work
```

### Step 3: If Test Passes, Create Pre-Restore Backup

```bash
# Backup current state first!
TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)Z
mkdir -p "backups/pre-restore_${TIMESTAMP}"
cp mosaic_ui/index.html "backups/pre-restore_${TIMESTAMP}/mosaic_ui_index.html"
```

### Step 4: Restore

```bash
cp "$BACKUP/mosaic_ui_index.html" mosaic_ui/index.html
```

### Step 5: Test Again (in production location)

```bash
# Restart server
pkill -f local_dev_server
python3 local_dev_server.py &

# Test http://localhost:3000
# Capture with CodexCapture
# Analyze for errors
```

### Step 6: User Verification

```
"Restored from: $BACKUP

Test results: [report findings]

Ready for you to test."
```

---

## CODEXCAPTURE MANDATORY USAGE

**Every test session MUST:**

1. Launch Chromium with CodexCapture
2. Press Command+Shift+Y at EACH test point:
   - Page load
   - Login attempt
   - Chat interaction
   - PS101 start
   - PS101 advancement
   - Any error state

3. Analyze EVERY capture:

```bash
LATEST=$(ls -t ~/Downloads/CodexAgentCaptures/ | head -1)

# Check console errors
cat ~/Downloads/CodexAgentCaptures/$LATEST/console.json | jq

# Check 404s
cat ~/Downloads/CodexAgentCaptures/$LATEST/network.json | jq -r '.[] | select(.responseStatus == 404)'

# Share path with team
echo "Capture: ~/Downloads/CodexAgentCaptures/$LATEST"
```

---

## TEAM HANDOFF REQUIREMENTS

**When handing off to another agent:**

1. **Create handoff document:** `.ai-agents/FOR_[AGENT]_[TASK]_[DATE].md`

2. **Must include:**
   - Current state (what works, what doesn't)
   - Latest WORKING backup location
   - What needs to be done
   - Expected outcome
   - Rollback plan
   - Test verification steps

3. **Update AI_RESUME_STATE.md**
   - Latest backup
   - Current status
   - Next steps
   - Team member assignments

4. **Provide chat message:**

```
[Your Role] completed: [task]

Current state:
✅ Working: [list]
❌ Broken: [list]

Latest WORKING backup: [path]
Latest backup (any state): [path]

For [Next Agent]:
Read: [handoff doc path]
Task: [clear action]
Test: [verification steps]
Rollback if fails: [command]

Status: [WORKING/BROKEN/UNKNOWN]
```

---

## WHAT TO DO IF SOMETHING BREAKS

**IMMEDIATE:**

1. STOP making changes
2. Restore from last WORKING backup
3. Verify restoration worked
4. Inform user of rollback
5. THEN diagnose what went wrong

**DO NOT:**

- Try another fix immediately
- Restore from different backup hoping it works
- Make multiple changes to "debug"
- Declare anything fixed without user confirmation

**DO:**

- Analyze CodexCapture for errors
- Read BACKUP_MANIFEST.md carefully
- Test in isolation (/tmp) before production
- Ask Gemini for architectural guidance
- Document what failed and why

---

## ENFORCEMENT

**This protocol is MANDATORY.**

**Any AI agent that:**

- Restores without testing first
- Declares "fixed" without user confirmation
- Makes changes without backup
- Skips CodexCapture verification

**Has FAILED their role and must:**

1. Immediately rollback
2. Document failure in `.ai-agents/FAILURE_REPORT_[DATE].md`
3. Hand off to another agent
4. Update this protocol to prevent recurrence

---

## SINGLE SOURCE OF TRUTH

**Working Baseline Location:**

```
backups/working-[latest]/
```

**Always updated after user confirms something works.**

**Before any change, verify:**

```bash
# What's the last confirmed working state?
ls -lt backups/working-* | head -1
```

**If no working-* backup exists:**

```
STOP. Download from production Netlify.
Test it locally.
Create working-* backup.
THEN make changes.
```

---

**This protocol prevents today's disaster from ever happening again.**

**NO EXCEPTIONS. NO SHORTCUTS.**
