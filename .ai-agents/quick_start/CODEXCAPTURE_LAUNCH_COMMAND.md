# CodexCapture Launch Command

**Canonical Reference - Do Not Guess**

## Production Testing

```bash
/Applications/Chromium.app/Contents/MacOS/Chromium --user-data-dir=/Users/damianseguin/CodexChromiumProfile --load-extension=/Users/damianseguin/CodexTools/CodexCapture https://whatismydelta.com
```

## Using Wrapper Script

```bash
/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/scripts/start_browser_for_codex.sh https://whatismydelta.com
```

## CodexCapture Usage

**Keyboard Shortcut:** Command+Shift+Y

**Captures Location:** `~/Downloads/CodexAgentCaptures/`

**When to Capture:**

- After login failure
- When UI breaks
- Before/after state changes
- On any error

## DO NOT use these (incorrect)

❌ `open -a "Chromium"` (doesn't load extension correctly)
❌ `open -a "Google Chrome"` (wrong browser)
❌ Any command with `/path/to/` placeholders
