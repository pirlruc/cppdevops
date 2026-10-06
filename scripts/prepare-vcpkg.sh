#!/bin/sh
# Prepare a vcpkg manifest build. No-op unless USE_VCPKG=true.
# CHECKOUT_TOKEN, when set, is written only into a gitconfig file so
# vcpkg_from_git can clone private ports. The token is never printed.
set -eu

if [ "${USE_VCPKG:-false}" != "true" ]; then
  exit 0
fi

mkdir -p "${GITHUB_WORKSPACE}/.vcpkg-bin"

if [ -n "${GITHUB_ENV:-}" ]; then
  printf 'VCPKG_DEFAULT_BINARY_CACHE=%s\n' "${GITHUB_WORKSPACE}/.vcpkg-bin" >> "${GITHUB_ENV}"
  printf 'VCPKG_DISABLE_METRICS=1\n' >> "${GITHUB_ENV}"
fi

if [ -z "${CHECKOUT_TOKEN:-}" ]; then
  exit 0
fi

dest="${RUNNER_TEMP:-/tmp}/vcpkg-gitconfig"
umask 077
git config --file "${dest}" \
  "url.https://x-access-token:${CHECKOUT_TOKEN}@github.com/.insteadOf" \
  "https://github.com/"
if [ -n "${GITHUB_ENV:-}" ]; then
  printf 'GIT_CONFIG_GLOBAL=%s\n' "${dest}" >> "${GITHUB_ENV}"
fi
