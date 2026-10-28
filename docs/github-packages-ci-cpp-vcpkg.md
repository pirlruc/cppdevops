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
| Base | `ci-cpp` Debian `sha256:6b71cd22…` plus vcpkg `434307da` |

### Tags

| Tag | Digest |
|-----|--------|
| `6.3.0` / `latest` | `sha256:7df56682882f2472cd0dd13d9d9148ea7a3f0cdd5140f12014abd4be0ba5cda4` (tag index) |
| `6.3.0` `linux/amd64` (Actions) | `sha256:e551e5f6f6ec5b65bd571fb13c549916fc0ac4e6156c2185f0a8eb5be2a2fe44` |
| `6.2.1` | Previous image. `sha256:81c6b20f05865a90b0ac665b595aad00e7a7f415e2a1845a82e183d3092deef6` (tag index) |
| `6.2.1` `linux/amd64` | `sha256:1fa50525672e1b308fe8adbc7113b59d0a3ebad0946bdefd906a8aa69845d016` |
| `6.0.0` | Previous image. `sha256:b92e65c8144e14922bdc37728fa53fa2d0251dc2fa887b38f03cbc312fced337` (tag index) |
| `6.0.0` `linux/amd64` | `sha256:b8da2259addfb1efcfc60dec396ad2e496a6f5be500016a8341ddc129a37c583` |
| `5.2.0` | Previous image. `sha256:76b9587f04834322dadd318e3ce5d17349e68df990a9575647f7dc6fb7553cde` (tag index) |

The package may be private. Pin the `linux/amd64` image manifest. A tag
index pull returns `manifest unknown`.

## Authentication

```bash
echo "$CR_PAT" | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/pirlruc/ci-cpp-vcpkg:6.3.0
```

The PAT needs `read:packages`. Public Hub pulls do not.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
