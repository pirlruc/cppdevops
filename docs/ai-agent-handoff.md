# AI Agent Handoff — cppdevops

## Identity

| Field | Value |
|-------|-------|
| **Folder** | cppdevops |
| **Remote** | <https://github.com/pirlruc/cppdevops> |
| **Branch** | `main`. **v6.6.2** image jobs take `container_token`. `cpp-infra` and `cpp-security` pin commondevops 6.1.1 (`c7751385f74edcf7f4ce1e64b408f225a38d9416`). Other callees stay on 6.1.0 (`2c5e1ebe9797828128e01f3941b5a02650abe59a`). containerdevops 6.5.0 (`b8c0746603eefdc89571b17c62d1e965b28ff31f`). Workflow containers use ci-cpp 6.6.0 linux/amd64 `sha256:8674685f88da7690e34418a32c52e37b832e339e290516a75a7dbf4f51932c30`. |
| **Role** | Reusable GitHub Actions workflows + C++ library bootstrap templates/scripts + `ci-cpp` image |
| **Type** | CI infrastructure (not a C++ library) |

## Scope

Owns reusable workflows under `.github/workflows/`:

- `cpp-quality.yml`, `cpp-tests.yml`, `cpp-docs.yml`, `cpp-dynamic.yml`, `cpp-codeql.yml`
- `cpp-security.yml` → thin forwarder to commondevops secrets-sast + supply-chain
- `cpp-infra.yml` → thin forwarder to commondevops common-infra-lint
- `cpp-mobile-matrix.yml` (real NDK/Xcode smoke compile)
- Self-CI: `cppdevops-ci.yml`, `cppdevops-security.yml`, `ci-cpp-image.yml`

Also owns `templates/`, `scripts/sync-library-*.sh`, and the live Docker
contexts `docker/ci-cpp/` (Debian and Alpine, both with vcpkg) and
`docker/ci-cpp-opencv/`. `ci-cpp-ubuntu` and `ci-cpp-vcpkg` stopped at 6.3.0.

Standalone library callers should pin `pirlruc/cppdevops@<sha>` (`CI-018`)
and pass the same value as `scripts_ref`. The published analysis image is
ci-cpp 6.4.0 Debian. Actions pins the linux/amd64 manifest.
Hub/Packages, one page per image:
[`docs/docker-hub-ci-cpp.md`](docker-hub-ci-cpp.md),
[`docs/docker-hub-ci-cpp-ubuntu.md`](docker-hub-ci-cpp-ubuntu.md),
[`docs/docker-hub-ci-cpp-vcpkg.md`](docker-hub-ci-cpp-vcpkg.md),
[`docs/docker-hub-ci-cpp-opencv.md`](docker-hub-ci-cpp-opencv.md),
and the matching `docs/github-packages-ci-cpp*.md` pages.
Never `@main`. Checklist: [`docs/consumer-checklist.md`](consumer-checklist.md).

Contract reference: [`docs/workflows.md`](workflows.md).

## Pins (2026-10-28)

