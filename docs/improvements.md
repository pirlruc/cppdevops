# Improvements — cppdevops

Backlog for the reusable CI workflows repository.

## High

- Consumers should pin `pirlruc/cppdevops@<sha>` (`CI-018`) once libraries split from the OS folder (thin callers currently may still use `@main` from sync script — prefer SHA).
- Ensure coverxygen + valgrind hooks are available as blocking options for library callers.

## Medium

- Document workflow inputs/outputs for each reusable workflow in README.
- Keep threshold reads aligned with `docs/guardrails/cpp/profile.thresholds.yml`.
- **Upstream github-scaffold:** update `scripts/issues-sync-all.sh` / `issues-resync-all.sh` path lists from legacy `traits/`…`drawer/` to Nordic folder names (`runa-cpp/`, …).
- **Upstream github-scaffold:** `scripts/setup-library-submodules.sh` still defaults `GUARDRAILS_REF=9285d36` — change default to `main`.

## Low

- Consider publishing example thin-caller snippets per library type (header-only vs compiled).

## Guardrails / methodology compliance

- Pins: `docs/guardrails` @ `06bf913`, `.github/scaffold` @ `11f4393` (synced templates).
- Cite stable Guardrail IDs (`CI-*`) in new Epics/deviations.
- C++ library layout gates (`CPP-BUILD-*` CMake/vcpkg/devcontainer) are **N/A** for this infra repo; quality profile still applies to scripts/workflows where relevant.
- Thresholds: read from pinned `docs/guardrails/`, do not duplicate org defaults locally.
- Platform/CI deltas for consumers: [`platform-and-ci-deltas.md`](platform-and-ci-deltas.md).
- Bootstrap templates/scripts now live in this repo (`templates/`, `scripts/sync-library-*.sh`).
