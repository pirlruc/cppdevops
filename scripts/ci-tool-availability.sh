#!/usr/bin/env bash
# Host vs project-local tool detection (heimdall port, C++ subset).
# Does not install system packages.
set -euo pipefail

ci_project_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

ci_venv_bin() {
  local root_dir="$1"
  echo "${root_dir}/.venv-quality/bin"
}

ci_lizard_available() {
  local root_dir="$1"
  command -v lizard >/dev/null 2>&1 || [[ -x "$(ci_venv_bin "${root_dir}")/lizard" ]]
}

ci_coverxygen_available() {
  local root_dir="$1"
  command -v coverxygen >/dev/null 2>&1 \
    || python3 -c "import coverxygen" 2>/dev/null \
    || [[ -x "$(ci_venv_bin "${root_dir}")/coverxygen" ]]
}

ci_doxygen_available() {
  command -v doxygen >/dev/null 2>&1
}

ci_cmake_available() {
  command -v cmake >/dev/null 2>&1
}
