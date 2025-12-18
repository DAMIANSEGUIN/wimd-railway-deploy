# MOSAIC — CANON GOVERNANCE REWRITE (DETERMINISTIC GATES)
# Patch: resolves Gemini CLARIFY_REQUIRED on placeholder + network reachability
# Date: 2025-12-17 (America/Toronto)

## 0. Purpose

This document specifies **deterministic, non-behavioural** enforcement gates that prevent repo↔service authority drift and stop “wrong service / wrong repo” debugging loops.

---

## 1. One Rule for Enforcement (the load-bearing rule)

**RULE-0 / NON-BYPASSABLE ENFORCEMENT:**  
> Any action that can change runtime state (deploy, push-to-deploy, `railway up`, promotion, environment var changes) **MUST** be preceded by a successful `mosaic_enforce` run.  
> The enforcement tool must be invoked automatically by at least one mandatory mechanism (local wrapper, CI, and/or runtime), and must *fail closed* when prerequisites are missing.

This is enforced as “cannot proceed” gates, not as guidance.

---

## 2. Canon Objects

Repository contains a `.mosaic/` directory:

- `.mosaic/authority_map.json` (single source of declared repo↔service mapping)
- `.mosaic/policy.yaml` (deterministic gate rules)
- `.mosaic/enforce.sh` (or `enforce.py`) (enforcer executable)
- `.mosaic/manifest.lock` (optional; hashes / expected files)

---

## 3. Authority Map

### 3.1 authority_map.json — **no unresolved placeholders**

**Hard rule:** `authority_map.json` cannot contain raw placeholders like `<railway-url>` without a defined resolution mechanism.

Two allowed patterns:

#### Pattern A (recommended): **Template + resolver**
Store a template string and the resolver rules:

```json
{
  "version": "1",
  "repo": {
    "github_owner": "DAMIANSEGUIN",
    "github_repo": "what-is-my-delta-site",
    "branch": "main"
  },
  "services": [
    {
      "service_id": "railway:wimd-career-coaching/what-is-my-delta-site",
      "runtime_identity_path": "/__version",
      "runtime_base_url": {
        "mode": "template",
        "template": "https://${RAILWAY_STATIC_URL}",
        "required_env": ["RAILWAY_STATIC_URL"]
      }
    }
  ]
}
```

**Deterministic resolution rule:**  
- If `runtime_base_url.mode == "template"`, the enforcer **must**:
  1) verify all `required_env` keys exist and are non-empty  
  2) substitute `${VARNAME}` strictly from process env  
  3) produce a concrete URL  
- If any required env var is missing/empty → **CLARIFY_REQUIRED** (not ALLOW, not REJECT).

#### Pattern B: **Concrete URL(s) per environment**
If you prefer explicit URLs, store them per environment and require `MOSAIC_ENV`:

```json
{
  "version": "1",
  "repo": { "github_owner": "DAMIANSEGUIN", "github_repo": "what-is-my-delta-site", "branch": "main" },
  "services": [
    {
      "service_id": "railway:wimd-career-coaching/what-is-my-delta-site",
      "runtime_identity_path": "/__version",
      "runtime_base_url": {
        "mode": "env_map",
        "required_env": ["MOSAIC_ENV"],
        "env_map": {
          "prod": "https://wimd-career-coaching-production.up.railway.app",
          "staging": "https://wimd-career-coaching-staging.up.railway.app"
        }
      }
    }
  ]
}
```

**Deterministic resolution rule:**  
- If `mode == "env_map"`, enforcer reads `MOSAIC_ENV` and picks `env_map[MOSAIC_ENV]`.  
- Missing `MOSAIC_ENV` or missing mapping → **CLARIFY_REQUIRED**.

---

## 4. Policy

### 4.1 policy.yaml — runtime identity check is **context-conditional**

Gemini correctly flagged that runtime checks assume network reachability. Fix: make the runtime check conditional on **execution mode**.

