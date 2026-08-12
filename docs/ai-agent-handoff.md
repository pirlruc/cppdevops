# AI Agent Handoff — cppdevops

## Identity

| Field | Value |
|-------|-------|
| **Folder** | `cpp/cppdevops/` |
| **Remote** | https://github.com/pirlruc/cppdevops |
| **Branch** | `feature-dependency-update-policy` |
| **Role** | Reusable GitHub Actions workflows + C++ library bootstrap templates/scripts + `ci-cpp` image |
| **Type** | CI infrastructure (not a C++ library) |

## Scope

Owns reusable workflows under `.github/workflows/`:

- `cpp-quality.yml`, `cpp-tests.yml`, `cpp-docs.yml`, `cpp-dynamic.yml`, `cpp-codeql.yml`
- `cpp-security.yml` → thin forwarder to commondevops secrets-sast + supply-chain
- `cpp-infra.yml` → thin forwarder to commondevops common-infra-lint
- `cpp-mobile-matrix.yml` (placeholder; deviations recorded)

Also owns `templates/`, `scripts/sync-library-*.sh`, and `docker/ci-cpp/`.

Standalone library callers should pin `pirlruc/cppdevops@1.0.0` or `@<sha>` (`CI-018`).

Contract reference: [`docs/workflows.md`](workflows.md).

## Pins (2026-08-12)

| Submodule / artifact | Pin |
|----------------------|-----|
| `docs/guardrails` | `5a7ac83` (main tip after ci-base → ci-lint/ci-supply-chain; tag `1.1.0` is older) |
| `.github/scaffold` | `f8a6ba1` (main tip) |
| `ghcr.io/pirlruc/ci-cpp` | local `:local` built (rootfs **1065 MB** via `du -sxm /`); publish via `ci-cpp-image.yml` on release |
| commondevops `uses:` | tag **4.0.0** → `e4e902e62c35aa7e546536a0ba5a7782e377128e` |
| containerdevops `uses:` | tag **2.4.0** → `ea908fd0feb87ab6615b71f5af1cce0637a6567b` |

Open companion PRs (not merged): [guardrails #58](https://github.com/pirlruc/guardrails/pull/58),
[github-scaffold #37](https://github.com/pirlruc/github-scaffold/pull/37),
[methodologies #49](https://github.com/pirlruc/methodologies/pull/49).

## Delivery status

| Phase / epic | Status |
|--------------|--------|
| Phase 1 — CONS-* | Done |
| Phase 2 — GATE/COV/CI-TRIGGER/TOOL-CFG/DOC/DYN/SEC-MECH-001…004/INFRA/CI-001 | Done (authored) |
| MOBILE-MECH-001 | Open (placeholder + deviations CI-014 / CPP-BUILD-010/011) |
| DEP-MECH-001 | T1 done (registries + cooldown); T2 Insights after default-branch land |
| AIREV-MECH-001 | Done — appended CPPD-* epics |
| CPPD-IMG-001 / IMG-002 / WF-001 / WF-002 / CI-001 / REL-001 / ECO-001 | Open |
| `run_sbom` default | **true** (SC-SBOM-001) |

## Mobile toolchain pins (`CPP-BUILD-012`)

| Pin | Value | Review |
|-----|-------|--------|
| `MIN_ANDROID_NDK_VERSION` | 26.1.10909125 | 2027-01-01 |
| `MIN_XCODE_VERSION` | 15.4 | 2027-01-01 |

(Also defaults on `cpp-mobile-matrix.yml` inputs `min_ndk` / `min_xcode`.)

## Commands

```bash
docker build -t ghcr.io/pirlruc/ci-cpp:local docker/ci-cpp
./scripts/sync-library-tooling.sh /path/to/library
./scripts/sync-library-devcontainer.sh /path/to/library <cmake-target> [display-name]
./scripts/generate-doxyfile.sh /path/to/library
python3 .github/scaffold/scripts/issues-sync.py \
  --repo pirlruc/cppdevops --yaml docs/issues.yml --dry-run
```

## Known pitfalls

- **`ghcr.io/pirlruc/ci-cpp` is unpublished** — every `container:` job fails at startup until CPPD-IMG-002.
- Thresholds are vendored at `scripts/cpp.profile.thresholds.yml` (drift-check via `scripts/check-threshold-drift.sh`).
- Mobile matrix is echo-only — see `docs/guardrail-deviations.yml` and MOBILE-MECH-001.
- Seven consumer libraries still pin `@main` (CPPD-ECO-001 / CI-018 on their side).
- Private nested checkout needs a PAT when private.

## Suggested next work

1. CPPD-WF-001 / WF-002 — vendor thresholds + gate correctness.
2. CPPD-IMG-001 / IMG-002 — redesign + publish `ci-cpp`.
3. CPPD-CI-001 — self-CI + local parity scripts.
4. MOBILE-MECH-001 — real NDK/Xcode smoke; clear deviations.
5. Annotated tag **2.0.0** + digest-pin `container:` refs.
6. DEP-MECH-001-T2 Insights after merge to `main`.

## See also

- [workflows.md](workflows.md)
- [README.md](../README.md)
- [CHANGELOG.md](../CHANGELOG.md)
- [commondevops](https://github.com/pirlruc/commondevops)
- [containerdevops](https://github.com/pirlruc/containerdevops)
- [guardrails](https://github.com/pirlruc/guardrails)

*Last updated: 2026-08-12*
