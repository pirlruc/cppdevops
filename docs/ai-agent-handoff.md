# AI Agent Handoff — cppdevops

## Identity

| Field | Value |
|-------|-------|
| **Folder** | `cpp/cppdevops/` |
| **Remote** | https://github.com/pirlruc/cppdevops |
| **Branch** | `main` (tag **2.1.0**) |
| **Role** | Reusable GitHub Actions workflows + C++ library bootstrap templates/scripts + `ci-cpp` image |
| **Type** | CI infrastructure (not a C++ library) |

## Scope

Owns reusable workflows under `.github/workflows/`:

- `cpp-quality.yml`, `cpp-tests.yml`, `cpp-docs.yml`, `cpp-dynamic.yml`, `cpp-codeql.yml`
- `cpp-security.yml` → thin forwarder to commondevops secrets-sast + supply-chain
- `cpp-infra.yml` → thin forwarder to commondevops common-infra-lint
- `cpp-mobile-matrix.yml` (real NDK/Xcode smoke compile)
- Self-CI: `cppdevops-ci.yml`, `cppdevops-security.yml`, `ci-cpp-image.yml`

Also owns `templates/`, `scripts/sync-library-*.sh`, and `docker/ci-cpp/`.

Standalone library callers should pin `pirlruc/cppdevops@2.1.0` or `@<sha>` (`CI-018`).
Never `@main`. Checklist: [`docs/consumer-checklist.md`](consumer-checklist.md).

Contract reference: [`docs/workflows.md`](workflows.md).

## Pins (2026-08-12)

