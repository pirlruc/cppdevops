#!/usr/bin/env bash
# Install per-library .devcontainer/ and standalone CMakePresets.json from cppdevops templates.
set -euo pipefail

LIB_ARG="${1:?library path (absolute or relative to cwd)}"
CMAKE_TARGET="${2:?cmake build target name, e.g. runa or heimdallcv-core}"
LIB_DISPLAY="${3:-$(basename "$(cd "$LIB_ARG" && pwd)")}"

CPPDEVOPS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIB="$(cd "$LIB_ARG" && pwd)"
TEMPLATE="$CPPDEVOPS_ROOT/templates/cpp"

mkdir -p "$LIB/.devcontainer" "$LIB/docs"

cp "$TEMPLATE/devcontainer/Dockerfile" "$LIB/.devcontainer/Dockerfile"
cp "$TEMPLATE/devcontainer/reinstall-cmake.sh" "$LIB/.devcontainer/reinstall-cmake.sh"

APT_PACKAGES="${DEVCONTAINER_APT_PACKAGES:-clang-18 libc++-18-dev libc++abi-18-dev clang-format-18 clang-tidy-18 cppcheck doxygen graphviz gitleaks ninja-build pkg-config python3-pip python3-venv}"
sed -e "s|@LIB_DISPLAY_NAME@|${LIB_DISPLAY}|g" \
  -e "s|@DEVCONTAINER_APT_PACKAGES@|${APT_PACKAGES}|g" \
  "$TEMPLATE/devcontainer/devcontainer.standalone.json.in" > "$LIB/.devcontainer/devcontainer.json"
sed -e "s|@CMAKE_TARGET@|${CMAKE_TARGET}|g" \
  "$TEMPLATE/CMakePresets.standalone.json.in" > "$LIB/CMakePresets.json"

echo "Synced standalone devcontainer + CMakePresets to $LIB (target: $CMAKE_TARGET)"
