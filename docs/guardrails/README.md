# Central Guardrails (publish to `pirlruc/guardrails`)

This folder contains language-agnostic guardrails and org-default profiles intended for the central repository: [pirlruc/guardrails](https://github.com/pirlruc/guardrails).

## Adoption model

1. **Link, don't duplicate.** Consuming repositories reference these docs (vendored copy or pinned git submodule at `docs/guardrails/`).
2. **Inherit the profile.** Adopt `profile.md` tools and thresholds by default; read numeric gates from `profile.thresholds.yml` in CI.
3. **Record only deltas.** Repo-specific choices and justified threshold deviations go in the consuming repo's own guardrails note — not here.
4. **One repo per library.** Publishable C++ libraries are standalone git repositories; link central guardrails via submodule at `docs/guardrails/` (see [`cpp/guardrails.md`](cpp/guardrails.md#standalone-library-repository)).

## Layout

| Path | Purpose |
|------|---------|
| `<lang>/guardrails.md` | Principles by verification category (what/why) |
| `<lang>/profile.md` | Org-default tools, config inventory, deviation rule |
| `<lang>/profile.thresholds.yml` | Machine-readable numeric gates (CI source of truth) |
| `ci/guardrails.md` | Generic CI/CD principles (repo-specific CI stays in each repo) |

## Deviation rule

Repos may change a threshold only with a recorded justification:

| Field | Required |
|-------|----------|
| Item | Threshold key or tool |
| Org default | Value from `profile.thresholds.yml` or `profile.md` |
| Repo value | New value |
| Why | Technical or operational rationale |
| Owner | Named maintainer |
| Review date | YYYY-MM-DD |

Lowering a gate below the org default requires an ADR. Stricter values need no approval.

## Languages

- `cpp/` — full profile (primary)
- `python/`, `kotlin/`, `swift/`, `java/` — principles + minimal profile stubs
- `ci/` — cross-language CI principles
