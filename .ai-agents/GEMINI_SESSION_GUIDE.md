# Gemini Session Start Guide

**Problem:** Gemini tries to access files outside the project directory

**Root Cause:** Gemini's working directory is not set to the project folder

---

## Quick Fix (2 Steps)

### For User

**Step 1: Run the launch script**

```bash
./scripts/start_gemini_session.sh
```

**Step 2: Copy the output and paste it as your FIRST message to Gemini**

The script will show you exactly what to tell Gemini to set its working directory correctly.

---

## What This Does

The script:

1. ✅ Verifies the project directory exists
2. ✅ Checks that status.sh is present
3. ✅ Generates the exact text to paste to Gemini

---

## Manual Method (If Script Fails)

**Paste this as your FIRST message to Gemini:**

```
Set working directory to:
/Users/damianseguin/WIMD-Deploy-Project

Then run this command:
./scripts/status.sh

Do NOT search files outside this directory.
```

---

## Why Gemini Gets Lost

**Without setting working directory:**

- Gemini defaults to `~/` (home directory)
- Broad searches (`find`, `grep`) scan entire system
- Hits permission errors on system files
- Can't find project files

**With working directory set:**

- Gemini starts in `/Users/damianseguin/WIMD-Deploy-Project`
- Searches stay within project bounds
- All project files accessible
- No permission errors

---

## Verifying It Worked

**After telling Gemini to set working directory, ask:**

```
What is your current working directory?
```

**Should see:**

```
/Users/damianseguin/WIMD-Deploy-Project
```

**If different, repeat the working directory command.**

---

## For Gemini (Auto-Instructions)

When you see this message:

```
Set working directory to:
/Users/damianseguin/WIMD-Deploy-Project
```

**You MUST:**

1. Set your working directory to that path
2. Verify: `pwd` should return exactly that path
3. Then run: `./scripts/status.sh`
4. Stay within this directory for ALL file operations

**DO NOT:**

- Search outside this directory
- Access ~/Library/* files
- Access ~/MosaicBackup/* files
- Use absolute paths outside project
- Run broad system scans

**If you need to search files:**

```bash
# ✅ CORRECT - stays in project
grep -r "pattern" .
find . -name "*.py"

# ❌ WRONG - searches entire system
grep -r "pattern" /
find ~ -name "*.py"
```

---

## Troubleshooting

### Issue: "Permission denied" on Library files

**Cause:** Working directory not set, Gemini searching system files

**Fix:** Restart session with working directory command

### Issue: "Cannot find scripts/status.sh"

**Cause:** Wrong working directory

**Fix:** Set working directory to full project path

### Issue: Gemini keeps getting lost

**Cause:** Working directory resets between messages

**Fix:** Every session start, paste the working directory command first

---

**Created:** 2025-11-25
**By:** Claude Code
**Purpose:** Ensure Gemini starts in correct project directory
