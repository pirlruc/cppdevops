# ci-cpp-vcpkg

The Debian analysis image plus a pinned vcpkg
(`434307da09bc05b2c86996dccc8b2351fc0d5d37`). OpenCV is not installed.
Builds use `VCPKG_DEFAULT_BINARY_CACHE`. The image sets
`VCPKG_DEFAULT_TRIPLET=x64-linux-libcxx` so ports link libc++, the same
standard library the libraries compile with. Not a product runtime — no
`HEALTHCHECK`.

Analysis tools are documented on [ci-cpp](docker-hub-ci-cpp.md). OpenCV and
Eigen from the image are [ci-cpp-opencv](docker-hub-ci-cpp-opencv.md).

## Image

| Item | Value |
|------|--------|
| Docker Hub | `pirlruc/ci-cpp-vcpkg` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | `ci-cpp` Debian 5.0.0 (`sha256:3406477b…`) plus vcpkg |
| Context | `docker/ci-cpp-vcpkg/` |

### Tags

| Tag | Digest |
|-----|--------|
| `5.2.0` / `latest` | `sha256:76b9587f04834322dadd318e3ce5d17349e68df990a9575647f7dc6fb7553cde` (tag index) |
| `sha-<git>` | Exact git SHA of the published commit |

Prefer a digest in production. Confirm the `linux/amd64` image manifest
before pinning Actions `container:`; a tag index is not a pullable image.

```bash
docker pull pirlruc/ci-cpp-vcpkg:5.2.0
```

## Quick start

```bash
docker run --rm pirlruc/ci-cpp-vcpkg:5.2.0 vcpkg version
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
