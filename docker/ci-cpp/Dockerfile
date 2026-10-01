# syntax=docker/dockerfile:1
# C++ CI toolchain image — Ubuntu 24.04 (CPP-BUILD-004 / CPP-BUILD-009).
# Lint/secrets/SAST and SBOM scanners live in commondevops ci-lint /
# ci-supply-chain; cpp-* workflows forward there. This image keeps the
# compile/test/doc/quality toolchain only.
#
# uv is COPY --from a digest-pinned donor (build stage only). The venv is
# built on Ubuntu so it matches the final Python (3.12), not a Debian 13 donor.
#
# No HEALTHCHECK: short-lived CI toolchain (CLI job container), not a supervised
# service (DOCKER-RUN-002 / DOCKER-RUN-006).
# Publish target: ghcr.io/pirlruc/ci-cpp
#
# Base tag in a comment for DOCKER-BUILD-003: ubuntu:24.04
# Both stages repeat this digest. check-base-image-age.sh pulls every FROM
# that is not scratch or ${ARG}, so a stage name such as `os` fails closed.
# Digest refreshed 2026-10-01. The image config Created date is still
# 2026-09-11, so base_image_max_age_days (30) fails on 2026-10-11 until Ubuntu
# publishes a newer noble config. Do not move this image to ubuntu:26.04
# (CPP-BUILD-004).

FROM docker.io/library/ubuntu:26.04@sha256:da6fc2be547864451aa253836dd926da33623312df4a9a243e35dc877c378a78 AS pybuild

# ---------------------------------------------------------------------------
# pybuild — install Python CLIs into /opt/venv; uv and pip stay out of the
# final image. pip 26.2.1 vendors msgpack 1.1.2 (GHSA-6v7p-g79w-8964); the
# tools do not need pip at runtime.
# ---------------------------------------------------------------------------
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates=20260601~24.04.1 \
      python3=3.12.3-0ubuntu2.1 \
      python3-venv=3.12.3-0ubuntu2.1 \
 && rm -rf /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:0.12.0@sha256:606e70c71c852d03f611b1e56a195d08648507018a7057fab82c4974c4eae105 \
  /uv /usr/local/bin/uv
ENV UV_PYTHON=/usr/bin/python3 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
RUN python3 -m venv /opt/venv \
 && /usr/local/bin/uv pip install --python /opt/venv/bin/python --no-cache \
      'pip==26.2.1' \
      'setuptools==84.0.0' \
      'msgpack==1.2.3' \
      'clang-format==23.1.0' \
      'pygments==2.21.0' \
      'coverxygen==1.8.2' \
      'cpplint==2.0.2' \
      'gcovr==8.6' \
      'lizard==1.17.10' \
      'metrixpp==1.8.1' \
      'pyyaml==6.0.3' \
 && /usr/local/bin/uv pip uninstall --python /opt/venv/bin/python pip \
 && find /opt/venv -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true \
 && find /opt/venv -type f -name '*.pyc' -delete

# ---------------------------------------------------------------------------
# Final image
# ---------------------------------------------------------------------------
FROM docker.io/library/ubuntu:26.04@sha256:da6fc2be547864451aa253836dd926da33623312df4a9a243e35dc877c378a78

LABEL org.opencontainers.image.title="ci-cpp" \
      org.opencontainers.image.description="Short-lived C++ CI toolchain for pirlruc/cppdevops: Clang/libc++, CMake, Ninja, cppcheck, clang-tidy/format, Doxygen, gcovr, lizard, Metrix++, coverxygen, cloc, valgrind. Ubuntu 24.04. Non-root 1000:1000, linux/amd64." \
      org.opencontainers.image.source="https://github.com/pirlruc/cppdevops" \
      org.opencontainers.image.url="https://github.com/pirlruc/cppdevops/pkgs/container/ci-cpp" \
      org.opencontainers.image.documentation="https://github.com/pirlruc/cppdevops/blob/main/docs/workflows.md" \
      org.opencontainers.image.vendor="pirlruc" \
      org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/opt/venv/bin:/usr/local/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Apt versions are pinned (DL3008 / DOCKER-BUILD-004). `upgrade` moves
