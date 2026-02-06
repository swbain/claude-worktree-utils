# claude-worktree

Create git worktrees with Claude Code configuration automatically copied from the source repo.

## Usage

```bash
./claude-worktree.sh <branch-name>
```

Run from a git repository root. The script will:

1. Create a worktree at `../<repo-name>-<branch-name>`
2. Copy Claude Code project settings from `~/.claude.json`
3. Copy `.claude/settings.local.json` if it exists
4. Copy `.mcp.json` if it exists
5. Copy `CLAUDE.local.md` if it exists

## Example

```bash
cd ~/projects/my-app
claude-worktree.sh feature-xyz
# Creates worktree at ~/projects/my-app-feature-xyz
```

## What Gets Copied

From `~/.claude.json` project config:
- `allowedTools`
- `mcpServers`
- `mcpContextUris`
- `enabledMcpjsonServers`
- `disabledMcpjsonServers`

The new project also gets `hasTrustDialogAccepted: true` set automatically.

Local files (if they exist):
- `.claude/settings.local.json` - Local Claude settings
- `.mcp.json` - Project MCP server configuration
- `CLAUDE.local.md` - Local project instructions

## Requirements

- `jq` - for JSON manipulation
- Must be run from a git repository root

## Installation

```bash
# Clone or copy the script somewhere in your PATH
cp claude-worktree.sh ~/.local/bin/
chmod +x ~/.local/bin/claude-worktree.sh
```
