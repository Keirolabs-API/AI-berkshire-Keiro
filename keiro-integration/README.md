# Keiro × AI Berkshire

[AI Berkshire](https://github.com/xbtlin/ai-berkshire) 是一套基于 Claude Code 的价值投研
Skill 合集：`/investment-team`、`/industry-funnel`、`/bottleneck-hunter` 等 skill 会
启动 4 个并行 Agent 做联网研究，再由 Team Lead 综合。

这些 skill 默认用 Claude Code 内置的 `WebSearch` / `WebFetch` 联网。本集成把联网手段
换成 **Keiro MCP server** 的四个 API 工具——多源交叉验证、单页结构化抽取、带出处的
直接问答——让投研 Agent 拿到"能据以决策"的素材，而不是"看起来正确的分析"。

## 接入了什么

| 文件 | 作用 |
|---|---|
| `.mcp.json` | 在本仓库内注册 Keiro MCP server，Claude Code 启动后自动加载 |
| `.env.keiro.example` | `KEIRO_API_KEY` 模板，复制为 `.env.keiro` 后填入 |
| `scripts/keiro-setup.sh` | 把 `.env.keiro` 里的 key 写进 `.mcp.json` |
| `keiro-integration/keiro-research-preflight.md` | 会话开头跑一次的预飞 skill，向四个 Agent 下发"优先用 Keiro 工具"的规则 |
| `keiro-integration/MCP_SERVER.md` | Keiro MCP server 完整文档（工具、鉴权、限速、各客户端配置） |

投研 skill 本身（`skills/*.md`）**未改动**——只替换联网手段，不动分析框架。

## 工具映射

| AI Berkshire 原本 | Keiro 工具 | 信用 |
|---|---|---|
| `WebSearch` 关键词搜 | `mcp__keirolabs__web_search` | ~1–2 |
| `WebSearch`+`WebFetch` 拼深度研究 | `mcp__keirolabs__web_research` | ~3–5 |
| `WebFetch` 读单个 URL | `mcp__keirolabs__extract_url` | ~1–3 |
| 反复搜索拼一个事实 | `mcp__keirolabs__answer` | ~5 |

## 启用步骤

```bash
cd keiro-berkshire
cp .env.keiro.example .env.keiro          # 填入你的 keiro_ key
./scripts/keiro-setup.sh                   # 写入 .mcp.json
# 重启本仓库下的 Claude Code，确认 Keiro MCP server 已连接
```

然后每次投研会话开头：

```
/keiro-research-preflight      # 把 keiro-integration/keiro-research-preflight.md 复制到 ~/.claude/commands/ 后
/investment-team 拼多多         # 正常跑投研 skill，Agent 会优先用 Keiro 联网
```

## 为什么这样做（而不是改 18 个 skill）

skill 文件里写死的是 `WebSearch`。逐个改写 18 个 `.md` 既脆又会和上游
`git pull --rebase` 冲突。改用一条预飞规则 + 一个 MCP server 注册，让 Agent 在运行时
自行选择更合适的 Keiro 工具，是更小、更易维护的 diff。需要某条 skill 硬绑 Keiro 工具
时，再单独改那一条。

## 信用与限速

四个 Agent 并行 = 并发搜索量 ×4。Starter 档 `web_research` 100/min、`extract_url`
100/min、`answer` 100/min；Pro/Startup 更高。完整限速表见 `MCP_SERVER.md` 与
`get_rate_limits` 工具。上游失败时 `web_research`/`extract_url` 自动降级
deep→medium→light。

## 风险声明

沿用上游 README：本项目仅供教育与研究，不构成投资建议。Keiro 只负责联网与抽取，
不改变任何投研结论的责任归属。