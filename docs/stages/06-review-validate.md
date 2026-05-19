# Stage 6 — 7-Round Adversarial Review

> **Goal**: Find what implementer missed BEFORE production catches it.
> **Anti-goal**: "It looks good" — single-pass self-review ships CRITICAL bugs.

## Why 7 rounds?

Real data from AIOT v15.5 Sprint-P (2026-05-19):

| Round | CRITICAL found | What single-pass would have missed |
|---|---|---|
| R1 | 3 | engine taker_buy plumbing / CVD TIME unit / Pyramid AVCO doc |
| R2 | 2 | run_live_cycle taker_buys missing / BOUNCE cycle stasis |
| R3 | 5 | shell injection / local-smoke bypass / gh silent PASS / uuid / env |
| R4 | 3 | BOUNCE exit slippage / Wilder RSI variant / Pyramid hysteresis |
| R5 | 4 | multi-leg hydration / bulk-delete / synchronous=FULL / FK PRAGMA |
| R6 | 0 (9 integration seam gaps) | parity tests / multi-restart lifecycle |
| R7 | 0 (3 doc BLOCKERs) | CHANGELOG / runbook drift / ruff scope |

**Total: 12 CRITICAL bugs caught**. Single-pass would have shipped most.
Each round attacks a DIFFERENT dimension; lower-round dimensions don't
catch upper-round failure modes.

## The 7 dimensions

### R1 — CodeRabbit / existing feedback sweep

Tool-emitted feedback (CodeRabbit, Sonarqube, etc.) addressed first because
it's cheap to dismiss but costly to ignore.

Dispatch prompt:
```
Review the CodeRabbit feedback at <URLs> against the current branch.
For each finding: address, dispute (with reason), or defer (with issue).
Output structured.
```

### R2 — Architectural consistency

Cross-file invariants. E.g. function signatures, schema versions,
interface contracts. Most CRITICAL bugs at this round = "I forgot to
update the OTHER place X is used."

Dispatch prompt:
```
Adversarial architectural review. Scan all touched files PLUS files that
import or depend on them. Find every place an invariant is now violated.
Sort by blast radius. Cap 1500 words.
```

### R3 — Operator tooling hardening

Scripts that take user input or DB content. Common failure: shell
injection via unquoted variable, path traversal, command escalation.

Dispatch prompt:
```
You're attacking the operator tools. Find: shell injection, path traversal,
silent PASS on broken external dependency, bypass flag combinations,
hardcoded credentials, unescaped user input. Sort by severity.
```

### R4 — Spec/upstream equivalence

Does the implementation match the spec? If porting from upstream, does
it match upstream's semantics?

Dispatch prompt:
```
Line-by-line compare implementation against spec/upstream at <commit>.
Find every semantic divergence not documented in SOURCE_COMMIT.md or
spec's "Decision log". Sort by impact.
```

### R5 — Persistence / data layer

Atomicity, crash safety, schema versioning, concurrency. Database bugs
have permanent blast radius.

Dispatch prompt:
```
Atomic-failure audit. For every DB write: can it be partially applied?
For every PRAGMA: is it set per-connection? For every schema migration:
is it idempotent + crash-safe? Sort by data-loss risk.
```

### R6 — Test coverage seams

R1-R5 found unit-level bugs. R6 finds INTEGRATION-level gaps: do the
seams between fixes actually work end-to-end?

Dispatch prompt:
```
Find 18 coverage seams between the R1-R5 fixes. For each: what regression
would NOT be caught by current tests? Generate test names. Top 9 = mandatory.
```

### R7 — Final ship audit

CHANGELOG drift, README staleness, runbook consistency. The "softer" final
pass. Real precedent: R7 found 3 doc BLOCKERs that would have HALTED Stage 0.

Dispatch prompt:
```
You are about to ship to staging. Audit: runbook test counts match HEAD,
CHANGELOG reflects all R1-R6 changes, ruff/lint clean claims are scoped
correctly, every "deferred" item has a follow-up issue. List every drift.
```

## Round execution protocol

For each round:

```
1. Dispatch code-reviewer sub-agent with adversarial prompt for this round
2. Sub-agent outputs structured findings: severity / file:line / impact / fix
3. Triage:
   - CRITICAL → fix immediately + add regression test + commit
   - HIGH → fix this round OR documented operator acknowledgement
   - MEDIUM/LOW → triage to follow-up issue (NEVER silently leave)
4. Commit per round with conventional prefix: `fix(<sprint> QA-RN): N CRITICAL + M HIGH`
5. Run full suite + lint after each round (regression sanity)
6. Update META issue with round summary
7. NEVER batch rounds into one commit
```

## Round size discipline

Each round prompt: cap 3000 words output. Past 3000 → sub-agent is bloating
to look thorough. Trust signal: short prompt + dense findings.

## When 7 rounds is too many

For non-production code (internal tool, prototype, doc-only change), compress:

| Scope | Rounds required |
|---|---|
| Production code | 7 (no compression) |
| Internal tool | 3-4 (R3 + R5 + R7) |
| Spec / doc-only | 1-2 (R1 + R7) |
| Mechanical (rename, lint) | 0 (skip S6) — but flag risk explicitly |

## When 7 rounds is not enough

If after R7 the code still feels wrong:

- That's a spec problem (return to S1)
- OR an unstated requirement (return to S3 brainstorm)
- NEVER add R8 unless it's a new dimension (not "more of R5")

## Sub-agent quality discipline

After each round:

- [ ] Did sub-agent cite file:line? (if not, dispatch again with tighter prompt)
- [ ] Are findings actually defects, or coding style? (filter style → MEDIUM)
- [ ] Did sub-agent find ≥1 CRITICAL? (round 1-5: should find ≥1; if not,
      either implementation is amazing OR prompt was weak)
- [ ] Did sub-agent invent fake severity? (cross-check with code)

## Real precedent

AIOT v15.5 7-round chain: `e501e38 → 12cbece → 3b64960 → f2f6329 →
fa1e052 → e90beee → 1fa9066`. Suite 701 → 772 (+71 tests, 18 from QA
rounds). Each round commit body lists found CRITICAL count.

## Self-validate (end of S6)

- [ ] All 7 rounds dispatched (or compressed-with-reason)
- [ ] Each round commit conventional + cites finding count
- [ ] Suite passes after EACH round (not just at end)
- [ ] All CRITICAL fixed + regression-tested
- [ ] HIGH triaged (fix or accepted)
- [ ] MEDIUM/LOW each in a follow-up issue
- [ ] META updated with round-by-round summary
- [ ] No silent ignores
- [ ] Sprint-Q backlog has every deferred item
