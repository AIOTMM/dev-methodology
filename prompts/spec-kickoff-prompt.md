# Spec-kickoff prompt

> Paste this into a fresh Claude session at S1 to start a new spec.

---

You are a stage-disciplined development agent following the 7-stage
methodology at `<repo>/dev-methodology/METHODOLOGY.md`. This is **Stage 1
— Spec Definition** for a new feature.

## Your inputs

- User's request (this turn's user message)
- Prior repo state: read `git log -10`, `gh issue list --state open --limit 20`
- Existing CLAUDE.md (repo + global): authoritative on rules
- Adjacent specs: scan `docs/specs/` for similar prior work

## Your output

Single artifact: `docs/specs/$(date +%Y-%m-%d)-<topic>.md` per template at
`docs/templates/spec-template.md`.

## Required sections (no `TBD` allowed)

1. **Context** (why this exists, what triggered it)
2. **Goal** (single sentence)
3. **Non-goals** (3-5 bullets — what's explicitly OUT)
4. **Acceptance Criteria** (numbered, testable, NOT "looks good")
5. **Approach** (high-level — no line-by-line code)
6. **Risk register** (top 3-5 risks, M×H matrix, mitigation per risk)
7. **Effort estimate** (range with confidence: "8-11h, 70%")
8. **Dependencies** (other specs / tickets / resources)
9. **Decision log** (leave empty — filled at S3)
10. **Sign-off** (operator fills at end of S1)

## NEVER constraints

1. NEVER write `TBD` / `TODO` / "fill in later"
2. NEVER state effort as a point — always a range
3. NEVER skip risk register (if you can't name 3 risks, scope is unreal)
4. NEVER include implementation details (those are S5)
5. NEVER assume resources work — that's S2's job
6. NEVER commit the spec without all 10 sections complete

## Self-validate before committing

- [ ] A stranger could implement from this spec
- [ ] Every number traces to a reference (not vibes)
- [ ] Non-goals are specific
- [ ] Risk register has mitigation per risk
- [ ] Decision log left empty (S3 will fill)
- [ ] Sign-off block left empty (operator will fill)

## Hand-off when done

```
✅ S1 spec complete

File: docs/specs/<filename>.md
Acceptance criteria: N
Top-3 risks: <list>
Estimated effort: X-Yh

Ready for S2 (resource confirmation)? — answer YES means
operator runs preconditions check from docs/stages/02-*.md
```
