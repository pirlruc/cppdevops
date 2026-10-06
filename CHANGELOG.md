# Changelog

All notable changes to this repository are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

## [5.1.1] - 2026-10-06

### Fixed

- Pin commondevops 5.3.3 so nested secrets-sast and supply-chain workflows
  grant the permissions their jobs use.

## [5.1.0] - 2026-10-06

### Fixed

- Reusable `cpp-*.yml` workflows grant, at workflow level, every permission
  their jobs request. `permissions: {}` made GitHub reject the run before any
  job started (CPPD-PERM-001).

### Added

- `ci-cpp-vcpkg` image: the Debian analysis toolchain plus a pinned vcpkg.
  OpenCV is not installed in the image. `use_vcpkg` and `container_image`
  inputs on quality, tests, codeql, and dynamic restore a files binary cache
  and authenticate private `vcpkg_from_git` ports from `checkout_token`
  without writing the token into the log (CPPD-CACHE-001).
- `templates/cmake/pirlruc_library.cmake` matches the libraries: C++20 via
  `target_compile_features`, `FILE_SET` headers, and `EXPORT_NAME`
  (CPPD-CMAKE-002).

## [5.0.2] - 2026-10-02

### Changed

- Publish `-debian` on ci-cpp and `latest-alpine` on the Alpine variant.
  Publish `ci-cpp-ubuntu` to Docker Hub when that repository exists.

## [5.0.1] - 2026-10-02

### Changed

- Pin analysis jobs to ci-cpp **5.0.0** Debian
  `sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67`.
  The ubuntu-compile job pins ci-cpp-ubuntu
  `sha256:0a6f9b7f044e9e1a2098ff7f57425d16245daaeff505b07dca90199933a3011f`.
  Alpine is `sha256:78103428af883fe259241796d359edd3cfbaefe34e11878760a97c1a9efc2986`.
- Pin guardrails **1.10.0**.

## [5.0.0] - 2026-10-02

### Changed

- **Breaking:** `ci-cpp` analysis moves from Ubuntu 24.04 to DHI Debian 13
  (Clang 18, unsuffixed tags). Alpine 3.24 is published as `-alpine` with
  Clang 20, because the Alpine libc++ requires Clang 20. `ci-cpp-ubuntu` is
  compile-only (Clang 18, libc++, CMake, Ninja, git). Devcontainers stay
  Ubuntu. CPP-BUILD-004 is recorded under CPPD-IMG-003. Graphviz, cloc, and
  curl are gone. Python tools install from a hashed lock. SC-PROV-001 is
  retired because publish attaches registry provenance without signing.
  Final stages clear setuid and setgid bits. Scheduled security runs
  Scorecard and the PAT expiry audit. zizmor requires full SHA pins.
- Pin both `ci-cpp` stages to `ubuntu:24.04@sha256:a853f94d…` (config Created
  2026-09-18). The previous pin (`008173c2…`, Created 2026-09-11) fails
  DOCKER-BUILD-006 on 2026-10-11. Local Trivy `os,library` (no ignorefile):
  the fixable highs from 3.1.0 are gone; CVE-2026-64564 and 167 other unfixed
  `linux-libc-dev` highs remain (CPPD-SCAN-001).

## [4.0.3] - 2026-10-02

### Changed

- Threshold drift fails when `GUARDRAILS_READ_TOKEN` is unset. The secret is
  now on the repository. Dependabot still skips the job. Tag only. No GitHub
  Release, so the image is not republished.

## [4.0.2] - 2026-10-01

### Changed

- Hub and Packages examples pull `4.0.0`, the current image. Tag only.
  No GitHub Release, so the image is not republished.

## [4.0.1] - 2026-10-01

### Changed

- Write the 4.0.0 digest `sha256:cf40f3bc99ebe50a286d1e57ac0aa63c28678ef44e65b3a6dbef0c7420afa47f`
  into the workflow `container:` pins, the published rescan, and the Hub and
  Packages pages. Tag only. No GitHub Release, so the image is not republished.

## [4.0.0] - 2026-10-01

### Breaking

- Cross-repo callers of `cpp-*` must pass `scripts_ref` equal to the `uses:`
  pin (CI-034). `templates/ci-quality.yml` does this and passes
  `CPPDEVOPS_READ_TOKEN` into quality, tests, docs, codeql, dynamic, mobile,
  and fuzz.
- Nested commondevops pin is **5.2.6**
  (`8aad4ba4a597a87565d6d3d1a92a8bdd7568921c`). Nested containerdevops pin is
  **6.1.0** (`edef9c8413363c46dcb276f5188a033d9fc6fd4e`). Publish needs
  `attestations: write`.

### Added

- `cpp-fuzz.yml` builds and runs one libFuzzer target. `run_fuzz` defaults to
  false so a library with no target skips it (CPPD-FUZZ-001). `ci-cpp` installs
  `libfuzzer-18-dev` and `libclang-rt-18-dev` so `-fsanitize=fuzzer,address` links.
