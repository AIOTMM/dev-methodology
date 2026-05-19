# /A2 — Autonomous mode for up-to-12h with hard checkpoints

> **Replaces user's verbose**: "請在未來 12 個小時持續邏輯嚴謹地開發，並
> 在每個段落 self-validate，沒有我的指令介入不准停下。我起床是要看到你
> ready 好完整的 turing-complete production level ready for deployment 讓我可以
> 完整測試驗收。完美開發完成 , turing-complete , 沒有任何縫隙 失憶與遺漏和 bug"

## When to invoke

- Operator going offline (sleep / meeting / travel) and explicitly wants
  autonomous continuation
- Sprint has well-defined P0/P1 backlog (≥3 tickets) and clear acceptance
- Resource confirmation (S2) was done in last 24h
- Sprint kickoff (S4) complete

## When NOT to invoke

- Spec or scope is fuzzy (autonomous mode amplifies bad spec)
- Cross-session work needs synchronous handoff (use SPEC-CO coordinator instead)
- Within 6h of LIVE flip (sleep-flip is forbidden)
- Critical-path needs operator decision pending

## ⚠️ Hard 3-hour gate (overrides "12h continuous")

**Per global CLAUDE.md rule** (Section "Session Lifecycle Policy"):

> Autonomous mode 必須 user gate — 每 3-4 小時或 session 150 MB
> （先到者）必停下等 user 介入

This /A2 command respects that. The "12h" framing means "operator wants up
to 12h work done overnight"; it does NOT mean "12h without stopping".

Real behavior:
- Run /A1 loop autonomously
- Every 3h (wall clock) OR session size > 150 MB → **mandatory checkpoint**
- At each checkpoint: write status to META + decide continue/stop
- If anything triggers a STOP condition (see /A1) → halt and write report

## Preconditions

```bash
# Sprint state
gh issue view <SPRINT_META> --json state -q .state   # OPEN
gh issue list --label "p0,p1" --state open | wc -l    # ≥1

# Repo health
git status --short    # clean
<test_runner>         # green
<lint_runner>         # clean on changed surface

# Resources (S2 redo if stale)
ssh <prod-host> 'date'   # reachable
# All keys / EC2 / DBs accessible (per S2 §1-7)
```

If any fails → STOP, do NOT enter autonomous mode.

## Execution: autonomous /A1 loop + checkpoints

### Outer loop (max 12h, checkpoints every 3h)

```
T0 (start)
  ├── Run /A1 inner loop for ≤3h OR until first checkpoint trigger
  ├── At T+3h (or trigger): write CHECKPOINT-1 to META, self-evaluate
  ├── Continue OR halt per checkpoint outcome

T+3h (CHECKPOINT-1)
  ├── If healthy AND backlog remaining → continue /A1
  ├── Otherwise → halt + write final report

T+6h (CHECKPOINT-2)
  ├── Same logic

T+9h (CHECKPOINT-3)
  ├── Same logic

T+12h (HARD STOP regardless of state)
  └── Write final report + halt
```

### Checkpoint procedure (must run at every 3h boundary)

```bash
# 1. Capture current state
CKPT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NEW_COMMITS=$(git log @{u}..HEAD --oneline | wc -l)
CLOSED_TICKETS=$(gh issue list --search "closed:>${SESSION_START_DATE}" --label "sprint-<name>" | wc -l)
SUITE_RESULT=$(<test_runner>; echo $?)
META_PROGRESS=$(gh issue view <META> --json body -q .body | grep -cE "^\s*- \[x\]")

# 2. Self-evaluate against autonomous criteria:
HEALTHY=true
[ $SUITE_RESULT -ne 0 ]                && HEALTHY=false   # any test failure
[ -n "$(git status --porcelain)" ]      && HEALTHY=false   # uncommitted drift
ssh <prod-host> 'systemctl is-active <critical-daemons>' | grep -v active && HEALTHY=false

# 3. Write checkpoint to META
gh issue comment <META> --body "$(cat <<EOF
## 🕐 Checkpoint at $CKPT (T+$ELAPSED_HOURS h)

Commits since start: $NEW_COMMITS
Tickets closed: $CLOSED_TICKETS
Suite: $([ $SUITE_RESULT -eq 0 ] && echo "GREEN" || echo "RED 🔴")
Daemons: $(daemon_summary)
Working tree: $(git status --short | wc -l) modified files

Decision: $([ "$HEALTHY" = true ] && echo "CONTINUE" || echo "HALT")
Next checkpoint: $NEXT_CKPT
EOF
)"

# 4. If HEALTHY=false → halt; write final report; STOP
# 5. If backlog empty (no P0/P1 open) → switch to wrap-up mode
# 6. If session size > 150MB → halt regardless
# 7. Otherwise → continue inner /A1 loop
```

