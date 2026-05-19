# Pattern: 12-Factor Agents

> Extracted from Dex Horthy's "12-Factor Agents" (2025). Production-grade
> LLM systems treated as deterministic software with embedded LLM steps,
> not prompt-and-loop autonomous agents.
>
> Source: `https://github.com/vins-hub/12-factor-agents-zh`

## Core thesis (verbatim Dex)

> "Production agents are **deterministic software with embedded LLM steps**,
> not prompt-and-loop systems."

The mental model:

```
Your deterministic business logic (95%)
  ↓
  └─ micro-agents (5-10 steps each)
      └─ LLM handles: interpretation, decision output, error recovery
```

Treat LLM as **a stateless, context-sensitive reducer function**, not an
autonomous agent.

## The 12 factors

### Atomic layers (Factors 1-4)

| # | Factor | Core principle |
|---|---|---|
| 1 | Natural language → tool calls | Translate NL intent to typed JSON, never execute NL directly |
| 2 | **Own your prompts** | Prompts are first-class code in git; never outsource to frameworks |
| 3 | **Own your context window** | Custom XML structures > standard message format (5x denser, attention-friendlier) |
| 4 | Tools are structured outputs | LLM outputs JSON; deterministic code interprets → executes |

### Program semantics (Factors 5-8)

| # | Factor | Core principle |
|---|---|---|
| 5 | Unify execution state | Tools, errors, results all merged into single thread |
| 6 | Launch / pause / resume | Threads serialize; can resume after operator wait |
| 7 | Contact humans with tools | Human-in-loop = first-class tool, not exception |
| 8 | **Own your control flow** | Your switch + for-loop = ability to inject any logic between LLM steps |

### Engineering rigor (Factors 9-12)

| # | Factor | Core principle |
|---|---|---|
| 9 | Compact errors | Error → 1-line summary → context, NOT 500-line stack trace |
| 10 | **Small focused agents** | Each agent ≤ 10 tools, ≤ 10 steps typical, ≤ 20 max |
| 11 | Trigger from anywhere | API / cron / Slack / webhook — same agent, different entry |
| 12 | **Stateless reducer** | `agent: Thread → Event`. State lives in thread, not agent. |

### Optimization (Factor 13)

| # | Factor | Core principle |
|---|---|---|
| 13 | Pre-fetch known context | If known at build-time, fetch ahead-of-call, save round-trip |

## The 4 most-critical factors for dev-meth integration

### Factor 2 — Own Your Prompts

**Why critical**: dev-meth ships prompts (`prompts/coordinator-prompt.md`,
`prompts/implementer-prompt.md`, etc.). These ARE the engineering interface
between dev-meth methodology and LLM execution. Owning them means:

- Versioned in git (every commit traceable)
- Testable via evals (correctness verifiable, not vibes)
- Iterate without framework release cycle
- Visible during debug (no "framework magic")
- Use advanced techniques (CoT, few-shot, structure-as-HTML)

**dev-meth integration**: `prompts/` directory is the embodiment of Factor 2.

### Factor 3 — Own Your Context Window

**Why critical**: Context engineering > prompt engineering. Same model + same
prompt can produce 2x quality delta based on context structure.

> "At any point, your input to an LLM in an agent is: 'here's what happened
> so far, what's the next step?'"

Custom XML-like structures (`<tool_result>`, `<error>`, `<event>`) beat
standard message format by:

- Higher token density per byte
- Better attention to nested structure
- Filter sensitive content per-tag
- Format flexibility as product evolves

**dev-meth integration**: 
- `docs/patterns/coordinator-parallel-handoff.md` uses `=== START === / === END ===`
  markers (custom structure)
- Sub-agent prompts use 6-section template (Context / Task / Inputs / Constraints / Output / Self-validate) — also Factor 3 alignment

### Factor 8 — Own Your Control Flow

**Why critical**: The switch + for-loop hijack determines what dev-meth
can do BETWEEN LLM steps:

- Conditional break (pause for operator input — Factor 7)
- Result processing (summarize tool output, cache responses)
- Validation layers (LLM-as-judge for structured output)
- Cross-cutting concerns (logging, rate limiting, tracing)
- Differentiated execution (sync `continue` vs async `break + approval`)

**dev-meth integration**: 
- `/A1` per-step sub-agent review = control flow ownership
- `/A2` 3h checkpoint = injected pause-resume
- S7 G7 9-gate `executor_live_flip.py` = differentiated execution per gate

### Factor 10 — Small Focused Agents

**Why critical**: Limits matter:

> "The bigger and more complex a task is, the more steps it will take,
> which means a longer context window. As context grows, LLMs are more
> likely to get lost or lose focus."

