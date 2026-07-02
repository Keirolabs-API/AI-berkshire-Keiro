#!/usr/bin/env sh
# ponytail: posix sh, no deps. Reads KEIRO_API_KEY from .env.keiro and writes it
# into .mcp.json's Authorization header. Run once after copying .env.keiro.example.
# Upgrade path: if you need multi-profile keys, switch to a real env loader.
set -eu

root="$(cd "$(dirname "$0")/.." && pwd)"
env_file="$root/.env.keiro"
mcp_file="$root/.mcp.json"

[ -f "$env_file" ] || { echo "missing $env_file (cp .env.keiro.example .env.keiro)"; exit 1; }
# shellcheck disable=SC1090
. "$env_file"
case "$KEIRO_API_KEY" in
  keiro_REPLACE_ME|"") echo "set KEIRO_API_KEY in $env_file first"; exit 1;;
esac

url="${KEIRO_MCP_URL:-https://kierolabs.space/mcp/api}"
cat > "$mcp_file" <<EOF
{
  "mcpServers": {
    "keirolabs": {
      "url": "$url",
      "transport": "streamable-http",
      "headers": {
        "Authorization": "Bearer $KEIRO_API_KEY"
      }
    }
  }
}
EOF
echo "wrote $mcp_file with key ${KEIRO_API_KEY%????????????}****"
echo "restart Claude Code in this repo to load the Keiro MCP server"