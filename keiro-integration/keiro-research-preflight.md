# Keiro 研究预飞（在每个投研会话开头运行一次）

把这条命令复制到 `~/.claude/commands/` 后，在开始任何投研 skill
（`/investment-team`、`/investment-research`、`/industry-funnel`…）之前先跑一次：
`/keiro-research-preflight`。它会向本次会话注入"优先用 Keiro MCP 工具做联网研究"
的规则，并被 Team Lead 下发给四个并行 Agent。

## 你现在拥有的工具（Keiro MCP server 已通过 .mcp.json 接入）

| 想做什么 | 用这个 Keiro 工具 | 不要再用 |
|---|---|---|
| 快速搜索、拿标题/URL/摘要 | `mcp__keirolabs__web_search` | 内置 `WebSearch` |
| 深度研究：搜索+抓全文+综合成答案 | `mcp__keirolabs__web_research` | 手动 WebSearch + WebFetch 拼接 |
| 读单个 URL、抽结构化数据 | `mcp__keirolabs__extract_url` | 内置 `WebFetch` |
| 直接要一个有出处的事实答案 | `mcp__keirolabs__answer` | 反复搜索 |

## 分配规则（Team Lead 下发给各 Agent 时遵守）

- **business-analyst / industry-researcher**：产业链、竞争对手、新闻 →
  `web_research` 做多源交叉验证；单家公司主页/财报页面 → `extract_url` 抽结构化字段。
- **financial-analyst**：股价、PE/PB、市值、最新财报核心数字 →
  `answer` 拿带出处的事实，再 `web_search` 复核第二来源（投研核心原则要求关键数据≥2源交叉验证）。
- **risk-assessor**：近 1–2 小时新闻、供应链瓶颈、监管动态 →
  `web_search`（高频、低成本），深挖某条线索再切 `web_research`。
- **team-lead**：综合阶段只做研判，不再联网；需要补查事实时用 `answer`。

## 信用与限速提醒

- 每次调用扣信用：`web_search` ~1–2、`extract_url` ~1–3、`web_research` ~3–5、`answer` ~5。
- 四个 Agent 并行 = 并发搜索量×4，注意 tier 限速（Starter `web_research` 100/min）。
- 上游失败时 `web_research`/`extract_url` 自动降级 deep→medium→light，无需手动重试。

## 执行

读完后，向用户确认"Keiro 工具已就绪"，然后正常启动被请求的投研 skill。
不要替换投研 skill 本身的分析框架，只替换其联网手段。