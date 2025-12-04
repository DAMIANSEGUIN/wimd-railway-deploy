# PS101 Baseline Status – 2025-11-27

**Date:** 2025-11-27  
**Agents:** User, Claude Code, Gemini, Codex (terminal)  
**Purpose:** Capture the current *working baseline* for PS101, login, and chat so future sessions do not re‑break stable features.

---

## 1. Current Baseline Snapshot

- **Active file:** `mosaic_ui/index.html`
- **Source backup:** `backups/pre-ps101-fix_20251126_220704Z/mosaic_ui_index.html`
- **Supporting file:** `mosaic_ui/js/main.js` (dummy file to satisfy `<script type="module" src="./js/main.js">`)

This is the only snapshot currently verified where:
- ✅ Login works  
- ✅ Chat works  
- ❌ PS101 does **not** advance (known hoisting/runtime bug)

The later `pre-scope-fix_20251126_233100Z` backup **cannot** be used as a baseline because it re‑introduces a login regression.

---

## 2. Behavior on This Baseline

### 2.1 Login

- Login modal is present and opens.
- Submitting credentials hits `/auth/login` or `/auth/register` correctly.
- On success:
  - `isAuthenticated` is set `true`.
  - `authModal` hides.
  - UI shows logged‑in state (per existing implementation).

**Status:** ✅ Working.

### 2.2 Chat

- “help” (`#openChat`) opens the chat panel.
- Sending a message:
  - Renders the user message.
  - Triggers `send()` → `askCoach()` → `callJson('/wimd', ...)`.
  - Produces a bot response when backend is reachable.

**Status:** ✅ Working (subject to backend/network availability).

### 2.3 PS101

- PS101 welcome/flow UI renders.
- Typing into the PS101 textarea updates the UI partially, but **Next / prompt advancement does not work**.
- Console shows a **hoisting/scope error** around `handleStepAnswerInput` when PS101 wiring runs.

**Status:** ❌ Broken (navigation / progression only).

---

## 3. PS101 Hoisting/Scope Bug (Root Cause on This Baseline)

On `pre-ps101-fix_20251126_220704Z` (now in `mosaic_ui/index.html`):

- `initPS101EventListeners()` is defined in the main IIFE and wires:
  ```js
  const textarea = document.getElementById('step-answer');
  if (textarea) {
    textarea.removeEventListener('input', handleStepAnswerInput);
    textarea.addEventListener('input', handleStepAnswerInput);
  }
  ```
- `handleStepAnswerInput(e)` is defined **inside the separate PS101 IIFE**, not at the same scope:
  ```js
  function handleStepAnswerInput(e) {
    const step = PS101State.getCurrentStep();
    if (!step) return;
    // updates char count + calls updateNavButtons(...)
  }
  ```
- Because `handleStepAnswerInput` is not in the outer IIFE’s scope (nor on `window`), when `initPS101EventListeners()` runs it effectively hits:
  - `ReferenceError: handleStepAnswerInput is not defined`

This aligns with the CodexCapture evidence (2025‑11‑27) and the user’s observation:
- “Login came up and the first main chat worked but the PS101 prompt did not forward so maybe hoisting again?”

**Key point:** On this baseline the PS101 *data/state objects* exist, but **the event wiring cannot see `handleStepAnswerInput`**, so PS101 cannot progress.

---

## 4. Backup Status Matrix

**Backup #1 – `pre-ps101-fix_20251126_220704Z`**
- ✅ Login working  
- ✅ Chat working  
- ❌ PS101 advancement broken (hoisting/scope error on `handleStepAnswerInput`)  
- **Role:** **Current working baseline** for all future PS101 fixes.

**Backup #2 – `pre-scope-fix_20251126_233100Z`**
- ❌ Login UI effectively missing/broken (cannot log in)  
- ❓ Chat not fully testable (blocked by login regression)  
- ❓ PS101 status unknown in practice on this snapshot (not testable without login)  
- **Role:** Historical reference only; **not** acceptable as a baseline.

**Post‑restore backup – `backups/post-restore_20251127_171057Z`**
- Contains the restored `mosaic_ui_index.html` based on `pre-scope-fix` (with PS101 objects), but:
  - Shares the **same login regression** and thus is not usable for live work.
- **Role:** Archive of a broken state; not a deployment candidate.

---

## 5. Agreed Constraints Going Forward

1. **Do not** restore `mosaic_ui/index.html` from `pre-scope-fix_20251126_233100Z` or `post-restore_20251127_171057Z` for active work.
2. All new PS101 fixes must be implemented **on top of** the pre‑ps101‑fix baseline now in `mosaic_ui/index.html`.
3. Login and chat are considered **must‑not‑break**; PS101 fixes are not allowed to regress them.
4. When PS101 is fixed on this baseline, create:
   - A new dated backup.
   - An update to this document or a new follow‑up doc (e.g., `PS101_BASELINE_STATUS_2025-11-28.md`).

---

## 6. Where to Look Next

**For future sessions (Claude / Codex / Gemini):**

- Start here for PS101 baseline:  
  `.ai-agents/PS101_BASELINE_STATUS_2025-11-27.md`
- Then read:
  - `.ai-agents/TEAM_DOCUMENTATION_REFERENCE.md` (indexes current docs)
  - `AI_RESUME_STATE.md` (session resume state – references this file)
  - `.ai-agents/FOR_GEMINI_PS101_HOISTING_ISSUE_2025-11-26.md` (initial hoisting report)
  - `.ai-agents/GEMINI_RECOVERY_PLAN_2025-11-27.md` (architectural recovery plan)

