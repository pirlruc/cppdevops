# ci-cpp-opencv (GitHub Packages)

Ubuntu compile image with OpenCV 4.14.0, Eigen 3.4, and a libc++ vcpkg.
Same contents as [docker-hub-ci-cpp-opencv.md](docker-hub-ci-cpp-opencv.md).
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
| `5.2.0` / `latest` | `sha256:561316dd5a31b8765f3d6569833ad5fff05bdba42d184a92d11cd4c0c738c42b` (tag index) |

Confirm the `linux/amd64` image manifest before an Actions `container:` pin.
A tag index pull returns `manifest unknown`.

## Authentication

If the package is public, anonymous pulls work:

```bash
docker pull ghcr.io/pirlruc/ci-cpp-opencv:5.2.0
```

## License

MIT. Source: https://github.com/pirlruc/cppdevops
