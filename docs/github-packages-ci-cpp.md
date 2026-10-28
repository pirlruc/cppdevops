# ci-cpp (GitHub Packages)

Short-lived C++ analysis image. Same Debian and Alpine contents as
[docker-hub-ci-cpp.md](https://hub.docker.com/r/pirlruc/ci-cpp). Not a product runtime — no
`HEALTHCHECK`.

## Image

| Item | Value |
|------|--------|
| GHCR | `ghcr.io/pirlruc/ci-cpp` |
| Architectures | `linux/amd64` |
| User | non-root `1000:1000` |
| Base | Debian 13 (unsuffixed); Alpine 3.24 (`-alpine`) |

### Tags

Same 6.3.0 manifests as [docker-hub-ci-cpp.md](https://hub.docker.com/r/pirlruc/ci-cpp). This
package is private, so an anonymous manifest read returns 403. Actions pulls
`ghcr.io/pirlruc/ci-cpp` at the `linux/amd64` image manifest
`sha256:88d24172b5b6ab74a4276a60bb341c238b072cb57169c690a21c2d2cfbeafbac`,
not the tag index `sha256:26422f64…`.

| Tag | Digest |
|-----|--------|
| `6.3.0` / `6.3.0-debian` / `latest` / `latest-debian` | `sha256:26422f6453e04c72d46792fe6ab70574eeb037f55c1ba31c962ab86cb8a71802` (tag index) |
| `6.3.0` `linux/amd64` (Actions) | `sha256:88d24172b5b6ab74a4276a60bb341c238b072cb57169c690a21c2d2cfbeafbac` |
| `6.3.0-alpine` / `latest-alpine` | `sha256:2176dd7427f53691ea0e79710870fee5af31a7ff96c7135367e7b709a27179fb` (tag index) |
| `6.3.0-alpine` `linux/amd64` (Actions) | `sha256:d686e56e013cf560818d9b7df515db78bf8313495155d66cf4125a99db44717b` |
| `6.2.1` / `6.2.1-debian` | Previous Debian. `sha256:043eab3763325104619dc252ef003d03aa0690545b443858e0c528c1715be0c1` (tag index) |
| `6.2.1` `linux/amd64` | `sha256:88fd10cb4cf754f190f565f14667fc5eef8cd933326fe2daa84ed0479709f19a` |
| `6.2.1-alpine` | Previous Alpine. `sha256:e1f4ce03f7645c6e806d2917f77708c320bdcfab580055c946c963d876f50496` (tag index) |
| `6.2.1-alpine` `linux/amd64` | `sha256:7412677a59089bd4556d20a4ee574da73ea3445454c5694ab5b057d509e8a410` |
| `6.0.0` / `6.0.0-debian` | Previous Debian. `sha256:b560e30b94c2b50538f61673bcbd8267403d021b8e4059fecf15817c9f3e4b26` (tag index) |
| `6.0.0` `linux/amd64` | `sha256:32d74a33b346770271e26a640cf7261751285bf4f2095d56fa6658a7f4b61ef1` |
| `6.0.0-alpine` | Previous Alpine. `sha256:24e40b95d1ddc8d66886e58282799bff197fea723d669f77cd6b70026f8ccea9` (tag index) |
| `6.0.0-alpine` `linux/amd64` | `sha256:ee55ee3368f9c629a650cd89bb44c73e118aa522fe197896e3328e639b61e83f` |
| `5.2.0` / `5.2.0-debian` | Previous Debian analysis. `sha256:94667c573a1fe4a08aa333cd4083a53553d394c34a8d854d12912831b5536cde` (tag index) |
| `5.0.0` | Previous Debian analysis. `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67` |
| `5.0.0-alpine` | Previous Alpine analysis. `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986` |

Debian owns the unsuffixed tags. Prefer a digest in production.

## Authentication

```bash
echo "$CR_PAT" | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/pirlruc/ci-cpp:6.3.0
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
      image: ghcr.io/pirlruc/ci-cpp@sha256:88d24172b5b6ab74a4276a60bb341c238b072cb57169c690a21c2d2cfbeafbac
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

Same toolchain as [docker-hub-ci-cpp.md](https://hub.docker.com/r/pirlruc/ci-cpp). clang-format
is 23.1.0.

## License

MIT. Source: https://github.com/pirlruc/cppdevops
