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

ARG BASE=docker.io/library/ubuntu:24.04@sha256:561618e2c15bf2397621dd04f96926663a3b5616c189cf7e38db7e82f5c538ea

# ---------------------------------------------------------------------------
# pybuild — install Python CLIs into /opt/venv; uv stays out of the final image.
# ---------------------------------------------------------------------------
# hadolint ignore=DL3006
FROM ${BASE} AS pybuild
# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      python3 \
      python3-venv \
 && rm -rf /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:0.12.0@sha256:606e70c71c852d03f611b1e56a195d08648507018a7057fab82c4974c4eae105 \
  /uv /usr/local/bin/uv
ENV UV_PYTHON=/usr/bin/python3 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
RUN python3 -m venv /opt/venv \
 && /usr/local/bin/uv pip install --python /opt/venv/bin/python --no-cache \
      'pip==26.2.1' \
      'msgpack==1.2.1' \
      'coverxygen==1.8.2' \
      'cpplint==2.0.2' \
      'gcovr==8.6' \
      'lizard==1.17.10' \
      'metrixpp==1.8.1' \
      'pyyaml==6.0.3' \
 && find /opt/venv -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true \
 && find /opt/venv -type f -name '*.pyc' -delete

# ---------------------------------------------------------------------------
# Final image
# ---------------------------------------------------------------------------
# hadolint ignore=DL3006
FROM ${BASE}

LABEL org.opencontainers.image.title="ci-cpp" \
      org.opencontainers.image.description="Short-lived C++ CI toolchain for pirlruc/cppdevops: Clang/libc++, CMake, Ninja, cppcheck, clang-tidy/format, Doxygen, gcovr, lizard, Metrix++, coverxygen, valgrind. Ubuntu 24.04. Non-root 1000:1000, linux/amd64." \
      org.opencontainers.image.source="https://github.com/pirlruc/cppdevops" \
      org.opencontainers.image.url="https://github.com/pirlruc/cppdevops/pkgs/container/ci-cpp" \
      org.opencontainers.image.documentation="https://github.com/pirlruc/cppdevops/blob/main/docs/workflows.md" \
      org.opencontainers.image.vendor="pirlruc" \
      org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/opt/venv/bin:/usr/local/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Single RUN for apt + non-root user to keep dive efficiency above org floor.
# Base image is digest-pinned; apt package versions float within Ubuntu 24.04.
# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      clang \
      clang-format \
      clang-tidy \
      cmake \
      cppcheck \
      doxygen \
      graphviz \
      libc++-dev \
      libc++abi-dev \
      llvm \
      ninja-build \
      python3 \
      valgrind \
      ca-certificates \
      git \
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
