# Python Org Profile (Central Defaults)

Numeric gates: [`profile.thresholds.yml`](profile.thresholds.yml). Principles: [`guardrails.md`](guardrails.md).

## Predetermined tools (recommended)

| Category | Org default |
|----------|-------------|
| Formatter/linter | `ruff` (format + lint) |
| Type checking | `mypy` or `pyright` |
| Unit tests | `pytest` |
| Secret scan | `gitleaks` |
| Security SAST | `semgrep` |
| Statement coverage | >= `statement_coverage`% per package |
| Branch coverage | >= `branch_coverage`% per package |

Repos define Python version support, virtualenv/poetry/uv choice, and local commands in their specific guardrails note.

## Deviation rule

See [`../README.md`](../README.md). Lowering coverage gates requires an ADR.
