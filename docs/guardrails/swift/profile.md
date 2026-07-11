# Swift Org Profile (Central Defaults)

Numeric gates: [`profile.thresholds.yml`](profile.thresholds.yml). Principles: [`guardrails.md`](guardrails.md).

## Fixed baseline

| Area | Value |
|------|-------|
| Swift language | Swift 6 |
| Package manager | SPM (CocoaPods migration required for legacy) |
| Dev OS | macOS |
| Formatter | SwiftFormat + `.swiftformat` |
| Minimum Xcode | 26 |
| Minimum iOS deployment | 15.0 |

## Predetermined tools

| Category | Org default |
|----------|-------------|
| Static analysis | SwiftLint + compiler warnings |
| Unit tests | XCTest via `xcodebuild test` |
| Coverage | Xcode coverage + `xcresultparser` |
| Statement coverage | >= `statement_coverage`% (line coverage) |
| Secret scan | `gitleaks` |
| Security SAST | `semgrep` |

## Deviation rule

See [`../README.md`](../README.md). Lowering coverage gates requires an ADR.
