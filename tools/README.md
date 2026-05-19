# Tools

Three portable validators that gate methodology-doc quality.

## verify_alignment.sh

**Purpose**: cross-reference integrity check.

**Checks**:
1. All 7 stage files exist (`docs/stages/01-*.md` through `07-*.md`)
2. All commands have 7 required sections
3. Patterns referenced in stages exist in `docs/patterns/`
4. METHODOLOGY.md links resolve
5. README.md entry-point references resolve

**Exit codes**:
- `0` — all checks pass
- `1` — drift detected, fix per output

**Usage**:
```bash
bash tools/verify_alignment.sh
```

**Portability**: macOS Bash 3.2 + Linux. No `mapfile`, no `pipe-to-while`.

## check_stage_docs.sh

**Purpose**: every stage doc has the required structural sections.

**Required per stage doc**:
- "Goal" section
- One of: Inputs / Required outputs / Probe questions / Resource categories /
  Step-by-step / Required artifacts / TDD-first / 7-round / 9-gate
- One of: Anti-patterns / Forbidden behaviors / Constraints / NEVER
- "Self-validate" section

**Exit codes**:
- `0` — all stage docs structurally OK
- `1` — at least one stage missing a required section

**Usage**:
```bash
bash tools/check_stage_docs.sh
```

Also warns if a stage doc exceeds 500 lines (soft bloat limit).

## check_gates.py

**Purpose**: parse a sprint META issue's gate progression (G1-G9 per S7).

**Inputs**:
- `--repo OWNER/REPO`
- `--meta <META_ISSUE_NUMBER>`

**Output**: gate-by-gate status + next-action recommendation.

**Exit codes**:
- `0` — all 9 gates passed
- `1` — at least one gate still open

**Usage**:
```bash
python3 tools/check_gates.py --repo AIOTMM/agent-5.2-binance-perp --meta 327
```

**Requires**:
- Python 3.8+
- `gh` CLI authenticated
- META issue must use `- [ ] G1 — rc-tag` style checkboxes

**Note**: this tool is a LIVE GitHub-data reader. It does NOT validate the
methodology repo itself; it's for downstream sprints that use the methodology.

## CI integration

Recommended pre-commit hook for methodology repo:

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit
bash tools/verify_alignment.sh || exit 1
bash tools/check_stage_docs.sh || exit 1
```

For downstream projects: invoke `check_gates.py` from sprint-close cron OR
from `/sprint-kickoff` precondition check.

## Limitations

- These tools check STRUCTURAL integrity, not SEMANTIC correctness.
- Sub-agent adversarial review (S6) catches semantic bugs.
- Validators are NECESSARY (catch easy stuff) but NOT SUFFICIENT.
