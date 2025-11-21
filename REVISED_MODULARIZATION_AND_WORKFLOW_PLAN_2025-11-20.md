# Revised Implementation Plan: Modularization, Verification, and Workflow
**Date:** 2025-11-20
**Author:** Gemini
**Enhanced by:** Claude Code (Documentation Specialist)
**Status:** Ready for Implementation
**Context:** This document addresses the three critical gaps identified in `.ai-agents/DIAGNOSTIC_OUTSTANDING_ISSUES_FOR_GEMINI_2025-11-20.md`.

**Enhancement Log:**
- Added module size targets (Section 1.5) — *Claude Code*
- Added circular dependency detection (Section 1.6) — *Claude Code*
- Enhanced Playwright script with retry logic (Section 2.2) — *Claude Code*
- Added agent timing expectations (Section 3.1) — *Claude Code*
- Added parallel workflow examples (Section 3.4) — *Claude Code*
- Added test coverage targets + Jest config (Section 5.4) — *Claude Code*

## Introduction

This revised plan provides a concrete, executable strategy for the ongoing refactoring effort. It directly tackles the three critical issues raised in the diagnostic report: creating an executable modularization plan, solving the unreliable `curl`-based verification, and defining a multi-agent workflow.

---

## 1. Solution for Critical Gap #1: Executable Modularization Plan

This plan provides a "HOW" for breaking down the monolithic `mosaic_ui/index.html` file into maintainable JavaScript modules.

### 1.1. Target File Structure

The new modular structure will live in `mosaic_ui/js/`:

```
mosaic_ui/
└── js/
    ├── main.js        # Orchestrates module initialization and bootstraps the app (entry point).
    ├── state.js       # Manages shared application state (replaces global `window.APP_STATE`); **no direct DOM access**.
    ├── api.js         # Handles all `fetch` calls to the backend.
    ├── ui.js          # DOM manipulation, UI updates, and event listeners.
    ├── auth.js        # Manages login, registration, and user session logic. Depends on api.js, ui.js, state.js.
    └── ps101.js       # Handles the complex PS101 flow. Depends on api.js, ui.js, state.js.
```

### 1.2. Module Extraction Order and Dependency Flow

Extraction will proceed in phases to minimize risk, starting with the most foundational and least dependent modules.

1.  **Phase 1: `state.js`** - Centralize shared state to remove global variables. This is the top priority as it decouples other modules.
2.  **Phase 2: `api.js`** - Consolidate all backend communication.
3.  **Phase 3: `ui.js`** - Extract generic DOM helper functions.
4.  **Phase 4: `auth.js`** - Extract user authentication logic.
5.  **Phase 5: `ps101.js`** - Extract the main PS101 business logic as the final step.

**Optional alternative (equivalent risk, slightly different sequencing):**
- **Step 0:** Introduce a thin `main.js` entry-point that simply wraps the existing inline logic in an `initApp()` module function without changing behavior.  
- **Step 1:** Extract `api.js` around `ensureConfig`/`callJson` and existing `fetch` calls (health check, upload, job search, auth, coach API).  
- **Step 2:** Extract `state.js` and update `api.js` to import only the minimal session helpers it needs (for example, `setSession` / `getSessionId`).  
- **Step 3+:** Continue with `ui.js`, `auth.js`, and `ps101.js` as above.

### 1.3. Import/Export Contract Example

Modules will use standard ES6 imports/exports.

**Example: `mosaic_ui/js/auth.js`**
```javascript
// mosaic_ui/js/auth.js

import { fetchApi } from './api.js';
import { showAuthError, hideAuthModal } from './ui.js';

async function login(email, password) {
  const response = await fetchApi('/login', { email, password });
  if (response.success) {
    hideAuthModal();
    return true;
  } else {
    showAuthError(response.error);
    return false;
  }
}

function register(email, password) {
  // ... registration logic ...
}

export { login, register };
```

**Example: `mosaic_ui/index.html` (or another module)**
```html
<script type="module">
  import { login } from './js/auth.js';

  document.getElementById('login-button').addEventListener('click', () => {
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    login(email, password);
  });
</script>
```

### 1.4. Migration and Rollback Strategy