The dev-meth role architecture (IMPLEMENTER / COORDINATOR / REVIEWER) IS
Factor 10:

- Each role: ≤ 10 tools, single responsibility
- Median task completion: ≤ 10 steps
- Context stays within 50% of model limit
- Deterministic orchestrator (METHODOLOGY.md S1-S7) coordinates roles

### Factor 12 — Stateless Reducer

**Why critical**: This is the meta-pattern that synthesizes all 11 prior.

```
agent: Thread → Event

foldl(agent_reducer, empty_thread, [event₁, event₂, ...]) → final_thread
```

Properties:

- **Reproducibility**: same input → same output
- **Time-travel debug**: replay any thread state
- **Horizontal scale**: parallel threads, no shared state
- **Pausability**: serialize thread, resume cleanly
- **Auditability**: full event history

**dev-meth integration**:
- META issue body = "the thread" (state lives there)
- Every commit appends events (issue close, comment, sub-agent finding)
- Coordinator never holds in-session state; reads META → acts → updates META

### Haskell `foldl` analogy

```haskell
foldl :: (b -> a -> b) -> b -> [a] -> b
foldl agent_reducer empty_thread [event_1, event_2, ...] = final_thread
```

5 FP properties inherited by agents:

| Property | Meaning for agents |
|---|---|
| Pure | same input → same output (modulo LLM sampling) → reproducible, testable |
| Composable | two agent reducers chain into pipeline |
| Time-travelable | any thread snapshot can replay → debug superpower |
| Parallelizable | stateless → N workers, N threads, zero interference |
| Distributable | reducer can move between machines without state migration |

Dex's terminal critique of OpenAI Assistants API: putting state behind
a vendor server violates Factor 5 (unify state) AND Factor 12 (stateless
reducer) simultaneously — you lose audit, fork, replay, and vendor freedom.

## How the 12 factors map to dev-meth artifacts

| Factor | dev-meth artifact |
|---|---|
| 1 (NL→tool) | `commands/A1`-`commands/MP` translate natural-language ops into structured actions |
| **2 (Own prompts)** | **`prompts/` directory (6 templates, git-tracked)** |
| **3 (Own context)** | **Custom `=== START === / END ===` markers in coordinator-parallel-handoff** |
| 4 (Structured outputs) | Sub-agent findings: severity / file:line / impact / fix |
| 5 (Unify state) | META issue contains all sprint state |
| 6 (Pause/resume) | `docs/SESSION-CONTEXT.md` = serialized thread for compact-survival |
| 7 (Contact humans with tools) | §C operator critical path in coordinator-parallel-handoff |
| **8 (Own control flow)** | **`/A1` per-step gates, `/A2` 3h checkpoint, S7 9-gate flip** |
| 9 (Compact errors) | Anti-pattern AP-7 "trust me sub-agent reports" → verify-don't-recall |
| **10 (Small agents)** | **3 roles (IMPLEMENTER / COORDINATOR / REVIEWER), each ≤ 10 NEVER constraints, single scope** |
| 11 (Trigger anywhere) | Same `/A1` command works from new session, resume, post-compact, post-merge |
| **12 (Stateless reducer)** | **META + Project + commit chain = thread; agent is pure function over it** |

## Brief history of software (ch00 deep)

60 years of software was always **directed graphs (DAG)** of operations.
Agent's promise: let LLM decide edges at runtime. Reality: pure-loop agents
**hit a wall at ~10-20 turns** as context bloats and LLM "gets lost".

### Why pure-loop agents break

> "Even with longer context windows, you always get better results with
> shorter, focused prompts and context."

Practical resolution: **sprinkle micro-agents into a larger deterministic
DAG**. Each micro-agent stays ≤ 10 steps, LLM owns interpretation of
free-form human input within a well-scoped task.

### Minimum agent loop (4 steps)

```python
initial_event = {"message": "..."}
context = [initial_event]
while True:
  next_step = await llm.determine_next_step(context)
  context.append(next_step)
  if next_step.intent == "done":
    return next_step.final_answer
  result = await execute_step(next_step)
  context.append(result)
```

Each line maps to a factor:
- `initial_event` → Factor 11 (trigger from anywhere)
- `context = [...]` → Factor 3 (own your context)
- `llm.determine_next_step(...)` → Factor 1 + 4 (NL → structured outputs)
- `if next_step.intent == "done"` → Factor 8 (own your control flow)
- `context.append(result)` → Factor 5 + 9 (unify state + compact errors)

## Factor 1 deep: the first-token high-stakes choice

Every LLM call: the FIRST TOKEN decides natural-text vs structured JSON.
Once it commits, it's irreversible.

