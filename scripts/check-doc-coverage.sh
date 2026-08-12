#!/usr/bin/env bash
# Doc coverage via coverxygen + Doxygen XML (CPP-DOC-001).
# Does not mutate the consumer's tracked Doxyfile — uses a temp copy.
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
TARGET="$(bash "${CPPDEVOPS_ROOT}/scripts/read-thresholds.sh" doc_coverage "${THRESH_FILE}")"

cd "${ROOT}"
if [[ ! -f Doxyfile ]]; then
  echo "No Doxyfile — skip doc coverage"
  exit 0
fi

if ! command -v doxygen >/dev/null 2>&1; then
  echo "error: doxygen not on PATH" >&2
  exit 1
fi
if ! command -v coverxygen >/dev/null 2>&1 && ! python3 -c "import coverxygen" 2>/dev/null; then
  echo "error: coverxygen not on PATH / not importable (ship it in ci-cpp)" >&2
  exit 1
fi

TMP_DOXY="$(mktemp)"
trap 'rm -f "${TMP_DOXY}"' EXIT
cp Doxyfile "${TMP_DOXY}"
if ! grep -qE '^[[:space:]]*GENERATE_XML[[:space:]]*=' "${TMP_DOXY}"; then
  printf '\nGENERATE_XML = YES\n' >> "${TMP_DOXY}"
else
  # Force XML on for coverxygen without touching the tracked file
  sed -i 's/^[[:space:]]*GENERATE_XML[[:space:]]*=.*/GENERATE_XML = YES/' "${TMP_DOXY}"
fi
doxygen "${TMP_DOXY}"

XML_DIR="xml"
[[ -d "${XML_DIR}" ]] || XML_DIR="build/xml"
[[ -d "${XML_DIR}" ]] || { echo "Doxygen XML not found"; exit 1; }

OUT="${ROOT}/build/doc-coverage.info"
mkdir -p "${ROOT}/build"
if command -v coverxygen >/dev/null 2>&1; then
  coverxygen --xml-dir "${XML_DIR}" --src-dir "${ROOT}" --output "${OUT}" --format lcov
else
  python3 -m coverxygen --xml-dir "${XML_DIR}" --src-dir "${ROOT}" --output "${OUT}" --format lcov
fi

python3 - "${OUT}" "${TARGET}" <<'PY'
import sys
path, target = sys.argv[1], float(sys.argv[2])
text = open(path).read()
covered = total = 0
for line in text.splitlines():
    if line.startswith("DA:"):
        total += 1
        if line.split(",")[-1].strip() not in ("0", ""):
            covered += 1
if total == 0:
    print("error: empty coverxygen report", file=sys.stderr)
    sys.exit(1)
pct = 100.0 * covered / total
print(f"doc coverage {pct:.1f}% (min {target}%)")
sys.exit(0 if pct >= target else 1)
PY
