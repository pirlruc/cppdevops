# C++ Org Profile (Central Defaults)

Org-default tools and thresholds for C++ repositories. Numeric gates: [`profile.thresholds.yml`](profile.thresholds.yml). Principles: [`guardrails.md`](guardrails.md).

Repositories adopt this profile by default. Deviations follow the rule in [`../README.md`](../README.md).

## Fixed baseline (no deviation)

| Area | Value |
|------|-------|
| C++ standard | C++20 only |
| Compiler | Clang >= 18 |
| Standard library | libc++ |
| Supported platforms | Linux (dev/CI), iOS, Android |
| Dev OS | Ubuntu 24.04 LTS (local required; CI parity recommended) |
| Formatter | `clang-format` + `.clang-format` |
| Infra tooling | `.editorconfig`, devcontainer, `pre-commit`, documented bootstrap |
| Tool configs | In-repo canonical config per adopted tool (shared by local, pre-commit, CI) |

## Predetermined tools and thresholds

| Category | Org default | Deviation |
|----------|-------------|-----------|
| Host-vs-target libc++ | Local may use upstream LLVM libc++; CI validates target platform libc++ variants (Linux, iOS, Android) | Compensating validation required |
| Warning profile | `-Wall -Wextra -Wpedantic` + curated Clang warnings | Record if different |
| CI warnings-as-errors | Enabled on protected branches | Record if disabled |
| Local warnings-as-errors | Disabled by default; opt-in target available | Allowed |
| Warning suppressions | Targeted only, with rationale comment | No deviation |
| Static analysis | `clang-tidy` + `cppcheck` + `cpplint` | Equivalent coverage required |
| Security SAST | `semgrep` (CI + pre-commit) | Equivalent SAST required |
| Secret scan | `gitleaks` (CI + pre-commit); block on verified secrets | Rare; compensating control |
| Code metrics | Metrix++ + clang-tidy metric/readability checks | Partial opt-out with record |
| Complexity | lizard CCN < `max_cyclomatic_complexity` | Stricter allowed |
| Maintainability | Metrix++ MI >= `min_maintainability_index` | Stricter allowed |
| Unit tests | Google Test + Google Mock (CMake/CTest) | Equivalent capability required |
| Statement coverage | >= `statement_coverage`% per module | Lower requires ADR |
| Branch coverage | >= `branch_coverage`% per module | Lower requires ADR |
| API documentation | >= `doc_coverage`% (Doxygen + coverxygen) | Lower requires record |
| Docs CI gate | Blocking on protected branches | Record if advisory |
| Dynamic analysis | valgrind memcheck — zero definite leaks (host-native) | Equivalent required |
| Dependency vuln scan | Grype — block High/Critical; Trivy advisory | Rare |
| SBOM | Syft on release/merge pipelines | Record if omitted |
| Lint blocking | Block on all errors | Weaker requires record |
| Quality exception authority | Engineering Lead | Role definition |

## Tool config mapping

| Tool / category | Config file(s) |
|-----------------|----------------|
| Editor | `.editorconfig` |
| Formatting | `.clang-format` |
| Pre-commit | `.pre-commit-config.yaml` |
| Static analysis | `.clang-tidy`, `cppcheck-suppressions.xml` |
| Security SAST | `.semgrep.yml` and/or `.semgrep/` |
| Secret scan | `.gitleaks.toml` |
| Code metrics | Metrix++ project config + `.clang-tidy` metric checks |
| Build (library root) | `CMakeLists.txt` |
| Configure/build presets | `CMakePresets.json` (`sourceDir: .` for standalone repos) |
| Dependency manifest | `vcpkg.json`, optional `vcpkg-configuration.json` |
| Shared CMake helpers | `cmake/*.cmake` (vendored or fetched) |
| Tests | CTest targets in `CMakeLists.txt` / `test/` |
| Dev container | `.devcontainer/devcontainer.json` (+ optional `Dockerfile`) |
| Package export | `cmake/*Config.cmake.in`, `*.pc.in` when installable |
| Agent/reviewer context | `docs/ai-agent-handoff.md`, `docs/improvements.md` (recommended) |
| Central guardrails | `docs/guardrails/` git submodule (pinned SHA) |
| Complexity | lizard config or CI scope definition |
| Documentation | Doxygen config + coverxygen integration |

## Repo-set values (define in consuming repository)

These are not org-fixed; each repo documents its choice:

- CMake preset names and local lint/test commands
- Bootstrap command documented in `README.md` (must work from repo root without a parent monorepo)
- Mobile toolchain pins (`MIN_ANDROID_NDK_VERSION`, `MIN_XCODE_VERSION`) when targeting iOS/Android
- Platform matrix deviations (e.g. dropping Windows support)
- Cross-boundary dependency approval workflow
- PR size hard limit (soft limit: `pr_size_soft_limit_lines` in thresholds file)
- Escalation SLA and guardrail calibration cadence

## Deviation record (inline template)

```markdown
## Deviation: <item>

- **Org default:** <value from profile or thresholds.yml>
- **Repo value:** <new value>
- **Why:** <rationale>
- **Owner:** <name/role>
- **Review date:** YYYY-MM-DD
```

Lowering `statement_coverage`, `branch_coverage`, or `doc_coverage` below org defaults requires an ADR.
