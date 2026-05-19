# Roadmap

> Mirror of GitHub META issue [#25](https://github.com/AIOTMM/dev-methodology/issues/25)
> for offline-readable / git-blame-able tracking.
>
> If GitHub goes down or repo is forked, this file preserves the backlog.

## Current state — v1.2.0 (2026-05-19)

- HEAD: `10f79dc`
- Validators: PASS
- External-use verdict from R8 review: **READY**
- Files: 63

## v1.3 — Polish (~10h, P1)

Close R-round deferred findings:

- [ ] [#1 R4-H1: 2-axis round-skip matrix (blast-radius × reversibility)](https://github.com/AIOTMM/dev-methodology/issues/1) (~1h)
- [ ] [#2 R4-H4: deploy timeline matrix by stake level](https://github.com/AIOTMM/dev-methodology/issues/2) (~1h)
- [ ] [#3 R5-K: explicit operator definition](https://github.com/AIOTMM/dev-methodology/issues/3) (~20min)
- [ ] [#4 R5-Q: Tier-1/2/3 alarm ladder definition](https://github.com/AIOTMM/dev-methodology/issues/4) (~1h)
- [ ] [#5 R6-H7: METHODOLOGY.md S7 trading-detail bleed → abstract](https://github.com/AIOTMM/dev-methodology/issues/5) (~1h)
- [ ] [#6 R7-N3: README repo structure tree update](https://github.com/AIOTMM/dev-methodology/issues/6) (~10min)
- [ ] [#7 R5-R: 'fresh session uncertainty' guidance](https://github.com/AIOTMM/dev-methodology/issues/7) (~20min)
- [ ] [#8 R7-S7: check_gates.py --offline mode](https://github.com/AIOTMM/dev-methodology/issues/8) (~1h)
- [ ] [#9 R5-T: canonical NEVER-TYPE list per project](https://github.com/AIOTMM/dev-methodology/issues/9) (~40min)
- [ ] [#10 R4-M6: generalize 'Manual SQL LIVE flip' anti-pattern](https://github.com/AIOTMM/dev-methodology/issues/10) (~30min)

## v1.4 — Expand (~15-20h, P2)

New walkthroughs + tooling:

- [ ] [#11 CLI tool walkthrough (3rd domain example)](https://github.com/AIOTMM/dev-methodology/issues/11) (~3h)
- [ ] [#12 Data-pipeline walkthrough (4th domain example)](https://github.com/AIOTMM/dev-methodology/issues/12) (~3h)
- [ ] [#13 Fresh-project bootstrap script](https://github.com/AIOTMM/dev-methodology/issues/13) (~3h)
- [ ] [#14 CI integration example](https://github.com/AIOTMM/dev-methodology/issues/14) (~1h)
- [ ] [#15 Daily-cycle commands from vinsai_AI](https://github.com/AIOTMM/dev-methodology/issues/15) (~3h)
- [ ] [#16 Multi-LLM cross-check skill formalized](https://github.com/AIOTMM/dev-methodology/issues/16) (~2h)
- [ ] [#17 Operator-decisions v2 template generalization](https://github.com/AIOTMM/dev-methodology/issues/17) (~2h)
- [ ] [#18 Per-pattern domain-translation expansion](https://github.com/AIOTMM/dev-methodology/issues/18) (~2h)

## v1.5 — Explore (P3, unknown effort)

Long-term exploration:

- [ ] [#19 Mine 6 unread session memories](https://github.com/AIOTMM/dev-methodology/issues/19) (~4h)
- [ ] [#20 Build exemplar fresh project from S1](https://github.com/AIOTMM/dev-methodology/issues/20) (~8h)
- [ ] [#21 Visual flowchart of 7 stages (Mermaid + PNG)](https://github.com/AIOTMM/dev-methodology/issues/21) (~1h)
- [ ] [#22 Sub-agent prompt library expansion](https://github.com/AIOTMM/dev-methodology/issues/22) (~3h)
- [ ] [#23 R5-G: standardize placeholders](https://github.com/AIOTMM/dev-methodology/issues/23) (~1h)
- [ ] [#24 R5-H: docs/sprints/ first-sprint bootstrap](https://github.com/AIOTMM/dev-methodology/issues/24) (~20min)

## How to resume after time away

1. `git log -1` — confirm HEAD
2. `bash tools/verify_alignment.sh` — green?
3. Read `README.md` → `METHODOLOGY.md` → `dev-agent.md` → `docs/adoption-guide.md` → this file
4. Open META #25 on GitHub
5. Pick highest-priority unchecked v1.3 item
6. Use methodology on itself: `/sprint-kickoff` → /A1 per issue → S6 → close

## Effort summary

| Milestone | Issues | Effort | Priority |
|---|---|---|---|
| v1.3 | 10 | ~10h | P1 |
| v1.4 | 8 | ~15-20h | P2 |
| v1.5 | 6 | unknown | P3 |
| **Total** | **24** | **~25-30h** | — |

## Anti-amnesia anchors

6 files = full bootstrap context:

1. `README.md` — entry
2. `METHODOLOGY.md` — 7-stage overview
3. `dev-agent.md` — agent definition
4. `docs/adoption-guide.md` — apply to a project
5. `examples/sprint-P-walkthrough.md` — real precedent
6. `ROADMAP.md` (this file) + META #25 — current state

Read those 6 = you know everything material. Anything not in them is in
`docs/` subfolders by topic.

## Milestones on GitHub

- v1.3: https://github.com/AIOTMM/dev-methodology/milestone/1
- v1.4: https://github.com/AIOTMM/dev-methodology/milestone/2
- v1.5: https://github.com/AIOTMM/dev-methodology/milestone/3

## Sign-off per milestone

Each v1.x closes when:
- [ ] All milestone issues closed
- [ ] CHANGELOG entry added
- [ ] New version tag pushed
- [ ] Validators still green
- [ ] Self-review (mini-R7) pass
