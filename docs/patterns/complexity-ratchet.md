# Pattern: Complexity Ratchet (AI-era quality compounding)

> Extracted from Garry Tan's "AI Agent Complexity Ratchet" thesis (Y Combinator
> 2026). The mechanism that makes AI-assisted development a quality-only
> direction—never quality-down.
>
> Source: `https://github.com/vins-hub/garrytan-complexity-ratchet-zh`

## Core thesis

**AI doesn't experience effort.** The brutal final 20% of test coverage—
impractical for human teams pre-2025—aligns perfectly with agent strengths.

This eliminates the economic barrier to 90%+ coverage:

> "Getting to 90% used to be a heroic effort. Now it's a Tuesday."

## The ratchet mechanism

Each AI coding session adds **3 forward-only artifacts** to the codebase:

1. **Automated tests** — encode correctness as executable constraints
2. **Documentation** — capture the WHY behind decisions, not just WHAT
3. **Evaluation metrics** — quantify quality thresholds with comparative scoring

The next AI agent iteration **loads all three into context simultaneously**.
The agent literally cannot regress below these baselines because they're
embedded in its working environment.

## Verification bottleneck (the new constraint)

For 60 years software's bottleneck was production speed. AI agents have
**eliminated** that constraint. The new bottleneck:

| Era | Bottleneck | Solved by |
|---|---|---|
| 1960s | Memory / compute | Moore's Law |
| 1980s | UI complexity | Frameworks |
| 2000s | Web scale | Cloud |
| 2010s | Dev speed | DevOps / CI-CD |
| **2025+** | **Verification** | **Complexity ratchet (this pattern)** |

Human attention is the physical limit: ~500 LOC/8h review capacity, unchanged
in 30 years. AI-generated code creates a verification deficit that human
review alone cannot close.

## 3-layer verification (the new baseline)

```
Static verification   → types, lints, code analysis (fast, cheap, misses behavior)
Test verification     → unit + integration + E2E (catches behavioral within scenarios)
Production verification → feature flags, canary, monitoring (real-world at user expense)
```

Each layer catches what the prior misses. None alone is sufficient.

## 90% coverage threshold (calibrated, not magical)

Capers Jones 10K-project meta-analysis:
- < 70% coverage → ~70% defect removal
- **85-95% coverage → 92-97% defect removal**
- DO-178C (FAA avionics) > 99% with strict coverage gates

90% is **economic, not statistical**:
- Pre-AI: writing tests cost human willpower at 5-10 tests / day. 80%→90% =
  multiple months of effort. Marginal cost > marginal benefit at ~80%.
- Post-AI: writing tests at $0.001/test (Claude API). Marginal cost ≈ 0.
  New equilibrium is 90%+.

## Aggregate-weighted coverage (not per-file 90%)

Coverage targets differ by criticality:

| Layer | Target | Rationale |
|---|---|---|
| Payment / financial paths | 95-100% | money loss = non-recoverable |
| Core business logic | 90-95% | shipping bugs costs trust + rework |
| Backend integration | 85-90% | regression-tested via integration |
| UI layer | 70-85% | E2E covers happy path, unit covers logic |
| Generated / mechanical code | 60-75% | low semantic complexity |

**Aggregate weighted** = 90%. Per-file 90% is vanity.

## 6 test types (full coverage requires all 6)

| Type | % of effort | Targets | AI suitability |
|---|---:|---|---|
| **Unit** | 70% | Function logic, edge cases | Excellent (millisecond execution) |
| **Integration** | 20% | Module interactions, real DB/API in single process | Good (use testcontainers, not mocks) |
| **E2E** | 5% | Full system, user journeys | Limited (5-15 critical journeys only; slow + flaky) |
| **Property-based** | 3% | Mathematical invariants over generated inputs | Excellent (Hypothesis, fast-check) |
| **Mutation** | meta | Verify tests actually catch bugs | Good — required quality gate |
| **Fuzz / Snapshot** | 1% | Random input resilience, UI output | Domain-specific |

**Key principle**: 90% coverage from one type alone = false safety net.
Each type catches different failure layers.

