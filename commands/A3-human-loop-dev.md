# /A3 — Per-section smoke test + virtual-env deploy + 3-round design review + 7-round adversarial

> **Replaces user's verbose**: "每完成一個 section 都請 smoke test &
> deploy 到 virtual env 並用人類視角檢視，並用人類視角檢視過 使用 claude
> design & superpower review 三輪 self-validate 生成優化方案再接續下一個 item
> 開發 ... review & self-validate 7 rounds"

## When to invoke

- High-stakes scope (production deploy, multi-tenant, financial, safety)
- Building a methodology / framework / reusable tool
- Operator wants to verify each section before next begins
- After a previous bug shipped to production (raised vigilance level)

## When NOT to invoke

- Mechanical fixes (typo, lint, simple rename) — overkill
- Hot path requiring quick iteration (use /A1 instead)
- Spec is fuzzy (S1 first, /A3 is wasted on unclear scope)

## Difference vs /A1 and /A2

| Dimension | /A1 | /A2 | /A3 |
|---|---|---|---|
| Review per section | sub-agent once | sub-agent once | 3-round design + 7-round adversarial |
| Smoke test | post-commit | post-commit | post-section (virtual env or staging) |
| Operator stop point | per-ticket | every 3h | per-section before next |
| Speed | fast | autonomous | slow + thorough |
| Use | normal sprint | overnight | framework / safety-critical |

## Preconditions

```bash
# Sprint kickoff done
gh issue view <META> --json state -q .state    # OPEN

# Virtual env / staging available
which python3 -m venv || which docker          # both OK
<staging-deploy-tool> --version

# CodeRabbit (if used) configured on repo
gh api repos/$REPO/installation 2>&1 | grep -i coderabbit    # optional
```

## Execution loop (per ROADMAP ITEM)

### Phase 1 — Develop the section

Follow /A1 phases 1-5 (Read → TDD red → implement → sub-agent review →
apply findings). Stop BEFORE committing.

### Phase 2 — Smoke test in virtual env

```bash
# Set up clean venv (if Python)
python3 -m venv /tmp/A3-venv-$(date +%s)
source /tmp/A3-venv-*/bin/activate
pip install -e .  # or pip install -r requirements.txt

# Smoke: run the affected code path end-to-end
python3 -c "from <module> import <function>; <function>()"

# OR Docker:
docker build -t a3-smoke:$(git rev-parse --short HEAD) .
docker run --rm a3-smoke:$(git rev-parse --short HEAD) <entrypoint>
```

Acceptance: exit 0 + expected output. Any failure → fix before proceeding.

### Phase 3 — Deploy to staging / virtual env

For web: deploy to staging URL.
For CLI tool: install in clean container, run from CLI.
For lib: install in fresh venv, import + use externally.

Acceptance: feature accessible to a fresh observer (not just the implementer).

### Phase 4 — Human-perspective check

```
Spawn `general-purpose` sub-agent with prompt:

"You're a first-time user of <feature>. The staging URL / installed CLI /
fresh-venv lib is at <location>. Try to accomplish <user goal> using ONLY
public-facing documentation. Record every confusion, friction point,
broken expectation. Cap at 600 words."
```

Apply findings:
- Confusion → docstring / runbook update
- Friction → API or CLI improvement
- Broken expectation → bug, fix immediately

### Phase 5 — Design review (3 rounds)

Each round dispatches a distinct sub-agent with a different framing:

#### Round 1 — "Implementer's review"

```
Sub-agent prompt:

"You wrote this code. Audit it for: (a) inconsistencies with your own
prior design decisions, (b) missing edge cases you THOUGHT you handled
but didn't, (c) `TODO` / `XXX` / dead branches you forgot to clean up.
Sort by impact. Cap at 500 words."
```

#### Round 2 — "Architect's review"

```
"You're a senior architect seeing this code for the first time. Where does
it violate single-responsibility, leak coupling, or build patterns that
won't generalize? Sort by maintainability impact. Cap at 500 words."
```

#### Round 3 — "User's review"

```
"You're the operator using this in production. What would surprise you?
What ergonomic issue would make you avoid this tool? What logging /
error message is unhelpful at 3am? Sort by operator-pain. Cap at 500 words."
```

Apply ALL CRITICAL/HIGH findings from each round before Phase 6.

