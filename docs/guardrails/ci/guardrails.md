# CI/CD Guardrails (Generic)

Cross-language CI/CD principles. Repo-specific workflow inventory, cache keys, timeouts, and action pins belong in each consuming repository.

## Principles

| Principle | Rationale |
|-----------|-----------|
| Pin third-party action versions by commit SHA | Immutable references survive tag moves and supply-chain retags |
| Use workflow concurrency groups | Cancel superseded runs on the same branch or PR |
| Set explicit job timeouts | Prevent hung runners from blocking the queue |
| Cache dependencies with content-addressed keys | Speed up CI without stale artifacts after lockfile changes |
| Fail fast on security gates | Block merges when High/Critical findings are unreviewed |
| Separate quality, test, docs, and security workflows | Narrow blast radius and parallelize feedback |
| Document cache invalidation inputs | CMake hashes, lockfiles, and tool pins must be obvious |
| Provide local CI parity commands | Same gates runnable locally before push |

## Workflow categories

Each repository should define separate workflows (or equivalent jobs) for:

1. **Quality** — formatting, lint, static analysis, complexity metrics
2. **Tests & coverage** — unit tests, coverage gates (read thresholds from `<lang>/profile.thresholds.yml`)
3. **Documentation** — API doc generation and coverage checks
4. **Security** — secret scan, SAST, dependency review, SBOM/vuln scan

## Multiplatform build matrix

For C++ repositories targeting Linux, iOS, and Android:

- Host-native CI (Linux) is the primary reference for quality gates, coverage, and dynamic analysis.
- Mobile builds (iOS, Android) validate clang + libc++ compatibility on pinned toolchains.
- Document the platform matrix and toolchain pins in repo-specific guardrails.
- Retire platform-specific workflows (e.g. Windows MSVC/MinGW) when a repo drops that platform; record the deviation.
- Cache keys must include platform/toolchain identifiers when matrix builds share runners.

## Shared reusable workflows

Organizations may publish **`workflow_call`** workflows in a dedicated repository (for example `org/cppdevops`):

- Each **library repository** keeps thin caller workflows that pin the shared repository at a **commit SHA** or semver tag.
- Do not copy shared job bodies into every library repo; update pins deliberately with changelog review.
- Caller inputs name the library path (typically `.` for standalone repos) and whether jobs are blocking.
- Numeric gates: read from vendored `docs/guardrails/<lang>/profile.thresholds.yml`, or pass a pinned guardrails SHA as a workflow input.

## Threshold consumption

CI jobs that enforce numeric gates must read from the language `profile.thresholds.yml`. Repo overlays (justified deviations) merge on top of central defaults.

## References

- [GitHub Actions — security hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- heimdall reference: `docs/guardrails/generic/ci.md` (seed source for this document)