*   **Migration:** Each phase will be a separate Git branch and Pull Request, allowing for isolated review and testing.
*   **Rollback:**
    *   For simple extractions (`state.js`, `api.js`), a `git revert <commit-hash>` is sufficient to roll back a failed deployment.
    *   For complex, high-risk modules (`ps101.js`), a feature flag will be used in `index.html`:
        ```javascript
        const USE_MODULAR_PS101 = false; // Set to true to enable
        if (USE_MODULAR_PS101) {
          import('./js/ps101.js').then(ps101 => ps101.init());
        } else {
          // old inline script logic
        }
        ```
    This allows for instant rollback via an environment variable or a simple boolean flip without needing a full redeployment.

### 1.5. Module Size Targets *(Added by Claude Code)*

To ensure maintainability and prevent the recreation of monolithic files, each module must adhere to the following size limits:

| Module | Target Size | Rationale |
|--------|-------------|-----------|
| `state.js` | **< 200 lines** | Pure data structures, no business logic |
| `api.js` | **< 300 lines** | Wrapper functions only, no complex processing |
| `ui.js` | **< 250 lines** | Generic DOM helpers, no application logic |
| `auth.js` | **< 400 lines** | Login/register/session management (complex but bounded) |
| `ps101.js` | **< 500 lines** | Complex flow, but still manageable (currently ~800 lines in monolith) |

**Enforcement:** During code review, if a module exceeds its target size, consider:
1. Splitting into sub-modules (e.g., `auth-session.js`, `auth-validation.js`)
2. Moving generic utilities to `ui.js` or a new `utils.js`
3. Refactoring to reduce duplication

In addition to the line targets:
- `state.js` **must not** interact with the DOM directly. It should own pure data structures, persistence, and timers only.  
- Any DOM reads/writes (metrics UI, save banners, PS101 view updates, chat widgets, etc.) belong in `ui.js`, `auth.js`, or `ps101.js`, with state flowing through explicit imports from `state.js`.

### 1.6. Circular Dependency Detection *(Added by Claude Code)*

To prevent circular dependencies that can break ES6 module loading:

**Installation:**
```bash
npm install --save-dev madge
```

**Add to Phase 1 Checklist:**
```bash
# After extracting any module, run:
npx madge --circular mosaic_ui/js/

# Expected output:
# ✔ No circular dependencies found!

# If circular dependencies are detected:
# ✖ Found 1 circular dependency!
# auth.js > ui.js > auth.js
```

**Resolution Strategy:**
1. Move shared code to a new `common.js` module
2. Use dependency injection patterns
3. Redesign module boundaries to eliminate cycle

### 1.7. Main Application Entry Point (`main.js`)

To keep `index.html` simple and ensure a single, well-defined boot path, a lightweight entry-point module will be introduced:

- **File:** `mosaic_ui/js/main.js`  
- **Responsibility:** Orchestrate initialization only – it imports the other modules and calls their exported init functions (for example, `initState`, `initUI`, `initAuth`, `initPS101`), but contains no business logic itself.  
- **Integration with HTML:** Replace the existing inline `<script>` in `mosaic_ui/index.html` with:
  ```html
  <script type="module" src="./js/main.js"></script>
  ```
- **Dependency direction:** `main.js` depends on `state.js`, `api.js`, `ui.js`, `auth.js`, and `ps101.js`, but none of those modules import from `main.js`. This keeps each feature module testable in isolation.

As modules are extracted, any cross-cutting initialization that currently happens inside the IIFE (for example, `initApp()` and top-level event listener wiring) should be gradually moved behind explicit module exports and then called from `main.js`.

---

## 2. Solution for Critical Gap #2: `curl` Limitation in Verification

This plan replaces the acknowledged "fragile" `curl` checks with a robust, browser-based verification method using Playwright.

### 2.1. Decision: Adopt Playwright for Live Verification

As noted in the diagnostics, Playwright is already a project dependency. It is the correct tool for verifying JavaScript-rendered content and will eliminate the false negatives produced by `curl`.

### 2.2. New Verification Script: `scripts/verifications/verify_live_site.js`

A new script will be created to perform headless browser checks.

