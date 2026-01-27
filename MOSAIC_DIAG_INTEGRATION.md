# mosaic-diag Integration Guide

**Created:** 2025-12-04
**Purpose:** Integrate mosaic-diag v2.0 into Mosaic project workflow
**Status:** Ready for team review

---

## What is mosaic-diag?

A headless diagnostic + prognostic system that:

✅ **Prevents recurring blockers** by running preflight checks
✅ **Tracks incident patterns** with structured logging
✅ **Provides CI-friendly outputs** (JSON, exit codes)
✅ **Enables data-driven improvements** (metrics, trends)

**Based on:** `RECURRING_BLOCKERS.md` patterns + `mosaic_diag_spec_v2.0.md`

---

## Quick Start

### 1. Test It Now

```bash
# Check your Python environment
python3 mosaic-diag/cli.py preflight env

# Check deployment prerequisites
python3 mosaic-diag/cli.py preflight deploy

# Log the current Render blocker
python3 mosaic-diag/cli.py incident add \
  --category deployment \
  --severity high \
  --symptom "Render auto-deploy not pulling new code" \
  --root-cause "GitHub webhook broken"

# Review recent incidents
python3 mosaic-diag/cli.py incidents --limit 5
```

### 2. Expected Output

You should see Python 3.7 flagged as too old:

```
ENVIRONMENT:
  ❌ env.python_version
     Python 3.7 is too old (need 3.9+)
```

This validates the system works!

---

## Integration Points

### Integration 1: Pre-Deployment Checks

**Add to `scripts/deploy.sh`** (before git push):

```bash
# Run preflight checks
python3 mosaic-diag/cli.py preflight deploy

if [ $? -ne 0 ]; then
    echo "❌ Preflight checks failed - deployment aborted"
    echo "Run: python3 mosaic-diag/cli.py preflight deploy"
    exit 1
fi
```

**This prevents:**

