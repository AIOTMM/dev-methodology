# Example walkthrough: SaaS auth migration (hypothetical)

> Companion to `examples/sprint-P-walkthrough.md` showing the same 7-stage
> methodology applied to a non-trading domain. Per `docs/DOMAIN-TRANSLATION.md`,
> trading-domain vocabulary is substituted with SaaS-equivalent terms.
>
> Status: hypothetical (illustrative only, not from a real sprint). Mark
> `[SAAS-EXAMPLE]` so readers know it's not the validated AIOT precedent.

## Sprint scope (SAAS-EXAMPLE)

- 3 endpoint migrations onto new auth (JWT v1 → JWT v2 with refresh tokens)
- Cross-repo: `acme/api` (backend) + `acme/infra` (k8s + IaC)
- 3 tenant groups: enterprise / mid-market / starter
- Promotion waterfall: shadow → canary 1% → canary 10% → 100%

## Translation mapping for this example

| Trading domain | This SaaS example |
|---|---|
| Strategy (Pyramid / CVD / BOUNCE) | Endpoint group (`/auth/login` / `/auth/refresh` / `/auth/revoke`) |
| Account (bitabc / vins2 / vinslai) | Tenant tier (enterprise / mid-market / starter) |
| Paper trade | Canary deployment at 1% traffic |
| 24h soak | Staging burn-in under realistic load |
| LIVE flip | Feature flag flip to 100% via LaunchDarkly |
| Magic phrase | Deploy approval token signed by on-call lead |
| HFV-EQUIV gate | Request-replay golden-fixture regression suite |
| Stealth orders / ghosts | Internal feature flags not exposed to API contract |

## S1 — Spec definition (Day 1)

File: `docs/specs/2026-XX-XX-jwt-v2-migration.md`

```
Context: JWT v1 expires 2026-Q4. v2 adds refresh tokens + shorter access TTL.
Goal:    Migrate 3 endpoints to JWT v2 with zero downtime.
Non-goals:
  - NOT changing rate-limit semantics
  - NOT updating client SDKs (separate sprint)
  - NOT rotating signing keys (separate sprint)
Acceptance:
  1. /auth/login emits v2 tokens; v1 still accepted during grace period
  2. /auth/refresh works with v2 tokens; v1 returns 410 Gone
  3. /auth/revoke invalidates both v1 and v2 tokens
  4. Replay regression suite green (per-endpoint golden fixtures)
  5. Canary rollout 1% → 10% → 100% with zero error-rate spike
Risks:
  - Token re-issue thundering herd → mitigation: gradual rollout
  - Refresh-token replay attack → mitigation: rotation + reuse detection
  - Tenant-specific edge cases → mitigation: per-tier canary
Effort: 5-7 days, 60% confidence
```

## S2 — Resource confirmation (Day 1 same day)

Smoke tests:
- `gh auth status` → authenticated ✓
- `kubectl get ns staging` → reachable ✓
- LaunchDarkly API key → 200 ✓
- Replay-fixture generator (`scripts/gen_auth_fixtures.py`) → works ✓
- Tenant test accounts (3 tiers) → can issue tokens ✓
- Operator energy zone (per `docs/patterns/priority-scoring.md`) → GREEN ✓

Findings: replay fixtures cover 80% of real traffic patterns; 20% gap
documented as risk. Operator accepts.

## S3 — Brainstorm (Day 1-2)

Endpoint-tenant assignment:

- **Option A**: All 3 endpoints on enterprise first → REJECTED (highest blast radius)
- **Option B**: `/auth/login` × starter first (lowest blast, fastest signal) →
  CHOSEN for Wave 1
- **Option C**: `/auth/refresh` × mid-market Wave 2 (refresh is most-used)
- **Option D**: `/auth/revoke` × enterprise Wave 3 (admin-only, slowest)

Priority scoring (per `docs/patterns/priority-scoring.md`):

| Option | Deadline | Energy | EV | Dependency | Score |
|---|---|---|---|---|---|
| A enterprise-first | 0.6 | 0.7 | 0.4 | 0.2 | 0.49 |
| B starter-first    | 0.6 | 0.9 | 0.7 | 0.5 | 0.68 |
| C mid-refresh      | 0.6 | 0.7 | 0.6 | 0.3 | 0.55 |
| D enterprise-revoke| 0.4 | 0.7 | 0.5 | 0.1 | 0.43 |

