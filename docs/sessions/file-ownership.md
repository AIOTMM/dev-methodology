# File ownership (cross-session)

> When multiple Claude sessions work on the same repo or related repos,
> define WHO OWNS WHAT before any code edits.
>
> Required by `docs/stages/05-development.md` §"Cross-session handoff
> during S5" and `docs/patterns/multi-session-coordination.md`.

## Why this exists

Real failure mode:

```
Session A edits file F. Session B is also editing F.
Both push within minutes. Last push wins. First push's changes lost.
Resolution: hours of "what did A actually do?" detective work.
```

File ownership prevents this: each file has a designated owner-session.
Non-owners must coordinate before editing.

## Per-project setup

In your project's `CLAUDE.md`, add a file-ownership table:

```markdown
## File ownership (cross-session)

| Path | Owner session | Editable by others? |
|---|---|---|
| core/strategy/* | Strategies | NO (open issue first) |
| core/infra/* | OB-Dev | NO |
| docs/specs/* | (current sprint owner) | YES (PR review) |
| docs/sprints/* | SPEC-CO | NO |
| operator-decisions-*.md | Operator (Vins) | NEVER |
| .github/* | First-to-edit, then frozen | NO without coordination |
```

## Resolution rules

If you need to edit a non-owned file:

1. STOP before editing
2. Open issue in shared META OR comment on existing ticket
3. Describe: what change, why, why now
4. Tag the owning session for ack
5. Wait for ack (or operator override) before editing
6. Owner session merges proposed change, OR delegates

Coordination cost is real but bounded; merge-conflict cost is unbounded.

## What "ownership" actually means

- **Owner**: writes / refactors / closes issues on this file
- **Reviewer rights**: anyone can read, anyone can comment, anyone can open issue
- **Edit rights**: only owner OR operator override OR SPEC-CO arbitrated decision

## When ownership boundaries are unclear

If a file is genuinely shared (e.g. `CHANGELOG.md`, `README.md`):

- Mark as "FIRST-TO-EDIT, then frozen for this sprint"
- Or designate explicit shared-ownership: "Strategies + OB-Dev co-own, PR review"

## When ownership changes

Sprint-by-sprint OK. Don't hot-swap mid-sprint without coordination.

## Real precedent

AIOT v15.5 Sprint-P (May 2026):

```
Strategies session: code in agent-5.2-binance-perp/{core,strategies,tests}/*
OB-Dev session:     code in AIOT-MVP/{bin,deploy,db}/*
SPEC-CO session:    META issue bodies + Project board only (no code)
Operator (Vins):    operator-decisions-*.md (typed answers), magic phrases
```

Result: 0 merge conflicts over 3-day parallel sprint.

## Self-validate

- [ ] CLAUDE.md has ownership table
- [ ] Every active session knows its scope
- [ ] Non-owned edits go through coordination first
- [ ] Operator owns operator-only files (decisions, phrases)
- [ ] SPEC-CO owns META + Project + decision logs

## Anti-pattern: implicit ownership

```
# WRONG (vague — both sessions assume they "own" engine):
"Strategies handles strategy code, OB-Dev handles infra"

# CORRECT (explicit per-file):
"Strategies owns core/strategy/* + strategies/* + their tests.
 OB-Dev owns bin/* + deploy/* + db/migrations/* + .github/workflows/*."
```

Vague ownership = no ownership. Make it grep-able.
