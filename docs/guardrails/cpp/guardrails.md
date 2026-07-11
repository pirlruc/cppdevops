# C++ Guardrails (Generic)

Repository-agnostic principles for C++ projects. Tools and thresholds: [`profile.md`](profile.md). Numeric gates: [`profile.thresholds.yml`](profile.thresholds.yml).

## Build & Toolchain

- Target **C++20** (`CMAKE_CXX_STANDARD 20`). C++23/C++26 out of baseline until governance approves.
- Primary compiler: **Clang >= 18**. Standard library: **libc++** on all supported platforms.
- **Supported compilation targets:** Linux (host/dev/CI reference), iOS, Android. Windows is not in the org baseline; repos that drop Windows must record the deviation.
- Development reference OS: **Ubuntu 24.04 LTS** (CI parity recommended; deployment containers unrestricted).
- Use target-based CMake; centralize compile/link policy in shared modules.
- Each **publishable library** is its own git repository with a root-level `CMakeLists.txt`, `CMakePresets.json`, and `.devcontainer/` (see [Standalone library repository](#standalone-library-repository)).
- Reproducible configure/build/test presets for local and CI parity.
- All PRs must remain buildable on protected branches.

### Platform matrix (Linux, iOS, Android)

| Platform | Role | Compiler | Standard library |
|----------|------|----------|------------------|
| Linux | Dev + CI reference | Clang >= 18 | libc++ |
| iOS | Deployment | Xcode (repo-pinned min version) | libc++ |
| Android | Deployment | NDK Clang (repo-pinned min version) | libc++ |

Repos document mobile toolchain pins (`MIN_ANDROID_NDK_VERSION`, `MIN_XCODE_VERSION`) in their specific guardrails.

### Mobile profile (when targeting Android or iOS)

- Treat C++20 as partially implemented on mobile toolchains; verify against pinned NDK/Xcode status pages.
- Do not use features marked unsupported for pinned toolchains.
- Prefer `__cpp_*` feature-test macros when availability is toolchain-dependent.

### Standalone library repository

When an organization ships multiple C++ libraries as **separate git repositories**, each library repo is the canonical unit for build, test, CI, and onboarding.

**Required at repository root (each library):**

| Artifact | Purpose |
|----------|---------|
| `CMakeLists.txt` | Standalone `project()` and library target(s) |
| `CMakePresets.json` | Configure/build presets with `sourceDir: .` |
| `vcpkg.json` | Dependency manifest scoped to this library only |
| `.devcontainer/` | Dev container; workspace root is the library repo (no parent monorepo mount) |
| Tooling configs | `.clang-format`, `.clang-tidy`, `.cpplint`, `.editorconfig`, `.gitleaks.toml`, `.pre-commit-config.yaml` |
| `LICENSE`, `README.md`, `.gitignore` | Legal and bootstrap documentation |

**Recommended:**

| Artifact | Purpose |
|----------|---------|
| `cmake/*.cmake` | Vendored shared CMake helpers until a shared modules repo exists |
| `docs/ai-agent-handoff.md` | Scope, allowed/forbidden dependencies, migration state |
| `docs/improvements.md` | Library-owned backlog |
| `docs/guardrails/` | Git submodule → central guardrails repo, pinned by SHA |
| `.github/workflows/` | Thin CI callers pinning org reusable workflows by SHA |

**Dependency rules after split:**

- Consume sibling libraries via `find_package()`, vcpkg registry, or pinned `FetchContent` — not `add_subdirectory(../sibling)`.
- Record repo-specific deviations (platform matrix, toolchain pins) in the consuming repo's guardrails delta doc — not in the central guardrails repo.

**Monorepo (optional, transitional):** a private integration workspace may aggregate library checkouts via `add_subdirectory`. Root-level tooling duplicates in such a workspace are not canonical; each library repo must remain independently buildable.

## Formatting & Static Analysis

- Enforce formatting and static analysis in CI with equivalent local commands.
- Run header-aware analyzers on translation units when standalone header scans produce false positives.
- Keep production code warning-clean; block on agreed severity threshold.
- Exceptions require owner, rationale, and expiry.

## Complexity & Maintainability

- Enforce cyclomatic complexity and maintainability-index gates on production sources.
- Collect structural metrics (coupling, size) in CI and local workflows.

## Testing & Coverage

- Require a unit test framework; tests executable locally and in CI via CMake/CTest.
- Require automated tests for new behavior and bug fixes.
- Enforce per-module/component coverage thresholds (not aggregate-only).
- Define flaky-test handling and quarantine rules.
- Local and CI test execution must use the same entrypoint.

## Dynamic Analysis

- Run memory-safety dynamic analysis (e.g. valgrind memcheck) on host-native test suites where applicable.
- Block on definite leaks in gated paths.

## API & Architecture

- Define explicit library/module boundaries and ownership for each public component.
- Prefer independent top-level namespaces per library; avoid a shared root namespace unless justified.
- Public headers expose stable, intentional contracts only.
- New cross-boundary dependencies require explicit justification.
- Breaking changes allowed only with migration documentation.
- Retain wrappers over std/external APIs only when they add functionality or ergonomics beyond the underlying library.

## Generic Programming & Type Safety

- Use concepts/constraints for public templates where they improve correctness and diagnostics.
- Avoid over-generic abstractions that reduce readability without safety benefit.

## Performance & Reliability

- Performance changes require profiling evidence or benchmarks on critical paths.
- Use modern value semantics where meaningful (`move`, `constexpr`, `final`, const-correctness).
- Concurrency changes must document thread-safety model and invariants.

## Documentation

- Public API documentation must meet the repository threshold (see `profile.thresholds.yml`).
- Architecture docs per major component: scope, allowed/forbidden dependencies, extension points.
- Documentation checks should run in CI.

## Security & Supply Chain

- Secret scanning required in CI and pre-commit.
- Security SAST in CI and local hooks.
- Dependency vulnerability scanning and SBOM generation for supply-chain visibility.
- New external dependencies require rationale, owner, and security/license review.

## CI/CD & DevOps

See [`../ci/guardrails.md`](../ci/guardrails.md) for cross-language CI principles. Repo-specific workflow inventory, cache keys, and action pins stay in each consuming repository.

## Delivery & Change Management

- Keep changes small and reviewable.
- Require rollback or mitigation note for risky changes.
- Track technical debt from exceptions with owner and due date.

## References

- [Clang C++20 status](https://clang.llvm.org/cxx_status.html#cxx20)
- [libc++ C++20 status](https://libcxx.llvm.org/docs/Status/Cxx20.html)
- [Android NDK C++ support](https://developer.android.com/ndk/guides/cpp-support)
- [Apple Xcode C++20 support](https://developer.apple.com/xcode/cpp/)
