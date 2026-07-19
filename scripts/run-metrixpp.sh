#!/usr/bin/env bash
# Run Metrix++ using .metrixpp.yml knobs + guardrails MI threshold.
set -euo pipefail

LIB="${1:-.}"
ROOT="$(cd "$LIB" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CPPDEVOPS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT"

CONFIG="${ROOT}/.metrixpp.yml"
THRESH_FILE="${ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
if [[ ! -f "$THRESH_FILE" ]]; then
  THRESH_FILE="${CPPDEVOPS_ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
fi

MI_MIN="$(bash "$CPPDEVOPS_ROOT/scripts/read-thresholds.sh" min_maintainability_index "$THRESH_FILE" 2>/dev/null || echo 40)"

PATHS=(include src)
if [[ -f "$CONFIG" ]] && command -v python3 >/dev/null; then
  mapfile -t PATHS < <(python3 - <<'PY' "$CONFIG"
import sys, yaml
from pathlib import Path
cfg = yaml.safe_load(Path(sys.argv[1]).read_text()) or {}
for p in cfg.get("paths") or ["include", "src"]:
    print(p)
PY
  ) || PATHS=(include src)
fi

EXISTING=()
for p in "${PATHS[@]}"; do
  [[ -d "$p" ]] && EXISTING+=("$p")
done
if [[ ${#EXISTING[@]} -eq 0 ]]; then
  echo "No source paths for Metrix++; skipping"
  exit 0
fi

if ! command -v metrix++ >/dev/null 2>&1 && ! python3 -c "import metrixpp" 2>/dev/null; then
  pip3 install --quiet metrixpp || true
fi

METRIX=(python3 -m metrixpp)
if command -v metrix++ >/dev/null 2>&1; then
  METRIX=(metrix++)
fi

DB="${ROOT}/build/metrixpp.db"
mkdir -p "${ROOT}/build"
rm -f "$DB"

"${METRIX[@]}" collect \
  --std.code.complexity.cyclomatic \
  --std.code.maintindex.simple \
  --std.code.lines.code \
  --db-file="$DB" \
  -- "${EXISTING[@]}"

"${METRIX[@]}" limit \
  --db-file="$DB" \
  --max-limit="std.code.complexity:cyclomatic:10" \
  --min-limit="std.code.maintindex:simple:${MI_MIN}"

echo "Metrix++ OK (MI >= ${MI_MIN})"
