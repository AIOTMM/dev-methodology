# QUICKSTART — 啟動新 Claude Code session 開始開發

> Finalized session-start instructions for dev-meth + superpowers hybrid pipeline.
> Companion to `PROJECT-BOOTSTRAP.md` (the bootstrap content itself).
> Source: `AIOTMM/dev-methodology/templates/QUICKSTART.md`

---

## 一次性安裝（如果還沒做，先跑這個）

複製整段貼到 terminal：

```bash
DEVMETH=/Users/laijack/Documents/dev-methodology
TARGET=~/.claude/commands
mkdir -p "$TARGET"
for cmd in sprint-kickoff A1-continue-dev A2-autonomous-12h A3-human-loop-dev MP-multi-project-continuous; do
  dest="$TARGET/$cmd.md"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "skip $cmd"; continue
  fi
  ln -sf "$DEVMETH/commands/$cmd.md" "$dest"
done
ln -sf "$DEVMETH/templates/PROJECT-BOOTSTRAP.md" ~/.claude/PROJECT-BOOTSTRAP.md
echo "=== install done ==="
ls -l ~/.claude/commands/ | grep -E "A1|A2|A3|sprint-kickoff|MP"
ls -l ~/.claude/PROJECT-BOOTSTRAP.md
```

跑完看到 5 個 dev-meth command symlink + BOOTSTRAP symlink 就 OK。

---

## 新 Session 啟動 Prompt（複製整段貼第一句）

```
請讀 ~/.claude/PROJECT-BOOTSTRAP.md 的「Bootstrap prompt」區塊並嚴格執行。

執行完三件事再停下等我：
1. 列出本次開發前 3 個會執行的動作
2. 確認 ~/.claude/commands/ 已裝 dev-meth slash command
   （/sprint-kickoff /A1 /A2 /A3 /MP）
3. 告訴我接下來需要我提供：(a) 專案描述 (b) 是否已存在 GitHub repo
   (c) sprint 範圍 — 然後等我回覆，不要自己開始

專案資訊（我會在下一輪告訴你，先別動）：
- 專案名稱：
- Stack：
- 是否已有 repo：
- Sprint goal：
```

---

## 預期 Claude 的回應應該長這樣

```
✅ 已讀 PROJECT-BOOTSTRAP.md，理解 dev-meth + superpowers 混合工作流。

本次開發前 3 個動作：
1. 等你提供專案資訊後，invoke superpowers:brainstorming 探索需求
   + 提 2-3 方案 + 寫 design spec 到 docs/superpowers/specs/
2. Design 確認後 invoke superpowers:writing-plans 寫實作計畫
3. /sprint-kickoff 建 META issue + Project board + Milestones + Labels

Dev-meth slash command 安裝狀態：
- ✅ /sprint-kickoff
- ✅ /A1 (A1-continue-dev)
- ✅ /A2 (A2-autonomous-12h)
- ✅ /A3 (A3-human-loop-dev)
- ✅ /MP (MP-multi-project-continuous)

請提供：
(a) 專案描述（在做什麼、解決什麼問題）
(b) 是否已有 GitHub repo（給 URL 或我幫你開）
(c) Sprint 範圍（PoC / MVP / Production-ready / 哪幾個 feature）

等你回覆，不會自己開始。
```

**如果 Claude 沒先停下來等你 → 直接打斷它**：
> "STOP，你跳過了 brainstorm gate，重來"

---

## 之後的指令節奏

| 階段 | 你打的命令 | 預期動作 |
|---|---|---|
| 給專案資訊後 | 任由它走 brainstorming | Claude 問 1 題 / 你答 / 重複 4-6 輪 → design spec |
| spec 確認 | 「spec OK，請 write plan」 | 產 plan 檔到 `docs/superpowers/plans/` |
| plan 確認 | `/sprint-kickoff` | 建 GitHub Project + META issue + Milestones + Labels + 拆 ticket |
| 開始開發 | `/A1` | 接續每張票，per-step review + TDD |
| 長時間沒空看 | `/A2` | autonomous 12h（睡前用） |
| 重要決策節點要你 gate | `/A3` | 每階段停下等你 |
| ship 階段 | 跟 Claude 說「ship it」 | 走 `ship → land-and-deploy → canary` |
| compact 警告出現 | 「請更新 META event log 後 stop」 | 把進度寫進 META，安全 compact |
| 新 session 接手 | 上面的 start prompt 再貼一次 | Claude 讀 META + 5 commit + plan → 接手 |

---

## 路徑速查

| 用途 | 路徑 |
|---|---|
| Bootstrap 內文 | `~/.claude/PROJECT-BOOTSTRAP.md` |
| 本檔（快速啟動）| `~/.claude/QUICKSTART.md`（symlink）或 `/Users/laijack/Documents/dev-methodology/templates/QUICKSTART.md` |
| Dev-meth slash command | `~/.claude/commands/{sprint-kickoff,A1-...,A2-...,A3-...,MP-...}.md` |
| Dev-meth 主索引 | `/Users/laijack/Documents/dev-methodology/METHODOLOGY.md` |
| 3 大思考 pattern | `/Users/laijack/Documents/dev-methodology/docs/patterns/{twelve-factor-agents,complexity-ratchet,structure-as-html}.md` |
| 7-round review pattern | `/Users/laijack/Documents/dev-methodology/docs/patterns/adversarial-review-7-rounds.md` |
| GitHub workflow 規範 | `/Users/laijack/Documents/dev-methodology/docs/stages/04-ticket-creation.md` |
| Issue 模板 | `/Users/laijack/Documents/dev-methodology/.github/ISSUE_TEMPLATE/{meta-tracking,spec,task}.yml` |

---

## 升級 / 維護

```bash
# 拉最新版（pattern + bootstrap + 命令都會跟新，因為是 symlink）
cd /Users/laijack/Documents/dev-methodology && git pull

# 驗證安裝完整
ls -l ~/.claude/commands/ | grep -E "A1|A2|A3|sprint|MP"
ls -l ~/.claude/PROJECT-BOOTSTRAP.md ~/.claude/QUICKSTART.md
```

如果 symlink 顯示紅色（broken），表示 dev-meth 目錄被搬走 — 修正 `$DEVMETH` 後重跑安裝。

---

## 卸載

```bash
rm ~/.claude/commands/{sprint-kickoff,A1-continue-dev,A2-autonomous-12h,A3-human-loop-dev,MP-multi-project-continuous}.md
rm ~/.claude/PROJECT-BOOTSTRAP.md ~/.claude/QUICKSTART.md
```

Dev-meth repo 不動，只移除全域 symlink。
