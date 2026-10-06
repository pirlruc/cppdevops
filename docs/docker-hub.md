# ci-cpp

Short-lived C++ CI toolchain images. `ci-cpp-image.yml` publishes `ci-cpp`,
`ci-cpp-ubuntu`, and `ci-cpp-vcpkg` to Docker Hub and GitHub Packages. The unsuffixed `ci-cpp`
tag is the Debian 13 analysis image (Clang 18, libc++, CMake, Ninja, cppcheck,
clang-tidy/format, Doxygen, gcovr, lizard, Metrix++, coverxygen, valgrind).
`ci-cpp` `-alpine` is the Alpine 3.24 analysis image (Clang 20, because Alpine
libc++ is LLVM 22). `ci-cpp-ubuntu` is compile-only: Clang 18, libc++, CMake,
Ninja, and git. `ci-cpp-vcpkg` is the Debian analysis image plus a pinned
vcpkg (`434307da09bc05b2c86996dccc8b2351fc0d5d37`); OpenCV is not installed
there and builds use `VCPKG_DEFAULT_BINARY_CACHE`. `ci-cpp-opencv` is the
Ubuntu 24.04 compile image with OpenCV 4.14.0 built from the release tarball
and Eigen 3.4 from `libeigen3-dev`. The same image ships vcpkg, the
`x64-linux-libcxx` triplet, and overlay ports that satisfy `opencv4` and
`eigen3` from the image instead of compiling them. It is published on the
next image release; it is not on Docker Hub yet.
Not a product runtime — no `HEALTHCHECK`. graphviz and cloc are not installed.
curl is installed in `ci-cpp-vcpkg` so vcpkg can bootstrap. `ci-cpp-opencv`
bootstraps vcpkg in the build stage and does not keep curl in the final image.

## Image

| Item | Value |
|------|--------|
| Docker Hub | `pirlruc/ci-cpp`, `pirlruc/ci-cpp-ubuntu`, `pirlruc/ci-cpp-vcpkg`. `pirlruc/ci-cpp-opencv` is created on the first publish |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Debian 13 via `dhi.io/python` for `ci-cpp` and `ci-cpp-vcpkg`; Alpine 3.24 for `-alpine`; Ubuntu 24.04 official for `ci-cpp-ubuntu` and `ci-cpp-opencv` |

### Tags

Digests below are the `linux/amd64` manifest. `latest` on each repository
matches the 5.1.2 tag of that repository. Reusable workflow defaults still
pin the 5.0.0 Debian analysis digest until that pin is written forward.

| Image | Tag | Digest |
|-------|-----|--------|
| `pirlruc/ci-cpp` | `5.1.2` / `5.1.2-debian` / `latest` / `latest-debian` | `sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d` |
| `pirlruc/ci-cpp` | `5.1.2-alpine` / `latest-alpine` | `sha256:d530ad4233669428fce12d3ad698e012317cec81ed8a7a07a623fad39c51cc73` |
| `pirlruc/ci-cpp-ubuntu` | `5.1.2` / `latest` | `sha256:cbb32848894dc532c6c7ab00691173ddb68e35619d2e385c17234140938d3704` |
| `pirlruc/ci-cpp-vcpkg` | `5.1.2` / `latest` | `sha256:ecd3578a5c48bc2842910cadbddca78c7b0622308f81221a0b27da19f779204b` |
| `pirlruc/ci-cpp-opencv` | not published | Built from `docker/ci-cpp/Dockerfile.opencv`. First Hub tag arrives with the next image release |
| `pirlruc/ci-cpp` | `5.0.0` | Previous Debian analysis. `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67` |
| `pirlruc/ci-cpp` | `5.0.0-alpine` | Previous Alpine analysis. `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986` |
| `pirlruc/ci-cpp` | `4.0.0` | Previous Ubuntu 24.04 release. `sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f` |
| `pirlruc/ci-cpp` | `sha-<git>` / `sha-<git>-debian` / `sha-<git>-alpine` | Exact git SHA of the published commit |

