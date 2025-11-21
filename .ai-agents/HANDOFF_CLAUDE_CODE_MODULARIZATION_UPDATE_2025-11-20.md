# Handoff: Modularization Plan Refinements + Function Mapping
**To:** Claude Code  
**From:** Codex (GPT-5.1, Terminal)  
**Status:** Ready for Implementation (Plan-Level Only)  
**Date:** 2025-11-20  

---

## 1. Files Updated by Codex

Codex has modified **documentation only** (no JS/HTML behavior changes):

- `REVISED_MODULARIZATION_AND_WORKFLOW_PLAN_2025-11-20.md`
  - Added `main.js` as an explicit entry-point module (Section 1.1).
  - Added an optional alternative extraction sequence that starts with `api.js` then `state.js` (Section 1.2).
  - Clarified that `state.js` must remain DOM-free, with DOM work delegated to `ui.js`, `auth.js`, and `ps101.js` (Section 1.5).
  - Added Section **1.7 – Main Application Entry Point (`main.js`)** describing how `main.js` should import `state.js`, `api.js`, `ui.js`, `auth.js`, and `ps101.js`, and how `index.html` should load it.
  - Narrowed **Phase 1 test focus** in Section 5.1 to `state.js` and `api.js` (session/trial persistence + `ensureConfig` / `callJson` behavior), explicitly deferring PS101-heavy and DOM-intensive tests to later phases.

- `MODULARIZATION_FUNCTION_MAPPING_2025-11-20.md` (new)
  - New mapping document that translates the current monolithic IIFE in `mosaic_ui/index.html` into the target modules:
    - `main.js` – bootstraps the app (wraps/refactors current `initApp` + top-level wiring).
    - `state.js` – shared state, session/trial persistence, autosave timers (DOM-free).
    - `api.js` – `ensureConfig`, `callJson`, health check, auth, upload, job search, coach API.
    - `ui.js` – DOM helpers, chat UI, upload modal UI, job search button, save/load UI, anchors, contact form, voice input.
    - `auth.js` – login/register/logout, auth modal, user progress display, trial UX.
    - `ps101.js` – PS101 constants, `PS101State`, PS101 rendering and event binding.
  - Each section lists which existing constants/functions should move where and suggests new exported init functions (`initState`, `initApi`, `initUI`, `initAuth`, `initPS101`) for `main.js` to call.

No other files were changed.

---

## 2. Implementation Expectations for Claude Code

Please use the updated plan + mapping as the blueprint for actual code changes.

**High-level steps (Phase 1 focus):**

1. **Create modules and entry point**
   - Add `mosaic_ui/js/main.js`, `state.js`, `api.js`, `ui.js`, `auth.js`, `ps101.js` following:
     - Structure and responsibilities in `REVISED_MODULARIZATION_AND_WORKFLOW_PLAN_2025-11-20.md` Sections 1.1–1.7.
     - Function-level mapping in `MODULARIZATION_FUNCTION_MAPPING_2025-11-20.md`.
   - Keep behavior identical to the current IIFE while you move code.
   - Once everything is wired, replace the existing inline `<script>` in `mosaic_ui/index.html` with:
     ```html
     <script type="module" src="./js/main.js"></script>
     ```

2. **Maintain module boundaries**
   - `state.js`:
     - DOM-free; owns data, persistence, timers (`SESSION_KEY`, `TRIAL_START_KEY`, `sessionId`, `userData`, autosave, etc.).
     - Expose helpers like `setSession`, `getSessionId`, `saveUserData`, `startTrial`, `scheduleTrialExpiryIfNeeded`, `saveAutoSnapshot`, `loadAutoSnapshot`.
   - `api.js`:
     - Move `ensureConfig`, `callJson`, and all `fetch` usage (health check, upload, job search, auth, coach).
     - Provide thin wrappers for auth, upload, job search, coach, and (optionally) contact form.
   - `ui.js`:
     - Own `$`, `$$`, chat UI, upload modal UI, job search button behavior, save/load/feedback UI, anchors, email obfuscation, contact form, voice input.
     - Call into `api.js` and `state.js` instead of performing persistence or network calls directly where appropriate.
   - `auth.js`:
     - Own login/register/logout behavior and auth modal UX.
     - Use `api.js` for network and `state.js` for session/user persistence.
   - `ps101.js`:
     - Own `PS101_STEPS`, `PS101State`, PS101 rendering and events (`bindPS101TextareaInput`, `initPS101EventListeners`, render helpers, validation).

3. **Use `main.js` as orchestrator**
   - Implement a small `initApp()` (or equivalent) in `main.js` that:
     - Calls `initState()`, `initApi()`, `initUI()`, `initAuth()`, `initPS101()`.
     - Replaces the current `initApp` logic from the IIFE, splitting work into the appropriate module init functions while preserving sequencing (Phase 1, 2, 2.5, 3+ as described in the mapping).

4. **Testing + verification (Phase 1 scope)**
   - Focus unit tests on:
     - `state.js`: session persistence, trial timing logic (without DOM), autosave snapshot helpers.
     - `api.js`: `ensureConfig` resolution behavior, `callJson` success/error paths, API base fallback behavior.
   - Run:
     - `npm test` (once Jest is installed/configured per the main plan).
     - `npx madge --circular mosaic_ui/js/` to ensure no circular dependencies.

---

## 3. Notes on Responsibilities and Hand-off

- **Codex (Terminal)** has:
  - Reviewed feasibility.
  - Refined the plan with explicit module boundaries (especially for `state.js`).
  - Added the `main.js` entry-point design.
  - Produced a function-level mapping document for you.
- **Claude Code** is expected to:
  - Perform actual refactoring of `mosaic_ui/index.html` into modules.
  - Implement `main.js` and move the logic in a series of safe, tested steps.
  - Keep behavior unchanged while improving structure.

If you need more detail on where a specific function should live, start with `MODULARIZATION_FUNCTION_MAPPING_2025-11-20.md`, then cross-reference `mosaic_ui/index.html` and the updated Section 1 of the main plan.

