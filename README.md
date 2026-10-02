# cppdevops

[pirlruc/cppdevops](https://github.com/pirlruc/cppdevops) — reusable GitHub Actions
workflows (`workflow_call`) for pirlruc C++ libraries, plus the `ci-cpp` toolchain
image and library bootstrap templates.

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
| `cpp-mobile-matrix.yml` | iOS / Android NDK+Xcode smoke compile (MOBILE-MECH-001) |

Full input/output contract: [`docs/workflows.md`](docs/workflows.md).

## Actions quota mode (CI-TRIGGER-001)

Library thin callers use **`workflow_dispatch` only** so pushes/PRs do not consume
Actions minutes. Re-enable `push`/`pull_request` or label-gated `run-ci` when quota
allows.

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

Pin `@<sha>` or an annotated tag (`CI-018`). Do not pin `@main`. Consumer
libraries still on `@main` (and draupnir-cpp legacy workflows) follow
[`docs/consumer-checklist.md`](docs/consumer-checklist.md). Advisory mode:
`blocking: false` keeps `continue-on-error` so findings are visible without
failing the workflow during refactor.

## Thresholds

Numeric gates are read from `scripts/cpp.profile.thresholds.yml` (vendored from
the pinned `docs/guardrails/cpp/profile.thresholds.yml` profile; CPPD-WF-001).
CI drift-checks the copy against the submodule (`scripts/check-threshold-drift.sh`).

Reusable `cpp-*` jobs run in
`container: ghcr.io/pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67`.

## Library bootstrap (templates + scripts)

```bash
./scripts/sync-library-tooling.sh /path/to/bor-cpp
./scripts/sync-library-devcontainer.sh /path/to/bor-cpp core bor-cpp
./scripts/generate-doxyfile.sh /path/to/bor-cpp
```

| Path | Role |
|------|------|
| `templates/cpp/` | clang/format/tidy, pre-commit, gitleaks, presets, Doxyfile, scanners |
| `templates/cmake/pirlruc_library.cmake` | Shared CMake helper |
| `scripts/sync-library-tooling.sh` | Copy analysis configs + create-once `ci-quality.yml` |
| `scripts/sync-library-devcontainer.sh` | Standalone devcontainer from template |
| `scripts/generate-doxyfile.sh` | Generate `Doxyfile` from `Doxyfile.in` |

Synced configs include: clang-format/tidy, cpplint, gitleaks, semgrep, Metrix++
(`.metrixpp.yml`), cppcheck suppressions, CodeQL, Syft/Grype/Trivy, ShellCheck,
actionlint.

Issue/PR templates remain in [pirlruc/github-scaffold](https://github.com/pirlruc/github-scaffold).

## Methodology

[GitHub Issue-native ADR](https://github.com/pirlruc/methodologies/tree/1.8.0/github-issue-adr)
— Epic = decision record. Templates: [pirlruc/github-scaffold](https://github.com/pirlruc/github-scaffold).
Quality: pin [pirlruc/guardrails](https://github.com/pirlruc/guardrails) at `docs/guardrails/`.
Deviations: [`docs/guardrail-deviations.yml`](docs/guardrail-deviations.yml) only.

## Documentation

- Agent handoff: [`docs/ai-agent-handoff.md`](docs/ai-agent-handoff.md)
- Workflow contracts: [`docs/workflows.md`](docs/workflows.md)
- Docker Hub: [`docs/docker-hub.md`](docs/docker-hub.md)
- GitHub Packages: [`docs/github-packages.md`](docs/github-packages.md)
- Consumer pin / draupnir retirement: [`docs/consumer-checklist.md`](docs/consumer-checklist.md)
- Authored backlog: [`docs/issues.yml`](docs/issues.yml)
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)

## Review protocol

Changes to reusable workflow bodies affect all libraries — submit as a separate
reviewable changeset.
