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
    runa-cpp) echo "runa" ;;
    mjolnir-cpp) echo "patterns" ;;
    bor-cpp) echo "core" ;;
    mimir-cpp) echo "logging" ;;
    edda-cpp) echo "edda" ;;
    bifrost-cpp) echo "io" ;;
    nornir-cpp) echo "flow" ;;
    heimdallcv) echo "heimdallcv-core" ;;
    *) echo "$1" ;;
  esac
}

if [[ -z "$CMAKE_TARGET" ]]; then
  CMAKE_TARGET="$(resolve_cmake_target "$LIB_BASENAME")"
fi

# Core analysis / editor configs
for f in \
  .clang-format \
  .clang-tidy \
  .editorconfig \
  .cpplint \
  .gitleaks.toml \
  .pre-commit-config.yaml \
  .semgrep.yml \
  .metrixpp.yml \
  .grype.yaml \
  .syft.yaml \
  trivy.yaml \
  .shellcheckrc \
  actionlint.yaml \
  cppcheck-suppressions.xml
do
  if [[ -f "$TEMPLATE/$f" ]]; then
    cp "$TEMPLATE/$f" "$LIB/$f"
  fi
done

# CodeQL config
mkdir -p "$LIB/.github/codeql"
if [[ -f "$TEMPLATE/codeql/codeql-config.yml" ]]; then
  cp "$TEMPLATE/codeql/codeql-config.yml" "$LIB/.github/codeql/codeql-config.yml"
fi

mkdir -p "$LIB/.github/workflows"
CPPDEVOPS_REF="${CPPDEVOPS_WORKFLOW_REF:-$(git -C "$CPPDEVOPS_ROOT" rev-parse HEAD 2>/dev/null || echo main)}"
if [[ "$STANDALONE" == "1" ]]; then
  # Create-once: libraries customize callers (mobile, doc_coverage, run_sbom, SHA pins).
  # Overwriting would strip those customizations (CI-018 / CPP-SEC-003).
  if [[ ! -f "$LIB/.github/workflows/ci-quality.yml" ]]; then
    # Quota mode: manual workflow_dispatch only (CI-TRIGGER-001)
    cat > "$LIB/.github/workflows/ci-quality.yml" <<EOF
name: Quality

on:
  workflow_dispatch:
    inputs:
      blocking:
        description: Pass blocking=true when ready to enforce
        type: boolean
        default: false
  # Re-enable when Actions quota allows:
  # push:
  #   branches: [main]
  # pull_request:

jobs:
  quality:
    uses: pirlruc/cppdevops/.github/workflows/cpp-quality.yml@${CPPDEVOPS_REF}
    with:
      library_path: .
      blocking: \${{ inputs.blocking }}
  tests:
    uses: pirlruc/cppdevops/.github/workflows/cpp-tests.yml@${CPPDEVOPS_REF}
    with:
      library_path: .
      blocking: \${{ inputs.blocking }}
  docs:
    uses: pirlruc/cppdevops/.github/workflows/cpp-docs.yml@${CPPDEVOPS_REF}
    with:
      library_path: .
      blocking: \${{ inputs.blocking }}
      doc_coverage: '95'
  security:
    uses: pirlruc/cppdevops/.github/workflows/cpp-security.yml@${CPPDEVOPS_REF}
    with:
      library_path: .
      blocking: \${{ inputs.blocking }}
      # CPP-SEC-003: false for routine Quality; enable on release/merge dispatches
      run_sbom: false
  codeql:
    uses: pirlruc/cppdevops/.github/workflows/cpp-codeql.yml@${CPPDEVOPS_REF}
    with:
      library_path: .
      blocking: \${{ inputs.blocking }}
  dynamic:
    uses: pirlruc/cppdevops/.github/workflows/cpp-dynamic.yml@${CPPDEVOPS_REF}
    with:
      library_path: .
      blocking: \${{ inputs.blocking }}
  mobile:
    uses: pirlruc/cppdevops/.github/workflows/cpp-mobile-matrix.yml@${CPPDEVOPS_REF}
    with:
      library_path: .
      blocking: \${{ inputs.blocking }}
EOF
  else
    echo "keep existing $LIB/.github/workflows/ci-quality.yml (create-once)"
  fi
  mkdir -p "$LIB/cmake"
  if [[ ! -f "$LIB/cmake/pirlruc_library.cmake" ]]; then
    cp "$CPPDEVOPS_ROOT/templates/cmake/pirlruc_library.cmake" "$LIB/cmake/pirlruc_library.cmake"
  fi
  bash "$CPPDEVOPS_ROOT/scripts/sync-library-devcontainer.sh" "$LIB" "$CMAKE_TARGET" "$LIB_BASENAME"
else
  echo "warn: --monorepo mode is deprecated; prefer --standalone" >&2
fi

if [[ -x "$LIB/.github/scaffold/scripts/sync-templates.sh" ]]; then
  bash "$LIB/.github/scaffold/scripts/sync-templates.sh"
fi

# Ensure Doxyfile exists when template generator is available
if [[ ! -f "$LIB/Doxyfile" ]] && [[ -x "$CPPDEVOPS_ROOT/scripts/generate-doxyfile.sh" ]]; then
  bash "$CPPDEVOPS_ROOT/scripts/generate-doxyfile.sh" "$LIB" || true
fi

echo "Synced tooling to $LIB (target: $CMAKE_TARGET, standalone: $STANDALONE)"
