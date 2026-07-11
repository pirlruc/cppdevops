# Swift Guardrails (Generic)

Repository-agnostic principles for Swift/iOS projects. Org defaults: [`profile.md`](profile.md).

## Language & Toolchain

- Target **Swift 6**; repositories not yet on Swift 6 must define a migration plan.
- **Xcode/xcodebuild** required for reproducible local and CI workflows.
- **SPM** required for dependencies; CocoaPods repos must define migration to SPM.

## iOS Platform

- Minimum Xcode and iOS deployment targets per org profile.
- Platform API usage must be availability-annotated (`@available`, `if #available`).

## Developer Environment

- macOS required for local development and CI build/test gates.
- `.editorconfig`, `pre-commit`, `SwiftFormat` with in-repo config required.

## Static Analysis & Linting

- Enforce formatting and static analysis in CI with local parity.
- Block on agreed severity; exceptions require owner, rationale, and expiry.

## Testing & Coverage

- Require tests for new behavior and bug fixes.
- Enforce per-module coverage thresholds via Xcode coverage reporting.
- Define flaky-test and quarantine policy.

## API & Architecture

- Define explicit module boundaries and ownership.
- Breaking changes require migration documentation.
- Concurrency model changes (actors/tasks) require safety notes.

## Performance & Reliability

- Performance changes require profiling or benchmark evidence.
- Rollback notes for risky changes.

## Security & Supply Chain

- Secret scanning in CI and pre-commit.
- New dependencies require owner and security/license review.

## Documentation & Delivery

- Public API documentation meets threshold; docs checks in CI.
- Keep PRs small and reviewable.
