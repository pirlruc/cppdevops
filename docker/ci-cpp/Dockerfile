# syntax=docker/dockerfile:1
# C++ CI toolchain image — Ubuntu 24.04 (CPP-BUILD-004 / CPP-BUILD-009).
# Scanner CLIs are COPY --from DHI / Hub donors to match commondevops ci-base.
# Publish target: ghcr.io/pirlruc/ci-cpp

FROM docker.io/library/ubuntu:24.04@sha256:561618e2c15bf2397621dd04f96926663a3b5616c189cf7e38db7e82f5c538ea

LABEL org.opencontainers.image.title="ci-cpp" \
      org.opencontainers.image.description="C++ CI toolchain for pirlruc/cppdevops" \
      org.opencontainers.image.source="https://github.com/pirlruc/cppdevops" \
      org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/opt/venv/bin:/usr/local/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

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
      ninja-build \
      python3 \
      python3-pip \
      python3-venv \
      valgrind \
      ca-certificates \
      curl \
      git \
 && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir \
      coverxygen \
      cpplint \
      gcovr \
      lizard \
      metrixpp \
      pyyaml

# Shared scanners (same digests as commondevops ci-base, 2026-08-10)
COPY --from=dhi.io/syft:1-debian13@sha256:3484ac184dd20f130a2f7b7ceb57b2e4f21a264338bb384295ea72bb825b2e3c \
  /usr/bin/syft /usr/local/bin/syft
COPY --from=dhi.io/grype:0-debian13@sha256:b5af85761b7c2cd5afbfc8e75ca3b23d6a706c14c3831966f2e25218ff2da23f \
  /usr/bin/grype /usr/local/bin/grype
COPY --from=dhi.io/trivy:0-debian13@sha256:f957a8173ddfc1e82cd4454fd760011e65cb03f42ffe67a91fe105a140ffade5 \
  /usr/bin/trivy /usr/local/bin/trivy
COPY --from=dhi.io/gitleaks:8-debian13@sha256:08b93b96ee818647ab1fb8e148bf8af4e1190b344e48b0e9bfa57eae98db8117 \
  /usr/local/bin/gitleaks /usr/local/bin/gitleaks
COPY --from=dhi.io/shellcheck:0-debian13@sha256:eb696ecbc0a6dbe57588d88c700c3da7cce3824f8c865795348f9b51c7524331 \
  /usr/local/bin/shellcheck /usr/local/bin/shellcheck
COPY --from=hadolint/hadolint:2.12.0-alpine /bin/hadolint /usr/local/bin/hadolint
COPY --from=rhysd/actionlint:1.7.7 /usr/local/bin/actionlint /usr/local/bin/actionlint

WORKDIR /workspace
ENTRYPOINT []
CMD ["bash"]
