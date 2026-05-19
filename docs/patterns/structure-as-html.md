# Pattern: Structure-as-HTML output

> Extracted from Andrej Karpathy's "structure-your-response-as-HTML" tweet
> (mid-2025). Companion to `examples/sprint-P-walkthrough.md` style
> reports. Adopted into dev-meth as the recommended **report-tier output
> format** for substantive analyses, retros, and shareable reviews.
>
> Source: `https://github.com/vins-hub/karpathy-structure-as-html-zh`

## Core insight

Human-AI I/O is asymmetric:
- Humans prefer **audio input** to AI (efficient encoding)
- Humans prefer **visual output** from AI (~⅓ of brain processes vision)

Markdown is a partial answer. **HTML is the current-feasible answer.** Future
is neural-video, but HTML is the leap available now.

## Output evolution ladder

```
raw text → markdown → HTML → interactive neural simulations
                       ↑
                  We are here
```

## When to use HTML (instead of markdown)

Use HTML if EITHER condition holds:
- Output will be re-read or shared (not single-use)
- Output has structure (sections / tables / comparisons / phases)

## 7 high-ROI use cases (Karpathy + dev-meth precedent)

| Use case | Why HTML wins |
|---|---|
| Planning docs | folding for phases, sticky TOC for navigation |
| Analysis reports | summary-first, details collapsed, color-coded risk |
| Knowledge bases | searchable, anchor-linked, repeatable reference |
| Data dashboards | metric cards, charts, filterable tables |
| Tutorials | progressive disclosure, copyable code, hidden advanced sections |
| Cheat sheets | dense grid layout, color-aided scanning, print-optimized |
| Code reviews | severity tiering, code highlighting, side-by-side suggestions |

## When NOT to use HTML

- Short response (< 200 words) → plain text
- Real-time conversation turn → plain text
- Pure Q&A or list response → markdown sufficient
- Output rendered inside chat UI → markdown sufficient (chat strips CSS)

## 4-level prompt refinement

### Level 1 — Minimal

```
Format your entire response as a complete HTML document.
```

Functional but inconsistent.

### Level 2 — Style baseline

```
Format your entire response as a complete HTML document.
Style constraints:
  - system font stack
  - max-width 800px, centered
  - line-height 1.6, comfortable reading
  - dark-mode auto via @media (prefers-color-scheme: dark)
  - code blocks with monospace + subtle background
  - DO NOT wrap output in markdown code fences
```

Mid-to-high quality, documentation-grade.

### Level 3 — Structural

```
... [Level 2 additions]
Required structure:
  - <h1> + 1-line conclusion at top
  - <details><summary> for any section over 5 lines (collapsed by default)
  - <table> for comparisons (≥2 rows)
  - Color code (semantic): red = critical, yellow = warning, green = ok
  - Pre-conclusion: "Key takeaways" box (3-5 bullet)
```

Production-grade.

### Level 4 — Interactive

```
... [Level 3 additions]
Required interactivity:
  - Sticky TOC sidebar with scroll-detection active highlight
  - Search input filtering visible tables
  - Copy button on every code block
  - Anchor links on every heading
```

Mini single-page app.

## Anti-patterns (Karpathy chapter 05)

1. **Wrap brief answer in HTML** — < 200 chars + no structure = pure waste
2. **Render HTML inside chat UI** — save as file, open in browser
3. **Omit `<style>` block** — HTML without styling is worse than markdown
4. **Mask thin content with design** — substance first, presentation second
5. **Full regeneration during iteration** — preserve existing, request targeted patches
6. **Embed hidden metadata** — HTML is end-user; use JSON for inter-LLM workflows
7. **Depend on external CDNs** — inline SVG + inline CSS = self-contained file
8. **Build complex SPAs in HTML output** — switch to React/Vue at that threshold

## How HTML mode reveals LLM priority judgments

A key Karpathy insight: HTML output forces the LLM to make priority calls:
- What goes in the conclusion box (most important)
- What collapses into `<details>` (secondary)
- What gets color-coded red (urgent)
- What's sticky vs scrollable (always-accessible vs reference)

→ HTML output is **higher-fidelity than markdown** because it forces structural commitment.

## Integration with dev-meth stages

| Stage | When to apply HTML output |
|---|---|
| S1 Spec | spec docs stay in `.md` (git diff-friendly), generate `.html` for stakeholder review |
| S2 Resource confirmation | smoke-test report → HTML if shared cross-team |
| S3 Brainstorm | decision matrix → HTML table with operator-rationale-typed |
| S4 Tickets | META issue body uses markdown (GitHub renders); HTML for offline mirror |
| S5 Develop | code commits markdown; per-PR review → HTML for non-engineer reviewers |
| **S6 Review** | **R7 ship audit report → HTML strongly recommended** (severity-tiered, sticky TOC) |
| **S7 Deploy** | **Deploy-day status dashboard → HTML required** (canary metrics, live alerts) |

## Real precedent (AIOT)

AIOT v15.5 + Sprint-P used HTML output for:
- /aiot-analysis daily reports (dark-mode, sticky TOC)
- MM Daily Report dashboards (severity-color metric cards)
- Sprint-P Stage-7 review reports (collapsed details, comparison tables)

Result: operator review time dropped ~60% vs equivalent markdown-only.

## Operator-side automation snippet

For repeated reports, save Level 2-3 prompt as Raycast snippet OR build
SDK wrapper:

```python
def html_report(prompt_body: str, level: int = 3) -> str:
    """Wrap prompt body with HTML formatting instructions and strip
    markdown code-fence wrappers from response."""
    template = HTML_LEVEL_PROMPTS[level]
    msg = anthropic.messages.create(...)
    html = msg.content[0].text.strip()
    return html.removeprefix("```html").removesuffix("```")
```

## Connection to Complexity Ratchet

HTML output IS the natural home for the ratchet's eval-record artifact
(see `docs/patterns/complexity-ratchet.md`):

- Mutation scores → HTML table with severity-color cells
- Coverage trend → HTML chart (inline SVG, no CDN)
- Per-cycle test+doc+eval audit → HTML report with collapsed `<details>`

This makes HTML output the **evidence layer of the ratchet**.

## Connection to 12-Factor Agents

Karpathy's chapter 07 explicitly maps HTML output to Dex Horthy's
12-factor framework:

- **Factor 2 (Own Your Prompts)**: HTML templates are first-class prompt assets, not framework-hidden
- **Factor 3/4 (Own Context / Structured Outputs)**: HTML is the "presentation layer" of structured output
- **Factor 10 (Small Focused Agents)**: dedicated report-agent / dashboard-agent generates HTML; not monolithic

This makes HTML output the natural **presentation layer for 12-factor
agent stacks** (see `docs/patterns/twelve-factor-agents.md`).

## Self-validate

- [ ] HTML decision matches "shared OR structured" rule (not auto-HTML everything)
- [ ] Level 2 minimum: style + dark mode + max-width + DO-NOT-fence
- [ ] No external CDN required (self-contained)
- [ ] No content masked by design (substance precedes presentation)
- [ ] Iteration patches existing HTML, no full regen
