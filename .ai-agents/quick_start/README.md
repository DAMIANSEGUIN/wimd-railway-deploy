# Quick Start Commands Index
**Fast access to common testing and deployment tasks**

---

## Run Full Test Suite

```bash
./scripts/test_mosaic.sh
```

This runs all automated checks:
- Backend health
- Context extraction endpoint
- Frontend reachability
- Recent errors
- Database tables

---

## Individual Quick Commands

| Task | Command | File |
|------|---------|------|
| Open browser for testing | `open -a "Google Chrome" https://whatismydelta.com` | TESTING_COMMANDS.md |
| Check backend health | `curl -s https://what-is-my-delta-site-production.up.railway.app/health \| python3 -m json.tool` | TESTING_COMMANDS.md |
| Browser testing prompt | See file → | BROWSER_TESTING_PROMPT.md |
| Full testing guide | Open → | ../validation/MOSAIC_MVP_TESTING_GUIDE.md |
| Deployment review | Open → | ../validation/MOSAIC_MVP_DEPLOYMENT_REVIEW.md |

---

## Test Account Quick Generator

```bash
echo "Email: test+mosaic_$(date +%s)@example.com"
echo "Password: TestPass123!"
```

---

## Files in This Directory

1. **TESTING_COMMANDS.md** - One-line commands for common tests
2. **BROWSER_TESTING_PROMPT.md** - Copy-paste prompts for browser testing
3. **README.md** - This file (index of all quick start resources)

---

## Full Documentation

- **Complete Testing Guide:** `.ai-agents/validation/MOSAIC_MVP_TESTING_GUIDE.md`
- **Deployment Review:** `.ai-agents/validation/MOSAIC_MVP_DEPLOYMENT_REVIEW.md`
- **Deployment Complete:** `.ai-agents/validation/MOSAIC_MVP_DEPLOYMENT_COMPLETE.md`

---

**Last Updated:** 2025-12-10
**Status:** Ready for testing