> "Forcing LLM to always output JSON—even 'I want to ask the human' as a
> `request_human_input` tool intent—gives you more control. You may not
> get a quality boost but you preserve your freedom to try weird stuff
> (reinforcing Factor 2 ownership)."

## Factor 5 deep: unify execution + business state

| Type | Examples |
|---|---|
| **Execution state** | current step, next step, retry count, waiting, timers |
| **Business state** | messages, tool calls, tool results, human responses |

Most agent frameworks separate these. **For agents, this is overkill** —
execution state is metadata derivable from business state:

```
current_step = thread.events[-1].type
waiting_on   = thread.events[-1].type == 'request_human_input'
retry_count  = count(events, type='error') for current action
```

7 benefits of unification: Simplicity / Serialization / Debug / Flexibility /
Recovery / Forking / Human Interface.

**Exception** — DON'T put in context: session IDs, API tokens, passwords,
internal user IDs, large blobs. Keep these as session-metadata with
reference IDs.

## Factor 6 deep: 4 verbs (Launch / Query / Pause / Resume)

Agents are programs. Programs need:

| Verb | Unix | Web service |
|---|---|---|
| Launch | `./myprog` | `POST /process` |
| Query | `ps`, `top` | `GET /process/:id` |
| Pause | `kill -STOP` | (hard) |
| Resume | `kill -CONT` | (hard — webhook + state restore) |

Most framework miss the last 3. **Key capability**: pause AT THE INSTANT
between "LLM picks tool" and "tool executes". This requires Factor 5 (state
serializable) + Factor 8 (control flow owned) + Factor 7 (human contact
via tool).

## Factor 7 deep: human as tool intent

Concrete shape:

```python
class RequestHumanInput:
  intent: "request_human_input"
  question: str
  context: str
  urgency: Literal["low", "medium", "high"]   # high → SMS, low → email
  format: Literal["free_text", "yes_no", "multiple_choice"]
  channel: Literal["slack", "email", "sms"]    # multi-channel
  choices: List[str]                            # for multiple_choice
```

Loop handles it:

```python
if next_step.intent == 'request_human_input':
  thread.events.append({'type': 'human_input_requested', 'data': next_step})
  thread_id = await save_state(thread)
  await notify_human(next_step, thread_id)
  return  # exit loop, await webhook
```

Webhook resumes:

```python
@app.post('/webhook')
def webhook(req: Request):
  thread_id = req.body.threadId
  thread = await load_state(thread_id)
  thread.events.push({'type': 'response_from_human', 'data': req.body})
  # continue agent loop
```

## Factor 8 deep: 3 control flow patterns

When you own `handle_next_step()`, each tool intent can have a DIFFERENT
execution strategy. Three canonical patterns:

| Intent | Mode | Behavior |
|---|---|---|
| `request_clarification` | **async / break** | LLM wants more info, break loop, await human webhook |
| `fetch_open_issues` | **sync / continue** | Tool returns immediately, feed result back to LLM, `continue` loop |
| `create_issue` | **async / break + approval** | High-stakes — break loop, request human approval, resume on `yes` |

This is the essence of Factor 8: **same LLM, same thread, different
tools each get their own execution strategy**. No framework can predict
your business's classification — only you can write it.

> "We need to be able to interrupt a running agent and resume later,
> ESPECIALLY between 'tool selection' and 'tool invocation'." — Dex

## Inner Loop vs Outer Loop (Factor 7 + 11 framework)

The framing that makes enterprise AI agents valuable:

| Mode | Who triggers | Who's "in charge" |
|---|---|---|
| **Inner Loop** | Human asks agent (ChatGPT mode) | Human |
| **Outer Loop** | Cron / event / webhook triggers agent | Agent (proactively contacts humans when needed) |

Outer-loop example (Humanlayer deploybot):

```
[Human] merges PR → main
  ↓
[Deterministic] deploys to staging, runs e2e tests
  ↓
[Agent] proposes `deploy_frontend_to_prod(SHA)`
  ↓
[Deterministic] requests human approval
  ↓
[Human] rejects: "deploy the backend first"
  ↓
[Agent] interprets human feedback → proposes `deploy_backend_to_prod`
  ↓
... (continues until done) ...
```

**LLM's only job**: interpret free-form human feedback ("can you deploy
the backend first?") into the next structured tool call. ALL execution
is deterministic. This is why micro-agents (5-10 step) work in
production while monolithic agents (50 tools, ∞ steps) don't.

## Factor 10 deep: edge-of-capability moat

NotebookLM team's observation (cited by Dex):

> "The most magical AI moments come when I'm really, really, really close
> to the edge of the model's capability."

**Operational implication**: find where the model JUST barely works on
a focused task, and ship agents at that edge. Once it slips outside,
split into two micro-agents.

