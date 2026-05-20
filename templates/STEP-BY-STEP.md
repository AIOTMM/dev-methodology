# STEP-BY-STEP — 從零開啟新 Claude Code session 到開始開發

> First-time walkthrough for dev-meth + superpowers hybrid pipeline.
> Companion to `PROJECT-BOOTSTRAP.md` (bootstrap content) and
> `QUICKSTART.md` (reference manual).
>
> Source: `AIOTMM/dev-methodology/templates/STEP-BY-STEP.md`

---

## Step 0 — 一次性安裝（只跑一次，永久生效）

打開 terminal，貼這段：

```bash
DEVMETH=/Users/laijack/Documents/dev-methodology
mkdir -p ~/.claude/commands
for cmd in sprint-kickoff A1-continue-dev A2-autonomous-12h A3-human-loop-dev MP-multi-project-continuous; do
  ln -sf "$DEVMETH/commands/$cmd.md" ~/.claude/commands/$cmd.md
done
ln -sf "$DEVMETH/templates/PROJECT-BOOTSTRAP.md" ~/.claude/PROJECT-BOOTSTRAP.md
ln -sf "$DEVMETH/templates/QUICKSTART.md" ~/.claude/QUICKSTART.md
ln -sf "$DEVMETH/templates/STEP-BY-STEP.md" ~/.claude/STEP-BY-STEP.md
echo "=== install done ==="
```

跑完看到 `install done` → Step 0 完成，跳到 Step 1。

---

## Step 1 — 開啟新 Claude Code session

在你想開發的目錄 `cd` 進去（如果是全新專案，先 `mkdir <project> && cd <project>`），然後打開新的 Claude Code session。

---

## Step 2 — 第一句貼這段啟動 prompt

```
請讀 ~/.claude/PROJECT-BOOTSTRAP.md 的「Bootstrap prompt」區塊並嚴格執行。

執行完三件事再停下等我：
1. 列出本次開發前 3 個會執行的動作
2. 確認 ~/.claude/commands/ 已裝 dev-meth slash command
3. 告訴我接下來需要我提供：(a) 專案描述 (b) 是否已存在 GitHub repo
   (c) sprint 範圍 — 然後等我回覆，不要自己開始
```

**等 Claude 回 3 件事的確認。不要急著給專案資訊。**

---

## Step 3 — 確認 Claude 沒跳步

Claude 應該回類似：

```
✅ 已讀 PROJECT-BOOTSTRAP.md
本次前 3 個動作：
  1. brainstorming
  2. writing-plans
  3. /sprint-kickoff
Dev-meth commands: ✅ /sprint-kickoff /A1 /A2 /A3 /MP
請提供：(a) 專案描述 (b) GitHub repo (c) sprint 範圍
```

**如果 Claude 沒停下、直接開始寫 code → 打斷它**：

> STOP，你跳過了 brainstorm gate，重來。

---

## Step 4 — 給專案資訊（第二句）

```
專案描述：<在做什麼、解決什麼問題、誰用、成功標準>
Stack：<語言 / 框架 / 部署目標>
GitHub repo：<已有的話貼 URL；要新開告訴我 owner+name>
Sprint 範圍：<PoC / MVP / production-ready / 哪幾個 feature>
```

---

## Step 5 — 走 Brainstorming（Claude 主導，你回答）

Claude 會 invoke `superpowers:brainstorming`，**一次問 1 題**，你逐題回答。
4-6 輪後它會寫 design spec 到 `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`。

讀完 spec → 你說：

```
spec OK，請 invoke writing-plans
```

---

## Step 6 — 走 Writing Plans

Claude invoke `superpowers:writing-plans`，產出
`docs/superpowers/plans/YYYY-MM-DD-<topic>.md`。讀完 plan → 你說：

```
plan OK，請執行 /sprint-kickoff
```

---

## Step 7 — Sprint Kickoff（建 GitHub 工作流）

