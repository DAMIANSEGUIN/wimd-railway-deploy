# PROTOCOL ISSUE: File Naming Ambiguity

**Created:** 2026-01-24
**Severity:** HIGH - Causes confusion and errors
**Status:** NEEDS PROTOCOL UPDATE

---

## THE PROBLEM

**Current Protocol Says:** "NEVER use absolute paths" (MANDATORY_AGENT_BRIEFING.md)

**But This Creates Ambiguity When:**

Multiple files have the same name in different locations:
```
.git/hooks/pre-push          (ACTIVE - installed git hook, outdated)
.mosaic/enforcement/pre-push  (REFERENCE - newer version, not installed)
.githooks/pre-push            (UNKNOWN - another version)
```

When someone says "pre-push", which file do they mean?

---

## CONCRETE EXAMPLE FROM TODAY

**What happened:**
1. Claude Code wrote: "Check .mosaic/enforcement/pre-push"
2. User couldn't find it
3. Gemini looked for it, couldn't locate it
4. Turns out there are THREE files named "pre-push"
5. The ACTIVE one (.git/hooks/pre-push) is different from the REFERENCE one

**Why it happened:**
- Relative path "pre-push" is ambiguous
- Absolute paths are prohibited
- No clear naming convention for "active vs reference" versions

---

## ROOT CAUSE

**Protocol Conflict:**

```
MANDATORY_AGENT_BRIEFING.md:
❌ WRONG: /Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project/api/index.py
✅ CORRECT: api/index.py
```

**This works for unique file paths:**
- `api/index.py` - Only one file with this path ✅
- `CLAUDE.md` - Only one file with this name ✅

**But breaks for duplicate names:**
- `pre-push` - THREE different files ❌
- `config.json` - Could be anywhere ❌
- `test.sh` - Many test scripts ❌

---

## EXAMPLES OF NAMING AMBIGUITY

### Example 1: Hooks
```
Which "pre-push" file?
- .git/hooks/pre-push         (installed, runs on git push)
- .mosaic/enforcement/pre-push (reference implementation)
- .githooks/pre-push           (legacy?)
```

### Example 2: Config Files
```
Which "config.json" file?
- .mosaic/config.json          (agent config?)
- frontend/config.json         (frontend config?)
- backend/config.json          (backend config?)
```

### Example 3: Documentation
```
Which "README.md" file?
- README.md                    (root)
- docs/README.md               (documentation)
- .mosaic/enforcement/README.md (enforcement docs)
- api/README.md                (API docs)
```

---

## PROPOSED PROTOCOL CHANGES

### Option A: Always Use Full Relative Paths
```markdown
❌ WRONG: "Check pre-push"
✅ CORRECT: "Check .git/hooks/pre-push"

❌ WRONG: "Update config.json"
✅ CORRECT: "Update .mosaic/config.json"
```

**Pros:**
- No ambiguity
- Still relative (cross-agent compatible)
- Clear which file is meant

**Cons:**
- More verbose
- Agents must know directory structure

### Option B: Unique File Naming Convention
```markdown
Instead of:
  .git/hooks/pre-push
  .mosaic/enforcement/pre-push

Use:
  .git/hooks/pre-push
  .mosaic/enforcement/pre-push.template

Or:
  .git/hooks/git-pre-push-hook
  .mosaic/enforcement/mosaic-pre-push-reference
```

**Pros:**
- Files have unique names
- No ambiguity
- Short references work

**Cons:**
- Requires renaming existing files
- Breaking change

### Option C: Context-Aware References
```markdown
When referencing files, specify context:

"The INSTALLED git hook at .git/hooks/pre-push"
"The REFERENCE implementation at .mosaic/enforcement/pre-push"

Or use qualifiers:
- "active pre-push" = .git/hooks/pre-push
- "reference pre-push" = .mosaic/enforcement/pre-push
```

**Pros:**
- Human-readable
- Context makes intent clear
- No file renames needed

**Cons:**
- Requires consistent qualifier usage
- More verbose

### Option D: File Registry
```markdown
Create .mosaic/FILE_REGISTRY.json:

{
  "pre-push": {
    "active": ".git/hooks/pre-push",
    "reference": ".mosaic/enforcement/pre-push",
    "legacy": ".githooks/pre-push"
  },
  "config": {
    "mosaic": ".mosaic/config.json",
    "frontend": "frontend/config.json"
  }
}
```

**Pros:**
- Single source of truth
- Can track active vs reference vs legacy
- Machine-readable

**Cons:**
- New file to maintain
- Requires agents to check registry

---

## IMMEDIATE FIXES NEEDED

### 1. Clarify Current Pre-Push Situation
```bash
# Active hook (what runs on git push):
.git/hooks/pre-push

# Reference implementation (newer, correct):
.mosaic/enforcement/pre-push

# Legacy (unknown purpose):
.githooks/pre-push
```

**Action:** Document which is authoritative

### 2. Update Protocol Documents
```
Files to update:
- MANDATORY_AGENT_BRIEFING.md
- CROSS_AGENT_PROTOCOL.md
- SESSION_INIT.md

Add rule:
"ALWAYS use full relative paths when files with same name exist in multiple locations"
```

### 3. Create Naming Standards
```markdown
# PROPOSED STANDARD

When multiple versions of a file exist:

Active/Installed:  [filename]
Reference/Template: [filename].template or [filename].reference
Legacy/Backup:     [filename].legacy or [filename].backup

Examples:
.git/hooks/pre-push              (active - what runs)
.mosaic/enforcement/pre-push     (reference - correct version)
.githooks/pre-push.legacy        (old version, kept for reference)
```

---

## IMPACT ANALYSIS

**Who is affected:**
- All AI agents (Claude, Gemini, ChatGPT)
- User (when searching for files)
- Documentation writers

**How often does this happen:**
- Pre-push hook confusion (today)
- Config files (potential)
- Test scripts (potential)
- Any file with a common name

**Cost of NOT fixing:**
- Continued confusion
- Wasted time searching
- Incorrect file references
- Agents editing wrong files

---

## RECOMMENDATION

**Immediate (Today):**
1. Adopt Option A: Always use full relative paths
2. Update VALIDATION_REQUEST_FOR_GEMINI.md with correct paths
3. Document which pre-push file is active vs reference

**Short-term (This Week):**
1. Update protocol documents with new rule
2. Rename legacy/backup files with .legacy or .backup extension
3. Create .mosaic/FILE_REGISTRY.json for common duplicate names

**Long-term (Next Sprint):**
1. Audit repo for duplicate file names
2. Establish naming conventions
3. Add pre-commit check for duplicate names in critical directories

---

## QUESTIONS FOR USER/GEMINI

1. **Which option do you prefer?**
   - A: Always full relative paths
   - B: Unique file naming
   - C: Context-aware references
   - D: File registry
   - E: Combination of above

2. **Should we rename existing files?**
   - Rename .githooks/pre-push → .githooks/pre-push.legacy
   - Rename .mosaic/enforcement/pre-push → .mosaic/enforcement/pre-push.template
   - Keep as-is, just use full paths

3. **What's the authoritative pre-push hook?**
   - .git/hooks/pre-push (currently active)
   - .mosaic/enforcement/pre-push (newer, mentions Render)
   - Should we replace active with reference version?

---

**END OF PROTOCOL ISSUE DOCUMENTATION**

**Status:** AWAITING DECISION - Do not make changes until user/Gemini validate approach
