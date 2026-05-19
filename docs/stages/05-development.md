# Stage 5 — Develop

> **Goal**: Ship code that passes its own tests AND survives S6 adversarial review.
> **Anti-goal**: "Move fast" — speed without discipline ships 12 CRITICAL bugs.

## Inputs

- Spec (S1) with acceptance criteria
- Resource confirmation (S2)
- Decision log (S3)
- Tickets + META (S4)

## TDD-first protocol

For every ticket, in order:

```
Phase 1: Read & plan      (Read tools, NOT Write)
Phase 2: TDD RED          (write failing tests at acceptance-criteria-cited path)
Phase 3: Implement minimal (just enough to make tests green)
Phase 4: TDD REFACTOR     (clean up if tests still green)
Phase 5: Self-validate    (full suite, not just touched tests)
Phase 6: Sub-agent review (per /A1 phase 4)
Phase 7: Commit + push
Phase 8: Close ticket + status report
```

NEVER skip phase 2 (RED). If you can't write a failing test, the acceptance
criterion isn't testable — go back to S1.

## Sub-agent dispatch decision tree

Extracted from real-world data (AIOT v15.5, /aiot-analysis sub-agent failures):

| Trigger | Decision |
|---|---|
| ≥5 independent file edits | Dispatch parallel sub-agents |
| Cross-file refactor with shared state | Sequential in main session (no sub-agent) |
| Single-file feature < 200 lines | Direct edit, no dispatch |
| Adversarial review | Always dispatch (independence beats self-review) |
| Long-running task with progress to watch | Direct execution (sub-agent is black box) |
| Token-heavy lookup ≥3 files | Dispatch `Explore` sub-agent |
| Token-heavy lookup < 3 files | Direct grep/Read |

### Sub-agent prompt requirements

Sub-agent must be SELF-CONTAINED. Required sections:

```
1. Context (1 paragraph — what the parent session has done so far)
2. Task (1-2 sentences)
3. Inputs (file paths, commit hashes, issue numbers — NOT "you know")
4. Constraints (NEVER list, with rationale)
5. Output format (structured, with word cap)
6. Self-validate (sub-agent must answer 3-5 verification questions)
```

Cite `prompts/subagent-template.md`.

## Tool discipline

### NEVER sleep-poll background tasks

```bash
# WRONG:
sleep 60 && tail output.log
sleep 120 && check_status

# CORRECT:
# Option A: foreground with long timeout
<long-command>  # timeout: 600000ms

# Option B: background + wait for system notification
<long-command> &  # run_in_background=true
# System notifies on completion; do NOT poll
```

### EVERY external call gets a timeout

Real precedent (AIOT /aiot-analysis hang):

```bash
# WRONG:
ssh remote "long_query.py"

# CORRECT:
ssh -o ConnectTimeout=3 remote "long_query.py" &
PID=$!
( sleep 30; kill $PID 2>/dev/null ) &
wait $PID
```

### NEVER recite cached output

If a sub-script generates data, RE-RUN it every time. NEVER paste output
from a previous run claiming it's current.

```bash
# WRONG: copy yesterday's scan output, present as today's
# CORRECT: re-execute scan command, show fresh output
```

## Conventional commits

```
<type>(<scope>): <subject line ≤72 chars>

<body explaining WHY, not WHAT — diff shows WHAT>

<footer with issue refs, breaking-change notes>
```

Types:
- `feat`: new feature
- `fix`: bug fix
- `refactor`: no behavior change
- `test`: test-only change
- `docs`: doc change
- `chore`: tooling/config
- `perf`: performance only
- `ci`: CI config

Scope examples: `(engine)`, `(state-db)`, `(R5-A)`, `(QA-R7)`.

## File size discipline

Per global CLAUDE.md bloat budgets:

| Artifact | Soft limit | Hard limit |
|---|---|---|
| Python file | 500 lines | 800 lines |
| Bash script | 200 lines | 300 lines |
| Skill `.md` | 300 lines | 500 lines |
| Sub-agent prompt | 250 lines | 400 lines |
| Report PDF | 20 pages | 30 pages |

Past soft limit → triage refactor candidate.
Past hard limit → BLOCK merge, refactor first.

Exception: `# BLOAT-OK: <reason>` comment at top of file.

## Cross-session handoff during S5

If your ticket touches another session's territory (per
`docs/sessions/file-ownership.md`):

1. STOP before editing
2. Open issue in shared META with the proposed change
3. Wait for other session's ack
4. Coordinate via SPEC-CO if available

NEVER edit another session's owned files without coordination.

## Anti-pattern: "trust me" sub-agent reports

Sub-agent's summary describes what it INTENDED to do, not necessarily what
it DID. Always verify with `git diff` / `cat` / `grep` after a sub-agent
edits files.

## Cross-cutting patterns (v1.3 imports)

S5 implementation must honor 3 cross-cutting patterns:

### Complexity Ratchet (`docs/patterns/complexity-ratchet.md`)

Every commit adds 3 forward-only artifacts:

- **Tests** (unit + integration + appropriate type per matrix)
- **Documentation** (WHY behind decisions, not WHAT)
- **Eval records** (quality threshold quantified vs previous baseline)

Coverage CI gate: diff coverage cannot decrease without operator override.
Mutation score ≥ 75% on critical paths.

### 12-Factor Agents (`docs/patterns/twelve-factor-agents.md`)

When S5 involves writing LLM-integrated code (agents, prompts, structured
outputs), honor:

- Factor 2 (Own prompts) — prompts in git, never framework-hidden
- Factor 3 (Own context) — custom XML structure beats default message format
- Factor 8 (Own control flow) — switch + for-loop in your code, not framework
- Factor 10 (Small focused) — ≤ 10 tools per agent, ≤ 10 steps median
- Factor 12 (Stateless reducer) — `agent: Thread → Event`, state in thread

### Structure-as-HTML (`docs/patterns/structure-as-html.md`)

If S5 ships analysis tools / reports / dashboards, output should be HTML
(Level 2-3) by default. Markdown only for git-diffable specs.

## Real precedent

AIOT v15.5 Pyramid F-PYR-02 fix used this protocol:
- Phase 2 RED: `test_tp_armed_in_current_cycle` written before fix
- Phase 3 implement: minimal hysteresis predicate
- Phase 6 review: 3 rounds (implementer / architect / user perspective)
- All 7 tests went RED→GREEN per cycle

See [`docs/lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md`](../lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md) §S5.

## Self-validate (per ticket)

- [ ] RED test written FIRST, confirmed failing
- [ ] Implementation makes the RED test green
- [ ] Full suite still green (not just touched test)
- [ ] Lint/type clean on touched files
- [ ] Conventional commit + WHY-body
- [ ] Sub-agent review dispatched (per S6 R1-R7 cycle)
- [ ] No NEVER violations
- [ ] Cited issue # in commit footer
