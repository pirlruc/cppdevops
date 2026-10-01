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
| `4.0.0` | Ubuntu 24.04 release with clang-format 23. Digest `sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f` |
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
docker pull ghcr.io/pirlruc/ci-cpp@sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f
```

## Use as a GitHub Actions job container

```yaml
jobs:
  quality:
    runs-on: ubuntu-24.04
    container: ghcr.io/pirlruc/ci-cpp@sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f
```

Digest-pin the container (CI-026). Do not float on `:latest`.

## What is inside

Same toolchain as [docker-hub.md](docker-hub.md). clang-format in 4.0.0 is 23.1.0.

## Verify a publish

```bash
docker pull ghcr.io/pirlruc/ci-cpp@sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f
```

That digest is 4.0.0, the same manifest Docker Hub publishes.

## Vulnerabilities

See [docker-hub.md](docker-hub.md). Signing follows repository visibility
(`SC-SIGN-001` / `SC-PROV-001` while private).

## License

MIT. Source: https://github.com/pirlruc/cppdevops
