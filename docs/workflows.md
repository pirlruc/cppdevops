# Reusable workflows

All workflows support `workflow_call` (and `workflow_dispatch` where noted).
Top-level `permissions: {}` (CI-025); jobs grant least privilege. Secret-using
jobs skip when `github.event.pull_request.user.login == 'dependabot[bot]'`
(CI-024). Do not compare `github.actor`. Nested script checkout uses
`actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1` (v7.0.1) with
`persist-credentials: false` and `ref: scripts_ref` (CI-034). Cross-repo
callers must pass `scripts_ref` equal to the `uses:` pin.

Shared inputs:

| Input | Type | Default | Notes |
|-------|------|---------|-------|
| `library_path` | string | (required on most) | Library root relative to the caller checkout |
| `blocking` | bool | `false` | `false` → collect-then-fail stays advisory (`ADVISORY=true`); missing tools/thresholds always fail |
| `scripts_ref` | string | `""` | Commit SHA matching the `uses:` pin. Required for cross-repo callers (CI-034). |
| `checkout_token` (secret) | string | — | PAT with `contents:read` on `pirlruc/cppdevops` for quality/tests/docs/codeql/dynamic/mobile/fuzz, and on `commondevops` for security/infra |

Consumers pin `pirlruc/cppdevops/.github/workflows/<name>.yml@<sha-or-tag>`
(`CI-018`). Prefer `@<sha>` or an annotated release tag over `@main`.

Thresholds for C++ gates come from
`docs/guardrails/cpp/profile.thresholds.yml`, vendored as
`scripts/cpp.profile.thresholds.yml` for sparse-checkout CI (CPPD-WF-001).

---

## `cpp-quality.yml`

clang-format, cpplint, clang-tidy, cppcheck, lizard, Metrix++.

| Input | Default | Notes |
|-------|---------|-------|
| `library_path` | required | |
| `blocking` | `false` | |

Numeric gates (CCN, coverage) come from `scripts/cpp.profile.thresholds.yml`
(CI-021/022). Job runs in
`container: ghcr.io/pirlruc/ci-cpp@sha256:3406477bb7fc730c53df4a28dffa07a9dce5ee6f6830102df1bedc8727973b67`
(same digest on `cpp-tests`, `cpp-docs`, `cpp-dynamic`, `cpp-codeql`).

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
The memcheck step runs valgrind on each discovered `*test*` binary and **fails
closed** when valgrind is missing or no test binary exists (`CI-035`) — it
must not pass green as a `ctest -T memcheck` no-op.

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

## `cpp-fuzz.yml`

Builds one CMake target with `-fsanitize=fuzzer,address` and runs it for
`fuzz_seconds`. `run_fuzz` defaults to false, which skips the job when the
library has no fuzz target (CPPD-FUZZ-001).

| Input | Default |
|-------|---------|
| `library_path` | required |
| `fuzz_target` | `""` |
| `fuzz_seconds` | `30` |
| `run_fuzz` | `false` |
| `blocking` | `false` |
| `scripts_ref` | `""` |

---

## `cpp-mobile-matrix.yml`

Cross-compiles `scripts/mobile-smoke/smoke.cpp` on Android NDK (`min_ndk`) and
iOS Xcode (`min_xcode`) with clang + libc++ (MOBILE-MECH-001). This is C++/NDK
and Xcode only. Kotlin, Gradle, Compose, and Swift stay in the product
repository (CPPD-MOBILE-002, CPPD-PIN-002).

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

## `ci-cpp-image.yml` (caller)

Thin caller into containerdevops for lint/build/scan/publish of `docker/ci-cpp`.
Triggers (same shape as commondevops `ci-lint-image.yml`):

| Trigger | Behaviour |
|---------|-----------|
| `release: published` | Build + publish |
| `schedule` (monthly, 20th 05:17 UTC) | Rebuild within `ci_image_max_age_days` (CI-027) |
| `pull_request` → `main` (paths: `docker/ci-cpp/**`, workflow) | Lint/build/scan only |
| `workflow_dispatch` | Optional `blocking` / `publish` |

Secrets: `CONTAINERDEVOPS_READ_TOKEN`, `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.
Size gate `size_class: ci_toolchain` (DOCKER-PERF-002, `ci_image_max_size_mb` 2000).
Private repo: `sign` is false (SC-SIGN-001 / SC-PROV-001 deviations).

## `cppdevops-ci.yml` (self)

`push` / `pull_request` on `main` plus `workflow_dispatch`. Calls commondevops
`common-infra-lint` and runs `scripts/check-threshold-drift.sh`. Secret-backed
jobs skip Dependabot (CI-024). The token-free `pins` job still runs.

## `cppdevops-security.yml` (scheduled)

Weekly Wednesday 06:17 UTC (staggered vs commondevops Mon / containerdevops Tue)
plus `workflow_dispatch`. Secrets/SAST + supply-chain via commondevops; published
`ci-cpp` rescan via containerdevops at the same digest as reusable workflow
`container:` pins (`ghcr.io/pirlruc/ci-cpp@sha256:cf40f3bc…`, not `:latest`).

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
