#!/usr/bin/env bash
# Per-library coverage gate check (M6). Reads thresholds from vendored guardrails.
set -euo pipefail
LIB="${1:?library path}"
THRESH="$(
  cd "$(dirname "$0")/.." && bash cppdevops/scripts/read-thresholds.sh statement_coverage
)"
echo "Checking ${LIB} coverage >= ${THRESH}% (integrate lcov/gcov in CI build)"
# Placeholder: CI job runs gcovr/lcov and compares to THRESH