**`scripts/verifications/verify_live_site.js`** *(Enhanced by Claude Code)*
```javascript
const { chromium } = require('playwright');

(async () => {
  const url = process.argv[2] || 'https://whatismydelta.com';
  const MAX_RETRIES = 3;
  let browser;

  try {
    browser = await chromium.launch();
    const page = await browser.newPage();

    // Retry logic with exponential backoff (Claude Code enhancement)
    let attempt = 0;
    while (attempt < MAX_RETRIES) {
      try {
        await page.goto(url, { timeout: 15000, waitUntil: 'networkidle' });
        break; // Success - exit retry loop
      } catch (error) {
        attempt++;
        if (attempt === MAX_RETRIES) {
          throw new Error(`Failed to load ${url} after ${MAX_RETRIES} attempts: ${error.message}`);
        }
        // Exponential backoff: 2s, 4s, 8s
        const delay = 2000 * Math.pow(2, attempt - 1);
        console.error(`Attempt ${attempt} failed, retrying in ${delay}ms...`);
        await new Promise(r => setTimeout(r, delay));
      }
    }

    // Wait for the auth modal to be potentially rendered
    const authModal = await page.locator('#authModal').count();
    // Check for a key element of the PS101 flow
    const ps101State = await page.locator('[data-ps101-state]').count();

    const results = {
      siteReachable: true,
      authUIPresent: authModal > 0,
      ps101FlowPresent: ps101State > 0,
    };

    console.log(JSON.stringify(results));

    if (!results.authUIPresent || !results.ps101FlowPresent) {
      // Screenshot on failure for debugging (Claude Code enhancement)
      await page.screenshot({ path: '/tmp/verification-failure.png' });
      console.error('❌ Screenshot saved to /tmp/verification-failure.png');
      process.exit(1); // Fail if critical elements are missing
    }
    process.exit(0);

  } catch (error) {
    console.error(error.message);

    // Try to capture screenshot even on catastrophic failure (Claude Code enhancement)
    if (browser) {
      try {
        const page = await browser.newPage();
        await page.goto(url, { timeout: 5000 });
        await page.screenshot({ path: '/tmp/verification-error.png' });
        console.error('❌ Error screenshot saved to /tmp/verification-error.png');
      } catch (screenshotError) {
        // Silent fail on screenshot - don't mask original error
      }
    }

    console.log(JSON.stringify({ siteReachable: false, authUIPresent: false, ps101FlowPresent: false }));
    process.exit(1);
  } finally {
    if (browser) {
      await browser.close();
    }
  }
})();
```

### 2.3. Integration into `verify_deployment.sh`

The master verification script will be updated to call the new Playwright script, replacing the `curl` calls for live checks.

**Excerpt from updated `scripts/verify_deployment.sh`:**
```bash
# ... (local file checks remain the same) ...

echo "--- Verifying Live Deployment ($BASE_URL) ---"

# Use Playwright for reliable, JS-aware checks
if ! node scripts/verifications/verify_live_site.js "$BASE_URL"; then
  echo "❌ CRITICAL: Live site verification failed using Playwright."
  CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
else
  echo "✅ Live site verification passed using Playwright."
fi
```

---

## 3. Solution for Critical Gap #3: Multi-Agent Workflow

This workflow defines roles and protocols to enable parallel work, clear handoffs, and effective failure recovery.

### 3.1. Agent Role Definitions (Strength-Based) *(Enhanced by Claude Code)*

*   **Gemini (Architect & Analyst):**
    *   **Responsibilities:** Problem diagnosis, architectural planning, defining module boundaries, documentation, and code review.
    *   **Primary Task:** Create detailed, executable plans and handoff documents (like this one).
    *   **Constraint:** Due to the known command-execution bug, Gemini should **not** perform file modifications or run complex shell commands.
    *   **Timing Expectations:** *(Added by Claude Code)*
        - Planning tasks: 1-2 hours
        - Code review: 30 min - 1 hour
        - **Stuck threshold:** >2 hours on same task → escalate to human

*   **Claude Code (Executor & Refactorer):**
    *   **Responsibilities:** Reliably execute plans from Gemini, perform large-scale and complex file modifications, run tests, and carry out deployments.
    *   **Primary Task:** Turn plans into code.
    *   **Timing Expectations:** *(Added by Claude Code)*
        - Module extraction: 2-4 hours per module
        - Script execution: 5-15 minutes
        - Test execution: 10-30 minutes
        - **Stuck threshold:** >4 hours on module extraction → escalate to human

