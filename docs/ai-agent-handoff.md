# AI Agent Handoff — cppdevops

## Identity

| Field | Value |
|-------|-------|
| **Folder** | `cpp/cppdevops/` |
| **Remote** | https://github.com/pirlruc/cppdevops |
| **Branch** | `feature-align-3.1.0` → tag **3.1.0** |
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

Standalone library callers should pin `pirlruc/cppdevops@3.1.0` or `@<sha>` (`CI-018`).
`templates/ci-quality.yml` now pins `@3.0.0` until this tag lands (bump in the next
consumer sync). Hub/Packages: [`docs/docker-hub.md`](docker-hub.md),
[`docs/github-packages.md`](github-packages.md).
Never `@main`. Checklist: [`docs/consumer-checklist.md`](consumer-checklist.md).

Contract reference: [`docs/workflows.md`](workflows.md).

## Pins (2026-08-12)

| Submodule / artifact | Pin |
|----------------------|-----|
| `docs/guardrails` | tag **1.6.0** → `77cf16eb…` |
| `.github/scaffold` | tag **1.5.0** → `9e04ed53…` |
| `ghcr.io/pirlruc/ci-cpp` | `@sha256:54ea6b2354709b742a3b1ae289b82c0cbb1ad9241d59ee06b94331ecf945d7f9` (tags `:latest` / `:20260812` / `:sha-3d09f6d`). Reusable `container:` and `cppdevops-security.yml` published rescan share this digest. |
| commondevops `uses:` | tag **5.0.0** → `bcddb5db4ba5d291aa7f434d447e43175f14136c` |
| containerdevops `uses:` | tag **5.0.2** → `32384866e5669dbde8bdecde153a6ae6ead728ed` |

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
| CPPD-PIN-001 | Done (this wave) |
| Deviations remaining | SC-SIGN-001 (Free-plan private-repo pattern) |

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
- Threshold drift CI checks out the in-tree `docs/guardrails` submodule
  (`submodules: true`) and always runs `scripts/check-threshold-drift.sh`.
  Do not skip when `GUARDRAILS_READ_TOKEN` is unset.
- Compose GHCR scan/publish refs from `handoff_package` + `digest`. Do not
  pass `needs.build.outputs.image_ref` (Actions secret-masks the owner).
- `sync-library-tooling.sh` requires `CPPDEVOPS_WORKFLOW_REF`; it never
  defaults to `main`.
- clang-format pre-commit stays on **v22.1.8** (ci-cpp is clang-format 18).
  Do not take Dependabot's v23 bump unless the image formatter matches.
- **Consumer pins (CI-018):** seven libraries still pin `@main`. See
  [`docs/consumer-checklist.md`](consumer-checklist.md). After this tag, callers
  pin **3.0.0**. github-scaffold seed `templates/ci-quality.yml` still historically
  pinned `cppdevops@1.0.0`; this repo now vendors a 3.0.0-ready copy with
  `permissions:`. draupnir-cpp still has legacy CodeQL/Codacy/Ubuntu workflows.
- Missing Doxyfile: `check-doc-coverage.sh` generates via `generate-doxyfile.sh`
  or fails closed (CI-035).
- Private nested checkout needs a PAT when private.

## Suggested next work

1. After the 3.1.0 GitHub Release, write the new ci-cpp digest into reusable
   `container:` pins and `cppdevops-security.yml`.
2. Bump the seven `@main` consumers ([checklist](consumer-checklist.md)) to **3.1.0**.
3. Close Dependabot #76 as superseded (clang-format v23 was not taken).

## See also

- [workflows.md](workflows.md)
- [consumer-checklist.md](consumer-checklist.md)
- [README.md](../README.md)
- [CHANGELOG.md](../CHANGELOG.md)
- [commondevops](https://github.com/pirlruc/commondevops)
- [containerdevops](https://github.com/pirlruc/containerdevops)
- [guardrails](https://github.com/pirlruc/guardrails)

## Recent history

- 2026-09-15: **3.1.0** — containerdevops 5.0.1 GHCR handoff, Hub/Packages docs,
  mobile header TU, pip 26.2.1 pins, checkout_token on dynamic/codeql, token-free
  pins, in-tree threshold-drift, no clang-format v23.
- 2026-09-14: Tagged **3.0.0** + GitHub Release (`cbb1aeb…`, #75). Seed
  `templates/ci-quality.yml` pins `@3.0.0`.
- 2026-09-14: Guardrails **1.6.0** / scaffold **1.5.0**, commondevops **5.0.0**,
  containerdevops **4.0.0**. Fail-closed threshold reader, Doxyfile generate-or-fail,
  collect-then-fail, `size_class: ci_toolchain`, SC-DEP-004, POSIX CI wrapper.
  Retired DOCKER-PERF-001; kept SC-SIGN-001. Branch `feature-guardrails-16`.
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

*Last updated: 2026-09-15*
