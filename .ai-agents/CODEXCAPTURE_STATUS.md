# CodexCapture Extension - Critical Testing Tool

**Status:** ACTIVE (Updated 2025-11-26)
**Priority:** CRITICAL - Required for all browser testing

---

## What It Is

CodexCapture is a Chrome/Chromium extension that captures:
- Console logs (all errors, warnings, info)
- Network requests (XHR, fetch, with headers and payloads)
- Screenshots (visual state at capture time)

**Location:** `~/Downloads/CodexAgentCaptures/`

---

## Usage Protocol

**EVERY TIME you open Chromium for testing:**

1. ✅ Verify CodexCapture is installed
2. ✅ Mention Command+Shift+Y to user
3. ✅ Remind user to capture at key moments

**Keyboard Shortcut:** Command+Shift+Y

---

## When to Capture

Capture at these critical moments:
- After login failure
- When UI disappears/breaks
- When network request fails
- Before and after state changes

---

## Repair Script

If CodexCapture stops working:
```bash
bash ~/scripts/codexcapturerepair.sh
```

---

## Reading Captures

Captures are timestamped directories containing:
- `console.json` - All console output
- `network.json` - All HTTP requests/responses
- `screenshot.jpeg` - Visual state

**To analyze:**
```bash
# Latest capture
ls -t ~/Downloads/CodexAgentCaptures/ | head -1

# Read console logs
cat ~/Downloads/CodexAgentCaptures/[TIMESTAMP]/console.json | jq

# Read network logs
cat ~/Downloads/CodexAgentCaptures/[TIMESTAMP]/network.json | jq
```

---

## AI Agent Reminder

**MANDATORY:** Before asking user to test in browser:

1. Open Chromium (not Chrome)
2. Verify CodexCapture installed
3. Tell user: "Use Command+Shift+Y to capture diagnostics"
4. After user captures, read the files to diagnose

**DO NOT FORGET THIS STEP**

---

Last updated: 2025-11-26 by Claude Code
