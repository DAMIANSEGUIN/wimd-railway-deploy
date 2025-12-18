# User Enforcement Checklist

**Use this to enforce governance when AI agents fail to self-enforce**

## Before Running Any Command

□ Did agent cite source file for this command?
□ Does command appear to be single-line or proper multi-line?
□ Can I copy-paste this directly?

## If Command Breaks

1. Stop session immediately
2. Say: "This command is broken. Fix it now before continuing."
3. Do NOT let agent continue until fixed
4. Do NOT accept "I'll do better next time"

## Before Accepting Technical Claims

□ Did agent show search results?
□ Did agent cite file:line number?
□ Or did agent guess/assume?

## If Agent Guessed

1. Say: "Show me the file you got this from"
2. If agent cannot → reject the answer
3. Force agent to search and cite source

## Session Health Check

□ Is agent following declared mode?
□ Is agent tracking token usage?
□ Has agent validated recent outputs?

## When to Stop Session

- Agent provides broken command
- Agent guesses instead of searching
- Agent violates governance repeatedly
- Agent cannot fix errors immediately
