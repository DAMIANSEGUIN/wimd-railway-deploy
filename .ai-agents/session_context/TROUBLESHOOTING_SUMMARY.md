---
source: TROUBLESHOOTING_CHECKLIST.md
commit: 31d099c
lines: 1-400
generated: 2025-12-09T16:20:00Z
schema_version: v1.0
---

# Troubleshooting Summary

## Pre-Flight Checklist (Before ANY Code Changes)
- [ ] Context manager pattern? (`with get_conn() as conn:`)
- [ ] PostgreSQL syntax? (`%s` not `?`, `SERIAL`, cursor first)
- [ ] Errors logged explicitly? (no silent exceptions)
- [ ] Idempotent operation? (ON CONFLICT, check before insert)
- [ ] Rollback plan exists?
- [ ] Tested locally?

## Critical Error Patterns

### RAILWAY_RESTART_LOOP
**Symptom:** Container crashes repeatedly
**Fix:** Check deploy logs for exception, verify DATABASE_URL

### PG_CONNECTION_FAILED
**Symptom:** App using SQLite fallback
**Fix:** Verify DATABASE_URL contains `railway.internal`

### CONTEXT_MANAGER_BUG
**Symptom:** AttributeError on conn.execute
**Fix:** Must use `with get_conn() as conn:` not `conn = get_conn()`

### SQLITE_FALLBACK_ACTIVE
**Symptom:** Data wiped on deploy
**Fix:** Check DATABASE_URL, PostgreSQL service status

## Emergency Procedures

### Production Down
1. Check Railway dashboard - service running?
2. Check deploy logs for error
3. Rollback: `git revert HEAD && git push origin main`

### Data Loss Detected
1. Check if PostgreSQL connected (logs for STORAGE messages)
2. If SQLite: no recovery (ephemeral)
3. Ensure DATABASE_URL uses railway.internal

## Quick Commands
```bash
railway logs                    # View logs
curl /health                    # Check health
git checkout prod-2025-11-18   # Rollback
```

---
*Full checklists in TROUBLESHOOTING_CHECKLIST.md - retrieve for detailed debugging workflows*
