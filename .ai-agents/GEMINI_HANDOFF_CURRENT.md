# Gemini Handoff to Gemini CLI — 2025-11-18 11:05 UTC

Share this note in chat when you start Gemini so it knows what to read and what the current focus is. This note also points Gemini to the workflow/template doc that we agreed is the canonical set of guidelines for running Gemini in this repo.

1. **Read the workflow/template:**  
   ```
   Please read `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/GEMINI_CLI_WORKFLOW.md` first—the workflow doc is our canonical template for working with Gemini and contains the guardrails you should never deviate from.
   ```

2. **Then read the session issue:**  
   ```
   After that, read `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/GEMINI_SESSION_20251118_110500.md` to understand the blocker we’re troubleshooting right now.
   ```

3. **Stay in role:**  
   - Don’t execute commands yourself; propose exact macOS Monterey + zsh commands, one shot at a time.  
   - Use the evidence/log hints in the session issue note before suggesting patches.  
   - Ask for additional files/logs if needed; I’ll paste the outputs from my shell.

4. **Document everything:**  
   - Any evidence, commands, or fixes belong in `.ai-agents/URGENT_DEPLOYMENT_PROCESS_AMBIGUITY_2025-11-18.md` or a new URGENT note.  
   - Mention those paths so Claude can later pick up the audit trail.

5. **Relevant deployment assets:**  
   Share status/info from the files below so the evidence trail is complete:  
   - `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/deploy_logs/2025-11-18_ps101-qa-mode.md`  
   - `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/TEAM_NOTE_DEPLOYMENT_FOLLOWUP_2025-11-18.md`  
   - `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/.ai-agents/URGENT_DEPLOYMENT_PROCESS_AMBIGUITY_2025-11-18.md` and any new evidence files (e.g., `.ai-agents/evidence/`).  
   - `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/scripts/verify_critical_features.sh`  
   - `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/Mosaic/PS101_Continuity_Kit/check_spec_hash.sh`  
   - `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/frontend/index.html`, `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/mosaic_ui/index.html`  
   - `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/package.json` and `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/netlify.toml` for build context.  

Once Gemini has processed these two documents, we can run the commands it suggests, copy outputs back to it, and iterate until the warning is explained or resolved.
