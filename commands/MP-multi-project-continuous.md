# /MP — Multi-project continuous build until ALL items done

> **Replaces user's verbose**: "直到精細邏輯嚴謹開發 , merge , deploy
> 完所有 <multi-product-name> projects & all items"
> (e.g. AIOTMM/AIOT-MVP, acme/platform, your-org/q3-release)
>
> Wraps `/sprint-kickoff` → `/A1` → `/A2` / `/A3` in a loop that spans
> MULTIPLE projects (e.g. AIOT-MVP frontend + backend + infra simultaneously).

## When to invoke

- Operator wants a multi-day push spanning multiple repos / projects
- Each project is independently structured but converges on a single
  production goal (e.g. "ship Q3 platform release")
- Pre-existing sprint per project has its own META + Project + tickets

## When NOT to invoke

- Single-project scope (use `/A1` or `/A3` directly)
- No clear "until done" condition (open-ended → operator must define)
- Critical-path through any one project requires synchronous operator
  (use SPEC-CO coordinator instead)

## Preconditions

```bash
# For each project in scope:
for proj in $PROJECTS; do
  # Sprint kickoff done?
  gh issue view <PROJ_META> --json state -q .state    # OPEN
  # Backlog non-empty?
  gh issue list --milestone "<proj-sprint>" --state open | wc -l    # ≥1
  # Working tree clean?
  cd $PROJ_DIR && git status --short                  # empty
done

# Cross-project coordination: SPEC-CO session active?
# (If multi-session arch, /MP runs as IMPLEMENTER in each project,
# SPEC-CO maintains cross-project META)
```

## Execution: nested loops

```
OUTER LOOP: while ANY project has open P0/P1:
    For each project (priority order: blockers first):
        INNER: invoke /A3 on next item in that project
        Apply 3h checkpoint per /A2 rules

    Cross-project alignment check (every 6h):
        verify_alignment.sh
        if drift detected → halt + escalate to SPEC-CO

    Deploy gate check (per project):
        if project's P0/P1 all closed AND S7 gates G1-G6 ready:
            advance project to "ready for LIVE flip" state
            notify operator
        if all projects "ready for LIVE flip":
            HALT — operator must orchestrate LIVE
```

## Project rotation policy

Default: round-robin (1 item per project per rotation).

Override when:
- Project P has a blocker that other projects depend on → P0-first
- Project Q's daemon is degraded → Q's incident response takes precedence
- Operator pins priority order in latest /MP invocation message

## Cross-project synchronization touchpoints

Per `docs/patterns/multi-session-coordination.md`, every 6h OR after each
significant project advance:

```bash
# Update each project's META
for proj in $PROJECTS; do
  gh issue comment <PROJ_META> --body "checkpoint at $(date), <state>"
done

# Update cross-project META (if exists)
# E.g. AIOT-MVP-roadmap META referencing each sub-project
gh issue comment <CROSS_META> --body "..."

# Run alignment check
bash tools/verify_alignment.sh

# Verify Project board (cross-repo)
gh project item-list <PROJ_NUMBER> --owner $OWNER --format json | \
  python3 -c "import json,sys;d=json.load(sys.stdin);
from collections import Counter
c=Counter(i.get('status','?') for i in d['items'])
for k,v in sorted(c.items()): print(f'{k:>16}: {v}')"
```

## Halt conditions (any one stops /MP)

1. ANY project's suite goes RED
2. ANY project's working tree gets dirty without ability to clean
3. Cross-project alignment check FAILS (drift detected)
4. Production daemon in any environment goes degraded
5. Cumulative session size > 150 MB (per CLAUDE.md)
6. Operator typed override anywhere
7. ALL P0/P1 across ALL projects closed (work done)
8. Hard 12h wall-clock from /MP start

## "Turing-complete production-ready" honest definition

User says "完美開發完成, turing-complete, 沒有任何縫隙 失憶與遺漏和 bug,
直到精細邏輯嚴謹開發, merge, deploy 完所有 AIOT-MVP projects & all items"

Real interpretation:

| User says | Real definition |
|---|---|
| "完美" (perfect) | All sprint-defined acceptance met; out-of-scope items deferred-with-issue |
| "turing-complete" | All in-scope tickets shipped through /A3 7-round review |
| "沒有縫隙" (no gaps) | Every project's META P0/P1 list checked; integration tests cross-project |
| "失憶與遺漏" (no amnesia) | Cross-project META + Project board + CHANGELOG tell the full story |
| "deploy 完所有 projects" | Each project at S7 G6 "ready for LIVE flip" — actual flip remains operator gate |

Set operator expectations accordingly in status reports.

## Status report cadence

- Per item: brief 5-line summary (from /A1 / /A3)
- Per 3h checkpoint: full state across all projects
- Per 6h: cross-project alignment report
- At halt: comprehensive final report

## Final report template (when /MP terminates)

```
# /MP final report at <timestamp>

## Scope
- Projects: <list>
- Started: <T0>
- Halted: <T_end>
- Halt reason: <one of conditions OR "all P0/P1 done">

## Per-project status
### <project A>
- HEAD: <hash>
- Tickets closed this session: #<list>
- Tests: +<N> passing
- S7 gates ready: G1 ✅ G2 ✅ ... G6 ✅ / G7 awaiting operator
- Outstanding P0/P1: <list>

### <project B>
- ...

## Cross-project state
- Project board: <URL> (M of N items done)
- Cross-META commits: <list>
- Alignment check: PASS / FAIL details

## Operator next actions
- [ ] LIVE flip <project A> via /A3 §S7 G7 invocation
- [ ] Decision needed on <ambiguity>
- [ ] Review <commits> before next /MP

## Risks surfaced this session
- ...

## Recommended next /MP invocation
- After operator addresses above
- Estimate: ~Xh additional autonomous work
```

## NEVER constraints

1. NEVER skip per-item /A3 acceptance gates
2. NEVER skip 3h checkpoints
3. NEVER cross-push to another project's repo (each /MP iteration scopes
   to one project at a time)
4. NEVER flip LIVE in /MP mode — that's operator-synchronous
5. NEVER let one project's failure silently halt others without alert
6. NEVER claim "deploy 完成" when operator hasn't flipped LIVE
7. NEVER consume operator-only decisions (capital allocation, magic phrases)
8. NEVER `--force` push in any project
9. NEVER ignore SPEC-CO coordinator if running multi-session

## Resume protocol (operator wakes / returns)

```bash
# Operator reads final report
gh issue view <CROSS_META> --json comments -q '.comments[-1].body'

# Verify state
for proj in $PROJECTS; do
  cd $PROJ_DIR
  git status --short
  git log @{u}..HEAD --oneline   # nothing should be local-only
  <test_runner>
done

# Address halt cause if any
# Then either:
#   - /MP again (continue) — only if backlog has new P0/P1
#   - /A3 specific project (focused continuation)
#   - /S7 deploy-gate work (LIVE prep)
```

## Acceptance

/MP session ends successfully when ANY of:

```
□ ALL projects' P0/P1 closed AND S7 G6 ready (handoff to operator for LIVE)
  OR
□ Halted on STOP condition with full final report
  OR
□ Hard 12h reached with checkpoint reports + final state captured
```

In all 3 cases, the operator gets:
- Cross-project comprehensive status
- Specific next actions
- Risks list
- Recommended next-invocation guidance
