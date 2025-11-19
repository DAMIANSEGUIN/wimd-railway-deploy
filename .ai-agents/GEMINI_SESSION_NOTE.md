# Gemini Session Starter (Share in chat to prime Gemini)

Use this note whenever you open a fresh Gemini CLI session. Paste the whole thing into Gemini as your first message (or the first message after the workflow doc), so Gemini knows which files to read and which document is the single source of truth.

1. **Always point Gemini to the workflow doc:**
   ```
   Please read `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/GEMINI_CLI_WORKFLOW.md` first and operate under those rules. It describes how the agents coordinate, how commands are handled, and how evidence is logged.
   ```

2. **Then share the current issue in a dedicated session doc:**  
   I keep the workflow doc stable so it doesn’t need rewriting every session. Instead, I will write each session’s blocker into a new session note named like:
   ```
   /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/GEMINI_SESSION_<YYYYMMDD_HHMM>.md
   ```
   This file holds the specific symptom, logs, and desired outcome for the current loop. After I create that file, share its contents with Gemini in the same turn as the workflow doc so the assistant has both the process and the live issue. The session note can be short (a paragraph plus the latest log snippet) and replaced each time we start troubleshooting.

3. **Reminder to keep commands manual:**  
   Tell Gemini again: “Do not execute commands yourself. Provide one-shot commands that run on macOS Monterey with zsh. I will execute them in my terminal and paste the output for you.”

4. **Logging & handoffs:**  
   Results, logs, and evidence stay in `.ai-agents/URGENT_*` or `.ai-agents/TEAM_NOTE_*`. Mention those files to Gemini after each loop, so Claude can later audit the state.

With this pairing—static workflow doc + per-session issue doc—Gemini stays aligned with the role expectations and every debugging loop stays traceable without re-editing the workflow guidance. Share this note first and then follow up with the current session file whenever you restart a session.
