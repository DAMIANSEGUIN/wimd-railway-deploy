# Mosaic UI Modularization – Function Mapping

**Date:** 2025-11-20  
**Author:** Codex (GPT-5.1, Terminal)  

This document maps the current inline JavaScript in `mosaic_ui/index.html` (the large IIFE starting at the `<script>` tag around `mosaic_ui/index.html:1112`) into the target modules described in `REVISED_MODULARIZATION_AND_WORKFLOW_PLAN_2025-11-20.md`.

It is intended as a concrete handoff for the execution agent (Claude Code) to implement the extraction safely and consistently.

---

## 1. Source Context

- All current behavior lives inside a single IIFE:
  - Helper functions: `$`, `$$`, `smoothTo`, `setStatus`, `debounce`, etc.
  - Global-ish state: `sessionId`, `currentUser`, `userData`, `trialStartTime`, PS101 state, etc.
  - Network helpers: `ensureConfig`, `callJson`, direct `fetch` calls (health check, upload, job search, auth, contact form, coach API).
  - UI wiring: chat widget, upload modal, job search integration, save/load, PS101 flow, contact form, voice input, anchors, etc.
- The goal is to:
  - Move core logic into ES modules under `mosaic_ui/js/`.
  - Keep `state.js` DOM-free.
  - Centralize network logic in `api.js`.
  - Concentrate DOM operations and event listeners in `ui.js`, `auth.js`, and `ps101.js`.
  - Introduce a thin `main.js` entry point that coordinates initialization.

Line numbers below are approximate and for orientation only; use function names and comments in the source file as the true reference.

---

## 2. `main.js` – Application Entry Point

**New file:** `mosaic_ui/js/main.js`  
**Responsibility:** Orchestrate initialization only – no business logic.

**Imports (target shape):**
- `import { initState } from './state.js';`
- `import { initApi } from './api.js';`
- `import { initUI } from './ui.js';`
- `import { initAuth } from './auth.js';`
- `import { initPS101 } from './ps101.js';`

**Behavior to migrate from `mosaic_ui/index.html`:**
- The overall boot sequence currently handled by the `initApp()` function (around `mosaic_ui/index.html:2094`):
  - Phase 1: auth/trial initialization (`safeLocalStorageGet`, `startTrial`, `scheduleTrialExpiry`).
  - Phase 2: initial UI visibility (show `#feedback`, etc.).
  - Phase 2.5: API status check and chat system setup.
  - Phase 3+: navigation/link handlers, resource links, email obfuscation, contact form submission, voice input wiring, etc.

**Target structure:**
- `main.js` should:
  - Call `initState()` (from `state.js`) to restore session/trial/user data.
  - Call `initApi()` (from `api.js`) to prime config, if needed.
  - Call `initUI()` (from `ui.js`) to wire generic UI (anchors, save banners, metrics, chat shell, upload modal, job search button, contact form, voice input, etc.).
  - Call `initAuth()` (from `auth.js`) to wire login/register/logout, auth modal, and CTA visibility.
  - Call `initPS101()` (from `ps101.js`) to wire PS101 flow controls and restore PS101 progress.
- After extraction, `index.html` should only include:
  ```html
  <script type="module" src="./js/main.js"></script>
  ```

---

## 3. `state.js` – Shared Application State (DOM-free)

**File:** `mosaic_ui/js/state.js`  
**Constraint:** No direct DOM access; pure data + persistence + timers.

**Constants/keys to move:**
- `SESSION_KEY`, `USER_DATA_KEY`, `TRIAL_START_KEY`, `QA_TOGGLE_KEY`.
- `FORCE_TRIAL`, `TRIAL_DURATION`.

**Variables to own:**
- `sessionId`
- `currentUser`
- `userData`
- `trialStartTime`
- `isAuthenticated`
- `autoSaveInterval`
- `dirty`, `savedThisSession` (for global “unsaved changes” tracking).

**Functions to move:**
- `safeLocalStorageGet(key, defaultValue)` and `safeLocalStorageSet(key, value)`  
  - Currently defined near `mosaic_ui/index.html:2071`.
  - Should be generalized and exported.
- Session helpers:
  - `setSession(id)` – currently updates `sessionId`, localStorage, `document.body.dataset.session`, and starts autosave.
  - New helper to expose `getSessionId()` (simple accessor over internal `sessionId`).
