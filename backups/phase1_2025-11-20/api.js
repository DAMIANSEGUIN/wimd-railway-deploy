// api.js - Network and Backend Access
// All fetch calls and backend communication

import { getSessionId } from './state.js';

// API configuration
const API_BASE = '/wimd';
let apiBase = '';
let configPromise = null;

/**
 * Ensure API configuration is loaded
 * Tries multiple endpoints in order until one succeeds
 */
export async function ensureConfig() {
  if (apiBase) return apiBase;
  if (configPromise) return configPromise;

  const endpoints = [
    `${window.location.origin}/config`,
    'https://what-is-my-delta-site-production.up.railway.app/config',
    'https://whatismydelta.com/config'
  ];

  configPromise = (async () => {
    for (const url of endpoints) {
      try {
        const response = await fetch(url, { timeout: 5000 });
        if (response.ok) {
          const data = await response.json();
          apiBase = data.apiBase || API_BASE;
          console.log('[API] Config loaded from', url, '→', apiBase);
          return apiBase;
        }
      } catch (error) {
        console.warn('[API] Config fetch failed for', url, error.message);
      }
    }
    // Fallback
    apiBase = API_BASE;
    console.log('[API] Using fallback apiBase:', apiBase);
    return apiBase;
  })();

  return configPromise;
}

/**
 * Generic JSON API call helper
 * Automatically handles session headers, content type, and error parsing
 */
export async function callJson(path, { method = 'GET', body, headers = {}, signal } = {}) {
  await ensureConfig();

  const init = { method, headers: { ...headers } };

  if (signal) {
    init.signal = signal;
  }

  if (body !== undefined) {
    if (body instanceof FormData) {
      init.body = body;
    } else {
      init.headers['Content-Type'] = 'application/json';
      init.body = JSON.stringify(body);
    }
  }

  // Add session header if available
  const sessionId = getSessionId();
  if (sessionId) {
    init.headers['X-Session-ID'] = sessionId;
  }

  const url = path.startsWith('http') ? path : `${apiBase}${path}`;

  try {
    const response = await fetch(url, init);

    if (!response.ok) {
      const errorText = await response.text();
      let errorMessage;
      try {
        const errorJson = JSON.parse(errorText);
        errorMessage = errorJson.detail || errorJson.message || errorText;
      } catch {
        errorMessage = errorText || `HTTP ${response.status}`;
      }
      throw new Error(errorMessage);
    }

    return await response.json();
  } catch (error) {
    console.error('[API] callJson error:', path, error);
    throw error;
  }
}

/**
 * Fetch API health status
 * Returns { ok: boolean, data?: object }
 */
export async function fetchApiHealth() {
  try {
    const response = await fetch(`${API_BASE}/health`, {
      method: 'GET',
      timeout: 5000
    });

    if (response.ok) {
      const data = await response.json();
      return { ok: data.ok === true, data };
    }
    return { ok: false };
  } catch (error) {
    console.warn('[API] Health check failed:', error.message);
    return { ok: false, error: error.message };
  }
}

/**
 * Register a new user
 */
export async function registerUser({ email, password, discountCode = null }) {
  const body = { email, password };
  if (discountCode) {
    body.discount_code = discountCode;
  }

  return await callJson('/auth/register', {
    method: 'POST',
    body
  });
}

/**
 * Login an existing user
 */
export async function loginUser({ email, password }) {
  return await callJson('/auth/login', {
    method: 'POST',
    body: { email, password }
  });
}

/**
 * Logout current user
 */
export async function logoutUser(oldSessionId = null) {
  const headers = {};
  if (oldSessionId) {
    headers['X-Session-ID'] = oldSessionId;
  }

  return await callJson('/auth/logout', {
    method: 'POST',
    headers
  });
}

/**
 * Upload a file with optional prompt
 */
export async function uploadWimdFile(file, prompt = 'Please analyze this file and provide career coaching insights.') {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('prompt', prompt);

  const response = await fetch(`${API_BASE}/wimd/upload`, {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }

  return await response.json();
}

/**
 * Search for jobs
 */
export async function searchJobs({ query, location = 'Toronto, ON', maxResults = 5 }) {
  const response = await fetch(`${API_BASE}/jobsearch`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      query,
      location,
      max_results: maxResults
    })
  });

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }

  return await response.json();
}

/**
 * Ask the career coach
 */
export async function askCoach(prompt, { timeout = 15000 } = {}) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const payload = { prompt: prompt.trim() };
    const data = await callJson('/wimd', {
      method: 'POST',
      body: payload,
      signal: controller.signal
    });

    const message = data?.result?.message ?? data?.result ?? data?.message ?? '';
    return typeof message === 'string' ? message.trim() : '';
  } catch (error) {
    if (error.name === 'AbortError') {
      return 'request timed out - please try again';
    }
    console.error('[API] Coach API error:', error);
    return `connection issue (${error.message || 'unknown error'})`;
  } finally {
    clearTimeout(timeoutId);
  }
}

/**
 * Initialize API module (optional one-time setup)
 */
export function initApi() {
  console.log('[API] Initializing API module');
  // Pre-fetch config in background
  ensureConfig().catch(err => {
    console.warn('[API] Background config fetch failed:', err);
  });
}

// Export API_BASE for modules that need direct access
export { API_BASE };
