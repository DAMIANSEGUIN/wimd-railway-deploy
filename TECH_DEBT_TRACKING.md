# Technical Debt Tracking

## Security

### S314 - XML parsing in job sources

* **Issue**: The `indeed.py` and `weworkremotely.py` job sources use insecure XML parsing, which is vulnerable to XML external entity (XXE) attacks.
* **Mitigation**: The registration of these job sources has been temporarily disabled in `api/index.py` to make the vulnerable code paths unreachable.
* **Next Steps**: The XML parsing in these files must be updated to use a secure parser (e.g., `defusedxml`). Once fixed, the job sources can be re-enabled.
* **Date**: 2025-12-16

## Pre-commit Hooks

### `validate_metadata.sh`

* **Issue**: The `validate_metadata.sh` pre-commit hook was causing issues and has been disabled.
* **Mitigation**: The hook is not present in the `.pre-commit-config.yaml` file.
* **Next Steps**: The hook should be re-enabled and any issues with it should be fixed. The hook is located at `scripts/validate_metadata.sh`.
* **Date**: 2025-12-16
