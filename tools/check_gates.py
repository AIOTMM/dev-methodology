#!/usr/bin/env python3
"""check_gates.py — verify S7 gate progression for a sprint.

Reads sprint META issue, parses gate state, reports next eligible action.

Usage:
    python3 tools/check_gates.py --repo OWNER/REPO --meta <META_ISSUE_NUMBER>
"""
import argparse
import json
import re
import subprocess
import sys
from typing import Dict, List


GATES = [
    ("G1", "rc-tag"),
    ("G2", "Stage-0 sanity"),
    ("G3", "operator decisions signed"),
    ("G4", "calibration ±tolerance"),
    ("G5", "24h soak SOAK-COMPLETE"),
    ("G6", "paper-week green"),
    ("G7", "flip-script dual-path"),
    ("G8", "sequential LIVE flip"),
    ("G9", "post-flip 24h monitoring"),
]


def gh(cmd: List[str]) -> str:
    return subprocess.run(["gh"] + cmd, capture_output=True, text=True, check=True).stdout


def fetch_meta(repo: str, meta: int) -> Dict:
    raw = gh(["issue", "view", str(meta), "--repo", repo,
              "--json", "title,body,state,comments"])
    return json.loads(raw)


def parse_gates(body: str) -> Dict[str, bool]:
    """Find lines like '- [x] G1 ...' and return {gate: passed}."""
    state = {}
    for gate, _ in GATES:
        pattern = re.compile(rf"-\s*\[([ xX])\]\s*{gate}\b")
        match = pattern.search(body)
        if match:
            state[gate] = match.group(1) in ("x", "X")
        else:
            state[gate] = None  # not tracked yet
    return state


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--repo", required=True)
    p.add_argument("--meta", required=True, type=int)
    args = p.parse_args()

    meta = fetch_meta(args.repo, args.meta)
    state = parse_gates(meta["body"])

    print(f"# Gate state for {args.repo}#{args.meta}\n")
    next_gate = None
    for gate, label in GATES:
        passed = state.get(gate)
        if passed is True:
            icon = "✅"
        elif passed is False:
            icon = "⬜"
            if next_gate is None:
                next_gate = (gate, label)
        else:
            icon = "❓"
            if next_gate is None:
                next_gate = (gate, label)
        print(f"  {icon} {gate} — {label}")

    print()
    if next_gate:
        gate, label = next_gate
        print(f"Next action: open {gate} ({label}). See docs/stages/07-deploy-qa.md §{gate}.")
        return 1  # not all gates passed
    else:
        print("✅ All gates passed. Sprint LIVE-flip complete.")
        return 0


if __name__ == "__main__":
    sys.exit(main())
