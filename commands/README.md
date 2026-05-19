# Commands

> Polished, Claude-optimized, zero-failure-target prompt templates extracted
> from AIOT v15.5 + Sprint-P real usage.

## Quick reference

| Command | Purpose | Typical duration | Operator presence |
|---|---|---|---|
| `/sprint-kickoff` | Plan next sprint, 3-round validate, create META + tickets + checklist | 1-4h | required |
| `/A1` | Continue dev item-by-item with per-step sub-agent review | per-ticket 1-4h | required at ticket close |
| `/A2` | Autonomous up-to-12h with 3h hard checkpoints | up to 12h | offline during run |
| `/A3` | Per-section smoke + venv deploy + 3-round design + 7-round adversarial | per-section 2-8h | gates between sections |
| `/MP` | Multi-project continuous; rotates between projects until all done | up to 12h+ | offline during run |

## Invocation pattern

Each command is a self-contained markdown file. To invoke:

```
# In your Claude session:
"Read /path/to/dev-methodology/commands/<command>.md and execute according to that spec."

# OR if dev-methodology is the working repo:
"/A1"   (if Claude Code has slash command mapping)

# OR via prompt template:
cat dev-methodology/commands/<command>.md | claude
```

## Composition

Commands chain naturally:

```
new sprint?
    /sprint-kickoff → /A1 (P0/P1) → /A1 (P2) → /A3 (S7 deploy prep)

long-haul day?
    /sprint-kickoff → /A2 (overnight) → /A1 (morning catch-up)

multi-project release?
    /MP (rotate) → /A3 (final per-project) → operator LIVE flip
```

## What was removed from user's original prompts (and why)

The user's natural-language prompts mixed:
- Imperative commands ("接續開發")
- Emotional emphasis ("精細邏輯嚴謹", "不准停下", "完美")
- Aspirational goals ("turing-complete", "沒有任何縫隙")
- Implicit assumptions ("sprint exists", "tests are green")
- Repetition (same paragraph appearing 2-3 times)

The polished versions:
- Use Claude-friendly structure (preconditions / execution / acceptance)
- Replace emotional emphasis with measurable gates
- Translate aspirational goals into honest checkable criteria
- Make implicit assumptions EXPLICIT (preconditions section)
- Deduplicate via cross-references

This is NOT softening — it's making the goals achievable. "Turing-complete"
is a goal; the methodology makes it measurable via acceptance criteria.

## Anti-amnesia features

Every command includes:

1. **Preconditions** — what must be true before the command runs
2. **Resume protocol** — if interrupted, how to figure out where we were
3. **NEVER constraints** — repeated each time so a fresh session honors them
4. **Acceptance gates** — explicit "done" definition
5. **Cross-references** — links to `docs/stages/`, `docs/patterns/`,
   `docs/templates/` so a fresh session can self-bootstrap

## Operator's natural-language → command mapping

| If operator says | Run |
|---|---|
| "start next sprint" / "plan to-dos" | `/sprint-kickoff` |
| "繼續開發" / "繼續" / "接著做" | `/A1` |
| "晚上自動跑" / "12 小時 autonomous" / "我去睡覺" | `/A2` |
| "每個 section 都驗收" / "smoke test 每個" / "7 rounds review" | `/A3` |
| "把所有 project 都做完" / "做完所有 items" | `/MP` |
| "deploy" / "上線" / "flip LIVE" | `/A3` §S7 (NOT autonomous — operator gate) |

## Customization

Each command has the same structure so you can customize per-project:

- `<test_runner>` → `pytest` / `cargo test` / `npm test`
- `<lint_runner>` → `ruff` / `clippy` / `eslint`
- `<prod-host>` → your EC2 / Cloud Run / etc.
- `<critical-daemons>` → your `systemctl` service list
- `<META>` → your sprint's META issue number

Substitute these in your project's CLAUDE.md or in command invocation prompt.

## Don't pollute

If you find yourself wanting to add `/A4`, `/A5`, etc. — first check whether
existing commands cover it. If yes, document the case as an example in
the existing command. If no, draft the new command in a sibling file and
get it through 7-round review like any other artifact.

## Version

`commands/` v1.0 — extracted 2026-05-19 from Sprint-P sprint + QA-R1..R7
adversarial review iteration. Self-validated 3 rounds.