### Phase 6 — Adversarial review (7 rounds)

This is the heavyweight check. Each round attacks a different dimension
(see `docs/patterns/adversarial-review-7-rounds.md` for full doctrine):

| Round | Focus |
|---|---|
| R1 | CodeRabbit feedback (if any) addressed |
| R2 | Architectural consistency across files |
| R3 | Operator tooling hardening (shell injection, path traversal) |
| R4 | Spec/upstream equivalence (does it match the spec?) |
| R5 | Persistence layer (atomic, crash-safe, schema) |
| R6 | Test coverage seams (integration not just unit) |
| R7 | Final ship audit (CHANGELOG, runbook, doc consistency) |

For each round:

```bash
# Dispatch code-reviewer sub-agent with adversarial prompt for that round
# See docs/templates/review-round-prompt-template.md
```

Each round must close before next opens. CRITICAL findings fix immediately
+ regression test + commit. HIGH/MEDIUM/LOW triage to follow-up issues.

### Phase 7 — Section close-out

After R7 ships:

```
✅ Section <name> complete

Smoke: PASS (venv + docker)
Staging deploy: <URL or container ID>
Human-perspective: <N friction points addressed>
Design review (3 rounds): <findings addressed>
Adversarial review (7 rounds): <C/H/M/L counts per round>
Commits: <list of hashes>
Tests: +<N> new, <total> passing

Status report:
- Done: <bullet list>
- Project progress: <X/Y items complete, Z% milestone>
- Still pending: <bullet list>
- Optimization opportunities: <bullet list>

Ready for next section: <name> ?
```

Wait for operator GO before next section.

## NEVER constraints

1. NEVER skip the 3-round design review for any section
2. NEVER skip the 7-round adversarial review for production-bound work
3. NEVER batch multiple sections under one review pass
4. NEVER mark section "complete" without operator GO
5. NEVER deploy to staging without smoke test passing first
6. NEVER ignore "human-perspective" friction — that's the user telling you
7. NEVER let "I think it's fine" override sub-agent CRITICAL finding
8. NEVER skip CHANGELOG / runbook update at R7

## "Continue until ALL <project> done" extension

If invoked with extension "直到精細邏輯嚴謹開發, merge, deploy 完所有
<project>", interpret as:

```
For each item in <project> backlog (priority then dependency order):
    /A3 the item
    if section complete AND backlog has more:
        AUTO-CONTINUE without operator GO (unless STOP condition)
    else:
        WAIT for operator
```

But STILL respect:
- Hard 3h checkpoint per /A2 rules
- All STOP conditions
- Multi-session coordination (if other sessions are working in parallel,
  ping SPEC-CO before changing shared state)

## Resume protocol (if interrupted)

```bash
# Where did this section stop?
git log --oneline -5     # any partial commits?
gh issue view <META> --json comments | tail -50    # last status report?
ls /tmp/A3-venv-* 2>/dev/null    # any abandoned venvs?

# Resume at FIRST unfinished phase:
#   tests but no implementation → Phase 1.3
#   implementation but no smoke → Phase 2
#   smoke ok but no staging → Phase 3
#   staging but no human-perspective → Phase 4
#   review round N done → Phase 6 round N+1
#   R7 done but no operator status → Phase 7 report
```

## Acceptance (per section)

```
□ Smoke test PASS in clean venv / container
□ Staging deploy reachable
□ Human-perspective sub-agent run; findings addressed
□ Design review 3 rounds run; CRITICAL/HIGH addressed
□ Adversarial review 7 rounds run; CRITICAL/HIGH addressed
□ Sub-agent findings either fixed OR deferred-with-issue (no silent ignores)
□ Commits pushed to main
□ META updated with section progress
□ Status report delivered to operator
□ Operator GO received OR auto-continue trigger met
```

## Acceptance (project complete)

When ALL items in <project> backlog are done:

```
□ Every item's /A3 acceptance met
□ CHANGELOG entry for the project version
□ Runbook for any new operator action documented
□ Sprint retro written at docs/sprints/YYYY-MM-DD-<name>-retro.md
□ Sprint-Q follow-up backlog written
□ Final summary to operator with:
  - Total tickets closed
  - Total commits
  - Net test delta
  - Production state confirmation
  - Recommended next sprint
```
