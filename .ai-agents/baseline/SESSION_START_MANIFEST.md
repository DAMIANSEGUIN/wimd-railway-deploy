# Session Start Baseline Measurement
**Date:** 2025-12-09
**Measured By:** Claude Code
**Purpose:** Establish baseline before MCP v1.1 implementation
**Corrected:** 2025-12-09 16:15 - Fixed to match actual start_session.sh output

---

## Current Context Size

**Total:** 30,887 bytes (30.2 KB)

**Breakdown:**
- `CLAUDE.md`: 16,090 bytes (15.7 KB)
- `TROUBLESHOOTING_CHECKLIST.md`: 14,797 bytes (14.4 KB)

**Not loaded by default:**
- `SELF_DIAGNOSTIC_FRAMEWORK.md`: 32,015 bytes (loaded on demand for errors)

---

## Files Currently Loaded at Session Start

From `scripts/start_session.sh`:

1. **CLAUDE.md** - Primary architecture and deployment reference
2. **TROUBLESHOOTING_CHECKLIST.md** - Error prevention and debugging workflows

**Available but not auto-loaded:**
3. **SELF_DIAGNOSTIC_FRAMEWORK.md** - Architecture-specific error handling (load on demand)

---

## Target After MCP Implementation

**Goal:** <10 KB total context at session start (67% reduction from 30KB)

**How:**
- Load summaries (~2KB each) with provenance
- Load retrieval triggers map (~1KB)
- Fetch full docs only when triggered by keywords/errors
- Store full docs in "memory layer" (retrievable but not in working context)

---

## Validation Criteria

After MCP implementation, measure again and verify:
- ✅ Total context size < 10KB
- ✅ Can still access all information when needed
- ✅ No critical constraints lost in summarization
- ✅ Session start faster (less parsing overhead)

---

## Notes

- This is the "working context" that the model sees on every message
- 30KB is consumed before user even starts working
- Every token in working context competes for model attention
- Research shows models struggle with information in middle of long contexts ("Lost in the Middle")
- Reducing this to <10KB should improve:
  - Initial response quality (less context to parse)
  - Sustained performance (more headroom before degradation)
  - Token efficiency (less repeated governance parsing)

---

**Baseline Established:** 30,887 bytes (corrected from initial 64KB measurement)
**Target:** <10,000 bytes
**Reduction:** >67%
