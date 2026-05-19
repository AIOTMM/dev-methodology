# /sprint-kickoff — Plan next sprint with 3-round self-validate

> **Replaces user's verbose**: "使用 superpower 為我精細邏輯嚴謹規劃下一
> round 的 to do lists, superpower review & self-validate 3 輪, 寫好
> roadmap items 推上 github projects 並開好 tickets, 並寫好一個新一輪
> development & deployment 的 checklists"

## When to invoke

- Starting a new sprint after previous sprint closes
- Adding a major scope chunk to existing sprint
- After 5+ tickets close and operator wants the next batch planned

## When NOT to invoke

- Mid-sprint with open critical-path items
- Within 24h of LIVE flip (focus, don't plan)
- Before previous sprint's retro is written

## Preconditions (verify before executing)

```bash
# Previous sprint state captured?
gh issue view <PREVIOUS_META> --json state,body | grep -E "closed|✅"

# Working tree clean?
git status --short    # must be empty

# Last commit pushed?
git log @{u}..HEAD --oneline    # must be empty
```

If any fails → STOP, fix, then resume.

## Execution

### Step 1 — Read context (no writes yet)

```bash
# Read previous sprint META + retro
gh issue view <PREVIOUS_META> --json body -q .body | head -200
cat docs/sprints/<PREVIOUS_RETRO>.md 2>/dev/null

# Read deferred backlog
cat docs/sprints/<CURRENT>-backlog.md

# Read user's CLAUDE.md + project CLAUDE.md (rules of engagement)
cat ~/.claude/CLAUDE.md
cat ./CLAUDE.md 2>/dev/null
```

### Step 2 — Draft roadmap (in memory, not yet committed)

Identify, in this order:

1. **Carried-forward P1 items** from previous sprint Sprint-Q backlog
2. **New asks** from operator (this turn's user message)
3. **Risk-derived items** (anything in lessons-learned/ANTI-PATTERNS.md
   that current state could hit)
4. **Hygiene items** (CHANGELOG update, runbook sync, etc.)

Categorize by priority:
- P0 BLOCKER: must close before any other work
- P1 pre-LIVE: must close before next LIVE flip
- P2 sprint: should close this sprint
- P3 polish: nice-to-have

### Step 3 — Self-validate round 1 (completeness)

Answer YES to ALL:

- [ ] Every previous Sprint-Q item with P1 label appears here OR is explicitly deferred-with-reason
- [ ] Every user-mentioned new ask appears as ≥1 ticket
- [ ] Every "carried risk" from previous retro has a mitigation item
- [ ] No item depends on undocumented external work

If any NO → fix and re-validate round 1.

### Step 4 — Self-validate round 2 (sizing + dependencies)

For every item:

- [ ] Effort estimate is a range (e.g. "3-5h") not a point
- [ ] Owner is named (specific session/person, not "us")
- [ ] Dependencies cite issue numbers (not "after we do X")
- [ ] Acceptance criteria are testable

If any NO → fix and re-validate round 2.

### Step 5 — Self-validate round 3 (anti-patterns)

Check against `docs/lessons-learned/ANTI-PATTERNS.md`. For each item ask:

- [ ] Is this a mega-ticket (3+ unrelated deliverables)? → split
- [ ] Is this manual SQL / manual deploy disguised as "operational"? → wrap script
- [ ] Does this skip S6 review? → reject
- [ ] Does this hide risk in "should work"? → demand testable acceptance

If any YES → revise.

### Step 6 — Create GitHub artifacts (only after 3 rounds pass)

```bash
# Milestones (if not exist)
gh api repos/$REPO/milestones -f title="<sprint>-pre-live" -f state=open
gh api repos/$REPO/milestones -f title="<sprint>-live-flip" -f state=open
gh api repos/$REPO/milestones -f title="<next>-follow-ups" -f state=open

# Labels (one-time per repo, see docs/stages/04-ticket-creation.md §4.3)

# Per-issue: use docs/templates/ticket-template.md
gh issue create --milestone "..." --label "p1,pre-live,..." --body "..."

# META tracking issue
gh issue create --milestone "<sprint>-pre-live" \
  --title "[META] <sprint> tracking dashboard" \
  --body "$(cat docs/templates/meta-tracking-issue-template.md)"
gh issue pin <META_NUMBER>

# Project board (if not exists)
gh project create --owner $OWNER --title "<sprint> roadmap"
for n in $TICKET_NUMBERS; do
  gh project item-add <PROJECT> --owner $OWNER --url "https://github.com/$REPO/issues/$n"
done
```

### Step 7 — Write sprint checklist

Output to `docs/sprints/YYYY-MM-DD-<sprint>-checklist.md` using
[`docs/templates/sprint-checklist-template.md`](../docs/templates/sprint-checklist-template.md).

Structure:
```
## Pre-development gates
## Development sequence (by priority)
## Per-ticket review gates (S6 rounds)
## Pre-deploy gates (S7 G1-G9)
## Post-deploy monitoring
## Retro trigger
```

Commit:
```bash
git add docs/sprints/
git commit -m "docs(sprint): <sprint> kickoff — N tickets across M milestones"
git push origin main
```

### Step 8 — Hand off

Post on operator's expected channel (Telegram / issue comment / direct):

```
🚀 <sprint> kickoff complete

Roadmap: N tickets (Px breakdown)
Milestones: M
Project board: <URL>
META issue: #<NUMBER> (pinned)
Checklist: docs/sprints/<file>.md

Ready for /continue-dev (A1) on first P0/P1 item.

Top-3 risks flagged:
1. ...
2. ...
3. ...
```

## NEVER constraints

1. NEVER skip the 3 self-validate rounds (S3-S5)
2. NEVER create tickets without acceptance criteria
3. NEVER pin a META issue with "TBD" sections
4. NEVER assign owner = "us" or "TBD"
5. NEVER quote external work without issue link
6. NEVER push to remote until 3 self-validates pass
7. NEVER use `--force` / `--no-verify` on the kickoff commit

## Resume protocol (if interrupted mid-execution)

```bash
# Check which step you were at:
[ -f docs/sprints/*-checklist.md ] && echo "Step 7+ done"
gh issue list --milestone "<sprint>-pre-live" --state open | wc -l   # > 0 means Step 6 done
git log -1 --format='%s' | grep -q "sprint.*kickoff" && echo "Step 7 commit done"

# Resume from the FIRST unfinished step. If unsure → restart from Step 1.
```

## Acceptance

```
□ All 3 self-validate rounds documented in the kickoff commit body
□ META issue pinned at repo
□ Project board populated with ALL tickets (count = ticket count)
□ Sprint checklist committed
□ Operator notified with kickoff summary
□ git log @{u}..HEAD is empty (everything pushed)
```

All boxes checked → /sprint-kickoff complete. Continue with /A1.
