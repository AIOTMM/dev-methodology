# Stage 1 — Spec Definition

> **Goal**: Produce a written spec a stranger could implement.
> **Anti-goal**: "Vibe code" — start typing before scope is fixed.

## Inputs

- User's verbal/text request
- Prior repo state (read `git log`, recent commits, open issues)
- Known constraints (CLAUDE.md, sprint discipline rules, regulatory)
- Existing similar specs in `docs/specs/`

## Required outputs

1. **Spec document**: `docs/specs/YYYY-MM-DD-<topic>.md`
2. **Acceptance criteria** (testable, NOT "feels right")
3. **Scope boundaries**:
   - IN: what this delivers
   - OUT: what's explicitly excluded
   - DEFERRED: what's recognized but pushed to follow-up
4. **Risk register** (top 3-5):
   - Description
   - Likelihood × Impact
   - Mitigation
5. **Effort estimate** with confidence interval (e.g. "8-11h, 70% confidence")

## Spec document structure

Use [`docs/templates/spec-template.md`](../templates/spec-template.md). Required
sections:

```
# Spec: <title>
## Context (why this exists, what triggered it)
## Goal (single sentence)
## Non-goals (3-5 bullets)
## Acceptance Criteria (numbered, testable)
## Approach (high-level, NOT line-by-line code)
## Risk register
## Effort estimate
## Dependencies (other specs / tickets / resources)
## Decision log (filled at S3)
## Sign-off (filled at end of S1)
```

## Operator sign-off gate

S1 → S2 requires:

- [ ] All sections filled
- [ ] No `TBD` / `TODO` left in body
- [ ] Acceptance criteria are testable (a future engineer could write a test
      from each line without further input)
- [ ] Risk register has ≥1 mitigation per risk
- [ ] Operator commits with `docs(spec): <topic>` message

Without these, S2 work is wasted because spec will shift.

## Anti-patterns to avoid

- **Vibe scope**: "make it better" — refuse, demand specifics
- **Mega-spec**: > 1 spec file for 1 feature → split into sub-specs each with own waterfall
- **Verbal-only spec**: "the user said X" — write it down or it never happened
- **Spec with implementation details**: spec is WHAT, not HOW. HOW is S3-S5.
- **No risk register**: if you can't name 3 risks, the spec isn't real

## Time budget

| Project size | Spec effort |
|---|---|
| Single function | 15-30 min |
| 1-file feature | 30-60 min |
| Multi-file sprint | 2-4 hours |
| Multi-repo sprint | 4-8 hours (with stakeholder review) |

If S1 takes > 1 day, the scope is too big. Split.

## Self-validate

After writing the spec:

- [ ] Can a stranger implement this without asking you a question?
- [ ] Are all numbers (effort, tolerances) backed by reference, not vibes?
- [ ] Did I cite prior specs / incidents / tickets where relevant?
- [ ] Are the non-goals specific (not "later we'll do more")?
- [ ] Is the decision log empty and ready for S3 to fill?

## Example

See [`examples/sprint-P-walkthrough.md`](../../examples/sprint-P-walkthrough.md) §S1.
