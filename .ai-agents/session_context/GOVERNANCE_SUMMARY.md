---
source: CLAUDE.md
commit: 31d099c
lines: 1-600
generated: 2025-12-09T16:20:00Z
schema_version: v1.0
---

# WIMD Railway Deploy - Governance Summary

## Project Identity

- **Name:** Foundation & Mosaic Development (WIMD Railway Deploy)
- **Production URL:** <https://whatismydelta.com> (LIVE ✅)
- **Stack:** FastAPI + PostgreSQL (Railway) + Vanilla JS (Netlify)
- **Repository:** github.com/DAMIANSEGUIN/wimd-railway-deploy
- **Last Deployment:** prod-2025-11-18 (commit: 31d099c)

## Critical Deployment Commands

**ALWAYS use wrapper scripts (never direct git push):**

```bash
./scripts/deploy.sh netlify    # Frontend
./scripts/deploy.sh railway    # Backend
./scripts/push.sh origin main   # Git push with verification
```

**Railway auto-deploys from `origin` main branch (2-5 min)**

## Current Production Status

- ✅ All features operational (auth, chat, job search, resume optimization)
- ✅ Phase 4+ complete (RAG, 12 job sources, cost controls)
- ✅ Deployment verification active

## Architecture Constraints

- **Database:** PostgreSQL (Railway) - use `with get_conn() as conn:` pattern
- **Context Manager Required:** All DB operations must use context manager
- **PostgreSQL Syntax:** Use `%s` not `?`, `SERIAL` not `AUTOINCREMENT`
- **Feature Flags:** Phase 4 features enabled, experiments disabled

## Quality Controls (MANDATORY)

**Before ANY code changes:**

1. Read TROUBLESHOOTING_CHECKLIST.md (error prevention)
2. Read SELF_DIAGNOSTIC_FRAMEWORK.md (architecture errors)
3. Run pre-deployment checks
4. Never commit without verification

## Known Issues

- Email service pending (password reset uses placeholder)
- Job sources deployed but need production testing

## Emergency Rollback

**Last known working:** `git checkout prod-2025-11-18`

---
*Full details in CLAUDE.md - retrieve on demand for deployment, database ops, or troubleshooting*
