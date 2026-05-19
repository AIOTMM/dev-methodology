---
name: spec-writing
description: Write a Stage-1 spec document per the 7-stage methodology. Produces docs/specs/YYYY-MM-DD-topic.md with all 10 required sections.
type: skill
---

# Skill: spec-writing

## When to invoke

- User's first message describes a new feature / sprint
- After S0 brainstorm exists, before any code

## Inputs

- User intent (verbal/text)
- Repo state (`git log`, open issues, existing specs)
- Constraints (CLAUDE.md, sprint discipline)

## Execution

1. Read `docs/stages/01-spec-definition.md`
2. Read `docs/templates/spec-template.md`
3. Use `prompts/spec-kickoff-prompt.md` content as guide
4. Write to `docs/specs/$(date +%Y-%m-%d)-<topic>.md`
5. All 10 sections filled, no `TBD`

## NEVER

- NEVER ship spec with `TBD` / `TODO`
- NEVER include implementation details (those are S5)
- NEVER assume resources work (S2's job)
- NEVER state effort as point value

## Acceptance

- A stranger could implement from this spec
- Every number cites reference
- Operator commits with `docs(spec): <topic>`
