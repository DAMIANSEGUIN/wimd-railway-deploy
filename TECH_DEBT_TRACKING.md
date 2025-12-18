# Technical Debt & Issues Tracking

**Created**: 2025-12-05
**Purpose**: Track recurring issues and technical debt that need resolution
**Status**: Active

---

## 🔴 CRITICAL: Multiple File Name Confusion

**Issue**: Multiple files with similar or identical names exist in different locations, creating confusion during session startup and command execution.

**Impact**:

- AI agents waste time searching for correct file
- Risk of reading outdated/wrong version of documentation
- Command paths become ambiguous
- Session initialization slower than necessary

**Examples Found**:

- `SESSION_START.md` exists in at least 6 different directories:
  - `/Users/damianseguin/wimd-railway-local/SESSION_START.md`
  - `/Users/damianseguin/Planning/SESSION_START.md`
  - `/Users/damianseguin/Planning/systems_cli/SESSION_START.md`
  - `/Users/damianseguin/AI_Workspace/Planning/SESSION_START.md`
  - `/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/SESSION_START.md` (canonical)
  - `/Users/damianseguin/Downloads/Planning/SESSION_START.md`

**Root Causes**:

1. Multiple project clones/copies across directories
2. No clear canonical location documented
3. Legacy project structure retained
4. No automated cleanup of outdated copies

**Recommended Actions**:

1. **Immediate**: Document canonical locations in TEAM_PLAYBOOK.md
2. **Short-term**: Create symbolic links from legacy locations to canonical files
3. **Medium-term**: Archive non-canonical copies to clearly marked archive directories
4. **Long-term**: Implement automated checks to detect duplicate configuration files

**Priority**: High (affects all AI agents, every session)

**Assigned To**: TBD

**Status**: Open - Documented 2025-12-05

---

## Template for Future Issues

**Issue**: [Brief description]

**Impact**: [How this affects development/production]

**Root Causes**: [Why this happened]

**Recommended Actions**: [Prioritized list of fixes]

**Priority**: Critical / High / Medium / Low

**Assigned To**: [Team member or TBD]

**Status**: Open / In Progress / Resolved

---

## Resolved Issues

(Issues will be moved here once resolved, with resolution date and notes)

---

**END OF TECH_DEBT_TRACKING.md**
