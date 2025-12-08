# Metadata Standard - Documentation Change Tracking
**Document Metadata:**
- Created: 2025-12-06 by Claude Code
- Last Updated: 2025-12-06 by Gemini
- Status: ACTIVE - Governance requirement

---

## Purpose
This document defines the standardized metadata header and changelog system for all Mosaic Platform governance and deployment documentation.

**Goal:** Enable all team members and AI agents to:
1. Identify last known working deployment version
2. Track who made changes and when
3. Determine if documentation is current or deprecated
4. Audit documentation changes over time

---

## Mandatory Metadata Header
**All governance and deployment files MUST include this header at the top:**
```markdown
**Document Metadata:**
- Created: YYYY-MM-DD by [Agent/User Name]
- Last Updated: YYYY-MM-DD by [Agent/User Name]
- Last Deployment Tag: prod-YYYY-MM-DD (commit: abc1234)
- Status: [ACTIVE / DEPRECATED / DRAFT]
```

### Field Definitions
#### Created
- **Format:** `YYYY-MM-DD by [Name]`
- **Purpose:** Track original author and creation date. Never changes.
#### Last Updated
- **Format:** `YYYY-MM-DD by [Name]`
- **Purpose:** Track most recent editor and edit date. Updates with every change.
#### Last Deployment Tag
- **Format:** `prod-YYYY-MM-DD (commit: abc1234)`
- **Purpose:** Reference last known working production deployment.
- **Source:** From `git describe --tags --abbrev=0` or a canonical deployment record.
- **Updates only when a new production deployment is verified.**
#### Status
- **Format:** One of: `ACTIVE`, `DEPRECATED`, `DRAFT`
- **Purpose:** Prevent use of outdated documentation.

---

## Files Requiring Metadata Headers
This applies to all documents within the governance bundle.

---

## Changelog Requirements
**Required when:** A file undergoes significant revisions.
**Format:**
```markdown
## Changelog
### v1.1 (2025-12-06 by Gemini)
- Summary of changes.
### v1.0 (2025-12-05 by Claude Code)
- Initial version.
```

---

## Metadata Update Protocol
### When Editing a File
1.  Update "Last Updated" field.
2.  Add a changelog entry if applicable.
3.  Update status if applicable.

---

## Validation Checklist
**Before committing documentation changes:**
- [ ] Metadata header present at top of file.
- [ ] "Last Updated" field updated to today.
- [ ] "Last Deployment Tag" is current (if applicable).
- [ ] "Status" field set correctly.
- [ ] Changelog entry added if needed.

---

## Integration with Governance
This standard is a core component of the Mosaic governance and is enforced for all documents in the bundle.