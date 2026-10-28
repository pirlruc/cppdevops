# ci-cpp-ubuntu (GitHub Packages)

Compile-only Ubuntu 24.04 image. Same contents as
[docker-hub-ci-cpp-ubuntu.md](https://hub.docker.com/r/pirlruc/ci-cpp-ubuntu). Not a product
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
| `6.2.1` / `latest` | `sha256:6c665e574be2fc82223e3c71f201131188c091b15e4238a15e60a1b1a8adaa23` (tag index) |
| `6.2.1` `linux/amd64` (Actions) | `sha256:5daf9d6151cf791cdc277a9a3b17949471baf9003a755db87b5efec8112fd91a` |
| `6.0.0` | Previous compile image. `sha256:05b8d4a8df645fcdf6ce14e9aefbaf0f213666483d5a12d705b098854d661a1e` (tag index) |
| `6.0.0` `linux/amd64` | `sha256:6334cc671263521da28f2fd032824de84c86e4242e6166fca35174dbd04ed66a` |
| `5.2.0` | Previous compile image. `sha256:cf2464213f9460585846b3fd8e5beb8d77fa8c2774f5f03b0a5e852e4e9de77e` (tag index) |

## Authentication

Anonymous pulls work:

```bash
docker pull ghcr.io/pirlruc/ci-cpp-ubuntu@sha256:5daf9d6151cf791cdc277a9a3b17949471baf9003a755db87b5efec8112fd91a
```

## Use as a GitHub Actions job container

```yaml
jobs:
  ubuntu-compile:
    runs-on: ubuntu-24.04
    container:
      image: ghcr.io/pirlruc/ci-cpp-ubuntu@sha256:5daf9d6151cf791cdc277a9a3b17949471baf9003a755db87b5efec8112fd91a
      options: --user root
```

## License

MIT. Source: https://github.com/pirlruc/cppdevops
