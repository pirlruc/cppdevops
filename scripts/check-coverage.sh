#!/usr/bin/env bash
# Coverage gate: compare gcovr/llvm-cov summary against guardrails thresholds.
set -euo pipefail

LIB="${1:?library path}"
ROOT="$(cd "${LIB}" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPPDEVOPS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

THRESH_FILE="${SCRIPT_DIR}/cpp.profile.thresholds.yml"
LIB_THRESH="${ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
if [[ -f "${LIB_THRESH}" ]]; then
  THRESH_FILE="${LIB_THRESH}"
elif [[ -f "${CPPDEVOPS_ROOT}/docs/guardrails/cpp/profile.thresholds.yml" ]]; then
  THRESH_FILE="${CPPDEVOPS_ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
fi

STMT_MIN="$(bash "${CPPDEVOPS_ROOT}/scripts/read-thresholds.sh" statement_coverage "${THRESH_FILE}")"
BRANCH_MIN="$(bash "${CPPDEVOPS_ROOT}/scripts/read-thresholds.sh" branch_coverage "${THRESH_FILE}")"

BUILD_DIR="${ROOT}/build"
cd "${ROOT}"

if [[ ! -d "${BUILD_DIR}" ]]; then
  echo "error: build directory missing at ${BUILD_DIR}" >&2
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

if ! command -v gcovr >/dev/null 2>&1; then
  echo "error: gcovr not on PATH (install in ci-cpp image / local env)" >&2
  exit 1
fi

if ! gcovr --root "${ROOT}" --filter "${ROOT}/(include|src)/" \
  --json-summary "${REPORT}" \
  --exclude '.*/(test|external|build)/.*' \
  ${GCOV_ARGS[@]+"${GCOV_ARGS[@]}"} \
  "${BUILD_DIR}"; then
  echo "error: gcovr failed to produce ${REPORT}" >&2
  exit 1
fi

if [[ ! -f "${REPORT}" ]]; then
  echo "error: coverage report missing at ${REPORT} after gcovr" >&2
  exit 1
fi

python3 - "${REPORT}" "${STMT_MIN}" "${BRANCH_MIN}" <<'PY'
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
# Treat "nothing to cover" as a pass (CPP-TEST-003 for pure metaprogramming).
if lines_total is not None and float(lines_total) == 0:
    print("coverage: zero instrumentable lines in include|src — pass (header-only / compile-time library)")
    sys.exit(0)

if stmt is None:
    print(f"error: could not parse statement coverage from {path}", file=sys.stderr)
    sys.exit(1)

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
