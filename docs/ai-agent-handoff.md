# AI Agent Handoff — cppdevops

## Identity

| Field | Value |
|-------|-------|
| **Folder** | `cpp/cppdevops/` |
| **Remote** | https://github.com/pirlruc/cppdevops |
| **Branch** | `feature-dependency-update-policy` |
| **Role** | Reusable GitHub Actions workflows + C++ library bootstrap templates/scripts |
| **Type** | CI infrastructure (not a C++ library) |

## Scope

Owns reusable workflows under `.github/workflows/`:

- `cpp-quality.yml`, `cpp-tests.yml`, `cpp-docs.yml`, `cpp-dynamic.yml`, `cpp-codeql.yml`
- `cpp-security.yml` → thin forwarder to commondevops secrets-sast + supply-chain
- `cpp-infra.yml` → thin forwarder to commondevops common-infra-lint
- `cpp-mobile-matrix.yml` (placeholder; deviations recorded)

Also owns `templates/`, `scripts/sync-library-*.sh`, and `docker/ci-cpp/`.

Standalone library callers should pin `pirlruc/cppdevops@1.0.0` or `@<sha>` (`CI-018`).

## Pins (2026-08-10)

| Submodule / artifact | Pin |
|----------------------|-----|
| `docs/guardrails` | tag `1.0.0` → `925b9f32659936382c67850ec125a182261710bf` |
| `.github/scaffold` | `0db5890f808e4a9b9d11eabfc9a95b2b90898fad` |
| `ghcr.io/pirlruc/ci-cpp` | local tag `:local`; workflows use `:latest` until publish |
| commondevops `uses:` | **`74695e83a7b79784ee81fd970d9051d8efd711e8`** — replace after first commondevops push |

## Delivery status

| Phase / epic | Status |
|--------------|--------|
| Phase 1 — CONS-* | Done |
| Phase 2 — GATE/COV/CI-TRIGGER/TOOL-CFG/DOC/DYN/SEC-MECH-001…004/INFRA/CI-001 | Done (authored) |
| MOBILE-MECH-001 | Open (placeholder + deviations CI-014 / CPP-BUILD-010/011) |
| DEP-MECH-001 | Open (Dependabot rewritten; Insights after default-branch land) |
| AIREV-MECH-001 | Open |
| `run_sbom` default | **true** (SC-SBOM-001) |

## Commands

```bash
# Local CI image (already built on this host as :local):
docker build -t ghcr.io/pirlruc/ci-cpp:local docker/ci-cpp
./scripts/sync-library-tooling.sh /path/to/library
python3 .github/scaffold/scripts/issues-sync.py \
  --repo pirlruc/cppdevops --yaml docs/issues.yml --dry-run
```

## Known pitfalls

- **`74695e83a7b79784ee81fd970d9051d8efd711e8`** in `cpp-infra.yml` / `cpp-security.yml` must be
  replaced after commondevops's first push; keep `scripts_ref` identical to `uses:` pin.
- Quality/tests/docs/dynamic/codeql jobs use `container: ghcr.io/pirlruc/ci-cpp:latest`
  (apt/pip install steps removed). Image must be pullable or jobs fail.
- Mobile matrix is echo-only — see `docs/guardrail-deviations.yml` and MOBILE-MECH-001.
- Private nested checkout of this repo from library callers needs a PAT when private.

## Suggested next work

1. First commondevops commit → replace `74695e83a7b79784ee81fd970d9051d8efd711e8`.
2. Publish `ghcr.io/pirlruc/ci-cpp:latest`.
3. Implement real NDK/Xcode smoke builds (MOBILE-MECH-001) and clear deviations.
4. Merge branch; Dependabot Insights confirmation (DEP-MECH-001-T2).

## See also

- [platform-and-ci-deltas.md](platform-and-ci-deltas.md)
- [improvements.md](improvements.md)
- [README.md](../README.md)
- [CHANGELOG.md](../CHANGELOG.md)
- [commondevops](https://github.com/pirlruc/commondevops)
- [guardrails](https://github.com/pirlruc/guardrails) (pinned at `docs/guardrails/`)

*Last updated: 2026-08-10*