- User data helpers:
  - `saveUserData(data)` – merges and persists user data.
  - New helper `getUserData()` to read current user data object.
- Trial helpers:
  - `startTrial()`, `scheduleTrialExpiry()`, `checkTrialExpired()`, `showSignUpPrompt()` – **but**:
    - Logic that solely deals with timestamps, elapsed time, and flags belongs here.
    - Any DOM-specific work (`#authModal`, `#authStatus` messages) should be pulled out into `auth.js` / `ui.js` and called via callbacks.
- Autosave helpers:
  - `startAutoSave()` / `stopAutoSave()`, currently managing the `autoSaveInterval` for user activity tracking.
  - Persistence-only pieces of `saveAuto()` / the auto-load IIFE should be wrapped here as:
    - `saveAutoSnapshot(snapshot: object)` – invoked by UI layer.
    - `loadAutoSnapshot(): object | null` – returns last saved snapshot for UI to apply.

**Exports (suggested):**
- `initState()`, `setSession()`, `getSessionId()`, `getUserData()`, `saveUserData()`
- `startTrial()`, `scheduleTrialExpiryIfNeeded()`
- `startAutoSave()`, `stopAutoSave()`
- `saveAutoSnapshot()`, `loadAutoSnapshot()`

UI modules (`ui.js`, `auth.js`, `ps101.js`) should call into these exports rather than inspecting localStorage or global variables directly.

---

## 4. `api.js` – Network and Backend Access

**File:** `mosaic_ui/js/api.js`  
**Responsibility:** All `fetch` calls and backend communication.

**Constants/variables to move:**
- `API_BASE` (currently `'/wimd'`).
- `apiBase` and `configPromise` (used by `ensureConfig` / `callJson`).

**Functions to move:**
- `ensureConfig()` – resolves `apiBase` by trying `/config` endpoints.
- `callJson(path, { method, body, headers, signal })` – generic JSON helper that:
  - Awaits `ensureConfig()`.
  - Attaches `X-Session-ID` from `state.js` (via `getSessionId()`).
  - Parses JSON and throws errors with meaningful messages.
- Health check logic:
  - Current `checkAPI()` function (around `mosaic_ui/index.html:123`) both calls the API and updates the DOM (`#apiStatus`).
  - Split into:
    - `fetchApiHealth()` in `api.js` → returns `{ ok: boolean, data }`.
    - A UI-layer helper in `ui.js` that updates `#apiStatus` based on the result.
- Auth endpoints:
  - The `authenticateUser` and `logout` functions currently call `callJson('/auth/register')`, `callJson('/auth/login')`, and `callJson('/auth/logout')`.
  - Create thin API helpers here:
    - `registerUser({ email, password, discountCode? })`
    - `loginUser({ email, password })`
    - `logoutUser(oldSessionId?)`
  - `auth.js` should call these helpers instead of `callJson` directly.
- Upload API:
  - Current `uploadFile(file)` function mixes UI work and network calls.
  - Move the network portion into:
    - `uploadWimdFile(file, prompt)` in `api.js` (returns parsed JSON).
  - `ui.js` should be responsible for updating `#uploadStatus`, chat messages, and closing the modal.
- Job search API:
  - Inline `fetch(`${API_BASE}/jobsearch`, ...)` call in the `#findJobs` click handler.
  - Replace with `searchJobs({ query, location, maxResults })` in `api.js`.
- Coach API:
  - `askCoach(prompt)` currently uses `callJson('/wimd', ...)` and returns a string.
  - Move this into `api.js` (pure network behavior) and export `askCoach(prompt: string): Promise<string>`.
  - `ui.js` (chat/coach strip) then imports and uses it.

**Exports (suggested):**
- `initApi()` (optional, if any one-time setup is needed).
- `ensureConfig()`, `callJson()`, `fetchApiHealth()`.
- `registerUser()`, `loginUser()`, `logoutUser()`.
- `uploadWimdFile()`, `searchJobs()`, `askCoach()`.

---

## 5. `ui.js` – Generic UI, Chat, Save/Load, Upload, Navigation

**File:** `mosaic_ui/js/ui.js`  
**Responsibility:** DOM helpers, non-auth UI, chat, upload modal, job search button, save/load banners, anchors, contact form, voice input.