Claude 跑 `/sprint-kickoff`，自動：

- 建 GitHub Project board
- 開 META tracking issue（用 dev-meth 模板）
- 開 milestones（PRE-LIVE / LIVE-flip 至少 2 個）
- 建 labels（priority / origin / type / area 四軸）
- 把 plan 拆成 task issues
- 把 spec / plan link 進 META body

跑完你會拿到 GitHub Project URL + META issue 號碼。

---

## Step 8 — 開始開發

```
/A1
```

Claude 接著走：讀 META → 挑下一張 P0/P1 票 → TDD（red → green → refactor）→
subagent review → commit（message 含 `Closes #N`）→ 下一張票。

**每張票結束會停下問你「繼續下一張嗎？」**

---

## Step 9 — 中途停 / 接手 / Ship

| 情境 | 命令 |
|---|---|
| 你要去吃飯 / 睡覺 | 「請更新 META event log 後 stop」 |
| 12hr autonomous（睡前用，謹慎） | `/A2` |
| 要逐階段 gate（高風險） | `/A3` |
| 開新 session 接手 | 回 Step 2 貼啟動 prompt（Claude 自動讀 META 接） |
| Sprint 完成要 ship | 「ship it」→ Claude 跑 `ship → land-and-deploy → canary` |
| 出現 compact 警告 | 「請更新 META 後 stop」（**絕不能跳過**） |

---

## 速記版（手機備忘錄存這 3 行就夠）

```
1. cd <project>
2. 貼："請讀 ~/.claude/PROJECT-BOOTSTRAP.md 的 Bootstrap prompt 區塊並嚴格執行..."
3. Claude 等你 → 給專案資訊 → brainstorm → plan → /sprint-kickoff → /A1
```

---

## 紅旗 / 綠旗（驗證 bootstrap 是否生效）

### 綠旗 ✅

| 信號 | 表示 |
|---|---|
| Claude 沒寫 code 就停下列 3 動作 | STOP gate 有效 |
| Claude 主動問澄清題（不是直接 scaffold） | brainstorming 會被 invoke |
| Claude 拒絕跳過寫 test 直接 commit | TDD 強制中 |
| Claude 拒絕 `sleep N && check` | hard rule 生效 |
| Claude resume 時主動讀 META issue | GitHub anchor 生效 |

### 紅旗 ❌

| 信號 | 表示 |
|---|---|
| Claude 立刻開始寫 code | brainstorming 被跳過 |
| 「我之後手動測就好」 | TDD 被繞過 |
| `sleep 60 && tail log` | hard rule 違反 |
| `git commit --no-verify` | hard rule 違反 |

任一紅旗 → STOP，重貼 bootstrap prompt，要求 Claude 逐條 acknowledge 硬性紀律。

---

## 三檔關係圖

```
~/.claude/STEP-BY-STEP.md     ← 本檔（first-time 走一遍）
       │
       ├─ ~/.claude/QUICKSTART.md     ← 反覆參考的 reference
       │       │
       │       └─ ~/.claude/PROJECT-BOOTSTRAP.md  ← 實際塞給 Claude 的內容
       │
       └─ ~/.claude/commands/{sprint-kickoff,A1,A2,A3,MP}.md
                                              ← Claude Code 內建 slash command
```

新人讀順序：本檔 → 跑一次 → 之後反覆看 QUICKSTART → 改規則改 BOOTSTRAP。

---

## 升級

```bash
cd /Users/laijack/Documents/dev-methodology && git pull
# pattern / bootstrap / quickstart / step-by-step / 命令都自動跟新（symlink）
```

---

## 卸載

```bash
rm ~/.claude/commands/{sprint-kickoff,A1-continue-dev,A2-autonomous-12h,A3-human-loop-dev,MP-multi-project-continuous}.md
rm ~/.claude/{PROJECT-BOOTSTRAP,QUICKSTART,STEP-BY-STEP}.md
```

Dev-meth repo 本體不動。
