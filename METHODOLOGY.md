# The 7-Stage Methodology

> Sequential by default. Stages 3-5 can compress when scope is small. Stage 6
> is non-negotiable for any change touching production.

---

## Visual

```
S1 Spec  ──→  S2 Resources  ──→  S3 Brainstorm  ──→  S4 Tickets
                                                          │
                                                          ▼
S7 Deploy & QA  ←──  S6 Review (7-round)  ←──  S5 Develop
```

Loop-back is allowed:
- S6 finds CRITICAL → return to S5 (do NOT bypass)
- S5 reveals spec gap → return to S1, document the gap as a sub-spec
- S2 finds blocker (no API key / no env access) → halt S3-7 entirely

## S1 — Spec Definition

**Goal**: produce a written spec a stranger could implement.

**Inputs**: user request, prior repo state, known constraints.

**Outputs**:
- `docs/specs/<YYYY-MM-DD>-<topic>.md` — single source of truth
- Acceptance criteria (testable, NOT "looks good")
- Explicit scope boundaries (what's IN, what's OUT, what's DEFERRED)
- Risk register (top 3-5 risks with mitigation)

**Gate to S2**: operator (you) writes "spec approved" + commits the file.

See [`docs/stages/01-spec-definition.md`](docs/stages/01-spec-definition.md).

## S2 — Resource Confirmation

**Goal**: confirm every input the spec assumes is actually available.

**Checklist**:
- [ ] Source repos accessible (git auth working)
- [ ] Test fixtures exist (or build plan documented)
- [ ] EC2/cloud creds work (run a smoke call)
- [ ] API keys for all external services (rotate if stale)
- [ ] Operator-in-the-loop available for sign-offs
- [ ] Disk/RAM/CPU headroom matches spec assumptions

**Gate to S3**: every checklist line confirmed live (not "should work").

See [`docs/stages/02-resource-confirmation.md`](docs/stages/02-resource-confirmation.md).

## S3 — Brainstorm

**Goal**: 2-3 alternatives presented, trade-offs explicit, operator picks.

**Rules**:
- Never present 1 option. Always 2-3.
- Each option lists: cost, time, risk, who's blocked.
- "Recommended" is allowed but defended in 1-2 sentences max.
- Operator decision logged in spec doc as `## Decision YYYY-MM-DD`.

**Anti-pattern caught**: "consensus first" — when AI agrees with user too
fast, surface why the disagreement should exist.

See [`docs/stages/03-brainstorming.md`](docs/stages/03-brainstorming.md).

## S4 — Tickets & Milestones

**Goal**: every distinct unit of work has a GitHub issue. Cross-repo work
has a Project board.

**Required artifacts**:
- 1 META tracking issue (pinned, single source of truth)
- 1 GitHub Project (cross-repo issues)
- 2+ milestones (PRE-LIVE gate / LIVE flip / follow-up sprint)
- Labels: priority (p0-p3), origin (sprint name), type (bug/feat/doc/test)
- Per-issue: source citation, acceptance criteria, effort estimate, owner

**Gate to S5**: META issue published + project board has ≥N items.

See [`docs/stages/04-ticket-creation.md`](docs/stages/04-ticket-creation.md).

## S5 — Develop

**Goal**: ship code that passes its own tests AND the next stage's review.

**Rules**:
- TDD: tests first, RED → GREEN → REFACTOR
- Sub-agent dispatch for ≥5-independent-file changes (parallel)
- Each commit: conventional prefix, body explains WHY not WHAT
- HFV-EQUIV-style gate: legacy parity preserved for high-stakes changes
- Cross-session work: handoff prompt MUST be self-contained

See [`docs/stages/05-development.md`](docs/stages/05-development.md).

## S6 — 7-Round Adversarial Review

**Goal**: find what the implementer missed BEFORE production catches it.

**Round dimensions**:
1. **R1 CodeRabbit sweep**: existing review feedback addressed
2. **R2 Architectural consistency**: cross-file invariants hold
3. **R3 Operator tooling hardening**: scripts safe against bad input
4. **R4 Upstream/spec equivalence**: implementation matches spec
5. **R5 Persistence/data layer**: atomic, crash-safe, schema-stable
6. **R6 Test coverage seams**: integration points actually tested
7. **R7 Final ship audit**: spec/doc consistency, CHANGELOG, runbooks

Each round: dispatch code-reviewer subagent with adversarial prompt
("find the worst-case failure mode you can"). Fix → regression test → commit.

See [`docs/stages/06-review-validate.md`](docs/stages/06-review-validate.md).

## S7 — Deploy & QA

**Goal**: production-flip via gates, not via courage.

**Gate sequence** (production-deploy specific):
```
G1 rc-tag  →  G2 Stage-0 sanity  →  G3 operator-decisions signed
              ↓
G4 calibration ±tolerance  →  G5 24h soak SOAK-COMPLETE  →  G6 paper-week green
              ↓
G7 flip-script + dual-path auth  →  G8 sequential LIVE flip per strategy
              ↓
G9 post-flip monitoring + Sprint-Q follow-ups
```

Each gate: explicit acceptance + escalation path + rollback option.

See [`docs/stages/07-deploy-qa.md`](docs/stages/07-deploy-qa.md).

---

## Time budgets (calibrated to AIOT v15.5)

| Stage | Min effort | Typical | Max before splitting |
|---|---|---|---|
| S1 | 30 min | 2-4h | 1 day |
| S2 | 15 min | 1h | 4h |
| S3 | 30 min | 1-2h | 4h |
| S4 | 30 min | 1-2h | 4h |
| S5 | depends | 1-5 days | 2 weeks |
| S6 | 4h | 6-12h | 2 days |
| S7 | 1 day (soak) | 1-3 weeks | depends |

## Anti-patterns this methodology blocks

See [`docs/lessons-learned/ANTI-PATTERNS.md`](docs/lessons-learned/ANTI-PATTERNS.md).
Top hits:

- Skipping S2 → discover EC2 unreachable mid-deploy
- Skipping S6 → 12 CRITICAL bugs ship to production
- Single-pilot Q1-Q8 → operator decisions don't cover real complexity
- Manual SQL LIVE flip → no audit trail, no rollback
- Sub-agent dispatch for 1-file edits → token waste
- "trust me" sub-agent reports → always verify
- **Vibecoding** (NL prompts without ratchet) → silent regression at moderate complexity (AP-14)
- **Markdown wall-of-text** for substantive analyses → see `docs/patterns/structure-as-html.md` (AP-15)
- **Framework-outsourced prompts** → debug by reverse-engineering templates (AP-16)
- **Agent monolith** (>10 tools / >20 steps) → context overflow + focus loss (AP-17)

## Foundational patterns (the 3 imported pillars)

These 3 patterns extend the 7 stages with cross-cutting engineering rigor:

| Pattern | Source | Role |
|---|---|---|
| [`docs/patterns/twelve-factor-agents.md`](docs/patterns/twelve-factor-agents.md) | Dex Horthy 12-Factor Agents | Engineering rigor of LLM stack — deterministic software with embedded LLM steps |
| [`docs/patterns/complexity-ratchet.md`](docs/patterns/complexity-ratchet.md) | Garry Tan AI Ratchet | Quality-only-up via per-cycle test+doc+eval artifacts; 90% coverage threshold |
| [`docs/patterns/structure-as-html.md`](docs/patterns/structure-as-html.md) | Karpathy HTML output | Presentation layer of report-tier outputs (analyses, retros, reviews) |

These reinforce each other:
- 12-Factor (Factor 2/3/8/10/12) → ownership of prompts / context / control flow / scope / state
- Complexity Ratchet → each cycle ratchets quality up (tests + docs + evals)
- Structure-as-HTML → ratchet's evidence (eval records, audit reports) lives in HTML format
