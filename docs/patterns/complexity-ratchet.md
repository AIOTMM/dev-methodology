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

1. **Automated tests** — encode what "correct" means as executable constraints
2. **Documentation** — record WHY decisions were made (not just WHAT the code does)
3. **Evaluation results** — establish quality thresholds with comparative scoring

The next AI agent iteration **loads all three into context simultaneously**.
The agent literally cannot regress below these baselines because they're
embedded in its working environment.

> **"The tests remember."** — Garry Tan. Nobody on the team needs to remember
> WHY weight rounding matters (Holder Confusion case): the 17 contract tests
> enforce it forever.

## Tech debt vs Complexity Ratchet (CRITICAL distinction)

These two concepts are OPPOSITES, not synonyms:

| Dimension | Tech Debt | Complexity Ratchet |
|---|---|---|
| Direction | bad accumulates | good baseline accumulates |
| Goal | minimize | maximize |
| Reversibility | refactor to pay off | forward-only (this is a feature) |
| Metaphor | bank interest | socket wrench |
| Origin | shortcut under deadline pressure | normal dev produces it automatically |
| Management | sprint budget for repayment | bake (test + doc + eval) into PR template |

> "A ratchet is a mechanism that allows motion in one direction only. A
> socket wrench turns a bolt forward and prevents it from turning back...
> The quality floor goes up with every turn. Forward-only motion. That's
> the ratchet."

## "Everything harnessable is testable" (Garry ch01 extension)

The ratchet is not limited to unit tests. **Anything observable becomes
assertable becomes ratcheted**:

| Layer | What to test | Example |
|---|---|---|
| OS | filesystem / cron / DB schema state | migration created table? cron fired? |
| Terminal (TTY) | agent behavioral contracts | did Claude ask the interactive question? |
| Browser | rendered output, form fill | does the page mount, does submit POST? |
| API | request/response schema | does response match JSON Schema? |
| Agent behavior | protocol compliance | does agent confirm before destructive ops? |

This is what the **GStack TTY test harness** (Case 2 below) accomplishes:
testing AGENT BEHAVIOR, not just code behavior.

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

## 3 canonical Garry case studies (ch04)

Garry's article showcases 3 real cases. Each demonstrates the exact
ratchet turn: **problem → add (test + doc + eval) → quality floor permanently rises one notch**.

### Case 1: GBrain "Holder Confusion"

- **System**: epistemological extraction across 28K pages
- **Problem**: V1 misattributed claim-holder in 35% of cases (cross-model
  eval scored 6.8/10)
- **Ratchet response**:
  - Tests: **17 contract tests**
  - Documentation: **6 failure modes documented**
  - Architecture: **weight rounding enforced at DB layer** (no fake 0.74
    precision; must round to 0.05 increments)
- **Effect**: "**The tests remember.**" Future extraction cannot ship below
  6.8/10 baseline. Nobody needs to remember WHY weight rounding matters —
  the tests enforce it.

### Case 2: GStack "TTY Test Harness"

- **System**: GStack interactive review skill
- **Problem**: Claude Code occasionally **skipped entire interactive
  conversation**, dumping findings + exiting. Defeats interactive design.
- **Untestable challenge**: "How do you unit-test 'did the AI have a
  conversation'?"
- **Ratchet 3-layer response**:
  - Layer 1: **STOP gates in skill prompt** (anti-rationalization
    clauses, MUST-ask-before-next-section)
  - Layer 2: **Anti-shortcut clause** ("Plan file is the OUTPUT of
    review, not a SUBSTITUTE for it")
  - Layer 3: **TTY harness test** — spawn Claude in pseudo-terminal,
    watch real-time output, fail if no interactive question fired
- **Effect**: Tests AGENT BEHAVIORAL CONTRACTS at the TTY level. Expands
  testing's definition from "code behavior" to "agent behavior".

### Case 3: OpenClaw Plugin E2E (PR #880)

- **System**: GStack OpenClaw plugin ecosystem
- **Problem**: how to test "plugin actually loads + runs" beyond compile?
- **Ratchet response**: **359-line end-to-end test** spanning 2 separate processes:
  1. Build plugin from source
  2. Spawn isolated OpenClaw instance
  3. Install plugin via CLI
  4. Verify runtime load via `plugins inspect`
  5. Set + validate config
  6. Confirm `plugins doctor` shows 0 diagnostics
- **Pattern**: "359 lines of test code. The kind of test humans almost
  NEVER write because setup is too tedious. Claude wrote it in 5 minutes.
  **That's the effort wall disappearing in real time.**"

### What these 3 cases prove

> "**Ratchet is not 'add more unit tests'.** It is 'for every lesson learned,
> lock an executable check into the codebase'."

Action for your repo: pull incident log → for each incident, write (test +
doc + eval) trio. Next incident cannot be the same incident.

## 8 AI-test-writer workflows (Garry ch06)

| Workflow | Use case | AI strength |
|---|---|---|
| 1. Coverage gap → AI batch-generate | Push 65% → 90% | ⭐⭐⭐⭐⭐ |
| 2. Bug-fix → regression test | Production incident → fix | ⭐⭐⭐⭐⭐ |
| 3. PR diff coverage gate | Every PR must add tests for new lines | CI-enforced |
| 4. AI catches fake tests | Code-review for `assert True` / mock-mock-pass | ⭐⭐⭐⭐ |
| 5. Property-based discovery | LLM proposes invariants | ⭐⭐⭐⭐ |
| 6. Mutation-driven test refinement | Mutmut score → AI patches failing tests | ⭐⭐⭐⭐ |
| 7. Flake-investigation loop | Investigate + fix flaky tests | ⭐⭐⭐ |
| 8. Test suite refactor | Reduce duplication, improve fixtures | ⭐⭐⭐⭐ |

**Critical prompt addition** (anti-mirror-implementation):

> "IMPORTANT: Write tests based on the docstring and intended behavior,
> NOT by mirroring the implementation. If implementation has bugs, the
> test should catch them."

Without this prompt, AI generates tests that mirror buggy code → tests
pass but actual behavior is wrong → false confidence.

## Garry × Dex synthesis (ch09)

| Concept | Owner | Side it covers |
|---|---|---|
| 12-factor agents | Dex Horthy | **Building** side — how to construct controllable LLM apps |
| 90% test coverage | Garry Tan | **Verification** side — how to verify AI-produced software |

Together: **production-grade AI application**.

Garry quote (terminal insight):
> "The companies that win the next 24 months won't be the ones with the
> fastest agents... They'll be the ones with the **strongest guardrails**."

12-factor = guardrail blueprint. 90% coverage = guardrail load-test.
Both = real guardrail.

### Organization 4-quadrant map

```
              ↑ 12-factor adoption
              │
   Type C     │     Type D ★ (target)
   over-eng   │     production-ready
   pretty arch│     arch + verification
              │
   ━━━━━━━━━━━┿━━━━━━━━━━→ 90% coverage
              │
   Type A     │     Type B
   early-stage│     reactive QA
   weak both  │     tests strong, agent loose
              │
              ↓
```

Most AI startups stuck Type A. Some big-co Type C (pretty architecture but
no tests). Few mature Type B (tested but agent loose). Rare Type D (both).

**Garry + Dex methodology = playbook to push organization to Type D from
any starting quadrant**.

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
