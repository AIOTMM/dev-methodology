# Session Context (Dev-Meth) — compact-survival anchor

> **Purpose**: After Claude session compacts (context compression) OR a fresh
> session resumes work on `AIOTMM/dev-methodology`, this file is the
> single-read source-of-truth.
>
> READ THIS FIRST when resuming. Do NOT rely on conversation memory.

---

## Session identity

- **Role**: Dev-Meth (Dev-Methodology session)
- **Scope**: ONLY `/Users/laijack/Documents/dev-methodology` (GitHub `AIOTMM/dev-methodology`)
- **Lineage**: ST-Dev (Strategies) → SPEC-CO (Coordinator) → Dev-Meth (this) — forked 2026-05-19
- **NOT in scope**: AIOT trading repos / vinsai / aiot-cmd / AIOT-MVP / cross-session coordination

## NEVER constraints (hard, repeated each compact)

1. NEVER push to any repo other than `AIOTMM/dev-methodology`
2. NEVER edit AIOT trading code or operator-decisions files
3. NEVER act as SPEC-CO coordinator (that role retired with branch fork)
4. NEVER consume operator-only decisions (magic phrases, capital allocation)
5. NEVER tag releases or push tags without operator GO
6. NEVER skip `bash tools/verify_alignment.sh` before committing
7. NEVER `--no-verify` git commits
8. NEVER write docs that reference unread sessions as "integrated" (R5 lesson)

## Current state (verified 2026-05-19 post-aaca502)

| Asset | Value |
|---|---|
| Repo | `AIOTMM/dev-methodology` |
| HEAD | `aaca502` |
| Tag latest | `v1.2.0` |
| Working tree | clean (no uncommitted) |
| Push state | synced with origin/master (nothing local-only) |
| `tools/verify_alignment.sh` | PASS ✅ |
| `tools/check_stage_docs.sh` | PASS ✅ |
| Total files | 63 |
| Total commits | 7 |

## Open backlog (25 issues, ~25-30h estimated effort)

