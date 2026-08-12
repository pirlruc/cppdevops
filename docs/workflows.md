# Reusable workflows

All workflows support `workflow_call` (and `workflow_dispatch` where noted).
Top-level `permissions: {}` (CI-025); jobs grant least privilege. Secret-using
jobs skip when `github.actor == 'dependabot[bot]'` (CI-024). Nested script
checkout uses `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1`
(v7.0.1) with `persist-credentials: false`.

Shared inputs:

| Input | Type | Default | Notes |
|-------|------|---------|-------|
| `library_path` | string | (required on most) | Library root relative to the caller checkout |
| `blocking` | bool | `false` | `false` → `continue-on-error` (advisory) |
| `checkout_token` (secret) | string | — | PAT with `contents:read` on `pirlruc/cppdevops` (and nested `commondevops` when forwarded) for private cross-repo callers |

Consumers pin `pirlruc/cppdevops/.github/workflows/<name>.yml@<sha-or-tag>`
(`CI-018`). Prefer `@<sha>` or an annotated release tag over `@main`.

Thresholds for C++ gates are intended to come from
`docs/guardrails/cpp/profile.thresholds.yml` (vendored copy under `scripts/`
when the submodule is not available in sparse checkout — see CPPD-WF-001).

---

## `cpp-quality.yml`

clang-format, cpplint, clang-tidy, cppcheck, lizard, Metrix++.

| Input | Default | Notes |
|-------|---------|-------|
| `library_path` | required | |
| `blocking` | `false` | |

Numeric gates (CCN, coverage) come from `scripts/cpp.profile.thresholds.yml`
(CI-021/022). Job runs in `container: ghcr.io/pirlruc/ci-cpp:latest` (until
digest-pinned).

---

## `cpp-tests.yml`

CMake configure/build, CTest, coverage gate (`scripts/check-coverage.sh`).

| Input | Default |
|-------|---------|
| `library_path` | required |
| `cmake_preset` | `ci-linux` |
| `blocking` | `false` |

---

## `cpp-docs.yml`

Doxygen + coverxygen via `scripts/check-doc-coverage.sh` (reads `doc_coverage`
from vendored thresholds; does not mutate the tracked Doxyfile).

| Input | Default |
|-------|---------|
| `library_path` | required |
| `blocking` | `false` |

---

## `cpp-dynamic.yml`

ASan/UBSan (`cmake --preset ci-asan`) and valgrind memcheck (`CPP-DYN-001`).

| Input | Default |
|-------|---------|
| `library_path` | required |
| `blocking` | `false` |
| `run_asan` | `true` |
| `run_valgrind` | `true` |

---

## `cpp-codeql.yml`

CodeQL for C++ using `.github/codeql/codeql-config.yml` (`CPP-SEC-002`).

| Input | Default |
|-------|---------|
| `library_path` | required |
| `blocking` | `false` |
| `cmake_preset` | `ci-linux` |

Skips Dependabot actor (`CI-024`).

---

## `cpp-security.yml`

Thin forwarder to [commondevops](https://github.com/pirlruc/commondevops):

- `common-secrets-sast.yml` (gitleaks + semgrep)
- `common-supply-chain.yml` (Syft / Grype / Trivy) when `run_sbom: true`

| Input | Default | Notes |
|-------|---------|-------|
| `library_path` | required | Passed as `working_directory` |
| `blocking` | `false` | |
| `run_sbom` | `true` | SC-SBOM-001 / CPP-SEC-003 |

`uses:` and `scripts_ref` must stay in lockstep (`CI-018`).

---

## `cpp-infra.yml`

Thin forwarder to commondevops `common-infra-lint.yml` (actionlint, shellcheck,
hadolint, zizmor).

| Input | Default |
|-------|---------|
| `blocking` | `false` |
| `working_directory` | `.` |
| `shell_scripts` | `""` |
| `dockerfiles` | `""` |

---

## `cpp-mobile-matrix.yml`

Android NDK + iOS Xcode matrix. Placeholder until MOBILE-MECH-001; deviations
`CI-014`, `CPP-BUILD-010`, `CPP-BUILD-011` recorded in
`docs/guardrail-deviations.yml`.

| Input | Default |
|-------|---------|
| `library_path` | required |
| `min_ndk` | `26.1.10909125` |
| `min_xcode` | `15.4` |
| `blocking` | `false` |

### Mobile toolchain pins (`CPP-BUILD-012`)

| Pin | Value | Review |
|-----|-------|--------|
| `MIN_ANDROID_NDK_VERSION` | 26.1.10909125 | 2027-01-01 |
| `MIN_XCODE_VERSION` | 15.4 | 2027-01-01 |

---

## Thin caller example

```yaml
name: Quality
on:
  workflow_dispatch:
    inputs:
      blocking:
        type: boolean
        default: false
permissions: {}
jobs:
  quality:
    uses: pirlruc/cppdevops/.github/workflows/cpp-quality.yml@<sha>
    with:
      library_path: .
      blocking: ${{ inputs.blocking }}
```

Seeded by `scripts/sync-library-tooling.sh` as create-once
`.github/workflows/ci-quality.yml`.
