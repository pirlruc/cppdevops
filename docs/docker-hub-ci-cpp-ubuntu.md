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

The `5.2.0` row is the tag's manifest list. Actions `container:` needs the
`linux/amd64` image manifest. This package is public on GHCR as well.

| Tag | Digest |
|-----|--------|
| `5.2.0` / `latest` | `sha256:cf2464213f9460585846b3fd8e5beb8d77fa8c2774f5f03b0a5e852e4e9de77e` (tag index) |
| `5.2.0` `linux/amd64` | `sha256:08580497f49d79012a03023377216a3ef2e274a7b7616d4f2a155d2d6551ed68` |
| `sha-<git>` | Exact git SHA of the published commit |

Prefer a digest in production. `latest` is never the only tag.

```bash
docker pull pirlruc/ci-cpp-ubuntu:5.2.0
docker pull pirlruc/ci-cpp-ubuntu@sha256:08580497f49d79012a03023377216a3ef2e274a7b7616d4f2a155d2d6551ed68
```

## Quick start

```bash
docker run --rm -v "$PWD:/workspace:ro" -w /workspace \
  pirlruc/ci-cpp-ubuntu:5.2.0 \
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
`sha256:534baea6a22c03a63003dbc8dbe78fe34bc0d7e595d9a9dc9834884ff530eb55`
was created 2026-09-17. `base_image_max_age_days` (30) fails on 2026-10-18
until Canonical publishes a newer noble image (`CPPD-SCAN-001`).

## License

MIT. Source: https://github.com/pirlruc/cppdevops
