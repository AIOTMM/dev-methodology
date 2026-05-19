# Example walkthrough: AIOT v15.5 Sprint-P (May 2026)

> Real 23-day sprint that the methodology was extracted from. Shows each
> stage with concrete artifacts.

## Sprint scope

- 3 strategy ports (Pyramid RSI 15m, CVD Divergence 5m, BOUNCE BOS V2)
- Cross-repo: `agent-5.2-binance-perp` (Strategies) + `AIOT-MVP` (OB-Dev)
- 3 Binance accounts: bitabc / vins2 / vinslai
- LIVE flip waterfall: paper → 24h soak → 7-day paper week → LIVE

## S1 — Spec definition (Day 1)

File: `docs/specs/2026-05-04-v15.5-path-b.md`

Key sections:
- Context: 3 strategies validated upstream `a-bitabc/AIOT-Strategies@6edd3928`
- Goal: port to v15.4 SDK, prepare for LIVE flip
- Non-goals: NOT building new strategies, NOT changing upstream calibration
- Acceptance: HFV-EQUIV 11/11 preserved, ports pass simulator parity, LIVE-ready
- Risks: spec-upstream divergence, multi-position state, hedge mode complexity
- Effort: 5-7 days, 60% confidence

## S2 — Resource confirmation (Day 1 same day)

Smoke tests:
- `gh auth status` → vins-hub authenticated ✓
- `git remote -v` → both repos accessible ✓
- `ssh aiot-ec2 'date'` → reachable ✓
- `python3 /tmp/qp_v2.py all` → 3 accounts return positions ✓
- `BINANCE_API_KEY_VINS2` → 401 (FAIL — discovered IP whitelist broken)

Findings: vins2 API alias workaround (use VINS singular key + `qp.py` label
map). Logged in spec resource appendix.

## S3 — Brainstorm (Day 1-2)

Strategy-account assignment:

- Option A: All 3 strategies on vinslai → REJECTED (margin insufficient)
- Option B: Pyramid×vinslai + CVD×bitabc → REJECTED (Pyramid needs bitabc headroom)
- Option C: CVD×vinslai + Pyramid×bitabc + BOUNCE×vins2 → CHOSEN
- Option D: Defer Wave 3 BOUNCE → kept as fallback

Decision logged in `operator-decisions-2026-05-18.md` v2.

## S4 — Tickets (Day 2-3)

Cross-repo Project #19 created:
- Strategies side: 23 issues + META #327 + Sprint-P milestone + Sprint-Q milestone
- OB-Dev side: 22 issues + META #1773 + M1/M2/M3 milestones
- Total: 45 items cross-repo

META #327 pinned. Two-way linked with #1773.

## S5 — Development (Day 3-15)

Implemented per /A1 protocol. Each ticket:
- TDD red → green → refactor
- Sub-agent review (S6 round)
- Commit + push
- META update + status report

Key commits:
- 3 strategy adapters
- HFV-EQUIV gate added
- A1.1 AVCO + A1.2 CVD indicators + A1.3 cycle_state + A1.4 fixtures
- Phase 1 & 2 infra (risk-budget daemon + stealth-tp)

## S6 — 7-round adversarial review (Day 15-19)

R1 `e501e38`: 3 CRITICAL — taker_buy wiring / CVD TIME unit / Pyramid AVCO doc
R2 `12cbece`: 2 CRITICAL — run_live_cycle taker_buys / BOUNCE cycle stasis
R3 `3b64960`: 5 CRITICAL + 6 HIGH — operator tooling hardening
R4 `f2f6329`: 3 CRITICAL + 5 docs — spec equivalence
R5 `fa1e052`: 4 CRITICAL + 2 HIGH — persistence layer
R6 `e90beee`: 9 integration seam tests
R7 `1fa9066`: 3 doc BLOCKERs + ruff sweep

Total: 12 CRITICAL + 14 HIGH + 18 deferred to Sprint-Q.

Suite: 701 → 772 (+71 tests).

## S7 — Deploy gating (Day 19-22+)

G1 rc2-tag: `v15.5-pathB-rc2` at `1fa9066`
G2 Stage 0: 772/772 + HFV 11/11 + daemons green ✓
G3 Operator decisions: 47 answers typed + GPG-signed + baseline SHA256 set
G4 Calibration: TODO (PF-1 verifies tool exists first)
G5 24h soak: in progress at recap time, ~14/24h
G6 Paper-week: pending G5 complete
G7 executor_live_flip.py: OB-Dev authoring per spec (4-11h)
G8 Sequential flips: Day 22 / 29 / 36 (one feature per week)
G9 Post-flip monitor: 24h each

## Lessons

See `docs/lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md`.

Top 3 takeaways:
1. **7-round review caught 12 CRITICALs** that single-pass would miss
2. **Cross-repo single source of truth (Project #19) prevented merge conflicts** over 3-day parallel work
3. **Operator-decisions v2 strategy×account matrix (47 fields) > single Q1-Q8** for multi-component sprints

## Reusable artifacts

- 5 polished commands (`/sprint-kickoff`, `/A1`, `/A2`, `/A3`, `/MP`)
- 7-round review sub-agent prompt templates
- Cross-repo Project pattern
- META + Project + Milestones + Labels scheme
- GPG + sha256 dual-path operator-decisions verification

This entire methodology repo is the extract.
