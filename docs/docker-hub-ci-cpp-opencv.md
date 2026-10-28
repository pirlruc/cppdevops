# ci-cpp-opencv

Ubuntu 24.04 compile image with OpenCV 4.14.0 built from the release tarball
and Eigen 3.4 from `libeigen3-dev`. The same image ships vcpkg, the
`x64-linux-libcxx` triplet, and overlay ports that satisfy `opencv4` and
`eigen3` from the image instead of compiling them. Not a product runtime —
no `HEALTHCHECK`.

vcpkg is bootstrapped in the build stage. curl is not in the final image.
Analysis tools stay on [ci-cpp](https://hub.docker.com/r/pirlruc/ci-cpp). A vcpkg image without
OpenCV is [ci-cpp-vcpkg](https://hub.docker.com/r/pirlruc/ci-cpp-vcpkg).

## Image

| Item | Value |
|------|--------|
| Docker Hub | `pirlruc/ci-cpp-opencv` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Ubuntu 24.04 official |
| Context | `docker/ci-cpp-opencv/` |

### Tags

| Tag | Digest |
|-----|--------|
| `6.3.0` / `latest` | `sha256:5b45c9c5a158b7b861f7933aac01d08b110eb0f2b692e02d778c64a054264368` (tag index) |
| `6.3.0` `linux/amd64` (Actions) | `sha256:42ba66c3c4c1b4f9552d43f11fa6eace05608000434b35e520b79c560dda4773` |
| `6.2.1` | Previous image. `sha256:406fe12b00792678a55b549f082487123bf9fe738200e5b0837a728437a2fb80` (tag index) |
| `6.2.1` `linux/amd64` | `sha256:4185b1185f9a453712eca90935a0c253090caf008c2a1f0582547589a3c82b86` |
| `6.0.0` | Previous image. `sha256:79089fae85e7dd80bf5eb58c337fa84b81d6e5a2d6d28a3a1ea61407b1fb1fe2` (tag index) |
| `6.0.0` `linux/amd64` | `sha256:c167f4b2c3cd19d522992f406ceebabf19922e6bbb05cfa6aec77c9d4416ed23` |
| `5.2.0` | Previous image. `sha256:561316dd5a31b8765f3d6569833ad5fff05bdba42d184a92d11cd4c0c738c42b` (tag index) |
| `sha-<git>` | Exact git SHA of the published commit |

Prefer a digest in production. Pin the `linux/amd64` image manifest. A tag
index is not a pullable Actions `container:`.

```bash
docker pull pirlruc/ci-cpp-opencv:6.3.0
docker pull pirlruc/ci-cpp-opencv@sha256:42ba66c3c4c1b4f9552d43f11fa6eace05608000434b35e520b79c560dda4773
```

## What is inside

| Tool | Role |
|------|------|
| clang / clang++ / libc++ | Compile on Clang 18 |
| cmake / ninja / git | Configure and build |
| OpenCV 4.14.0 | Modules `core`, `imgproc`, `imgcodecs`, built with libc++. Tarball SHA-256 `ee8fb9b30eb60850431b4656447080e3737b56e45719c92b67f245950609f86e` |
| Eigen 3.4 | `libeigen3-dev`. `WITH_EIGEN=OFF` on the OpenCV build |
| vcpkg `434307da` | `/opt/vcpkg`, triplet `/opt/vcpkg-triplets`, overlays `/opt/vcpkg-overlays` |
| overlay `opencv4` | Empty port. Sets `OpenCV_DIR` to `/usr/local/lib/cmake/opencv4` |
| overlay `eigen3` | Empty port. Sets `Eigen3_DIR` to `/usr/share/eigen3/cmake` |

System jpeg, png, and zlib are present. curl is not.

The Ubuntu base matches `ci-cpp-ubuntu`:
`ubuntu:24.04@sha256:24737cef17f4e22b1977df7d9a05e77c4e28b7da5b8911f8d8ccda136bf3573c`.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
