# cppdevops

Local stand-in for the future `pirlruc/cppdevops` repository.

Contains **reusable GitHub Actions workflows** (`workflow_call`) shared by all C++ library repos in the image_proc monorepo.

## Workflows

| Workflow | Purpose |
|----------|---------|
| `cpp-quality.yml` | clang-format, clang-tidy, cppcheck, cpplint, lizard CCN |
| `cpp-tests.yml` | CMake build + CTest + coverage |
| `cpp-docs.yml` | Doxygen + coverxygen doc coverage |
| `cpp-security.yml` | gitleaks, semgrep |

## Usage (per-library caller)

```yaml
jobs:
  quality:
    uses: ./cppdevops/.github/workflows/cpp-quality.yml
    with:
      library_path: traits
      blocking: false  # M1 advisory; M4 sets true
```

When libraries split to separate repos:

```yaml
uses: pirlruc/cppdevops/.github/workflows/cpp-quality.yml@<sha>
```

## Thresholds

Read from `docs/guardrails/cpp/profile.thresholds.yml` (vendored central profile).

## Review protocol

Changes to reusable workflow bodies affect all libraries — submit as a separate reviewable changeset.
