# Keiro × AI Berkshire

> Value-investing research, powered by a 4-agent parallel team — with web research routed through the [Keiro MCP server](https://kierolabs.space/mcp/api).

This is a Keiro-enabled fork of [`xbtlin/ai-berkshire`](https://github.com/xbtlin/ai-berkshire), a collection of Claude Code skills that simulate a real investment-research team: four agents (business, financial, industry, risk) research a company in parallel, then a Team Lead synthesizes a verdict — Pass / Fail / Gray Zone — in the spirit of Buffett, Munger, Duan Yongping, and Li Lu.

The original skills drive their web research through Claude Code's built-in `WebSearch` / `WebFetch`. **This integration swaps that layer for Keiro's MCP tools** — multi-source deep research, structured single-page extraction, and cited direct answers — so the agents pull decision-grade material instead of "analysis that looks right."

The upstream project is Chinese-first. The investment framework is language-agnostic; see [English output](#english-output) to run it in English without editing the skills.

---

## How it works

```
                ┌─────────────────────────────────────────────┐
                │            /investment-team <ticker>         │
                │                   (Team Lead)                │
                └───────┬───────────┬───────────┬──────────────┘
                        │           │           │
              business-  │  financial-│ industry- │  risk-
              analyst    │  analyst   │ researcher│  assessor
                        │           │           │
                        ▼           ▼           ▼
            ┌──────────────────────────────────────────────────┐
            │  Keiro MCP server  (registered via .mcp.json)     │
            │  web_search · web_research · extract_url · answer │
            └──────────────────────────────────────────────────┘
```

The skills' analysis frameworks are **untouched**. Only the web-research transport changes — the smallest diff that survives upstream `git pull --rebase`.

---

## Tool mapping

| AI Berkshire (original)        | Keiro tool                          | Credits |
|--------------------------------|-------------------------------------|---------|
| `WebSearch` (keywords)         | `mcp__keirolabs__web_search`        | ~1–2    |
| `WebSearch` + `WebFetch` chain | `mcp__keirolabs__web_research`      | ~3–5    |
| `WebFetch` (one URL)           | `mcp__keirolabs__extract_url`       | ~1–3    |
| Repeated searches for one fact | `mcp__keirolabs__answer`            | ~5      |

Per-agent assignment is handled by the preflight skill (see [Setup](#setup)).

---

## What's in this repo

| Path                                         | Purpose                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------|
| `skills/*.md`, `codex-skills/`, `codex-prompts/` | The investment-research skills (unmodified upstream).              |
| `.mcp.json`                                  | Registers the Keiro MCP server for this repo.                          |
| `.env.keiro.example` → `.env.keiro`         | Your `keiro_` API key (gitignored).                                    |
| `scripts/keiro-setup.sh`                     | Writes the key from `.env.keiro` into `.mcp.json`.                     |
| `keiro-integration/keiro-research-preflight.md` | One-shot preflight skill: tells the 4 agents to prefer Keiro tools. |
| `keiro-integration/README.md`                | Short integration reference.                                           |
| `keiro-integration/MCP_SERVER.md`            | Full Keiro MCP server docs (tools, auth, rate limits, client configs). |
| `README.upstream.md`                         | Original ai-berkshire README (preserved for rebase cleanliness).       |
| `README_EN.md`                               | Upstream English README.                                               |
| `reports/`                                   | Generated research reports (upstream).                                 |

---

## Setup

```bash
# 1. add your Keiro API key (create one starting with keiro_ in the Keiro dashboard → API Keys)
cp .env.keiro.example .env.keiro
$EDITOR .env.keiro            # set KEIRO_API_KEY=keiro_...

# 2. inject it into .mcp.json
./scripts/keiro-setup.sh

# 3. install the preflight skill so Claude Code can run it
cp keiro-integration/keiro-research-preflight.md ~/.claude/commands/

# 4. restart Claude Code in this repo, confirm the Keiro MCP server connects
```

## Usage

```
/keiro-research-preflight        # run once per session — arms agents with Keiro tools
/investment-team <ticker>        # then any upstream skill; agents research via Keiro
```

Other skills work the same way: `/investment-research`, `/industry-funnel`, `/bottleneck-hunter`, `/earnings-team`, `/quality-screen`, `/thesis-tracker`, `/portfolio-review`, … (full list in `skills/`).

---

## English output

The skills instruct agents to write reports in Chinese by default. To get English output without editing 18 skill files, add one line to `CLAUDE.md` under "报告语言与风格":

```
- Language override: when the user asks in English, all reports and agent output switch to English; all other rules unchanged.
```

The Keiro `answer` / `web_research` tools return English by default for English queries, so English sessions need no extra wiring.

---

## Credits & rate limits

Four agents in parallel = 4× concurrent search volume. Per-tier limits (full table in `keiro-integration/MCP_SERVER.md` or the `get_rate_limits` tool):

| Tool         | Starter  | Pro      | Startup   |
|--------------|----------|----------|-----------|
| web_search   | 1000/min | 1000/min | 1000/min  |
| web_research | 100/min  | 500/min  | 1000/min  |
| extract_url  | 100/min  | 200/min  | 300/min   |
| answer       | 100/min  | 200/min  | 300/min   |

`web_research` and `extract_url` auto-fallback `deep → medium → light` on upstream 502/503/504/timeout — no manual retry needed.

---

## Disclaimer

For educational and research purposes only. **Not investment advice.** Investing involves risk; always do your own due diligence. Keiro only fetches and extracts web content — it does not change any research conclusion or its accountability.

---

upstream credit: [xbtlin/ai-berkshire](https://github.com/xbtlin/ai-berkshire) · Keiro MCP: [kierolabs.space/mcp/api](https://kierolabs.space/mcp/api)