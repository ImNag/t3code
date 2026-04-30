#!/bin/zsh

set -e

# Trust the project's .mise.toml so non-interactive IDE shells don't block.
if command -v mise >/dev/null 2>&1; then
  mise trust --quiet 2>/dev/null || true
fi

# Run the desktop app in dev mode. Whatever env this script inherits from
# its launcher (IDE run config) reaches the spawned Claude Agent SDK, so
# CLAUDE_CODE_USE_BEDROCK and AWS_* vars set on the run config take effect.
bun run dev:desktop
