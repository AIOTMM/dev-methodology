# Dev-Methodology

> **A combat-tested, multi-session AI-augmented software-development framework
> extracted from the AIOT v15.5 + Sprint-P production sprint (2026-05).**
>
> 12 CRITICAL bugs caught across 7 adversarial review rounds. 772 tests
> ship-green. 45-item cross-repo Project board. 23-day spec→LIVE waterfall.
> The methodology that produced this is what this repo distills.

---

## What this repo is

A drop-in development methodology you can copy into ANY non-trivial project to:

> **Domain context**: The methodology was extracted from AIOT (a cryptocurrency
> trading system) Sprint-P, but is project-agnostic. See
> [`docs/GLOSSARY.md`](docs/GLOSSARY.md) for term translations and
> [`PREREQUISITES.md`](PREREQUISITES.md) for environment setup.

1. **Define a spec rigorously** (not "vibe code")
2. **Confirm production resources** before code is written
3. **Brainstorm with adversarial alternatives** (not consensus-first)
4. **Plan tickets + milestones + cross-repo Project boards**
5. **Develop with TDD + sub-agent dispatch**
6. **Self-validate via 7-round adversarial review**
7. **Deploy via gated waterfall** (Stage 0 → soak → paper → LIVE flip)

Each stage has a `docs/stages/0N-*.md` file with checklist + acceptance.

Each stage has skill files (`skills/`) + prompt templates (`prompts/`) + slash
commands (`commands/`) you can copy-paste into Claude Code / Cursor / Codex.

## When to use this

- ✅ Multi-session AI development (Strategies + OB-Dev + Coordinator pattern)
- ✅ Production deploy with safety gates (paper → soak → LIVE flip)
- ✅ Cross-repo coordination (e.g. backend repo + infra repo)
- ✅ Sprints where regression cost > development cost
- ✅ Operator-in-the-loop systems (financial / safety-critical / multi-tenant)

## When NOT to use this

- ❌ Single-file scripts (< 200 lines total project)
- ❌ Throwaway prototypes
- ❌ Solo-developer 1-day fixes
- ❌ Cases where 7-round review > 50% of total effort budget

## Entry points

- **New to this**: read `METHODOLOGY.md` (15-min overview) → `dev-agent.md`
- **Starting a project**: copy `prompts/spec-kickoff-prompt.md` to your session
- **Mid-sprint**: jump to `docs/stages/0X-*.md` matching your current stage
- **Stuck cross-session**: read `docs/patterns/multi-session-coordination.md`
- **Need to review work**: `commands/A1-continue-dev.md` (single round) or `docs/patterns/adversarial-review-7-rounds.md` (full doctrine)
- **Lessons learned**: `docs/lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md`

## Repo structure

```
dev-methodology/
├── README.md                       ← you are here
├── METHODOLOGY.md                  ← 7-stage waterfall overview
├── dev-agent.md                    ← Claude agent definition
├── CLAUDE.md                       ← project-local Claude config
├── docs/
│   ├── stages/0[1-7]-*.md          ← stage-specific playbooks
│   ├── patterns/                   ← reusable patterns (multi-session, gates, etc.)
│   ├── lessons-learned/            ← real sprint retros + ANTI-PATTERNS.md
│   └── templates/                  ← spec / runbook / handoff templates
├── skills/                         ← Claude Code skill files (loadable)
├── prompts/                        ← session-kickoff prompt templates
├── commands/                       ← slash command implementations
├── tools/                          ← verify_alignment.sh + check_gates.py etc.
├── .github/                        ← issue templates + PR template
└── examples/sprint-P-walkthrough.md  ← real-world reference
```

## Tested in production

- AIOT v15.5 Path B sprint (3 strategy ports, $200K+ aggregate position)
- Sprint P Hummingbot integration (5 daemons + cron infra)
- 7-round adversarial review caught: shell injection, multi-leg DB drop,
  exit slippage zero-out, RSI hysteresis missing, 5 more CRITICALs
- Single-day Strategies+OB-Dev coordination, 0 merge conflicts

## License

MIT — copy freely. If it works for you, tell `vins@bitabc.io`.
