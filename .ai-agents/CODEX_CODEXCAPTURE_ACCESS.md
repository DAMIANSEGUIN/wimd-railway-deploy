# CodexCapture Evidence Access for Codex

**Date:** 2025-11-18
**For:** Codex in Cursor
**From:** Claude Code

---

## CodexCapture Logs Location

### Primary Evidence Directory

**Path:** `/Users/damianseguin/Downloads/CodexAgentCaptures/`

**Structure:**
```
/Users/damianseguin/Downloads/CodexAgentCaptures/
├── CodexCapture_2025-11-18T02-03-12-313Z/
│   ├── screenshot.jpeg    (Visual capture of page)
│   ├── console.json       (Browser console logs)
│   └── network.json       (Network/HAR data)
├── CodexCapture_2025-11-17T22-34-34-226Z/
│   ├── screenshot.png
│   ├── console.json
│   └── network.json
└── [Additional captures by timestamp]
```

---

## Latest Capture (Post-Deployment)

### Original Location
**Path:** `/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_2025-11-18T02-03-12-313Z/`

### **CODEX: Copied Into Repo for Easy Access**
**Path:** `.ai-agents/evidence/CodexCapture_2025-11-18T02-03-12-313Z/`

**You can read directly:**
- `.ai-agents/evidence/CodexCapture_2025-11-18T02-03-12-313Z/screenshot.jpeg`
- `.ai-agents/evidence/CodexCapture_2025-11-18T02-03-12-313Z/console.json`
- `.ai-agents/evidence/CodexCapture_2025-11-18T02-03-12-313Z/network.json`

**Contents:**
1. **screenshot.jpeg** - whatismydelta.com login page
   - Shows: "WELCOME TO YOUR CAREER TRANSITION"
   - Email/Password fields visible
   - "trial period ended - sign up to continue" message

2. **console.json** - Console buffer state
   ```json
   [{
     "level": "info",
     "message": "Console buffer capture not instrumented"
   }]
   ```

3. **network.json** - 5 API resources captured:
   - `https://whatismydelta.com/assets/prompts.csv` (200 OK)
   - `https://whatismydelta.com/config` (200 OK)
   - `https://what-is-my-delta-site-production.up.railway.app/health` (200 OK)
   - `https://whatismydelta.com/favicon.ico` (200 OK)
   - `https://whatismydelta.com/data/prompts.ps101.json` (200 OK)

---

## How to Access from Cursor

### Direct File Reads

You can read any capture file directly using absolute paths:

```
# Screenshot
/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_2025-11-18T02-03-12-313Z/screenshot.jpeg

# Console logs
/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_2025-11-18T02-03-12-313Z/console.json

# Network data
/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_2025-11-18T02-03-12-313Z/network.json
```

### List Available Captures

```bash
ls -lat /Users/damianseguin/Downloads/CodexAgentCaptures/
```

This will show all captures sorted by most recent first.

### Find Specific Capture

```bash
# List all captures
find /Users/damianseguin/Downloads/CodexAgentCaptures/ -name "CodexCapture_*" -type d

# List captures from today
find /Users/damianseguin/Downloads/CodexAgentCaptures/ -name "CodexCapture_2025-11-18*" -type d
```

---

## CodexCapture Documentation (In Repo)

**Accessible to Codex in Cursor:**

### Main Status Document
**Path:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/CODEXCAPTURE_STATUS.md`

**Contains:**
- Current configuration (verified 2025-11-17)
- How to use the extension
- Troubleshooting guide
- File locations
- Integration instructions

### Handoff Document
**Path:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/HANDOFF_CODEXCAPTURE_2025-11-17.md`

**Contains:**
- What was fixed
- Current state
- Next steps
- Verification checklist

### Quick Reference
**Path:** `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/SHARE_WITH_CODEX.md`

**Contains:**
- Quick summary
- Test instructions
- Troubleshooting

---

## Creating New Captures

### Trigger Capture

**Keyboard shortcut:** `Command+Shift+Y` (Mac)

