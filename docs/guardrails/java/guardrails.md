# Java Guardrails (Generic)

Repository-agnostic principles for Java projects. Org defaults: [`profile.md`](profile.md).

## Language & Build

- Define Java LTS version support and build system baseline (Maven/Gradle).
- Enforce formatter, linter, and static analysis in CI with local parity.

## Code Quality

- Block on agreed quality findings; exceptions require owner and expiry.

## Testing & Coverage

- Require unit/integration tests for behavior changes and bug fixes.
- Enforce per-module coverage thresholds.
- Define flaky-test handling.

## API & Architecture

- Public API changes require migration and compatibility notes.
- Module/service boundary changes require architecture rationale.
- Concurrency changes must include thread-safety notes.

## Security & Supply Chain

- New dependencies require owner and security/license review.
- Enforce vulnerability and secret scanning in CI.

## Performance & Reliability

- Performance-sensitive changes require benchmark/profiling evidence.
- Reliability-impacting changes include rollback/mitigation plan.

## Documentation & Delivery

- Meet API/documentation threshold; keep PRs focused.
