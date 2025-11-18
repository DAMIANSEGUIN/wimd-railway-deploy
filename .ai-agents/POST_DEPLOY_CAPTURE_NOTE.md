# Post-Deploy Capture Instructions

**For:** User
**Date:** 2025-11-18
**Deploy ID:** 691be4fae7190d5046657c09

---

## Post-Deploy Capture Needed

**Codex is waiting for post-deploy CodexCapture evidence.**

### Steps to Capture

1. **Open production site:**
   ```
   https://whatismydelta.com
   ```

2. **Trigger CodexCapture:**
   - Press `Command+Shift+Y` (keyboard shortcut)
   - Or use desktop launcher: `/Users/damianseguin/Desktop/LaunchTestChromium.command`

3. **Find the new capture:**
   ```bash
   ls -lat ~/Downloads/CodexAgentCaptures/ | head -3
   ```

4. **Copy to repo for Codex:**
   ```bash
   # Replace [timestamp] with actual folder name
   cp -r ~/Downloads/CodexAgentCaptures/CodexCapture_[timestamp]/ .ai-agents/evidence/
   ```

5. **Share path with Codex:**
   ```
   .ai-agents/evidence/CodexCapture_[timestamp]/
   ```

---

## What Codex Will Verify

**Post-deploy capture should show:**
- ✅ PS101 QA mode changes (localStorage check)
- ✅ Updated line count (4241)
- ✅ No console errors
- ✅ All API endpoints responding

**Compare to pre-deploy:**
- Pre: `.ai-agents/evidence/CodexCapture_2025-11-18T02-03-12-313Z/`
- Post: `.ai-agents/evidence/CodexCapture_[new-timestamp]/`

---

## Alternative: Use Existing Pre-Deploy Capture

**If post-deploy capture not needed immediately:**

Codex can use the pre-deploy capture as baseline and verify via:
- Live site inspection
- API health checks
- Deployment logs

**Pre-deploy capture location:**
```
.ai-agents/evidence/CodexCapture_2025-11-18T02-03-12-313Z/
```

---

**Codex: Waiting for post-deploy capture path when available.**
