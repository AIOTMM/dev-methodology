# Prerequisites

> What you need set up BEFORE using this methodology.

## Required tools

### 1. AI agent runtime (one of)

| Tool | Path conventions | Sub-agent equivalent |
|---|---|---|
| **Claude Code** (CLI) | `~/.claude/agents/`, `~/.claude/commands/` | `Agent` tool with `subagent_type` |
| **Cursor** | `.cursor/rules/` (project), `.cursor/commands/` | Not supported (use main thread) |
| **Codex** (OpenAI) | `.codex/` per project | Limited sub-agent support |
| **Other** | flat-file fallback: copy files into project root | sequential prompts in main thread |

This methodology was developed against Claude Code. Other runtimes may need
adaptation; sub-agent dispatch (S6 R1-R7) is the main feature that varies.

### 2. GitHub CLI (`gh`)

```bash
# Install: https://cli.github.com/
gh auth status   # must show authenticated
gh repo view     # must work in your repo
```

GitLab / Bitbucket / Jira users: this methodology assumes GitHub for issues
+ Projects + milestones. Substitute your tracker's equivalent for `gh` calls;
abstract requirement is "one canonical META + a board view".

### 3. Git (≥2.30)

```bash
git --version   # 2.30+ recommended for `git verify-commit`
```

GPG signing optional but required for S7 G3 operator-decisions
verification:

```bash
git config --get user.signingkey   # if empty, set up GPG
gpg --list-secret-keys              # at least one key
```

### 4. Code-reviewer sub-agent (Claude Code)

The methodology uses `code-reviewer` sub-agent type heavily for S6 rounds.
If your Claude Code installation doesn't have it:

```bash
# Add to ~/.claude/agents/code-reviewer.md (Claude Code agent definition format).
# Or use generic sub-agent with `prompts/reviewer-prompt.md` content.
```

See `prompts/reviewer-prompt.md` for the prompt template that works across
runtimes.

## Optional but recommended

### CodeRabbit (PR review bot)

If integrated to your repo, S6 R1 ("CodeRabbit / existing feedback sweep")
gets free input. Without it, R1 still works against any prior PR review
comments.

### Tester runner

The methodology references `<test_runner>` placeholder. Substitute:

- Python: `pytest`
- Rust: `cargo test`
- Node: `npm test` / `pnpm test`
- Go: `go test ./...`

Set in your project's CLAUDE.md so commands can substitute.

### Lint runner

Similarly `<lint_runner>`:

- Python: `ruff check` / `mypy`
- Rust: `cargo clippy`
- Node: `eslint` / `tsc --noEmit`
- Go: `go vet`

## Recommended project structure after copy-in

```
your-project/
├── dev-agent.md             ← copy from dev-methodology
├── CLAUDE.md                ← customize per project
├── docs/
│   ├── specs/               ← S1 outputs
│   ├── sprints/             ← per-sprint checklists + retros
│   └── methodology/         ← copy of dev-methodology docs (optional)
├── .github/
│   ├── ISSUE_TEMPLATE/      ← copy from dev-methodology
│   └── PULL_REQUEST_TEMPLATE.md  ← copy from dev-methodology
├── commands/                ← copy from dev-methodology
├── prompts/                 ← copy from dev-methodology (or symlink)
├── skills/                  ← copy applicable skills
└── (your source tree)
```

## Setup verification

```bash
# After copy-in, run:
bash <path-to-dev-methodology>/tools/verify_alignment.sh

# Should pass on a fresh copy. If FAIL, your copy is missing files.
```

## When things differ

Your project's CLAUDE.md should ALWAYS override this methodology where they
conflict. The methodology is a starting point; your project's reality is
authoritative.

Bidirectional improvements: if your project's adaptation produces a better
pattern, contribute upstream via PR (see [`CONTRIBUTING.md`](CONTRIBUTING.md)).
