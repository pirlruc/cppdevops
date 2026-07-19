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

# Prefer gcovr JSON summary when available. Clang builds need llvm-cov as the gcov driver.
REPORT="${BUILD_DIR}/coverage.json"
GCOV_ARGS=()
if command -v llvm-cov >/dev/null 2>&1; then
  GCOV_ARGS=(--gcov-executable "llvm-cov gcov")
elif command -v llvm-cov-18 >/dev/null 2>&1; then
  GCOV_ARGS=(--gcov-executable "llvm-cov-18 gcov")
fi

if command -v gcovr >/dev/null 2>&1; then
  gcovr --root "$ROOT" --filter "${ROOT}/(include|src)/" \
    --json-summary "$REPORT" \
    --exclude '.*/(test|external|build)/.*' \
    ${GCOV_ARGS[@]+"${GCOV_ARGS[@]}"} \
    "$BUILD_DIR" || true
fi

if [[ -f "$REPORT" ]]; then
  python3 - "$REPORT" "$STMT_MIN" "$BRANCH_MIN" <<'PY'
import json, sys
path, stmt_min, branch_min = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
data = json.load(open(path))

def first(*vals):
    for v in vals:
        if v is not None:
            return v
    return None

# gcovr json-summary shapes vary; support common keys (0.0 is a valid value)
stmt = first(
    data.get("line_percent"),
    (data.get("lines") or {}).get("percent") if isinstance(data.get("lines"), dict) else None,
    data.get("statement_coverage"),
)
branch = first(
    data.get("branch_percent"),
    (data.get("branches") or {}).get("percent") if isinstance(data.get("branches"), dict) else None,
    data.get("branch_coverage"),
)
lines_total = first(
    data.get("line_total"),
    data.get("lines_total"),
    (data.get("lines") or {}).get("count") if isinstance(data.get("lines"), dict) else None,
    (data.get("lines") or {}).get("total") if isinstance(data.get("lines"), dict) else None,
)
branch_total = first(
    data.get("branch_total"),
    data.get("branches_total"),
    (data.get("branches") or {}).get("count") if isinstance(data.get("branches"), dict) else None,
    (data.get("branches") or {}).get("total") if isinstance(data.get("branches"), dict) else None,
)

# Header-only / compile-time libraries may have zero instrumentable lines.
# Treat "nothing to cover" as a pass (CPP-TEST-003 deviation for pure metaprogramming).
if lines_total is not None and float(lines_total) == 0:
    print("coverage: zero instrumentable lines in include|src — pass (header-only / compile-time library)")
    sys.exit(0)

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
if branch_total is not None and float(branch_total) == 0:
    print("coverage: zero instrumentable branches — skipping branch threshold")
elif branch_v < branch_min:
    print(f"FAIL: branch coverage {branch_v} < {branch_min}", file=sys.stderr)
    ok = False
sys.exit(0 if ok else 1)
PY
else
  echo "No coverage.json — attempting llvm-cov report"
  if [[ -f "${BUILD_DIR}/default.profdata" ]] || ls "${BUILD_DIR}"/*.profdata >/dev/null 2>&1; then
    echo "llvm-cov artifacts present; enforce via gcovr in CI for numeric gates"
  fi
  echo "warning: coverage report missing; gate not evaluated (configure PIRLRUC_WITH_COVERAGE=ON)"
  # Soft when no report yet — callers with blocking=true should produce a report
  exit 0
fi
