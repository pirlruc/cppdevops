#!/usr/bin/env bash
# Public API doc coverage from the Clang AST (CPP-DOC-001).
# Doxygen stays the HTML renderer in cpp-docs.yml. This script does not run it.
set -euo pipefail

LIB="${1:?library path}"
shift || true
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
TARGET="$(bash "${CPPDEVOPS_ROOT}/scripts/read-thresholds.sh" doc_coverage "${THRESH_FILE}")"

exec python3 "${SCRIPT_DIR}/check-doc-coverage.py" \
  --root "${ROOT}" \
  --threshold "${TARGET}" \
  -- \
  "$@"
