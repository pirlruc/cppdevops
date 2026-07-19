#!/usr/bin/env bash
# Copy shared C++ tooling configs into a library repo root.
# Canonical home: pirlruc/cppdevops (templates under templates/cpp).
set -euo pipefail

LIB_ARG="${1:?library path required (absolute or relative to cwd)}"
shift || true

STANDALONE=1
CMAKE_TARGET=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --standalone) STANDALONE=1; shift ;;
    --monorepo) STANDALONE=0; shift ;;
    *) CMAKE_TARGET="$1"; shift ;;
  esac
done

CPPDEVOPS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$CPPDEVOPS_ROOT/templates/cpp"
LIB="$(cd "$LIB_ARG" && pwd)"
LIB_BASENAME="$(basename "$LIB")"

resolve_cmake_target() {
  case "$1" in
    draupnir-cpp|drawer) echo "improc-drawer" ;;
    runa-cpp) echo "traits" ;;
    mjolnir-cpp) echo "patterns" ;;
    bor-cpp) echo "core" ;;
    mimir-cpp) echo "logging" ;;
    edda-cpp) echo "json" ;;
    bifrost-cpp) echo "io" ;;
    nornir-cpp) echo "flow" ;;
    heimdallcv) echo "heimdallcv-core" ;;
    *) echo "$1" ;;
  esac
}

if [[ -z "$CMAKE_TARGET" ]]; then
  CMAKE_TARGET="$(resolve_cmake_target "$LIB_BASENAME")"
fi

for f in .clang-format .clang-tidy .editorconfig .cpplint .gitleaks.toml .pre-commit-config.yaml; do
  cp "$TEMPLATE/$f" "$LIB/$f"
done

mkdir -p "$LIB/.github/workflows"
if [[ "$STANDALONE" == "1" ]]; then
  cat > "$LIB/.github/workflows/ci-quality.yml" <<EOF
name: Quality

on:
  push:
    branches: [main]
  pull_request:

jobs:
  quality:
    uses: pirlruc/cppdevops/.github/workflows/cpp-quality.yml@main
    with:
      library_path: .
      blocking: false
  tests:
    uses: pirlruc/cppdevops/.github/workflows/cpp-tests.yml@main
    with:
      library_path: .
      blocking: false
  docs:
    uses: pirlruc/cppdevops/.github/workflows/cpp-docs.yml@main
    with:
      library_path: .
      blocking: false
  security:
    uses: pirlruc/cppdevops/.github/workflows/cpp-security.yml@main
    with:
      library_path: .
      blocking: false
EOF
  mkdir -p "$LIB/cmake"
  if [[ ! -f "$LIB/cmake/improc_library.cmake" ]]; then
    cp "$CPPDEVOPS_ROOT/templates/cmake/improc_library.cmake" "$LIB/cmake/improc_library.cmake"
  fi
  bash "$CPPDEVOPS_ROOT/scripts/sync-library-devcontainer.sh" "$LIB" "$CMAKE_TARGET" "$LIB_BASENAME"
else
  echo "warn: --monorepo mode is deprecated; prefer --standalone" >&2
fi

if [[ -x "$LIB/.github/scaffold/scripts/sync-templates.sh" ]]; then
  bash "$LIB/.github/scaffold/scripts/sync-templates.sh"
fi

echo "Synced tooling to $LIB (target: $CMAKE_TARGET, standalone: $STANDALONE)"