- Advisory OS+library posture scan (`ignorefile: none`) next to the blocking
  library scan.
- Deviations CI-032 and REL-PUB-004. The repository returns to private on the
  Free plan (CPPD-PIN-003).

### Changed

- `docs/guardrails` tag **1.9.0** (`16a2c95c…`); `.github/scaffold` tag
  **1.8.0** (`ac9059fd…`). Decision links cite methodologies **1.8.0**.
- CI-024 skips use `github.event.pull_request.user.login`. Dependabot pull
  requests run `pins`, `scaffold`, and a token-free `lint-dependabot` job.
- `ci-cpp` stays on Ubuntu 24.04 (CPP-BUILD-004). Both stages pin
  `ubuntu:24.04@sha256:008173c2…`. The config Created date is still
  2026-09-11, so DOCKER-BUILD-006 fails on 2026-10-11 until Ubuntu publishes
  a newer noble config. clang-format **23.1.0** comes from the venv; apt
  clang-format 18 is not installed. Pre-commit mirrors-clang-format is v23.1.0.
- `dhi_login` is false. Publish verifies with `clang++ --version`. Handoff
  cleanup runs whenever publish did not succeed.
- The artifact sweep also deletes `*.dockerbuild` artifacts and Actions
  caches on pull and tag refs.

## [3.1.2] - 2026-09-15

### Changed

