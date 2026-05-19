# Glossary

> Acronyms and methodology-specific terms. Reference this when you see an
> unfamiliar abbreviation in stage / pattern / command files.

## Methodology terms

- **S1-S7**: the 7 stages (Spec / Resources / Brainstorm / Tickets / Develop /
  Review / Deploy)
- **R1-R7**: the 7 adversarial review rounds at S6
- **G1-G9**: the 9 deploy gates at S7
- **META**: a "master tracking" GitHub issue, pinned, single source of truth
  per sprint
- **Project board**: GitHub Project (the kanban-style cross-repo view)
- **Sprint-Q backlog**: deferred items from current sprint, sized as v15.6
  follow-ups
- **SPEC-CO**: Spec Coordinator role (cross-session, non-implementing)

## Roles

- **IMPLEMENTER**: writes code, runs tests, commits, pushes in one specific repo
- **COORDINATOR**: cross-session alignment, no code, edits issue/META truth
- **REVIEWER**: adversarial audit only, produces structured findings, no fix code
- **OPERATOR**: the human in the loop; types magic phrases, signs decisions

## Quality-gate terms

- **HFV-EQUIV / HFV equivalence gate**: a project-specific name for
  "preserve-legacy-bit-equivalence" tests. Generalizable: any test suite
  that asserts new code matches legacy behavior in critical paths
- **ABC adapter**: Abstract Base Class adapter pattern — a port of an
  external strategy/module that satisfies a target SDK's interface
- **AVCO**: Average Volume-weighted Cost — finance-domain accounting for
  position cost basis across multiple buys
- **Adversarial review**: sub-agent dispatched with "find worst-case failure"
  framing (vs "looks good?")
- **Soak test / soak monitor**: 24h continuous monitoring before deploy
- **Paper-week**: 7 days of simulated trading before LIVE flip

## Tool terms

- **gh CLI**: GitHub's official command-line interface (https://cli.github.com/)
- **CodeRabbit**: third-party PR review bot (https://coderabbit.ai/)
- **Sub-agent**: an isolated Claude session dispatched by parent for a
  scoped task (review / search / parallel implementation)

## Domain-specific (AIOT trading examples only — generalize when porting)

- **AIOT**: a specific cryptocurrency token (the example domain)
- **Sprint-P**: the May 2026 deploy-preparation sprint
- **v15.5 / v15.4**: AIOT SDK versions
- **BSC**: Binance Smart Chain
- **Hummingbot**: a market-making bot framework
- **Stealth orders / ghosts**: hidden limit orders held off public order book
- **bitabc / vins2 / vinslai**: trading account labels in AIOT

These domain terms appear in `examples/sprint-P-walkthrough.md` and
`docs/lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md`. When applying the
methodology to a non-trading project, substitute domain-equivalent terms
in your own CLAUDE.md / spec files.

## When unsure

If a term isn't here, search:

```bash
grep -rn "<term>" docs/ commands/ skills/ prompts/
```

If you find usage but no definition, open an issue: glossary gap.
