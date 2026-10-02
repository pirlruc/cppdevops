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
| `5.0.0` / `5.0.0-debian` | Debian 13 analysis. Digest `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67` |
| `5.0.0-alpine` | Alpine 3.24 analysis. Digest `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986` |
| `4.0.0` | Previous Ubuntu 24.04 release. Digest `sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f` |
| `3.1.0` | Previous immutable Ubuntu 24.04 release |
| `3.0.0` | Previous immutable release |
| `latest` | Latest non-prerelease publish |
| `sha-<git>` | Exact git SHA of the published commit |

Prefer a digest (or a version tag) in production. `latest` is never the only tag.

```bash
docker pull pirlruc/ci-cpp:5.0.0
# or
docker pull pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67
```

## Quick start

```bash
docker run --rm -v "$PWD:/workspace:ro" -w /workspace \
  pirlruc/ci-cpp:4.0.0 \
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
  pirlruc/ci-cpp:4.0.0 \
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
docker pull pirlruc/ci-cpp@sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f
```

Signing is skipped while the repo is private on the Free plan (`SC-SIGN-001`).
The registry still stores BuildKit provenance (`mode=max`) and an SBOM.
Publish sets `sign` from repository visibility. Pull by digest:

```bash
docker pull pirlruc/ci-cpp@sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f
```

That digest is the published 4.0.0 Ubuntu image. 5.0.0 replaces it after release.

## Vulnerabilities

The blocking image scan covers language packages plus `docker/ci-cpp/.trivyignore.yaml`.
An advisory posture scan covers `os,library` with no ignorefile. A local Trivy
scan of this image (os and library, no ignorefile) found 5 CRITICAL and 163
HIGH, all in `linux-libc-dev`. The fixable highs named for 3.1.0 are gone
(CVE-2025-10263, CVE-2026-53186, CVE-2026-64091, CVE-2026-57585,
GHSA-6v7p-g79w-8964, CVE-2025-47273). CVE-2026-64564 remains, with the other
unfixed kernel-header findings. The compiler image needs that package
(CPPD-SCAN-001). The Ubuntu config Created date is still 2026-09-11, so the
30-day age gate fails on 2026-10-11.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
