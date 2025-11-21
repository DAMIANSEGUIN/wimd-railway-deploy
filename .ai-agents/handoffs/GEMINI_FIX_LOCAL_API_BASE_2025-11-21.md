# Handoff: Fix Local API Base for Development
**To:** Claude Code
**From:** Gemini
**Status:** Ready for Implementation
**Date:** 2025-11-21

## 1. Objective

Temporarily modify the `ensureConfig` function in `mosaic_ui/js/api.js` to correctly resolve the `apiBase` for local development. This will fix the "Fails to fetch" error caused by CORS policy blocking requests to remote servers from `localhost`.

The current implementation fails when run on a local server because it falls back to a remote `apiBase`, causing login requests to be blocked.

## 2. File to Modify

- `mosaic_ui/js/api.js`

## 3. Detailed Instructions

1.  **Locate the `ensureConfig` function** in `mosaic_ui/js/api.js`.

2.  **Modify the `endpoints` array.** Add a new, high-priority endpoint for a common local backend server (`http://localhost:3000/config`).

3.  **Change the final fallback behavior.** If all config fetches fail, ensure the `apiBase` falls back to the relative `API_BASE` constant (`'/wimd'`) instead of a hardcoded remote URL.

**Replace this code block:**
```javascript
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
```

**With this new code block:**
```javascript
export async function ensureConfig() {
  if (apiBase) return apiBase;
  if (configPromise) return configPromise;

  const endpoints = [
    // 1. High-priority local backend server
    'http://localhost:3000/config',
    // 2. Local config file served by current server (e.g. python -m http.server)
    `${window.location.origin}/config`,
    // 3. Production endpoints (will likely fail on localhost due to CORS)
    'https://what-is-my-delta-site-production.up.railway.app/config',
    'https://whatismydelta.com/config'
  ];

  configPromise = (async () => {
    for (const url of endpoints) {
      try {
        const response = await fetch(url, { timeout: 2000 }); // Reduced timeout for local dev
        if (response.ok) {
          const data = await response.json();
          // Use the fetched apiBase, but fall back to the URL's origin if apiBase is missing
          apiBase = data.apiBase || new URL(url).origin;
          console.log('[API] Config loaded from', url, '→', apiBase);
          return apiBase;
        }
      } catch (error) {
        console.warn('[API] Config check failed for', url);
      }
    }
    // CRITICAL FIX: Fallback to relative path for local development, not a remote URL
    apiBase = API_BASE; // API_BASE is '/wimd'
    console.log('[API] All config checks failed. Using relative fallback apiBase:', apiBase);
    return apiBase;
  })();

  return configPromise;
}
```

## 4. Acceptance Criteria

- [ ] When testing locally (e.g., `http://localhost:8000`), the "Login Fails to fetch" error is gone.
- [ ] The browser's Network tab shows that the `/auth/login` request is now being sent to a `localhost` URL (e.g., `http://localhost:3000/auth/login` or `http://localhost:8000/wimd/auth/login`) and **not** to `https://what-is-my-delta-site-production.up.railway.app`.
- [ ] Existing tests for `api.js` still pass.

This change makes local development robust without requiring a remote server or a complex proxy setup for initial testing.
