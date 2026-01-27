# MCP Retrieval Triggers Map

**How this works:** When keywords detected in conversation, automatically fetch relevant docs.

## Trigger → Document Mappings

### 1. Error/Failure Keywords

**Keywords:** error, failed, crash, bug, exception, broken, issue, problem, timeout
**Fetch:** TROUBLESHOOTING_CHECKLIST.md
**Why:** Error prevention and debugging workflows

### 2. Deployment Keywords

**Keywords:** deploy, push, render, production, staging, release, rollback
**Fetch:** CLAUDE.md (Deployment Commands section)
**Why:** Deployment procedures and verification

### 3. Database Keywords

**Keywords:** database, postgresql, sqlite, query, migration, schema, connection, SQL
**Fetch:** SELF_DIAGNOSTIC_FRAMEWORK.md (Storage section)
**Why:** Database patterns and error handling

### 4. Test Keywords

**Keywords:** test, pytest, golden, failing test, coverage, unit test
**Fetch:** CLAUDE.md (Testing section), test files
**Why:** Test framework and validation

### 5. Context Overflow (>1000 words in response)

**Trigger:** Agent response length > 1000 words
**Fetch:** CONTEXT_ENGINEERING_CRITICAL_INFRASTRUCTURE.md
**Why:** Agent may be struggling with context, needs guidance

## Implementation Note

This map is used by `.ai-agents/session_context/trigger_detector.py` to determine when to fetch full documentation.

---
**Version:** v1.0
**Last Updated:** 2025-12-09
