## What

(One-sentence summary of what this PR does — not why)

## Why

(Why this PR exists — link to issue, spec, or incident)

Closes #<issue>

## How

(High-level approach, not line-by-line. Reviewer reads diff for that.)

## Self-validate (implementer must check before requesting review)

- [ ] Tests added (TDD red→green for new behavior)
- [ ] Full test suite green
- [ ] Lint clean on touched files
- [ ] Conventional commit prefix used
- [ ] No `--no-verify` / `--force` used
- [ ] No secrets committed (env vars, keys, tokens)
- [ ] CHANGELOG entry added (if user-visible)
- [ ] Runbook updated (if operator-visible change)

## S6 adversarial review

- [ ] Sub-agent review dispatched on this branch
- [ ] CRITICAL findings: fixed in this PR or escalated to operator
- [ ] HIGH findings: addressed or operator-typed acknowledgement
- [ ] MEDIUM/LOW: filed as follow-up issues (cite numbers)

Round(s) covered: R1 ☐ R2 ☐ R3 ☐ R4 ☐ R5 ☐ R6 ☐ R7 ☐

## Cross-references

- Sprint META: #
- Spec: `docs/specs/...`
- Adjacent issues: #
