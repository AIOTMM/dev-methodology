---
name: adversarial-review
description: Run S6 7-round adversarial review on a scope. Dispatches code-reviewer sub-agents per dimension, triages findings, commits per-round.
type: skill
---

# Skill: adversarial-review

## When to invoke

- After S5 implementation feels complete
- Before any LIVE flip
- After CRITICAL bug shipped (increase rigor next sprint)

## Inputs required

- `<scope>`: commits / files / module
- `<sprint-name>`: for commit prefix
- `<rounds>`: which rounds to run (default: all 7 for production code)

## Execution

For each round in scope:

1. Read `docs/patterns/adversarial-review-7-rounds.md` for round template
2. Dispatch sub-agent (use `prompts/reviewer-prompt.md`)
3. Triage findings (CRITICAL → fix + test; HIGH → fix or escalate; MED/LOW → follow-up issue)
4. Commit with conventional prefix: `fix(<sprint> QA-R<N>): <C/H/M/L count> — <round name>`
5. Run full suite + lint after each round
6. Update META with round summary

## NEVER

- NEVER batch rounds into one commit
- NEVER skip a round to save time without operator approval
- NEVER ignore CRITICAL findings
- NEVER claim "passed" without sub-agent dispatch (self-review insufficient)

## Acceptance

- All scoped rounds executed
- Each round has commit + finding count
- Suite green after each round
- All CRITICAL findings closed
- Follow-up issues for MED/LOW

## Real precedent

AIOT v15.5: 7 rounds caught 12 CRITICAL bugs. Without this skill, those
would have shipped.
