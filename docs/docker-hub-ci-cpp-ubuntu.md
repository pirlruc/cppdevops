# ci-cpp-ubuntu

Compile-only C++ image: Clang 18, libc++, CMake, Ninja, and git on Ubuntu
24.04. Analysis tools stay on [ci-cpp](docker-hub-ci-cpp.md). Not a product
runtime — no `HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| Docker Hub | `pirlruc/ci-cpp-ubuntu` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Ubuntu 24.04 official |
| Context | `docker/ci-cpp-ubuntu/` |

### Tags

The `6.0.0` row is the tag's manifest list. Actions `container:` needs the
`linux/amd64` image manifest. This package is public on GHCR as well.

| Tag | Digest |
|-----|--------|
| `6.0.0` / `latest` | `sha256:05b8d4a8df645fcdf6ce14e9aefbaf0f213666483d5a12d705b098854d661a1e` (tag index) |
| `6.0.0` `linux/amd64` | `sha256:6334cc671263521da28f2fd032824de84c86e4242e6166fca35174dbd04ed66a` |
| `5.2.0` | Previous compile image. `sha256:cf2464213f9460585846b3fd8e5beb8d77fa8c2774f5f03b0a5e852e4e9de77e` (tag index) |
| `sha-<git>` | Exact git SHA of the published commit |

Prefer a digest in production. `latest` is never the only tag.

```bash
docker pull pirlruc/ci-cpp-ubuntu:6.0.0
docker pull pirlruc/ci-cpp-ubuntu@sha256:6334cc671263521da28f2fd032824de84c86e4242e6166fca35174dbd04ed66a
```

## Quick start

```bash
docker run --rm -v "$PWD:/workspace:ro" -w /workspace \
  pirlruc/ci-cpp-ubuntu:6.0.0 \
  clang++ --version
```

## What is inside

| Tool | Role |
|------|------|
| clang / clang++ / libc++ | Compile on Clang 18 |
| cmake / ninja | Configure and build |
| git | Fetch sources |

Not included: clang-tidy, cppcheck, Doxygen, valgrind, vcpkg, OpenCV.

## Vulnerabilities

The Ubuntu compile image is not a like-for-like replacement for the analysis
image. On 5.0.0 the rootfs was 616 MB, with the same unfixed `linux-libc-dev`
highs as the previous Ubuntu analysis image (Trivy 5 CRITICAL / 163 HIGH).

The `ubuntu:24.04` digest
`sha256:68ee22004a9109b44973313b02ff7b1de250f1de0f5ecb628d73f579aaff33ac`
is still the current noble index. Its `linux/amd64` manifest was created
2026-09-30. `base_image_max_age_days` (30) falls on 2026-10-30. There is no
newer 24.04 index to pin, and the image stays on 24.04 (`CPPD-SCAN-001`).

## License

MIT. Source: https://github.com/pirlruc/cppdevops