**Prerequisites:**
1. Launch test Chromium: `/Users/damianseguin/Desktop/LaunchTestChromium.command`
2. Navigate to target site (e.g., https://whatismydelta.com)
3. Press `Command+Shift+Y`
4. New folder created in `/Users/damianseguin/Downloads/CodexAgentCaptures/`

**Important:** Don't click extension icon - use keyboard shortcut only

### Reset/Repair Extension

**Script:** `/Users/damianseguin/scripts/codexcapturerepair.sh`

```bash
bash /Users/damianseguin/scripts/codexcapturerepair.sh
```

This will:
- Set Chromium download directory
- Verify extension path
- Create capture directory
- Verify all files exist

---

## Usage Examples

### Example 1: Debug Production Issue

**User reports:** "Chat button not working"

**Codex actions:**
1. User runs CodexCapture on production site (Command+Shift+Y)
2. User provides capture path: `/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_[timestamp]/`
3. Codex reads:
   - `screenshot.jpeg` - See visual state
   - `console.json` - Check for JavaScript errors
   - `network.json` - Verify API calls

### Example 2: Verify Deployment

**After deployment:**
1. User captures production site
2. Codex compares:
   - Network calls (verify new endpoints)
   - Console logs (check for errors)
   - Screenshot (verify UI changes)

### Example 3: Investigation

**User reports:** "Something broke"

**Codex reads multiple captures:**
```bash
# Before deployment
/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_2025-11-17T22-34-34-226Z/

# After deployment
/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_2025-11-18T02-03-12-313Z/
```

Compare network.json and console.json to find what changed.

---

## Deployment Evidence Workflow

### Standard Process

1. **Pre-deployment capture:**
   - User captures current production state
   - Path shared with Codex

2. **Deploy changes**

3. **Post-deployment capture:**
   - User captures new production state
   - Path shared with Codex

4. **Codex verification:**
   - Compare before/after captures
   - Verify expected changes
   - Check for unexpected issues

5. **Document in deploy log:**
   - Reference capture paths
   - Note any anomalies
   - Archive evidence

---

## File Format Details

### screenshot.jpeg / screenshot.png
- Visual capture of browser viewport
- Shows exactly what user saw
- Codex can analyze visually (multimodal LLM capability)

### console.json
- Array of console log entries
- Format:
  ```json
  [
    {
      "level": "info|warn|error",
      "message": "Log message text"
    }
  ]
  ```
- If not instrumented: Shows placeholder message

### network.json
- Performance API resource timing data
- Each entry includes:
  - `name` - URL of resource
  - `responseStatus` - HTTP status code
  - `duration` - Request duration in ms
  - `transferSize` - Bytes transferred
  - Other timing details

---

## Limitations & Notes

### What CodexCapture Captures
- ✅ Screenshot of visible tab
- ✅ Console logs (if buffer instrumented)
- ✅ Network resource timing (Performance API)

### What It Doesn't Capture
- ❌ Full HAR file (only resource timing)
- ❌ Request/response bodies
- ❌ WebSocket traffic
- ❌ Service worker activity

### Console Buffer Instrumentation
- Current state: Not instrumented
- Shows: "Console buffer capture not instrumented"
- Future: Can add console buffer script if needed

---

## Quick Access Checklist

**For Codex to access capture evidence:**

□ **User provides capture path:**
  Example: `/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_2025-11-18T02-03-12-313Z/`

□ **Codex reads files directly:**
  - Read screenshot: `[path]/screenshot.jpeg`
  - Read console: `[path]/console.json`
  - Read network: `[path]/network.json`

□ **Codex analyzes:**
  - Visual inspection of screenshot
  - Parse console.json for errors
  - Check network.json for API status

□ **Document findings:**
  - Reference capture path in investigation docs
  - Note any issues found
  - Suggest next steps

---

## Reference Documents

**In repo (accessible to Codex):**
- `.ai-agents/CODEXCAPTURE_STATUS.md` - Full status and troubleshooting
- `.ai-agents/HANDOFF_CODEXCAPTURE_2025-11-17.md` - Detailed handoff
- `.ai-agents/SHARE_WITH_CODEX.md` - Quick reference
- `.ai-agents/SESSION_START_PROTOCOL.md` - Includes CodexCapture in Step 4

**Outside repo (require user to provide paths):**
- `/Users/damianseguin/Downloads/CodexAgentCaptures/` - Capture evidence
- `/Users/damianseguin/scripts/codexcapturerepair.sh` - Repair script
- `/Users/damianseguin/CodexTools/CodexCapture/` - Extension source

---

## Summary for Codex

**TL;DR:**
- Captures live in: `/Users/damianseguin/Downloads/CodexAgentCaptures/`
- User will provide full path when sharing evidence
- You can read screenshot, console.json, network.json directly
- Documentation in `.ai-agents/CODEXCAPTURE_STATUS.md`
- Extension status: ✅ OPERATIONAL (Command+Shift+Y)

**Latest capture for this deployment:**
```
/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_2025-11-18T02-03-12-313Z/
```

---

**END OF CODEX ACCESS NOTE**
