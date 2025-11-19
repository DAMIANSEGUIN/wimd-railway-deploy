# Gemini CLI Workflow for Troubleshooting

**Purpose:** Capture how the Codex Terminal (SSE/CIT) team will pair with Gemini CLI as a terminal-based, repo-embedded assistant while working inside `~/AI_Workspace/WIMD-Railway-Deploy-Project`. Share this with the team so every agent knows the guardrails, expectations, and the precise loop to follow when Gemini is engaged.

---

## 1. Session Context

1. **Project root:** Always start Gemini from `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project` (where `package.json`, `netlify.toml`, `frontend`, `mosaic_ui`, etc., live). This ensures Gemini sees the same files and scripts as the humans.
2. **Baseline prompt:** As soon as Gemini launches:

   ```
   You are helping me debug the Mosaic web app in this folder. The repo contents are the source of truth. Before proposing fixes, always inspect the relevant files, read any logs I paste, and provide specific shell commands tailored for macOS Monterey + zsh. Do not run commands yourself; show me the command and wait for me to execute it.
   ```

3. **Project brief:** Also share an evergreen snapshot in the same session so the assistant understands the stack:

   > "Mosaic is a Next.js/React frontend + Netlify/Railway deployment. Production builds may fail or chat flows may regress (especially around `coachAsk`/`coachSend`). We troubleshoot via `npm run dev/build` and `./scripts` helpers."

   No need to repeat this each turn; refer back to it if Gemini loses focus.

4. **Roles:** Gemini acts as a smart terminal pair—a navigator, log reader, and command recommender—while Gemini’s work is coordinated through this document.

---

## 2. Tight Troubleshooting Loop

1. **Target one symptom:** Always focus on one error or warning (e.g., `API_BASE` warning, production auth probe, or “cannot access X before initialization”). Tell Gemini the symptom and let it read the relevant files/logs before proposing a fix.
2. **Use manual command execution:**
   - Gemini may run non-destructive commands itself when it has permission (e.g., `cat`, `ls`, `rg`, `curl -I`, simple `sed`/`awk` for diagnostics). For commands that could mutate critical files, Gemini must propose them and wait for human execution.
   - Always describe commands clearly before running them ("Running `rg 'API_BASE' mosaic_ui` now then sharing the output"). Humans will copy/paste into the shell as needed, but Gemini can run permissible commands directly if it clarifies intent first.
   - Output from the command (manual or automated) is captured back into Gemini so it can reason forward.
3. **File + log pairing:**
   - Ask Gemini to open specific files (e.g., `frontend/index.html`) and summarize error-prone areas.
   - Provide stack traces or log excerpts immediately after a failing command (`npm run build`, `./scripts/deploy.sh`), so it can map to exact lines.
4. **Iterate:**
   - Accept a patch/diff from Gemini, apply (via `cat <<'EOF' > file` or `apply_patch`), rerun the verifying command, and feed back results.
   - If the patch doesn’t fix it, share the new error and repeat.

---

## 3. Evidence & Documentation

1. **Evidence capture:** In parallel to the Gemini loop, log findings in `.ai-agents/URGENT_DEPLOYMENT_PROCESS_AMBIGUITY_2025-11-18.md` (or a new URGENT file if the issue differs). Include:
   - Timestamped logs.
   - File names and line numbers referenced by Gemini.
   - Commands run and their outputs.
2. **Diagnostic document creation:** Gemini is allowed to create or update diagnostic-focused docs (e.g., `.ai-agents/DIAGNOSIS_AND_SUGGESTED_CHANGES_*.md` or evidence notes) when it clarifies purpose and shares content for human review before finalizing. These docs should always be referenced in the URGENT log.
3. **Handoff prep:** Once a fix is ready, snapshot the relevant command output and file diffs for Claude Code CLI to audit. Mention these in the same URGENT note or `.ai-agents/TEAM_NOTE_*` as applicable.
4. **Communicate results:** When the loop resolves one bug, write a brief summary with evidence paths so the next agent can pick up seamlessly.

---

## 4. Sanity Checks & Self-Healing

1. **Sanity module ideas:** Ask Gemini to help sketch modules that validate critical env vars, ping the AI backend, or log status lines when the app boots. Iterate in the same loop: patch, test, feed back.
2. **No speculative fixes:** Gemini should only propose code changes after pinning the error to files/logs. The fix must be minimal and require explicit approval (“Here’s the diff; run `npm run build` to verify”).
3. **Testing commands:** Keep commands short, safe, and sequential (`npm run lint`, `./scripts/verify_critical_features.sh`, `npm run build`). Gemini can remind which scripts exist via `package.json` if requested.

---

## 5. Summary Guidance for the Team

1. **Gemini CLI is a trusted pair:** treat it like a focused, terminal-resident teammate that sees your whole repo.
2. **Always feed Gemini real data:** logs, stack traces, commands run, file context—without that, it cannot recommend trustworthy fixes.
3. **Document the loop:** capture outputs/decisions in `.ai-agents/` notes so Claude can audit and SSE/CIT agree on next moves.
4. **Use it for one bug at a time:** avoid “fix everything” prompts; keep each session scoped for clarity.

This workflow keeps problems reproducible, ensures evidence trails, and makes Gemini a high-leverage partner for our MSSP deployment workflow. If the team finds this helpful, update this doc with new best practices or example prompts over time.
