# Session Start Files — Quick Guide

**Last Updated:** 2026-02-03

---

## Which File to Use?

### Starting a New Session

**Use:** `SESSION_START_CONTROL_SURFACE_v2.2.html`

**How:**
1. Open in browser
2. Copy "Control Surface" section (button 1)
3. Paste into new Claude Code session
4. Claude responds with BOUND statement
5. Grant authorization: "Full permission for this session"

**Why HTML:** Easy click-to-copy, all sections organized, no formatting issues

---

### Resuming After Crash

**Use:** `CRASH_RECOVERY_QUICK_REFERENCE.md`

**How:**
1. Open the file
2. Run "Immediate Checks" section
3. Review findings
4. Report to user
5. Get authorization before continuing

**Why this file:** Quick, focused checklist for recovery

---

### AI Agent Reading During Session

**Use:** `SESSION_START_CONTROL_SURFACE_v2.2.md`

**How:**
- AI reads this automatically if referenced
- Contains all control surface rules
- Includes crash recovery protocol
- Has current project context

**Why this file:** Complete reference, machine-readable markdown

---

## File Inventory

### Primary Files

| File | Purpose | Format | Use Case |
|------|---------|--------|----------|
| `SESSION_START_CONTROL_SURFACE_v2.2.html` | **Start new session** | HTML | Open in browser, click-copy |
| `SESSION_START_CONTROL_SURFACE_v2.2.md` | Complete reference | Markdown | AI reads during session |
| `CRASH_RECOVERY_QUICK_REFERENCE.md` | **Crash recovery** | Markdown | Resume after interruption |

### Supporting Files

| File | Purpose | When to Use |
|------|---------|-------------|
| `NEXT_SESSION_START.md` | Last session summary (Jan 27) | Context about previous work |
| `SESSION_BACKUP_2026_01_27_END.md` | Full session backup (Jan 27) | Deep dive into Jan 27 session |
| `.mosaic/agent_state.json` | Agent state machine | Check current task status |

---

## Quick Start Guide

### Scenario 1: Fresh Start (Normal)

```bash
1. Open: SESSION_START_CONTROL_SURFACE_v2.2.html (in browser)
2. Click: "Copy control surface" button
3. Paste: Into new Claude Code session
4. Say: "Full permission for this session"
5. Start working!
```

---

### Scenario 2: Crash Recovery

```bash
1. Open: CRASH_RECOVERY_QUICK_REFERENCE.md
2. Run: Immediate checks section
3. Check: Session logs (~/.claude/projects/-Users-damianseguin/*.jsonl)
4. Verify: Production health (curl commands)
5. Report: Findings to user
6. Get: Authorization before proceeding
```

---

### Scenario 3: Mid-Session Reference

```bash
# If AI needs to check rules during session:
cat SESSION_START_CONTROL_SURFACE_v2.2.md

# If user wants to see project context:
Open: SESSION_START_CONTROL_SURFACE_v2.2.html (in browser)
Click: Section 4 "Project Context"
```

---

## Authorization Modes Explained

### USER_GO (Default)
```
User: "Check production health"
AI: INTENT_ACK — Awaiting authorization
User: "Go ahead"
AI: [Checks health] STOP
User: "Now check version"
AI: INTENT_ACK — Awaiting authorization
```

**Good for:** Sensitive operations, when you want fine control

---

### SESSION_AUTH_FULL
```
User: "Full permission for this session"
AI: AUTHORIZATION_MODE=SESSION_AUTH_FULL
User: "Check production health and version"
AI: [Checks health] [Checks version] Task complete. STOP
User: "Now update the docs"
AI: [Updates docs] Task complete. STOP
```

**Good for:** Normal work sessions, multiple tasks

---

### SESSION_AUTH_CONTINUOUS
```
User: "Act freely this session. Fix the SSL cert issue."
AI: AUTHORIZATION_MODE=SESSION_AUTH_CONTINUOUS
    [Reads code] [Identifies issue] [Fixes code] [Tests] [Commits]
    SSL cert issue resolved. Ready for next task.
User: "Great. Now update the session state."
AI: [Updates state files without waiting for new USER_GO]
```