| Submodule / artifact | Pin |
|----------------------|-----|
| `docs/guardrails` | tag **1.15.0** → `2d4bb70e95449f6922781716857adeb22badf676` |
| `.github/scaffold` | tag **1.12.0** → `9c443ea978851768f451b1df2020dd86dfb1a967` |
| methodologies (links only; not a submodule) | tag **1.9.1** |
| `ghcr.io/pirlruc/ci-cpp` (debian, unsuffixed) | `6.6.0` `linux/amd64` `sha256:8674685f88da7690e34418a32c52e37b832e339e290516a75a7dbf4f51932c30`. Tag index `sha256:bee2ce53fe717e52d85cc1e13994808eb098a4d2f1e76ff37b84b087bdfc331c`. Includes vcpkg. Private package: `packages: read` and `container.credentials` |
| `ghcr.io/pirlruc/ci-cpp` (alpine) | `6.4.0-alpine` `linux/amd64` `sha256:817f79358c86cf4045288f74768901daa2b0f5416807e50ab4a601e8d7a8f331`. Tag index `sha256:2665aeaa0f9eb9b0a355a1216671724227cf21f5eaa4da7592a0d2f9fc78520d`. Includes vcpkg |
| `ghcr.io/pirlruc/ci-cpp-ubuntu` | `6.3.0` `linux/amd64` `sha256:2a7622d8299d126f127847c09818de867170a3992efead0d1ecd7edd41c2a3d5`. Tag index `sha256:c5dc493c2059d61c8da58b001aeedff2ccb35ba28736eba73f3c378e814d06f8` |
| `ci-cpp-vcpkg` | `6.3.0` `linux/amd64` `sha256:e551e5f6f6ec5b65bd571fb13c549916fc0ac4e6156c2185f0a8eb5be2a2fe44`. Tag index `sha256:7df56682882f2472cd0dd13d9d9148ea7a3f0cdd5140f12014abd4be0ba5cda4`. OpenCV is not in this image |
| `ci-cpp-opencv` | `6.4.0` `linux/amd64` `sha256:5c603b8864c017e82906a2a6c6aa6728a3cc8aba1b8f12c83947d57ed04aa484`. Tag index `sha256:f7e721a5593987ac9a8e9ae145f4e622ebf8e34355b9dadcbab3154b980468eb`. OpenCV 4.14.0, Eigen 3.4, libc++ triplet, analysis tools. `sha256:42ba66c3…` remains the 6.3.0 linux/amd64 image |
| commondevops `uses:` | `9e28757e47375bbe02f1150e3612cdf69723dd29` (included in tag **5.3.3** and later). Token audit is **5.4.1** `d03953476f3d5fa1081a0834d9882007ff26dd91` |
| containerdevops `uses:` | `2ad052e69d2587cdaf8ccac59b9dae5c60f5560b` (included in tag **6.2.0**) |

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
| Deviations remaining | SC-SIGN-001, CI-032, REL-PUB-004. CPP-BUILD-004 dropped with guardrails 1.12.0 |

## Mobile toolchain pins (`CPP-BUILD-012`)

| Pin | Value | Review |
|-----|-------|--------|
| `MIN_ANDROID_NDK_VERSION` | 26.1.10909125 | 2027-01-01 |
| `MIN_XCODE_VERSION` | 15.4 | 2027-01-01 |

## Commands

```bash
docker build -t ci-cpp:debian-local docker/ci-cpp
docker build -f docker/ci-cpp/Dockerfile.alpine -t ci-cpp:alpine-local docker/ci-cpp
docker build -t ci-cpp-opencv:local docker/ci-cpp-opencv
./scripts/check-ci-local.sh
./scripts/check-ci-docker.sh
./scripts/sync-library-tooling.sh /path/to/library
./scripts/sync-library-devcontainer.sh /path/to/library <cmake-target> [display-name]
./scripts/generate-doxyfile.sh /path/to/library
python3 .github/scaffold/scripts/issues-sync.py \
  --repo pirlruc/cppdevops --yaml docs/issues.yml --dry-run
```

## Known pitfalls

- Host PATH has no `vcpkg`. `ci-cpp:debian-local` has `/opt/vcpkg/vcpkg`, and that tree has no `.git`, so `vcpkg x-ci-verify-versions` cannot read port git trees. Pointing `--vcpkg-root` at NjordLabs/cpp-registry fails because that checkout has no `scripts/vcpkg-tools.json`. Do not install vcpkg on the host.
- Doc coverage lists headers with `os.walk(followlinks=True)` and must keep the path Clang opened. `Path.resolve()` follows an `include/` directory symlink into `modules/` and then every declaration looks private. `header_relative()` tries the opened path before the resolved path.
- `cpp-fuzz` configures with `-G Ninja`. ci-cpp has ninja and no make, so a bare `cmake -B build` stops before it compiles the fuzz target.
- A called workflow's `github.workflow` is the caller name. `cpp-fuzz`, `cpp-infra`, and `cpp-security` must not build their concurrency group from that name, or the pending jobs cancel each other. The group includes `github.run_attempt` so a rerun does not reuse the previous attempt's group.
- `cpp-dynamic.yml` input `asan_options` defaults to `detect_leaks=1:halt_on_error=1`. Callers that link the image's libstdc++ OpenCV from a libc++ test can add `alloc_dealloc_mismatch=0`.
- Coverage counts `include|src` and `modules/*/include|src`. If the image has gcovr but no `llvm-cov` or `gcov`, and the job is root, `check-coverage.sh` installs `llvm-18`.
- `cpp-release.yml` grants `attestations: write` because `common-release.yml` requests it. `cpp-infra.yml` and `cpp-security.yml` forward `secrets.checkout_token` into commondevops.

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
  `container: ghcr.io/pirlruc/ci-cpp@sha256:32d74a33…` (CI-018). Do not float `:latest`.