| Submodule / artifact | Pin |
|----------------------|-----|
| `docs/guardrails` | `5a7ac83` (main tip after ci-base → ci-lint/ci-supply-chain; tag `1.1.0` is older). File-only bump later — do not move the gitlink in this wave. |
| `.github/scaffold` | `f8a6ba1` (main tip) |
| `ghcr.io/pirlruc/ci-cpp` | `@sha256:54ea6b2354709b742a3b1ae289b82c0cbb1ad9241d59ee06b94331ecf945d7f9` (tags `:latest` / `:20260812` / `:sha-3d09f6d`). Reusable `container:` and `cppdevops-security.yml` published rescan share this digest. |
| commondevops `uses:` | **`75d0fafc90fbef7bb118025437502ca2cf42a11e`** (post-4.0.0 #62: zizmor `-c`, `packages: read`) |
| containerdevops `uses:` | tag **3.0.2** → `3607bf0809c951d6d4b832d58f625a34eb3bb75b` |

Open companion PRs (not merged): [guardrails #58](https://github.com/pirlruc/guardrails/pull/58),
[github-scaffold #37](https://github.com/pirlruc/github-scaffold/pull/37),
[methodologies #49](https://github.com/pirlruc/methodologies/pull/49).

## Delivery status

| Phase / epic | Status |
|--------------|--------|
| Phase 1 — CONS-* | Done |
| Phase 2 — GATE/COV/CI-TRIGGER/TOOL-CFG/DOC/DYN/SEC-MECH-001…004/INFRA/CI-001 | Done |
| MOBILE-MECH-001 | Done (smoke TU; deviations CI-014 / CPP-BUILD-010/011 cleared) |
| DEP-MECH-001 | T1 done; T2 Insights after default-branch land |
| AIREV-MECH-001 | Done — appended CPPD-* epics |
| CPPD-IMG-001 / IMG-002 / WF-001 / WF-002 / CI-001 | Done on `main` |
| CPPD-REL-001 | Done — CHANGELOG 2.0.0 + annotated tag + GitHub Release |
| CPPD-ECO-001 | Done in yaml (checklist shipped; library pin bumps are still those repos) |
| CPPD-WF-003 | Done — digest docs, fail-closed memcheck (CI-035), security digest pin (`2.1.0`) |
| CPPD-PIN-001 | Open (filed; do not bump this wave) |
| Deviations remaining | DOCKER-PERF-001, SC-SIGN-001 |

## Mobile toolchain pins (`CPP-BUILD-012`)

| Pin | Value | Review |
|-----|-------|--------|
| `MIN_ANDROID_NDK_VERSION` | 26.1.10909125 | 2027-01-01 |
| `MIN_XCODE_VERSION` | 15.4 | 2027-01-01 |

## Commands

```bash
docker build -t ghcr.io/pirlruc/ci-cpp:local docker/ci-cpp
./scripts/check-ci-local.sh
./scripts/check-ci-docker.sh
./scripts/sync-library-tooling.sh /path/to/library
./scripts/sync-library-devcontainer.sh /path/to/library <cmake-target> [display-name]
./scripts/generate-doxyfile.sh /path/to/library
python3 .github/scaffold/scripts/issues-sync.py \
  --repo pirlruc/cppdevops --yaml docs/issues.yml --dry-run
```

## Known pitfalls

- **Wave 3 GitHub status drift:** MOBILE-MECH-001, AIREV-MECH-001, and
  DEP-MECH-001 are `done` in `docs/issues.yml`. GitHub issues
  [#27](https://github.com/pirlruc/cppdevops/issues/27),
  [#28](https://github.com/pirlruc/cppdevops/issues/28),
  [#36](https://github.com/pirlruc/cppdevops/issues/36),
  [#37](https://github.com/pirlruc/cppdevops/issues/37),
  [#38](https://github.com/pirlruc/cppdevops/issues/38), and
  [#39](https://github.com/pirlruc/cppdevops/issues/39) still need
  `issues-sync.py --update` after approval (dry-run first).
- **Dependabot Insights (DEP-MECH-001-T2):** no grouped `all-dependencies` PR
  yet after the multi-ecosystem config landed (monthly cadence). Re-check next cycle.
- **Dive efficiency:** `COPY --from=pybuild --chown=1000:1000 /opt/venv` dropped
  the extra `chown -R` layer. Local `ci-cpp:local` measured **97.11%**
  (`efficiencyScore` 0.971077…) vs org floor 95%. Host `dive` was missing;
  used `wagoodman/dive:v0.13.1`. Do not lower the gate.
- Reusable workflows and published rescan pin
  `container: ghcr.io/pirlruc/ci-cpp@sha256:54ea6b…` (CI-018). Do not float `:latest`.
- Threshold drift CI checks out `pirlruc/guardrails` with `GUARDRAILS_READ_TOKEN`
  (preferred) or `COMMONDEVOPS_READ_TOKEN` when that PAT also covers guardrails.
  Without either, the job soft-skips; run `scripts/check-threshold-drift.sh` locally.
  Do not use `submodules: true` with `github.token` (private clone 403/404).
- **Consumer pins (CI-018):** seven libraries still pin `@main`. See
  [`docs/consumer-checklist.md`](consumer-checklist.md). github-scaffold
  [`templates/ci-quality.yml`](https://github.com/pirlruc/github-scaffold/blob/main/templates/ci-quality.yml)
  still pins `cppdevops@1.0.0` while this repo is heading to **2.1.0** — consumers
  must bump; the scaffold seed is create-once. draupnir-cpp still has legacy
  CodeQL/Codacy/Ubuntu workflows to retire after the pin.
- The `docs/guardrails` pin (`5a7ac83`) does not yet include **CI-035**;
  `cpp-dynamic.yml` cites it anyway. File-only gitlink bump later — do not
  move the submodule in this wave.
- Private nested checkout needs a PAT when private.

## Suggested next work

1. `issues-sync.py` write to close GitHub CPPD-WF-003 / CPPD-ECO-001 and create CPPD-PIN-001 (dry-run first).
2. Bump the seven `@main` consumers and draupnir-cpp legacy retirement
   ([checklist](consumer-checklist.md)). Callers pin **2.1.0**.
3. Provision `GUARDRAILS_READ_TOKEN` (contents:read on `pirlruc/guardrails`) so threshold-drift CI stops soft-skipping.
4. CPPD-PIN-001 — re-pin `docs/guardrails` to annotated tag `1.6.0` and remediate gates.

## See also

- [workflows.md](workflows.md)
- [consumer-checklist.md](consumer-checklist.md)
- [README.md](../README.md)
- [CHANGELOG.md](../CHANGELOG.md)
- [commondevops](https://github.com/pirlruc/commondevops)
- [containerdevops](https://github.com/pirlruc/containerdevops)
- [guardrails](https://github.com/pirlruc/guardrails)

## Recent history

- 2026-09-11: Tagged **2.1.0**. Filed CPPD-PIN-001 (stale non-tag guardrails pin vs 1.6.0).
  CHANGELOG `[2.1.0]` closed over the dive/memcheck/checklist body.
- 2026-09-11: Wave E — `COPY --from=pybuild --chown=1000:1000` (local dive
  **97.11%** vs 95% floor); `cpp-dynamic.yml` memcheck fail-closed (CI-035);
  docs digest-pin and vendored thresholds; published rescan digest-pinned;
  consumer checklist (CI-018 / draupnir / scaffold `@1.0.0` vs 2.1.0).
  CPPD-WF-003 and CPPD-ECO-001 marked done in yaml. Branch `feature-dive-chown`.
- 2026-09-11: Wave 4 — `cppdevops-security.yml` published rescan calls
  `container-published-rescan.yml@3.0.2`; image CI stays on `container-scan.yml`
  at the same SHA. commondevops pin → `75d0faf…` (single SHA). DEP-MECH-001-T2
  Insights limitation recorded; epic marked done in yaml.
- 2026-09-11: accepted copilot ai-reviewer finding filed as CPPD-WF-003 on
  `feature-ai-reviewer-issues` (merged as #52). Wave 3 yaml marks MOBILE-MECH-001,
  AIREV-MECH-001, and DEP-MECH-001 done; GitHub issues still open pending `--update`.

*Last updated: 2026-09-11*
