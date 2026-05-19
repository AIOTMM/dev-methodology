# <sprint> dev & deploy checklist

## Pre-development gates

- [ ] Spec committed
- [ ] S2 resource confirmation done
- [ ] S3 decision logged
- [ ] META issue pinned
- [ ] Project board populated

## Development sequence

(Filled per priority order)

## Per-ticket review gates

- [ ] Sub-agent review (S6 R1 per ticket)
- [ ] Self-validate

## Pre-deploy gates (S7)

- [ ] G1 rc-tag
- [ ] G2 Stage-0 sanity
- [ ] G3 operator sign-off
- [ ] G4 calibration
- [ ] G5 soak SOAK-COMPLETE
- [ ] G6 paper-week green
- [ ] G7 flip-script dual-path auth

## Post-deploy monitoring

- [ ] G8 sequential LIVE flip
- [ ] G9 24h post-flip green

## Retro trigger

- [ ] At sprint close: write docs/sprints/YYYY-MM-DD-<sprint>-retro.md
