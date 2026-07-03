# AI Berkshire — Project Guide

> One person + Claude Code = an investment-research team. This is the full
> reference for the framework, every skill, every tool, and how the Keiro MCP
> integration fits in.

This is the Keiro-enabled fork of [`xbtlin/ai-berkshire`](https://github.com/xbtlin/ai-berkshire). The investment framework is unchanged from upstream; only the web-research transport was swapped for the [Keiro MCP server](https://kierolabs.space/mcp/api). See [README.md](../README.md) for the quick start.

---

## 1. What this is

A collection of Claude Code skills (slash commands) that turn a single analyst into a four-agent research team. Each engagement can run four masters of value investing **in parallel** — Buffett (financials/valuation), Munger (industry/inversion), Duan Yongping (business model), Li Lu (long-term certainty & management) — then a Team Lead synthesizes a forced verdict: **Pass / Fail / Gray Zone**, with price bands and tiered advice.

The discipline it enforces:

- **Forced conclusions, no hedging.** No "on the one hand / on the other." Every core judgment ships with a counter-argument ("但另一方面…") so the reader weighs it themselves.
- **Fact vs opinion, separated.** Facts carry sources; opinions are labeled. "数据显示", not "我觉得".
- **Two-source cross-check.** Key numbers must come from ≥2 sources; estimates labeled as such.
- **Mirror test.** If you can't state the thesis in 5 sentences, you don't buy. No exceptions.

> Educational and research only. **Not investment advice.**

---

## 2. The four-master framework

| Master | Lens | What the agent owning this lens does |
|---|---|---|
| **Warren Buffett** | Financials & valuation | Reads the filings, computes owner-earnings / ROE / margin trends, checks the price against intrinsic value. Uses `tools/financial_rigor.py` for exact math. |
| **Charlie Munger** | Industry & inversion | Maps the value chain, lists the moat (and what would erase it), runs pre-mortem inversion: "what kills this in 5 years?" |
| **Duan Yongping (段永平)** | Business model | Asks "is this a good business?" — pricing power, customer lock-in, C2M/network effects, whether the model is copyable. "本分" check. |
| **Li Lu (李录)** | Long-term certainty & management | 10-year certainty, management culture & track record, capital allocation, alignment, fraud/risk surface. "买股票就是买人." |

These four produce **real tension**, not consensus. A company can score 4.4/5 on Buffett's financials and 2.0/5 on Li Lu's certainty — and that disagreement is the point. The Team Lead reconciles it into one verdict.

---

## 3. Skills (slash commands)

All skills live in `skills/*.md`. After `./install.sh` they are copied to `~/.claude/commands/` and invoked as `/skill-name`. Web research inside any skill routes through Keiro when the preflight has armed the agents.

### Core research

| Skill | Purpose |
|---|---|
| `/investment-team <ticker>` | The flagship. Four agents research in parallel; Team Lead writes the final Pass/Fail/Gray-Zone verdict with price bands. Output in `reports/{company}/`. |
| `/investment-research <ticker>` | Single-pass four-master synthesis, lighter than the team flow. File: `{company}-research-{YYYYMMDD}.md`. |
| `/investment-checklist <ticker>` | Buffett buy-side checklist — run before entering a position. `{company}-checklist-{YYYYMMDD}.md`. |
| `/quality-screen <ticker>` | 7-metric "remove the non-first-tier" screen. Fast reject pass. |
| `/private-company-research <name>` | Multi-agent deep dive on an unlisted company (e.g. ByteDance). `{company}-private-{YYYYMMDD}.md`. |

### Industry & screening

| Skill | Purpose |
|---|---|
| `/industry-research <industry>` | Value-chain panorama + four-master single-stock framework. Root-level `{industry}-industry-{YYYYMMDD}.md`. |
| `/industry-funnel <industry>` | Funnel from the whole market down to 3 names. Root-level `{industry}-funnel-{YYYYMMDD}.md`. |
| `/bottleneck-hunter` | Global supply-chain bottleneck arbitrage — find the choke point, find the incumbent. |

### Earnings & tracking

| Skill | Purpose |
|---|---|
| `/earnings-review <ticker> <period>` | First-source earnings deep read. `{company}-earnings-{period}.md`. |
| `/earnings-team <ticker> <period>` | Four-master parallel earnings read + WeChat article + reader review. |
| `/thesis-tracker <ticker>` | Long-maintained discipline system: the buy thesis, what would invalidate it, drift checks. `{company}-thesis.md`. |
| `/portfolio-review` | Portfolio management — from "research a company" to "run a book". Root-level `portfolio-latest.md`. |
| `/management-deep-dive <ticker>` | Management depth study ("buy the stock = buy the people"). `{company}-management-{YYYYMMDD}.md`. |

### Data & content

| Skill | Purpose |
|---|---|
| `/financial-data` | Financial-data fetch + cross-validation spec. |
| `/news-pulse <ticker>` | Price-move attribution. Four agents scout events / regulation / rivals / sentiment → event timeline + cause + thesis-recheck flag. |
| `/deep-company-series <ticker>` | 8 long-form articles dissecting one company. |
| `/dyp-ask <question>` | Answer a question the way Duan Yongping would. |
| `/wechat-article` | Author–editor–reader three-agent collaboration to turn a research report into a WeChat article. |

### Keiro integration skill

| Skill | Purpose |
|---|---|
| `/keiro-research-preflight` | Run **once per session**. Arms the four agents with the rule "prefer Keiro MCP tools for web research." Lives in `keiro-integration/keiro-research-preflight.md`. |

---

## 4. Tools (`tools/`)

Python helpers called by skills at validation checkpoints. All stdlib-only unless noted.

| Tool | Role |
|---|---|
| `financial_rigor.py` | Exact financial math (PE/ROE/owner-earnings/etc.). Skills call this at critical checkpoints so numbers aren't eyeballed. |
| `report_audit.py` | Pulls ~15% of financial data points from a draft report, checks them against reliable sources. Pass = release; fail = bounce with reasons. |
| `ashare_data.py` | A-share data: Tencent quotes + East Money search/financials, zero external deps. |
| `xueqiu_scraper.py` | Xueqiu (雪球) scraper: walks a user's full timeline, filters original posts by keyword. Login-state cache is gitignored. |
| `morningstar_fair_value.py` | Pulls Morningstar fair-value estimates for valuation cross-check. |
| `stock_screener.py` | Momentum-discovery + value-verification screener over the watchlist. |
| `momentum_backtest.py`, `momentum_backtest_v2.py` | Backtest the momentum leg of the screen. |

Install step copies these to be executable; skills invoke them via `python3 tools/<name>.py`.

---

## 5. Repository layout

```
install.sh                      # one-command install + setup
.mcp.json                       # registers the Keiro MCP server for this repo
.env.keiro.example              # KEIRO_API_KEY template (→ .env.keiro, gitignored)
skills/*.md                     # the 18 research skills (unmodified upstream)
codex-skills/, codex-prompts/   # same skills, packaged for Codex
tools/*.py                      # financial-rigor, report-audit, screeners, scrapers
scripts/
  install-claude-commands.sh    # copy skills → ~/.claude/commands
  keiro-setup.sh                # write .env.keiro key → .mcp.json
  install-codex-*.{sh,py}       # Codex equivalents
  sync-codex-*.py               # keep codex packs in sync with skills/
keiro-integration/
  keiro-research-preflight.md   # the preflight skill
  README.md                     # short integration reference (中文)
  MCP_SERVER.md                 # full Keiro MCP server docs
docs/PROJECT_GUIDE.md           # this file
reports/                        # generated research reports (by company / by industry)
README.md                       # Keiro-fork quick start
README.upstream.md              # original ai-berkshire README (preserved for clean rebase)
README_EN.md                    # upstream English README
CLAUDE.md                       # project instructions (report rules, naming, git)
```

### Report naming

| Skill | Path |
|---|---|
| `/investment-team` | `reports/{company}/` (4 lens files + 最终报告.md) |
| `/investment-research` | `reports/{company}/{company}-research-{YYYYMMDD}.md` |
| `/investment-checklist` | `reports/{company}/{company}-checklist-{YYYYMMDD}.md` |
| `/industry-research` | `reports/{industry}-industry-{YYYYMMDD}.md` (root) |
| `/industry-funnel` | `reports/{industry}-funnel-{YYYYMMDD}.md` (root) |
| `/earnings-review` | `reports/{company}/{company}-earnings-{period}.md` |
| `/thesis-tracker` | `reports/{company}/{company}-thesis.md` (long-lived) |
| `/portfolio-review` | `reports/portfolio-latest.md` (root, rolling) |
| `/management-deep-dive` | `reports/{company}/{company}-management-{YYYYMMDD}.md` |

Industry/funnel/portfolio/multi-company reports sit at the `reports/` root; single-company reports live in a per-company folder.

---

## 6. Install & setup

```bash
./install.sh
```

That single command:

1. Creates `.env.keiro` from `.env.keiro.example`; prompts for your `keiro_…` API key if not set.
2. Injects the key into `.mcp.json` (via `scripts/keiro-setup.sh`).
3. Installs the 18 skills + the Keiro preflight into `~/.claude/commands/` (via `scripts/install-claude-commands.sh`).

Then **restart Claude Code in this repo** so the MCP server connects. Get a key from the Keiro dashboard → API Keys.

> To run on **Codex** instead of Claude Code: use `scripts/install-codex-skills.sh` / `install-codex-prompts.sh`. The Keiro MCP layer is Claude-Code-specific; Codex users keep the upstream `WebSearch`/`WebFetch` transport.

---

## 7. Typical session

```
/keiro-research-preflight          # once per session — arms agents with Keiro tools
/investment-team PDD               # four agents research Pinduoduo in parallel
```

What happens:

1. Team Lead splits the ticker into four lenses.
2. Each agent researches its lens, pulling web material through Keiro:
   - keyword search → `mcp__keirolabs__web_search`
   - deep multi-source → `mcp__keirolabs__web_research`
   - one URL extract → `mcp__keirolabs__extract_url`
   - one cited fact → `mcp__keirolabs__answer`
3. `financial_rigor.py` verifies the numbers each agent relies on.
4. Team Lead reconciles the four lenses into **Pass / Fail / Gray Zone** with price bands and tiered advice, writes `reports/{company}/最终报告.md`.
5. Optional: `report_audit.py` spot-checks 15% of data points before release.

Other entry points: `/industry-funnel AI算力` → funnel to 3 names. `/earnings-team 腾讯 2025Q4` → earnings read + WeChat article. `/thesis-tracker 腾讯` → long-lived discipline file.

---

## 8. The Keiro MCP integration

The skills' analysis frameworks are **untouched**. Only the web-research transport changed — the smallest diff that survives an upstream `git pull --rebase`.

### Tool mapping

| AI Berkshire (original) | Keiro tool | Credits |
|---|---|---|
| `WebSearch` (keywords) | `mcp__keirolabs__web_search` | ~1–2 |
| `WebSearch` + `WebFetch` chain | `mcp__keirolabs__web_research` | ~3–5 |
| `WebFetch` (one URL) | `mcp__keirolabs__extract_url` | ~1–3 |
| Repeated searches for one fact | `mcp__keirolabs__answer` | ~5 |

### Why a preflight skill, not 18 edits

Each skill file hard-codes `WebSearch`. Editing 18 `.md` files is brittle and conflicts with upstream rebase. One preflight rule + one MCP registration lets agents pick the right Keiro tool at runtime — a smaller, maintainable diff. When a single skill must hard-bind a Keiro tool, edit just that one.

### Rate limits (four agents in parallel = 4× volume)

| Tool | Starter | Pro | Startup |
|---|---|---|---|
| web_search | 1000/min | 1000/min | 1000/min |
| web_research | 100/min | 500/min | 1000/min |
| extract_url | 100/min | 200/min | 300/min |
| answer | 100/min | 200/min | 300/min |

`web_research` / `extract_url` auto-fallback `deep → medium → light` on upstream 502/503/504/timeout — no manual retry. Full table and client configs in [`keiro-integration/MCP_SERVER.md`](../keiro-integration/MCP_SERVER.md).

---

## 9. English output

Skills default to Chinese reports. To get English without editing 18 files, add one line to `CLAUDE.md` under "报告语言与风格":

```
- Language override: when the user asks in English, all reports and agent output switch to English; all other rules unchanged.
```

Keiro's `answer` / `web_research` return English by default for English queries, so English sessions need no extra wiring.

---

## 10. Git workflow

- `origin` → `xbtlin/ai-berkshire` (upstream). `keiro` → `Keirolabs-API/AI-berkshire-Keiro` (this fork).
- Before pushing upstream-bound work: `git pull --rebase origin main` (upstream moves often).
- Commit messages: short, describe the change.
- Don't commit intermediate process files (`data_collection.md`, etc.) — only final reports.
- `.env.keiro` is gitignored; only `.env.keiro.example` is committed.

---

## 11. Disclaimer

Educational and research purposes only. **Not investment advice.** Historical returns (documented in `README.upstream.md`) do not guarantee future results. Investing involves risk; always do your own due diligence. Keiro only fetches and extracts web content — it does not change any research conclusion or its accountability.