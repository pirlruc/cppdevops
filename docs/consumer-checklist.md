# Consumer pin and draupnir retirement checklist

Library-side follow-up for [CI-018](https://github.com/pirlruc/guardrails/blob/main/ci/guardrails.md)
(owned by each library repo, tracked here as CPPD-ECO-001). Pin reusable
workflows at a **tag or full SHA**, never `@main`.

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
3. After [cppdevops 2.1.0](https://github.com/pirlruc/cppdevops/releases) is
   tagged, bump to `@2.1.0` (or that tag's SHA). Until then, `@2.0.0` or a
   post-2.0.0 SHA is the current release pin.

### github-scaffold seed is still `1.0.0`

[github-scaffold `templates/ci-quality.yml`](https://github.com/pirlruc/github-scaffold/blob/main/templates/ci-quality.yml)
still pins `pirlruc/cppdevops@1.0.0`. That seed is create-once; copying it into
a library does **not** pick up 2.0.0 / 2.1.0. Consumers that were seeded from
it (or that still float `@main`) must bump the `uses:` lines themselves.
Do not wait for a scaffold template bump.

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
