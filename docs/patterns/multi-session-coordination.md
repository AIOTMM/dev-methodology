# Multi-session coordination

> Pattern for parallel Claude sessions on multiple repos.

## When

- ≥2 repos with cross-dependency
- ≥2 implementers (or 1 implementer per repo)
- Single deploy goal

## Architecture

```
        SPEC-CO (Coordinator)
        - no code
        - maintains META truth
        - arbitrates ambiguity
              │
       ┌──────┴──────┐
       ▼             ▼
 Implementer-A   Implementer-B
 (repo A)        (repo B)
       │             │
       └──── Project Board ────
            (cross-repo single source)
```

## Single source of truth

- 1 META issue per repo, pinned, two-way linked across repos
- 1 GitHub Project containing ALL repo's issues
- Operator-decisions file in one repo (operator pinned)

## Handoff protocol

Each session opens with a self-contained prompt (see `prompts/`).
Cross-session touchpoints are explicit triggers (NOT "post everything").

## Anti-pattern: synchronous waiting

If A is blocked on B, A goes to next-priority work, NOT waits.
SPEC-CO arbitrates merging when both reach handoff state.

## Real precedent

AIOT v15.5: SPEC-CO + Strategies + OB-Dev. 45-item cross-repo Project,
0 merge conflicts, parallel work for 3 days.
