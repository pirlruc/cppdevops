# ci-cpp

Short-lived C++ CI toolchain image for GitHub Actions jobs that compile, test,
and lint C++ libraries: Clang/libc++, CMake, Ninja, cppcheck, clang-tidy/format,
Doxygen, gcovr, lizard, Metrix++, coverxygen, valgrind. Not a product runtime —
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
| `3.1.0` | Immutable Ubuntu 24.04 release (this wave) |
| `3.0.0` | Previous immutable release |
| `latest` | Latest non-prerelease publish |
| `sha-<git>` | Exact git SHA of the published commit |

Prefer a digest (or a version tag) in production. `latest` is never the only tag.

```bash
docker pull pirlruc/ci-cpp:3.1.0
# or
docker pull pirlruc/ci-cpp@sha256:f42b11bc342c0dd6faef6454f4a37cf4230b9c2c87357623cad5ed0102608656
```

## Quick start

```bash
docker run --rm -v "$PWD:/workspace:ro" -w /workspace \
  pirlruc/ci-cpp:3.1.0 \
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
  pirlruc/ci-cpp:3.1.0 \
  clang++ --version
```

## What is inside

| Tool | Role |
|------|------|
| clang / clang++ / libc++ | Compile (CPP-BUILD-004 / 009) |
| cmake / ninja | Configure and build |
| clang-format / clang-tidy / cppcheck | Lint |
| gcovr / llvm-cov | Coverage |
| lizard / Metrix++ / coverxygen / Doxygen | Complexity and docs |
| valgrind | Dynamic analysis |

Not a product runtime — no `HEALTHCHECK`.

## Verify a publish

```bash
docker pull pirlruc/ci-cpp@sha256:f42b11bc342c0dd6faef6454f4a37cf4230b9c2c87357623cad5ed0102608656
```

Signing is skipped on this private Free-plan repo (`SC-SIGN-001` / `SC-PROV-001`).
