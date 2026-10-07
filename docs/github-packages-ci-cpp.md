# ci-cpp (GitHub Packages)

Short-lived C++ analysis image. Same Debian and Alpine contents as
[docker-hub-ci-cpp.md](docker-hub-ci-cpp.md). Not a product runtime — no
`HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| GHCR | `ghcr.io/pirlruc/ci-cpp` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Debian 13 (unsuffixed); Alpine 3.24 (`-alpine`) |

### Tags

Same 5.2.0 manifests as [docker-hub-ci-cpp.md](docker-hub-ci-cpp.md). This
package is private, so an anonymous manifest read returns 403. Actions pulls
`docker.io/pirlruc/ci-cpp` at the `linux/amd64` image manifest
`sha256:28db91b4a240ec459e90afedf07d9ed5030e3733933c82944127a156bca711d3`,
not the tag index `sha256:94667c57…`.

| Tag | Digest |
|-----|--------|
| `5.2.0` / `5.2.0-debian` / `latest` / `latest-debian` | `sha256:94667c573a1fe4a08aa333cd4083a53553d394c34a8d854d12912831b5536cde` (tag index) |
| `5.2.0-alpine` / `latest-alpine` | `sha256:f7d2f1f22eff2ed9640a4c12c76bfb459d4ecff487dcfa8820bda605850475c1` |
| `5.0.0` | Previous Debian analysis. `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67` |
| `5.0.0-alpine` | Previous Alpine analysis. `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986` |

Debian owns the unsuffixed tags. Prefer a digest in production.

## Authentication

```bash
echo "$CR_PAT" | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/pirlruc/ci-cpp:5.2.0
```

The PAT needs `read:packages`.

## Use as a GitHub Actions job container

```yaml
jobs:
  quality:
    runs-on: ubuntu-24.04
    permissions:
      packages: read
    container:
      image: ghcr.io/pirlruc/ci-cpp@sha256:28db91b4a240ec459e90afedf07d9ed5030e3733933c82944127a156bca711d3
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
      options: --user root
```

Pin the `linux/amd64` image manifest (CI-026). The package is private, so
the job needs `packages: read` and `container.credentials`, the same pull
pydevops uses for `ci-lint`. The calling repository must have Actions read
on the package. `--user root` lets the runner write the workspace. Do not
float on `:latest`.

## What is inside

Same toolchain as [docker-hub-ci-cpp.md](docker-hub-ci-cpp.md). clang-format
is 23.1.0.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