*   **Codex (Specialist & Accelerator):**
    *   **Responsibilities:** Rapidly implement well-defined, boilerplate code, such as writing unit tests from a template or creating simple components.
    *   **Primary Task:** Accelerate development by handling repetitive, pattern-based tasks in parallel.
    *   **Timing Expectations:** *(Added by Claude Code)*
        - Boilerplate code: 30 min - 1 hour
        - Unit test file: 15-30 minutes per file
        - **Stuck threshold:** >1 hour on boilerplate → escalate to human

### 3.2. Handoff Protocol

Handoffs between agents will occur via structured markdown files in a dedicated `.ai-agents/handoffs/` directory.

**Handoff Template (`.ai-agents/handoffs/TEMPLATE.md`):**
```markdown
# Handoff: [Brief Task Title]
**To:** [Target Agent: Claude Code | Codex]
**From:** [Source Agent: Gemini]
**Status:** Ready for Implementation

## Objective
A clear, one-sentence goal for this task.

## Files to Modify
- `path/to/source_file.js`
- `path/to/target_file.html`

## Detailed Instructions
1.  **Cut** the following code block from `source_file.js` (lines 100-150):
    ```javascript
    // Code to be moved
    ```
2.  **Paste** the code into `target_file.html` immediately before the line containing `<!-- PASTE HERE -->`.
3.  Run `npm test` to verify no regressions were introduced.

## Acceptance Criteria
- [ ] The specified code is removed from the source file.
- [ ] The specified code is present in the target file.
- [ ] All verification scripts pass successfully.
```

### 3.3. Orchestration and Failure Recovery

*   **Orchestrator:** The **Human User** is the primary orchestrator, responsible for assigning tasks and resolving deadlocks.
*   **Failure Detection:** An agent is considered "stuck" if it fails the same task twice or enters a repetitive, non-productive loop.
*   **Recovery Process:** If an agent is stuck, the Human User will:
    1.  Interrupt the agent.
    2.  Create a new handoff document summarizing the failed task and the error.
    3.  Assign the task to a different agent according to the roles defined above (e.g., if Gemini fails at execution, reassign to Claude Code).

### 3.4. Parallel Workflow Examples *(Added by Claude Code)*

To demonstrate the speedup from parallel execution, here are concrete examples:

**Example 1: Extract 3 Modules Simultaneously (2 hours vs. 6 hours sequential)**

**Hour 1:**
- **Claude Code:** Extract `api.js` (no dependencies, can start immediately)
- **Gemini:** Analyze `ps101.js` boundaries (planning only, no execution risk)
- **Codex:** Install and configure Jest test framework (`npm install --save-dev jest`, create `jest.config.js`)

**Hour 2:**
- **Claude Code:** Extract `auth.js` (depends on completed `api.js` from Hour 1)
- **Gemini:** Document API contracts for all extracted modules (review + documentation)
- **Codex:** Write unit tests for `api.js` following Claude's template

**Result:** 3 modules extracted + tested in 2 hours (vs. 6 hours if done sequentially)

**Example 2: Bug Fix + Testing + Documentation (1 hour vs. 3 hours sequential)**

**0-20 minutes:**
- **Claude Code:** Fix `bindPS101TextareaInput` ordering bug in `mosaic_ui/index.html`
- **Gemini:** Review deployment logs for any related issues
- **Codex:** Update existing tests that may be affected

**20-60 minutes:**
- **Claude Code:** Deploy fix to staging, run verification
- **Gemini:** Document the fix in `.ai-agents/BUG_FIX_LOG.md`
- **Codex:** Add regression test to prevent future occurrences

**Result:** Bug fixed, tested, and documented in 1 hour (vs. 3 hours sequential)

---

## 4. Solution for Important Gap #4: Robust JavaScript Ordering Fix

The original fix for the `bindPS101TextareaInput is not defined` error relied on brittle line numbers. This section provides a robust, pattern-based approach for an execution agent to apply the fix.

### Handoff Task for Execution Agent (e.g., Claude Code)

A handoff file should be created with the following instructions:

