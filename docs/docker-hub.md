# ci-cpp

Short-lived C++ CI toolchain image for GitHub Actions jobs that compile, test,
and lint C++ libraries: Clang/libc++, CMake, Ninja, cppcheck, clang-tidy/format,
Doxygen, gcovr, lizard, Metrix++, coverxygen, cloc, valgrind. Not a product runtime —
no `HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| Docker Hub | `pirlruc/ci-cpp` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Ubuntu 24.04 (digest-pinned at publish) |

### Tags

| Tag | Meaning |
|-----|---------|
| `4.0.0` | Ubuntu 24.04 release with clang-format 23. Digest `sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f` |
| `3.1.0` | Previous immutable Ubuntu 24.04 release |
| `3.0.0` | Previous immutable release |
| `latest` | Latest non-prerelease publish |
| `sha-<git>` | Exact git SHA of the published commit |

Prefer a digest (or a version tag) in production. `latest` is never the only tag.

```bash
docker pull pirlruc/ci-cpp:4.0.0
# or
docker pull pirlruc/ci-cpp@sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f
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
| clang / clang++ / libc++ | Compile (CPP-BUILD-004 / 009) |
| cmake / ninja | Configure and build |
| clang-format 23.1.0 / clang-tidy / cppcheck | Lint |
| gcovr / llvm-cov | Coverage |
| lizard / Metrix++ / coverxygen / Doxygen | Complexity and docs |
| cloc | Line counts for quality gates |
| valgrind | Dynamic analysis |

Not a product runtime — no `HEALTHCHECK`.

## Verify a publish

```bash
docker pull pirlruc/ci-cpp@sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f
```

Signing is skipped while the repo is private on the Free plan (`SC-SIGN-001` /
`SC-PROV-001`). Publish sets `sign` from repository visibility.

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
