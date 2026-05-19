# Pattern: 4D AI Fluency Framework

> Reference framework for human-AI collaboration. Extracted from vinsai
> session (2026-03-31 brainstorm) and combat-tested across the AIOT v15.5
> + Sprint-P + vinsai_AI life-optimization sprints.

## Source

Rick Dakan (Ringling College of Art and Design) + Joseph Feller (University
College Cork), *4D AI Fluency Framework*. Four capabilities that, combined,
maximize AI-collaboration effectiveness.

The framework names what experienced AI-augmented developers do
implicitly. Naming it makes it teachable + auditable.

## The 4 Ds

### D1 — Delegation (代表團)

**Definition**: decide which tasks the human should do, which the AI should
do, and how to split.

**Methodology integration**:
- S1 spec → human (irreducibly judgment-bound)
- S2 resource smoke tests → AI (mechanical, auditable)
- S3 brainstorm options → AI generates, human picks
- S4 ticket creation → AI orchestrates, human approves META
- S5 implementation → AI for ≥80%; human for irreversible / multi-system
- S6 adversarial review → AI (sub-agent independence) — must
- S7 operator-typed magic phrases / capital allocation → human only

**Decision rubric**:

```
Can a stranger verify the output from the artifact alone?
  YES → delegate to AI
  NO  → human must do (or AI under human's close supervision)

Is the output's reversibility high (can be undone in < 1h)?
  YES → AI can act
  NO  → human must approve before AI acts

Is the cost of getting it wrong > cost of going slowly?
  YES → AI generates draft, human reviews and types final
  NO  → AI acts, human reviews post hoc
```

### D2 — Description (說明)

**Definition**: communicate effectively with AI. Define output, guide
process, specify desired AI behavior.

**Methodology integration**:
- Sub-agent prompt template (`prompts/subagent-template.md`) — 6 required
  sections: Context / Task / Inputs / Constraints / Output / Self-validate
- Handoff prompt requirements (`docs/patterns/cross-session-handoff.md`) —
  9 required sections, self-contained
- NEVER constraints listed per-role, repeated each session
- Reviewer prompt adversarial framing ("find worst-case", not "review for quality")

**Anti-pattern caught**: "you remember what we discussed" — fresh session
has no memory. Description discipline forces self-containment.

### D3 — Discrimination (辨識力)

**Definition**: critically evaluate AI's output, process, behavior. Assess
quality, accuracy, appropriateness; identify improvements.

**Methodology integration**:
- S6 adversarial review (7 rounds across 7 dimensions) — discrimination
  scaled
- Sub-agent dispatch rule: "verify with diff, not narrative summary"
- Triage CRITICAL / HIGH / MEDIUM / LOW per finding
- "Trust me sub-agent reports" is the anti-pattern — always verify

**Concrete discrimination tools**:
- `git diff` to verify sub-agent's claimed work
- `tools/verify_alignment.sh` for cross-ref integrity
- Self-validate checklists at every stage

### D4 — Diligence (勤奮)

**Definition**: use AI responsibly and ethically. Avoid taking shortcuts
that compromise integrity, safety, or others' trust.

**Methodology integration**:
- NEVER `--no-verify` git commits (catches real issues)
- NEVER skip S6 review for "small" changes
- NEVER pretend sub-agent output is verified when it isn't
- NEVER consume operator-only decisions
- Pre-flight resource confirmation (S2) — not "should work" but smoke-tested
- Anti-pattern doc (`docs/lessons-learned/ANTI-PATTERNS.md`) maintained
  across sprints

**Diligence-failure precedent**: from `feedback_aiot_analysis_no_subagent`
memory — sub-agent dispatched for /aiot-analysis hung indefinitely because
main agent didn't add timeouts. Diligence means: every external call has
a timeout, every status report verified, every shortcut explained.

## How the 4Ds compose at each stage

| Stage | D1 Delegation | D2 Description | D3 Discrimination | D4 Diligence |
|---|---|---|---|---|
| S1 Spec | Human writes | Template-bound output | Operator sign-off | All sections filled, no `TBD` |
| S2 Resources | AI smoke-tests | Categorized checklist | Pass/fail per item | Adjacent surfaces also checked |
| S3 Brainstorm | AI options, human picks | 2-3 alternatives + tradeoffs | Operator overrides logged | Strawman alternatives forbidden |
| S4 Tickets | AI creates, human approves META | Template-bound bodies | Cross-link integrity | Owner = specific name |
| S5 Develop | AI implements, human approves | Conventional commits | Tests must run | Trust-but-verify diff |
| S6 Review | AI sub-agents per round | Adversarial framing | 7 dimensions, no compression | CRITICAL fixes mandatory |
| S7 Deploy | AI gates, human at G3/G8 | Audit log per gate | Each gate's acceptance | NEVER manual SQL flip |

Every stage owes acceptance to all 4 Ds. Missing one → quality erodes.

## When 4D fails

- **D1 over-delegation**: AI types magic phrase. Operator trust gone.
- **D1 under-delegation**: human writes mechanical S2 smoke tests. Time wasted.
- **D2 vagueness**: "make it better" → AI guesses. Output wrong.
- **D3 trust-without-verify**: AI says "done", human believes, ship breaks.
- **D4 shortcut**: skip S6 because "small change". 12 CRITICAL bugs ship.

## Real precedent (vinsai_AI + AIOT)

- **vinsai_AI sprint** (2026-03-31): user explicitly cited 4D framework in
  brainstorm message 5 of session `ee4f24ba`. Built daily-cycle commands
  (/morning + /meeting + /evening-review) following all 4 Ds.
- **AIOT v15.5 QA-R1..R7**: 7-round review caught 12 CRITICAL because
  every round was a fresh discrimination pass — never trusted prior round's
  "looks good".

## Multi-LLM cross-check extension

vinsai brainstorm note: user explicitly stated "引入其他的 LLM 來避免陷入
樂觀、幻覺" (use multiple LLMs to avoid optimism/hallucination bias).

Methodology equivalent: sub-agent dispatch is the cheapest version of
multi-LLM cross-check. Real multi-LLM (Codex + Gemini + Claude) is the
heavier version when stakes warrant.

S6 R3 (operator tooling) + R5 (persistence) particularly benefit from
multi-LLM cross-check because they hit attack-surface blind spots.

## Self-validate

- [ ] Did I delegate the right scope (not too much, not too little)?
- [ ] Did I describe with enough specificity that fresh session could repeat?
- [ ] Did I discriminate output before declaring done?
- [ ] Did I take the disciplined path even when shortcut existed?
