# Domain translation

> The methodology was extracted from a financial trading system. This file
> maps trading-domain vocabulary to other domains so you can apply the
> methodology to SaaS / CLI / data pipelines / non-trading production
> services without re-thinking everything.

## Concept map

| Trading-domain term | SaaS equivalent | CLI tool equivalent | Data pipeline equivalent | General abstract |
|---|---|---|---|---|
| **Strategy** (Pyramid / CVD / BOUNCE) | Feature / endpoint / tenant | Subcommand / mode | Dataset / job | "feature unit" |
| **LIVE flip** | Production rollout / GA | Version publish | Promote to prod schedule | "activation / promotion" |
| **Paper trade / paper-week** | Canary deployment (1-10% traffic) | Dry-run flag against prod inputs | Shadow run (`--write-to-staging`) | "non-side-effecting validation window" |
| **24h soak** | Staging stability burn-in | Pre-publish smoke loop | Off-peak dry-run | "continuous health window" |
| **Position** | User session / cart / order | Open subcommand context | Active job run | "active stateful unit" |
| **Order book / depth** | Request queue / event log | Stdin buffer | Kafka topic | "event stream" |
| **HARD_STOP** | Circuit breaker | Hard abort flag | Pipeline kill switch | "automatic safety stop" |
| **Account** | Tenant / customer | User-scope config | Owner of pipeline | "isolation boundary" |
| **Magic phrase** | Deploy approval phrase | `--confirm-i-know-what-im-doing` | Cron operator signature | "operator-typed irreversible-action token" |
| **Stealth orders / ghosts** | Hidden feature flag | Internal CLI flag | Side-effect-free intermediates | "implementation-detail not exposed to outside" |
| **mode='live' SQL flip** | Feature flag toggle (LaunchDarkly) | npm publish | DAG enable | "promotion primitive" |
| **Capital allocation** | Resource budget per tenant | Per-user rate limit | Pipeline cost cap | "scarce-resource assignment decision" |

## Examples re-rendered for SaaS

### S7 G6 paper-week → SaaS canary-week

```
G6 Original (trading):
  Run feature in PAPER mode (no real money) for 7 days.
  Daily: 0 × 401, 0 × -1, 100% × 200 API success.

G6 SaaS equivalent:
  Deploy feature behind feature-flag at 1% → 10% traffic over 7 days.
  Daily: error rate ≤ 0.1%, p99 latency within ±10% of baseline,
  zero customer-data inconsistencies in shadow comparison.
```

### S7 G7 flip-script → SaaS feature-flag toggle

```
G7 Original (trading):
  executor_live_flip.py with 9 internal gates including
  `UPDATE strategies SET mode='live' WHERE uuid=?`.

G7 SaaS equivalent:
  promote_feature.py with same 9 gates, ending in
  `launchdarkly.flag('feature-X').set(targeting='100%')`.
```

### NEVER constraints translated

From `prompts/implementer-prompt.md`:

```
Original: NEVER type operator phrases / NEVER deploy / NEVER LIVE flip
SaaS:    NEVER kubectl apply to prod / NEVER run prod migration alone /
         NEVER rotate prod secret unilaterally / NEVER bypass feature flag
```

## When the methodology DOESN'T translate

Some trading-domain concepts have no clean analog:

- **Funding rates / margin liquidation**: financial-system specific, has no
  SaaS counterpart. The G4 calibration±tolerance gate's exact math doesn't
  port; the GATE's PRINCIPLE (regression-tolerance verification) does.
- **HFV-EQUIV bit-equivalence**: trading systems often require deterministic
  replay against historical inputs. SaaS rarely needs this; A/B comparison
  is the closer analog.
- **Paper-mode side-effect avoidance**: easier in trading (mock orders) than
  in SaaS (shadow execution requires more plumbing).

For these, the methodology's structure transfers but the implementation
detail must be re-thought. Document your project-specific instantiation in
your CLAUDE.md.

## Threshold scaling

Trading-system thresholds are calibrated to high-stakes financial risk.
Scale down for lower-stakes projects:

| Stake level | Soak duration | Canary window | Round depth (S6) |
|---|---|---|---|
| Money / safety / regulated | 24h + 7d | All 7 rounds | No skipping |
| Customer data (PII / health) | 12h + 3d | R1, R3, R5, R7 | Full review |
| Customer availability (uptime) | 4h + 1d | R1, R3, R7 | + targeted R5 if DB-touching |
| Internal tools | 1h smoke | R3 only | Spot check |
| Mechanical (typo, lint) | None | None | Skip with explicit flag |

## Adoption protocol

When porting this methodology to your domain:

1. Read this file alongside `METHODOLOGY.md`
2. Substitute terms in your project's CLAUDE.md
3. Copy stage docs verbatim; substitute terms via project glossary
4. Adapt `commands/` to your domain's invocation patterns
5. Replace `examples/sprint-P-walkthrough.md` with a domain-equivalent walkthrough

The methodology's STRUCTURE is domain-agnostic. The vocabulary is the
translation problem this file solves.
