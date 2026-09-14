#!/usr/bin/env bash
# Fail if vendored C++ thresholds drift from the pinned guardrails submodule.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDED="${ROOT}/scripts/cpp.profile.thresholds.yml"
UPSTREAM="${ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
if [[ ! -f "${VENDED}" ]]; then
  echo "error: missing ${VENDED}" >&2
  exit 1
fi
if [[ ! -f "${UPSTREAM}" ]]; then
  echo "error: guardrails submodule missing at ${UPSTREAM} (CI-022 / CI-035)" >&2
  exit 1
fi
# Compare keys/values only (ignore comment-only header differences)
extract() {
  grep -E '^[a-z_]+:' "$1" | sed 's/[[:space:]]*#.*//' | sed 's/[[:space:]]*$//'
}
if ! diff -u <(extract "${UPSTREAM}") <(extract "${VENDED}"); then
  echo "error: scripts/cpp.profile.thresholds.yml drifted from docs/guardrails/cpp/profile.thresholds.yml" >&2
  exit 1
fi
echo "Thresholds in sync with docs/guardrails/cpp/profile.thresholds.yml"
