SESSION_END_OPTIONS.md
Mosaic Session Termination Commands (Canonical Complete Set)
Version 1.0 — Minimal Format

**Document Metadata:**
- Created: 2025-12-05 by User (Damian)
- Last Updated: 2025-12-05 by User (Damian)
- Last Deployment Tag: prod-2025-11-18 (commit: 31d099c)
- Status: ACTIVE

1. SESSION_END (Standard Termination)
SESSION_END
• Enter HANDOFF mode
• Summarize completed work
• Record last-known-state
• Preserve NEXT_TASK exactly
• Declare unresolved uncertainties
• Stop all processing
• Await next session

2. SESSION_HARD_STOP (Strict Boundary)
SESSION_HARD_STOP
• Enter HANDOFF mode immediately
• Do not generate code or propose new tasks
• Summarize completed work only
• Freeze NEXT_TASK without modification
• Record last-known-state
• Stop all processing and remain idle

3. SESSION_ABORT (Emergency Stop)
SESSION_ABORT
• Cease execution immediately
• Discard partial outputs from this step
• Enter DIAGNOSE mode
• Identify source of drift OR violation
• Restore last-known-state from previous stable step
• Do not update NEXT_TASK
• Await supervision

4. SESSION_HANDOFF (Multi-Agent Handoff)
SESSION_HANDOFF
• Enter HANDOFF mode
• Provide exact last-known-state
• Provide NEXT_TASK verbatim
• Provide current mode
• Provide unresolved uncertainties
• Do not generate code
• Signal readiness for next agent

5. SESSION_FREEZE (End-of-Day Preservation)
SESSION_FREEZE
• Enter HANDOFF mode
• Summarize completed work
• Record last-known-state in full detail
• Preserve NEXT_TASK exactly
• Note all blockers and pending clarifications
• Create a clear re-entry point for next session
• Stop all processing

6. SESSION_SAFETY_EXIT (Repository Risk Exit)
SESSION_SAFETY_EXIT
• Enter DIAGNOSE mode
• Verify file paths and repo boundaries
• Halt all BUILD and REPAIR activity
• Preserve NEXT_TASK
• Document the risk that triggered safety mode
• Stop all processing until user approval

7. SESSION_CONSOLIDATE (Cognitive Compression End)
SESSION_CONSOLIDATE
• Enter HANDOFF mode
• Summarize strategic decisions made
• Summarize architectural constraints
• Record last-known-state
• Preserve NEXT_TASK exactly
• Declare all open uncertainties
• Stop all processing

Retrieval Command:
To retrieve this list at any time, use: GET_SESSION_END_OPTIONS
