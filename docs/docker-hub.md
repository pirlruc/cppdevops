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
`eigen3` from the image instead of compiling them. Tag `5.2.0` is on Docker Hub
and GHCR.
Not a product runtime — no `HEALTHCHECK`. graphviz and cloc are not installed.
curl is installed in `ci-cpp-vcpkg` so vcpkg can bootstrap. `ci-cpp-opencv`
bootstraps vcpkg in the build stage and does not keep curl in the final image.

The 5.2.0 publish pushed the images. The Hub Overview step is advisory: the
token can push but cannot write repository descriptions, so that step returned
Forbidden and did not fill the Overview for `ci-cpp-ubuntu`, `ci-cpp-vcpkg`, or
`ci-cpp-opencv`. This page is the description for every image name.

## Image

| Item | Value |
|------|--------|
| Docker Hub | `pirlruc/ci-cpp`, `pirlruc/ci-cpp-ubuntu`, `pirlruc/ci-cpp-vcpkg`. `pirlruc/ci-cpp-opencv` is created on the first publish |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Debian 13 via `dhi.io/python` for `ci-cpp` and `ci-cpp-vcpkg`; Alpine 3.24 for `-alpine`; Ubuntu 24.04 official for `ci-cpp-ubuntu` and `ci-cpp-opencv` |

### Tags

Digests below are the tag's manifest list. `latest` matches 5.2.0. Actions
`container:` cannot pull that index, and `ghcr.io/pirlruc/ci-cpp` is private.
Workflow defaults pin
`docker.io/pirlruc/ci-cpp@sha256:28db91b4a240ec459e90afedf07d9ed5030e3733933c82944127a156bca711d3`.

| Image | Tag | Digest |
|-------|-----|--------|
| `pirlruc/ci-cpp` | `5.2.0` / `5.2.0-debian` / `latest` / `latest-debian` | `sha256:94667c573a1fe4a08aa333cd4083a53553d394c34a8d854d12912831b5536cde` |
| `pirlruc/ci-cpp` | `5.2.0-alpine` / `latest-alpine` | `sha256:f7d2f1f22eff2ed9640a4c12c76bfb459d4ecff487dcfa8820bda605850475c1` |
| `pirlruc/ci-cpp-ubuntu` | `5.2.0` / `latest` | `sha256:cf2464213f9460585846b3fd8e5beb8d77fa8c2774f5f03b0a5e852e4e9de77e` |
| `pirlruc/ci-cpp-vcpkg` | `5.2.0` / `latest` | `sha256:76b9587f04834322dadd318e3ce5d17349e68df990a9575647f7dc6fb7553cde` |
| `pirlruc/ci-cpp-opencv` | `5.2.0` / `latest` | `sha256:561316dd5a31b8765f3d6569833ad5fff05bdba42d184a92d11cd4c0c738c42b` |
| `pirlruc/ci-cpp` | `5.1.2` / `5.1.2-debian` | `sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d` |
| `pirlruc/ci-cpp` | `5.0.0` | Previous Debian analysis. `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67` |
| `pirlruc/ci-cpp` | `5.0.0-alpine` | Previous Alpine analysis. `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986` |
| `pirlruc/ci-cpp` | `4.0.0` | Previous Ubuntu 24.04 release. `sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f` |
| `pirlruc/ci-cpp` | `sha-<git>` / `sha-<git>-debian` / `sha-<git>-alpine` | Exact git SHA of the published commit |

5.1.2 adds `-debian` and `latest-alpine` on `ci-cpp`. Debian owns the
unsuffixed analysis tags. `ci-cpp-ubuntu`, `ci-cpp-vcpkg`, and `ci-cpp-opencv`
are separate image names. Prefer a digest in production. `latest` is never
the only tag.

```bash
docker pull pirlruc/ci-cpp:5.2.0
docker pull pirlruc/ci-cpp-ubuntu:5.2.0
docker pull pirlruc/ci-cpp-vcpkg:5.2.0
docker pull pirlruc/ci-cpp-opencv:5.2.0
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
