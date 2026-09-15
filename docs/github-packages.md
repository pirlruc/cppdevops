# ci-cpp (GitHub Packages)

Short-lived C++ CI toolchain image. Same contents as the Docker Hub page.
Not a product runtime — no `HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| GHCR | `ghcr.io/pirlruc/ci-cpp` |
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

Prefer a digest in production.

## Authentication

If the package is public, anonymous pulls work:

```bash
docker pull ghcr.io/pirlruc/ci-cpp:3.1.0
```

If the package is private, authenticate with a PAT that has `read:packages`:

```bash
echo "$CR_PAT" | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/pirlruc/ci-cpp:3.1.0
# or
docker pull ghcr.io/pirlruc/ci-cpp@sha256:<digest>
```

## Use as a GitHub Actions job container

```yaml
jobs:
  quality:
    runs-on: ubuntu-24.04
    container: ghcr.io/pirlruc/ci-cpp@sha256:<digest>
```

Digest-pin the container (CI-026). Do not float on `:latest`.
