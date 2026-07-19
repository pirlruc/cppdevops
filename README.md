# cppdevops

[pirlruc/cppdevops](https://github.com/pirlruc/cppdevops) — reusable GitHub Actions workflows (`workflow_call`) for pirlruc C++ libraries.

## Workflows

| Workflow | Purpose |
|----------|---------|
| `cpp-quality.yml` | clang-format, clang-tidy, cppcheck, cpplint, lizard CCN |
| `cpp-tests.yml` | CMake build + CTest + coverage |
| `cpp-docs.yml` | Doxygen + coverxygen doc coverage |
| `cpp-security.yml` | gitleaks, semgrep |
| `cpp-mobile-matrix.yml` | iOS / Android matrix |

## Usage (standalone library caller)

```yaml
jobs:
  quality:
    uses: pirlruc/cppdevops/.github/workflows/cpp-quality.yml@<sha>
    with:
      library_path: .
      blocking: true
```

During local OS-folder development you may still call sibling `./cppdevops/...` paths; prefer SHA-pinned remote callers for published Nordic repos (`CI-018`).

## Thresholds

Read from `docs/guardrails/cpp/profile.thresholds.yml` (pinned central profile).

## Library bootstrap (templates + scripts)

This repo owns the shared C++ library bootstrap assets formerly under the image_proc OS folder:

```bash
# From a sibling Nordic checkout (or any path)
./scripts/sync-library-tooling.sh /path/to/bor-cpp
./scripts/sync-library-devcontainer.sh /path/to/bor-cpp core bor-cpp
./scripts/generate-doxyfile.sh /path/to/bor-cpp
```

See [`docs/platform-and-ci-deltas.md`](docs/platform-and-ci-deltas.md) for platform/CI policy deltas vs central guardrails.

## Methodology

[GitHub Issue-native ADR](https://github.com/pirlruc/methodologies/tree/main/github-issue-adr) — Epic = decision record, optional Y-statement, no ADR markdown files. Templates: [pirlruc/github-scaffold](https://github.com/pirlruc/github-scaffold). Quality: pin [pirlruc/guardrails](https://github.com/pirlruc/guardrails) at `docs/guardrails/`. Applies to **new issues only**.

## Documentation

- Agent handoff: [`docs/ai-agent-handoff.md`](docs/ai-agent-handoff.md)
- Platform/CI deltas: [`docs/platform-and-ci-deltas.md`](docs/platform-and-ci-deltas.md)
- Backlog: [`docs/improvements.md`](docs/improvements.md)

## Review protocol

Changes to reusable workflow bodies affect all libraries — submit as a separate reviewable changeset.
