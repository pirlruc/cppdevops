# ci-cpp (GitHub Packages)

Short-lived C++ CI toolchain images. Same contents as the Docker Hub page:
`ci-cpp`, `ci-cpp-ubuntu`, `ci-cpp-vcpkg`, and `ci-cpp-opencv`.
Not a product runtime — no `HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| GHCR | `ghcr.io/pirlruc/ci-cpp`, `ghcr.io/pirlruc/ci-cpp-ubuntu`, `ghcr.io/pirlruc/ci-cpp-vcpkg`. `ghcr.io/pirlruc/ci-cpp-opencv` is created on the first publish |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Debian 13 analysis (`ci-cpp`, `ci-cpp-vcpkg`); Alpine 3.24 (`-alpine`); Ubuntu 24.04 compile (`ci-cpp-ubuntu`, `ci-cpp-opencv`) |

### Tags

Same 5.1.2 manifests as [docker-hub.md](docker-hub.md). `ci-cpp` on GHCR is
private, so an anonymous manifest read returns 403; the public Hub platform
manifests match the GHCR manifests confirmed for `ci-cpp-ubuntu` and
`ci-cpp-vcpkg`.

| Image | Tag | Digest |
|-------|-----|--------|
| `ghcr.io/pirlruc/ci-cpp` | `5.1.2` / `5.1.2-debian` / `latest` / `latest-debian` | `sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d` |
| `ghcr.io/pirlruc/ci-cpp` | `5.1.2-alpine` / `latest-alpine` | `sha256:d530ad4233669428fce12d3ad698e012317cec81ed8a7a07a623fad39c51cc73` |
| `ghcr.io/pirlruc/ci-cpp-ubuntu` | `5.1.2` / `latest` | `sha256:cbb32848894dc532c6c7ab00691173ddb68e35619d2e385c17234140938d3704` |
| `ghcr.io/pirlruc/ci-cpp-vcpkg` | `5.1.2` / `latest` | `sha256:ecd3578a5c48bc2842910cadbddca78c7b0622308f81221a0b27da19f779204b` |
| `ghcr.io/pirlruc/ci-cpp-opencv` | not published | First tag arrives with the next image release |
| `ghcr.io/pirlruc/ci-cpp` | `5.0.0` | Previous Debian analysis. Workflow defaults still pin `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67` |
| `ghcr.io/pirlruc/ci-cpp` | `5.0.0-alpine` | Previous Alpine analysis. `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986` |

Debian owns the unsuffixed analysis tags. Prefer a digest in production.

## Authentication

If the package is public, anonymous pulls work:

```bash
docker pull ghcr.io/pirlruc/ci-cpp-ubuntu:5.1.2
```

`ci-cpp` and `ci-cpp-vcpkg` may be private. Authenticate with a PAT that has
`read:packages`:

```bash
echo "$CR_PAT" | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/pirlruc/ci-cpp:5.1.2
docker pull ghcr.io/pirlruc/ci-cpp-vcpkg:5.1.2
# or
docker pull ghcr.io/pirlruc/ci-cpp@sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d
```

## Hardened local run

```bash
docker run --rm \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --tmpfs /tmp:rw,noexec,nosuid,size=256m \
  -v "$PWD:/workspace:ro" -w /workspace \
  ghcr.io/pirlruc/ci-cpp@sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d \
  clang++ --version
```

## Use as a GitHub Actions job container

```yaml
jobs:
  quality:
    runs-on: ubuntu-24.04
    container: ghcr.io/pirlruc/ci-cpp@sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d
```

Digest-pin the container (CI-026). Do not float on `:latest`.

## What is inside

Same toolchain as [docker-hub.md](docker-hub.md). clang-format in the analysis images is 23.1.0.

## Verify a publish

```bash
docker pull ghcr.io/pirlruc/ci-cpp@sha256:4cf9a6f1372e2652d329c4257e6380f5fde846dccf92f45f744f8bfb4b9b417d
```

That digest is 5.1.2 Debian, the same `linux/amd64` manifest Docker Hub
publishes for unsuffixed `ci-cpp`. Workflow defaults still pin the 5.0.0
digest `sha256:3406477b…` until the write-back.

## Vulnerabilities

See [docker-hub.md](docker-hub.md). Signing follows repository visibility
(`SC-SIGN-001` while private). Registry provenance is BuildKit `mode=max`.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
