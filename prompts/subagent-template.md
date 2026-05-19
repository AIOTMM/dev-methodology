# Sub-agent prompt template

> Generic template for any sub-agent dispatch. For S6 review-specific
> dispatches, use `prompts/reviewer-prompt.md` (specialization of this).

---

## 6 required sections (per `docs/stages/05-development.md` §"Sub-agent prompt requirements")

```
## Context

(1 paragraph: what the parent session has done so far — verified facts only,
not "you remember")

## Task

(1-2 sentences: what you want this sub-agent to produce)

## Inputs

- File paths: <absolute paths>
- Commits: <hashes>
- Issue numbers: <list>
- Other refs: <list>
(NOT "you know which file" — be explicit)

## Constraints (NEVER list)

1. NEVER <constraint> — <rationale>
2. NEVER <constraint> — <rationale>
3. ...

## Output format

(Structured. Specify:
- Format (markdown table / JSON / bullet list)
- Word cap
- Required fields per item
- Sort order)

## Self-validate

(Sub-agent answers before submitting:
- [ ] Did I follow output format?
- [ ] Under word cap?
- [ ] No constraint violated?
- [ ] All inputs referenced?)
```

## Example fill-in for a research dispatch

```
## Context
We're at S2 of methodology. Spec at docs/specs/2026-XX-XX-feature.md.
Spec mentions Stripe webhook handling. I need to confirm Stripe webhook
secret rotation policy doesn't block deploy.

## Task
Research current Stripe webhook secret rotation behavior. Confirm whether
in-flight webhooks during rotation are dropped or queued.

## Inputs
- Spec section: docs/specs/2026-XX-XX-feature.md §"Stripe webhook"
- Current Stripe API version in use: 2023-10-16
- Production endpoint: <URL>

## Constraints
1. NEVER assume — cite Stripe docs URL per claim
2. NEVER recommend tools outside Stripe SDK
3. NEVER suggest disabling signature verification

## Output format
- Single markdown report, max 400 words
- 3 sections: behavior / risk / recommendation
- Cite ≥2 Stripe docs URLs

## Self-validate
- [ ] Every claim has a Stripe-docs URL
- [ ] No "should" / "probably" — facts or "unknown"
- [ ] Under 400 words
- [ ] Recommendation is actionable
```

## When to use this vs `reviewer-prompt.md`

| Task | Template |
|---|---|
| S6 adversarial review (R1-R7) | `prompts/reviewer-prompt.md` |
| Search / exploration | this template (Context = "I need to find X") |
| Parallel implementation | this template (Task = specific file/function to build) |
| Documentation lookup | this template |
| Independent decision check | this template + reviewer-prompt's adversarial framing |

## Parent-session responsibilities

After dispatching:
- Verify sub-agent's claimed work (git diff, file contents)
- Apply findings using sub-agent's structured output
- NEVER trust narrative summary without verification

Per `docs/stages/05-development.md` §"trust me sub-agent reports".
