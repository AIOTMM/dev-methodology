# Stage 2 — Resource Confirmation

> **Goal**: Confirm every input the spec assumes is actually available.
> **Anti-goal**: "Trust the docs" — assume resources work without smoke test.

## Inputs (from S1)

- Spec document with "Dependencies" section
- List of external services / APIs / cloud accounts the spec mentions
- Operator-availability window for sign-offs

## Required outputs

- Resource confirmation appendix in spec doc, OR separate
  `docs/specs/<spec>-resources.md`
- Pass/fail per resource category (see below)
- Any FAIL → escalated to risk register or fix-before-S3

## Why this exists

The most common failure mode in production sprints is starting S5 (develop)
on assumptions that turn out wrong:

- "EC2 should be reachable" → SSH keychain stale, 30 min lost
- "API keys exist in .env" → key rotated, IP whitelist broken
- "Test fixtures are there" → fixture file missing, blocks TDD
- "DB schema is v2" → schema_version=1, migration not run
- "Container has the tool" → binary not in PATH inside docker

S2 surfaces ALL of these in 15-60 minutes BEFORE you write any code.

## Resource categories

### 1. Repo / git access

```bash
# Smoke each repo the spec mentions:
for r in $REPOS; do
  cd "$r"
  git status --short                    # working tree state
  git fetch origin --quiet               # auth works?
  git log -1 --format='%h %s'            # HEAD reachable
done
```

### 2. Cloud / EC2 access

```bash
# Verify SSH actually works (not "should"):
ssh -o ConnectTimeout=5 your-host 'echo "alive @ $(date)"'

# Verify long-running daemons:
ssh your-host 'systemctl is-active your-daemon.service'

# Verify container layer:
ssh your-host 'docker ps --format "{{.Names}}\t{{.Status}}"'
```

### 3. Secrets / API keys

```bash
# Read env on remote (NEVER cat secrets locally — leaks to terminal scrollback):
ssh your-host 'grep -c "^[A-Z_]*=." /home/.../env | echo "$(cat) keys loaded"'

# Smoke API auth (without revealing the secret):
ssh your-host 'python3 -c "
import os, urllib.request, hmac, hashlib, urllib.parse, time
# ... signed request to /fapi/v2/account ..."'

# For each key, expect: 200 OK = healthy, 401 = rotate, 5xx = degraded
```

### 4. Database / persistence

```bash
# Schema version
sqlite3 prod.db "SELECT value FROM schema_version WHERE key='version'"

# Recent activity (heartbeat exists?)
sqlite3 prod.db "SELECT count(*) FROM logs WHERE ts > strftime('%s','now','-1 hour')"

# Disk headroom
df -h | grep -E "(/$|/data|/var)"
```

### 5. Test fixtures / data

```bash
# Each fixture file listed in spec:
for f in $FIXTURES; do
  [ -f "$f" ] || echo "MISSING: $f"
done

# Synthetic data generation tools work?
python3 tools/generate_test_fixtures.py --dry-run
```

### 6. Operator availability + state

For decisions requiring human-in-the-loop sign-off:

- Confirm operator (named individual) reachable during sprint window
- Confirm magic-phrase / decision file location
- Confirm comm channel for escalation (Telegram / Slack / email)

**Operator energy state** (vinsai_AI sprint precedent — see
`docs/patterns/priority-scoring.md`):

- Self-report or biometric (WHOOP `recovery_pct` ≥67% = GREEN /
  34-66% = YELLOW / <34% = RED)
- Match high-cognitive sprint work (S5 multi-system, S6 review) to
  GREEN-zone hours
- RED-zone hours: limit to S2 / S4 mechanical work or rest

Resource availability includes operator state. Spec assuming
"operator does 8h focused work" must check operator can actually
deliver 8h, not just be reachable.

### 7. CPU / RAM / Network headroom

```bash
# CPU
uptime  # load avg should be < num_cores
# RAM
free -h  # available > 20% of total
# Network (if doing API-heavy work):
curl -s https://your-api/healthz -o /dev/null -w "%{http_code} %{time_total}\n"
```

## Acceptance gate to S3

- [ ] Every line in the spec's "Dependencies" section smoke-tested live
- [ ] All findings logged in spec's "Resource confirmation" appendix
- [ ] Any FAIL → either fix immediately OR add to risk register + adjust scope
- [ ] No "should work" / "probably fine" allowed — pass/fail only

## Time budget

| Project size | S2 effort |
|---|---|
| Single repo, no cloud | 15 min |
| Multi-repo, single cloud | 30-60 min |
| Multi-repo + cloud + DB + API keys | 1-2 hours |
| Multi-region / multi-account | 2-4 hours |

## Anti-patterns

- **Assume by analogy**: "the other strategy worked → this one will too"
- **Skip when tired**: "I'll fix the API key when I hit it" → lost hours
- **Hide failed smoke test**: report it explicitly, even if it's ugly
- **Confirm only what spec mentions**: also check adjacent surfaces (e.g.
  spec mentions API X, also smoke API Y on same key)

## Real precedent

From AIOT v15.5 Sprint P, the `BINANCE_API_KEY_VINS2` IP whitelist
expiration was caught during S2 via `qp_v2.py` smoke test, NOT mid-S5.
This saved an estimated 4-6h of debugging during deploy week.

See [`docs/lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md`](../lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md) §S2.

## Self-validate

- [ ] Every spec-assumption tested (not just the obvious ones)
- [ ] Findings recorded WHERE the future engineer will look
- [ ] Failed smoke tests escalated, not buried
- [ ] Adjacent surfaces also checked