- **Milestone v1.3 (polish)**: 11 open / 0 closed (includes META #25 pinned)
- **Milestone v1.4 (expand)**: 8 open
- **Milestone v1.5 (explore)**: 6 open

### v1.3 priorities (P1, ~10h total) — sorted by effort ascending

| # | Title | Effort |
|---|---|---|
| #6 | R7-N3: README repo structure tree update | 10min |
| #3 | R5-K: explicit operator definition | 20min |
| #7 | R5-R: 'fresh session uncertainty' guidance | 20min |
| #9 | R5-T: canonical NEVER-TYPE list per project | 40min |
| #10 | R4-M6: generalize 'Manual SQL LIVE flip' anti-pattern | 30min |
| #1 | R4-H1: 2-axis round-skip matrix | 1h |
| #2 | R4-H4: deploy timeline matrix by stake level | 1h |
| #4 | R5-Q: Tier-1/2/3 alarm ladder definition | 1h |
| #5 | R6-H7: METHODOLOGY.md S7 trading-detail bleed → abstract | 1h |
| #8 | R7-S7: check_gates.py offline / dry-run mode | 1h |

### v1.4 (P2, ~15-20h)

| # | Title |
|---|---|
| #11 | CLI tool walkthrough (3rd domain example) |
| #12 | Data-pipeline walkthrough (4th domain example) |
| #13 | Fresh-project bootstrap script |
| #14 | CI workflow example |
| #15 | Daily-cycle commands from vinsai_AI |
| #16 | Multi-LLM cross-check skill |
| #17 | Operator-decisions v2 template generalization |
| #18 | Per-pattern domain-translation expansion |

### v1.5 (P3, exploratory)

| # | Title |
|---|---|
| #19 | Mine 6 unread session memories |
| #20 | Build exemplar fresh-S1 project |
| #21 | Visual flowchart (Mermaid + PNG) |
| #22 | Sub-agent prompt library expansion |
| #23 | R5-G: standardize placeholders |
| #24 | R5-H: first-sprint bootstrap guide |

## Resume protocol (after compact OR fresh session)

```bash
# Step 1: confirm repo + HEAD
cd /Users/laijack/Documents/dev-methodology
git log -1 --format='%h %s'   # expect aaca502 OR newer

# Step 2: working-tree clean?
git status --short              # expect empty

# Step 3: validators green?
bash tools/verify_alignment.sh  # expect exit 0
bash tools/check_stage_docs.sh  # expect exit 0

# Step 4: read 6 anti-amnesia anchors (full bootstrap context)
cat README.md
cat METHODOLOGY.md
cat dev-agent.md
cat docs/adoption-guide.md
cat ROADMAP.md
cat docs/SESSION-CONTEXT.md   # this file

# Step 5: read META on GitHub
gh issue view 25 --json body -q .body

# Step 6: pick next work item (smallest effort first per /A1)
gh issue list --milestone "v1.3 — polish (R4/R6/R7 deferred)" --state open

# Step 7: execute per /A1 protocol
# - TDD red (if test possible)
# - implement minimal
# - sub-agent review
# - validate
# - commit + push
# - close issue
```

## What was done in immediately-prior session messages (before this compact-prep)

In order:

1. `30436ce` — v1.0.0 initial release
2. `b7adfbe` — v1.1 stages 5-7 + 4 patterns + 6 skills + 4 prompts + tools + GitHub templates
3. `79cbbcc` — R4+R6 partial: domain-translation + onboarding hygiene
4. `79313c1` — R7 BLOCKERs + R5 critical: ship hygiene
5. `38d2932` — R5 honest-gap fix: vinsai_AI session integration (4D / priority scoring / multi-LLM / operator state / daily cycle)
6. `37a76c1` — R8 polish: 7 SHIP_RISK + 3 NICE_TO_HAVE
7. `10f79dc` — tools: remove noisy sed in Check 6
8. `f643023` — R8 user-flagged gap: coordinator-parallel-handoff pattern + adoption-guide
9. `aaca502` — roadmap: 24 backlog issues + META #25 + ROADMAP.md

7 review rounds (R1-R7) self-applied; R8 final verdict: READY.

## Critical files (never lose track of)

| File | Purpose |
|---|---|
| `README.md` | Entry point |
| `METHODOLOGY.md` | 7-stage overview |
| `dev-agent.md` | Agent role definition |
| `CLAUDE.md` | Project-local config |
| `ROADMAP.md` | Backlog mirror of META #25 |
| `docs/SESSION-CONTEXT.md` | THIS file — compact survival anchor |
| `docs/GLOSSARY.md` | Term definitions (HFV-EQUIV / META / 4D / EV / etc.) |
| `docs/DOMAIN-TRANSLATION.md` | Trading → SaaS/CLI/pipeline term map |
| `docs/adoption-guide.md` | How to apply methodology mid-sprint |
| `PREREQUISITES.md` | Setup before using methodology |
| `CHANGELOG.md` | v1.0/v1.1/v1.2 history |
| `LICENSE` | MIT |
| `CONTRIBUTING.md` | How to improve methodology |

## Validation gates (must pass before any commit)

```bash
bash tools/verify_alignment.sh
bash tools/check_stage_docs.sh
```

Both must exit 0. If either fails, the commit is broken.

## Per-issue workflow

For each work item (issue):

1. Read issue body for full spec (Source / Risk / Fix / Acceptance / Effort)
2. TDD red (write test that fails, if testable)
3. Implement minimal change
4. Sub-agent review (dispatch `code-reviewer` for non-trivial items)
5. Apply review findings
6. Run BOTH validators
7. Conventional commit message (`fix:` / `feat:` / `docs:` / `test:`)
8. Body explains WHY not WHAT
9. Push to `origin/master`
10. Close issue with commit hash + verification note

## Deferred items NOT in current backlog (acceptable as-is)

These were R-round findings deliberately accepted as-is, NOT issues to open:

- R8-J: MP command body `AIOT-MVP` repeated as `e.g.` examples (cosmetic)
- R8-K: S2 `BINANCE_API_KEY_VINS2` named precedent (informative real example, labeled correctly)
- Various R4 M1-M8 / R6 M-tier / R7 N-tier already addressed by GLOSSARY + PREREQUISITES + DOMAIN-TRANSLATION

## Honest "what I never did" list

Per R5 honest-gap precedent: state explicitly what was NOT done.

- ❌ Have not read 6 unread session memories (issue #19, deferred to v1.5)
- ❌ Have not built exemplar fresh-S1 project (issue #20, deferred to v1.5)
- ❌ Have not added Mermaid diagrams (issue #21, deferred to v1.5)
- ❌ Have not built bootstrap.sh (issue #13, deferred to v1.4)
- ❌ Have not authored CI workflow file (issue #14, deferred to v1.4)
- ❌ Have not formalized multi-LLM cross-check skill (issue #16, deferred)
- ❌ Have not generalized operator-decisions v2 template (issue #17, deferred)

Each is tracked. None is silently abandoned.

## Self-validate (this file)

- [ ] HEAD recorded correctly: `aaca502`
- [ ] Push state confirmed synced
- [ ] Validators recorded as PASS
- [ ] META #25 pinned status verified true
- [ ] All 24 work issues + META referenced
- [ ] NEVER constraints repeated
- [ ] Resume protocol uses verifiable commands
- [ ] 6 anti-amnesia anchor files listed
- [ ] No "you remember" language anywhere
- [ ] Honest deferred list included

## If you find this file inconsistent with reality

If `git log -1` shows different HEAD or validators fail or issue counts differ:

1. Trust the LIVE git state, not this file
2. Update this file as your first commit
3. Continue from there

This file is a SNAPSHOT, not authoritative for live state. Live state is
git + GitHub.
