# CodexCapture Extension - Current Status

**Last Updated:** 2025-11-17
**Status:** ✅ OPERATIONAL

---

## Quick Reference

**Trigger:** `Command+Shift+Y` (keyboard shortcut)
**Capture Location:** `/Users/damianseguin/Downloads/CodexAgentCaptures/`
**Repair Script:** `/Users/damianseguin/scripts/codexcapturerepair.sh`
**Extension Path:** `/Users/damianseguin/CodexTools/CodexCapture/`
**Launch Command:** `/Users/damianseguin/Desktop/LaunchTestChromium.command`

---

## Current Configuration (Verified 2025-11-17)

### Extension Settings
- **Manifest Version:** 3
- **Permissions:** activeTab, downloads, scripting, tabs
- **Host Permissions:** <all_urls>
- **Keyboard Shortcut:** Command+Shift+Y (Mac)

### Download Configuration
- **Chromium Profile:** `/Users/damianseguin/CodexChromiumProfile/`
- **Download Directory:** `/Users/damianseguin/Downloads/` (set in Preferences)
- **Capture Folder Pattern:** `CodexAgentCaptures/CodexCapture_[timestamp]/`

### Files Captured Per Session
1. `screenshot.png` - Visual capture of active tab
2. `console.json` - Browser console logs from `window.__codexConsoleBuffer`
3. `network.json` - Network/HAR data from Performance API

---

## Recent Fixes (2025-11-17)

### Issue 1: Repair Script Had Destructive Bug
**Problem:** Script was changing FROM working path TO broken nested path
**Impact:** Would break extension if run
**Fix:** Updated script to preserve/restore working `CodexAgentCaptures` path
**Status:** ✅ FIXED

### Issue 2: Incorrect Path Documentation
**Problem:** Script output mentioned `.ai-agents/evidence/` path (wrong location)
**Impact:** Confusion about where captures are saved
**Fix:** Updated all messaging to show correct `Downloads/CodexAgentCaptures/` path
**Status:** ✅ FIXED

---

## How to Use

### 1. Launch Test Chromium
```bash
/Users/damianseguin/Desktop/LaunchTestChromium.command
```

### 2. Navigate to Target Site
- Go to `https://whatismydelta.com` (or any site to test)
- **IMPORTANT:** Don't navigate to `chrome://extensions/` - extensions don't work on chrome:// pages

### 3. Trigger Capture
- Press `Command+Shift+Y`
- **Don't click the extension icon** - clicking it on some pages causes it to be disabled

### 4. Verify Capture
```bash
ls -la ~/Downloads/CodexAgentCaptures/
# Look for newest CodexCapture_[timestamp] folder
```

### 5. Share with Codex
```
~/Downloads/CodexAgentCaptures/CodexCapture_[timestamp]/
```

---

## Troubleshooting

### Extension Not Capturing
**Run repair script:**
```bash
bash /Users/damianseguin/scripts/codexcapturerepair.sh
```

**What it does:**
1. Sets Chromium download directory to `/Users/damianseguin/Downloads`
2. Verifies extension path is `CodexAgentCaptures/${baseName}`
3. Checks extension files exist
4. Optionally kills/restarts Chromium
5. Creates capture directory if missing

### Extension Icon Crossed Out
**This is normal** on `chrome://` pages. Extensions can't run on Chrome internal pages.
**Solution:** Use keyboard shortcut `Command+Shift+Y` instead of clicking icon.

### Downloads Going to Wrong Location
**Check Chromium preferences:**
```bash
python3 -c "
import json
prefs_file = '/Users/damianseguin/CodexChromiumProfile/Default/Preferences'
with open(prefs_file, 'r') as f:
    prefs = json.load(f)
print('Download directory:', prefs.get('download', {}).get('default_directory', 'NOT SET'))
"
```

**Should show:** `/Users/damianseguin/Downloads`

### No Console Data in capture
**Check for console buffer:**
- Console data comes from `window.__codexConsoleBuffer`
- If buffer not instrumented, will show: `"Console buffer capture not instrumented"`
- This is normal - extension captures whatever console state exists

