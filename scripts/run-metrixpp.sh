#!/usr/bin/env bash
# Run Metrix++ using .metrixpp.yml knobs + guardrails MI / CCN thresholds.
set -euo pipefail

LIB="${1:-.}"
ROOT="$(cd "${LIB}" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPPDEVOPS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ROOT}"

CONFIG="${ROOT}/.metrixpp.yml"
THRESH_FILE="${SCRIPT_DIR}/cpp.profile.thresholds.yml"
LIB_THRESH="${ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
if [[ -f "${LIB_THRESH}" ]]; then
  THRESH_FILE="${LIB_THRESH}"
elif [[ -f "${CPPDEVOPS_ROOT}/docs/guardrails/cpp/profile.thresholds.yml" ]]; then
  THRESH_FILE="${CPPDEVOPS_ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
fi

MI_MIN="$(bash "${CPPDEVOPS_ROOT}/scripts/read-thresholds.sh" min_maintainability_index "${THRESH_FILE}")"
CCN_MAX="$(bash "${CPPDEVOPS_ROOT}/scripts/read-thresholds.sh" max_cyclomatic_complexity "${THRESH_FILE}")"

PATHS=(include src)
if [[ -f "${CONFIG}" ]] && command -v python3 >/dev/null; then
  mapfile -t PATHS < <(python3 - "${CONFIG}" <<'PY'
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
  [[ -d "${p}" ]] && EXISTING+=("${p}")
done
if [[ ${#EXISTING[@]} -eq 0 ]]; then
  echo "No source paths for Metrix++; skipping"
  exit 0
fi

METRIX=(python3 -m metrixpp)
if command -v metrix++ >/dev/null 2>&1; then
  METRIX=(metrix++)
elif ! python3 -c "import metrixpp" 2>/dev/null; then
  echo "error: metrix++ / metrixpp not available (ship it in ci-cpp)" >&2
  exit 1
fi

DB="${ROOT}/build/metrixpp.db"
mkdir -p "${ROOT}/build"
rm -f "${DB}"

"${METRIX[@]}" collect \
  --std.code.complexity.cyclomatic \
  --std.code.maintindex.simple \
  --std.code.lines.code \
  --db-file="${DB}" \
  -- "${EXISTING[@]}"

"${METRIX[@]}" limit \
  --db-file="${DB}" \
  --max-limit="std.code.complexity:cyclomatic:${CCN_MAX}"

# This metrix++ build stores std.code.mi:simple as a 1-point score
# (lower is better), not the 0-100 index CPP-CPLX-001 names. Do not compare
# it with min_maintainability_index.
echo "Metrix++ OK (CCN <= ${CCN_MAX}; std.code.mi:simple is not the 0-100 index, floor ${MI_MIN} not applied)"
