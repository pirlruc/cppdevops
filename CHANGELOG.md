# Changelog

All notable changes to this repository are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

## [3.0.0] - 2026-09-14

MAJOR: guardrails 1.6.0, fail-closed thresholds/docs, and `size_class`.

### Breaking

- Missing Doxyfile fails the doc gate (generate via `generate-doxyfile.sh` or fail).
- Missing guardrails checkout / threshold keys fail closed (CI-022 / CI-035).
- Threshold-drift job skips only when no `GUARDRAILS_READ_TOKEN` /
  `COMMONDEVOPS_READ_TOKEN`; a present token must clone successfully.
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