**Mutation score ≥ 75%** validates the suite isn't self-deceiving (does the
test actually fail when the code is wrong?).

## 10 testing anti-patterns

### Critical (#1-3, immediate fix required)

1. **`assert True`** — asserts that verify nothing
2. **Mirror-implementation tests** — same constants in test and code, so
   passes mean nothing
3. **Over-mocking** — every dependency mocked; passes locally, fails in prod

### Structural (#4-7)

4. **Oversized tests lacking isolation** — one test depends on side effects of another
5. **Abandoned `@skip` tests without expiration** — silent decay
6. **Exception-swallowing try/except** — error masked as success
7. **Order-dependent suite** — `pytest -p random_order` would reveal coupling

### Cultural (#8-10)

8. **Flaky tests accepted as "normal"** — they're not; root-cause + fix
9. **LOC as success metric** — covers everything, asserts nothing
10. **Manual QA as automated-coverage substitute** — humans miss regressions

> **80% coverage is more dangerous than 60%** — creates false confidence.
> Fix anti-patterns BEFORE pursuing higher coverage.

## 12-week implementation roadmap

| Week | Phase | Deliverable |
|---|---|---|
| 1-2 | Measure | Baseline coverage + per-module + mutation score in critical paths |
| 3-4 | Attack high-risk systems | AI-generated unit tests → 95%+ on top-3 systems |
| 5-6 | Business logic | git-history hot-file targeting → batch test generation |
| 7-8 | Integration + E2E | API endpoint coverage + 5-15 critical user flows |
| 9-10 | Mutation + cleanup | Mutation analysis + remove false/fake tests |
| 11 | CI hardening | Diff coverage gate + anti-pattern lint |
| 12 | Final audit | Verify targets + lessons-learned commit |

Estimated cost: $35-45K for 12 weeks (AI tools + infra + human review).
ROI: < 1 production incident's cost.

## How this ratchets dev-meth's existing stages

| Stage | Pre-ratchet | Post-ratchet (this pattern) |
|---|---|---|
| **S5 Develop** | TDD + sub-agent review | Add: every commit raises coverage OR justifies decrease |
| **S6 Review (R6)** | Integration seams audit | Add: mutation-score audit (≥75%) |
| **S7 G4 calibration** | ±10% PnL parity (trading) / ±X% (general) | Add: coverage regression check (current ≥ baseline) |

## Anti-pattern: vibecoding without the ratchet

> "Projects using vibecoding (natural-language-only prompts) without the
> ratchet consistently fail around moderate complexity, as regression goes
> undetected until users report failures."

The methodology's `/A1` per-step sub-agent review IS the ratchet's S5
instance. The 7-round S6 IS the ratchet's verification layer. Without these,
AI-assisted development is vibecoding.

## Integration with Structure-as-HTML

The ratchet's 3rd artifact (eval records / quality thresholds) lives most
effectively as HTML (see `docs/patterns/structure-as-html.md`):

- Coverage report → HTML with severity color (red < 70 / yellow 70-89 / green ≥ 90)
- Mutation score → HTML table with per-module breakdown
- Quality trend over commits → inline SVG chart in HTML
- 12-week roadmap progress → HTML dashboard with sticky TOC

Markdown coverage reports get ignored. HTML coverage reports get reviewed.

## Integration with 12-Factor Agents

The complexity ratchet pairs with 12-factor agents (see
`docs/patterns/twelve-factor-agents.md`):

- **Factor 2 (Own prompts)**: prompts versioned + tested
- **Factor 8 (Own control flow)**: deterministic gates that enforce coverage
- **Factor 12 (Stateless reducer)**: each iteration adds artifacts; pure forward motion

## Self-validate

- [ ] All 3 ratchet artifacts produced per session (tests + docs + evals)
- [ ] Coverage measured per-module, aggregate weighted, not vanity
- [ ] Mutation score ≥ 75% on critical paths
- [ ] All 10 anti-patterns absent from new commits
- [ ] CI gate: diff coverage cannot decrease without explicit operator override
- [ ] Per-issue acceptance includes "+N test cases" line in commit body
