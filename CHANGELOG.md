# Changelog

All notable changes to this repository are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

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
