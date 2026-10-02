# Consumer pin and draupnir retirement checklist

Library-side follow-up for [CI-018](https://github.com/pirlruc/guardrails/blob/main/ci/guardrails.md)
(owned by each library repo, tracked here as CPPD-ECO-001). Pin reusable
workflows at a **tag or full SHA**, never `@main`.

## 5.0.0 image base (breaking for direct image users)

`ci-cpp` analysis moves from Ubuntu 24.04 to a Docker Hardened Images Debian 13
base. Alpine is published as `ci-cpp` with tag suffix `-alpine`. Compile-and-ctest
on Ubuntu uses the separate `ci-cpp-ubuntu` image. graphviz, cloc, and curl are
not in the analysis image. The devcontainer stays Ubuntu 24.04. Do not pin the
5.0.0 workflows until `ci-cpp-ubuntu:5.0.0` exists; the `ubuntu-compile` job
references that tag.

## Who still pins `@main`

Seven Nordic libraries still call `pirlruc/cppdevops/.github/workflows/*.yml@main`:

| Repo | Thin caller |
|------|-------------|
| [bifrost-cpp](https://github.com/pirlruc/bifrost-cpp) | `.github/workflows/ci-quality.yml` |
| [draupnir-cpp](https://github.com/pirlruc/draupnir-cpp) | `.github/workflows/ci-quality.yml` |
| [edda-cpp](https://github.com/pirlruc/edda-cpp) | `.github/workflows/ci-quality.yml` |
| [heimdallcv](https://github.com/pirlruc/heimdallcv) | `.github/workflows/ci-quality.yml` |
| [mimir-cpp](https://github.com/pirlruc/mimir-cpp) | `.github/workflows/ci-quality.yml` |
| [mjolnir-cpp](https://github.com/pirlruc/mjolnir-cpp) | `.github/workflows/ci-quality.yml` |
| [nornir-cpp](https://github.com/pirlruc/nornir-cpp) | `.github/workflows/ci-quality.yml` |

`bor-cpp` and `runa-cpp` already pin a SHA and are out of this list.

## Pin bump (every consumer)

1. Read this repo's [CHANGELOG](https://github.com/pirlruc/cppdevops/blob/main/CHANGELOG.md)
   and GitHub Releases for the target tag or SHA (`CI-019`).
2. Replace every `uses: pirlruc/cppdevops/.github/workflows/*.yml@main` (or an
   older tag) with `@<annotated-tag>` or `@<full-sha>`. Do **not** leave `@main`.
3. After [cppdevops 3.1.2](https://github.com/pirlruc/cppdevops/releases/tag/3.1.2)
   is tagged, bump to `@3.1.2`. Do not stay on `@3.0.0` / `@main`.
   Tag **3.1.2** has no GitHub Release (does not republish `ci-cpp`).

### github-scaffold seed is still `1.0.0`

[github-scaffold `templates/ci-quality.yml`](https://github.com/pirlruc/github-scaffold/blob/main/templates/ci-quality.yml)
still pins `pirlruc/cppdevops@1.0.0` until [GS-CI-004](https://github.com/pirlruc/github-scaffold)
lands. This repo's vendored `templates/ci-quality.yml` pins `@3.1.2`. Consumers
that were seeded from the old scaffold (or that still float `@main`) must bump
the `uses:` lines themselves. Do not wait for a scaffold template bump.

## draupnir-cpp retirement

Once [draupnir-cpp](https://github.com/pirlruc/draupnir-cpp) pins cppdevops and
the thin caller is the only quality/test/docs/security path, retire the legacy
workflows so they stop competing with `ci-quality.yml`:

| Workflow | Why it goes |
|----------|-------------|
| [codeql.yml](https://github.com/pirlruc/draupnir-cpp/blob/main/.github/workflows/codeql.yml) | Replaced by `cpp-codeql.yml` via the thin caller |
| [codacy-coverage-reporter.yml](https://github.com/pirlruc/draupnir-cpp/blob/main/.github/workflows/codacy-coverage-reporter.yml) | Coverage lives in `cpp-tests.yml` |
| [cpp_build_test_ubuntu.yml](https://github.com/pirlruc/draupnir-cpp/blob/main/.github/workflows/cpp_build_test_ubuntu.yml) | Ubuntu host build replaced by `cpp-tests.yml` in `ci-cpp` |
| [cpp_artifacts_ubuntu.yml](https://github.com/pirlruc/draupnir-cpp/blob/main/.github/workflows/cpp_artifacts_ubuntu.yml) | Artifact path is library-owned; drop or replace after the caller lands |

Do not delete those files from *this* repo — they are not in the tree. File the
removals in draupnir-cpp after the pin bump.
