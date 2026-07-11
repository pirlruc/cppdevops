# Java Org Profile (Central Defaults)

Numeric gates: [`profile.thresholds.yml`](profile.thresholds.yml). Principles: [`guardrails.md`](guardrails.md).

## Predetermined tools (recommended)

| Category | Org default |
|----------|-------------|
| Build | Gradle (Kotlin DSL) or Maven |
| Formatter/linter | Spotless + Checkstyle or equivalent |
| Static analysis | SpotBugs / Error Prone |
| Unit tests | JUnit 5 |
| Statement coverage | >= `statement_coverage`% per module |
| Branch coverage | >= `branch_coverage`% per module |
| Secret scan | `gitleaks` |
| Security SAST | `semgrep` |

## Deviation rule

See [`../README.md`](../README.md). Lowering coverage gates requires an ADR.