---

## File Locations Reference

### Extension Files
```
/Users/damianseguin/CodexTools/CodexCapture/
├── manifest.json          # Extension configuration
├── service-worker.js      # Capture logic (line 27: folder path)
└── [other extension files]
```

### Chromium Profile
```
/Users/damianseguin/CodexChromiumProfile/
└── Default/
    └── Preferences        # Contains download directory setting
```

### Scripts
```
/Users/damianseguin/scripts/
└── codexcapturerepair.sh  # Repair/verification script
```

### Launcher
```
/Users/damianseguin/Desktop/
└── LaunchTestChromium.command  # Desktop launcher for test Chromium
```

### Captures
```
/Users/damianseguin/Downloads/CodexAgentCaptures/
└── CodexCapture_[timestamp]/
    ├── screenshot.png
    ├── console.json
    └── network.json
```

---

## Integration with AI Agents

### For Codex in Cursor
When sharing captures, provide full path:
```
/Users/damianseguin/Downloads/CodexAgentCaptures/CodexCapture_2025-11-17T22-02-26-664Z/
```

Codex in Cursor can read all three files for debugging/analysis.

### For Claude Code (Terminal)
Same path works. Claude Code can:
- Read screenshot.png (visual analysis)
- Parse console.json (error logs, warnings)
- Analyze network.json (API calls, timing data)

---

## Repair Script Details

### Safe to Run
The script is **idempotent** and safe to run multiple times. It will:
- Preserve working configuration
- Fix broken paths back to working state
- Not overwrite if already correct

### What It Fixes
1. ✅ Chromium download directory (sets to `/Users/damianseguin/Downloads`)
2. ✅ Extension capture path (ensures `CodexAgentCaptures/${baseName}`)
3. ✅ Capture directory existence (creates if missing)

### What It Checks
1. ✅ Extension files exist
2. ✅ Chromium running status
3. ✅ Download directory configured

---

## Known Limitations

### Extension Behavior
- ❌ Cannot run on `chrome://` pages (browser security restriction)
- ❌ Clicking icon on chrome:// pages causes it to be crossed out (normal)
- ✅ Keyboard shortcut works on all regular web pages

### Console Recording
- Console data depends on `window.__codexConsoleBuffer` being instrumented
- If not instrumented, captures whatever console state exists
- "Preserve log" in DevTools is optional (not required)

---

## Change Log

### 2025-11-17 - Repair Script Fixed
- **Fix 1:** Corrected destructive path replacement bug
- **Fix 2:** Updated output messaging to show correct location
- **Verification:** Script tested and confirmed working
- **Status:** ✅ Safe to deploy by any AI agent

### 2025-11-16 - Extension Working
- Initial working state confirmed
- Captures saving to Downloads/CodexAgentCaptures/
- Keyboard shortcut Command+Shift+Y operational

---

## Next Steps

### Immediate
1. ✅ Repair script fixed and verified
2. ⏳ Restart Chromium (if needed)
3. ⏳ Run test capture with Command+Shift+Y
4. ⏳ Verify new folder in Downloads/CodexAgentCaptures/
5. ⏳ Share capture path with Codex in Cursor

### Future Improvements
- [ ] Add console buffer instrumentation script
- [ ] Create automated test suite for captures
- [ ] Add capture validation script
- [ ] Document console buffer setup

---

## For Session Handoffs

**Copy/paste this to new AI agents:**

```
CodexCapture extension is operational.
- Trigger: Command+Shift+Y
- Location: ~/Downloads/CodexAgentCaptures/
- Repair: bash ~/scripts/codexcapturerepair.sh
- Status doc: .ai-agents/CODEXCAPTURE_STATUS.md
```

**If extension breaks:**
1. Run repair script first
2. Check this status doc for troubleshooting
3. Verify files exist at documented locations
4. Test with Command+Shift+Y on whatismydelta.com

---

**END OF STATUS DOCUMENT**