The enforcer must be invoked with one of these explicit modes:

- `MODE=local`  → no network assumptions; enforce repo invariants only.
- `MODE=ci`     → network reachability can be controlled; runtime identity checks mandatory.
- `MODE=runtime`→ running inside the deployed service; self-attest identity.

**Hard rule:** if MODE is absent → **CLARIFY_REQUIRED**.

Example `policy.yaml` (spec-level):

```yaml
version: 1

modes:
  - local
  - ci
  - runtime

rules:

  - id: REPO_REMOTE_MATCH
    when: always
    check: git_remote_equals_authority_map_repo()

  - id: BRANCH_MATCH
    when: always
    check: git_branch_equals(authority_map.repo.branch)

  - id: CLEAN_WORKTREE
    when: always
    check: git_status_is_clean_or_explicitly_allowed()

  - id: RUNTIME_IDENTITY_MATCH
    when: mode_is("ci")
    check: runtime_commit_equals_git_sha(
            runtime_url=resolve_runtime_base_url() + authority_map.services[0].runtime_identity_path,
            expected_sha=git_sha("HEAD"),
            timeout_seconds=5
          )
    on_network_failure: CLARIFY_REQUIRED
    note: >
      Mandatory only in CI mode. In local mode, network failure is not treated
      as authority drift; it is treated as CLARIFY_REQUIRED so humans can decide.

  - id: RUNTIME_SELF_ATTEST
    when: mode_is("runtime")
    check: runtime_self_reports_commit_equals_env("GIT_SHA")
```

**Deterministic semantics:**
- `RUNTIME_IDENTITY_MATCH` in `MODE=ci`:
  - If HTTP 200 and SHA mismatch → **REJECT** (authority drift)
  - If DNS/TLS/timeout/connection failure → **CLARIFY_REQUIRED** (environment constraint, not proof of drift)
- In `MODE=local`: rule is skipped by design; no network assumptions.

---

## 5. Non-Bypassable Placement Strategy (3 layers, single authority)

This is safe (not competing authorities) if and only if all layers read the **same** `.mosaic/authority_map.json` + `.mosaic/policy.yaml` and emit the same verdict schema.

### 5.1 Local gate (developer machine)
- `.githooks/pre-push` runs: `.mosaic/enforce.sh MODE=local`
- If CLARIFY_REQUIRED or REJECT → block push

### 5.2 CI gate (authoritative)
- CI workflow runs: `.mosaic/enforce.sh MODE=ci`
- If CLARIFY_REQUIRED or REJECT → block merge/deploy

### 5.3 Runtime gate (optional but strong)
- Service exposes `/__version` including `GIT_SHA`
- Build injects `GIT_SHA` at build time
- Optional startup check: runtime asserts `GIT_SHA` present (fail fast if missing)

---

## 6. Output Contract (machine language)

Enforcer prints a single JSON object to stdout:

```json
{
  "verdict": "ALLOW|REJECT|CLARIFY_REQUIRED",
  "rule_results": [
    {"id":"REPO_REMOTE_MATCH","status":"PASS|FAIL|SKIP","details":"..."},
    {"id":"RUNTIME_IDENTITY_MATCH","status":"PASS|FAIL|SKIP","details":"..."}
  ],
  "required_fixes": [
    {"file":".mosaic/authority_map.json","change_spec":"..."}
  ]
}
```

---

## 7. Minimal Implementation Notes (non-executable here)

- Use `curl --fail --silent --max-time 5` for runtime check in CI mode.
- Treat any non-200 or network failure as CLARIFY_REQUIRED unless you can prove drift.
- Never “guess” URLs; resolve only via declared env vars / env_map.

---

## 8. What changed in this patch (for Gemini)

- authority_map.json now defines **how** runtime URL is resolved (template/env_map), no raw placeholders.
- runtime identity check is now **mode-conditional**; network failures produce **CLARIFY_REQUIRED**, not false REJECT.

# END