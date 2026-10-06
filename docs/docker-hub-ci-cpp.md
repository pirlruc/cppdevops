# ci-cpp

Short-lived C++ analysis image. Debian 13 owns the unsuffixed tags (Clang 18,
libc++, CMake, Ninja, cppcheck, clang-tidy/format, Doxygen, gcovr, lizard,
Metrix++, coverxygen, valgrind). Alpine 3.24 is the `-alpine` variant (Clang 20,
because Alpine libc++ is LLVM 22). Not a product runtime — no `HEALTHCHECK`.
graphviz and cloc are not installed.

Compile-only and dependency images are separate names:
[ci-cpp-ubuntu](docker-hub-ci-cpp-ubuntu.md),
[ci-cpp-vcpkg](docker-hub-ci-cpp-vcpkg.md),
[ci-cpp-opencv](docker-hub-ci-cpp-opencv.md).

## Image

| Item | Value |
|------|--------|
| Docker Hub | `pirlruc/ci-cpp` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Debian 13 via `dhi.io/python` (unsuffixed); Alpine 3.24 (`-alpine`) |
| Context | `docker/ci-cpp/` |

### Tags

`5.2.0` digests below are the tag's manifest list, except the Actions row,
which is the `linux/amd64` image manifest. Actions `container:` cannot pull
the tag index, and `ghcr.io/pirlruc/ci-cpp` is private. Workflow defaults pin
the public Hub image manifest.

| Tag | Digest |
|-----|--------|
| `5.2.0` / `5.2.0-debian` / `latest` / `latest-debian` | `sha256:94667c573a1fe4a08aa333cd4083a53553d394c34a8d854d12912831b5536cde` (tag index) |
| `5.2.0` `linux/amd64` (Actions) | `sha256:28db91b4a240ec459e90afedf07d9ed5030e3733933c82944127a156bca711d3` |
| `5.2.0-alpine` / `latest-alpine` | `sha256:f7d2f1f22eff2ed9640a4c12c76bfb459d4ecff487dcfa8820bda605850475c1` |
| `5.1.2` / `5.1.2-debian` | `sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d` |
| `5.0.0` | Previous Debian analysis. `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67` |
| `5.0.0-alpine` | Previous Alpine analysis. `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986` |
| `4.0.0` | Previous Ubuntu 24.04 release. `sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f` |
| `sha-<git>` / `sha-<git>-debian` / `sha-<git>-alpine` | Exact git SHA of the published commit |

5.1.2 adds `-debian` and `latest-alpine`. Debian owns the unsuffixed tags.
Prefer a digest in production. `latest` is never the only tag.

```bash
docker pull pirlruc/ci-cpp:5.2.0
docker pull pirlruc/ci-cpp:5.2.0-alpine
docker pull pirlruc/ci-cpp@sha256:28db91b4a240ec459e90afedf07d9ed5030e3733933c82944127a156bca711d3
```

## Quick start

```bash
docker run --rm -v "$PWD:/workspace:ro" -w /workspace \
  pirlruc/ci-cpp:5.2.0 \
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
  pirlruc/ci-cpp:5.2.0 \
  clang++ --version
```

## What is inside

| Tool | Role |
|------|------|
| clang / clang++ / libc++ | Compile. Debian stays on Clang 18. Alpine is Clang 20 |
| cmake / ninja | Configure and build |
| clang-format 23.1.0 / clang-tidy / cppcheck | Lint |
| gcovr / llvm-cov | Coverage |
| lizard / Metrix++ / coverxygen / Doxygen | Complexity and docs |
| valgrind | Dynamic analysis |

Not included: vcpkg, OpenCV, Eigen. Those live on `ci-cpp-vcpkg` and
`ci-cpp-opencv`.

## Verify a publish

```bash
docker pull pirlruc/ci-cpp@sha256:28db91b4a240ec459e90afedf07d9ed5030e3733933c82944127a156bca711d3
```

Signing is skipped while the repo is private on the Free plan (`SC-SIGN-001`).
The registry still stores BuildKit provenance (`mode=max`) and an SBOM.

## Vulnerabilities

Local Trivy (`os,library`, no ignorefile) and Docker Scout, compared with the
previous Ubuntu `ci-cpp` 4.0.0. No HIGH or CRITICAL finding had a fixed version.

| Image | Rootfs | Trivy C/H | Scout |
|-------|--------|-----------|-------|
| 5.0.0 Debian analysis | 1369 MB | 2 / 105, unfixed | 9 packages, 11 highs |
| 5.0.0 Alpine analysis | 1160 MB | 0 / 0 | no vulnerable package |

Debian CRITICAL findings are CVE-2026-6653 (`libxml2`) and CVE-2026-43185
(`linux-libc-dev`), both unfixed. Alpine does not own the unsuffixed tags.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
