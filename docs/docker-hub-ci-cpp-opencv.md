# ci-cpp-opencv

Ubuntu 24.04 compile image with OpenCV 4.14.0 built from the release tarball
and Eigen 3.4 from `libeigen3-dev`. The same image ships vcpkg, the
`x64-linux-libcxx` triplet, and overlay ports that satisfy `opencv4` and
`eigen3` from the image instead of compiling them. Not a product runtime —
no `HEALTHCHECK`.

vcpkg is bootstrapped in the build stage. curl is not in the final image.
Analysis tools stay on [ci-cpp](docker-hub-ci-cpp.md). A vcpkg image without
OpenCV is [ci-cpp-vcpkg](docker-hub-ci-cpp-vcpkg.md).

The Hub Overview step is advisory: the publish token can push but cannot
write repository descriptions, so the first 5.2.0 publish left this
repository's Overview empty. This page is the description.

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
| `5.2.0` / `latest` | `sha256:561316dd5a31b8765f3d6569833ad5fff05bdba42d184a92d11cd4c0c738c42b` (tag index) |
| `sha-<git>` | Exact git SHA of the published commit |

Prefer a digest in production. Confirm the `linux/amd64` image manifest
before pinning Actions `container:`; a tag index is not a pullable image.

```bash
docker pull pirlruc/ci-cpp-opencv:5.2.0
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

The Ubuntu base digest is the same noble pin as `ci-cpp-ubuntu` and ages out
on 2026-10-18 (`CPPD-SCAN-001`).

## License

MIT. Source: https://github.com/pirlruc/cppdevops
