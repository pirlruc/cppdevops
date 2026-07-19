# AI Agent Handoff — cppdevops

## Identity

| Field | Value |
|-------|-------|
| **Folder** | `cppdevops/` |
| **Role** | Reusable GitHub Actions workflows + C++ library bootstrap templates/scripts |
| **Docs** | `docs/ai-agent-handoff.md`, `docs/platform-and-ci-deltas.md`, `docs/improvements.md`, `README.md` |
| **Type** | CI infrastructure (not a C++ library) |

## Scope

Owns reusable workflows under `.github/workflows/`:

- `cpp-quality.yml`, `cpp-tests.yml`, `cpp-docs.yml`, `cpp-security.yml`
- `cpp-mobile-matrix.yml`

Also owns library bootstrap assets under `templates/` and `scripts/sync-library-*.sh` / `generate-doxyfile.sh`.

Standalone library callers should pin `pirlruc/cppdevops@<sha>` (`CI-018`).

## Upstream gaps (github-scaffold)

Recorded in [`improvements.md`](improvements.md): Nordic path lists in `issues-*-all.sh`; `GUARDRAILS_REF` default still `9285d36` (should be `main`).

## Issue methodology (new issues only)

Epic issues are decision records ([github-issue-adr](https://github.com/pirlruc/methodologies/tree/main/github-issue-adr)). Submodules: `docs/guardrails/`, `.github/scaffold/`. Templates: `.github/ISSUE_TEMPLATE/` (synced from scaffold). Do not retroactively edit existing GitHub issues.

## See also

- [platform-and-ci-deltas.md](platform-and-ci-deltas.md)
- [improvements.md](improvements.md)
- [README.md](../README.md)
- [guardrails](guardrails/) (pinned profile)

*Last updated: 2026-07-19*
