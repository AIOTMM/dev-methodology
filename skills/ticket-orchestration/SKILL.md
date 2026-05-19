---
name: ticket-orchestration
description: Create GitHub milestones + labels + per-issue tickets + META tracking + Project board for a sprint per S4 methodology.
type: skill
---

# Skill: ticket-orchestration

## When to invoke

- Sprint kickoff after S1-S3 complete
- Adding a major scope chunk to existing sprint

## Inputs

- Spec doc (S1 output)
- Decision log (S3)
- Effort estimates per work unit

## Execution

Per `docs/stages/04-ticket-creation.md`:

1. Verify `gh auth` + repo + existing labels/milestones
2. Create milestones (≥2: PRE-LIVE / LIVE-flip / follow-ups)
3. Create labels (priority, type, sprint, area)
4. Create per-issue tickets using `docs/templates/ticket-template.md`
5. Create META tracking issue, pin it
6. Create Project board, add all tickets

## NEVER

- NEVER ticket without acceptance criteria
- NEVER owner = "us" or "TBD"
- NEVER skip dependency chain documentation
- NEVER pin META with `TBD` sections

## Acceptance

- META pinned with all P0/P1 listed
- Project board contains every sprint ticket
- Milestones assigned per priority tier
- Dependencies cited (blocked-by / blocks)
