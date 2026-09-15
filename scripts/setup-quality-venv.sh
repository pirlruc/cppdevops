#!/usr/bin/env bash
# Project-local quality venv (coverxygen, lizard). Does not touch system Python.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${ROOT}/.venv-quality"
if [[ -x "${VENV}/bin/python" ]]; then
  echo "Using existing ${VENV}"
  exit 0
fi
python3 -m venv "${VENV}"
"${VENV}/bin/pip" install -q 'lizard==1.17.10' 'coverxygen==1.8.2'
echo "Created ${VENV}"
