# /A1 — Continue dev with per-step superpower review + self-validate

> **Replaces user's verbose**: "接續開發每一個 roadmap item，每個環節請精細
> 邏輯嚴謹地使用 superpower review 並 self-validate ，確保可以完整精細
> 邏輯嚴謹地開發完成"

## When to invoke

- After `/sprint-kickoff` complete and operator says "start"
- Mid-sprint when picking up after operator break
- After a previous ticket closes and next P0/P1 is open

## When NOT to invoke

- No active sprint META issue
- All P0/P1 tickets already closed (move to P2 or new sprint)
- Operator decision pending on critical-path item

## Preconditions

```bash
# Sprint kickoff was done?
gh issue list --label "sprint-<name>" --state open | head -1   # must return ≥1 item

# Sprint META issue exists?
gh issue view <META> --json state -q .state   # must be "OPEN"

# Working tree clean?
git status --short    # must be empty

# Suite green?
<test_runner_command>   # must exit 0
```

If any fails → STOP, address, then resume.

## Execution loop

For each P0/P1 ticket (in priority order, then dependency order):

### Per-ticket sequence

#### Phase 1 — Read & plan

```bash
# Read full ticket body
gh issue view <N> --json title,body,labels

# Read linked dependencies
for dep in $(gh issue view <N> --json body -q .body | grep -oE "#[0-9]+"); do
  gh issue view "${dep#\#}" --json title,state | head -3
done

# Read relevant code (cite file:line)
# Read relevant tests
```

Sketch implementation plan in scratchpad (NOT committed yet). Identify:
- Files to touch (≤3 → direct; ≥5 → sub-agent dispatch)
- Tests to write first (TDD)
- Risk of regression elsewhere

#### Phase 2 — TDD red

Write failing tests at the path specified in ticket's acceptance criteria.
Run them. Confirm failure mode matches what acceptance requires.

#### Phase 3 — Implement

Write minimal code to make tests pass. Re-run tests. Repeat until green.

Do NOT add scope beyond what ticket says.

#### Phase 4 — Per-step superpower review (sub-agent dispatch)

```
Dispatch `code-reviewer` sub-agent with prompt:

"Adversarial review of [files touched] for ticket #<N>. Find the worst-case
failure mode. Sort by severity. For each finding: file:line, impact, fix.
Cap at 800 words. Do not soften."
```

#### Phase 5 — Apply review findings

- CRITICAL → fix immediately + add regression test
- HIGH → fix or document with explicit operator acknowledgement
- MEDIUM/LOW → triage to follow-up issue, do NOT silently leave

#### Phase 6 — Self-validate

For this ticket, answer YES to ALL:

- [ ] All acceptance-criteria boxes can be checked off
- [ ] Tests run green (`pytest`, `cargo test`, or whatever)
- [ ] Suite-wide regression test still green (full suite, not just touched file)
- [ ] Lint/type clean on touched files (`ruff`, `mypy`, etc.)
- [ ] Commit message uses conventional prefix + WHY-not-WHAT body
- [ ] No NEVER constraint violated
- [ ] Sub-agent review's CRITICAL findings all addressed

#### Phase 7 — Commit + push

```bash
git add <files>
git commit -m "$(cat <<EOF
<type>(<scope>): <subject>

<body explaining WHY, not WHAT>

Closes #<N>
Review: <sub-agent finding count> CRITICAL/HIGH/MEDIUM/LOW addressed
Tests: +<N> new, <total> passing
EOF
)"
git push origin main
```

#### Phase 8 — Close ticket + update META

```bash
gh issue close <N> --comment "Closed by commit <hash>. Sub-agent review: <summary>. Tests: <delta>."

# Update META issue: tick the box for this ticket
gh issue edit <META> --body "$(updated body with ticket marked done)"
```

#### Phase 9 — Status report to operator

After each ticket (NOT after each phase):

```
✅ Ticket #<N> closed (<title>)

Files: <list>
Tests: +<N> passing, regression 0
Review findings: <C/H/M/L counts>
Effort actual: <Xh> (vs estimate <Yh>)
Next: ticket #<M> (<title>) — <estimate> hours
```

### Loop break conditions

STOP the loop and ping operator if:

- Suite regression appears (any test that was passing now fails)
- Sub-agent surfaces CRITICAL that can't be fixed within ticket scope
- New dependency discovered (need an issue not in current sprint)
- Effort overrun > 2× estimate
- Operator gate is needed (decision, sign-off, magic phrase)

Do NOT proceed past a STOP condition without operator acknowledgement.

## NEVER constraints

1. NEVER skip per-step sub-agent review
2. NEVER commit with failing tests (any test, not just the new ones)
3. NEVER push WIP commits to `main` without operator request
4. NEVER batch close multiple tickets in one commit (1 ticket = 1+ commits)
5. NEVER ignore sub-agent CRITICAL findings — fix, defer-with-issue, or escalate
6. NEVER auto-merge dependency tickets out of stated order
7. NEVER `--no-verify` git commits (hooks catch real issues)
8. NEVER paste secrets in commits/comments

## Resume protocol (if interrupted mid-ticket)

```bash
# What state is this ticket in?
git status --short                              # any unstaged work?
git log --oneline -3                            # last 3 commits relate to this ticket?
gh issue view <N> --json comments | tail -20    # any sub-agent review posted?

# Resume from FIRST unfinished phase:
#   no test file yet → Phase 2
#   tests fail → Phase 3 (implement)
#   no review comment → Phase 4
#   review unread → Phase 5
#   uncommitted clean code → Phase 6
#   committed not pushed → Phase 7 push
#   pushed not ticket-closed → Phase 8
```

## Acceptance (per-ticket)

```
□ Acceptance criteria all checked
□ Suite green (full, not just new tests)
□ Sub-agent review documented in commit body
□ CRITICAL/HIGH findings closed (fixed or escalated)
□ Commit pushed
□ Ticket closed with commit-hash citation
□ META issue updated
□ Operator status report sent
```

## Acceptance (loop complete)

Loop terminates naturally when no P0/P1 tickets remain open in sprint.
At that point:

```
□ All sprint META P0/P1 boxes checked
□ Sprint moves to LIVE-flip preparation per /A3 or /S7
□ Operator notified: "P0/P1 complete, N P2/P3 remaining"
```

Operator decides: continue with P2 via /A1 OR switch to /A3 deploy-mode.