5.1.2 adds `-debian` and `latest-alpine` on `ci-cpp`. Debian owns the
unsuffixed analysis tags. `ci-cpp-ubuntu`, `ci-cpp-vcpkg`, and `ci-cpp-opencv`
are separate image names. Prefer a digest in production. `latest` is never
the only tag.

```bash
docker pull pirlruc/ci-cpp:5.1.2
docker pull pirlruc/ci-cpp-ubuntu:5.1.2
docker pull pirlruc/ci-cpp-vcpkg:5.1.2
# or
docker pull pirlruc/ci-cpp@sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d
```

## Quick start

```bash
docker run --rm -v "$PWD:/workspace:ro" -w /workspace \
  pirlruc/ci-cpp:5.1.2 \
  clang++ --version
```

Hardened local run (read-only workspace mount):

```bash
docker run --rm \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --tmpfs /tmp:rw,noexec,nosuid,size=256m \
  -v "$PWD:/workspace:ro" -w /workspace \
  pirlruc/ci-cpp:5.1.2 \
  clang++ --version
```

## What is inside

| Tool | Role |
|------|------|
| clang / clang++ / libc++ | Compile. Debian and Ubuntu stay on Clang 18. Alpine is Clang 20 |
| cmake / ninja | Configure and build |
| clang-format 23.1.0 / clang-tidy / cppcheck | Lint (analysis images only) |
| gcovr / llvm-cov | Coverage (analysis images only) |
| lizard / Metrix++ / coverxygen / Doxygen | Complexity and docs (analysis images only) |
| valgrind | Dynamic analysis (analysis images only) |
| vcpkg `434307da` | Dependency install (`ci-cpp-vcpkg` only). `spdlog`, `nlohmann-json`, and `eigen3` install from that baseline (`eigen3` 5.0.1) |
| OpenCV 4.14.0 / Eigen 3.4.0 | `ci-cpp-opencv` only. OpenCV modules: core, imgproc, imgcodecs, built with libc++. Eigen is `libeigen3-dev` |

Not a product runtime — no `HEALTHCHECK`.

## Verify a publish

```bash
docker pull pirlruc/ci-cpp@sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d
docker pull pirlruc/ci-cpp-ubuntu@sha256:cbb32848894dc532c6c7ab00691173ddb68e35619d2e385c17234140938d3704
docker pull pirlruc/ci-cpp-vcpkg@sha256:ecd3578a5c48bc2842910cadbddca78c7b0622308f81221a0b27da19f779204b
```

Signing is skipped while the repo is private on the Free plan (`SC-SIGN-001`).
The registry still stores BuildKit provenance (`mode=max`) and an SBOM.
Publish sets `sign` from repository visibility. The digests above are the
5.1.2 `linux/amd64` manifests.

## Vulnerabilities

Local Trivy (`os,library`, no ignorefile) and Docker Scout, compared with the
previous Ubuntu `ci-cpp` 4.0.0. No HIGH or CRITICAL finding had a fixed version.

| Image | Rootfs | Trivy C/H | Scout |
|-------|--------|-----------|-------|
| 4.0.0 Ubuntu | 1119 MB | 5 / 163, all OS (`linux-libc-dev`) | 1 package, 56 findings |
| 5.0.0 Debian analysis | 1369 MB | 2 / 105, unfixed | 9 packages, 11 highs |
| 5.0.0 Alpine analysis | 1160 MB | 0 / 0 | no vulnerable package |
| 5.0.0 Ubuntu compile | 616 MB | 5 / 163, same kernel headers as 4.0.0 | 1 package, 56 findings |

Alpine does not own the unsuffixed tags. The Ubuntu compile image is not a
like-for-like replacement for the analysis image. Debian CRITICAL findings are
CVE-2026-6653 (`libxml2`) and CVE-2026-43185 (`linux-libc-dev`), both unfixed.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
