# Changelog

## v1.2.0 — 2026-05-19 (polish — broken refs + hygiene + 2nd walkthrough)

### Fixed (R5 deferred items)

- Broken tool refs replaced with project-substitution placeholders:
  - `tools/count_by_state.py` → inline python3 one-liner in MP command
  - `tools/generate_test_fixtures.py` → project-substitution placeholder
  - `tools/soak_monitor.sh` → marked as PROJECT-IMPLEMENTED with AIOT precedent
- Missing `docs/sessions/file-ownership.md` authored — defines per-file
  cross-session ownership protocol with anti-pattern + real precedent

### Added (R4 + hygiene)

- `examples/saas-walkthrough.md` — hypothetical SaaS auth migration showing
  same 7-stage methodology applied to non-trading domain
- `CHANGELOG.md` (this file) — per R7 N2
- `tools/README.md` — describes the 3 validators + expected exit codes

### Documented

- `docs/lessons-learned/2026-03-31-vinsai-AI-system-extraction.md` —
  v1.1 integration of vinsai_AI session methodology

## v1.1.0 — 2026-05-19 (vinsai integration)

### Added

- `docs/patterns/4d-ai-fluency.md` — Rick Dakan + Joseph Feller's framework
  for human-AI collaboration (Delegation / Description / Discrimination / Diligence),
  cited at every methodology stage
- `docs/patterns/priority-scoring.md` — 4-factor priority formula
  (0.35·deadline + 0.25·energy_match + 0.25·EV + 0.15·dependency) extracted
  from vinsai_AI `~/.claude/scripts/vins_ai_engine.py`
- Anti-patterns AP-11/AP-12/AP-13 added (operator state ignored,
  single-LLM check, frozen formula)
- vinsai_AI terms added to GLOSSARY (WHOOP / energy zone / TDL / EV / 4D)

### Changed

- S2 resource confirmation §6 now includes operator energy state
- S3 brainstorming Pattern 4 + Pattern 5 (priority scoring + 4D check)

## v1.0.0 — 2026-05-19 (initial public release)

### Repo extracted from AIOT v15.5 Sprint-P + QA-R1..R7 sprint

- 7-stage methodology (S1 Spec → S7 Deploy)
- 7-round adversarial review doctrine (R1-R7)
- 9-gate deploy waterfall (G1-G9)
- 5 polished commands (sprint-kickoff / A1 / A2 / A3 / MP)
- 6 skill manifests
- 5 prompt templates (kickoff / coordinator / implementer / reviewer / handoff / subagent)
- 3 portable validators (verify_alignment / check_stage_docs / check_gates)
- GitHub issue + PR templates
- LICENSE (MIT), CONTRIBUTING, PREREQUISITES, GLOSSARY, DOMAIN-TRANSLATION

### Validated through 7-round self-application

- 83 findings across 4 sub-agent rounds (R4 / R5 / R6 / R7)
- All R7 BLOCKERs closed
- All R4/R6 CRITICALs closed
- 4/6 R5 CRITICALs closed; remaining 2 deferred-with-rationale
