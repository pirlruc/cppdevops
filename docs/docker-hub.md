# ci-cpp

Short-lived C++ CI toolchain images. The unsuffixed `ci-cpp` tag is the Debian 13
analysis image (Clang 18, libc++, CMake, Ninja, cppcheck, clang-tidy/format,
Doxygen, gcovr, lizard, Metrix++, coverxygen, valgrind). `ci-cpp` `-alpine` is
the Alpine 3.24 analysis image (Clang 20, because Alpine libc++ is LLVM 22).
`ci-cpp-ubuntu` is compile-only: Clang 18, libc++, CMake, Ninja, and git.
Not a product runtime — no `HEALTHCHECK`. graphviz, cloc, and curl are not installed.

## Image

| Item | Value |
|------|--------|
| Docker Hub | `pirlruc/ci-cpp` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Debian 13 via `dhi.io/python` for `ci-cpp`; Alpine 3.24 for `-alpine`; Ubuntu 24.04 official for `ci-cpp-ubuntu` |

### Tags

| Tag | Meaning |
|-----|---------|
| `5.0.0` | Debian 13 analysis (unsuffixed). Digest `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67` |
| `5.0.0-alpine` | Alpine 3.24 analysis. Digest `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986` |
| `ci-cpp-ubuntu:5.0.0` | Compile-only Ubuntu 24.04 image on GHCR, not Docker Hub. Digest `sha256:0a6f9b7f044e9e1a2098ff7f57425d16245daaeff505b07dca90199933a3011f` |
| `4.0.0` | Previous Ubuntu 24.04 release. Digest `sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f` |
| `3.1.0` | Previous immutable Ubuntu 24.04 release |
| `3.0.0` | Previous immutable release |
| `latest` | Latest non-prerelease Debian publish. 5.0.0 has no `latest-alpine` |
| `sha-<git>` / `sha-<git>-alpine` | Exact git SHA of the published commit |

5.0.0 Debian was published with an empty suffix, so there is no `5.0.0-debian`
tag. The next image publish adds `-debian` and `latest-alpine`, matching
`ci-lint`. `ci-cpp-ubuntu` is a separate image name. Prefer a digest in
production. `latest` is never the only tag.

```bash
docker pull pirlruc/ci-cpp:5.0.0
# or
docker pull pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67
```

## Quick start

```bash
docker run --rm -v "$PWD:/workspace:ro" -w /workspace \
  pirlruc/ci-cpp:5.0.0 \
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
  pirlruc/ci-cpp:5.0.0 \
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

Not a product runtime — no `HEALTHCHECK`.

## Verify a publish

```bash
docker pull pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67
```

Signing is skipped while the repo is private on the Free plan (`SC-SIGN-001`).
The registry still stores BuildKit provenance (`mode=max`) and an SBOM.
Publish sets `sign` from repository visibility. Pull by digest:

```bash
docker pull pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67
```

That digest is the published 5.0.0 Debian analysis image.

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
