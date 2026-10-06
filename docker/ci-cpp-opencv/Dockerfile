# syntax=docker/dockerfile:1
# OpenCV compile image. OpenCV 4.14.0 is built from the release tarball because
# the vcpkg port lags the 4.x release the vision libraries need. Eigen is the
# distro package so find_package(Eigen3) stays on 3.4. Overlay ports make
# manifest installs reuse those system libraries instead of compiling them.
# vcpkg and the libc++ triplet are copied from the build stage. curl stays in
# the build stage only.
# No HEALTHCHECK. kics-scan disable=b03a748a-542d-44f4-bb86-9199ab4fd2d5
# Base tag in a comment for DOCKER-BUILD-003: ubuntu:24.04
# Digest Created 2026-09-17 (same index as ci-cpp-ubuntu).
# base_image_max_age_days (30) fails on 2026-10-18 until Canonical publishes a newer image.

FROM docker.io/library/ubuntu:24.04@sha256:534baea6a22c03a63003dbc8dbe78fe34bc0d7e595d9a9dc9834884ff530eb55 AS opencv-build

ENV DEBIAN_FRONTEND=noninteractive \
    OPENCV_VERSION=4.14.0 \
    VCPKG_COMMIT=434307da09bc05b2c86996dccc8b2351fc0d5d37

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates=20260601~24.04.1 \
      clang=1:18.0-59~exp2 \
      cmake=3.28.3-1build7 \
      curl=8.5.0-2ubuntu10.15 \
      git=1:2.43.0-1ubuntu7.3 \
      gzip=1.12-1ubuntu3.2 \
      libc++-dev=1:18.0-59~exp2 \
      libc++abi-dev=1:18.0-59~exp2 \
      libeigen3-dev=3.4.0-4build0.1 \
      libjpeg-turbo8-dev=2.1.5-2ubuntu2 \
      libpng-dev=1.6.43-5ubuntu0.6 \
      nasm=2.16.01-1build1 \
      ninja-build=1.11.1-2 \
      pkg-config=1.8.1-2build1 \
      unzip=6.0-28ubuntu4.1 \
      zip=3.0-13ubuntu0.2 \
      zlib1g-dev=1:1.3.dfsg-3.1ubuntu2.2 \
 && rm -rf /var/lib/apt/lists/*

RUN curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      -o /tmp/opencv.tar.gz \
      "https://github.com/opencv/opencv/archive/refs/tags/${OPENCV_VERSION}.tar.gz" \
 && printf '%s\n' "ee8fb9b30eb60850431b4656447080e3737b56e45719c92b67f245950609f86e  /tmp/opencv.tar.gz" > /tmp/opencv.sha256 \
 && sha256sum -c /tmp/opencv.sha256 \
 && tar -xzf /tmp/opencv.tar.gz -C /tmp \
 && cmake -S "/tmp/opencv-${OPENCV_VERSION}" -B /tmp/opencv-build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
      -DCMAKE_EXE_LINKER_FLAGS="-stdlib=libc++" \
      -DCMAKE_SHARED_LINKER_FLAGS="-stdlib=libc++" \
      -DBUILD_LIST=core,imgproc,imgcodecs \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_opencv_apps=OFF \
      -DBUILD_DOCS=OFF \
      -DWITH_GTK=OFF \
      -DWITH_FFMPEG=OFF \
      -DWITH_V4L=OFF \
      -DWITH_QT=OFF \
      -DWITH_OPENGL=OFF \
      -DWITH_IPP=OFF \
      -DWITH_EIGEN=OFF \
      -DBUILD_JPEG=OFF \
      -DBUILD_PNG=OFF \
      -DBUILD_ZLIB=OFF \
      -DOPENCV_GENERATE_PKGCONFIG=ON \
 && cmake --build /tmp/opencv-build --target install \
 && rm -rf /tmp/opencv.tar.gz /tmp/opencv-build "/tmp/opencv-${OPENCV_VERSION}"

RUN curl -fsSL --retry 5 --retry-delay 2 --retry-all-errors -o /tmp/vcpkg.tar.gz \
      "https://github.com/microsoft/vcpkg/archive/${VCPKG_COMMIT}.tar.gz" \
 && tar -xzf /tmp/vcpkg.tar.gz -C /opt \
 && rm -f /tmp/vcpkg.tar.gz \
 && mv "/opt/vcpkg-${VCPKG_COMMIT}" /opt/vcpkg \
 && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

FROM docker.io/library/ubuntu:24.04@sha256:534baea6a22c03a63003dbc8dbe78fe34bc0d7e595d9a9dc9834884ff530eb55

LABEL org.opencontainers.image.title="ci-cpp-opencv" \
      org.opencontainers.image.description="Compile image: Clang 18, libc++, CMake, Ninja, vcpkg, OpenCV 4.14.0, Eigen 3.4. Ubuntu 24.04. Non-root 1000:1000, linux/amd64." \
      org.opencontainers.image.source="https://github.com/pirlruc/cppdevops" \
      org.opencontainers.image.vendor="pirlruc" \
      org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/opt/vcpkg:/usr/local/bin:${PATH}" \
    VCPKG_ROOT=/opt/vcpkg \
    VCPKG_DISABLE_METRICS=1 \
    VCPKG_DEFAULT_BINARY_CACHE=/vcpkg-cache \
    VCPKG_DEFAULT_TRIPLET=x64-linux-libcxx \
    VCPKG_OVERLAY_TRIPLETS=/opt/vcpkg-triplets \
    VCPKG_OVERLAY_PORTS=/opt/vcpkg-overlays

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates=20260601~24.04.1 \
      clang=1:18.0-59~exp2 \
      cmake=3.28.3-1build7 \
      git=1:2.43.0-1ubuntu7.3 \
      gzip=1.12-1ubuntu3.2 \
      libc++-dev=1:18.0-59~exp2 \
      libc++abi-dev=1:18.0-59~exp2 \
      libeigen3-dev=3.4.0-4build0.1 \
      libjpeg-turbo8-dev=2.1.5-2ubuntu2 \
      libpng-dev=1.6.43-5ubuntu0.6 \
      nasm=2.16.01-1build1 \
      ninja-build=1.11.1-2 \
      pkg-config=1.8.1-2build1 \
      unzip=6.0-28ubuntu4.1 \
      zip=3.0-13ubuntu0.2 \
      zlib1g-dev=1:1.3.dfsg-3.1ubuntu2.2 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=opencv-build /usr/local /usr/local
COPY --from=opencv-build --chown=1000:1000 /opt/vcpkg /opt/vcpkg
COPY triplets/ /opt/vcpkg-triplets/
COPY vcpkg-overlays/ /opt/vcpkg-overlays/

RUN ldconfig \
 && if ! id -u 1000 >/dev/null 2>&1; then \
      useradd --uid 1000 --create-home --shell /bin/bash ci; \
    fi \
 && mkdir -p /workspace /vcpkg-cache \
 && chown -R 1000:1000 /workspace /vcpkg-cache /opt/vcpkg-triplets /opt/vcpkg-overlays \
 && find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -exec chmod a-s {} +

WORKDIR /workspace
USER 1000:1000
ENTRYPOINT []
CMD ["bash"]
