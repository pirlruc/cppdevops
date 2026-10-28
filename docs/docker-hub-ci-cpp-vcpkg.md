# ci-cpp-vcpkg

The Debian analysis image plus a pinned vcpkg
(`434307da09bc05b2c86996dccc8b2351fc0d5d37`). OpenCV is not installed.
Builds use `VCPKG_DEFAULT_BINARY_CACHE`. The image sets
`VCPKG_DEFAULT_TRIPLET=x64-linux-libcxx` so ports link libc++, the same
standard library the libraries compile with. Not a product runtime — no
`HEALTHCHECK`.

Analysis tools are documented on [ci-cpp](https://hub.docker.com/r/pirlruc/ci-cpp). OpenCV and
Eigen from the image are [ci-cpp-opencv](https://hub.docker.com/r/pirlruc/ci-cpp-opencv).

## Image

| Item | Value |
|------|--------|
| Docker Hub | `pirlruc/ci-cpp-vcpkg` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | `ci-cpp` Debian `sha256:6b71cd22…` plus vcpkg |
| Context | `docker/ci-cpp-vcpkg/` |

### Tags

| Tag | Digest |
|-----|--------|
| `6.2.1` / `latest` | `sha256:81c6b20f05865a90b0ac665b595aad00e7a7f415e2a1845a82e183d3092deef6` (tag index) |
| `6.2.1` `linux/amd64` (Actions) | `sha256:1fa50525672e1b308fe8adbc7113b59d0a3ebad0946bdefd906a8aa69845d016` |
| `6.0.0` | Previous image. `sha256:b92e65c8144e14922bdc37728fa53fa2d0251dc2fa887b38f03cbc312fced337` (tag index) |
| `6.0.0` `linux/amd64` | `sha256:b8da2259addfb1efcfc60dec396ad2e496a6f5be500016a8341ddc129a37c583` |
| `5.2.0` | Previous image. `sha256:76b9587f04834322dadd318e3ce5d17349e68df990a9575647f7dc6fb7553cde` (tag index) |
| `sha-<git>` | Exact git SHA of the published commit |

Prefer a digest in production. Pin the `linux/amd64` image manifest. A tag
index is not a pullable Actions `container:`.

```bash
docker pull pirlruc/ci-cpp-vcpkg:6.2.1
docker pull pirlruc/ci-cpp-vcpkg@sha256:1fa50525672e1b308fe8adbc7113b59d0a3ebad0946bdefd906a8aa69845d016
```

## Quick start

```bash
docker run --rm pirlruc/ci-cpp-vcpkg:6.2.1 vcpkg version
```

## What is inside

Everything in Debian `ci-cpp`, plus:

| Tool | Role |
|------|------|
| vcpkg `434307da` | Dependency install. `spdlog`, `nlohmann-json`, and `eigen3` install from that baseline (`eigen3` 5.0.1) |
| `x64-linux-libcxx` | Triplet at `/opt/vcpkg-triplets`. `VCPKG_CXX_FLAGS` is `-stdlib=libc++` |
| curl | Present so vcpkg can fetch ports |

Not included: OpenCV. The vcpkg `eigen3` port is Eigen 5, not the Eigen 3.4
headers on `ci-cpp-opencv`.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
