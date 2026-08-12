#!/usr/bin/env bash
# Read a threshold key from a YAML profile (vendored or guardrails submodule).
set -euo pipefail
KEY="${1:?threshold key required}"
FILE="${2:-}"
if [[ -z "${FILE}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  FILE="${SCRIPT_DIR}/cpp.profile.thresholds.yml"
fi
if [[ ! -f "${FILE}" ]]; then
  echo "Missing ${FILE}; vendor scripts/cpp.profile.thresholds.yml or pass an explicit path." >&2
  exit 1
fi
# Strip inline comments after the value
grep "^${KEY}:" "${FILE}" | head -1 | awk '{print $2}' | tr -d '\r'
