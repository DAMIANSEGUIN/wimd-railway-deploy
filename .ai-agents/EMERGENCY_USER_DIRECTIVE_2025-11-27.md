# EMERGENCY USER DIRECTIVE

**Date:** 2025-11-27T18:35:00Z
**From:** User (via Claude Code)
**To:** Gemini AND Codex
**Priority:** CRITICAL

---

## USER DIRECTIVE

**STOP explaining previous broken builds to user.**

**STOP wasting time with multiple restore attempts.**

**GET IT WORKING.**

---

## Current State

- ❌ No login
- ❌ No chat
- ❌ No PS101
- ❌ Complete system failure

---

## What User Said

User insists there WAS a working backup where:
- ✅ Login worked
- ✅ Chat worked
- ✅ PS101 advanced through steps
- Minor bugs: character counter, prompt counter (ACCEPTABLE)

**User made Claude create this backup.**

**Location user specified:** `backups/pre-scope-fix_20251126_233100Z/`

---

## The Problem

This backup has `<script type="module" src="./js/main.js"></script>` reference.

File `js/main.js` does NOT exist.

Results in 404 error, breaks everything.

---

## SOLUTION NEEDED FROM GEMINI/CODEX

**Option 1:** Remove js/main.js line, fix whatever breaks

**Option 2:** Create dummy js/main.js file

**Option 3:** Find ACTUAL working backup

**Option 4:** Download from production Netlify

**CHOOSE ONE. FIX IT. STOP EXPLAINING.**

---

## Files

- Current broken: `mosaic_ui/index.html`
- Backup claimed working: `backups/pre-scope-fix_20251126_233100Z/mosaic_ui_index.html`
- Server: Running port 3000
- CodexCapture: `~/Downloads/CodexAgentCaptures/CodexCapture_2025-11-27T17-49-26-735Z/`

---

## DO NOW

**Gemini:** Diagnose and provide fix plan (ONE plan, not options)

**Codex:** Test whatever Gemini says, capture errors, report findings

**Claude:** Execute Gemini's plan, verify it works

**STOP WASTING TIME.**

---

**User is frustrated. Get it working.**
