// state.js - DOM-free application state management
// Handles session, user data, trial mode, and autosave

// Storage keys
export const SESSION_KEY = 'delta_session_id';
export const USER_DATA_KEY = 'delta_user_data';
export const TRIAL_START_KEY = 'delta_trial_start';
export const QA_TOGGLE_KEY = 'ps101_force_trial';

// Trial configuration
const FORCE_TRIAL = localStorage.getItem(QA_TOGGLE_KEY) === 'true';
export const TRIAL_DURATION = FORCE_TRIAL ? Number.MAX_SAFE_INTEGER : 5 * 60 * 1000; // 5 minutes

// Internal state
let sessionId = '';
let currentUser = null;
let userData = {};
let trialStartTime = null;
let isAuthenticated = false;
let autoSaveInterval = null;
let dirty = false;
let savedThisSession = false;

// Callbacks for DOM updates (allows state → UI communication without DOM dependency)
let sessionCallbacks = [];
let userDataCallbacks = [];

// Safe localStorage helpers
export function safeLocalStorageGet(key, defaultValue = null) {
  try {
    return localStorage.getItem(key) || defaultValue;
  } catch (e) {
    console.warn('[STATE] localStorage.getItem failed:', e);
    return defaultValue;
  }
}

export function safeLocalStorageSet(key, value) {
  try {
    localStorage.setItem(key, value);
  } catch (e) {
    console.warn('[STATE] localStorage.setItem failed:', e);
  }
}

// Session management
export function setSession(id, onSessionChange) {
  if (!id) return;
  sessionId = id;
  safeLocalStorageSet(SESSION_KEY, id);

  // Notify callbacks (for DOM updates)
  if (onSessionChange) {
    onSessionChange(id);
  }
  sessionCallbacks.forEach(cb => cb(id));

  startAutoSave();
}

export function getSessionId() {
  return sessionId;
}

export function registerSessionCallback(callback) {
  if (typeof callback === 'function') {
    sessionCallbacks.push(callback);
  }
}

// User data management
export function saveUserData(data) {
  userData = { ...userData, ...data };
  safeLocalStorageSet(USER_DATA_KEY, JSON.stringify(userData));

  // Notify callbacks
  userDataCallbacks.forEach(cb => cb(userData));
}

export function getUserData() {
  return userData;
}

export function setCurrentUser(user) {
  currentUser = user;
  isAuthenticated = !!user;
}

export function getCurrentUser() {
  return currentUser;
}

export function isUserAuthenticated() {
  return isAuthenticated;
}

export function registerUserDataCallback(callback) {
  if (typeof callback === 'function') {
    userDataCallbacks.push(callback);
  }
}

// Trial mode management
export function startTrial() {
  if (!trialStartTime) {
    trialStartTime = Date.now().toString();
    safeLocalStorageSet(TRIAL_START_KEY, trialStartTime);
    console.log('[STATE] Trial started:', trialStartTime);
  }
  return trialStartTime;
}

export function getTrialStartTime() {
  return trialStartTime;
}

export function checkTrialExpired() {
  if (!trialStartTime) return false;
  const elapsed = Date.now() - parseInt(trialStartTime, 10);
  return elapsed > TRIAL_DURATION;
}

export function scheduleTrialExpiryIfNeeded(onExpire) {
  if (!trialStartTime || isAuthenticated) return;

  const elapsed = Date.now() - parseInt(trialStartTime, 10);
  const remaining = TRIAL_DURATION - elapsed;

  if (remaining > 0) {
    console.log('[STATE] Trial expires in', Math.floor(remaining / 1000), 'seconds');
    setTimeout(() => {
      if (!isAuthenticated) {
        console.log('[STATE] Trial expired');
        if (onExpire) onExpire();
      }
    }, remaining);
  } else {
    console.log('[STATE] Trial already expired');
    if (onExpire) onExpire();
  }
}

// Autosave management
function startAutoSave() {
  if (autoSaveInterval) return; // Already running

  autoSaveInterval = setInterval(() => {
    // This is a placeholder - actual save logic handled by UI layer
    console.log('[STATE] Autosave interval tick');
  }, 30000); // Every 30 seconds
}

export function stopAutoSave() {
  if (autoSaveInterval) {
    clearInterval(autoSaveInterval);
    autoSaveInterval = null;
  }
}

// Snapshot persistence (for UI state)
export function saveAutoSnapshot(snapshot) {
  if (!snapshot || typeof snapshot !== 'object') return;

  const data = {
    ...snapshot,
    timestamp: new Date().toISOString(),
    sessionId: sessionId
  };

  safeLocalStorageSet('auto_save', JSON.stringify(data));
}

export function loadAutoSnapshot() {
  try {
    const saved = safeLocalStorageGet('auto_save');
    if (!saved) return null;

    const data = JSON.parse(saved);
    // Only load if from same session
    if (data.sessionId === sessionId) {
      return data;
    }
    return null;
  } catch (e) {
    console.warn('[STATE] Failed to load auto snapshot:', e);
    return null;
  }
}

// Reset state for testing (not for production use)
export function __resetStateForTesting() {
  sessionId = '';
  currentUser = null;
  userData = {};
  trialStartTime = null;
  isAuthenticated = false;
  autoSaveInterval = null;
  dirty = false;
  savedThisSession = false;
  sessionCallbacks = [];
  userDataCallbacks = [];
}

// Dirty state tracking (for unsaved changes warning)
export function markDirty() {
  dirty = true;
}

export function markClean() {
  dirty = false;
  savedThisSession = true;
}

export function isDirty() {
  return dirty;
}

export function wasSavedThisSession() {
  return savedThisSession;
}

// Initialize state from localStorage
export function initState() {
  console.log('[STATE] Initializing state module');

  // Load session
  sessionId = safeLocalStorageGet(SESSION_KEY, '');
  if (sessionId) {
    console.log('[STATE] Restored session:', sessionId);
  }

  // Load user data
  try {
    const storedData = safeLocalStorageGet(USER_DATA_KEY, '{}');
    userData = JSON.parse(storedData);
  } catch (e) {
    console.warn('[STATE] Failed to parse user data:', e);
    userData = {};
  }

  // Load trial state
  trialStartTime = safeLocalStorageGet(TRIAL_START_KEY);

  // Handle QA override
  if (FORCE_TRIAL && !trialStartTime) {
    trialStartTime = Date.now().toString();
    safeLocalStorageSet(TRIAL_START_KEY, trialStartTime);
    console.log('[STATE] QA trial override active - start timestamp injected');
  } else if (FORCE_TRIAL) {
    console.log('[STATE] QA trial override active - existing timestamp honored');
  }

  console.log('[STATE] Initialization complete', {
    hasSession: !!sessionId,
    hasUserData: Object.keys(userData).length > 0,
    trialActive: !!trialStartTime
  });
}