**Helpers to move:**
- DOM shorthands:
  - `$` and `$$` helper functions (currently defined at the top of the IIFE).
  - Export them so other modules can import when needed.
- Chat helpers:
  - `ensureChatRefs()`, `chatGuard()`, `addMsg()`.
  - Event handlers for `send()` and chat key handling can live here or in a dedicated `initChat()` that wires `#chat`, `#sendMsg`, `#chatInput`, etc.
- Coach strip helpers:
  - `ensureCoachStripRefs()`, `sendStrip()` and related key/click handlers for `#coachAsk`, `#coachSend`.
  - These should call `askCoach()` from `api.js` and may consult the knowledge base from `loadPrompts`/`findBestMatch`.
- Knowledge base / prompt loading:
  - `careerPrompts`, `ps101Framework`, `loadPrompts()`, and `findBestMatch()` (around `mosaic_ui/index.html:1112+`).
  - These can be:
    - Kept in `ui.js` under a `coach` namespace, or
    - Split out later into a dedicated `coach.js` if size requires.
- Upload modal UI:
  - `closeUploadModal()` and event listeners for:
    - `#openUpload`, `#closeUpload`.
    - Drag-and-drop over `#dropZone`.
    - File picker change (`#filePick`).
  - These should call `uploadWimdFile()` from `api.js` and then update `#uploadStatus` and chat via `addMsg()`.
- Job search UI:
  - Click handler for `#findJobs` that currently runs `fetch(`${API_BASE}/jobsearch`...)`.
  - Replace direct `fetch` with `searchJobs()` from `api.js`, and update chat messages (`addMsg('finding jobs...')`, success/failure responses).
- Save/load + feedback UI:
  - `markDirty()`, `collect()`, `collectFeedback()`, `apply(data)`, `download(filename, obj)`.
  - `debounce()` utility used for auto-save.
  - These functions manage DOM values and should remain here while delegating persistence to `state.js` (via `saveAutoSnapshot()` / `loadAutoSnapshot()`).
- Navigation and anchors:
  - `smoothTo(id)` and the `document.querySelectorAll('a[href^="#"]')` click wiring.
  - `scrollToSection(sectionId)` (around `mosaic_ui/index.html:3078`).
- Contact form and email obfuscation:
  - Logic that:
    - Builds `emailContact` dynamically.
    - Handles contact form submission (Netlify form POST to `/`).
  - These remain in `ui.js` (pure DOM + network via `fetch`, or optionally switched to `api.js` later).
- Voice input:
  - `webkitSpeechRecognition` integration and event handlers bound to `#voiceBtn`.

**Exports (suggested):**
- `initUI()` – wires all non-auth, non-PS101 UI features.
- Utility exports used by other modules: `$`, `$$`, `setStatus`, `addMsg`, `download`, `smoothTo`.

---

## 6. `auth.js` – Authentication and Trial UX

**File:** `mosaic_ui/js/auth.js`  
**Responsibility:** Login, registration, logout, auth modal, trial messaging, and user progress display.

**Functions and behavior to move:**
- `authenticateUser(email, password, isRegister = false, discountCode = null)`:
  - Currently:
    - Validates email/password.
    - Calls `callJson('/auth/register')` or `callJson('/auth/login')`.
    - Populates `currentUser` and `userData`.
    - Updates UI (`#authStatus`, `#authModal`, `#welcome`, `#logoutBtn`, user progress panel).
  - After extraction:
    - Should rely on `registerUser()` / `loginUser()` from `api.js`.
    - Should rely on `setSession()` / `saveUserData()` from `state.js`.
    - Should use `setStatus()` / other helpers from `ui.js` for DOM updates.
- `logout()`:
  - Currently clears session-related localStorage keys, sets a `LOGGING_OUT` flag in `sessionStorage`, calls `/auth/logout`, and reloads the page.
  - After extraction:
    - Should use `logoutUser()` in `api.js` and `state.js` helpers to clear state.
    - Remains the place that triggers `window.location.reload()`.
- `updateUserProgress()`:
  - Updates `#sessionDisplay`, `#pathDisplay`, `#lastActivityDisplay`, and toggles `#userProgress`.
  - Continues to live here, using `getUserData()` from `state.js`.
