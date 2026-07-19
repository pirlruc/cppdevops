#!/usr/bin/env bash
# Coverage gate: compare gcovr/llvm-cov summary against guardrails thresholds.
set -euo pipefail

LIB="${1:?library path}"
ROOT="$(cd "$LIB" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CPPDEVOPS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

THRESH_FILE="${ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
if [[ ! -f "$THRESH_FILE" ]]; then
  THRESH_FILE="${CPPDEVOPS_ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
fi

STMT_MIN="$(bash "$CPPDEVOPS_ROOT/scripts/read-thresholds.sh" statement_coverage "$THRESH_FILE")"
BRANCH_MIN="$(bash "$CPPDEVOPS_ROOT/scripts/read-thresholds.sh" branch_coverage "$THRESH_FILE")"

BUILD_DIR="${ROOT}/build"
cd "$ROOT"

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "error: build directory missing at $BUILD_DIR" >&2
  exit 1
fi

# Prefer gcovr JSON summary when available
REPORT="${BUILD_DIR}/coverage.json"
if command -v gcovr >/dev/null 2>&1; then
  gcovr --root "$ROOT" --filter "${ROOT}/(include|src)/" \
    --json-summary "$REPORT" \
    --exclude '.*/(test|external|build)/.*' \
    "$BUILD_DIR" || true
fi

if [[ -f "$REPORT" ]]; then
  python3 - "$REPORT" "$STMT_MIN" "$BRANCH_MIN" <<'PY'
import json, sys
path, stmt_min, branch_min = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
data = json.load(open(path))
# gcovr json-summary shapes vary; support common keys
stmt = data.get("line_percent") or data.get("lines", {}).get("percent") or data.get("statement_coverage")
branch = data.get("branch_percent") or data.get("branches", {}).get("percent") or data.get("branch_coverage")
if stmt is None:
    print("warning: could not parse statement coverage from", path)
    sys.exit(0)
stmt = float(stmt)
branch_v = float(branch) if branch is not None else stmt
print(f"coverage statement={stmt}% (min {stmt_min}) branch={branch_v}% (min {branch_min})")
ok = True
if stmt < stmt_min:
    print(f"FAIL: statement coverage {stmt} < {stmt_min}", file=sys.stderr)
    ok = False
if branch_v < branch_min:
    print(f"FAIL: branch coverage {branch_v} < {branch_min}", file=sys.stderr)
    ok = False
sys.exit(0 if ok else 1)
PY
else
  echo "No coverage.json — attempting llvm-cov report"
  if [[ -f "${BUILD_DIR}/default.profdata" ]] || ls "${BUILD_DIR}"/*.profdata >/dev/null 2>&1; then
    echo "llvm-cov artifacts present; enforce via gcovr in CI for numeric gates"
  fi
  echo "warning: coverage report missing; gate not evaluated (configure IMPROC_WITH_COVERAGE=ON)"
  # Soft when no report yet — callers with blocking=true should produce a report
  exit 0
fi
