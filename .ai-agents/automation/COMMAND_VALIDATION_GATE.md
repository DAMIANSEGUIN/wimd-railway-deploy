# Command Validation Gate

**Mandatory Pre-Delivery Validation for All Commands**

---

## GATE RULES (ALWAYS ENFORCE)

Before providing ANY command to the user, it MUST pass ALL checks:

### ✅ Check 1: Directory Paths Are Absolute

- ❌ BAD: `./scripts/test.sh`
- ✅ GOOD: `/Users/damianseguin/WIMD-Deploy-Project/scripts/test.sh`

### ✅ Check 2: Files Exist

- Test with: `[ -f "/path/to/file" ] && echo "EXISTS" || echo "MISSING"`
- Only provide commands for files that exist

### ✅ Check 3: Scripts Are Executable

- Test with: `[ -x "/path/to/script.sh" ] && echo "EXECUTABLE" || echo "NOT EXECUTABLE"`
- If not executable, include: `chmod +x /path/to/script.sh &&`

### ✅ Check 4: Bash Syntax Is Valid

- Test with: `bash -n /path/to/script.sh`
- Fix any syntax errors before providing

### ✅ Check 5: Commands Are Tested

- Actually run the command in a test environment
- Verify it produces expected output
- Catch errors before user sees them

### ✅ Check 6: Error Handling Included

- Every command must have: `|| echo "ERROR: [helpful message]"`
- Or: `set -e` for scripts that should fail fast

### ✅ Check 7: Current Working Directory Is Clear

- If command requires specific directory: `cd /absolute/path &&`
- Or: Use absolute paths throughout

---

## VALIDATION WORKFLOW

```
User Request
     ↓
Parse Intent
     ↓
Draft Commands
     ↓
┌─────────────────────────────────┐
│  VALIDATION GATE (MANDATORY)    │
│                                 │
│  ✓ Paths absolute?              │
│  ✓ Files exist?                 │
│  ✓ Scripts executable?          │
│  ✓ Syntax valid?                │
│  ✓ Command tested?              │
│  ✓ Error handling?              │
│  ✓ Working directory clear?     │
└─────────────────────────────────┘
     ↓
   PASS? ────NO───→ Fix & Re-test
     ↓
    YES
     ↓
Deliver to User
```

---

## VALIDATION COMMANDS (Use Before Every Response)

```bash
# Check 1: File exists
[ -f "/Users/damianseguin/WIMD-Deploy-Project/scripts/test_mosaic.sh" ] && echo "EXISTS" || echo "MISSING"

# Check 2: Executable
[ -x "/Users/damianseguin/WIMD-Deploy-Project/scripts/test_mosaic.sh" ] && echo "EXECUTABLE" || echo "NOT EXECUTABLE"

# Check 3: Bash syntax
bash -n /Users/damianseguin/WIMD-Deploy-Project/scripts/test_mosaic.sh

# Check 4: Test run (dry run if possible)
/Users/damianseguin/WIMD-Deploy-Project/scripts/test_mosaic.sh --help 2>&1 | head -5

# Check 5: Current directory
pwd
```

---

## EXAMPLES

### ❌ INVALID (Will NOT Pass Gate)

```bash
# Relative path
./scripts/test.sh

# File doesn't exist
/Users/damianseguin/nonexistent.sh

# Not executable
/Users/damianseguin/WIMD-Deploy-Project/some_script.sh

# No error handling
curl https://example.com/api

# Unclear working directory
cd scripts && ./test.sh
```

### ✅ VALID (Passes Gate)

```bash
# Absolute path, exists, executable, error handling
/Users/damianseguin/WIMD-Deploy-Project/scripts/test_mosaic.sh || echo "ERROR: Test script failed. Check: render logs | tail -50"

# With explicit directory change
cd /Users/damianseguin/WIMD-Deploy-Project && \
  ./scripts/test_mosaic.sh || echo "ERROR: Test failed"

# Making executable first
chmod +x /Users/damianseguin/WIMD-Deploy-Project/scripts/test_mosaic.sh && \
  /Users/damianseguin/WIMD-Deploy-Project/scripts/test_mosaic.sh
```

---

## TEMPLATE FOR PROVIDING COMMANDS

```markdown
## [Task Name]

**Prerequisites:**
- Current directory: /Users/damianseguin/WIMD-Deploy-Project
- File exists: [verified ✅]
- Executable: [verified ✅]
- Syntax: [validated ✅]

**Command:**
```bash
/absolute/path/to/command || echo "ERROR: [helpful troubleshooting]"
```

**Expected Output:**

```
[show what success looks like]
```

**If Error:**

```bash
[exact command to diagnose]
```

```

---

## PRE-DELIVERY CHECKLIST

Before sending ANY response with commands, verify:

```

□ All paths are absolute (no ./ or ../)
□ All files tested to exist ([ -f path ])
□ All scripts tested as executable ([ -x path ])
□ All bash syntax validated (bash -n path)
□ All commands actually tested (ran them)
□ All commands have error handling (|| or set -e)
□ Working directory is explicit (cd /path or absolute paths)
□ Expected output is documented
□ Troubleshooting commands provided

```

**If ANY checkbox fails → DO NOT DELIVER → Fix first**

---

## ENFORCEMENT

This gate is **MANDATORY** and **PERMANENT**.

**Every command provided to user must:**
1. Use absolute paths: `/Users/damianseguin/WIMD-Deploy-Project/...`
2. Be tested before delivery
3. Include error handling
4. Have expected output documented

**No exceptions.**

---

**END OF VALIDATION GATE**

Gate Status: ✅ ACTIVE
Last Updated: 2025-12-10
Applies To: ALL future responses
