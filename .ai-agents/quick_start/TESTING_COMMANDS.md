# Quick Start Testing Commands

**One-Command Testing Shortcuts**

---

## Open Chrome for Testing

```bash
open -a "Google Chrome" https://whatismydelta.com
```

---

## Backend Health Check

```bash
curl -s https://what-is-my-delta-site-production.up.render.app/health | python3 -m json.tool
```

---

## Check Logs for Errors

```bash
render logs | grep -iE "error|warn|exception|context extraction" --color=always | tail -50
```

---

## Verify Context Extraction Endpoint

```bash
curl -X POST https://what-is-my-delta-site-production.up.render.app/api/ps101/extract-context \
  -H "Content-Type: application/json" \
  -v 2>&1 | grep -E "HTTP|404|401|422"
```

Expected: HTTP 422 (means endpoint exists, just needs auth)

---

## Database Quick Check

```bash
render run psql $DATABASE_URL -c "SELECT COUNT(*) FROM user_contexts;"
```

---

## Full Test Suite (All Checks)

```bash
#!/bin/bash
echo "=== Mosaic MVP Quick Test Suite ==="
echo ""
echo "1. Backend Health:"
curl -s https://what-is-my-delta-site-production.up.render.app/health | python3 -m json.tool
echo ""
echo "2. Context Endpoint (expect 422):"
curl -X POST https://what-is-my-delta-site-production.up.render.app/api/ps101/extract-context -v 2>&1 | grep "HTTP"
echo ""
echo "3. Recent Logs:"
render logs | grep -iE "error|warn" --color=always | tail -10
echo ""
echo "4. Database Context Count:"
render run psql $DATABASE_URL -c "SELECT COUNT(*) FROM user_contexts;"
echo ""
echo "=== Test Suite Complete ==="
```

---

## Test Account Generator

```bash
# Generate unique test email
echo "test+mosaic_$(date +%s)@example.com"
```

---

## Monitor Live (Auto-Refresh Health)

```bash
watch -n 30 'curl -s https://what-is-my-delta-site-production.up.render.app/health | python3 -m json.tool'
```
