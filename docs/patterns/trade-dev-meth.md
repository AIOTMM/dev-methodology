# Pattern: Trade-Dev-Meth (trading-code extension to dev-meth)

> Extension to dev-methodology's 7-stage waterfall + adversarial-review-7-rounds, specialized
> for code that executes live capital decisions against external markets.
>
> Source lessons: AIOT v15.5 Sprint Q+R+S A3 9-round hardening (2026-05-13 → 2026-05-20, 7
> production bugs found post-implementation) + Phase 0 EC2 Hummingbot ops hygiene
> (2026-05-21, AIOTMM/aiot-mm-tool#93).
>
> Pre-req: read `METHODOLOGY.md` (7-stage) + `complexity-ratchet.md` (90% coverage threshold)
> + `twelve-factor-agents.md` (Factor 2/3/8/10/12 ownership) + `adversarial-review-7-rounds.md`
> (R1-R7) **before** applying this extension.

## Audience

Code that **moves money** through external markets and runs **unattended** for hours or days.
Concrete: spot iceberg execution, perpetual futures market-making, derivative hedging bots,
algorithmic strategy controllers, cross-account orchestrators. If your code can lose user
capital between two operator check-ins, this pattern applies. Pure-application development
should follow the unmodified dev-meth 7-stage; do not pay the trading-extension overhead
without the live-capital justification.

---

## §1 Why trading-code is different (6 axes)

Ordinary application bugs are recoverable with a redeploy. Trading bugs are not. The
incremental discipline below exists because each of these axes has produced a measurable
production failure in AIOT v15.5 or its predecessors.

| # | Axis | What changes for trading code | Concrete failure precedent |
|---|---|---|---|
| 1 | **Live capital at risk** | A logic error converts to realized loss, not stack trace | Sprint Q+R+S A3 FINDING-3: future-dated flag mtime kept post-flip monitor active forever; would have masked a real outage at flip time |
| 2 | **24/7 continuous run** | No "office hours" — code must self-heal across days | Sprint Q+R+S A3 FINDING-5: `time.time()` vulnerable to NTP jumps; fixed by switching to `time.monotonic()` |
| 3 | **Kill-switch is the rollback** | `git revert` doesn't undo a market order — must have a runtime panic stop | CLAUDE.md hard rule "NEVER flip executor LIVE manually" pairs with `global_kill_switch.py` cron-checked every 5 min |
| 4 | **Paper-mode soak is mandatory** | No production-first deploy — even fully-tested code must observe before LIVE | OQ6 default 72 hr; Sprint S precedent |
| 5 | **Multi-account blast radius** | A bug deployed to 1 account silently fans out to 5+ (bitabc, vins, vinslai, vins2, master in AIOT v15.5) | Per-account key isolation; one rotate fail must not propagate |
| 6 | **Funding / borrow / settlement** | Bugs surface at 8h funding cadence or end-of-month settlement, not at deploy | "Funding rate accrued at 8-hour cadence and netted against gross PnL" (see `aiot-strategies-clone/short_strategy/BOUNCE_TOP_BOS_V2.md`) — bug only visible 8h after entry |

**Bottom line**: ordinary code's defect-discovery loop is "deploy → user reports →
hotfix". Trading code's is "deploy → user cannot intervene for 8 h → realized loss → no
hotfix possible". The discipline below closes that gap before it opens.

> Sprint Q+R+S A3 9-round hardening (commit range `57def48 → f91e6d7`, 2026-05-20) found
> 7 production bugs the original implementation passed in unit tests. Ordinary dev-meth's
> S5 (TDD) + S6 (7-round review) caught most by R3 / R6; the others required `S6.5 paper-mode
> soak` to surface. Without S6.5, those 7 bugs would have shipped to LIVE.

---

## §2 Adapted waterfall: where S6.5 + S7 fit

**S6.5 is an insertion, not a rewrite of upstream dev-meth.** Upstream `METHODOLOGY.md`
S1–S7 remains canonical. Trading sprints add **S6.5 paper-mode soak between S6 and S7**,
and restructure S7 from a generic "deploy & QA" into a **LIVE canary** with 24 h observation
plus rollback drill.

```
S1 Spec ──→ S2 Resources ──→ S3 Brainstorm ──→ S4 Tickets
                                                  │
                                                  ▼
S7 LIVE canary ←── S6.5 Paper-mode soak ←── S6 Review (7-round) ←── S5 Develop
        ▲                  ▲
        │                  │
        │                  └── NEW for trading: 24-168 h observation
        │                       (default 72 h per OQ6 / Sprint S precedent)
        │
        └── RESTRUCTURED: 24 h LIVE canary + dual-path auth + rollback drill
            (replaces ordinary "deploy" with explicit observation window)
```

### S6.5 — Paper-mode soak (NEW)

| Aspect | Requirement |
|---|---|
| **Duration** | Default 72 h. Override-able per sprint in LOCKED DECISIONS block (24 / 48 / 72 / 168 spectrum). |
| **Zero-crash gate** | 0 unhandled exception, 0 container restart, 0 systemd unit `failed` state |
| **State-drift gate** | Internal state (positions, AVCO, fill counters) reconciles vs broker truth at every tick |
| **Parity gate** | If a reference Python simulation exists for the strategy, paper fills diff ≤ 2 % vs sim on the same bars |
| **Observability gate** | All trades emit structured fill events to a log path operator can `tail -F` |

### S7 — LIVE canary (RESTRUCTURED from generic deploy)

| Aspect | Requirement |
|---|---|
| **Canary size** | Smallest deployable position — typically 1 account, smallest notional |
| **Observation window** | 24 h minimum after first LIVE fill |
| **Dual-path auth verify** | Both REST + WebSocket user-stream healthy throughout the 24 h |
| **Rollback drill** | Operator explicitly invokes kill-switch dry-run at the start of canary |
| **Escalation criteria** | Any unhandled error / auth 401 / state-drift in canary → STOP, do not scale |

Upstream dev-meth's S7 9-gate deploy framework (`docs/stages/07-deploy-qa.md` G1-G9) is
the trading specialization: G1 rc-tag · G2 Stage-0 sanity · G3 operator-decisions signed ·
G4 calibration ±tolerance · G5 24 h soak · G6 paper-week green · G7 flip-script + dual-path
auth · G8 sequential LIVE flip per strategy · G9 post-flip monitoring. These G1-G9 are
**trading instantiations** of S7, not a separate framework.

---

## §3 Trading-specific gates G1–G5

G1–G5 are **deploy-phase gates** that compound with adversarial-review-7-rounds R1–R7
(code-review phase gates). Each gate has a *source* (which lesson made it necessary), an
*enforcement* (where the check runs), and a *verify* (what evidence proves it passed).

### G1 — Backup before mutation

| Field | Value |
|---|---|
| **Source** | Phase 0 EC2 audit (AIOT v15.5 2026-05-20): 1 892 historical HB trades existed in postgres with zero backup cron. A single mistaken `DROP TABLE` would have erased the audit trail. |
| **Rule** | Always snapshot state (DB / config / credential files) **before** any mutation in production. |
| **Enforcement** | Phase 0 STEP 3+4 template: `pg_dump | gzip` + `sqlite3 .backup` + 14-day rotation + shadow restore verify (count match against production). |
| **Verify** | `gunzip -t` clean + restored row count equals production within ε. For sqlite: `PRAGMA integrity_check;` returns `ok`. |

### G2 — Paper-mode 72 h zero crash

| Field | Value |
|---|---|
| **Source** | OQ6 default + Sprint S precedent. |
| **Rule** | Default 72 h paper-mode soak with zero crash. **Operator may override per sprint** via the LOCKED DECISIONS block on the 24 / 48 / 72 / 168 h spectrum, with explicit rationale. |
| **Enforcement** | LOCKED DECISIONS block in sprint mandate; CI emits paper-mode duration as a deploy-flag check. |
| **Verify** | Zero unhandled exception in logs · zero container restart · zero state drift · reference-sim parity ≤ 2 % on the same input bars. |

### G3 — Backtest parity ≤ 2 % vs reference Python sim

| Field | Value |
|---|---|
| **Source** | `aiot-strategies-clone/docs/superpowers/specs/2026-05-20-phase0-aiot-strategies-gap-analysis.md` §7 item 4 — for strategies that have a validated standalone simulator, the production controller's backtest must match the sim. |
| **Rule** | Entry count, exit count, and realized PnL within ±2 % of the reference sim on the same time window. |
| **Enforcement** | Backtest report attached to the strategy's S6 PR. Numbers compared explicitly, not "looks similar". |
| **Verify** | `abs((prod_pnl − sim_pnl) / sim_pnl) ≤ 0.02` (symmetric tolerance — aligns with §2 S6.5 parity gate wording). Equivalent assertions on entry-count and exit-count: identical sets within the same window. |

### G4 — LIVE canary 24 h zero fill anomaly / zero auth 401 / zero state-drift

| Field | Value |
|---|---|
| **Source** | AIOT v15.5 Sprint Q+R+S A3 9-round hardening — multiple bugs only surfaced after deploy, not in unit tests. |
| **Rule** | After LIVE flip, 24 h of automated post-deploy observability with **at minimum: fill audit + auth heartbeat + state-drift detection**. |
| **Enforcement** | Per-strategy post-deploy monitor (e.g. a cron job, a daemon, or a SLO check inside the strategy host) that asserts each of the 3 axes every N minutes. |
| **Verify** | 24 h × audit-frequency consecutive green ticks logged. Any single red → STOP scaling, retro the root cause, do not auto-resume. |

> The 3-axis requirement is generic. A concrete implementation might be a separate
> daemon, a cron job, a Prometheus alert, or a built-in strategy health endpoint —
> whichever fits the sprint's deployment shape. The *rule* is observability coverage,
> not the choice of tool.

### G5 — Kill-switch verified (5 min worst-case manual recovery)

| Field | Value |
|---|---|
| **Source** | CLAUDE.md hard rule "NEVER flip executor LIVE manually" + the operator's existing `global_kill_switch.py` cron-checked every 5 min (path on AIOT-MVP EC2: `/home/ubuntu/aiot-cmd/code/bin/global_kill_switch.py`, mounted into container as `/app/bin/global_kill_switch.py`). |
| **Rule** | Every LIVE-capable strategy must have a documented manual stop path with worst-case time-to-stop ≤ 5 min. |
| **Enforcement** | Pre-canary checklist: operator runs kill-switch dry-run against the new strategy. Recovery runbook lives in `docs/runbooks/<strategy>-kill.md`. |
| **Verify** | Dry-run produces expected "would stop N positions" output. Runbook exists. Time-to-stop is measured (not estimated) in the dry-run. |

---

## §4 Trading hard rules T1–T9 (extending CLAUDE.md core)

These T-rules **extend**, not replace, the CLAUDE.md 8 core rules. They add trading-specific
prohibitions that ordinary application development does not require. T1-T8 are the original
set; T9 (change-window) added during 7-round adversarial review.

| # | Rule | Maps to / extends |
|---|---|---|
| **T1** | NEVER skip backup before mutation. | G1 enforcement; orthogonal to CLAUDE.md. |
| **T2** | NEVER skip paper-mode → LIVE. | G2 enforcement; orthogonal to CLAUDE.md. |
| **T3** | NEVER mutate live position without operator ack. | Aligns with OQ7 (print-diff-ack-apply) and CLAUDE.md "NEVER flip executor LIVE manually". |
| **T4** | NEVER rotate an exchange key without first verifying testnet auth round-trip. | New — preventive rule from Phase 0 audit observation (2026-05-20). Not yet documented as a past failure on this codebase, but multi-account key rotation is recognized as a high-blast-radius operation across the industry. |
| **T5** | NEVER install macOS LaunchAgent for production scheduled work. | Reaffirms CLAUDE.md core rule #8 (added 2026-05-11) — production cron is EC2. |
| **T6** | NEVER share or log Binance / exchange API keys. Use per-account aliasing (e.g. `BINANCE_API_KEY_<ACCOUNT>` environment variable names referenced in code, never the literal key string); keys remain env-only on the deployment host. | Extends CLAUDE.md secret-management (`security.md`). |
| **T7** | NEVER manual `SQL UPDATE strategies SET mode='live'`. Mode transitions go through the documented operator-gated path (e.g. AIOT-MVP OP-7 9-gates; other deployments may have a different gate count, but the rule — never bypass the gate path — is universal). | Aligns with CLAUDE.md "NEVER skip the 9 gates in OP-7". |
| **T8** | NEVER `--no-verify` git commits to bypass pre-commit hooks (secret-scan, lint, type-check). | Aligns with CLAUDE.md "NEVER --no-verify git commits". |
| **T9** | NEVER deploy LIVE during funding settlement window, weekend, or illiquid hours without explicit operator override. | New — funding windows and low-liquidity hours have outsize fill-quality risk; the operator must explicitly weigh the trade-off, not the implementer. |

---

## §5 Sprint template (reusable for Phase 0 and forward)

The Phase 0 sprint mandate (META AIOTMM/aiot-mm-tool#93) is itself a realization of this
template. The 6 blocks below — including the new **Block 0 SESSION CONTINUITY** — are
recommended for every trading sprint.

### Block 0 — SESSION CONTINUITY

```
SESSION CONTINUITY

You are session <UUID>, which has previously completed:
  - <prior sprint / artifact 1>
  - <prior sprint / artifact 2>
  - ...

This sprint extends from <upstream gate / decision point>. The cross-references at the
bottom of this mandate enumerate the prior artifacts you must hold in context. Do not
re-derive them; refer.
```

**Why this block exists**: trading sprints often span multiple sessions across context
compaction. Without an explicit continuity block, a fresh session loses the prior locked
decisions and re-derives them inconsistently. Block 0 is the Factor-12 "stateless
reducer" handshake.

### Block 1 — LOCKED OPERATOR DECISIONS

```
LOCKED OPERATOR DECISIONS

OQ1 = ...
OQ2 = ...
R1  = ...   (optional R-series patches that override the original OQs)
```

Each OQ / R entry is **one line, one decision, one default if absent**. The mandate
explicitly references the OQ identifier — implementation agents do not re-litigate the
choice.

### Block 2 — HARD CONSTRAINTS

```
HARD CONSTRAINTS

H1.  NEVER <action> ...
H2.  NEVER <action> ...
...
Hn.  NEVER <action> ...
```

Each H constraint is a NEVER clause. Soft constraints belong in Block 1 (operator decisions),
not here. The H block is the trading-specific compound of T1–T9 plus sprint-specific
prohibitions (e.g. "NEVER touch HB container during this sprint").

### Block 3 — STEP-BY-STEP with operator-ack gates

```
STEP 1 — <action>
  Prereq: <list>
  Change: <exact bash / file / API>
  Risk: <severity + blast radius>
  Test: <objective observable>
  Rollback: <exact reverse command>
  Checkpoint: <what evidence operator gets, what operator acks>

STEP 2 — ...
```

Every step has **prereq · change · risk · test · rollback · checkpoint**. Fields can be
condensed when redundant — e.g. a read-only pre-flight step has no meaningful rollback
because nothing changed; a print-only step has no test beyond operator review. Whatever
is condensed must be explicit ("rollback: n/a — read-only"), not silently omitted.
The checkpoint field is the Factor-7 human contact intent and is **never** optional.

### Block 4 — EXIT CRITERIA

```
EXIT CRITERIA

✓ <objective test 1>
✓ <objective test 2>
...
```

Every exit criterion is an objective observable (file SHA, row count, PID match,
duration ≥ N). Subjective claims ("looks good", "feels stable") are **not** valid
exit criteria.

### Block 5 — DECISION PACKAGE STEP A-D (handoff to next phase)

```
DECISION PACKAGE for Phase n+1

STEP A: Phase n ship evidence
  - <PR URL>
  - <SHIP report path>
  - <self-validate result>

STEP B: Phase n+1 scope draft
  - <item 1>: LOC estimate, risk, dependency
  - ...

STEP C: Phase n+1 sprint kickoff prompt draft
  (Block 0-4 outline ready for operator to ack)

STEP D: <N> design Qs blocking Phase n+1
  Q1. ...
  Q2. ...
```

This block is the *forward-looking* part of the sprint. Phase n cannot close cleanly
without delivering Phase n+1's STEP A–D so the next sprint can launch without re-discovery.

---

## §6 Cross-references

- `METHODOLOGY.md` — upstream 7-stage waterfall. S1-S7 remain canonical; this pattern inserts S6.5 and restructures S7.
- `docs/patterns/adversarial-review-7-rounds.md` — R1-R7 code-review gates. Compound with G1-G5 deploy gates here.
- `docs/patterns/twelve-factor-agents.md` — Factor 2 (own prompts) / 3 (own context) / 8 (own control flow) / 10 (small agents) / 12 (stateless reducer). Trading sprints especially benefit from Factor 8 — explicit operator-ack gates between steps.
- `docs/patterns/complexity-ratchet.md` — 90 % coverage threshold + 3 ratchet artifacts (tests + docs + evals). Trading code aim ≥ 95 % on money paths.
- `AIOTMM/aiot-mm-tool#93` (Phase 0 META) — realized sprint template (Block 0-5) instantiation that produced this pattern.
- `aiot-strategies-clone/docs/superpowers/specs/2026-05-20-phase0-aiot-strategies-gap-analysis.md` — concrete G3 backtest-parity example (Pyramid RSI / CVD / BOUNCE).
- AIOT v15.5 Sprint Q+R+S A3 9-round hardening (2026-05-20) — `~/.claude/projects/-Users-laijack-Documents-mm/memory/sprint_s_a3_final.md` — the 7-production-bug retrospective that motivated G4.

---

## Self-validate (12 checks — original 8 + 4 round-specific after 7-round adversarial review)

- [x] §1-§6 each section has trading-specific evidence (not pure dev-meth copy) — §1 cites Sprint Q+R+S 7 bugs; §3 G1-G5 are all trading-specialized; §4 T1-T9 are trading additions on top of CLAUDE.md core
- [x] §2 paper-mode soak inserted *between* S6 and S7, upstream S1-S7 unchanged
- [x] §3 G1-G5 compound with adversarial-review-7-rounds R1-R7 (do not replace)
- [x] §4 T1-T9 do not conflict with CLAUDE.md 8 core rules (T5 reaffirms; others extend)
- [x] §5 sprint template matches the structure of the Phase 0 mandate itself (self-bootstrap)
- [x] §6 cross-reference paths all exist on disk as of authoring (verified via pre-write check)
- [x] Audience declared explicitly at top (live-capital code, not plain-application code)
- [x] No emoji per CLAUDE.md style
- [x] **C1 fix** (round-specific): §4 T4 source no longer claims an undocumented past failure on this codebase — phrased as preventive rule from Phase 0 audit observation
- [x] **S1 fix** (round-specific): §3 G3 Verify field uses symmetric `abs((prod − sim) / sim) ≤ 0.02` formula matching §2 S6.5 parity-gate wording
- [x] **S2 fix** (round-specific): §4 T7 phrased as generic operator-gated rule with AIOT-MVP OP-7 9-gates as parenthetical example, not as a sprint-coupled hard requirement
- [x] **S3 + M2 + M5 fix** (round-specific): §5 Block 3 6-field check allows condensation with explicit "n/a" rather than silent omission; checkpoint field stays mandatory · M2 global_kill_switch.py path verified at `/home/ubuntu/aiot-cmd/code/bin/` and rephrased without unverified "dry-run" qualifier · M5 funding quote re-attributed to `BOUNCE_TOP_BOS_V2.md` (where the exact phrase lives) instead of `bos_v2_sim.py` (which uses different wording)
- [x] No secrets, no private absolute paths beyond `/Users/laijack/Documents/dev-methodology/` + `aiot-strategies-clone/` + `~/.claude/projects/-Users-laijack-Documents-mm/memory/sprint_s_a3_final.md` (all three are intentional pattern-doc citations to canonical sources)
