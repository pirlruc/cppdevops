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
| `4.0.0` | Ubuntu 24.04 release with clang-format 23. Digest is written in 4.0.1 after publish |
| `3.1.0` | Previous immutable Ubuntu 24.04 release |
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
docker pull ghcr.io/pirlruc/ci-cpp@sha256:f42b11bc342c0dd6faef6454f4a37cf4230b9c2c87357623cad5ed0102608656
```

## Use as a GitHub Actions job container

```yaml
jobs:
  quality:
    runs-on: ubuntu-24.04
    container: ghcr.io/pirlruc/ci-cpp@sha256:f42b11bc342c0dd6faef6454f4a37cf4230b9c2c87357623cad5ed0102608656
```

Digest-pin the container (CI-026). Do not float on `:latest`.

## What is inside

Same toolchain as [docker-hub.md](docker-hub.md). clang-format in 4.0.0 is 23.1.0.

## Verify a publish

```bash
docker pull ghcr.io/pirlruc/ci-cpp@sha256:f42b11bc342c0dd6faef6454f4a37cf4230b9c2c87357623cad5ed0102608656
```

That digest is 3.1.0. The 4.0.0 digest replaces it on this page in 4.0.1.

## Vulnerabilities

See [docker-hub.md](docker-hub.md). Signing follows repository visibility
(`SC-SIGN-001` / `SC-PROV-001` while private).

## License

MIT. Source: https://github.com/pirlruc/cppdevops
