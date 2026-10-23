# ci-cpp-vcpkg (GitHub Packages)

Debian analysis image plus pinned vcpkg. Same contents as
[docker-hub-ci-cpp-vcpkg.md](https://hub.docker.com/r/pirlruc/ci-cpp-vcpkg). Not a product
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
| `6.0.0` / `latest` | `sha256:b92e65c8144e14922bdc37728fa53fa2d0251dc2fa887b38f03cbc312fced337` (tag index) |
| `6.0.0` `linux/amd64` | `sha256:b8da2259addfb1efcfc60dec396ad2e496a6f5be500016a8341ddc129a37c583` |
| `5.2.0` | Previous image. `sha256:76b9587f04834322dadd318e3ce5d17349e68df990a9575647f7dc6fb7553cde` (tag index) |

The package may be private. Pin the `linux/amd64` image manifest. A tag
index pull returns `manifest unknown`.

## Authentication

```bash
echo "$CR_PAT" | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/pirlruc/ci-cpp-vcpkg:6.0.0
```

The PAT needs `read:packages`. Public Hub pulls do not.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