- Nested [commondevops](https://github.com/pirlruc/commondevops) pin is **5.1.2**
  (`b3c462bed0de4f6475e6be7875c4ababd831acc6`) with lockstep `scripts_ref`.
- `scripts/check-ci-docker.sh` default is ci-lint **5.1.1** Alpine
  `sha256:35a82a43…`.
- Seed `templates/ci-quality.yml` pins `@3.1.2`. Hub/Packages stay **3.1.0**
  (`sha256:f42b11bc…`); this tag has no GitHub Release and does not republish
  `ci-cpp`.

## [3.1.1] - 2026-09-15

### Changed

- Reusable `container:` pins and `cppdevops-security.yml` published rescan use
  the 3.1.0 `ci-cpp` digest
  `sha256:f42b11bc342c0dd6faef6454f4a37cf4230b9c2c87357623cad5ed0102608656`
  (from the 3.1.0 GitHub Release image publish). Do not float `:latest`.
- Seed `templates/ci-quality.yml` pins `@3.1.1`.

## [3.1.0] - 2026-09-15

### Added

- `docs/docker-hub.md` and `docs/github-packages.md` for `pirlruc/ci-cpp`.
- Mobile smoke compiles a generated TU that `#include`s a public header from
  `library_path` when `include/` exists.
- Optional `checkout_token` on `cpp-dynamic.yml` and `cpp-codeql.yml`.
- Token-free `pins` job (CI-024). Artifact sweep for leftover `container-image*`.

### Changed

- Image caller pins [containerdevops 5.0.2](https://github.com/pirlruc/containerdevops)
  (`32384866…`): `packages: write` on build, compose scan/publish from
  `handoff_package` + `digest` (do not pass `image_ref` — secret-masked).
- ci-cpp venv pins `pip==26.2.1`, `msgpack==1.2.1`, and exact
  coverxygen/gcovr/lizard/cpplint. Trivy library ignores document pip-vendored
  msgpack and setuptools vendor-metadata false positives (review 2026-11-12).
- `.clang-tidy` `HeaderFilterRegex` is `include/.*` (no hardcoded library names).
- `sync-library-tooling.sh` requires `CPPDEVOPS_WORKFLOW_REF` (never `main`).
- Doxyfile generation fails closed. Coverage fails if branch % is missing.
- clang-tidy fails when more than 400 TUs would be truncated.
- Threshold-drift always compares vendored C++ floors to the pinned
  `docs/guardrails` gitlink when `GUARDRAILS_READ_TOKEN` is set (do not use
  `submodules: true`, which also clones private `github-scaffold` with
  `github.token` and 404s). When the token is unset the job notices and
  skips the content diff; SC-DEP-004 `pins` still asserts the gitlink.
- CodeQL 4.37.9, setup-xcode 1.7.0, semgrep 1.176.0. clang-format pre-commit
  stays on v22.1.8 (ci-cpp ships clang-format 18; do not take v23).

## [3.0.0] - 2026-09-14

MAJOR: guardrails 1.6.0, fail-closed thresholds/docs, and `size_class`.

### Breaking

- Missing Doxyfile fails the doc gate (generate via `generate-doxyfile.sh` or fail).
- Missing guardrails checkout / threshold keys fail closed (CI-022 / CI-035).
- Threshold-drift job skips only when `GUARDRAILS_READ_TOKEN` is unset.
  Do not fall back to `COMMONDEVOPS_READ_TOKEN` (it lacks contents:read on
  private `pirlruc/guardrails`).
- CI toolchain images pass `size_class: ci_toolchain` (containerdevops 4.0.0).
- Callers re-pin commondevops **5.0.0** (`bcddb5db…`) with matching `scripts_ref`.

### Added

- Collect-then-fail aggregates on quality/tests/docs.
- SC-DEP-004 pin assert, markdown/YAML lint, POSIX `check-ci-docker.sh` wrapper.
- Host vs Docker tool-availability layer and CI parity summary.
- `templates/ci-quality.yml` with `permissions:` (CI-025 / CI-031).

### Changed

- `docs/guardrails` tag **1.6.0**; `.github/scaffold` tag **1.5.0**.
- Retired DOCKER-PERF-001 size deviation (DOCKER-PERF-002 class).
- SC-SIGN-001 kept as the documented Free-plan private-repo pattern.

## [2.1.0] - 2026-09-11

### Changed

- `docker/ci-cpp`: `COPY --from=pybuild --chown=1000:1000` so the venv is not a
  separate `chown -R` layer (DOCKER-PERF-001 dive efficiency).
- `cpp-dynamic.yml` memcheck runs valgrind on each discovered test binary and
  **fails closed** when valgrind is missing or no binary exists (CI-035 /
  CPP-DYN-001). `ctest -T memcheck` without `MEMORYCHECK_COMMAND` is no longer
  treated as a gate.
- `cppdevops-security.yml` published rescan pins
  `ghcr.io/pirlruc/ci-cpp@sha256:54ea6b…` (same digest as reusable `container:`
  pins), not `:latest`.

### Added

- [`docs/consumer-checklist.md`](docs/consumer-checklist.md) — CI-018 pin bump
  (not `@main`), draupnir-cpp legacy workflow retirement, and the
  github-scaffold `templates/ci-quality.yml` `@1.0.0` vs `2.1.0` gap.

## [2.0.0] - 2026-08-12

MAJOR release: publishable `ci-cpp` image, self-CI aligned with
commondevops/containerdevops, and real mobile matrix smoke builds.
Consumers should pin callers at `@2.0.0` (or a full SHA) per CI-018.

### Added

- `docker/ci-cpp` multi-stage Ubuntu 24.04 image (Clang/libc++, CMake, Ninja,
  cppcheck, clang-tidy/format, Doxygen, gcovr, lizard, Metrix++, coverxygen,
  valgrind); structure-test + trivyignore; non-root `1000:1000`.
- `ci-cpp-image.yml` thin caller to containerdevops@2.4.0 — triggers:
  `release` / monthly schedule (`17 5 20 * *`) / path-filtered `pull_request` /
  `workflow_dispatch` (mirrors commondevops image callers; Dependabot skipped).
- Self-CI: `cppdevops-ci.yml` (push/PR `main`) and `cppdevops-security.yml`
  (weekly Wed 06:17 UTC + published-image probe/rescan).
- Local parity: `scripts/check-ci-local.sh`, `scripts/check-ci-docker.sh`.
- Vendored `scripts/cpp.profile.thresholds.yml` + `scripts/check-threshold-drift.sh`.
- Real Android NDK + iOS Xcode smoke compile (`scripts/mobile-smoke/smoke.cpp`).
- MIT `LICENSE`, `docs/workflows.md`, `docs/issues-sync-targets.yml`,
  `docs/guardrail-deviations.yml`, Dependabot `registries` + `cooldown`.

### Changed

- commondevops reusable workflow pins → tag **4.0.0**.
- Mobile matrix is no longer echo-only (MOBILE-MECH-001).
- Gate scripts no longer soft-pass missing coverage, mutate Doxyfile, or bake
  Metrix CCN; dead workflow inputs removed; concurrency groups added.

### Removed

- Scanner COPY from retired `ci-base` (syft/grype/trivy/gitleaks/shellcheck/
  hadolint/actionlint) — those stay on ci-lint / ci-supply-chain.
- `docs/improvements.md`, `docs/platform-and-ci-deltas.md` (retired into
  `docs/issues.yml` / handoff / README).

### Deviations

- DOCKER-PERF-001 — `image_max_size_mb` 2000 (measured rootfs 1065 MB).
- SC-SIGN-001 — cosign `sign=false` while the repo is private.

## [1.0.0] - 2026-08-10

First annotated release of the reusable C++ CI workflows and library bootstrap
assets. Consumers should pin callers at `@1.0.0` (or a full SHA) per CI-018.

### Added

- Reusable workflows (`workflow_call`):
  - `cpp-quality.yml`, `cpp-tests.yml`, `cpp-docs.yml`
  - `cpp-security.yml`, `cpp-codeql.yml`, `cpp-dynamic.yml`
  - `cpp-infra.yml`, `cpp-mobile-matrix.yml`
- Thin-caller input contract: `library_path` (required) and `blocking` (optional).
- Library bootstrap templates under `templates/` and sync scripts under `scripts/`.
- Guardrails submodule at `docs/guardrails/` and github-scaffold at `.github/scaffold/`.
- `CHANGELOG.md` (REL-CHG-001).
