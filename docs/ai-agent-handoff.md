# AI Agent Handoff — cppdevops

## Identity

| Field | Value |
|-------|-------|
| **Folder** | `cpp/cppdevops/` |
| **Remote** | https://github.com/pirlruc/cppdevops |
| **Branch** | `feature-published-rescan-3.0.2` (from `origin/main` after #52) |
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

Standalone library callers should pin `pirlruc/cppdevops@2.0.0` or `@<sha>` (`CI-018`).

Contract reference: [`docs/workflows.md`](workflows.md).

## Pins (2026-08-12)

| Submodule / artifact | Pin |
|----------------------|-----|
| `docs/guardrails` | `5a7ac83` (main tip after ci-base → ci-lint/ci-supply-chain; tag `1.1.0` is older) |
| `.github/scaffold` | `f8a6ba1` (main tip) |
| `ghcr.io/pirlruc/ci-cpp` | `@sha256:54ea6b2354709b742a3b1ae289b82c0cbb1ad9241d59ee06b94331ecf945d7f9` (tags `:latest` / `:20260812` / `:sha-3d09f6d`) |
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
| CPPD-ECO-001 | Open (other repos) |
| CPPD-WF-003 | Open (filed; accepted copilot finding) |
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
- **Dive efficiency:** ci-cpp image is 93.05% vs org floor 95% (pre-existing;
  do not lower the gate). The 3.0.1 pin PR merged despite this advisory-looking
  fail because checks are not required.
- Reusable workflows pin `container: ghcr.io/pirlruc/ci-cpp@sha256:54ea6b…` (digest-pin after first publish).
- Threshold drift CI checks out `pirlruc/guardrails` with `GUARDRAILS_READ_TOKEN`
  (preferred) or `COMMONDEVOPS_READ_TOKEN` when that PAT also covers guardrails.
  Without either, the job soft-skips; run `scripts/check-threshold-drift.sh` locally.
  Do not use `submodules: true` with `github.token` (private clone 403/404).
- Seven consumer libraries still pin `@main` (CPPD-ECO-001 / CI-018 on their side).
- Private nested checkout needs a PAT when private.

## Suggested next work

1. After approval, `issues-sync.py --update` to close GitHub #27 #28 #36 #37 #38 #39
   and create CPPD-WF-003 (dry-run first).
2. Implement CPPD-WF-003 (docs drift + valgrind memcheck).
3. Provision `GUARDRAILS_READ_TOKEN` (contents:read on `pirlruc/guardrails`) so threshold-drift CI stops soft-skipping.
4. CPPD-ECO-001 — consumer pin bumps to `@2.0.0` (other repos; needs approval).
5. Investigate ci-cpp dive efficiency 93.05% vs 95% floor.

## See also

- [workflows.md](workflows.md)
- [README.md](../README.md)
- [CHANGELOG.md](../CHANGELOG.md)
- [commondevops](https://github.com/pirlruc/commondevops)
- [containerdevops](https://github.com/pirlruc/containerdevops)
- [guardrails](https://github.com/pirlruc/guardrails)

## Recent history

- 2026-09-11: Wave 4 — `cppdevops-security.yml` published rescan calls
  `container-published-rescan.yml@3.0.2`; image CI stays on `container-scan.yml`
  at the same SHA. commondevops pin → `75d0faf…` (single SHA). DEP-MECH-001-T2
  Insights limitation recorded; epic marked done in yaml.
- 2026-09-11: accepted copilot ai-reviewer finding filed as CPPD-WF-003 on
  `feature-ai-reviewer-issues` (merged as #52). Wave 3 yaml marks MOBILE-MECH-001,
  AIREV-MECH-001, and DEP-MECH-001 done; GitHub issues still open pending `--update`.

*Last updated: 2026-09-11*