- BUILD_ID loop (Blocker #1B)
- Deploying with uncommitted changes
- Branch configuration mismatches

---

### Integration 2: Session Start Protocol

**Update `SESSION_START.md` Gate 1:**

```markdown
**□ 1. Read `TEAM_PLAYBOOK.md` Section 1 (Quick Start) - 5 minutes**

**□ 2. Run preflight checks:**
```bash
python3 mosaic-diag/cli.py preflight all
```

If checks fail, review output before proceeding.

**□ 3. Review recent blockers:**

```bash
python3 mosaic-diag/cli.py incidents --limit 5
```

Know what patterns to avoid.

**□ 4. Read `TEAM_PLAYBOOK.md` Section 2 (Current Sprint Status) - 2 minutes**

```

**This prevents:**
- Python environment issues (Blocker #2A, #2B)
- Repeating recent mistakes

---

### Integration 3: Incident Logging Protocol

**When ANY blocker occurs**, agents should:

1. **Log it immediately:**
   ```bash
   python3 mosaic-diag/cli.py incident add \
     --category <deployment|environment|permissions|documentation> \
     --severity <critical|high|medium|low> \
     --symptom "What happened" \
     --root-cause "Why it happened" \
     --resolution "How it was fixed"
   ```

2. **Update RECURRING_BLOCKERS.md** if new pattern

3. **Add prevention to TEAM_PLAYBOOK.md** if applicable

**This enables:**

- Pattern detection (recurrence tracking)
- Data-driven prioritization
- Automated prevention suggestions (future phase)

---

### Integration 4: CI/CD Pipeline

**GitHub Actions** (`.github/workflows/deploy.yml`):

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  preflight:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Run Preflight Checks
        run: |
          python3 mosaic-diag/cli.py preflight all --json > preflight_results.json

          # Fail if critical checks failed
          if grep -q '"status": "fail"' preflight_results.json; then
            echo "❌ Preflight checks failed"
            python3 mosaic-diag/cli.py preflight all
            exit 1
          fi

      - name: Upload Preflight Results
        uses: actions/upload-artifact@v3
        with:
          name: preflight-results
          path: preflight_results.json
```

**This prevents:**

- Deploying broken code
- Environment mismatches
- Configuration drift

---

## Gemini Review Requirements

**Does Gemini need to review this implementation?**

**My Assessment: YES - Architecture review recommended**

**Reasons:**

1. **New system integration** - Affects deployment workflow
2. **Cross-team impact** - All agents will use this
3. **Data persistence** - JSONL storage patterns should be validated
4. **Security check** - No credentials exposed in preflight checks?

**Specific Review Requests for Gemini:**

1. **Architecture Validation:**
   - Is JSONL append-only pattern appropriate?
   - Should we use SQLite instead for incident storage?
   - Are check implementations deterministic enough?

2. **Integration Safety:**
   - Will this break existing deployment workflow?
   - Should preflight checks be blocking or advisory initially?
   - Are exit codes CI-friendly?

3. **Edge Cases:**
   - What happens if `mosaic-diag/diagnostics/` gets corrupted?
   - How do we handle concurrent writes (multiple agents)?
   - Should there be size limits on incident log?

4. **Team Protocol:**
   - Is integration into SESSION_START.md too intrusive?
   - Should this be opt-in initially or mandatory?
   - Do we need training for human user?

---

## Rollout Plan

**Phase 1: Testing (Now - Week 1)**

- [x] System implemented and working
- [ ] Gemini architecture review
- [ ] Human user tests locally
- [ ] Document any issues found

**Phase 2: Advisory Mode (Week 2)**

- [ ] Add to SESSION_START.md (non-blocking)
- [ ] Agents run preflight, log results, but don't block work
- [ ] Collect incident data for 1 week

**Phase 3: Blocking Mode (Week 3)**

- [ ] Add to `scripts/deploy.sh` (blocks deployment if critical checks fail)
- [ ] Add to CI/CD pipeline
- [ ] Become canonical workflow

**Phase 4: Prognostic Engine (Future)**

- [ ] Implement recurrence detection
- [ ] Implement clustering (Phase 2 of spec)
- [ ] Generate automated suggestions

---

## Success Metrics

**After 1 week:**

- [ ] 10+ incidents logged
- [ ] 0 duplicate Python environment issues (Blocker #2A/2B)
- [ ] 0 BUILD_ID loop incidents (Blocker #1B)

**After 1 month:**

- [ ] 50+ incidents logged
- [ ] 3+ new preflight checks added based on patterns
- [ ] 20% reduction in blocker time lost

---

## Files Created

```
mosaic-diag/
├── cli.py              # CLI entrypoint (executable)
├── storage.py          # Atomic file I/O
├── preflight.py        # Check registry + execution
├── incidents.py        # Incident logging + classification
├── README.md           # Full documentation
└── diagnostics/        # Data directory (created on first use)
    ├── incidents.jsonl
    ├── roadmap.json
    ├── check_suggestions.json
    ├── doc_suggestions.json
    └── roadmap_suggestions.json
```

**Also Created:**

- `RECURRING_BLOCKERS.md` - Blocker pattern analysis
- `MOSAIC_DIAG_INTEGRATION.md` - This document

**Modified:**

- `TEAM_PLAYBOOK.md` - Added Section 4 (Local Dev Setup), Communication Protocol

---

## Next Actions

**For User:**

1. Review this document
2. Test mosaic-diag locally (run commands above)
3. Decide: Should Gemini review before rollout?
4. If yes: Share this document + `mosaic-diag/` directory with Gemini

**For Gemini (if review requested):**

1. Review architecture (storage, checks, incidents)
2. Validate integration points
3. Identify risks/edge cases
4. Approve rollout or request changes

**For Claude Code (me):**

1. Wait for feedback
2. Address any issues found
3. Proceed with rollout per plan

---

## Questions for Discussion

1. **Should preflight checks be blocking from day 1?** Or start advisory?
2. **Should this be mandatory in SESSION_START.md?** Or opt-in?
3. **Who maintains incident log?** All agents or designated role?
4. **How often to review incidents?** Weekly? After each blocker?
5. **Should we add more checks now?** (Render webhook status, etc.)

---

**END OF INTEGRATION GUIDE**

**Status:** Ready for team review and Gemini architecture validation.
