# Kotlin Org Profile (Central Defaults)

Numeric gates: [`profile.thresholds.yml`](profile.thresholds.yml). Principles: [`guardrails.md`](guardrails.md).

## Predetermined tools (recommended)

| Category | Org default |
|----------|-------------|
| Formatter | `ktlint` |
| Static analysis | `detekt` |
| Android lint | `lint` (when Android module) |
| Unit tests | JUnit + Kotlin test |
| Coverage | Kover |
| Statement coverage | >= `statement_coverage`% per module |
| Branch coverage | >= `branch_coverage`% per module |
| Secret scan | `gitleaks` |
| Security SAST | `semgrep` |

## Deviation rule

See [`../README.md`](../README.md). Lowering coverage gates requires an ADR.
