# Stage 4 — Tickets & Milestones

> **Goal**: Every distinct work unit has a GitHub issue. Cross-repo work has
> a Project board. Single META issue is the truth.
> **Anti-goal**: "Track it in my head" — 3 weeks later, lost.

## Required artifacts

1. **META tracking issue** (1 per sprint, pinned at repo)
2. **GitHub Project** (cross-repo, board view)
3. **Milestones** (≥2: PRE-LIVE gate / LIVE flip / post-LIVE follow-ups)
4. **Per-work-unit issue** with full body (see template)
5. **Labels** (priority, origin, type, area)

## Step-by-step

### 4.1 — Verify gh + repo + labels + existing milestones

```bash
gh auth status
gh repo view --json nameWithOwner,defaultBranchRef
gh label list --limit 100
gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/milestones --paginate -q '.[] | "\(.number) \(.state) \(.title)"'
```

### 4.2 — Create milestones (if missing)

```bash
gh api repos/OWNER/REPO/milestones \
  -f title="<sprint>-pre-live gate" \
  -f description="<scope statement>" \
  -f state=open \
  -q .number

gh api repos/OWNER/REPO/milestones \
  -f title="<sprint> LIVE flip + closure" \
  -f state=open

gh api repos/OWNER/REPO/milestones \
  -f title="<sprint> follow-ups (post-LIVE)" \
  -f state=open
```

### 4.3 — Create labels (if missing)

Standard set:

| Label | Color | Purpose |
|---|---|---|
| `p0` `p1` `p2` `p3` | red→yellow | priority |
| `pre-live` | red | must close before LIVE flip |
| `blocker` | red | hard dependency |
| `nice-to-have` | grey | quality polish |
| `sprint-<name>` | yellow | sprint identity |
| `type-code` `type-test` `type-spec` `type-deploy` | green/blue | nature of work |
| `qa-r1` ... `qa-r7` | red | adversarial round origin |
| `operational` | blue | non-code operator task |

```bash
gh label create p0 --color B60205 --description "Priority P0 critical"
# ... repeat per label
```

### 4.4 — Per-issue body template

Use [`docs/templates/ticket-template.md`](../templates/ticket-template.md):

```
## Source
- Sprint: <name>
- Triggered by: <commit hash / incident / spec section>
- Backlog reference: docs/sprints/<file>.md item N

## Risk
- What goes wrong if NOT done
- Severity if shipped broken
- Blast radius

## Acceptance
- [ ] testable criterion 1
- [ ] testable criterion 2
- [ ] regression test exists at <path>

## Effort
~Xh (M components × Y hours)

## Owner
Specific name OR "operator (Vins)" OR "<session-name> session"

## Blocked by / Blocks
- Blocked by: #N
- Blocks: #M

## Cross-references
- META: #PIN
- Project: #BOARD
- Related: #X, #Y
```

### 4.5 — Create META tracking issue

The META issue is the **single source of truth**. Body structure:

```
## 📋 Master tracking for <sprint>

**HEAD**: <commit hash>
**Tests**: N passing
**Project**: <board URL>

## 🚦 Operational (sequential)
- [ ] #N OP-1 ...
- [ ] #N OP-2 ...

## 🔴 P1 pre-LIVE blockers
- [ ] ...

## 🟡 P2 sprint
- [ ] ...

## 🟢 P3 polish
- [ ] ...

## 📊 Status snapshot table

## 🎯 Gating contract for LIVE flip
1. Gate description → issue ref
2. ...

## 📚 References
- CHANGELOG, runbook, spec, prior META, etc.
```

Pin it:
```bash
gh issue pin <number>
```

### 4.6 — Create Project board

```bash
gh project create --owner OWNER --title "<sprint> roadmap"
# Returns project number
gh project item-add PROJECT --owner OWNER --url <issue-url>
# Loop over all sprint issues
```

### 4.7 — Cross-link

Every issue body MUST link to META. META MUST list every issue. Comment
chain on each issue cross-references peers.

For multi-repo sprints, create a mirror META on each repo two-way linked
(see [`docs/patterns/multi-session-coordination.md`](../patterns/multi-session-coordination.md)).

## Sizing rule

- 1 ticket = 1 deliverable. If a ticket has 3 unrelated deliverables, split.
- 1 ticket = ≤ 1 day of work. If > 1 day, split.
- Tests are part of the ticket, not separate ticket.
- Documentation update is its own ticket only if scope-changing.

## Anti-patterns

- **Single mega-ticket**: "Build feature X" → split into ≤5 sub-tickets
- **No acceptance criteria**: closes how? when? by whose call?
- **Owner = "us"**: nobody is responsible → escalation impossible
- **No effort estimate**: can't prioritize → unscheduled work
- **Label-only org**: scrolling through 50 issues without milestones

## Time budget

| Sprint size | Ticket creation |
|---|---|
| 1-3 tickets | 30 min |
| 4-10 tickets | 1-2 hours |
| 10-30 tickets (full sprint) | 2-4 hours |
| Cross-repo + Project + META | 3-6 hours |

## Real precedent

AIOT v15.5 created 23 Strategies + 22 OB-Dev = 45 items in Project #19,
with 5 milestones, 30+ labels, META #327 pinned + #1773 mirror.

See [`examples/sprint-P-walkthrough.md`](../../examples/sprint-P-walkthrough.md) §S4.

## Self-validate

- [ ] META issue exists, pinned, and lists every item
- [ ] Project board has all items, not just some
- [ ] Every issue has acceptance criteria (no "looks good" allowed)
- [ ] Every issue has named owner (not "us" or "TBD")
- [ ] Dependency chain (blocked-by / blocks) makes the sequence visible
- [ ] Cross-repo items mirrored on both sides if applicable