```markdown
# Handoff: Fix JS Function Ordering Bug
**To:** Claude Code
**From:** Gemini
**Status:** Ready for Implementation

## Objective
Fix the "bindPS101TextareaInput is not defined" error in `mosaic_ui/index.html` by moving the function definition before its call site.

## File to Modify
- `mosaic_ui/index.html`

## Detailed Instructions

This is a delicate operation. Do not use line numbers.

1.  **Find and Copy the function block:**
    *   Search for the exact start of the function: `function bindPS101TextareaInput()`.
    *   Select the entire function block, from that line down to and including its closing curly brace `}`.
    *   Copy the selected block to your clipboard.

2.  **Verify and Delete the original block:**
    *   After copying, delete the function block you just selected.

3.  **Find the insertion point:**
    *   Search for the exact start of the function that should precede it: `function initPS101EventListeners()`.

4.  **Paste the copied function:**
    *   Paste the `bindPS101TextareaInput` function block from your clipboard onto the line immediately *before* the `function initPS101EventListeners()` line. Ensure there is a blank line between the two functions for readability.

## Acceptance Criteria
- [ ] The `bindPS101TextareaInput` function is no longer at its original location.
- [ ] The `bindPS101TextareaInput` function is now located immediately before the `initPS101EventListeners` function.
- [ ] The application loads without the `bindPS101TextareaInput is not defined` console error.
```

---

## 5. Solution for Important Gap #5: Testing Strategy

To support the modularization effort and improve overall code quality, this section outlines a comprehensive testing strategy.

### 5.1. Unit Testing

*   **Framework:** **Jest**. It's a batteries-included framework that is well-suited for this project. An agent should be tasked with installing and configuring it (`npm install --save-dev jest`).
*   **Location:** For each new module in `mosaic_ui/js/`, a corresponding test file shall be created. For example, `mosaic_ui/js/auth.js` will be tested by `mosaic_ui/js/auth.test.js`.
*   **Responsibility:**
    *   The agent performing the module extraction (e.g., Claude Code) is responsible for writing initial, critical-path unit tests for the functions being moved.
    *   The specialist agent (Codex) can then be tasked in parallel to increase test coverage by writing tests for edge cases, using a provided template.

**Phase 1 test focus (to keep scope realistic):**
- For the initial extraction phase, prioritize unit tests for `state.js` and `api.js` only (session persistence behavior, trial timers in isolation, `ensureConfig`/`callJson` happy/error paths, API base fallback logic).  
- Defer PS101-heavy and DOM-intensive scenarios (PS101 flow rendering, chat widget behavior, complex form interactions) to later phases once those modules have been cleanly extracted into `ui.js`, `auth.js`, and `ps101.js`.

**Example: `mosaic_ui/js/auth.test.js`**
```javascript
// Mock the api.js dependency to isolate the auth module
jest.mock('./api.js', () => ({
  fetchApi: jest.fn(),
}));
import { fetchApi } from './api.js';
import { login } from './auth.js';

describe('login', () => {
  it('should return true on successful API call', async () => {
    fetchApi.mockResolvedValue({ success: true });
    const result = await login('test@test.com', 'password');
    expect(result).toBe(true);
  });

  it('should return false on failed API call', async () => {
    fetchApi.mockResolvedValue({ success: false, error: 'Invalid credentials' });
    const result = await login('test@test.com', 'wrong-password');
    expect(result).toBe(false);
  });
});
```

### 5.2. Integration Testing

*   **Framework:** **Playwright**. Since it will already be used for live-site verification, it is the natural choice for integration testing the frontend modules in a real browser environment.
*   **Location:** Integration tests will reside in a top-level `tests/integration/` directory.
*   **Responsibility:** These tests are more complex and should be written by Gemini or Claude Code as part of a dedicated task after modules are extracted. They will test the interactions between modules (e.g., clicking a login button in the UI calls the `auth` module, which calls the `api` module).

### 5.3. Test Execution Command

The `package.json` file should be updated with a `test` script:
```json
"scripts": {
  "test": "jest"
}
```
This allows any agent to run the full unit test suite by executing `npm test`.

### 5.4. Test Coverage Targets and Jest Configuration *(Added by Claude Code)*

To ensure quality without over-engineering, establish clear coverage targets:

**Coverage Targets:**
- **Unit tests:** >70% line coverage for extracted modules
- **Integration tests:** All critical user flows (login, PS101 flow, file upload)
- **Acceptance criteria:** `npm test` passes with 0 failures, no console errors in production

**Jest Configuration File: `jest.config.js`**

