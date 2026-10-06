# syntax=docker/dockerfile:1
# C++ analysis image on DHI Debian 13. Ubuntu compile coverage is
# docker/ci-cpp/Dockerfile.ubuntu (CPP-BUILD-004). Devcontainers stay Ubuntu.
#
# No HEALTHCHECK: short-lived CI toolchain, not a supervised service.
# kics-scan disable=b03a748a-542d-44f4-bb86-9199ab4fd2d5
# Base tag in a comment for DOCKER-BUILD-003: dhi.io/python:3.13-debian13-dev

FROM dhi.io/python:3.14-debian13-dev@sha256:2862b68470650afe57e569b24695d6df9184105ee298fdf83ca7572ea076fe5e AS pybuild
COPY --from=ghcr.io/astral-sh/uv:0.12.0@sha256:606e70c71c852d03f611b1e56a195d08648507018a7057fab82c4974c4eae105 \
  /uv /usr/local/bin/uv
COPY requirements.txt /tmp/requirements.txt
RUN /usr/local/bin/uv venv /opt/venv --python /usr/bin/python3 \
 && /usr/local/bin/uv pip install --python /opt/venv/bin/python --no-cache --require-hashes \
      -r /tmp/requirements.txt \
 && rm -f /tmp/requirements.txt \
 && find /opt/venv -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true

FROM dhi.io/python:3.14-debian13-dev@sha256:2862b68470650afe57e569b24695d6df9184105ee298fdf83ca7572ea076fe5e

LABEL org.opencontainers.image.title="ci-cpp" \
      org.opencontainers.image.description="C++ analysis toolchain: Clang 18, libc++, CMake, Ninja, cppcheck, clang-tidy, Doxygen, gcovr, lizard, Metrix++, coverxygen, valgrind. Debian 13. Non-root 1000:1000, linux/amd64." \
      org.opencontainers.image.source="https://github.com/pirlruc/cppdevops" \
      org.opencontainers.image.vendor="pirlruc" \
      org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/opt/venv/bin:/usr/local/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER root
# libclang-rt-18-dev Depends on lib32stdc++6, which conflicts with the DHI
# libc. Extract the deb so the amd64 sanitizer runtimes are present.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      clang-18=1:18.1.8-18+b1 \
      clang-tidy-18=1:18.1.8-18+b1 \
      libc++-18-dev=1:18.1.8-18+b1 \
      libc++abi-18-dev=1:18.1.8-18+b1 \
      libfuzzer-18-dev=1:18.1.8-18+b1 \
      llvm-18=1:18.1.8-18+b1 \
      cmake=3.31.6-2 \
      ninja-build=1.12.1-1 \
      cppcheck=2.17.1-2 \
      valgrind=1:3.24.0-3 \
      doxygen=1.9.8+ds-2.1 \
      git=1:2.47.3-0+deb13u1+dhi2 \
      ca-certificates=20250419+dhi2 \
 && apt-get download libclang-rt-18-dev=1:18.1.8-18+b1 \
 && dpkg-deb -x libclang-rt-18-dev_*.deb /tmp/rt \
 && cp -a /tmp/rt/usr/. /usr/ \
 && rm -rf /tmp/rt /tmp/libclang-rt-18-dev_*.deb /var/lib/apt/lists/* \
 && mkdir -p /usr/local/bin \
 && ln -sf /usr/bin/clang-18 /usr/local/bin/clang \
 && ln -sf /usr/bin/clang++-18 /usr/local/bin/clang++ \
 && ln -sf /usr/bin/clang-tidy-18 /usr/local/bin/clang-tidy \
 && ln -sf /usr/bin/llvm-cov-18 /usr/local/bin/llvm-cov \
 && ln -sf /usr/bin/llvm-profdata-18 /usr/local/bin/llvm-profdata \
 && ln -sf /usr/bin/llvm-symbolizer-18 /usr/local/bin/llvm-symbolizer \
 && if ! id -u 1000 >/dev/null 2>&1; then \
      printf 'ci:x:1000:1000::/home/ci:/bin/sh\n' >> /etc/passwd; \
      printf 'ci:x:1000:\n' >> /etc/group; \
    fi \
 && mkdir -p /home/ci /workspace \
 && chown -R 1000:1000 /workspace /home/ci

COPY --from=pybuild --chown=1000:1000 /opt/venv /opt/venv

WORKDIR /workspace
RUN find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -exec chmod a-s {} +
USER 1000:1000
ENTRYPOINT []
CMD ["sh"]
