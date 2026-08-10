# Platform and CI deltas (Nordic C++ libraries)

Org defaults live in the pinned [`docs/guardrails/`](../docs/guardrails/) submodule ([pirlruc/guardrails](https://github.com/pirlruc/guardrails)). This note records **shared consumer deltas** for pirlruc C++ libraries and CI callers in this repo. Cite Guardrail IDs in Epics when lowering a gate.

## Platform matrix

| Platform | Role | Compiler | Standard library | C++ standard |
|----------|------|----------|------------------|--------------|
| Linux (Ubuntu 24.04 LTS) | Dev + CI reference | Clang >= 18 | libc++ | C++20 |
| iOS | Deployment | Xcode (see pin) | libc++ | C++20 |
| Android | Deployment | NDK Clang (see pin) | libc++ | C++20 |
| Windows | **Not supported** | — | — | — |

### Mobile toolchain pins

| Pin | Value | Review date |
|-----|-------|-------------|
| `MIN_ANDROID_NDK_VERSION` | 26.1.10909125 | 2027-01-01 |
| `MIN_XCODE_VERSION` | 15.4 | 2027-01-01 |

### Deviation: Windows dropped

| Guardrail / item | Org default | Consumer value | Why | Review |
|------------------|-------------|----------------|-----|--------|
| Platform support (`CI-*` / platform matrix) | Not Windows-only centrally | Linux/iOS/Android only | Align with Clang + libc++; avoid MSVC/MinGW matrix | 2027-01-01 |

Windows MSVC/MinGW CI workflows are **retired**.

## Quality gates (org defaults — do not restate locally)

See `docs/guardrails/cpp/profile.thresholds.yml`: statement/branch/doc coverage **95%**, CCN **&lt; 10**, MI **≥ 40**. Tooling and CI principles: `cpp/profile.md`, `ci/guardrails.md`.

## Architecture expectations for library repos

- Independent top-level namespaces per library; no shared `improc::` root.
- Standalone repo layout: `CMakeLists.txt`, `CMakePresets.json`, `.devcontainer/`, `docs/{ai-agent-handoff,improvements}.md`, `docs/guardrails/` + `.github/scaffold/` submodules.
- CI callers: prefer `pirlruc/cppdevops/.github/workflows/*.yml@<sha>` (`CI-018`).
- Mobile matrix: `cpp-mobile-matrix.yml` where required (`CI-014`).
- Dynamic analysis: libraries ship CMake preset `ci-asan`; `cpp-dynamic.yml` configures via `cmake --preset ci-asan` (`CPP-DYN-001`).
- SBOM / vuln scans (`CPP-SEC-003`): `cpp-security.yml` input `run_sbom` defaults to `true` (SC-SBOM-001). Set `run_sbom: false` only with a recorded deviation when a library cannot afford SBOM on every run.

## External dependency policy (shared)

| Dependency | Status |
|------------|--------|
| spdlog | Keep |
| nlohmann/json | Replace jsoncpp |
| OpenCV | Keep (trimmed modules) |
| Eigen3 | Keep |
| zxing-cpp | Keep |
| freetype | Keep |
| pipes | Drop |
| nayuki-qr-code-generator | Drop if zxing covers QR |
| gtest | Keep (tests) |

## Bootstrap tooling (this repo)

Canonical C++ library bootstrap templates and scripts:

- `templates/cpp/` — clang/format/tidy, pre-commit, gitleaks, standalone presets + devcontainer, `Doxyfile.in`
- `templates/cmake/pirlruc_library.cmake`
- `scripts/sync-library-tooling.sh <lib-path>`
- `scripts/sync-library-devcontainer.sh <lib-path> <cmake-target> [display-name]`
- `scripts/generate-doxyfile.sh <lib-path>`

Issue/PR templates remain in [pirlruc/github-scaffold](https://github.com/pirlruc/github-scaffold).
