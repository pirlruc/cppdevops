# ci-cpp-vcpkg (GitHub Packages)

Debian analysis image plus pinned vcpkg. Same contents as
[docker-hub-ci-cpp-vcpkg.md](docker-hub-ci-cpp-vcpkg.md). Not a product
runtime — no `HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| GHCR | `ghcr.io/pirlruc/ci-cpp-vcpkg` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | `ci-cpp` Debian 5.0.0 plus vcpkg `434307da` |

### Tags

| Tag | Digest |
|-----|--------|
| `5.2.0` / `latest` | `sha256:76b9587f04834322dadd318e3ce5d17349e68df990a9575647f7dc6fb7553cde` (tag index) |

The package may be private. Confirm the `linux/amd64` image manifest before
an Actions `container:` pin. A tag index pull returns `manifest unknown`.

## Authentication

```bash
echo "$CR_PAT" | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/pirlruc/ci-cpp-vcpkg:5.2.0
```

The PAT needs `read:packages`. Public Hub pulls do not.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
