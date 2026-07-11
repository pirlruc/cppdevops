# Kotlin Guardrails (Generic)

Repository-agnostic principles for Kotlin projects. Org defaults: [`profile.md`](profile.md).

## Language & Build

- Define Kotlin/JDK target versions and build tool baseline (Gradle).
- Enforce formatter, linter, and static analysis in CI with local parity.

## API Design

- Prefer immutable `data class` models with `val` fields for result/config surfaces.
- Keep API changes backward compatible unless a versioned breaking change is intentional.

## Concurrency

- Use structured concurrency (`coroutineScope`, `async`, `withContext`); avoid global scopes.
- Keep suspend APIs explicit about dispatcher behavior and thread expectations.

## Testing & Coverage

- Require tests for new behavior and regressions.
- Enforce per-module line + branch coverage gates.
- Define flaky-test and determinism policy.

## API & Architecture

- Public API changes require compatibility/migration notes.
- Module boundary changes require rationale and ownership.

## Performance & Reliability

- Avoid unnecessary allocations in hot paths; prefer reuse where safe and measurable.
- Performance-sensitive changes require benchmark/profiling evidence.

## Security & Supply Chain

- New dependencies require owner and security/license review.
- Enforce vulnerability and secret scanning in CI.

## Documentation & Delivery

- Meet API/documentation threshold; docs checks in CI.
- Keep PRs small and focused.
