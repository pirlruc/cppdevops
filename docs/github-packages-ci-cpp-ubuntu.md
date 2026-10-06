# ci-cpp-ubuntu (GitHub Packages)

Compile-only Ubuntu 24.04 image. Same contents as
[docker-hub-ci-cpp-ubuntu.md](docker-hub-ci-cpp-ubuntu.md). Not a product
runtime — no `HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| GHCR | `ghcr.io/pirlruc/ci-cpp-ubuntu` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Ubuntu 24.04 |

### Tags

This package is public. The tag index and the `linux/amd64` image manifest
differ. Jobs that compile on Ubuntu pin the image manifest.

| Tag | Digest |
|-----|--------|
| `5.2.0` / `latest` | `sha256:cf2464213f9460585846b3fd8e5beb8d77fa8c2774f5f03b0a5e852e4e9de77e` (tag index) |
| `5.2.0` `linux/amd64` | `sha256:08580497f49d79012a03023377216a3ef2e274a7b7616d4f2a155d2d6551ed68` |

## Authentication

Anonymous pulls work:

```bash
docker pull ghcr.io/pirlruc/ci-cpp-ubuntu@sha256:08580497f49d79012a03023377216a3ef2e274a7b7616d4f2a155d2d6551ed68
```

## Use as a GitHub Actions job container

```yaml
jobs:
  ubuntu-compile:
    runs-on: ubuntu-24.04
    container:
      image: ghcr.io/pirlruc/ci-cpp-ubuntu@sha256:08580497f49d79012a03023377216a3ef2e274a7b7616d4f2a155d2d6551ed68
      options: --user root
```

## License

MIT. Source: https://github.com/pirlruc/cppdevops
