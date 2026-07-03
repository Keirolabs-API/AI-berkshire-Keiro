#!/usr/bin/env sh
# ponytail: one-command install + setup. Wraps the two existing scripts plus
# env creation. No deps beyond sh + cp. Upgrade path: if you need profile
# selection / multi-key support, split into a real installer lib.
set -eu

root="$(cd "$(dirname "$0")" && pwd)"
cd "$root"

# 1. API key → .env.keiro (create from example, then inject into .mcp.json)
if [ ! -f .env.keiro ]; then
  cp .env.keiro.example .env.keiro
fi
. ./.env.keiro
if [ "$KEIRO_API_KEY" = "keiro_REPLACE_ME" ] || [ -z "$KEIRO_API_KEY" ]; then
  printf 'Paste your Keiro API key (starts with keiro_): '
  read -r KEY
  case "$KEY" in
    keiro_*) ;;
    *) echo "expected a key starting with keiro_"; exit 1;;
  esac
  # rewrite the KEIRO_API_KEY line in .env.keiro (portable: no sed -i)
  grep -v '^KEIRO_API_KEY=' .env.keiro > .env.keiro.tmp || true
  printf 'KEIRO_API_KEY=%s\n' "$KEY" >> .env.keiro.tmp
  mv .env.keiro.tmp .env.keiro
  KEIRO_API_KEY="$KEY"
fi
./scripts/keiro-setup.sh

# 2. Install skills (upstream) + the Keiro preflight skill
./scripts/install-claude-commands.sh
dest="${CLAUDE_COMMANDS_DIR:-$HOME/.claude/commands}"
mkdir -p "$dest"
cp keiro-integration/keiro-research-preflight.md "$dest"/

cat <<EOF

✓ Done. Next:
  1. Restart Claude Code in this repo (loads the Keiro MCP server).
  2. Run  /keiro-research-preflight  once per session.
  3. Run any skill, e.g.  /investment-team <ticker>
EOF