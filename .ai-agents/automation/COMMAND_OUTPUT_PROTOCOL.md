# Command Output Protocol

**Technical Enforcement for Copy-Paste Safe Commands**

**Document Metadata:**

- Created: 2025-12-11 by Claude Code
- Last Updated: 2025-12-11 by Claude Code
- Last Deployment Tag: prod-2025-11-18 (commit: 31d099c)
- Status: ACTIVE

---

## PROBLEM

Commands with line breaks fail when user copy-pastes:

```bash
# BROKEN - line break in middle of URL
curl https://what-is-my-delta-site-production.up.render.app/health/compre
  hensive
```

Result: Command fails, user wastes time, erodes trust.

---

## SOLUTION: THREE-LAYER ENFORCEMENT

### Layer 1: Pre-Output Validation Script

Every command must pass through validator before being shown to user:

```bash
# Located at: .ai-agents/automation/validate_command_output.sh
./validate_command_output.sh "COMMAND_HERE"
```

Validator checks:

- No line breaks mid-command
- No word wrapping
- Single continuous line
- Valid bash syntax
- Executable files exist

### Layer 2: Markdown Code Block Rules

**RULE 1:** Always use triple backticks with bash language tag

```bash
# CORRECT
curl https://example.com/api
```

**RULE 2:** Never allow line wrapping - use backslash continuation if needed

```bash
# If URL is long, use explicit backslash
curl https://very-long-domain-name.com/api/endpoint \
  --header "Content-Type: application/json" \
  --data '{"key": "value"}'
```

**RULE 3:** Test command before output

```bash
# Run this FIRST before showing to user
bash -n <(echo "COMMAND_HERE")
```

### Layer 3: Format Enforcement Function

**Add to enforce_validation.sh:**

```bash
format_command_for_output() {
    local COMMAND="$1"

    # Check for unintended line breaks
    if echo "$COMMAND" | grep -qE '\n[[:space:]]+[[:alnum:]]'; then
        echo "❌ ERROR: Command has line break mid-word"
        echo "   This will fail when user copy-pastes"
        return 1
    fi

    # Check for line length > 120 chars without proper continuation
    if [ ${#COMMAND} -gt 120 ]; then
        if ! echo "$COMMAND" | grep -q '\\$'; then
            echo "⚠️  WARNING: Long command without backslash continuation"
            echo "   Consider adding explicit line breaks with \\"
        fi
    fi

    # Ensure single line or proper multi-line
    local LINE_COUNT=$(echo "$COMMAND" | wc -l | tr -d ' ')
    if [ "$LINE_COUNT" -gt 1 ]; then
        # Multi-line must have backslash continuations
        if ! echo "$COMMAND" | grep -qE '\\$'; then
            echo "❌ ERROR: Multi-line command without backslash continuation"
            return 1
        fi
    fi

    echo "✅ Command format valid for copy-paste"
    return 0
}
```

---

## MANDATORY WORKFLOW

**Before providing ANY command to user:**

```bash
# Step 1: Validate command
source .ai-agents/automation/enforce_validation.sh
validate_before_output "COMMAND_HERE"

# Step 2: Check format
format_command_for_output "COMMAND_HERE"

# Step 3: Test actual execution
bash -n <(echo "COMMAND_HERE")

# Step 4: Only then show to user
```

**Output template:**

````markdown
```bash
SINGLE_LINE_COMMAND_HERE
```
````

**Example - CORRECT:**

````markdown
```bash
curl https://what-is-my-delta-site-production.up.render.app/health/comprehensive
```
````

**Example - CORRECT (long command):**

````markdown
```bash
curl https://what-is-my-delta-site-production.up.render.app/health/comprehensive \
  -H "Authorization: Bearer token" \
  -H "Content-Type: application/json"
```
````

**Example - INCORRECT:**

````markdown
```bash
curl https://what-is-my-delta-site-production.up.render.app/health/compre
  hensive
```
````

---

## PRE-COMMIT HOOK INTEGRATION

Add to `.git/hooks/pre-commit`:

```bash
# Check for broken commands in markdown files
CHANGED_DOCS=$(git diff --cached --name-only --diff-filter=AM | grep -E '\.(md|txt)$' || true)
if [ -n "$CHANGED_DOCS" ]; then
    for DOC in $CHANGED_DOCS; do
        # Extract code blocks
        BLOCKS=$(sed -n '/```bash/,/```/p' "$DOC" 2>/dev/null || true)

        # Check for mid-word line breaks (space + word on next line)
        if echo "$BLOCKS" | grep -E '^[[:space:]]+[[:alnum:]]' | grep -v '^[[:space:]]*#'; then
            echo "❌ BLOCKED: Found broken command in $DOC"
            echo "   Commands must be on single line or use backslash continuation"
            exit 1
        fi
    done
fi
```

---

## AUTOMATED FIX SCRIPT

**Location:** `.ai-agents/automation/fix_broken_commands.sh`

```bash
#!/bin/bash
# Automatically detect and fix broken commands in markdown

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Usage: $0 <markdown_file>"
    exit 1
fi

# Find lines that look like continuation without backslash
# Pattern: URL followed by newline + indented text
perl -i -pe 's/(https?:\/\/[^\s]+)\n\s+([a-z])/$1$2/g' "$FILE"

echo "Fixed broken URLs in $FILE"
```

---

## ENFORCEMENT CHECKLIST

Before providing command to user:

```
□ Command tested with bash -n
□ No line breaks mid-word
□ Long commands use backslash continuation
□ Single line OR proper multi-line format
□ Wrapped in ```bash code block
□ Actually executed to verify it works
```

**If ANY checkbox fails → DO NOT PROVIDE COMMAND → Fix first**

---

## EXAMPLES

### ✅ CORRECT - Single line

```bash
curl https://what-is-my-delta-site-production.up.render.app/health/comprehensive
```

### ✅ CORRECT - Multi-line with backslash

```bash
curl https://what-is-my-delta-site-production.up.render.app/jobs/search \
  --data-urlencode "query=software engineer" \
  --data-urlencode "location=remote"
```

### ❌ INCORRECT - Line break mid-URL

```bash
curl https://what-is-my-delta-site-production.up.render.app/health/compre
  hensive
```

### ❌ INCORRECT - No backslash continuation

```bash
curl https://example.com/api
  --header "Authorization: Bearer token"
```

---

**END OF PROTOCOL**

Protocol Status: ✅ ACTIVE
Enforcement: MANDATORY - zero tolerance for broken commands
Violation: Immediate stop, fix, validate, retry
