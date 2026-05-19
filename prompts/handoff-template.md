# Handoff prompt template

> Use when session A passes work to session B (next morning, different
> implementer, or after compaction).

---

```
# Handoff from <session-name> at <ISO timestamp>

## Where we are (verified facts)

| Asset | Value |
|---|---|
| Repo HEAD | <commit hash + subject>           ← run `git log -1 --format='%h %s'` |
| Test suite | <count> passing                   ← run test suite, paste count |
| Sprint META | #<N>                              ← from current sprint |
| Project board | <URL>                          |
| Last ticket worked | #<M> — <state>             |
| Operator state | online / offline / asleep     |

## What was done in last session

- Commit <hash>: <one-line>
- Commit <hash>: <one-line>
- Issue #N closed
- Issue #M opened

## What's pending (open P0/P1)

- #<X>: <title> (<estimate>h)
- #<Y>: <title> (<estimate>h)

## Constraints (repeat — do not assume reader knows)

1. NEVER ...
2. NEVER ...
(per role: implementer / coordinator / reviewer — cite docs)

## Touchpoints

- If you find Z → escalate to SPEC-CO
- If suite breaks → halt + post to META
- If effort overrun 2× → ask operator

## Resume

Read first:
1. <META issue URL>
2. <Project board URL>
3. <docs/sprints/<sprint>-checklist.md>

Then execute:
- /A1 to continue at first P0/P1
- OR /A3 if next item needs full 7-round review

## Self-validate before acting

- [ ] I verified HEAD with `git log -1` (not from this handoff text)
- [ ] I verified test suite green
- [ ] I read META latest comment
- [ ] I understand my role (implementer / coordinator / reviewer)
- [ ] I know which NEVER constraints apply to me

If any unchecked → ask operator to clarify before acting.

=== END HANDOFF ===
```
