# Contributing

> This repo is the meta-methodology. Improvements should themselves follow
> the 7-stage methodology defined inside.

## Improvement workflow

1. **S1**: open an issue describing the methodology gap or improvement.
   Use `[SPEC]` template at `.github/ISSUE_TEMPLATE/spec.yml`.
2. **S2**: confirm any tools / patterns the improvement touches still work.
3. **S3**: brainstorm 2-3 ways to land the improvement (operator picks).
4. **S4**: open ticket per `.github/ISSUE_TEMPLATE/task.yml`.
5. **S5**: branch, write changes, ensure docs cross-reference correctly.
6. **S6**: run `bash tools/verify_alignment.sh` + `bash tools/check_stage_docs.sh`.
   For substantive changes, run R1-R7 adversarial review (sub-agent dispatch).
7. **S7**: open PR with `.github/PULL_REQUEST_TEMPLATE.md` checklist filled.

## Acceptance for v1.x change

- All cross-references resolve (alignment tool green)
- Stage docs maintain structure (stage-docs tool green)
- README.md and METHODOLOGY.md stay synchronized with stage files
- Commit message conventional (`docs:` / `feat:` / `fix:`)

## Don't pollute

- New stage X? Only if existing 7 cannot absorb the concept.
- New pattern? Only with ≥1 real precedent cited.
- New command? Only if existing commands cannot be parameterized to cover.

## Provenance

Every claim must trace to a real incident, sprint, or operator decision.
Hypothetical patterns belong in `docs/lessons-learned/HYPOTHETICAL.md`,
not in stages or patterns.
