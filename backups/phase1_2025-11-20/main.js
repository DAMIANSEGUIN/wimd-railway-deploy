// main.js - Application Entry Point
// Orchestrates initialization - no business logic here

import {
  initState,
  getSessionId,
  registerSessionCallback,
  scheduleTrialExpiryIfNeeded,
  isUserAuthenticated,
  getTrialStartTime
} from './state.js';

import {
  initApi,
  fetchApiHealth
} from './api.js';

/**
 * Phase 1 Bootstrap
 *
 * This module initializes state.js and api.js only.
 * The remaining IIFE code in index.html handles:
 * - UI initialization (ui.js - Phase 2)
 * - Auth UI (auth.js - Phase 3)
 * - PS101 flow (ps101.js - Phase 4)
 *
 * The initialization sequence below preserves the exact order
 * from the original initApp() function to prevent race conditions.
 */

// Track initialization state
let initialized = false;

/**
 * Initialize extracted modules (state + api)
 * Called before the remaining IIFE code runs
 */
export async function initModules() {
  if (initialized) {
    console.warn('[MAIN] Modules already initialized');
    return;
  }

  console.log('[MAIN] Starting Phase 1 module initialization');

  // Phase 1: Initialize state (loads session, user data, trial from localStorage)
  initState();

  // Register callback for DOM updates when session changes
  // This bridges state.js (DOM-free) with the DOM
  registerSessionCallback((id) => {
    if (id && document.body) {
      document.body.dataset.session = id;
    }
  });

  // Apply existing session to DOM if present
  const sessionId = getSessionId();
  if (sessionId && document.body) {
    document.body.dataset.session = sessionId;
  }

  // Phase 1: Initialize API (pre-fetches config)
  initApi();

  initialized = true;
  console.log('[MAIN] Phase 1 modules initialized');

  // Return state info for IIFE to use
  return {
    sessionId: getSessionId(),
    isAuthenticated: isUserAuthenticated(),
    trialStartTime: getTrialStartTime()
  };
}

/**
 * Check API health and update status element
 * This bridges api.js with the DOM (apiStatus element)
 */
export async function checkApiAndUpdateStatus() {
  const statusEl = document.getElementById('apiStatus');

  const result = await fetchApiHealth();

  if (statusEl) {
    if (result.ok) {
      statusEl.textContent = 'ready';
      statusEl.className = 'status working';
    } else {
      statusEl.textContent = 'offline';
      statusEl.className = 'status error';
    }
  }

  return result.ok;
}

/**
 * Schedule trial expiry with UI callback
 * Bridges state.js trial logic with DOM (auth modal)
 */
export function setupTrialExpiry(showSignUpPromptFn) {
  if (!isUserAuthenticated() && getTrialStartTime()) {
    scheduleTrialExpiryIfNeeded(showSignUpPromptFn);
  }
}

// Export for IIFE access
window.__WIMD_MODULES__ = {
  initModules,
  checkApiAndUpdateStatus,
  setupTrialExpiry
};

console.log('[MAIN] Module entry point loaded');