### STOP conditions (any one triggers halt + report)

1. Suite regression (any previously-passing test now fails)
2. Sub-agent surfaces CRITICAL beyond ticket scope
3. Working tree dirty without ability to clean-commit
4. Production daemon down (per `ssh ... systemctl is-active`)
5. EC2 / cloud reachability lost
6. Disk fill > 90% on any monitored path
7. Sprint META P0/P1 count → 0 (work done)
8. Session size > 150 MB (per CLAUDE.md)
9. Hard 12h wall-clock reached

## Final-report template (written at halt)

```
# /A2 final report at <timestamp>

## Status
- Wall-clock: T+<h>h
- Suite: GREEN/RED
- Halt reason: <one of STOP conditions OR "12h limit" OR "backlog complete">

## Done this session
- Tickets closed: #<list> (commits: <hashes>)
- Tests added: +N (total: <count>)
- Sub-agent reviews: <C/H/M/L counts addressed>

## Open
- P0/P1 still open: #<list>
- Sprint-Q deferred: #<list>
- New issues opened: #<list>

## Production state
- HEAD pushed: <hash>
- EC2 / prod synced: yes/no
- Daemons: <statuses>

## Operator next action recommended
- [ ] ...

## Risks discovered this session
- ...
```

Post this report on `<SPRINT_META>` as a comment + on operator's preferred
channel (Telegram / Slack).

## NEVER constraints

1. NEVER skip the 3h checkpoint
2. NEVER continue past a STOP condition
3. NEVER let session size exceed 150 MB without halting
4. NEVER flip LIVE in autonomous mode (LIVE requires synchronous operator)
5. NEVER write magic-phrase typed answers (operator-only)
6. NEVER `--force` push during autonomous
7. NEVER skip self-validate gates in inner /A1 loop just because "operator
   is asleep"
8. NEVER claim "turing-complete production-ready" without acceptance criteria
   evidence — that phrase is a goal, not a status. Use measurable language.
9. NEVER consume capital allocation decisions / production deploy phrases
   without operator's typed authorization in the session

## "Turing-complete production-ready" — what this ACTUALLY means

Operator's prompt asks for "turing-complete production level ready for
deployment, no gaps, no amnesia, no bugs". Real meaning:

| User says | Real interpretation |
|---|---|
| "turing-complete" | Acceptance criteria for in-scope tickets fully met; out-of-scope items deferred-with-ticket |
| "production-ready" | S7 G1-G6 gates can be checked off; G7-G9 awaits operator |
| "no gaps" | Every spec acceptance line has a test; every test green |
| "no amnesia" | META issue + Project board + commit messages tell the full story |
| "no bugs" | 0 regressions vs session-start baseline; new bugs documented as deferred |

Be honest in final report — use these dimensions, not the marketing phrase.

## Resume protocol (next-morning operator)

```bash
# Operator wakes up. To resume:
gh issue view <SPRINT_META> --json comments | tail -200
git log @{u}..HEAD --oneline    # any unpushed? (shouldn't be, but verify)
<test_runner>                    # confirm green
ssh <prod-host> 'systemctl status <daemons>'
```

If healthy → operator typed `/A1` to continue next ticket.
If A2 halted with STOP → operator addresses STOP cause first.

## Acceptance (session end)

```
□ All checkpoint comments written to META (one per 3h boundary)
□ Final report comment written
□ Operator-channel notification sent
□ git push complete (no local-only commits)
□ Working tree clean
□ Suite green
□ Session size logged in final report
```
