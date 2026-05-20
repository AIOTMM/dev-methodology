# PROJECT-BOOTSTRAP — dev-meth + superpowers hybrid workflow

> Canonical bootstrap prompt for a new Claude Code session. Paste the
> "Bootstrap prompt" section verbatim into the first message of any new
> dev session to activate the hybrid pipeline.
>
> Maintained at: `AIOTMM/dev-methodology/templates/PROJECT-BOOTSTRAP.md`
> Last reviewed: v1.3.2 (Karpathy + Garry + Dex integration)

---

## Why hybrid (dev-meth + superpowers)

Neither alone is sufficient:

| Concern | dev-meth alone | superpowers alone | hybrid |
|---|---|---|---|
| Strong STOP gates | weak (docs only) | strong (skill = enforced) | strong |
| TDD enforcement | recommended | enforced | enforced |
| 7-round adversarial review | strong (own pattern) | partial (codex) | strong |
| GitHub-issue thread anchor | yes (META template) | no (file-only) | yes |
| Domain context (12-factor / ratchet / HTML) | yes (3 patterns) | no | yes |
| Personal mental model | yes (S1-S7 stages) | no (gstack flavor) | yes |
| Real-world battle-test | low (new repo) | high (gstack community) | combined |

Hybrid pulls the **execution discipline** from superpowers and the
**thinking framework + domain wiring** from dev-meth.

---

## Bootstrap prompt (paste verbatim into new session)

