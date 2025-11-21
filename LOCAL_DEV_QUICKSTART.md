# Local Development Quick Start

## 🚀 Start Local Server

```bash
cd /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project
python3 local_dev_server.py
```

You'll see:
```
🚀 Local dev server running on http://localhost:3000
📡 Proxying API requests to https://what-is-my-delta-site-production.up.railway.app
📁 Serving static files from mosaic_ui/

✅ Open http://localhost:3000 in your browser
```

## 🌐 Open in Browser

**Easy way:**
- Double-click **OpenLocalhost.command** on your Desktop

**Manual way:**
- Open Chromium
- Go to `http://localhost:3000`

## ✅ What Should Work Now

- ✅ Login/logout/register
- ✅ PS101 flow (all 10 steps)
- ✅ Chat/coach interface
- ✅ File upload
- ✅ Job search
- ✅ No CORS errors

## 🛠️ Troubleshooting

### Server not running?
```bash
# Check status
curl http://localhost:3000/config

# Restart server
python3 local_dev_server.py
```

### Login still fails?
1. Check browser console for errors (Cmd+Option+J)
2. Check server logs: `tail -20 /tmp/dev_server.log`
3. Use CodexCapture (puzzle piece icon) to record issue

### Wrong port?
The desktop shortcut now uses port **3000** (not 8000)

## 📋 Testing Checklist

Use Codex's checklist to verify:
- [ ] Login works
- [ ] Logout works
- [ ] Register new user
- [ ] PS101 flow completes
- [ ] Chat responds
- [ ] File upload works
- [ ] Job search returns results

## 📸 Recording Issues

1. Click puzzle piece icon (CodexCapture) in browser
2. Captures saved to `~/Downloads/CodexAgentCaptures/`
3. Team can access latest in `.ai-agents/CodexCapture_*/`

## 🔄 Stopping Server

```bash
# Find and kill the server process
kill $(cat /tmp/dev_server.pid)
```

## 📚 More Info

See detailed documentation:
- `.ai-agents/CLAUDE_CODE_LOCAL_DEV_SETUP_COMPLETE_2025-11-21.md`
- `.ai-agents/HANDOFF_PHASE1_COMPLETE_2025-11-21.md`

---

**Last Updated:** 2025-11-21 12:50 PM
**Created By:** Claude Code (Sonnet 4.5)
