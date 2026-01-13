# GOVERNANCE.md
**(Canonical — Replaces All Prior Versions)**

## Purpose

Mosaic governance exists to **prevent false confidence**.

A system is considered **healthy only if real users can successfully use it end-to-end**.  
Component health, backend availability, or passing unit tests **do not constitute system health**.

> **Governance certifies usability, not components.**

---

## System Boundary (Locked)

Governance applies to **all layers below**.  
No layer may be inferred, skipped, or treated as “out of scope.”

- **L1 — Front End**
- **L2 — Backend / API**
- **L3 — Orchestration**
- **L4 — Data Layer**
- **L5 — Governance Layer**
- **L6 — Observability**
- **L7 — Security & Privacy**

**If any layer is unverified, deployment is BLOCKED.**

---

## Governance Rules (Fail-Closed)

1. No inference
2. No partial approval
3. User-path supremacy
4. Technical enforcement only
5. Coverage before enforcement

---

## Canonical Governance Gates

- FRONTEND_REACHABILITY
- INTEGRATION_CONNECTIVITY
- BACKEND_HEALTH
- RUNTIME_IDENTITY
- DATA_CONNECTIVITY
- SECRET_VALIDATION
- USER_PATH_SMOKE

---

## Outputs

- ALLOW
- BLOCK

---

## Authority

This file replaces all prior governance documents and is the sole source of truth.