```
本次開發採用 dev-meth + superpowers 混合工作流，全程嚴格遵守，禁止跳步。

## 主引擎：superpowers pipeline（強制 TDD + STOP gate）

1. 任何新 feature / refactor / 多檔修改 → 必先 invoke
   superpowers:brainstorming 探索需求 + 提 2-3 方案 + 寫 design spec 到
   docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md
2. Design 確認後 → invoke superpowers:writing-plans 寫實作計畫到
   docs/superpowers/plans/YYYY-MM-DD-<topic>.md
3. 執行 → invoke superpowers:subagent-driven-development（每 task 派新
   subagent + 兩段 review gate）；單檔 < 50 行純 bugfix 可用
   superpowers:executing-plans 直接做
4. 每個 task 必走 superpowers:test-driven-development（red → green → refactor）
5. 完成前 invoke superpowers:requesting-code-review；高風險變更追加
   codex 第二意見
6. Ship 階段 invoke ship → land-and-deploy → canary (gstack skills, no prefix)

## 流程包裝：dev-meth slash commands（如已安裝）

如果 ~/.claude/commands/ 內有以下命令（執行 install 腳本後）：
- /sprint-kickoff   ← 新 sprint 規劃，自動內含 superpowers 三輪 review
- /A1               ← 接續開發每一個 roadmap item（per-step review）
- /A2               ← autonomous 12h 自動開發
- /A3               ← human-loop dev（每階段等 operator gate）
- /MP               ← multi-project continuous

優先使用這些 slash command（它們已把 superpowers 串好）。沒裝就直接照上面
主引擎流程走。

## 思考框架：dev-meth patterns（補充思考層）

開工前讀以下 4 個檔案當 mental model（一次即可，不用每 task 重讀）：
- /Users/laijack/Documents/dev-methodology/docs/patterns/twelve-factor-agents.md
- /Users/laijack/Documents/dev-methodology/docs/patterns/complexity-ratchet.md
- /Users/laijack/Documents/dev-methodology/docs/patterns/structure-as-html.md
- /Users/laijack/Documents/dev-methodology/docs/patterns/adversarial-review-7-rounds.md

R7 ship audit 必用 7-round adversarial review pattern（不單跑 codex）。

## 狀態載體：GitHub Projects + Issues 完整工作流（anti-amnesia 主軸）

完整規範見：
**/Users/laijack/Documents/dev-methodology/docs/stages/04-ticket-creation.md**

新 sprint 開工必備 7 件套（順序不可顛倒）：

1. **GitHub Project (cross-repo board)** — `gh project create`，列 To-Do /
   In-Progress / Blocked / Done 四欄。多 repo sprint 必用 Project，單 repo 也建議。
2. **Milestones (≥2)** — 最少 PRE-LIVE gate + LIVE flip，視需要再加 post-LIVE 跟蹤。
3. **Labels** — 4 軸最少各 1 個：priority (p0/p1/p2/p3) · origin (sprint-<name>) ·
   type (spec/feat/fix/refactor/docs/test) · area (backend/frontend/infra/data 等)。
4. **META tracking issue** — 用 `.github/ISSUE_TEMPLATE/meta-tracking.yml`
   開，pinned。Body = sprint 唯一狀態源（Factor 5 統一狀態）。
5. **Per-work-unit issues** — 用 `task.yml` 模板，每張票 body 必含：Source /
   Risk / Acceptance / Effort / Owner / Blocked-by-Blocks / Cross-references。
6. **Spec issues** — 用 `spec.yml` 模板，spec docs 寫 `docs/superpowers/specs/`
   並在 spec issue body link 過去。
7. **Plan files** — `docs/superpowers/plans/<file>.md`，META 與相關 task issue
   都要 link 過去。

### PR + commit convention（dev-meth 也缺，bootstrap 一次補齊）

- Commit message 第一行：`<type>: <subject> (refs #N)` 或 `(closes #N)`。
  type ∈ `feat / fix / refactor / docs / test / chore / perf / ci`（符合
  conventional commits）。
- PR title：`<type>(<scope>): <subject>` — 例：`feat(auth): add OAuth2 PKCE flow`
- PR body 必含：
  - `## Summary` — 1-3 句
  - `## Related issues` — `Closes #N`（自動關 issue）/ `Refs #M`（單純引用）/
    `Blocks #K`（dependency 標示）
  - `## Test plan` — checklist
  - `## Risk` — 上線後最可能壞掉的點 + 偵測路徑
- 高風險 PR 額外標 label `risk-high` + 在 PR 內 `@mention` operator。
- merge 一律 `Squash and merge`，message 用 conventional 第一行。

### 跨 session / compact 接手流程（按順序）

```bash
# 1. 讀 META（the thread）
gh issue view <META_NUM> --json title,body,state -q .body | head -300

# 2. 讀 Project 看 In-Progress 狀態
gh project item-list <PROJ_NUM> --owner <OWNER> --limit 30

# 3. 讀最新 5 個 commit
git log --oneline -5

# 4. 讀對應 plan 檔
ls -t docs/superpowers/plans/ | head -3
cat docs/superpowers/plans/<latest>.md

# 5. 讀任何 in-progress 票的 sub-issue
gh issue view <N> --json body,comments
```

### Compact 前必做（絕不省略）

- 把 session 進展 append 到 META body 的 `## Event log` 區段
  （Factor 12: commit chain = event log；event log = 文字版的 commit chain）
- 在 META 標清楚 "next action when resumed: <action>"
- 把 design/plan 檔最後一次 commit 推上（不要留在本地）

### 跨 repo sprint

如果 sprint 跨 2+ repo（譬如 backend repo + infra repo），
讀 **/Users/laijack/Documents/dev-methodology/docs/patterns/dual-repo-sync.md**
+ **/Users/laijack/Documents/dev-methodology/docs/patterns/multi-session-coordination.md**。

### Sprint 收尾（S6 完成後）

- 寫 retro 到 `docs/sprints/<YYYY-MM-DD>-<sprint>-retro.md`（dev-meth
  `docs/lessons-learned/2026-05-19-sprint-P-QA-R1-R7.md` 是好範本）
- 更新 CHANGELOG.md（如有）
- 關 META issue（comment 寫 retro link + final HEAD）
- Archive Project（不要 delete）

## Domain context（已在記憶體，不用每次重貼）

- ~/.claude/CLAUDE.md（core philosophy + 8 條 hard rule）
- ~/.claude/rules/（coding-style / testing / security / data-reports /
  performance / agents / sprint-discipline / patterns / hooks）
- ~/.claude/projects/-Users-laijack-Documents-mm/memory/MEMORY.md
  （專案記憶總索引 + 20+ feedback rule）

## 硬性紀律（違反 = STOP）

- 禁止跳過 brainstorm 直接寫 code（單檔 < 50 行純 bugfix 除外）
- 禁止 sleep-poll（foreground+timeout 或 run_in_background+notify）
- 禁止 `--no-verify` git commit / `--no-gpg-sign` 規避
- 禁止偽稱跑了測試（沒跑就說沒跑，失敗就說失敗）
- 禁止 weasyprint 生 CJK PDF（用 pandoc + typst + PingFang SC）
- 禁止無授權安裝 macOS LaunchAgent（生產 cron 在 EC2，不在 Mac）
- 禁止猜星期幾（用 currentDate；trading 場景特別嚴格）
- 禁止 mock database 通過測試後上 prod（用 testcontainers 真 DB）

## 起手式

請先確認你理解以上流程，做兩件事：
(a) 列出本次開發前 3 個會執行的動作；
(b) 確認 ~/.claude/commands/ 是否已裝 dev-meth slash command
    （ls ~/.claude/commands/ | grep -E 'A1|A2|A3|sprint-kickoff' 看有沒有），
    沒裝就提醒我執行 install 腳本。

然後等我給專案描述再啟動 brainstorming。
```

---

## One-time install: dev-meth slash commands

To get `/sprint-kickoff /A1 /A2 /A3 /MP` working globally, run once:

```bash
# Symlink dev-meth commands into ~/.claude/commands/
DEVMETH=/Users/laijack/Documents/dev-methodology
TARGET=~/.claude/commands

mkdir -p "$TARGET"

# Safety: warn before overwriting non-symlink files
for cmd in sprint-kickoff A1-continue-dev A2-autonomous-12h A3-human-loop-dev MP-multi-project-continuous; do
  dest="$TARGET/$cmd.md"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "⚠️  $dest exists as a real file (not symlink). Skipping to avoid clobber."
    echo "    Backup or delete it manually, then re-run install."
    continue
  fi
  ln -sf "$DEVMETH/commands/$cmd.md" "$dest"
  echo "✓ Linked $cmd"
done

ls -l "$TARGET" | grep -E "A1|A2|A3|sprint-kickoff|MP"
```

Symlink (not copy) means dev-meth updates propagate automatically. **Caveat**: if you move `/Users/laijack/Documents/dev-methodology/` elsewhere, the symlinks break — re-run install pointing `DEVMETH` at the new path.

To **uninstall**:

```bash
rm ~/.claude/commands/{sprint-kickoff,A1-continue-dev,A2-autonomous-12h,A3-human-loop-dev,MP-multi-project-continuous}.md
```

---

## Per-project bootstrap: CLAUDE.md template

Optional — for each new project, drop this in the project root as `CLAUDE.md`:

```markdown
# Project: <name>

## Workflow
Uses dev-meth + superpowers hybrid bootstrap.
Refer: /Users/laijack/Documents/dev-methodology/templates/PROJECT-BOOTSTRAP.md

## Domain
- (project-specific stack / constraints / glossary)

## Overrides
(any project-specific rule that overrides dev-meth defaults)
```

This makes the bootstrap auto-loaded by Claude Code on every session in
this directory.

---

## Verifying the bootstrap is working

After pasting the bootstrap into a new session, expected behavior:

| Signal | Means |
|---|---|
| Claude lists 3 next actions WITHOUT writing code | ✅ STOP gate active |
| Claude asks clarifying question before scaffolding | ✅ brainstorming will be invoked |
| Claude refuses to commit without test | ✅ TDD enforced |
| Claude refuses to run sleep-poll | ✅ hard rule active |
| Claude proactively reads META issue on resume | ✅ GitHub anchor active |

Red flags (bootstrap NOT working):

| Signal | Means |
|---|---|
| Claude starts writing code immediately | ❌ brainstorming skipped |
| Claude says "I'll test it manually later" | ❌ TDD bypass |
| Claude uses `sleep 60 && check_status` | ❌ rule ignored |
| Claude commits with `--no-verify` | ❌ rule ignored |

If any red flag → STOP, re-paste bootstrap, ask Claude to acknowledge each
hard rule explicitly.

---

## Why this works (Factor mapping)

```
Bootstrap activates ↓
  ├── superpowers skills      → Factor 8 (own control flow with STOP gates)
  │                            → Factor 9 (compact errors via review gates)
  ├── dev-meth /A1 /A2 /A3   → Factor 8 + Factor 10 (small focused agents)
  ├── 3 thinking patterns    → Factor 2 (own prompts) + Factor 3 (own context)
  ├── GitHub META issue      → Factor 5 (unify state) + Factor 12 (reducer)
  ├── design/plan files      → Factor 6 (pause/resume) — survive compaction
  └── hard rules              → Factor 9 (compact errors) — recurring rule violations
                                 forced into compact form, not stack traces
```

Every piece earns its place in the bootstrap by mapping to at least one
12-factor principle. Nothing here is decoration.

---

## Self-validate

- [ ] Every referenced skill exists (`superpowers:brainstorming` etc.)
- [ ] Every referenced dev-meth command file exists in `commands/`
- [ ] Every referenced pattern file exists in `docs/patterns/`
- [ ] Every referenced issue template exists in `.github/ISSUE_TEMPLATE/`
- [ ] No project-specific (AIOT trading / 9Fi / etc.) leakage — bootstrap is portable
- [ ] No secret values, no private paths beyond `/Users/laijack/Documents/dev-methodology/`
- [ ] Hard rules match `~/.claude/CLAUDE.md` (no drift)
- [ ] Install + uninstall instructions both present (reversible)
