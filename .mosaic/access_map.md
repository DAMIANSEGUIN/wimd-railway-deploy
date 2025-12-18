# MOSAIC ACCESS MAP — AUTHORITATIVE

Scope: Defines how Gemini and other validators should access this repo and which files are authoritative inputs.

Repo root (must contain .git):
/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project

Authoritative control plane:
- .mosaic/ (single source of truth)

Gemini must read (in order):
- .mosaic/gemini_validation_note.md
- .mosaic/access_map.md

File access expectation:
- Gemini has access to the repo contents as local files under the repo root path above.
- Validation must fail closed if any required file is missing.

Next step after reading both files:
- Proceed with the repository inspection and enforcement validation exactly as specified in gemini_validation_note.md.
