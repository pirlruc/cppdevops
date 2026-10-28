# ci-cpp-opencv (GitHub Packages)

Ubuntu compile image with OpenCV 4.14.0, Eigen 3.4, and a libc++ vcpkg.
Same contents as [docker-hub-ci-cpp-opencv.md](https://hub.docker.com/r/pirlruc/ci-cpp-opencv).
Not a product runtime — no `HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| GHCR | `ghcr.io/pirlruc/ci-cpp-opencv` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Ubuntu 24.04 |

### Tags

| Tag | Digest |
|-----|--------|
| `6.2.1` / `latest` | `sha256:406fe12b00792678a55b549f082487123bf9fe738200e5b0837a728437a2fb80` (tag index) |
| `6.2.1` `linux/amd64` (Actions) | `sha256:4185b1185f9a453712eca90935a0c253090caf008c2a1f0582547589a3c82b86` |
| `6.0.0` | Previous image. `sha256:79089fae85e7dd80bf5eb58c337fa84b81d6e5a2d6d28a3a1ea61407b1fb1fe2` (tag index) |
| `6.0.0` `linux/amd64` | `sha256:c167f4b2c3cd19d522992f406ceebabf19922e6bbb05cfa6aec77c9d4416ed23` |
| `5.2.0` | Previous image. `sha256:561316dd5a31b8765f3d6569833ad5fff05bdba42d184a92d11cd4c0c738c42b` (tag index) |

Pin the `linux/amd64` image manifest. A tag index pull returns
`manifest unknown`.

## Authentication

If the package is public, anonymous pulls work:

```bash
docker pull ghcr.io/pirlruc/ci-cpp-opencv:6.2.1
```

## License

MIT. Source: https://github.com/pirlruc/cppdevops
