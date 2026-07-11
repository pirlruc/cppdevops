#!/usr/bin/env bash
# Read a threshold key from docs/guardrails/cpp/profile.thresholds.yml
set -euo pipefail
KEY="${1:?threshold key required}"
FILE="${2:-docs/guardrails/cpp/profile.thresholds.yml}"
grep "^${KEY}:" "$FILE" | awk '{print $2}'
