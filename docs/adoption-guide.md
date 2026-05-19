# Adoption guide — apply this methodology to an active sprint

> Concrete steps to lift the quality of a sprint already underway. Based on
> dropping the methodology into AIOT v15.5 Sprint-P mid-flight (Day 14 of 22).

## Stage of adoption matters

| Sprint stage at adoption | Effort | Win |
|---|---|---|
| Pre-S1 (fresh sprint) | Full 7 stages | Full coverage |
| Mid-S5 (development active) | S2 backfill + S6 going forward | ~70% coverage, less rework |
| Pre-S7 (deploy soon) | S6 rounds + S7 gates | ~50% coverage, catches deploy-bugs |
| Post-S7 (already shipped) | Retro extraction → next sprint full | Methodology starts at NEXT sprint |

## Concrete 4-step improvement for an active sprint

These 4 take ~1 hour total and lift quality immediately. Demonstrated against
AIOT v15.5 Sprint-P which was Day 14/22 at adoption time.

### Step 1 — Set operator-deadline on critical path (~5 min)

Critical path blockers without deadlines drift. Solution:

```bash
# Find the BLOCKING operator action (typically Q1-Qn sign-off, or magic-phrase decision)
# Set deadline. Post on its tracking issue.

gh issue comment <META-OP-X> --body "Operator deadline: <ISO timestamp>. After this, sprint blocks until signed."
```

For AIOT v15.5: Vins Q1-Q47 sign-off → set deadline 23:59 UTC same day.

### Step 2 — Add live progress metric to META (~10 min)

A pinned META that shows "all is well" but updates daily catches regressions
faster than weekly status meetings.

```bash
# Cron entry on operator machine OR EC2:
0 */4 * * * cd <repo> && bash <(cat <<'EOF'
P0=$(gh issue list --label p0 --state open --milestone "<sprint>" | wc -l)
P1=$(gh issue list --label p1 --state open --milestone "<sprint>" | wc -l)
TESTS=$(<test_runner>)
gh issue comment <META> --body "🤖 Auto-status $(date -u +%FT%TZ): P0=$P0 / P1=$P1 / suite=$TESTS"
EOF
)
```

Each comment is small but the trend graph reveals stuck items.

### Step 3 — Enforce coordination cadence (4h checkpoint, ~15 min setup)

Multiple parallel sessions drift if no cadence. Per `commands/A2` rules:

```
- Every 4h on the wall clock: each active session posts to META:
  "Checkpoint <ISO>. Status: <green/amber/red>. Did this cycle: <bullet list>.
   Blocked on: <list>. Next: <list>."
- If any session misses a 4h checkpoint → SPEC-CO pings them
- If session declares amber/red → SPEC-CO arbitrates immediately
```

### Step 4 — Open Sprint-Q issues for ALL deferred items (~30 min)

Per `docs/stages/06-review-validate.md`: "MEDIUM/LOW each in a follow-up
issue. NEVER silent ignores."

For each round's deferred findings:

```bash
gh issue create --milestone "<next-sprint>" --label "<priority>" \
  --title "[from QA-R<N>] <finding-summary>" \
  --body "$(cat <<EOF
## Source
QA Round <N> of <prior-sprint>
Finding ID: <e.g. F-R5-A>
Originally cited at: <round commit hash>

## Risk
<what was found>

## Why deferred from <prior-sprint>
<reason>

## Acceptance for <next-sprint>
- [ ] <criterion>
EOF
)"
```

Without this, deferred items get lost. Sprint-Q backlog is the prosthetic memory.

## Inject prompts into active sessions

### For SPEC-CO (this session)

Read at session start (already loaded):

```
prompts/coordinator-prompt.md
docs/patterns/cross-session-handoff.md
docs/patterns/coordinator-parallel-handoff.md
```

Whenever cross-session intervention needed, follow `coordinator-parallel-handoff.md`
section structure (§0 / §1 / §A / §B / §C / §D / §E).

