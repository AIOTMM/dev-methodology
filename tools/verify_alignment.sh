#!/usr/bin/env bash
# verify_alignment.sh — cross-check methodology repo internal consistency
#
# Runs as PR gate. Exits 0 on clean, 1 on drift.
#
# Checks:
#   1. Every docs/stages/0[1-7]-*.md exists
#   2. Every command in commands/ has 7 required sections
#   3. Every pattern referenced in stages exists in docs/patterns/
#   4. METHODOLOGY.md links to existing stage files
#   5. README.md links to existing entry points

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FAIL=0

echo "=== Check 1: 7 stage files exist ==="
for n in 1 2 3 4 5 6 7; do
  pattern="docs/stages/0${n}-*.md"
  count=$(ls $pattern 2>/dev/null | wc -l)
  if [[ $count -eq 1 ]]; then
    echo "  ✓ $(ls $pattern)"
  else
    echo "  ✗ MISSING or DUPLICATE: $pattern (found $count)"
    FAIL=1
  fi
done

echo ""
echo "=== Check 2: commands have 7 required sections ==="
REQUIRED_SECTIONS=(
  "When to invoke"
  "When NOT to invoke"
  "Preconditions"
  "Execution"
  "NEVER constraints"
  "Resume protocol"
  "Acceptance"
)
for cmd in commands/[A-Z]*.md commands/sprint-*.md; do
  [[ -f "$cmd" ]] || continue
  # Skip index/readme files; only check actual commands
  [[ "$(basename "$cmd")" == "README.md" ]] && continue
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -q "$section" "$cmd"; then
      echo "  ✗ $cmd missing section: $section"
      FAIL=1
    fi
  done
done
echo "  ✓ command structure checked"

echo ""
echo "=== Check 3: stages reference existing patterns ==="
for stage in docs/stages/*.md; do
  grep -oE 'docs/patterns/[a-z0-9-]+\.md' "$stage" | sort -u | while read ref; do
    if [[ ! -f "$REPO_ROOT/$ref" ]]; then
      echo "  ✗ $stage references missing: $ref"
      FAIL=1
    fi
  done
done
echo "  ✓ pattern references checked"

echo ""
echo "=== Check 4: METHODOLOGY.md links resolve ==="
grep -oE '\[.*\]\(docs/[^)]+\)' METHODOLOGY.md | sed 's/.*(\(.*\))/\1/' | while read link; do
  if [[ ! -f "$REPO_ROOT/$link" ]]; then
    echo "  ✗ METHODOLOGY.md broken link: $link"
    FAIL=1
  fi
done
echo "  ✓ METHODOLOGY.md links checked"

echo ""
echo "=== Check 5: README.md entry points exist ==="
grep -oE 'docs/[^ )]+\.md' README.md | sort -u | while read path; do
  if [[ ! -f "$REPO_ROOT/$path" ]]; then
    echo "  ✗ README.md broken ref: $path"
    FAIL=1
  fi
done
echo "  ✓ README.md refs checked"

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "✅ All alignment checks PASSED"
  exit 0
else
  echo "❌ Alignment FAILED — fix drift above"
  exit 1
fi
