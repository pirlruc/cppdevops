# Changelog

All notable changes to this repository are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Changed

- `docs/guardrails` tag **1.8.0** (`aa5184ce…`); `.github/scaffold` tag **1.7.0**
  (`e76bb3fd…`). Synced issue templates, Cursor rules, `AGENTS.md`, `SKILLS.md`,
  and `CLAUDE.md`. Decision links cite methodologies **1.6.0** (not a submodule
  in this repo).
- Record `SC-PROV-001` next to `SC-SIGN-001` (guardrails 1.8.0 Free-plan pattern).
- `ci-cpp` apt packages are version-pinned (hadolint DL3008 ignores removed).
  Both stages repeat `ubuntu:24.04@sha256:49675449…` (config created 2026-09-11).
  The previous digest was 60 days old, and a stage alias fails the base-image
  age gate.
- `ci-cpp` installs `cloc` 1.98. Python tools pin `setuptools==84.0.0`,
  `msgpack==1.2.3`, and `pygments==2.21.0`. `pip` is not left in the image
  (it vendors msgpack 1.1.2). `linux-libc-dev` is pinned at `6.8.0-142.142`.

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
