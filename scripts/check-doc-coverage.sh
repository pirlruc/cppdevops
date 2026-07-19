#!/usr/bin/env bash
# Doc coverage via coverxygen + Doxygen XML (CPP-DOC-001).
set -euo pipefail

LIB="${1:?library path}"
TARGET="${2:-95}"
ROOT="$(cd "$LIB" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CPPDEVOPS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

THRESH_FILE="${ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
if [[ ! -f "$THRESH_FILE" ]]; then
  THRESH_FILE="${CPPDEVOPS_ROOT}/docs/guardrails/cpp/profile.thresholds.yml"
fi
if [[ -f "$THRESH_FILE" ]]; then
  TARGET="$(bash "$CPPDEVOPS_ROOT/scripts/read-thresholds.sh" doc_coverage "$THRESH_FILE" || echo "$TARGET")"
fi

cd "$ROOT"
if [[ ! -f Doxyfile ]]; then
  echo "No Doxyfile — skip doc coverage"
  exit 0
fi

# Ensure XML output for coverxygen
if ! grep -q 'GENERATE_XML *= *YES' Doxyfile 2>/dev/null; then
  echo "GENERATE_XML = YES" >> Doxyfile
fi
doxygen Doxyfile

XML_DIR="xml"
[[ -d "$XML_DIR" ]] || XML_DIR="build/xml"
[[ -d "$XML_DIR" ]] || { echo "Doxygen XML not found"; exit 1; }

pip3 install --quiet coverxygen >/dev/null
OUT="${ROOT}/build/doc-coverage.info"
mkdir -p "${ROOT}/build"
python3 -m coverxygen --xml-dir "$XML_DIR" --src-dir "$ROOT" --output "$OUT" --format lcov || \
  coverxygen --xml-dir "$XML_DIR" --src-dir "$ROOT" --output "$OUT" --format lcov

# Summarize documented vs total from lcov-like output if present; else parse coverxygen print
python3 - "$OUT" "$TARGET" <<'PY'
import re, sys
path, target = sys.argv[1], float(sys.argv[2])
text = open(path).read()
# coverxygen lcov: DA lines; fallback: look for summary comment
covered = total = 0
for line in text.splitlines():
    if line.startswith("DA:"):
        total += 1
        if line.split(",")[-1].strip() not in ("0", ""):
            covered += 1
if total == 0:
    print("warning: empty coverxygen report")
    sys.exit(0)
pct = 100.0 * covered / total
print(f"doc coverage {pct:.1f}% (min {target}%)")
sys.exit(0 if pct >= target else 1)
PY
