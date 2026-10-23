# syntax=docker/dockerfile:1
# Compile-only Ubuntu 24.04 image for CPP-BUILD-004. Analysis stays on the
# Debian and Alpine images. No DHI Ubuntu image exists.
# No HEALTHCHECK. kics-scan disable=b03a748a-542d-44f4-bb86-9199ab4fd2d5
# Base tag in a comment for DOCKER-BUILD-003: ubuntu:24.04
# Digest created 2026-10-02. base_image_max_age_days (30) fails about 2026-11-01.

FROM docker.io/library/ubuntu:24.04@sha256:68ee22004a9109b44973313b02ff7b1de250f1de0f5ecb628d73f579aaff33ac

LABEL org.opencontainers.image.title="ci-cpp-ubuntu" \
      org.opencontainers.image.description="Compile-only C++ toolchain: Clang 18, libc++, CMake, Ninja, git. Ubuntu 24.04. Non-root 1000:1000, linux/amd64." \
      org.opencontainers.image.source="https://github.com/pirlruc/cppdevops" \
      org.opencontainers.image.vendor="pirlruc" \
      org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/bin:${PATH}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      clang=1:18.0-59~exp2 \
      libc++-dev=1:18.0-59~exp2 \
      libc++abi-dev=1:18.0-59~exp2 \
      cmake=3.28.3-1build7 \
      ninja-build=1.11.1-2 \
      git=1:2.43.0-1ubuntu7.4 \
      ca-certificates=20260816ubuntu0.24.04.1 \
 && rm -rf /var/lib/apt/lists/* \
 && if ! id -u 1000 >/dev/null 2>&1; then \
      useradd --uid 1000 --create-home --shell /bin/bash ci; \
    fi \
 && mkdir -p /home/ci /workspace \
 && chown -R 1000:1000 /workspace /home/ci

WORKDIR /workspace
RUN find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -exec chmod a-s {} +
USER 1000:1000
ENTRYPOINT []
CMD ["bash"]
