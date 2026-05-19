# Stage 3 — Brainstorm

> **Goal**: Surface 2-3 alternatives with explicit trade-offs; operator picks.
> **Anti-goal**: Consensus-first — when AI agrees with user too readily,
> hidden assumptions ship to production.

## Inputs

- Spec (S1)
- Resource confirmation (S2)
- Operator's preferences (CLAUDE.md / prior sprints)
- Adjacent precedent in `docs/lessons-learned/`

## The brainstorming rule

> Always present 2-3 alternatives. NEVER just one.

If you can only think of one option, the spec is too narrow OR you haven't
brainstormed enough.

## Option presentation format

For each option:

```
### Option A: <short name>

**What it does**: 1-2 sentences
**Cost (time)**: X hours
**Cost (token / compute)**: ~Y in tokens, Z in API/cloud cost
**Risk**: which spec risk does it amplify / mitigate?
**Owner blocker**: who has to do what
**Tested in**: prior precedent (commit / sprint / issue)

| Dimension | Score |
|---|---|
| Reversibility | high/med/low |
| Blast radius | small/med/large |
| Operator dependency | low/med/high |
| Implementation complexity | 1-5 |
```

## Recommended-option rule

You may name a recommendation, but:

- Max 2 sentences of defense
- MUST name a real downside (not "but it's slower" if speed isn't a factor)
- MUST list precedent or domain reason, not "feels right"
- Operator can override silently — don't argue twice

## Surface assumptions

For every option, list what would have to be true for it to work:

```
### Assumptions for Option A
- A.1 Engine's X interface stays stable
- A.2 Operator has time for 7-day soak
- A.3 No upstream regression in dependency Y

If any assumption fails → revisit S3.
```

## Decision log format

When operator picks, log in spec doc under `## Decision YYYY-MM-DD`:

```
## Decision 2026-05-19

**Chosen**: Option A
**Rationale (operator-typed)**: [their words verbatim]
**Rejected**: B (reason), C (reason)
**Risk accepted**: [from B's risk if any]
**Re-eval trigger**: if X happens, revisit
```

Decisions are committed with `docs(decision): S3 pick for <spec>`.

## Brainstorming patterns (when stuck)

### Pattern 1: Status-quo vs. alternative

Always include "do nothing / current path" as Option A. Forces explicit
"the new option must beat status quo by X."

### Pattern 2: Conservative / Standard / Aggressive

Tier risk explicitly:
- Conservative: lower upside, lower blast radius, slower to ship
- Standard: matches sprint precedent
- Aggressive: higher upside, larger blast radius, requires more S6

### Pattern 3: Sub-agent dispatch for adversarial alternatives

Spawn 1 sub-agent prompted: "Find 3 ways the implementer's preferred option
could fail in production. Sort by likelihood."

If sub-agent finds something the operator didn't, that's S3 doing its job.

## Skip conditions (when 1 option is OK)

S3 may compress to "Option A only" if:

- Mechanical fix (typo, lint clean) — but acknowledge in spec
- Spec explicitly says "no flexibility" (e.g. regulatory mandate)
- Reversibility is high AND cost is low — but still self-validate

In all other cases, ≥2 options required.

## Anti-patterns

- **Strawman alternatives**: 2 unrealistic options + "obvious" recommendation
- **Decision deferral**: "let's pick after we try Option A" → that's not a decision
- **Verbal consensus**: not committed to spec doc → forgotten in 2 weeks
- **Self-recommended sub-agent**: dispatch with biased prompt seeking agreement

## Real precedent

AIOT operator-decisions v2 went through brainstorming on strategy-account
assignment:

- Option A: All 3 strategies on vinslai → rejected (margin insufficient)
- Option B: Pyramid×vinslai + CVD×bitabc → rejected (pyramid needs bitabc headroom)
- Option C: CVD×vinslai + Pyramid×bitabc + BOUNCE×vins2 ← chosen
- Option D: Defer Wave 3 BOUNCE → still valid fallback

See [`docs/lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md`](../lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md) §S3.

## Self-validate

- [ ] Did I present ≥2 real options, not strawmen?
- [ ] Did I list each option's assumptions?
- [ ] Did I name precedent for any "recommended" pick?
- [ ] Did I let operator overrule without arguing twice?
- [ ] Is decision logged in spec with verbatim rationale?
