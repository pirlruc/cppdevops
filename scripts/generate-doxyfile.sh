#!/usr/bin/env bash
# Generate Doxyfile for a library from cppdevops templates.
set -euo pipefail
LIB_ARG="${1:?library path}"
CPPDEVOPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB="$(cd "${LIB_ARG}" && pwd)"
LIB_NAME="$(basename "${LIB}")"
sed "s/@LIB@/${LIB_NAME}/g" "${CPPDEVOPS_ROOT}/templates/cpp/Doxyfile.in" > "${LIB}/Doxyfile"
echo "Wrote ${LIB}/Doxyfile"