> "Wherever the edge is, **consistently hitting it is the moat**."

This requires engineering discipline — not just "make agents bigger".

## Factor 9 deep: error self-healing

Key insight: agents differ from traditional retry because LLM **changes
strategy** after seeing error (vs blind retry waiting for transient error
to clear).

```python
try:
  result = await handle_next_step(thread, next_step)
  thread['events'].append({'type': next_step.intent + '_result', 'data': result})
  consecutive_errors = 0
except Exception as e:
  consecutive_errors += 1
  if consecutive_errors < 3:
    thread['events'].append({'type': 'error', 'data': format_error(e)})
    # loop and retry with LLM-different-strategy
  else:
    # escalate to human (Factor 7) or compress context for fresh start
    break
```

3 consecutive errors → escalate. Common threshold.

## Factor 11 deep: trigger from anywhere

Agent should not be bound to one UI. **Meet users where they are**:

| Direction | Channels |
|---|---|
| Trigger FROM | Slack / email / SMS / cron / webhook / GitHub event / another agent |
| Reply TO | same multi-channel |

Concrete endpoints:

```
POST /agents/start         ← dashboard
POST /webhook/slack        ← Slack
POST /webhook/email        ← SendGrid
POST /webhook/sms          ← Twilio
GET  /trigger/daily-9am    ← cron
```

Each endpoint: (1) parse source → unified `Event`, (2) build/load thread,
(3) push event into agent loop.

## Appendix 13: Pre-fetch known context

**Optimization layer on top of all 12 factors**.

Anti-pattern: let LLM decide `fetch_git_tags` every call.

```python
# Wasted LLM call — you ALREADY KNOW agent will need git_tags
next_step = await llm.determine_next_step("...")
# next_step.intent == 'list_git_tags'  (predictable!)
tags = await fetch_git_tags()
# Now LLM call AGAIN with tags in context...
next_step_2 = await llm.determine_next_step("...with tags...")
```

Fix: pre-fetch at orchestrator level, skip the first LLM call:

```python
git_tags = await fetch_git_tags()  # known dependency, fetch ahead
prompt = render_template(tags=git_tags, thread_events=thread.events)
next_step = await llm.determine_next_step(prompt)
```

**1 LLM call saved per agent invocation. Compound savings at scale.**

This is also why Factor 3 (own your context) is critical — pre-fetched
data goes in YOUR custom-shaped context, not framework's default
message-list.

## Anti-framework position (nuanced)

NOT anti-framework — anti-blind-trust:

- Use frameworks for POC validation (LangChain, LlamaIndex, etc.)
- Extract underlying principles for production
- Expect to rewrite ~95% when scaling

This mirrors Heroku's original 12-Factor App philosophy: framework =
velocity for POC; ownership = production-grade.

## dev-meth's anti-framework stance

dev-meth itself is framework-light by design:

- No npm install / no pip install required
- No build system (only markdown + 3 bash/python validators)
- Each project COPIES files in (Factor 2 ownership)
- Each project customizes via project CLAUDE.md (Factor 2 ownership)

This IS Factor 2 + Factor 10 applied to the methodology itself.

## The 4 architecture commitments dev-meth makes

By integrating 12-factor agents:

1. **Determinism > autonomy**: 95% of dev-meth flow is deterministic
   (stage gates, validators, CI checks). LLM sits in 5% (decisions inside stages).
2. **Pure-function reducer**: Every operation is `(repo_state, action) → repo_state'`. 
   No hidden in-session state.
3. **Tooling output structure-as-HTML**: where appropriate (see
   `docs/patterns/structure-as-html.md`).
4. **Quality compounds via ratchet**: each cycle adds tests + docs + evals
   (see `docs/patterns/complexity-ratchet.md`).

## Connection across the 3 patterns

```
12-Factor Agents (this) — engineering rigor of agent stack
       │
       ├─ Structure-as-HTML — presentation layer of agent outputs
       │  (Factor 3/4: own context + structured outputs)
       │
       └─ Complexity Ratchet — quality compounding of agent codebase
          (Factor 2/8/12: own prompts + control flow + stateless)
```

These 3 patterns reinforce each other. Apply together for production-grade
AI-augmented development.

## Self-validate

- [ ] All 12 factors mapped to specific dev-meth artifact (no hand-waving)
- [ ] 4 most-critical factors (2/3/8/10/12) explicitly cited in stages or commands
- [ ] Anti-framework stance acknowledged (not anti-framework, anti-blind-trust)
- [ ] Cross-references to structure-as-html and complexity-ratchet present
- [ ] No undefined acronym (all terms in `docs/GLOSSARY.md`)
- [ ] Real precedent (12-factor agents source on GitHub) cited
