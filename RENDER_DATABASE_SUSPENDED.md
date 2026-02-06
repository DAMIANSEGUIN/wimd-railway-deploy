# CRITICAL: Render Database Suspended

**Status**: 2026-02-06 13:45 PST

## Issue
PostgreSQL database `mosaic-db` is **suspended** due to billing.

```json
{
  "status": "suspended",
  "suspended": "suspended",
  "suspenders": ["billing"],
  "expiresAt": "2026-02-04T23:29:26.02535Z"
}
```

## Impact
- Backend returns 502 errors
- Chat window cannot connect
- PS101 cannot save progress
- All API endpoints fail

## Resolution Required

### Option 1: Update Payment Method (Recommended)
1. Go to https://dashboard.render.com/d/dpg-d5e4ilali9vc73esoj2g-a
2. Update billing information
3. Resume database service
4. Wait 2-3 minutes for database to start
5. Restart backend: `render services restart srv-d5e4j0qli9vc73esori0`

### Option 2: Switch to Free Tier SQLite (Temporary)
- Remove `DATABASE_URL` from backend env vars
- Backend will fall back to SQLite
- **WARNING**: Data will be lost on each deploy

## Service IDs
- Database: `dpg-d5e4ilali9vc73esoj2g-a`
- Backend: `srv-d5e4j0qli9vc73esori0`
- Dashboard: https://dashboard.render.com

## Next Steps After Resume
```bash
# Wait for database to resume, then:
render services restart srv-d5e4j0qli9vc73esori0 -o json
# Verify: curl https://mosaic-backend-tpog.onrender.com/health
```
