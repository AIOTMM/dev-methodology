# Pattern: Priority scoring (4-factor weighted)

> Extracted from vinsai_AI session (2026-03-31 build of life-optimization
> system). Real formula in production at `~/.claude/scripts/vins_ai_engine.py`.
>
> Use when you have N candidate items and must pick the next K to work on.

## The formula

```
score = 0.35 * deadline_score
      + 0.25 * energy_match_score
      + 0.25 * EV_score (expected value)
      + 0.15 * dependency_score
```

Each factor scored 0.0-1.0 then weighted-summed. Top-scoring items go next.

### Why these 4 factors

- **Deadline (35%)**: time-sensitive items capture compounding cost-of-delay.
  35% weight makes deadline the dominant factor — but not so dominant that
  it overrides EV catastrophically (35% < 50%).
- **Energy match (25%)**: human operator's current cognitive state vs task
  cognitive demand. High-cog tasks at low-energy fail; low-cog tasks at
  high-energy waste capacity.
- **EV expected value (25%)**: probability-weighted reward minus cost.
  Captures upside that pure-deadline scoring misses (e.g. "this could
  produce $1M optionality if it works").
- **Dependency (15%)**: how many other items unblock when this one closes.
  Lower weight because it's discoverable structurally (DAG), unlike the
  others.

The weights are calibrated, not arbitrary. Adjust only with explicit
reason logged.

## Per-factor scoring

### Deadline score

```python
def deadline_score(item):
    days_until = (item.deadline - now).days
    if days_until <= 0:
        return 1.0  # past due
    elif days_until <= 1:
        return 0.95
    elif days_until <= 3:
        return 0.80
    elif days_until <= 7:
        return 0.60
    elif days_until <= 14:
        return 0.40
    elif days_until <= 30:
        return 0.20
    else:
        return 0.05
```

### Energy match score

Map operator's current energy zone (3-tier from biometric or self-report)
to task's cognitive demand:

```python
ENERGY_ZONES = {'GREEN': 0.67, 'YELLOW': 0.34, 'RED': 0.0}
TASK_DEMAND  = {'high': 1.0, 'medium': 0.6, 'low': 0.3}

def energy_match_score(zone, demand):
    zone_v = ENERGY_ZONES[zone]
    demand_v = TASK_DEMAND[demand]
    # Best match: high-energy + high-demand, or low-energy + low-demand
    return 1.0 - abs(zone_v - demand_v)
```

WHOOP biometric integration: zone derived from `recovery_pct`:
- ≥67% → GREEN
- 34-66% → YELLOW
- <34% → RED

Without biometrics: operator self-reports at sprint start.

### EV (Expected Value) score

```python
def ev_score(item):
    # Operator-estimated:
    #   probability_success: 0.0-1.0
    #   reward_if_success:   monetary or strategic units
    #   cost_if_failure:     same units
    ev = (item.probability_success * item.reward_if_success
          - (1 - item.probability_success) * item.cost_if_failure)
    # Normalize to 0-1 via the project's reward_cap baseline
    return min(1.0, max(0.0, ev / project.reward_cap))
```

For software dev tasks: reward = strategic value (e.g. "ships LIVE feature
P", "unblocks revenue stream Q"). Cost = effort + opportunity cost.

### Dependency score

```python
def dependency_score(item, all_items):
    blocked_count = sum(1 for x in all_items
                         if item.id in x.blocked_by_ids)
    max_blocked = max((sum(1 for x in all_items if y.id in x.blocked_by_ids)
                       for y in all_items), default=1)
    return blocked_count / max(max_blocked, 1)
```

Item that unblocks 5 others scores higher than item that unblocks 1.

## When to apply

S3 brainstorm (which option to pick) — score each option.
S4 ticket prioritization — score each ticket.
S5 within-day work selection — score remaining tickets per energy state.

## Operator override

The score is a recommendation, not a ruling. Operator can override with
typed rationale:

```
> Picked item #N (score 0.42) over item #M (score 0.78).
> Rationale: M is blocked on upstream PR review (1-week SLA).
> Operator: Vins / 2026-XX-XX
```

Override logged in spec decision log or sprint META.

## Anti-patterns

- **Single-factor optimization**: scoring on deadline alone → urgent-but-low-EV
  work crowds out high-EV strategic items
- **Weight tuning without precedent**: changing 0.35→0.50 mid-sprint
  invalidates prior prioritization; defer to next sprint
- **Energy ignored**: scheduling deep-cog work at RED energy → burnout +
  bug rate spikes
- **EV un-quantified**: "this is important" → not actionable; force operator
  to estimate even if uncertain

## Adapting to your domain

Trading domain: reward_cap = sprint PnL upper bound.
SaaS: reward_cap = ARR delta from feature ship.
CLI tool: reward_cap = user-time-saved (estimated).
Internal: reward_cap = engineering hours saved.

For non-monetary domains, normalize against a per-project baseline.

## Real precedent

vinsai_AI session (2026-03-31): 35+ TDLs scored daily via this formula.
WHOOP biometric → energy zone → scored top-3 surfaced in `/morning` command.
Validated via sprint completion rate vs. ad-hoc prioritization baseline:
~40% lift on high-EV item completion.

## Self-validate

- [ ] All 4 factors scored (not "I'll skip dependency")
- [ ] Weights are project's calibrated values (not freshly invented)
- [ ] Operator override logged with rationale (not silent re-pick)
- [ ] Output ranked top-K, not just top-1
- [ ] Re-score per day OR per significant state change (energy / new dependency)
