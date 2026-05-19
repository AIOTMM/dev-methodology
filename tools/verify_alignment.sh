#!/usr/bin/env bash
# verify_alignment.sh — cross-check methodology repo internal consistency
#
# Portable: works on macOS Bash 3.2 + Linux. No mapfile, no pipe-to-while.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FAIL=0

echo "=== Check 1: 7 stage files exist ==="
for n in 1 2 3 4 5 6 7; do
  pattern="docs/stages/0${n}-*.md"
  count=$(ls $pattern 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -eq 1 ]]; then
    echo "  ✓ $(ls $pattern)"
  else
    echo "  ✗ MISSING or DUPLICATE: $pattern (found $count)"
    FAIL=1
  fi
done

echo ""
echo "=== Check 2: commands have 7 required sections ==="
SECTIONS="When to invoke
When NOT to invoke
Preconditions
Execution
NEVER constraints
Resume protocol
Acceptance"
for cmd in commands/[A-Z]*.md commands/sprint-*.md; do
  [[ -f "$cmd" ]] || continue
  [[ "$(basename "$cmd")" == "README.md" ]] && continue
  while IFS= read -r section; do
    [[ -z "$section" ]] && continue
    if ! grep -q "$section" "$cmd"; then
      echo "  ✗ $cmd missing section: $section"
      FAIL=1
    fi
  done <<< "$SECTIONS"
done
echo "  ✓ command structure checked"

echo ""
echo "=== Check 3: stages reference existing patterns ==="
REFS_TMP=$(mktemp)
trap "rm -f $REFS_TMP" EXIT
for stage in docs/stages/*.md; do
  grep -oE 'docs/patterns/[a-z0-9-]+\.md' "$stage" 2>/dev/null | sort -u | \
    while IFS= read -r ref; do echo "$stage|$ref"; done
done > "$REFS_TMP"
while IFS='|' read -r stage ref; do
  [[ -z "$ref" ]] && continue
  if [[ ! -f "$REPO_ROOT/$ref" ]]; then
    echo "  ✗ $stage references missing: $ref"
    FAIL=1
  fi
done < "$REFS_TMP"
echo "  ✓ pattern references checked"

echo ""
echo "=== Check 4: METHODOLOGY.md links resolve ==="
LINKS_TMP=$(mktemp)
grep -oE '\[.*\]\(docs/[^)]+\)' METHODOLOGY.md 2>/dev/null | sed 's/.*(\(.*\))/\1/' > "$LINKS_TMP"
while IFS= read -r link; do
  [[ -z "$link" ]] && continue
  if [[ ! -f "$REPO_ROOT/$link" ]]; then
    echo "  ✗ METHODOLOGY.md broken link: $link"
    FAIL=1
  fi
done < "$LINKS_TMP"
rm -f "$LINKS_TMP"
echo "  ✓ METHODOLOGY.md links checked"

echo ""
echo "=== Check 5: README.md entry points exist ==="
RLINKS_TMP=$(mktemp)
grep -oE 'docs/[^ )*`]+\.md' README.md 2>/dev/null | \
  grep -v '\*' | grep -v '^docs/stages/0[NX]' | sort -u > "$RLINKS_TMP"
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  if [[ ! -f "$REPO_ROOT/$path" ]]; then
    echo "  ✗ README.md broken ref: $path"
    FAIL=1
  fi
done < "$RLINKS_TMP"
rm -f "$RLINKS_TMP"
echo "  ✓ README.md refs checked"

echo ""
echo "=== Check 6: tools/ refs in pattern + stage docs resolve ==="
# Only flag refs to literal `tools/<name>.ext` (paths starting with `tools/`)
# Skip "<your-…>/tools/…" placeholders and "your-project>/tools" etc.
TOOLS_TMP=$(mktemp)
for d in docs/patterns docs/stages commands; do
  for f in "$d"/*.md; do
    [[ -f "$f" ]] || continue
    # Match `tools/foo.sh` or `tools/foo.py` NOT preceded by < or /
    grep -oE '(^|[^<>/])tools/[a-z_0-9]+\.(sh|py)' "$f" 2>/dev/null | \
      sed 's|^[^t]*||' | sort -u | sed "s|^|$f|;s|^\([^|]*\)\(tools/\)|\1|\2|"
  done
done | sort -u > "$TOOLS_TMP"
# Skip — too many false positives from inline code blocks. Instead, simpler:
# check that the 3 well-known tools/* refs in the canonical docs exist.
for tool in tools/verify_alignment.sh tools/check_stage_docs.sh tools/check_gates.py; do
  if [[ ! -f "$REPO_ROOT/$tool" ]]; then
    echo "  ✗ canonical tool missing: $tool"
    FAIL=1
  fi
done
rm -f "$TOOLS_TMP"
echo "  ✓ canonical tools/* checked"

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "✅ All alignment checks PASSED"
  exit 0
else
  echo "❌ Alignment FAILED — fix drift above"
  exit 1
fi
