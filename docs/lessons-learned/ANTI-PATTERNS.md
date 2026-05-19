# Anti-patterns

Real failures observed across AIOT v15.5 + Sprint-P. Each one has a "if you
catch yourself doing X" → "do Y instead".

## AP-1 — Skip S1 / S2 because spec is "obvious"

**Symptom**: write code → hit unknown resource → 4h debug
**Catch**: any "should work" should be smoke-tested
**Fix**: redo S2

## AP-2 — Vibe scope ("make it better")

**Symptom**: 3 days in, scope unbounded
**Catch**: spec without testable acceptance criteria
**Fix**: redo S1 with measurable criteria

## AP-3 — Mega-ticket (3+ deliverables in one issue)

**Symptom**: ticket open 2 weeks, blocks other work
**Catch**: ticket description has "and" or "also"
**Fix**: split

## AP-4 — Single-pilot Q1-Q8 for multi-component sprint

**Symptom**: operator-decisions doesn't cover real complexity
**Catch**: 1 form for N components
**Fix**: per-component decision matrix (Sprint-P operator-decisions v2)

## AP-5 — Manual SQL LIVE flip

**Symptom**: deploy day, `UPDATE strategies SET mode='live'` typed in
**Catch**: no flip-script issue
**Fix**: dedicated executor_live_flip.py with 9 gates

## AP-6 — Sub-agent dispatch for <3 file lookup

**Symptom**: token waste, slow turnaround
**Catch**: dispatching "go find X in repo"
**Fix**: direct grep / Read

## AP-7 — "Trust me" sub-agent reports

**Symptom**: ship findings without verifying changes match
**Catch**: claim "did X" without code-level evidence
**Fix**: read the diff, not the report

## AP-8 — Skip S6 because change is "small"

**Symptom**: 12 CRITICAL bugs ship to production
**Catch**: production code without per-round adversarial audit
**Fix**: ALL production-touching code goes through ≥1 review

## AP-9 — Magic-phrase reuse

**Symptom**: same phrase used for multiple LIVE flips
**Catch**: phrase doesn't include sprint + date + strategy
**Fix**: per-flip dated phrase

## AP-10 — Ignore "should be reachable"

**Symptom**: assume cron, daemon, container alive
**Catch**: no `systemctl is-active` / `docker ps` verification
**Fix**: smoke every assumed-running thing

## AP-11 — Operator state ignored (vinsai_AI sprint, 2026-03-31)

**Symptom**: schedule deep-cog sprint work at RED energy zone → bug rate
spikes + operator burnout
**Catch**: spec assumes "8h focused work" without checking biometric/state
**Fix**: S2 includes operator energy zone (WHOOP recovery or self-report).
Match cognitive demand to zone (`docs/patterns/priority-scoring.md` §energy).

## AP-12 — Single-LLM cross-check assumed sufficient (vinsai brainstorm precedent)

**Symptom**: same LLM reviews its own work; correlated biases pass
**Catch**: review verdict unchallenged across multiple rounds
**Fix**: S6 R3 (tooling) + R5 (persistence) — invest in cross-LLM
(Codex / Gemini / Claude) when stakes warrant. Per vinsai_AI brainstorm:
"引入其他的 LLM 來避免陷入樂觀、幻覺".

## AP-14 — Vibecoding (NL prompts without ratchet)

**Symptom**: AI-assisted dev with natural-language prompts only, no
per-cycle test/doc/eval artifacts. Quality regresses silently; bugs
surface only when users report.
**Catch**: any sprint commit without "+N tests" line, or coverage decreases
without operator-typed acceptance.
**Fix**: per `docs/patterns/complexity-ratchet.md`, every cycle adds
tests + docs + evals. Coverage CI gate forbids regression.

## AP-15 — Markdown wall-of-text for substantive analyses

**Symptom**: 50-line markdown report nobody re-reads; structure lost in
flat prose.
**Catch**: report-tier output (analysis, retro, review) generated as
`.md` only with no structural commitment.
**Fix**: per `docs/patterns/structure-as-html.md`, anything with
re-read + structure triggers HTML output (Level 2+).

## AP-16 — Prompt outsourced to framework

**Symptom**: LangChain / LlamaIndex / framework hides actual prompt;
debugging by reverse-engineering template internals.
**Catch**: cannot show the exact tokens sent to LLM during last call.
**Fix**: per `docs/patterns/twelve-factor-agents.md` Factor 2, prompts
versioned in git as code, every character visible.

## AP-17 — Agent monolith (>10 tools in one agent)

**Symptom**: one "universal assistant" agent with 20+ tools, context
window > 50% utilization, frequently loses focus mid-task.
**Catch**: agent definition has more than 10 tools OR median task takes
> 20 steps.
**Fix**: per `docs/patterns/twelve-factor-agents.md` Factor 10, split
into micro-agents (≤ 10 tools, ≤ 10 steps median) + deterministic
orchestrator.

## AP-13 — Frozen formula never re-calibrated

**Symptom**: priority scoring weights (0.35/0.25/0.25/0.15) set in week 1,
never tested against outcome data
**Catch**: same weights surviving multiple sprints unchanged
**Fix**: re-calibrate at retro using completion rate vs. predicted priority
correlation. Update weights with logged rationale.
