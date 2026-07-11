# Python Guardrails (Generic)

Repository-agnostic principles for Python projects. Org defaults: [`profile.md`](profile.md).

## Runtime & Tooling

- Define supported Python versions and package manager baseline.
- Enforce formatter, linter, and type-checker in CI with local parity.

## Code Quality

- Block on agreed lint/type severity; exceptions require owner, rationale, and expiry.

## Testing & Coverage

- Require automated tests for new features and bug fixes.
- Enforce per-module coverage thresholds (see `profile.thresholds.yml` when defined).
- Define flaky-test and quarantine policy.

## API & Architecture

- Public API changes require migration notes.
- Cross-module boundary changes require explicit rationale.

## Performance & Reliability

- Performance-impacting changes require profiling or benchmark evidence.
- Async/concurrency changes must document threading/event-loop assumptions.

## Security & Supply Chain

- New dependencies require owner and security/license review.
- Enforce vulnerability and secret scanning in CI.

## Documentation & Delivery

- Meet minimum API/doc coverage threshold.
- Keep PRs small and focused; rollback notes for risky changes.

## Governance

- Escalation SLA and quality exception authority defined per org process.
