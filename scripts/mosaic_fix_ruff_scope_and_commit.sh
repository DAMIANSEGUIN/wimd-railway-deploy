#!/bin/bash
set -euo pipefail

ROOT="/Users/damianseguin/AI_Workspace/WIMD-Railway-Deploy-Project"
PY="/usr/bin/python3"
CACHE="/Users/damianseguin/.cache/pre-commit"
F="$ROOT/pyproject.toml"

cd "$ROOT"

[ -f "$F" ] || { echo "ERROR: Missing $F"; exit 1; }
[ -w "$F" ] || chmod u+w "$F" || true
[ -w "$F" ] || { echo "ERROR: $F not writable. Run: sudo chown damianseguin:staff \"$F\""; exit 1; }

$PY - <<EOF
import os
p=os.environ["F"]
t=open(p,"r",encoding="utf-8").read()
block = "[tool.ruff]\\nexclude = [\\n    \\".ai-agents\\",\\n    \\".claude-run\\",\\n    \\".cache\\",\\n    \\".venv\\",\\n    \\"node_modules\\",\\n]\\n"
if "[tool.ruff]" not in t:
    if not t.endswith("\\n"): t += "\\n"
    t += "\\n" + block
elif "exclude" not in t:
    lines=t.splitlines(True)
    out=[]
    inserted=False
    for line in lines:
        out.append(line)
        if not inserted and line.strip()=="[tool.ruff]":
            out.append(block)
            inserted=True
    t="".join(out)
open(p,"w",encoding="utf-8").write(t)
EOF

rm -rf "$CACHE"
$PY -m pip install --user -U pip pre-commit >/dev/null
$PY -m pre_commit run --all-files

if git diff --quiet -- "$F"; then
  echo "OK: pyproject.toml unchanged"
  exit 0
fi

git add "$F"
git commit -m "Chore: scope Ruff to application code (exclude governance and vendored runtimes)"
git push
