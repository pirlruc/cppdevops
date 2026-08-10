# cppdevops

[pirlruc/cppdevops](https://github.com/pirlruc/cppdevops) — reusable GitHub Actions workflows (`workflow_call`) for pirlruc C++ libraries.

## Workflows

| Workflow | Purpose |
|----------|---------|
| `cpp-quality.yml` | clang-format, clang-tidy, cppcheck, cpplint, lizard, Metrix++ |
| `cpp-tests.yml` | CMake build + CTest + coverage gate |
| `cpp-docs.yml` | Doxygen + coverxygen doc coverage |
| `cpp-security.yml` | Forwards to commondevops secrets-sast + supply-chain (CodeQL in `cpp-codeql.yml`) |
| `cpp-codeql.yml` | CodeQL SAST (in addition to semgrep) |
| `cpp-dynamic.yml` | ASan/UBSan + valgrind memcheck |
| `cpp-infra.yml` | Thin caller → `commondevops` `common-infra-lint.yml` |
| `cpp-mobile-matrix.yml` | iOS / Android matrix (placeholder) |

## Actions quota mode (CI-TRIGGER-001)

Library thin callers use **`workflow_dispatch` only** so pushes/PRs do not consume Actions minutes. Re-enable `push`/`pull_request` or label-gated `run-ci` when quota allows.

### Run CI manually

```bash
# From a library checkout
gh workflow run Quality -f blocking=false
# or via the GitHub Actions UI → Quality → Run workflow
```

### Local quality loop (preferred during quota pressure)

```bash
pre-commit install
pre-commit run --all-files
cmake --preset default -DPIRLRUC_WITH_TESTS=ON && cmake --build build -j && ctest --test-dir build --output-on-failure
```

## Usage (standalone library caller)

```yaml
on:
  workflow_dispatch:
    inputs:
      blocking:
        type: boolean
        default: false

jobs:
  quality:
    uses: pirlruc/cppdevops/.github/workflows/cpp-quality.yml@<sha>
    with:
      library_path: .
      blocking: ${{ inputs.blocking }}
```

Pin `@<sha>` for published Nordic repos (`CI-018`). Advisory mode: `blocking: false` keeps `continue-on-error` so findings are visible without failing the workflow during refactor.

## Thresholds

Read from `docs/guardrails/cpp/profile.thresholds.yml` (pinned central profile).

## Library bootstrap (templates + scripts)

```bash
./scripts/sync-library-tooling.sh /path/to/bor-cpp
./scripts/sync-library-devcontainer.sh /path/to/bor-cpp core bor-cpp
./scripts/generate-doxyfile.sh /path/to/bor-cpp
```

Synced configs include: clang-format/tidy, cpplint, gitleaks, semgrep, Metrix++ knobs (`.metrixpp.yml`), cppcheck suppressions, CodeQL, Syft/Grype/Trivy, ShellCheck, actionlint.

See [`docs/platform-and-ci-deltas.md`](docs/platform-and-ci-deltas.md) for platform/CI policy deltas vs central guardrails.

## Methodology

[GitHub Issue-native ADR](https://github.com/pirlruc/methodologies/tree/main/github-issue-adr) — Epic = decision record. Templates: [pirlruc/github-scaffold](https://github.com/pirlruc/github-scaffold). Quality: pin [pirlruc/guardrails](https://github.com/pirlruc/guardrails) at `docs/guardrails/`.

## Documentation

- Agent handoff: [`docs/ai-agent-handoff.md`](docs/ai-agent-handoff.md)
- Platform/CI deltas: [`docs/platform-and-ci-deltas.md`](docs/platform-and-ci-deltas.md)
- Backlog: [`docs/improvements.md`](docs/improvements.md)

## Review protocol

Changes to reusable workflow bodies affect all libraries — submit as a separate reviewable changeset.