B-then-C-then-D wins. Decision logged in spec.

## S4 — Tickets (Day 2-3)

Cross-repo Project #100 created:

- `acme/api` side: 18 issues + META + Sprint-Auth-V2 milestone
- `acme/infra` side: 8 issues + META + Sprint-Auth-V2 milestone
- Total: 26 items cross-repo

Cross-linked via two-way META.

## S5 — Development (Day 3-9)

Per /A1 protocol. Highlights:

- Day 3-5: `/auth/login` v2 implementation + replay fixture coverage
- Day 6-7: `/auth/refresh` v2 with reuse detection
- Day 8-9: `/auth/revoke` updates + tenant-aware invalidation
- TDD red per ticket
- Sub-agent review after each ticket
- Conventional commits (`feat(auth): ...`)

## S6 — 7-round adversarial review (Day 9-12)

- **R1**: existing PR review feedback addressed
- **R2**: cross-file consistency (does token validator agree with token issuer?)
- **R3**: operator-tooling hardening — found: deploy script accepted arbitrary
  tenant ID via env var without validation. Fixed.
- **R4**: spec equivalence — replayed v1 → v2 on golden fixtures, verified
  same access claims emitted
- **R5**: persistence — refresh-token table CRUD atomic, replay-attack
  detection idempotent. Found: missing index on tenant_id + token_hash
  caused replay-detect to be O(n) instead of O(log n). Fixed.
- **R6**: integration seams — flush + refresh + revoke sequence E2E test added
- **R7**: ship audit — CHANGELOG missing JWT v1 deprecation notice. Fixed.

Total: 6 CRITICAL caught + fixed.

## S7 — Deploy gating (Day 12-22+)

- **G1**: tag `v2.4.0-rc1` ✓
- **G2**: Stage 0 sanity in staging ✓
- **G3**: On-call lead signs deploy decision file ✓
- **G4**: replay calibration ±0.1% latency tolerance ✓
- **G5**: 24h staging burn-in under realistic load ✓
- **G6**: 7-day canary at 1% → 10% (vs trading's "paper week") ✓
- **G7**: promote_endpoint.py with 9 gates (per `docs/stages/07-deploy-qa.md`)
- **G8**: Sequential 100% rollout:
  - Day 19: `/auth/login` × starter
  - Day 22: `/auth/login` × mid-market
  - Day 25: `/auth/login` × enterprise
  - Day 26-30: `/auth/refresh` per tier
  - Day 31-35: `/auth/revoke` per tier
- **G9**: 24h post-promotion monitor per tier × per endpoint

## Lessons

Same structure as `examples/sprint-P-walkthrough.md` but with SaaS vocabulary.
Validates that 7-stage methodology is genuinely domain-agnostic.

Top 3 takeaways:
1. **Tenant-level sequential rollout** > big-bang prevented enterprise outage
2. **Replay fixtures as HFV-EQUIV equivalent** caught 80% of regressions
3. **Operator-state-aware sprint planning** (S2 §6) avoided deploy on RED day

## Real precedent disclaimer

This walkthrough is **HYPOTHETICAL** for illustration. The numbers,
specific tools, and team layout are invented based on common SaaS patterns.

For a real SaaS team:

- Replace `LaunchDarkly` with your feature-flag system
- Replace `acme/api` `acme/infra` with your repos
- Replace `enterprise/mid-market/starter` with your tenant tiers
- Calibrate canary percentages to your traffic baseline
- Adapt G6 duration to your reversibility tolerance

The 7-stage STRUCTURE transfers. The VOCABULARY is yours to define.

## Comparison to trading walkthrough

| Dimension | Sprint-P (trading) | This (SaaS) |
|---|---|---|
| Risk profile | Money | Customer trust + uptime |
| Reversibility | Within trade hold | Within feature flag toggle |
| Calibration data | Backtest replay | Request log replay |
| Deploy duration | 22 days | 35 days (more tiers) |
| Operator decisions | 47 fields (3×3 matrix) | 12 fields (3 endpoints × 3 tiers) |
| HFV-EQUIV cousin | Trading-bar fidelity | Request-response fidelity |

Same skeleton, different organs.
