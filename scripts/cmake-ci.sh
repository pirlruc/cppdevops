#!/bin/sh
# Run cmake, adding the vcpkg toolchain when USE_VCPKG=true.
set -eu

if [ "${USE_VCPKG:-false}" = "true" ]; then
  root="${VCPKG_ROOT:-}"
  tool="${root}/scripts/buildsystems/vcpkg.cmake"
  if [ ! -f "${tool}" ]; then
    echo "use_vcpkg: container has no VCPKG_ROOT toolchain (${root})" >&2
    exit 1
  fi
  exec cmake "-DCMAKE_TOOLCHAIN_FILE=${tool}" "$@"
fi

exec cmake "$@"