**Good for:** Complex multi-step work, autonomous execution

---

## Plain Language Support

**You can say:**
- "Go ahead" instead of `USER_GO`
- "Full permission" instead of `SESSION_AUTH_FULL`
- "Act freely" instead of `SESSION_AUTH_CONTINUOUS`
- "Stop" instead of `USER_STOP`
- "What do you think?" instead of switching to QUESTION lane

**AI will interpret these correctly!**

---

## Testing & Verification Tools

**AI agents have browser testing capabilities:**

- **Playwright**: Headless browser testing for actual UI verification
- **Install**: `npx playwright install chromium`
- **Test files**: Create `test-*.js` scripts for UI testing
- **Screenshots**: Saved to `/tmp/*.png` for visual verification

**Log access:**
- Session logs: `~/.claude/projects/-Users-damianseguin/*.jsonl`
- Debug logs: `~/.claude/debug/*.txt`
- Deployment logs: Render/Netlify dashboards

**When to use:**
- ✅ Required for any UI changes, JavaScript modifications, or frontend deployments
- ✅ User requests "test the UI" or "verify it works"
- ❌ Don't just grep for text - run actual browser tests

**See Control Surface v2.2 section "Testing & Verification Capabilities" for full details.**

---

## Project Context (Current)

```
Directory: /Users/damianseguin/WIMD-Deploy-Project
Status: ✅ All systems operational
Production: https://mosaic-backend-tpog.onrender.com (healthy)
Frontend: https://whatismydelta.com (live)
Last Deploy: dedf22f (Syntax fix in mosaic_ui, Feb 3)
Gates: All 10 passing
```

---

## Verification Commands

```bash
cd /Users/damianseguin/WIMD-Deploy-Project

# Quick checks
curl https://mosaic-backend-tpog.onrender.com/health
./scripts/gate_10_codebase_health.sh
git status

# Full verification
curl https://mosaic-backend-tpog.onrender.com/__version
curl -I https://whatismydelta.com
git log --oneline -5
```

---

## Common Questions

**Q: Which file do I paste into Claude?**
A: Open the HTML file in browser, click "Copy control surface" button, paste that.

**Q: Session crashed mid-work, what do I do?**
A: Open `CRASH_RECOVERY_QUICK_REFERENCE.md`, follow the checklist.

**Q: I want AI to work autonomously, not ask permission constantly.**
A: Say "Full permission for this session" or "Act freely this session"

**Q: How do I revoke permission?**
A: Say "Stop" or "Revoke permission"

**Q: Can I mix formal commands and plain language?**
A: Yes! Use whatever feels natural.

**Q: Where's the crash recovery protocol?**
A: It's in both the HTML (section 6) and `CRASH_RECOVERY_QUICK_REFERENCE.md`

**Q: What if production is down?**
A: Check Render dashboard directly: https://dashboard.render.com

---

## Version History

- **v2.2** (Feb 3, 2026): Session-level auth, plain language, crash recovery
- **v2.1** (Feb 2, 2026): Production truth hierarchy, cold-start protocol
- **v2.0** (Jan 25, 2026): Safe lanes (QUESTION, INTENT)
- **v1.0** (Jan 22, 2026): Initial control surface

---

## Quick Links

**Production:**
- Backend: https://mosaic-backend-tpog.onrender.com
- Frontend: https://whatismydelta.com
- Render: https://dashboard.render.com
- Netlify: https://app.netlify.com

**Local:**
- Project: `/Users/damianseguin/WIMD-Deploy-Project`
- Session logs: `~/.claude/projects/-Users-damianseguin/`
- Debug logs: `~/.claude/debug/`

---

**Ready to start? Open `SESSION_START_CONTROL_SURFACE_v2.2.html` in your browser!**
