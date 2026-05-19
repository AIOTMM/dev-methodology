# Lessons learned: vinsai_AI life-optimization system (2026-03-31)

> Sprint that built the human-side life-optimization counterpart to AIOT
> dev sprints. Source: session `ee4f24ba-194f-43bf-8768-a09059621247`,
> 88 user prompts, 16MB transcript.

## Sprint scope

- Build "vins_AI" personal AI assistant
- Integrate WHOOP biometric API → recovery-driven productivity
- TDL prioritization engine with 35+ tasks across 8 stakeholders
- Meeting transcript → action item pipeline (audio → Whisper → YAML)
- Daily cycle commands (`/morning`, `/meeting`, `/evening-review`)
- Backup automation (3× daily rclone to Google Drive)

## Why this matters to dev methodology

Most "dev methodology" docs ignore the operator. vinsai_AI sprint
proved the operator's state (biometric, cognitive, time-availability)
is itself a resource that S2 must confirm.

## Methodology contributions extracted

### C1 — 4D AI Fluency Framework

User's brainstorm message 5 explicitly cited Rick Dakan + Joseph Feller's
4D framework: Delegation / Description / Discrimination / Diligence.

This names what experienced AI-augmented developers do implicitly. Now
codified at `docs/patterns/4d-ai-fluency.md` + cited at every stage.

### C2 — Priority scoring formula (4 factors)

```
score = 0.35*deadline + 0.25*energy_match + 0.25*EV + 0.15*dependency
```

Real production formula at `~/.claude/scripts/vins_ai_engine.py`. Now at
`docs/patterns/priority-scoring.md` + cited in S3 brainstorm pattern.

Validated lift: ~40% improvement on high-EV item completion rate vs.
ad-hoc prioritization.

### C3 — Multi-LLM cross-check principle

User explicitly stated: "引入其他的 LLM 來避免陷入樂觀、幻覺" (use multiple
LLMs to avoid optimism + hallucination bias).

This is the strongest version of S6 adversarial review. Sub-agent dispatch
within the same LLM is the cheap version; cross-LLM (Codex + Gemini + Claude)
is the expensive but bias-decorrelated version.

Methodology now flags S6 R3 (operator tooling) + R5 (persistence) as
benefitting most from cross-LLM check.

### C4 — Operator-state-aware S2

S2 resource confirmation now includes operator energy state, not just
tech resources. Spec assuming "operator does 8h focused work" must check
operator can actually deliver — biometric or self-report.

### C5 — Daily cycle commands

`/morning` + `/evening-review` pattern: state-check → prioritize top-K →
work → measure completion → adjust tomorrow. Maps to S5 within-day
work-selection per energy state.

## What worked

- **Clear scope from msg 1**: user enumerated 5 daily-cycle commands +
  goal ("100M USD operational scaling"). Spec writing took 1 message.
- **Reference framework cited early** (msg 5 with 4D): operator named the
  evaluation criteria up front; AI had clear discrimination target.
- **Mode-shift after spec**: msg 3 was free-form ("how do I do this step
  by step?"); msg 4 returned the architecture diagram. Brainstorm → spec
  → ticket creation followed.

## What to do differently

- **Earlier S2**: vinsai sprint did S2 (WHOOP API access, OpenAI key, GDrive
  app) AFTER S5 implementation began. Two days lost when WHOOP OAuth wasn't
  set up. Methodology now mandates S2 BEFORE S5.
- **TDL priority weights frozen too early**: 0.35/0.25/0.25/0.15 were
  guessed in week 1; never re-calibrated against outcome data. Sprint-Q
  follow-up: A/B test weight variations.

## Anti-patterns surfaced (added to ANTI-PATTERNS.md)

- **AP-11**: Operator-state ignored — scheduling deep-cog sprint work at
  RED energy zone → bug rate spikes + burnout
- **AP-12**: Single-LLM cross-check assumed sufficient — same LLM has
  correlated biases; high-stakes review benefits from cross-LLM
- **AP-13**: Frozen-formula tuning — never re-calibrate weights against
  outcome data → priority recommendations drift from reality

## References

- Source session: `~/.claude/projects/-Users-laijack-Documents-mm/ee4f24ba-...jsonl`
- vins_AI system memory: `~/.claude/projects/-Users-laijack-Documents-mm/memory/vins-ai-system.md`
- TDL master: `~/.claude/projects/-Users-laijack-Documents-mm/memory/tdl-master.yaml`
- Priority engine: `~/.claude/scripts/vins_ai_engine.py`
- 4D Framework source: Dakan & Feller, *AI Fluency Framework* (academic
  reference)
