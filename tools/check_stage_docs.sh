#!/usr/bin/env bash
# check_stage_docs.sh — every stage file has the required structure
#
# Required sections per stage:
#   - Goal
#   - Inputs
#   - Acceptance gate to next stage (or Acceptance)
#   - Anti-patterns
#   - Self-validate

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FAIL=0

REQUIRED=(
  "Goal"
  "(Inputs|Required outputs|inputs|Probe questions|Resource categories|Step-by-step|Required artifacts|TDD-first|7-round|9-gate|Required outputs)"
  "(Anti-patterns?|Forbidden behaviors|Constraints|NEVER)"
  "Self-validate"
)

for stage in docs/stages/0[1-7]-*.md; do
  echo "Checking $stage..."
  for section in "${REQUIRED[@]}"; do
    if ! grep -qE "$section" "$stage"; then
      echo "  ✗ Missing section matching: $section"
      FAIL=1
    fi
  done

  # File size check (warn if past soft limit)
  lines=$(wc -l < "$stage")
  if [[ $lines -gt 500 ]]; then
    echo "  ⚠️  $stage is $lines lines (>500 soft limit per CLAUDE.md bloat budgets)"
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo ""
  echo "✅ All stage docs structurally OK"
  exit 0
else
  echo ""
  echo "❌ Stage doc structure incomplete"
  exit 1
fi