- `hideAuthModal()`:
  - Simple DOM toggle for `#authModal`.
- Trial UX hooks:
  - UI portions of `showSignUpPrompt()` (displaying `#authModal` and setting `authStatus` text).
  - Any “auth CTA visibility” helpers (e.g., `window.__updateAuthCTAVisibility` callbacks).

**Event bindings to move/wrap:**
- Wiring for:
  - Login form submit (email/password inputs, “login” button).
  - Registration form submit (if separate).
  - Logout button (`#logoutBtn`).
  - Any “start trial” or “sign up” buttons that open the auth modal.

**Exports (suggested):**
- `initAuth()`, `authenticateUser()`, `logout()`.

---

## 7. `ps101.js` – PS101 Flow, State, and UI

**File:** `mosaic_ui/js/ps101.js`  
**Responsibility:** Entire PS101 “island” – questions, state, experiments, obstacles, actions, reflection, and associated UI.

**Core data and state to move:**
- `PS101_STEPS` constant array (step definitions and prompts).
- `PS101State` object (defined around `mosaic_ui/index.html:3237`), including:
  - Properties: `currentStep`, `currentPromptIndex`, `steps`, `experiments`, `startedAt`, `lastUpdated`, `completed`, `completionScores`, etc.
  - Methods: `init()`, `save()`, `getCurrentStep()`, `getCurrentPrompt()`, `getAnswer()`, `setAnswer()`, `getStepAnswers()`, `isStepComplete()`, `nextPrompt()`, `prevPrompt()`, `goToStep()`, experiment helpers (`createExperiment()`, `getActiveExperiment()`, `updateExperiment()`, `addObstacle()`, `addAction()`, `updateReflection()`, etc.).
  - Current use of localStorage (`ps101_v2_state`, `ps101_state`) can remain inside this module for now, or be refactored later to share infrastructure with `state.js`.

**PS101-specific UI helpers to move:**
- Rendering helpers (all functions that exclusively operate on PS101 DOM structure):
  - `escapeHtml(text)`
  - `updateProgressIndicator(currentStep)`
  - `updateCharCount(current, max)`
  - `renderPreviousAnswers(currentStep)`
  - `renderWelcomeScreen()`
  - `renderCompletionScreen()`
  - `renderCurrentStep()` (and any related render helpers visible in the PS101 block).
- Input and validation:
  - `handlePS101TextareaInput(event)`
  - `updateNavButtons(currentStep, promptIndex, totalPrompts)`
  - `validateCurrentStep()`
- Event wiring:
  - `bindPS101TextareaInput()` and `initPS101EventListeners()` (around `mosaic_ui/index.html:2454+`).
  - Any listeners on:
    - `#start-ps101`, `#continue-ps101`, `#learn-more-ps101`.
    - Progress dots (`.progress-dots .dot`).
    - “Back” / “Next” buttons (`#ps101-back`, `#ps101-next`).
    - Experiment components (obstacle mapping, actions, reflection, etc.).

**Exports (suggested):**
- `initPS101()` – initializes `PS101State`, binds all PS101 UI handlers, and exposes any needed globals (if still required) in a controlled way.

---

## 8. Notes for Execution Agent (Claude Code)

- **No code has been modified yet** in `mosaic_ui/index.html`; this file is a mapping and design document only.
- The implementation should:
  - Create the modules listed above under `mosaic_ui/js/`.
  - Gradually move functions and logic from the existing IIFE into the appropriate module, keeping behavior identical.
  - Replace the inline `<script>` in `mosaic_ui/index.html` with a single `<script type="module" src="./js/main.js"></script>` once all dependencies are wired.
  - Keep `state.js` DOM-free and use it only for data/persistence/timers.
  - Use `madge` to verify there are no circular dependencies after each module extraction, per the main plan.
- For Phase 1, align test scope with the updated plan:
  - Add Jest tests for `state.js` and `api.js` first (no PS101 or heavy DOM work yet).
  - Mock `fetch` and storage as needed (`jest.setup.js` is already specified in the main plan).

See `REVISED_MODULARIZATION_AND_WORKFLOW_PLAN_2025-11-20.md` for the high-level roadmap and this file for concrete mapping while implementing the extraction.

