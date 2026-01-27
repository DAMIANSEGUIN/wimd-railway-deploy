# INTENT_FRAMEWORK.md
**Version:** 1.0  
**Date:** 2026-01-04  
**Status:** CURRENT  
**Applies to:** ALL AI agents, ALL deliverables

---

## THE PATTERN

```
Intent → Check → Receipt
```

**Before creating ANY deliverable, follow these three steps:**

---

## STEP 1: SHOW INTENT DOC

**Before writing code, creating documents, or making changes, show the user:**

```markdown
# INTENT DOC
## [Task Name]

**TASK:** 
[One sentence: what deliverable am I creating?]

**SCOPE:**
Included:
- [What's covered]
- [What's covered]

Excluded:
- [What's NOT covered]
- [What's NOT covered]

**SOURCES:**
[Specific files/documents I'll use - by exact name]

**CONSTRAINTS:**
- Will NOT fabricate information
- Will NOT embellish or exaggerate
- Will NOT guess on ambiguities
- Will NOT create without searching for existing versions

**UNCERTAIN:**
[Specific questions I need answered before proceeding]
[If none, write "None"]
```

---

## STEP 2: WAIT FOR CONFIRMATION

**Do NOT proceed until user responds with:**

✅ **"Proceed"** - Go ahead as described  
🔄 **"Adjust [X]"** - Modify scope/approach  
❌ **"Stop"** - Wrong interpretation

**If user provides adjustments:**
- Update Intent Doc
- Show revised version
- Wait for confirmation again

---

## STEP 3: PROVIDE RECEIPT

**After delivering the work, confirm what you actually did:**

```markdown
# RECEIPT
## [Task Name]

**SOURCES USED:**
- [Exact documents/files referenced]
- [All sources listed]

**INCLUDED:**
- [What I actually delivered]
- [What features/sections included]

**EXCLUDED:**
- [What I intentionally left out]
- [Why it was excluded]

**JUDGMENT CALLS:**
- [Where I made interpretive decisions]
- [Rationale for each decision]

**NEEDS VERIFICATION:**
- [What user should double-check]
- [Any uncertainties remaining]
```

---

## VERIFICATION CHECKLIST

**Before delivering ANY work, confirm:**

- [ ] All claims sourced from actual documents (no fabrication)
- [ ] No invented responsibilities or embellishments
- [ ] Searched existing docs before asking questions
- [ ] Showed Intent Doc and received confirmation
- [ ] Can defend every statement if challenged
- [ ] Noted where interpretation vs direct quote

---

## WHEN UNCERTAIN

**If a request has 2+ possible interpretations:**

1. **Show the options** to the user
2. **Explain outcome differences** for each interpretation
3. **Ask ONE clear question** to disambiguate

**Default:** Ask rather than guess

**Example:**
```
"This request could mean:

A) Just analyze gaps between job and resume
   → Quick assessment, factual only
   
B) Full application package with rewrite and strategy
   → Complete deliverable, time-intensive

Which do you want?"
```

---

## QUICK COMMANDS

User can invoke these at any time:

| Command | You Do |
|---------|--------|
| **"Show intent"** | Display Intent Doc before proceeding |
| **"Receipt"** | Show what you did vs what was requested |
| **"Sources only"** | List which documents you're using |
| **"Flag assumptions"** | Show where you're interpreting vs quoting |

---

## CRITICAL RULES

### DO ✅
- Search existing docs BEFORE asking questions
- Show Intent Doc for ALL deliverables (code, docs, analysis, everything)
- Use exact sources, cite specifically
- Ask when uncertain (one clear question)
- Provide Receipt after completing work
- Stop immediately if you can't source a claim

### DON'T ❌
- Guess when request has multiple interpretations
- Fabricate information ever
- Embellish or exaggerate claims
- Create deliverables without Intent Doc confirmation
- Skip the verification checklist
- Proceed when uncertain

---

## WHY THIS MATTERS

