# Pattern: 7-round adversarial review

> Extracted doctrine for running S6 across 7 distinct dimensions, each
> with a dedicated sub-agent prompt template.

## Why 7 (not 3, not 12)

Calibrated to real CRITICAL discovery rate:

- **3 rounds**: finds ~50% of CRITICALs (architectural + persistence layer
  bugs slip through)
- **7 rounds**: finds ~95% of CRITICALs (validated in AIOT v15.5: 12/12
  found, post-deploy zero new CRITICALs)
- **12 rounds**: diminishing returns; rounds 8-12 found 0 new CRITICALs in
  a parallel test

## Round dimensions (do NOT collapse)

Each round attacks a different failure mode. Collapsing rounds = collapsed
coverage:

| Round | Failure mode targeted | "What if implementer forgot..." |
|---|---|---|
| R1 | Existing tool feedback | ...the CodeRabbit/Sonar findings on prior commits |
| R2 | Cross-file consistency | ...to update the OTHER place X is used |
| R3 | Operator tooling safety | ...that user input can be shell-injected |
| R4 | Spec/upstream divergence | ...what spec actually said vs implementation |
| R5 | Persistence atomicity | ...mid-transaction crash leaves DB inconsistent |
| R6 | Integration seams | ...individual fixes are unit-tested but seams aren't |
| R7 | Ship documentation drift | ...CHANGELOG, runbook, README disagree |

## Sub-agent prompt templates

### R1 — CodeRabbit / existing feedback

```
Adversarial review Round 1: existing feedback sweep.

Inputs:
- Commit range: <range>
- Existing review URLs: <list>
- Code path: <repo>

Task: For each open external-review finding (CodeRabbit, Sonarqube, manual
PR comments), classify: addressed in this commit range / deferred / dispute.
For deferred items, recommend: fix-now / accept-with-rationale / new-issue.

Output: structured table. Cap 1500 words.

NEVER soften findings to be polite.
```

### R2 — Architectural consistency

```
Adversarial review Round 2: architectural consistency.

Inputs:
- Files touched: <list>
- Function signatures changed: <list>
- Schema migrations included: <list>

Task: For each touched file, grep callers / importers / consumers. Find every
place where the change makes prior invariant false. Examples:
- New required arg added → old callers broken
- Schema migration with no rollback path
- Interface method removed → downstream silently calls undefined

Sort by blast radius. Cap 2000 words.

The implementer's most common mistake at this round: "I updated where I
remembered, forgot the OTHER place."
```

### R3 — Operator tooling hardening

```
Adversarial review Round 3: operator tool attack surface.

Inputs:
- Scripts that take user input: <list>
- Scripts called from cron / systemd / docker exec: <list>

Attack surface checklist:
- Shell injection (DB content → echo → bash)
- Path traversal (user-supplied path → file read)
- Silent PASS on missing dependency (gh not installed → PASS instead of FAIL)
- Bypass flag combinations (--skip A --skip B → all skipped → PASS)
- Hardcoded credentials in scripts
- Unescaped variables in SSH command strings
- Cron expressions that look right but aren't (`*/240 * * * *` = every hour, not 4h)

Output: severity-sorted, file:line, exploit example, fix.
Cap 2500 words.
```

### R4 — Spec/upstream equivalence

```
Adversarial review Round 4: spec/upstream divergence.

Inputs:
- Spec or upstream source: <commit / file>
- Implementation: <commit / file>
- Documented divergences: <DIVERGENCES.md content>

Task: line-by-line diff implementation against spec/upstream. Find every
semantic divergence NOT already in documented-divergences. For each:
- Cite spec line vs impl line
- Impact (drift in metric / behavior delta)
- Whether documented or hidden

Cap 3000 words. List every divergence, even minor.
```

### R5 — Persistence / data layer

```
Adversarial review Round 5: persistence atomicity + crash safety.

Inputs:
- DB schema files: <list>
- DB write paths: <list>
- Migration scripts: <list>

Probe questions:
- Every multi-step DB write: in single transaction?
- Every PRAGMA: set per-connection (not once-globally)?
- Every migration: idempotent if re-run?
- Schema constraints (CHECK / FK / NOT NULL): enforced?
- Concurrent writer safety: BUSY_TIMEOUT? WAL mode? journal sync?
- Crash recovery: half-written rows surface as clear errors?
- Down-migration / rollback path exists?

Output: per-finding severity + data-loss risk + fix.
Cap 3000 words.
```

### R6 — Integration coverage seams

```
Adversarial review Round 6: integration test gaps.

Inputs:
- Test files: <list>
- R1-R5 fix summary: <findings>

Task: For each R1-R5 fix, identify what UNIT tests cover it. Then identify
what INTEGRATION seam between fixes is NOT covered:
- Fix A + Fix B both unit-tested. Does combining them produce expected behavior?
- Fix C is mid-flow. Does end-to-end full-flow test exercise C?
- State change A→B→C: does test exercise the transitions, or just states?

Output top 9 seam gaps with test names.
Cap 2500 words.
```

### R7 — Final ship audit

```
Adversarial review Round 7: ship readiness.

Inputs:
- README.md, CHANGELOG.md, runbook paths: <list>
- Current HEAD: <commit>
- Sprint scope: <issues>

Checks:
- Runbook test count matches HEAD's test count?
- Runbook commit hash matches HEAD?
- CHANGELOG lists every R1-R6 fix by commit hash?
- "ruff clean" / "lint clean" claims scoped correctly?
- Every "deferred" item has a follow-up issue with cite?
- README features match what code does?
- Spec acceptance criteria all checked?

Output: list every drift, severity, fix.
Cap 2000 words.

GO / NO_GO recommendation at end with top-3 reasons for each.
```

## Multi-round commit chain

After each round, commit with conventional prefix tagging the round:

```
fix(<sprint> QA-R1): 3 CRITICAL + 1 HIGH — existing-feedback sweep
fix(<sprint> QA-R2): 2 CRITICAL — architectural consistency
fix(<sprint> QA-R3): 5 CRITICAL + 6 HIGH — operator tooling hardening
fix(<sprint> QA-R4): 3 CRITICAL + 5 docs — spec equivalence
fix(<sprint> QA-R5): 4 CRITICAL + 2 HIGH — persistence layer
test(<sprint> QA-R6): 9 integration seam tests
docs(<sprint> QA-R7): 3 doc BLOCKERs + ruff sweep
```

## Round-skip rules

| Scope | Required rounds |
|---|---|
| Production code touching money / safety | All 7, no skip |
| Production code other | R1, R3, R5, R7 (minimum) |
| Internal tool | R3, R5, R7 |
| Spec / doc-only | R1, R7 |
| Mechanical (rename, lint) | None — but flag explicitly |

## What this pattern DOES NOT do

- Code review for STYLE (formatting, idioms) — different audit
- Performance optimization — different audit
- Refactoring suggestions for "cleaner code" — different audit
- New-feature ideation — that's S1 spec, not S6 review

## Real precedent

AIOT v15.5 Sprint-P: 7 rounds caught 12 CRITICAL bugs across commits
`e501e38 → 1fa9066`. Post-deploy: 0 new CRITICAL bugs in 24h soak +
7-day paper trade.

## Self-validate

- [ ] All 7 rounds dispatched (or compressed-with-rationale)
- [ ] Each round's findings committed with conventional prefix + count
- [ ] Suite green after EACH round, not just at end
- [ ] CRITICAL findings: 100% addressed
- [ ] HIGH findings: 100% addressed or operator-typed acknowledgement
- [ ] MEDIUM/LOW: 100% triaged to follow-up issues (never silent)
