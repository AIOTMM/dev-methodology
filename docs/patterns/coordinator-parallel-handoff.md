# Pattern: Coordinator parallel handoff (1-to-N session prompt)

> Distinct from single-handoff template — this is the pattern for a SPEC-CO
> coordinator producing ONE document that contains synchronized prompts
> for 2+ parallel implementer sessions PLUS operator instructions.
>
> Real precedent: AIOT v15.5 Sprint-P `onward-work-coordinated-2026-05-19.md`
> (454 lines, 4 distinct sections, 3 active recipients).

## When to use

- Multi-session parallel work (≥2 implementer sessions) requiring synchronized launch
- Operator coordination needed alongside session coordination
- Cross-repo work where touchpoints between sessions must be explicit
- After a SPEC-CO arbitration that affects multiple sessions

## Document structure (required sections)

```
§0  Status snapshot — verified facts only, not narrative
§1  Critical path overview — ASCII flow diagram
§A  === START <SESSION-1> PROMPT === ... === END <SESSION-1> PROMPT ===
§B  === START <SESSION-2> PROMPT === ... === END <SESSION-2> PROMPT ===
§C  Operator critical path — what only the human can do
§D  Coordination touchpoints — when each session talks to others
§E  Self-validate — coordinator's own integrity check
```

Optional:
- §F References (bookmark URLs)
- §G What this handoff explicitly does NOT delegate

## §0 Status snapshot rules

Every row in §0 is a verified fact, not "should be":

```
| Asset | Value |
|---|---|
| <Session-1> HEAD | <hash + subject>           ← verify via git log -1
| <Session-1> tests | <count> PASS              ← verify via test run
| <Session-2> HEAD | <hash + subject>
| <Session-2> tests | <count> PASS
| Production daemons | <up/degraded/down>      ← verify via systemctl
| Shared META | <issue#> <last-update timestamp>
| Project board | <URL> <X items>
| Operator dependency | <pending action>
| Earliest milestone | <date> from <gate>
```

If you can't verify a row, don't put it in §0. Move to §E as a known unknown.

## §1 Critical path ASCII

Forces operator + AI to see who's blocked on whom:

```
        <Operator>            <Session-1>          <Session-2>
             │                     │                     │
             ▼ (BLOCKING)          ▼ (parallel)          ▼ (parallel)
        <action>             <task>                <task>
             │                     │                     │
             │                     ▼                     ▼
             │              <handoff trigger>       <handoff trigger>
             ▼                     │                     │
        <action>                   └─────merge───────────┘
             │                          ▼
             └──────────────────────────┴──→ <next phase>
```

3 columns is the sweet spot. ≥4 columns → consider splitting into 2 documents.

## §A / §B Session prompt block requirements

Each session prompt block:

```
=== START <SESSION-NAME> PROMPT ===

You are the <SESSION-NAME> session for <repo>. <HEAD>, <test count>,
<other verified state>. The <prior sprint> is complete; you are now in
onward parallel work while <other sessions> <do other things>.

## Your authorized work this session (priority order)

🎯 Priority 1 — <task> (~Xh)
  <step-by-step>
  <decision tree if branching>

🎯 Priority 2 — ...

## Acceptance for this session
- [ ] ...

## Constraints (NEVER violate)
1. NEVER <constraint> — <rationale>

## Coordination with <other-session>
- If you find X → notify Y via Z
- When Q closes → cross-link R

## Escalation paths
- If <bad-thing> → halt + post to META + ping operator

## Self-validate (before declaring session done)
- [ ] ...

=== END <SESSION-NAME> PROMPT ===
```

The `=== START/END ===` markers are MANDATORY so a fresh session can be
told "copy from === START === to === END === verbatim into this Claude tab".

## §C Operator critical path

Must explicitly list:
- What ONLY the human can do (non-delegable)
- Why (irreversibility / accountability / magic phrase)
- Concrete commands the operator types
- What unblocks downstream

Example:
```
Vins critical path:
1. Read <decision file>
2. Type <N answers> per spec template (NEVER AI-typed)
3. Generate baseline hash: `sha256sum <file>`
4. Push hash to verification location: `<command>`
5. GPG-sign commit: `git commit -S -m "..."`
6. Push: `git push origin main`
7. Notify both sessions on shared META
```

## §D Coordination touchpoints table

Specific, bounded, time-deterministic:

| Trigger | Who notifies | Where |
|---|---|---|
| Specific event X | <session> | <issue / META / channel> |
| Specific event Y | <session> | <issue / META / channel> |

NOT:
- "Post all updates everywhere"
- "Keep everyone in the loop"
- "Communicate regularly"

Each row ⇒ one specific event triggering one specific notification. Cap at
8 rows; if more, you're over-coordinating.

## §E Coordinator's own self-validate

Before publishing this handoff, coordinator answers:

- [ ] §0 every row verified (not from memory / not narrative)?
- [ ] §1 ASCII path has the operator BLOCKING column clear?
- [ ] §A and §B can run truly parallel (no implicit deadlock)?
- [ ] §C is operator-only (nothing AI could do)?
- [ ] §D ≤8 touchpoints, each specific event → specific notification?
- [ ] NEVER constraints repeated per session even if other knows?
- [ ] No "you remember" / "as discussed" language in §A or §B?
- [ ] Resume protocol included for each session?
- [ ] Word count per session block ≤ 400 lines (otherwise distill)?

## Anti-patterns

- **Implicit ordering**: §A talks about something §B should have done first,
  but never says so → silent deadlock
- **Status snapshot rot**: §0 written 8h before publish, no re-verify → ship stale facts
- **Single mega-prompt**: §A and §B combined into one block → fresh session paste-confusion
- **Vague Vins critical path**: "operator signs off" without specific file / format / verification
- **Coordination over-load**: §D lists 20 triggers → noise, not signal
- **No `=== START ===` markers**: copy-paste boundary unclear → fresh session reads coordinator's narration as instruction

## File location convention

```
/Users/<operator>/Documents/<workspace>/handoff/
  └── onward-work-coordinated-YYYY-MM-DD.md
```

Or in repo: `docs/handoff/<date>-<sprint>.md`. Per-project; pick one and
honor it across the sprint.

## Real precedent

AIOT v15.5 Sprint-P: `/Users/laijack/Documents/mm/handoff/onward-work-coordinated-2026-05-19.md`
- 454 lines
- 3 recipients (Strategies / OB-Dev / Operator)
- 4 sections (§0/§1/§A/§B/§C/§D/§E)
- 8 coordination touchpoints
- 0 cross-session conflicts over 3-day execution window

## Self-validate

- [ ] All 7 required sections present
- [ ] Status snapshot rows verified
- [ ] Critical path ASCII rendered
- [ ] Each session prompt block has `=== START === / END ===` markers
- [ ] Operator critical path is non-delegable items only
- [ ] Touchpoints table ≤ 8 rows, specific
- [ ] No "you remember" language
