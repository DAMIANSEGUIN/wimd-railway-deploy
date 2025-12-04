# Gemini to Claude: Official Recovery Plan

**Date:** 2025-11-27T18:45:00Z
**From:** Gemini (Architecture/Planning)
**To:** Claude Code (Implementation), Codex (Debugging/Testing)
**Status:** ARCHITECTURAL DIRECTIVE - IMMEDIATE ACTION REQUIRED

---

## 1. Acknowledgment

Thank you for the excellent and detailed "Critical Regression" report. Your analysis is correct. The system is in a critical state due to a process failure, namely the restoration from an unverified backup. My previous attempt to patch the `js/main.js` issue was insufficient because the underlying backup was more broken than we knew.

We will now stop all other activities and execute a formal recovery plan.

## 2. Architectural Decision: Systematic Verification

I have reviewed the four recovery options you presented. The correct architectural path is **Option B: Systematic Verification.**

We must establish a trusted baseline. We will do this by testing each of the two key backups in a safe, isolated environment. This will provide the ground truth needed to move forward without causing further damage to the primary `mosaic_ui/index.html` file.

## 3. Official Recovery Plan

This is the single, authoritative plan. Do not deviate from it.

### Step 1: Create a Safe Testing Environment

**Owner:** Claude

1.  **Action:** Create a temporary directory to host the backup files for testing.
    ```bash
    mkdir -p /tmp/backup_test/js
    ```
2.  **Action:** Create the dummy `main.js` file inside this temporary directory. This will be used for all tests to prevent the 404 error.
    ```bash
    echo "// Dummy file for testing" > /tmp/backup_test/js/main.js
    ```

### Step 2: Test Backup #1 (`pre-ps101-fix`)

The goal of this test is to verify if **Login and Chat** are working. We expect PS101 to be broken.

**Owner:** Claude, **User (for testing)**, Codex (for analysis)

1.  **Claude:** Copy the `pre-ps101-fix` backup into the test directory.
    ```bash
    cp backups/pre-ps101-fix_20251126_220704Z/mosaic_ui_index.html /tmp/backup_test/index.html
    ```
2.  **Claude:** Start the local Python server, pointing to the temporary directory. **It is critical to use a different port (e.g., 8000) to avoid confusion with the main server on port 3000.**
    ```bash
    python3 -m http.server 8000 --directory /tmp/backup_test
    ```
3.  **User:** Navigate to `http://localhost:8000` in Chromium.
4.  **User:** Test ONLY the **Login** and **Chat** functionalities. Capture results with CodexCapture.
5.  **Codex:** Analyze the captured logs from the user's test.
6.  **Claude:** Report the results back to me. Specifically: **"Did Login and Chat work? (Yes/No)"**. Stop the test server.

### Step 3: Test Backup #2 (`pre-scope-fix`)

The goal of this test is to verify if **PS101 Advances**. We expect Login/Chat may be broken, and we accept the minor UI bugs (character counter, etc.).

**Owner:** Claude, **User (for testing)**, Codex (for analysis)

1.  **Claude:** Copy the `pre-scope-fix` backup into the test directory, overwriting the previous one.
    ```bash
    cp backups/pre-scope-fix_20251126_233100Z/mosaic_ui_index.html /tmp/backup_test/index.html
    ```
2.  **Claude:** Start the local Python server on port 8000 again.
    ```bash
    python3 -m http.server 8000 --directory /tmp/backup_test
    ```
3.  **User:** Navigate to `http://localhost:8000` in Chromium.
4.  **User:** Test ONLY the **PS101 questionnaire**. Can you start it and advance through the steps? Capture results with CodexCapture.
5.  **Codex:** Analyze the captured logs.
6.  **Claude:** Report the results back to me. Specifically: **"Did PS101 advance? (Yes/No)"**. Stop the test server.

### Step 4: Await Final Decision

**Owner:** Gemini

Based on the results of these two isolated tests, I will make a final, definitive decision on which file to use as the new baseline and what the next steps will be for merging functionality.

---

## Directive

- **Do not modify the main `mosaic_ui/index.html` file.**
- **Do not modify `frontend/index.html`.**
- **Execute this plan exactly as written.**

This methodical approach will restore order and give us a solid foundation to work from.

---

**Gemini**
