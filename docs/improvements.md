# Improvements — cppdevops

Backlog for the reusable CI workflows repository.

## High

- Consumers should pin `pirlruc/cppdevops@<sha>` (`CI-018`) once libraries split from the OS folder (thin callers currently may still use `@main` from sync script — prefer SHA).
- **Real mobile matrix builds** (`MOBILE-MECH-001`): replace placeholder `echo` steps in `cpp-mobile-matrix.yml` with Android NDK + iOS SDK cross-compile smoke of a header-including TU. Blocks library `MOBILE-001` (e.g. runa-cpp #27/#28).

## Medium

- Document workflow inputs/outputs for each reusable workflow in README (partially done).
- Keep threshold reads aligned with `docs/guardrails/cpp/profile.thresholds.yml`.
- **Upstream github-scaffold:** update `scripts/issues-sync-all.sh` / `issues-resync-all.sh` path lists from legacy `traits/`…`drawer/` to Nordic folder names (`runa-cpp/`, …).
- **Upstream github-scaffold:** `scripts/setup-library-submodules.sh` still defaults `GUARDRAILS_REF=9285d36` — change default to `main`.
- When Actions quota recovers: re-enable push/PR or label-gated `run-ci` (`CI-TRIGGER-001`).
- Coverage gate: gcov-compatible `--coverage` + `gcovr --gcov-executable "llvm-cov gcov"`; zero-instrumentable header-only libs pass (`COV-MECH-001` follow-up).

## Low

- Consider publishing example thin-caller snippets per library type (header-only vs compiled).
- Retire draupnir legacy CodeQL/Codacy/Ubuntu workflows once all libraries use cppdevops callers only.

## Recently implemented (local; push via PRs)

- Manual-first `workflow_dispatch` callers (`CI-TRIGGER-001`)
- Analysis config templates + sync (`TOOL-CFG-001`)
- clang-tidy / cppcheck / Metrix++ in `cpp-quality.yml` (`GATE-MECH-001`)
- Coverage gate script + `cpp-tests.yml` (`COV-MECH-001`)
- coverxygen gate (`DOC-MECH-001`)
- `cpp-dynamic.yml` ASan/UBSan + valgrind (`DYN-MECH-001`)
- Security harden + CodeQL + Syft/Grype/Trivy (`SEC-MECH-001`–`003`)
- `cpp-infra.yml` ShellCheck/actionlint/hadolint (`INFRA-MECH-001`)

## Guardrails / methodology compliance

- Pins: `docs/guardrails` @ `256f707`, `.github/scaffold` @ `11f4393` (synced templates).
- Delta compliance (06bf913 → 256f707): `cpp-dynamic.yml` uses `cmake --preset ci-asan` (`CPP-DYN-001`); `cpp-security.yml` gates Syft/Grype/Trivy behind `run_sbom` (default false, merge/release) (`CPP-SEC-003`); dual SAST + Metrix++ + CI-023 infra lint already wired.
- Cite stable Guardrail IDs (`CI-*`) in new Epics/deviations.
- C++ library layout gates (`CPP-BUILD-*` CMake/vcpkg/devcontainer) are **N/A** for this infra repo; quality profile still applies to scripts/workflows where relevant.
- Thresholds: read from pinned `docs/guardrails/`, do not duplicate org defaults locally.
- Platform/CI deltas for consumers: [`platform-and-ci-deltas.md`](platform-and-ci-deltas.md).
- Bootstrap templates/scripts now live in this repo (`templates/`, `scripts/sync-library-*.sh`).
- Guardrails profile revisions tracked on [pirlruc/guardrails](https://github.com/pirlruc/guardrails/issues) (`GR-CPP-*`).