# already-installed base packages onto the noble-security candidate before
# the pinned install locks the toolchain and the packages Docker Scout
# reported as fixable on ci-cpp:3.1.0.
# linux-libc-dev 6.8.0-142.142 clears the fixable kernel highs
# (CVE-2025-10263, CVE-2026-53186, CVE-2026-64091). Unfixed kernel advisories
# still attach to this header package; the compiler image needs it.
RUN apt-get update \
 && apt-get upgrade -y --no-install-recommends \
 && apt-get install -y --no-install-recommends \
      clang=1:18.0-59~exp2 \
      clang-tidy=1:18.0-59~exp2 \
      cmake=3.28.3-1build7 \
      cppcheck=2.13.0-2ubuntu3 \
      doxygen=1.9.8+ds-2ubuntu0.1 \
      graphviz=2.42.2-9ubuntu0.1 \
      libc++-dev=1:18.0-59~exp2 \
      libc++abi-dev=1:18.0-59~exp2 \
      libclang-rt-18-dev=1:18.1.3-1ubuntu1 \
      libfuzzer-18-dev=1:18.1.3-1ubuntu1 \
      llvm=1:18.0-59~exp2 \
      ninja-build=1.11.1-2 \
      python3=3.12.3-0ubuntu2.1 \
      valgrind=1:3.22.0-0ubuntu3 \
      ca-certificates=20260601~24.04.1 \
      git=1:2.43.0-1ubuntu7.3 \
      cloc=1.98-1 \
      linux-libc-dev=6.8.0-142.142 \
      libexpat1=2.6.1-2ubuntu0.6 \
      libglib2.0-0t64=2.80.0-6ubuntu3.9 \
      libglib2.0-bin=2.80.0-6ubuntu3.9 \
      libglib2.0-data=2.80.0-6ubuntu3.9 \
      util-linux=2.39.3-9ubuntu6.6 \
      bsdutils=1:2.39.3-9ubuntu6.6 \
      mount=2.39.3-9ubuntu6.6 \
      libblkid1=2.39.3-9ubuntu6.6 \
      libmount1=2.39.3-9ubuntu6.6 \
      libsmartcols1=2.39.3-9ubuntu6.6 \
      libuuid1=2.39.3-9ubuntu6.6 \
      libfdisk1=2.39.3-9ubuntu6.6 \
      libaom3=3.8.2-2ubuntu0.2 \
      curl=8.5.0-2ubuntu10.15 \
      libcurl4t64=8.5.0-2ubuntu10.15 \
      libxml2=2.9.14+dfsg-1.3ubuntu3.9 \
      perl=5.38.2-3.2ubuntu0.6 \
      perl-base=5.38.2-3.2ubuntu0.6 \
      perl-modules-5.38=5.38.2-3.2ubuntu0.6 \
      libperl5.38t64=5.38.2-3.2ubuntu0.6 \
      libsystemd0=255.4-1ubuntu8.17 \
      libp11-kit0=0.25.3-4ubuntu2.2 \
      libsqlite3-0=3.45.1-1ubuntu2.8 \
      libattr1=1:2.5.2-1ubuntu0.1 \
      diffutils=1:3.10-1ubuntu0.1 \
      bzip2=1.0.8-5.1ubuntu0.1 \
      libbz2-1.0=1.0.8-5.1ubuntu0.1 \
      libgcrypt20=1.10.3-2ubuntu0.2 \
      coreutils=9.4-3ubuntu6.3 \
      gpg=2.4.4-2ubuntu17.6 \
      gnupg=2.4.4-2ubuntu17.6 \
      zlib1g=1:1.3.dfsg-3.1ubuntu2.2 \
      libncursesw6=6.4+20240113-1ubuntu2.2 \
      ncurses-base=6.4+20240113-1ubuntu2.2 \
 && rm -rf /var/lib/apt/lists/* \
 && if ! id -u 1000 >/dev/null 2>&1; then \
      useradd --uid 1000 --create-home --shell /bin/bash ci; \
    fi \
 && mkdir -p /home/ci /workspace \
 && chown -R 1000:1000 /workspace /home/ci

COPY --from=pybuild --chown=1000:1000 /opt/venv /opt/venv

WORKDIR /workspace
USER 1000:1000

ENTRYPOINT []
CMD ["bash"]
