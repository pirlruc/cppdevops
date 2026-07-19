#!/usr/bin/env bash
# Install per-library .devcontainer/ and standalone CMakePresets.json from cppdevops templates.
set -euo pipefail

LIB_ARG="${1:?library path (absolute or relative to cwd)}"
CMAKE_TARGET="${2:?cmake build target name, e.g. traits or heimdallcv-core}"
LIB_DISPLAY="${3:-$(basename "$(cd "$LIB_ARG" && pwd)")}"

CPPDEVOPS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIB="$(cd "$LIB_ARG" && pwd)"
TEMPLATE="$CPPDEVOPS_ROOT/templates/cpp"

mkdir -p "$LIB/.devcontainer" "$LIB/docs"

cp "$TEMPLATE/devcontainer/Dockerfile" "$LIB/.devcontainer/Dockerfile"
cp "$TEMPLATE/devcontainer/reinstall-cmake.sh" "$LIB/.devcontainer/reinstall-cmake.sh"

APT_PACKAGES="${DEVCONTAINER_APT_PACKAGES:-clang libc++-dev libc++abi-dev ninja-build pkg-config}"
sed -e "s|@LIB_DISPLAY_NAME@|${LIB_DISPLAY}|g" \
  -e "s|@DEVCONTAINER_APT_PACKAGES@|${APT_PACKAGES}|g" \
  "$TEMPLATE/devcontainer/devcontainer.standalone.json.in" > "$LIB/.devcontainer/devcontainer.json"
sed -e "s|@CMAKE_TARGET@|${CMAKE_TARGET}|g" \
  "$TEMPLATE/CMakePresets.standalone.json.in" > "$LIB/CMakePresets.json"

echo "Synced standalone devcontainer + CMakePresets to $LIB (target: $CMAKE_TARGET)"