- Leftover `container-image-ci-cpp` Actions artifacts were deleted after the
  3.1.0 image publish. Do **not** delete published GHCR/Hub tags. Image builds
  inherit containerdevops BuildKit `cache-to: type=gha,mode=min`.
- Threshold drift CI checks out **only** the `docs/guardrails` gitlink SHA
  with `GUARDRAILS_READ_TOKEN` (contents:read on private `pirlruc/guardrails`).
  Do not use `submodules: true` — that also clones private `github-scaffold`
  with `github.token` and fails 404. The job fails if the token is unset.
  Dependabot skips the job. Do not fall back to `COMMONDEVOPS_READ_TOKEN`.
  Local `scripts/check-threshold-drift.sh` uses an initialized submodule.
- Compose GHCR scan/publish refs from `handoff_package` + `digest`. Do not
  pass `needs.build.outputs.image_ref` (Actions secret-masks the owner).
- `sync-library-tooling.sh` requires `CPPDEVOPS_WORKFLOW_REF`; it never
  defaults to `main`.
- clang-format pre-commit matches the analysis image formatter (**v23.1.0**).
  Do not bump that hook past the image's clang-format.
- **Consumer pins (CI-018):** seven libraries still pin `@main`. See
  [`docs/consumer-checklist.md`](consumer-checklist.md). Callers pin **3.1.2**.
  github-scaffold seed `templates/ci-quality.yml` still historically pinned
  `cppdevops@1.0.0`; this repo vendors a 3.1.2 copy with `permissions:`.
  draupnir-cpp still has legacy CodeQL/Codacy/Ubuntu workflows.
- Missing Doxyfile: `check-doc-coverage.sh` generates via `generate-doxyfile.sh`
  or fails closed (CI-035).
- Private nested checkout needs a PAT when private.

## Suggested next work