**Past failures without INTENT Framework:**
- AI fabricated job responsibilities → user had to correct multiple times
- AI created wrong deliverable → wasted time
- AI embellished experience → user couldn't defend in interview
- AI duplicated existing work → didn't search first

**With INTENT Framework:**
- User sees what you'll create BEFORE you create it
- Misunderstandings caught early
- No wasted effort on wrong interpretations
- No fabrications (everything sourced)
- Clear accountability (Receipt shows what was done)

---

## EXAMPLES

### Example 1: Code Creation

**User says:** "Fix the Render deployment"

**WRONG approach:**
- Immediately start coding
- Assume what "fix" means
- Make changes without showing intent

**CORRECT approach:**
```markdown
# INTENT DOC
## Render Deployment Fix

**TASK:** Debug Render deployment errors and implement fixes

**SCOPE:**
Included:
- Review Render logs for error messages
- Fix identified issues in deployment config
- Test deployment after fixes

Excluded:
- Frontend changes
- Database migrations
- New feature additions

**SOURCES:**
- Render logs from recent deployment attempt
- nixpacks.toml configuration
- requirements.txt dependencies

**CONSTRAINTS:**
- Will NOT modify code without understanding root cause
- Will NOT add new dependencies without discussion
- Will NOT change database schema

**UNCERTAIN:**
- Should I also update the health check endpoint, or just fix deployment?
```

*Wait for confirmation → Fix → Provide receipt*

---

### Example 2: Document Creation

**User says:** "Create a resume for this job"

**WRONG approach:**
- Immediately write resume
- Embellish experience
- Add skills not documented

**CORRECT approach:**
```markdown
# INTENT DOC
## Resume Creation

**TASK:** Create tailored resume for [Job Title] position

**SCOPE:**
Included:
- Gap analysis between job requirements and user's experience
- Resume formatted to highlight relevant qualifications
- Cover letter addressing key requirements

Excluded:
- Fabricated responsibilities
- Skills not documented in user's background
- Experience from jobs user didn't hold

**SOURCES:**
- User's LinkedIn profile
- User's master resume document
- Job description provided

**CONSTRAINTS:**
- Will NOT invent responsibilities
- Will NOT exaggerate scope of past work
- Will NOT add skills user hasn't demonstrated
- All claims must be defensible in interview

**UNCERTAIN:**
- Should I include the 2015 consulting work, or focus on recent roles?
```

*Wait for confirmation → Create → Provide receipt*

---

### Example 3: Analysis Request

**User says:** "What's wrong with my code?"

**WRONG approach:**
- Make assumptions about what code
- Guess at the problem
- Provide generic advice

**CORRECT approach:**
```markdown
# INTENT DOC
## Code Analysis

**TASK:** Analyze code for bugs/issues

**SCOPE:**
Included:
- Review error messages and logs
- Identify root cause of issue
- Suggest specific fixes

Excluded:
- Refactoring for style
- Performance optimization
- Adding new features

**SOURCES:**
- Code files provided by user
- Error messages/stack traces
- Log outputs if available

**CONSTRAINTS:**
- Will NOT suggest fixes without understanding the problem
- Will NOT make assumptions about codebase structure
- Will NOT recommend changes that could break other functionality

**UNCERTAIN:**
- Which specific file/function is having issues?
- What error are you seeing?
```

*Wait for clarification → Analyze → Provide receipt*

---

## ENFORCEMENT

**This is NOT optional.**

Every AI agent working with Damian MUST use this framework for every deliverable.

**If you skip this:**
- You may create the wrong thing
- You may fabricate information
- You may waste time
- You will need to redo work

**Better to:**
- Spend 1 minute showing Intent
- Get confirmation
- Build the right thing once

---

## SUMMARY

1. **Before:** Show Intent Doc
2. **During:** Work only on confirmed scope
3. **After:** Provide Receipt

**Every. Single. Time.**

---

END INTENT_FRAMEWORK.md
