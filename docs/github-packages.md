# ci-cpp (GitHub Packages)

Short-lived C++ CI toolchain image. Same contents as the Docker Hub page.
Not a product runtime — no `HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| GHCR | `ghcr.io/pirlruc/ci-cpp` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Debian 13 analysis (`ci-cpp`), Alpine 3.24 (`-alpine`), Ubuntu 24.04 compile (`ghcr.io/pirlruc/ci-cpp-ubuntu`) |

### Tags

| Tag | Meaning |
|-----|---------|
| `5.0.0` | Debian 13 analysis (unsuffixed). Digest `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67` |
| `5.0.0-alpine` | Alpine 3.24 analysis. Digest `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986` |
| `ci-cpp-ubuntu:5.0.0` | Compile-only Ubuntu 24.04. Digest `sha256:0a6f9b7f044e9e1a2098ff7f57425d16245daaeff505b07dca90199933a3011f` |
| `4.0.0` | Previous Ubuntu 24.04 release. Digest `sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f` |
| `3.1.0` | Previous immutable Ubuntu 24.04 release |
| `3.0.0` | Previous immutable release |
| `latest` | Latest non-prerelease Debian publish. 5.0.0 has no `latest-alpine` |
| `sha-<git>` / `sha-<git>-alpine` | Exact git SHA of the published commit |

5.0.0 has no `-debian` tag. The next publish adds it, plus `latest-alpine`.
Prefer a digest in production.

## Authentication

If the package is public, anonymous pulls work:

```bash
docker pull ghcr.io/pirlruc/ci-cpp:5.0.0
```

If the package is private, authenticate with a PAT that has `read:packages`:

```bash
echo "$CR_PAT" | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/pirlruc/ci-cpp:5.0.0
# or
docker pull ghcr.io/pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67
```

## Hardened local run

```bash
docker run --rm \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --tmpfs /tmp:rw,noexec,nosuid,size=256m \
  -v "$PWD:/workspace:ro" -w /workspace \
  ghcr.io/pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67 \
  clang++ --version
```

## Use as a GitHub Actions job container

```yaml
jobs:
  quality:
    runs-on: ubuntu-24.04
    container: ghcr.io/pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67
```

Digest-pin the container (CI-026). Do not float on `:latest`.

## What is inside

Same toolchain as [docker-hub.md](docker-hub.md). clang-format in the analysis images is 23.1.0.

## Verify a publish

```bash
docker pull ghcr.io/pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67
```

That digest is 5.0.0 Debian, the same manifest Docker Hub publishes for unsuffixed `ci-cpp`.

## Vulnerabilities

See [docker-hub.md](docker-hub.md). Signing follows repository visibility
(`SC-SIGN-001` while private). Registry provenance is BuildKit `mode=max`.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