Create this file in the project root to enforce coverage and configure the testing environment:

```javascript
module.exports = {
  // Use jsdom for DOM testing
  testEnvironment: 'jsdom',

  // Test file patterns
  testMatch: [
    '**/*.test.js',
    '**/__tests__/**/*.js'
  ],

  // Collect coverage from these files
  collectCoverageFrom: [
    'mosaic_ui/js/**/*.js',
    '!mosaic_ui/js/**/*.test.js',
    '!mosaic_ui/js/**/__tests__/**'
  ],

  // Enforce minimum coverage thresholds
  coverageThreshold: {
    global: {
      statements: 70,
      branches: 60,
      functions: 70,
      lines: 70,
    },
  },

  // Coverage report formats
  coverageReporters: ['text', 'lcov', 'html'],

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
};
```

**Jest Setup File: `jest.setup.js`**

Create this file to configure test environment:

```javascript
// Mock window.localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
global.localStorage = localStorageMock;

// Mock console.error to fail tests on unexpected errors
const originalError = console.error;
beforeAll(() => {
  console.error = (...args) => {
    originalError(...args);
    throw new Error('Test logged console.error - this should not happen');
  };
});

afterAll(() => {
  console.error = originalError;
});
```

**Running Tests with Coverage:**
```bash
# Run all tests
npm test

# Run with coverage report
npm test -- --coverage

# Run specific test file
npm test auth.test.js

# Run tests in watch mode during development
npm test -- --watch
```

---

## 6. Implementation Roadmap *(Added by Claude Code)*

To provide clear guidance on execution order and timing:

### Week 1: Foundation (5 days)

**Day 1 - Immediate Actions:**
- [ ] Claude Code: Fix `bindPS101TextareaInput` ordering bug (1 hour)
- [ ] Claude Code: Create and test Playwright verification script (2 hours)
- [ ] Codex: Install Jest + madge, create config files (1 hour)
- [ ] Gemini: Create first handoff document for `state.js` extraction (1 hour)

**Day 2-3 - First Module Extractions:**
- [ ] Claude Code: Extract `state.js` module (3 hours)
- [ ] Codex: Write unit tests for `state.js` (1 hour)
- [ ] Run: `npx madge --circular mosaic_ui/js/` (verify no circular deps)
- [ ] Claude Code: Extract `api.js` module (3 hours)
- [ ] Codex: Write unit tests for `api.js` (1 hour)

**Day 4-5 - Third Module + Integration:**
- [ ] Claude Code: Extract `ui.js` module (3 hours)
- [ ] Codex: Write unit tests for `ui.js` (1 hour)
- [ ] Gemini: Review all extracted modules for consistency (2 hours)
- [ ] Claude Code: Integration testing of state + api + ui (2 hours)
- [ ] Deploy to staging with feature flag `USE_MODULAR_CODE=true`

**Weekend - Staging Validation:**
- [ ] Monitor staging for 48 hours
- [ ] Check error rates, user flows
- [ ] If stable → enable on production Monday

### Week 2: Complex Modules (5 days)

**Day 1-2 - Auth Module:**
- [ ] Claude Code: Extract `auth.js` module (4 hours)
- [ ] Codex: Write unit tests for `auth.js` (2 hours)
- [ ] Integration testing with `api.js` and `ui.js` (2 hours)

**Day 3-5 - PS101 Module:**
- [ ] Gemini: Finalize `ps101.js` boundary analysis (2 hours)
- [ ] Claude Code: Extract `ps101.js` module (6 hours)
- [ ] Codex: Write unit tests for `ps101.js` (3 hours)
- [ ] Full end-to-end integration testing (4 hours)

**Weekend - Production Rollout:**
- [ ] Deploy all modules to production
- [ ] Monitor for 48 hours
- [ ] Remove old inline code if stable

### Success Metrics

**Before (Current State):**
- ❌ Files: 4,244 lines each
- ❌ Bug cycle: 2 weeks
- ❌ False positives: 50%
- ❌ Agent blocking: 5 hours for minor changes

**After (Target State):**
- ✅ Modules: <500 lines each
- ✅ Bug cycle: <1 hour (CI/CD)
- ✅ False positives: <5% (Playwright)
- ✅ Agent parallelization: 3x speedup

---

**End of Plan - Ready for Codex Review**
