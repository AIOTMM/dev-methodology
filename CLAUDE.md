# CLAUDE.md (project-local)

> Project: `dev-methodology` (the meta repo defining how to build other repos).
> This file overrides Claude's defaults FOR THIS REPO. The methodology
> herein is what you copy INTO other projects.

## Operating constraints in this repo

1. **Markdown-only** — there is no code to compile. Edits land in `.md` files.
2. **Self-referential discipline** — if you change methodology in
   `METHODOLOGY.md`, also update the affected stage / pattern / template files.
   Cross-link is enforced by `tools/verify_alignment.sh`.
3. **Never auto-rewrite history** — these docs are studied; commits should
   read clean.
4. **Every new pattern needs a real precedent** — cite at least one sprint
   or incident in `docs/lessons-learned/` proving it was real, not hypothetical.

## How operators use this repo

- READ for understanding: `README.md → METHODOLOGY.md → dev-agent.md`
- COPY into a new project:
  ```bash
  cp dev-methodology/dev-agent.md myproject/
  cp dev-methodology/CLAUDE.md myproject/
  cp -r dev-methodology/{skills,prompts,commands,tools} myproject/
  ```
- Customize `CLAUDE.md` per-project; keep methodology files as-is for
  upstream sync.

## Sync upstream

If you improve this methodology in a downstream project, push the diff back
to this repo via PR. The methodology is meant to ratchet.

## Validation

Before merging any change:

```bash
bash tools/verify_alignment.sh   # checks cross-refs not broken
bash tools/check_stage_docs.sh   # checks every stage has acceptance criteria
```
