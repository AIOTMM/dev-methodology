---
name: retro-extraction
description: At sprint close, write retro + extract anti-patterns + update Sprint-Q backlog. Ratchet methodology improvements.
type: skill
---

# Skill: retro-extraction

## When to invoke

- Sprint LIVE flip + 24h G9 monitor complete
- All P0/P1 sprint tickets closed
- Operator wants formal close-out

## Execution

1. Write `docs/sprints/YYYY-MM-DD-<sprint>-retro.md`:
   - Quantitative outcome (tests / commits / tickets / CRITICALs found)
   - Top 5 CRITICAL bugs caught (what would have shipped without S6)
   - What worked (process, tools, patterns)
   - What to do differently next sprint
   - References (META, Project, commits)

2. Update `docs/lessons-learned/ANTI-PATTERNS.md`:
   - Add any new anti-pattern observed this sprint
   - Cite this sprint as precedent
   - Document "if you catch yourself doing X" → "do Y instead"

3. Write `docs/sprints/<next-sprint>-backlog.md`:
   - Every MEDIUM/LOW from S6 rounds
   - Every operator-typed risk-accepted item
   - Every "deferred" decision from S3
   - Estimate per item, priority tier

4. Update methodology docs if pattern improved:
   - New pattern → `docs/patterns/<name>.md`
   - Modified stage → update `docs/stages/0X-*.md`
   - New skill → `skills/<name>/SKILL.md`

5. Commit: `docs(retro): <sprint> close-out + methodology ratchet`

## NEVER

- NEVER ship retro without quantitative outcome (vibes → useless retro)
- NEVER skip "what worked" (only listing failures distorts future decisions)
- NEVER let anti-patterns stay only-in-this-retro (must migrate to ANTI-PATTERNS.md)
- NEVER backlog without estimates (un-estimated = un-prioritized)

## Acceptance

- Retro doc has quantitative + qualitative sections
- ANTI-PATTERNS.md updated if applicable
- Sprint-Q backlog committed
- Methodology improvements migrated upstream
