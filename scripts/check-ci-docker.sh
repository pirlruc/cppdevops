#!/usr/bin/env bash
# Run CI steps missing on the host inside ghcr.io/pirlruc/ci-lint:latest.
#
# Env:
#   CPPDEVOPS_CI_IMAGE — image ref (default ghcr.io/pirlruc/ci-lint:latest)
#   CPPDEVOPS_DOCKER_STEPS — space-separated step names (required)
#   CPPDEVOPS_BUILD_LOCAL — unused for ci-lint (pull-only); reserved
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${CPPDEVOPS_CI_IMAGE:-}"
if [[ -z "${IMAGE}" ]]; then
  if docker image inspect ci-lint:local >/dev/null 2>&1; then
    IMAGE="ci-lint:local"
  elif docker image inspect ci-lint:alpine-local >/dev/null 2>&1; then
    IMAGE="ci-lint:alpine-local"
  else
    IMAGE="ghcr.io/pirlruc/ci-lint:latest"
  fi
fi

if [[ -z "${CPPDEVOPS_DOCKER_STEPS:-}" ]]; then
  echo "CPPDEVOPS_DOCKER_STEPS is required (e.g. actionlint shellcheck hadolint zizmor yamllint)" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required for host-unavailable CI checks" >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker engine is not running" >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  echo "==> Pulling ${IMAGE}"
  if ! docker pull "${IMAGE}"; then
    echo "error: cannot pull ${IMAGE}; set CPPDEVOPS_CI_IMAGE to a local tag (e.g. ci-lint:local)" >&2
    exit 1
  fi
fi

run_step() {
  local step="$1"
  case "${step}" in
    actionlint)
      docker run --rm -v "${ROOT}:/workspace" -w /workspace "${IMAGE}" \
        sh -c 'actionlint $(find .github/workflows -name "*.yml" -o -name "*.yaml" | head -40)'
      ;;
    shellcheck)
      docker run --rm -v "${ROOT}:/workspace" -w /workspace "${IMAGE}" \
        sh -c 'shellcheck $(find scripts -name "*.sh")'
      ;;
    hadolint)
      docker run --rm -v "${ROOT}:/workspace" -w /workspace "${IMAGE}" \
        sh -c 'hadolint $(find docker -name "Dockerfile*")'
      ;;
    zizmor)
      docker run --rm -v "${ROOT}:/workspace" -w /workspace "${IMAGE}" \
        zizmor .github/workflows
      ;;
    yamllint)
      docker run --rm -v "${ROOT}:/workspace" -w /workspace "${IMAGE}" \
        yamllint -d relaxed .github/workflows docs
      ;;
    *)
      echo "unknown Docker step: ${step}" >&2
      exit 1
      ;;
  esac
}

for step in ${CPPDEVOPS_DOCKER_STEPS}; do
  echo "==> ${step} (docker ${IMAGE})"
  run_step "${step}"
done