1. CPPD-SCAN-001 stays open. The Ubuntu pin is only in `docker/ci-cpp-opencv/Dockerfile`. Do not leave 24.04. Do not retag v6.3.0 through v6.3.2.
2. Callers that need vcpkg must pin the `linux/amd64` image manifest `sha256:b8da2259…`, not the tag index `sha256:b92e65c8…`. The same rule applies to `ci-cpp-opencv` (image `sha256:c167f4b2…`, index `sha256:79089fae…`).
3. Library callers pass `run_ios: false`. iOS is a recorded `CPP-BUILD-010` deviation.
4. The weekly token audit passes the three read tokens. `SCORECARD_TOKEN` is not set. Expiries were confirmed on 2026-10-23.
5. v6.1.0 is the image release. Digests are in that GitHub Release. Do not publish another Release only to reprint Hub pages. v6.0.1 stays a tag with no Release.
6. Hub Overviews for the four images update on a push to `main` when `docs/docker-hub*.md` changes, and on `workflow_dispatch`. That calls [container-hub-description](https://github.com/pirlruc/containerdevops/blob/6.3.0/.github/workflows/container-hub-description.yml) and does not republish images.
7. CPPD-PRIV-001 is done. The reusable C++ jobs already set `container.credentials`. Scorecard alerts 298, 308, and 300 were dismissed under CI-042 (review 2026-12-31). Alerts on jobs that also hold `packages: write`, `actions: write`, or `id-token: write` stay open.
8. CPPD-PKG-001 is open. Before any library leaves `c4309e56`, add bifrost-cpp, bor-cpp, draupnir-cpp, edda-cpp, heimdallcv, mimir-cpp, mjolnir-cpp, nornir-cpp, and runa-cpp to the private `ci-lint` and `ci-supply-chain` allow lists. Those pins do not pull the packages today. `ci-iac` has no library caller.

## vcpkg

Debian and Alpine `ci-cpp` install vcpkg `434307da` at `/opt/vcpkg` with
`VCPKG_FORCE_SYSTEM_BINARIES=1` and triplet `x64-linux-libcxx`. Alpine
bootstraps with `-musl` because the glibc vcpkg binary does not run there.
The published
6.3.0 `ci-cpp-vcpkg` digest `sha256:e551e5f6…` stays until callers move. Do not
rebuild that name. `run_ubuntu_compile` remains an input. The job is a no-op
and does not compile, because actionlint rejects `if: false`.

GitHub jobs pass `use_vcpkg: true` and `container_image` once 6.4.0 is
published. `scripts/prepare-vcpkg.sh` writes `checkout_token` only into a
gitconfig under `RUNNER_TEMP`.

## See also

- [workflows.md](workflows.md)
- [consumer-checklist.md](consumer-checklist.md)
- [README.md](../README.md)
- [CHANGELOG.md](../CHANGELOG.md)
- [commondevops](https://github.com/pirlruc/commondevops)
- [containerdevops](https://github.com/pirlruc/containerdevops)
- [guardrails](https://github.com/pirlruc/guardrails)

## Recent history

- 2026-10-28: **v6.3.2** grants `actions: read` on the CodeQL job so `codeql-action/analyze` can read the workflow run. No image republish. Do not move v6.1.0 through v6.3.1.
- 2026-10-28: **v6.3.0** on `fadd4e7` published the images (<https://github.com/pirlruc/cppdevops/actions/runs/40762360977>). Security dispatch <https://github.com/pirlruc/cppdevops/actions/runs/40762499368> succeeded. **v6.3.1** records the 6.3.0 index and linux/amd64 manifests in the reusable defaults and the Hub/GHCR pages. No second publish. Do not move v6.1.0 through v6.3.0.
- 2026-10-28: `feature-v631` grants the Scorecard job `actions: read`, pins commondevops 5.6.2 and containerdevops 6.3.6, adds `cpp-pins`, `cpp-threshold-drift`, `cpp-release`, `cpp-token-audit`, `cpp-doc-verify`, and `cpp-devcontainer`, and moves setuptools to 84.1.0. `templates/ci-quality.yml` drops `scripts_ref` on `cpp-infra` and grants `packages: read` plus `actions: read` on security. Merged as pull request 166.
- 2026-10-28: Dependabot pull requests pass `DEPENDABOT_GITHUB_TOKEN` to scaffold and doc verify. Actions runs pass `COMMONDEVOPS_READ_TOKEN`. Pull request 163 proved the Actions path (`scaffold / verify` and `docs / verify`). Pull request 154 then ran `scaffold / verify` on Dependabot, including the private commondevops checkout, and merged as `d72bea6`. The pinned `common-doc-verify` job still skips Dependabot, so `docs / verify` did not start. Threshold drift still skips Dependabot and still uses `GUARDRAILS_READ_TOKEN`.
- 2026-10-28: commondevops callers pin 5.5.3 (`c8ab717`). `scripts_ref` matches. Job containers pass the 5.5.0 linux/amd64 manifests (`ci-lint` `4d96a023…`, `ci-supply-chain` Debian `b43eb3a9…`) and do not forward `checkout_token`. That PAT is the registry password and cannot see the package. `github.token` can. Library repos stay on `c4309e56` until each one is on those allow lists (CPPD-PKG-001). Do not move v6.1.0 through v6.2.2. No image republish.
- 2026-10-28: CPPD-PKG-001 records that the nine library repos need `ci-lint` and `ci-supply-chain` pull before they move from `c4309e56` to v6.2.2. Merged as `97e917e`. Do not move v6.2.2.
- 2026-10-27: **v6.2.1** on `936f4fd` published the images. v6.2.0 did not. linux/amd64 ci-cpp is `sha256:88fd10cb4cf754f190f565f14667fc5eef8cd933326fe2daa84ed0479709f19a`. Digest write-back is pull request 157 and should be an annotated tag v6.2.2 with no release. Do not move `v6.2.0` or `v6.2.1`.
- 2026-10-24: **v6.1.0** on `3c1fdb60` (PR 150). Image tags are `6.1.0`. Issue #87 is closed. Hub pages still name 6.0.0. Debian owns the unsuffixed `ci-cpp` tags.
- 2026-10-23: **v6.0.2** — guardrails 1.13.1. Hub Overview push when `docs/docker-hub*.md` changes. Tag only. No GitHub Release.
- 2026-10-23: Hub Overview dispatch for `ci-cpp`, `ci-cpp-ubuntu`, `ci-cpp-vcpkg`, and `ci-cpp-opencv`. It does not republish images.
- 2026-10-23: v6.0.1 records the 6.0.0 `linux/amd64` manifests. No GitHub Release. Publish run <https://github.com/pirlruc/cppdevops/actions/runs/39919054101>. CPPD-SCAN-001 stays open.
- 2026-10-23: doc coverage is the Clang AST. coverxygen is removed. `-Wdocumentation` fails quality and test builds. Ubuntu Dependabot ignores `>= 24.10`. CPP-BUILD-004 deviation dropped against guardrails 1.12.0.
- 2026-10-02: spike. Hello-world `-stdlib=libc++ -fsanitize=address,undefined`
  passes on Debian Clang 18.1.8 and Alpine Clang 20.1.8. Ubuntu compile image
  passes without sanitizers. Alpine Clang 18 cannot compile libc++ 22.
  edda-cpp configure identifies Clang 18.1.8 and stops on jsoncpp, which the
  image does not ship (the Ubuntu image did not either).
- 2026-10-02: ci-cpp analysis is Debian 13 Clang 18. Alpine is Clang 20 because
  libc++ 22 does not compile with Clang 18. ci-cpp-ubuntu is compile-only.
  CPP-BUILD-004 deviation, review 2027-01-31. Published as 5.0.0; digests
  are pinned in 5.0.1. 5.0.0 has no `-debian` tag and no `latest-alpine`.
- 2026-10-02: CPPD-SCAN-001 local build pins
  `ubuntu:24.04@sha256:a853f94d…` (Created 2026-09-18). Trivy os+library,
  no ignorefile: 168 unfixed HIGH/CRITICAL, all `linux-libc-dev`. The six
  fixable highs from 3.1.0 are absent. CVE-2026-64564 remains. Not published.
- 2026-10-01: **4.0.1** (tag-only) — workflow and rescan pins use ci-cpp 4.0.0
  `sha256:cf40f3bc…`. No GitHub Release, so the image is not republished.
- 2026-10-01: **4.0.0** — guardrails **1.9.0**, scaffold **1.8.0**, methodologies
  links **1.8.0**. `scripts_ref` is required cross-repo. commondevops **5.2.6**,
  containerdevops **6.1.0**. ci-cpp stays Ubuntu 24.04 (`008173c2…`, config
  still 2026-09-11) and installs clang-format 23.1.0. `cpp-fuzz.yml` added.
  CI-032 and REL-PUB-004 recorded.
- 2026-09-30: guardrails **1.8.0** / scaffold **1.7.0**. Methodology decision
  links cite **1.6.0** (no methodologies submodule). `ci-cpp` pins apt
  versions, installs cloc, drops hadolint DL3006/DL3008 ignores, and upgrades
  the fixable Scout packages (`linux-libc-dev` 6.8.0-142.142, setuptools
  84.0.0, msgpack 1.2.3, pygments 2.21.0; pip removed). Base digest is
  `ubuntu:24.04@sha256:49675449…` (created 2026-09-11), repeated on both
  stages. `SC-PROV-001` recorded. Unfixed kernel advisories still attach to
  `linux-libc-dev`. Image CI scans language packages only; OS confirmation is
  CPPD-SCAN-001. Refresh this digest before 2026-10-11.
- 2026-09-15: **3.1.2** — re-pin commondevops 5.1.2; check-ci-docker default
  ci-lint 5.1.1 alpine digest; seed `@3.1.2`. Annotated tag only (no GitHub
  Release). Threshold-drift still skips without `GUARDRAILS_READ_TOKEN` (private
  gitlink cannot init with `GITHUB_TOKEN`). Dependabot #79 left open.
- 2026-09-15: **3.1.1** — pin reusable `container:` and published rescan to
  ci-cpp digest `sha256:f42b11bc…` from the 3.1.0 image publish. Annotated tag
  only (no GitHub Release) so CI C++ Image does not rebuild. Quota: leftover
  `container-image-*` artifacts deleted; GHA cache stays `mode=min` via
  containerdevops.
- 2026-09-15: **3.1.0** — containerdevops 5.0.2 GHCR handoff, Hub/Packages docs,
  mobile header TU, pip 26.2.1 pins, checkout_token on dynamic/codeql, token-free
  pins, threshold-drift via `GUARDRAILS_READ_TOKEN` gitlink checkout (not
  `submodules: true`), no clang-format v23.
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

- 2026-10-02: Scorecard and token audit on the Wednesday security workflow.
  zizmor policy is hash-pin. `GUARDRAILS_TOKEN` is step-scoped. Final image
  stages clear setuid. Hub and GHCR docs describe Debian, Alpine, and the
  Ubuntu compile image. 5.0.0 is published. 5.0.0 Debian has no `-debian`
  tag; `ci-cpp-ubuntu` is GHCR-only until the next publish.

- 2026-10-06: CPPD-PERM-001, CPPD-CMAKE-002, CPPD-CACHE-001. Workflow
  permissions match the jobs. `ci-cpp-vcpkg` adds vcpkg without OpenCV.
  Ubuntu 24.04 base digest moved; its created date is still 2026-09-18.
- 2026-10-06: Hub pages record 5.1.2 for `ci-cpp`, `ci-cpp-ubuntu`, and
  `ci-cpp-vcpkg`. `Dockerfile.opencv` builds OpenCV 4.14.0 plus Eigen 3.4.
  That image is local only until the next image release.

- 2026-11-02: `cpp-tests.yml` input `run_ubuntu_compile` defaults to true. Callers that need OpenCV set it false because `ci-cpp-ubuntu` does not ship that library. Quality, tests, docs, dynamic, and CodeQL set `defaults.run.shell` to bash after `on:`, because a default placed above `on:` was ignored and `ci-cpp-opencv` has dash as `/bin/sh`. Doc coverage follows directory symlinks under `include/`. The quality job also sets `shell: bash` in its own `defaults.run`, because that block replaced the workflow shell.

- 2026-11-03: Image consolidation on `feature-image-consolidation`. vcpkg folds into Debian and Alpine `ci-cpp`. `ci-cpp-opencv` gains a uv venv and llvm-cov. `ci-cpp-ubuntu` and `ci-cpp-vcpkg` directories are removed. Do not merge PRs #174 or #169. Do not `workflow_dispatch` with `publish: true`. Publish happens from the 6.4.0 release event. v6.4.1 is the later digest write-back and must not republish.

- 2026-11-03: v6.4.0 published the folded images. v6.4.1 records the linux/amd64 manifests and does not republish. Debian `sha256:3f477649…`, Alpine `sha256:817f7935…`, OpenCV `sha256:5c603b88…`.

*Last updated: 2026-11-03 (v6.4.0 published, v6.4.1 digest write-back).*

*Last updated: 2026-11-04 — filed documentation follow-up epics moved out of guardrails, methodologies, or github-scaffold. Not implemented here.*

*Last updated: 2026-11-08 — v6.6.4. Fuzz, infra, and security no longer share a concurrency group. v6.6.3 still configures fuzz with Ninja.*

*Last updated: 2026-11-07 — v6.5.0 branch. Guardrails 1.15.0. Scaffold 1.12.0. commondevops 6.0.1. containerdevops 6.4.0.*

*Last updated: 2026-11-07 — Scorecard Code-Review, Fuzzing, and CII-Best-Practices stay open. See docs/scorecard-open-checks.md.*

*Last updated: 2026-11-07 — vcpkg is not on the host PATH, so local cpp-registry verify stopped.*
