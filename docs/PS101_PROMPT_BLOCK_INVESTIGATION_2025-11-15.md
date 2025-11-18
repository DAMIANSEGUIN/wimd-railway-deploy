# PS101 Prompt Block Investigation — 2025-11-15

**Reporter:** Codex (Terminal)  
**Context:** Post-restoration of `prod-2025-11-12` build; validation hardening work in progress.  
**Status:** In-flight — diagnosis captured, fix pending.

---

## Current Symptom
- PS101 flow refuses to advance past Prompt 1 even when the textarea contains well over the minimum character requirement.
- Character counter remains at `0 / 1000`, indicating the input listener is not updating state.
- No console errors during reproduction; `Next` button click handler fires, but `validateCurrentStep()` always fails the length check.

## Immediate Findings
- The new validation helpers (`showValidationMessage`, `clearValidationMessage`) and skip wiring were added, but the textarea event listener does not persist after `renderCurrentStep()` re-renders the DOM.  
  - Each prompt change rebuilds the textarea node, so listeners attached before the render are detached.  
  - As a result, `PS101State.setAnswer` never sees the latest text, leaving the stored response empty and the char counter at zero.
- Because the stored answer stays blank, `validateCurrentStep()` enforces the minimum-length rule and blocks progression, even when the on-screen text looks sufficient.

## Impact
- Users cannot complete PS101; the flow is effectively frozen at the first prompt, blocking guided discovery.  
- This is a regression introduced during recent guardrail/validation work (not present in the Nov 12 baseline).

## Next Actions
1. Reworked the textarea binding so it is reattached after each render (`handlePS101TextareaInput` + `bindPS101TextareaInput`).
2. Restored strict “no skip” behaviour; skip button now hidden/disabled pending leadership approval.
3. Pending: retest the flow end-to-end (clear `localStorage`, walk all 10 prompts) and capture evidence for the deployment gate.
4. Pending: update the release log + notify Codex in Cursor once browser QA confirms the fix.

## Hotfix Summary
- `frontend/index.html` & `mosaic_ui/index.html`
  - Added resilient PS101 textarea binding helpers at lines ~2445–2485.
  - `renderCurrentStep()` now calls `bindPS101TextareaInput()` after every re-render (lines ~3885–3895).
  - Skip control disabled/hidden (lines ~2534–2540) to enforce required completion.
  - Validation messages updated to reflect strict requirements (no skip references).
- Baseline updated (`deployment/deploy_baseline.env`) for the new `mosaic_ui/index.html` line count (4352).

## Verification Checklist (to run next)
1. `localStorage.removeItem('ps101_v2_state')`
2. Reload PS101 UI, type into Prompt 1 → character counter increments.
3. Reach min characters → “Next” advances to Prompt 2.
4. Finish remaining prompts (spot check a few) to ensure state persistence.
5. Capture screenshots + console log snippet for deployment gate evidence.

## Hand-off Notes
- Reset local state (`localStorage.removeItem('ps101_v2_state')`) before retesting to ensure the new listener logic is exercised from a clean slate.  
- Coordinate with Codex in Cursor before redeploying; this regression needs a hotfix aligned with the guardrail protocol.
