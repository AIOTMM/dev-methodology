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
