# MCP Server

Keiro exposes a Model Context Protocol (MCP) server at /mcp/api that gives AI agents direct access to web search, research, extraction, and answer tools — plus full API documentation.

## TL;DR

- 12 tools: 4 API tools (web_search, web_research, extract_url, answer) + 8 docs/utility tools.
- API tools require authentication (API key or JWT). Credits deducted per call.
- Automatic fallback: deep → medium → light on upstream errors.
- Works with Cursor, Claude Desktop, Windsurf, VS Code, Antigravity, and 15+ more clients.

## Quick Start

### Authentication

Get connected in 30 seconds.

**1. Endpoint**

```
https://kierolabs.space/mcp/api
```

**2. Transport**

Streamable HTTP (protocol version 2025-03-26+). Supports POST, GET, and DELETE methods.

**3. Auth Header**

```
Authorization: Bearer keiro_your_api_key
```

**4. Minimal Config**

Paste into your MCP client

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

## Tools

The MCP server exposes 12 tools organized into two categories:

### API Tools

Require authentication. Credits deducted per call.

- **web_search** `auth` — Search the web and return structured results with titles, URLs, and snippets. ~1–2 credits
- **web_research** `auth` — Deep web research — searches, extracts content, and synthesizes a comprehensive answer. ~3–5 credits
- **extract_url** `auth` — Extract structured data from a URL. Supports custom JSON schemas, content expansion, and multiple extraction depths. ~1–3 credits
- **answer** `auth` — Get a direct answer to a question using web search + AI synthesis. ~5 credits

### Docs & Utility Tools

No credits consumed. Useful for discovering the API.

- **list_endpoints** — List all available Keiro v2 API endpoints with summaries.
- **get_endpoint** — Get full details for a specific endpoint including parameters, pricing, and rate limits.
- **get_rate_limits** — Get per-tier rate limits for all endpoints with recommended pacing.
- **get_auth** — Get authentication documentation — methods, headers, and error codes.
- **generate_code** — Generate ready-to-use code snippets (cURL, Python, JavaScript) for any endpoint.
- **get_mcp_tools** — List all available MCP tools with categories and descriptions.
- **suggest_schema** — Suggest a JSON schema for extract_url based on a description or template.
- **check_credits** — Check credit costs per endpoint across all tiers.

## Authentication

### API Key

Opaque key starting with `keiro_`. Created in the Keiro dashboard under API Keys. Pass in the `Authorization: Bearer` header.

### MCP JWT

Obtained via OAuth login (Google/GitHub). Used by the MCP OAuth flow for desktop clients. Separate from dashboard JWTs.

### Protocol Flow

`initialize` and `notifications/initialized` run without auth (MCP protocol requirement). All subsequent requests (`tools/list`, `tools/call`) require the Authorization header.

## JSON Schema (extract_url)

The `extract_url` tool supports custom JSON schemas for structured data extraction.

**Parameters**

- `json_schema` (object) — JSON Schema defining the output structure. Only works in deep/medium mode.
- `objective` (string) — Natural language instruction for what to extract.
- `expand_content` (boolean) — Fetch full page content before extraction (slower but more thorough).
- `max_chars` (integer) — Maximum characters to process. Range: 1000–50000. Default: 10000.

**Example**

```json
{
  "name": "extract_url",
  "arguments": {
    "url": "https://example.com/article",
    "mode": "deep",
    "json_schema": {
      "type": "object",
      "properties": {
        "title": { "type": "string" },
        "author": { "type": "string" },
        "body": { "type": "string" },
        "tags": { "type": "array", "items": { "type": "string" } }
      },
      "required": ["title", "body"]
    },
    "objective": "Extract the article metadata and content"
  }
}
```

### Built-in Templates

Use `suggest_schema` with a template parameter: `"article"`, `"product"`, `"recipe"`, `"person"`, `"event"`, `"faq"`.

## Fallback Behavior

When an upstream request fails, `web_research` and `extract_url` automatically retry with a less demanding mode.

**Fallback Chain:** `deep` → `medium` → `light`

Triggers: 502, 503, 504, timeout, ECONNREFUSED.

When all modes fail, the response includes `"retryable": false` in the `_meta` object.

## Rate Limits

MCP API tools share the same rate limits as the REST API. Use `get_rate_limits` to check limits for your tier.

| Tool | Starter | Pro | Startup |
|---|---|---|---|
| web_search | 1000/min | 1000/min | 1000/min |
| web_research | 100/min | 500/min | 1000/min |
| extract_url | 100/min | 200/min | 300/min |
| answer | 100/min | 200/min | 300/min |

Use `get_rate_limits` with a tier parameter for the full table including batch and poll limits.

## Client Configs

Copy the config for your MCP client. Replace `keiro_your_api_key` with your actual key.

### Coding IDEs

#### Cursor — `~/.cursor/mcp.json`

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### Windsurf

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### VS Code (Cline)

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### Roo Code

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### GitHub Copilot — VS Code settings.json

```json
{
  "servers": {
    "keirolabs": {
      "type": "http",
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### Continue — Uses `transport.type` instead of top-level transport

```json
{
  "mcpServers": {
    "keirolabs": {
      "transport": {
        "type": "http",
        "url": "https://kierolabs.space/mcp/api"
      },
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### Zed — Uses `context_servers` key

```json
{
  "context_servers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

### Desktop AI Apps

#### Claude Desktop — `%APPDATA%\Claude\claude_desktop_config.json` (Windows)

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### LibreChat — Uses `type: http`

```json
{
  "mcpServers": {
    "keirolabs": {
      "type": "http",
      "url": "https://kierolabs.space/mcp/api",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### LobeChat — Uses `type: streamable-http`

```json
{
  "mcpServers": {
    "keirolabs": {
      "type": "streamable-http",
      "url": "https://kierolabs.space/mcp/api",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### Cherry Studio

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

### Google / Gemini

#### Antigravity / Gemini — Important: uses `serverUrl`, not `url`

```json
{
  "mcpServers": {
    "keirolabs-api": {
      "serverUrl": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

### Agent Frameworks

#### OpenHands

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### LangChain (Python) — Uses `langchain_mcp_adapters`

```python
from langchain_mcp_adapters.client import MultiServerMCPClient

client = MultiServerMCPClient(
    {
        "keirolabs": {
            "transport": "streamable_http",
            "url": "https://kierolabs.space/mcp/api",
            "headers": {
                "Authorization": "Bearer keiro_your_api_key"
            }
        }
    }
)
```

#### Flowise

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### OpenAI Codex CLI

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

### Terminal Agents

#### Aider

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### Warp

```json
{
  "mcpServers": {
    "keirolabs": {
      "url": "https://kierolabs.space/mcp/api",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```

#### OpenCode — `opencode.jsonc`, uses `type: remote`

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "keirolabs": {
      "type": "remote",
      "url": "https://kierolabs.space/mcp/api",
      "headers": {
        "Authorization": "Bearer keiro_your_api_key"
      }
    }
  }
}
```