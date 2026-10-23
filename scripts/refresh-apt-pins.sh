#!/usr/bin/env bash
# Refresh apt version pins by reading the candidate version inside Docker.
# Also moves ubuntu:24.04 FROM digests to the tag's current index digest.
#
# Usage: scripts/refresh-apt-pins.sh [Dockerfile ...]
# Default: the four images that pin apt packages.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required" >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  set -- \
    docker/ci-cpp/Dockerfile \
    docker/ci-cpp-ubuntu/Dockerfile \
    docker/ci-cpp-vcpkg/Dockerfile \
    docker/ci-cpp-opencv/Dockerfile
fi

refresh_ubuntu_digest() {
  local file="$1"
  if ! grep -q 'ubuntu:24.04@sha256:' "${file}"; then
    return
  fi
  local digest
  digest="$(docker buildx imagetools inspect docker.io/library/ubuntu:24.04 | awk '/^Digest:/ {print $2; exit}')"
  if [[ -z "${digest}" ]]; then
    echo "could not resolve ubuntu:24.04" >&2
    exit 1
  fi
  python3 - "${file}" "${digest}" <<'PY'
import pathlib, re, sys
path, digest = sys.argv[1], sys.argv[2]
file = pathlib.Path(path)
text = file.read_text()
new, count = re.subn(r"(ubuntu:24\.04@)sha256:[0-9a-f]+", rf"\1{digest}", text)
if new != text:
    file.write_text(new)
print(f"{path}: ubuntu digest {digest} ({count} pins)")
PY
}

base_for() {
  local file="$1"
  local from
  from="$(grep -E '^FROM ' "${file}" | head -1 | awk '{print $2}')"
  if [[ -z "${from}" ]]; then
    echo "no FROM in ${file}" >&2
    exit 1
  fi
  printf '%s\n' "${from}"
}

refresh_packages() {
  local file="$1"
  local base="$2"
  local packages
  packages="$(grep -E '^[[:space:]]+[a-z0-9][a-z0-9.+-]*=[0-9]' "${file}" | awk '{print $1}' | cut -d= -f1 | sort -u)"
  if [[ -z "${packages}" ]]; then
    echo "${file}: no apt pins"
    return
  fi
  local listing joined
  joined="$(printf '%s' "${packages}" | tr '\n' ' ')"
  listing="$(docker run --rm --user root -e DEBIAN_FRONTEND=noninteractive -e PKGS="${joined}" "${base}" bash -c '
    apt-get update -qq
    for pkg in $PKGS; do
      ver="$(apt-cache policy "${pkg}" | awk "/Candidate:/ {print \$2; exit}")"
      printf "%s %s\n" "${pkg}" "${ver}"
    done
  ')"
  python3 - "${file}" "${listing}" <<'PY'
import pathlib, sys
path, listing = sys.argv[1], sys.argv[2]
file = pathlib.Path(path)
text = file.read_text()
import re
changed = []
rows = []
for line in listing.splitlines():
    pkg, ver = line.split(" ", 1)
    rows.append((pkg, ver))
rows.sort(key=lambda item: len(item[0]), reverse=True)
for pkg, ver in rows:
    if not ver or ver == "(none)":
        print(f"{path}: {pkg} has no candidate; left pinned")
        continue
    new, count = re.subn(
        rf"(?<![A-Za-z0-9.+-])({re.escape(pkg)})=[^ \\\n]+",
        rf"\1={ver}",
        text,
    )
    if count and new != text:
        changed.append(f"{pkg}={ver}")
        text = new
if changed:
    file.write_text(text)
print(f"{path}: " + (", ".join(changed) if changed else "pins already current"))
PY
}

for file in "$@"; do
  refresh_ubuntu_digest "${file}"
  base="$(base_for "${file}")"
  echo "${file}: apt query in ${base}"
  refresh_packages "${file}" "${base}"
done
