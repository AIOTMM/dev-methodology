# Pattern: Cross-session handoff

> When parallel Claude sessions work on shared scope. Handoff prompts must
> be SELF-CONTAINED so fresh sessions have no implicit dependencies.

## Why this exists

Real failure mode (observed across many sprints):

```
Session A finishes work, types "ok I'm done"
Session B starts, doesn't know what A did, asks user
User repeats context from memory (incomplete)
Session B builds on partial info, misses a constraint
Bug ships to production
```

Fix: every handoff produces a SELF-CONTAINED prompt that the next session
reads cold and is fully oriented.

## Handoff prompt requirements

Must include:

1. **Session role** (IMPLEMENTER / COORDINATOR / REVIEWER)
2. **Status snapshot** (verified facts only — git HEAD, test counts, daemon states)
3. **What was done** (commits with hashes)
4. **What's pending** (issue numbers, NOT "you remember")
5. **NEVER constraints** (per-role, repeated even if other sessions know)
6. **Coordination touchpoints** (when to talk to other sessions)
7. **Escalation paths** (when to halt + alert)
8. **Self-validate checklist** (next session confirms understanding)
9. **Resume protocol** (if interrupted, how to find state)

See `prompts/coordinator-prompt.md` and `prompts/implementer-prompt.md`
for canonical templates.

## Anti-pattern: "you remember"

```
# WRONG:
"continue what we were doing"
"finish the thing"
"work on the same files as before"

# CORRECT:
"continue ticket #N (read body at <URL>)
 acceptance criteria checklist not yet complete: [list]
 files touched so far: [paths with line counts]"
```

## Status snapshot rule

ALWAYS verify before stating. Never state from memory.

```bash
# WRONG: "HEAD is 1fa9066"  (from memory)
# CORRECT:
git log -1 --format='%h %s'    # verify, then quote
```

If you can't verify a fact, don't state it.

## Cross-session coordination touchpoints

NOT "post everything everywhere". Specific triggers:

| Trigger | Notify whom | Where |
|---|---|---|
| Major refactor in shared code | All sessions touching that code | Project board comment |
| Spec ambiguity discovered | SPEC-CO | Originating ticket |
| Cross-repo dependency added | Both repo's MOREs | Both META issues |
| Suite breaks | All sessions in same sprint | Sprint META |
| Production daemon down | All sessions + operator | Tier-2 alarm + META |
| Sprint complete | All sessions | Sprint META + operator |

## Handoff cadence

Per session work-unit (NOT continuous):

- After commit + push → status comment on relevant issue
- After issue close → cross-link in META update
- After session-pause (operator goes offline) → final status report
- After 3h checkpoint (per /A2 rules) → comment to META

Avoid:
- Comment-after-every-tool-call (noise)
- Status-on-session-start (read first, then act)

## Handoff prompt size

| Type | Target size |
|---|---|
| Coordinator setup | 100-200 lines (rich context) |
| Implementer kickoff | 150-300 lines (full constraints) |
| Reviewer dispatch | 50-150 lines (focused scope) |
| Per-checkpoint status | 20-50 lines (delta only) |

Past 400 lines → distill. Below 30 lines for kickoff → likely under-specified.

## Real precedent

AIOT v15.5 used 3 sessions (SPEC-CO + Strategies + OB-Dev). Handoff
prompts at `/Users/laijack/Documents/mm/handoff/`:

- `ob-dev-prompt-2026-05-19-v2.md` (213 lines)
- `onward-work-coordinated-2026-05-19.md` (454 lines — two-prompt combined)

Result: 0 cross-session miscommunication over 3-day sprint.

## Self-validate

- [ ] Every prompt is self-contained (no "you know" / "as discussed")
- [ ] Status snapshot verified, not from memory
- [ ] NEVER constraints listed per-role
- [ ] Touchpoints specific (not "post everywhere")
- [ ] Resume protocol included
- [ ] Self-validate checklist for next session
