---
name: brainstorming
description: Stage-3 brainstorm — produce 2-3 alternatives with explicit trade-offs. Operator picks; decision logged in spec.
type: skill
---

# Skill: brainstorming

## When to invoke

- After S1 spec approved + S2 resources confirmed
- Before S4 ticket creation (decisions inform tickets)

## Execution

Per `docs/stages/03-brainstorming.md`:

1. Read spec + resource confirmation
2. Generate 2-3 alternatives (NEVER just one)
3. Per option: cost (time + token), risk, blast radius, precedent
4. Optional: dispatch sub-agent for adversarial "find 3 ways Option A fails"
5. Present to operator with recommended pick + 1-2 sentence defense
6. Log operator's chosen option in spec under `## Decision YYYY-MM-DD`

## NEVER

- NEVER present 1 option (always ≥2)
- NEVER argue twice if operator overrules
- NEVER strawman alternatives
- NEVER defer decision ("we'll figure it out") — log a real decision

## Acceptance

- ≥2 options presented with trade-offs
- Each option's assumptions listed
- Operator's pick + verbatim rationale logged
- Rejected options + reason cited