### For Strategies session

Paste at session start (or every long-running message):

```
You are the IMPLEMENTER for AIOTMM/agent-5.2-binance-perp.

Methodology: read these files now and follow them:
1. /Users/laijack/Documents/dev-methodology/dev-agent.md (your agent definition)
2. /Users/laijack/Documents/dev-methodology/prompts/implementer-prompt.md (your role)
3. /Users/laijack/Documents/dev-methodology/commands/A1-continue-dev.md (your per-ticket loop)

Project-specific binding for placeholders:
- <test_runner>: python3 -m pytest core/tests/ strategies/ -q
- <lint_runner>: python3 -m ruff check
- <prod-host>: aiot-ec2 (176.34.17.230)
- <META>: #327 (AIOTMM/agent-5.2-binance-perp)
- <SPRINT_META>: same
- <project>: v15.5-pathB

Current state:
- HEAD: <run git log -1 to verify>
- Test count: <run test suite to verify>
- Phase 1 soak: <check stamp file>

Read those 3 methodology files in full before next action.
```

### For OB-Dev session

```
You are the IMPLEMENTER for AIOTMM/AIOT-MVP.

Methodology: read these files now and follow them:
1. /Users/laijack/Documents/dev-methodology/dev-agent.md
2. /Users/laijack/Documents/dev-methodology/prompts/implementer-prompt.md
3. /Users/laijack/Documents/dev-methodology/commands/A1-continue-dev.md
4. For OP-7 work specifically: docs/patterns/gate-driven-deploy.md

Project-specific binding:
- <test_runner>: make test (in /Users/laijack/Documents/mm/aiot_cmd)
- <prod-host>: aiot-ec2
- <META>: #1773
- <SPRINT_META>: same
- <project>: sprint-P

Current state:
- HEAD: <run git log -1>
- Daemons: <run systemctl is-active>

Read those 4 methodology files before next action.
```

## What this DOES NOT solve

- **Spec quality** still depends on operator's clarity (S1 input bound)
- **Inter-LLM bias** only addressed via cross-LLM (not adopted by default; see AP-12)
- **Operator energy state** requires biometric/self-report (S2 §6)
- **Methodology vs project drift** requires per-sprint CLAUDE.md customization

## Adoption acceptance

Mid-sprint adoption succeeded when:

- [ ] Operator deadline visible on every critical-path blocker
- [ ] Auto-metric posted to META at 4h cadence
- [ ] All deferred R1-R7 findings have GitHub issue in Sprint-Q backlog
- [ ] Implementer sessions read methodology files (verifiable by them quoting NEVER constraints)
- [ ] SPEC-CO uses §0/§1/§A/§B/§C/§D/§E structure for cross-session handoffs

## Real precedent

AIOT v15.5 Sprint-P adoption at Day 14: ~70% of methodology applied
retroactively. Wins observed:

- Vins critical path (Q1-Q47) became visible after Step 1
- 4 hidden parallel-session drifts caught via Step 3 cadence
- 50+ R1-R7 findings became trackable via Step 4 backlog
- 2 cross-session arbitrations resolved via coordinator-parallel-handoff pattern

## What to NOT skip when adopting mid-sprint

- **Don't skip S6 retroactively** — re-run R1-R7 on commits already shipped
- **Don't skip §C operator critical path** — non-delegable items are the silent killers
- **Don't skip §D touchpoints** — without explicit cadence, "we'll sync soon" stalls

## When to start fresh vs adopt mid-sprint

If you're > 80% through current sprint:
- Finish current sprint with whatever discipline you have
- Apply methodology fully starting NEXT sprint
- Use retro-extraction skill to bridge

If < 80% through:
- Adopt mid-sprint per the 4-step process above
- Re-run S6 R1-R7 on already-shipped code (this is the highest-leverage)

If < 40% through:
- Pause, do S1 spec, S2 resources properly
- 2-3 days of "ratchet" before resuming
- Strongest payback
