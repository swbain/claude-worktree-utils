# claude-worktree-utils

Create git worktrees with Claude Code configuration automatically copied from the source repo.

## Usage

### Create a worktree

```bash
./claude-worktree <branch-name>
```

Run from a git repository root. The script will:

1. Create a worktree at `../<repo-name>-<branch-name>`
2. Copy Claude Code project settings from `~/.claude.json`
3. Copy `.claude/settings.local.json` if it exists
4. Copy `.mcp.json` if it exists
5. Copy `CLAUDE.local.md` if it exists

### Example

```bash
cd ~/projects/my-app
claude-worktree feature-xyz
# Creates worktree at ~/projects/my-app-feature-xyz
```

### Remove a worktree

```bash
./cleanup-worktree <branch-name>
```

Run from the same git repository root where you created the worktree. The script will:

1. Remove the worktree at `../<repo-name>-<branch-name>`
2. Remove the project entry from `~/.claude.json`

Note: The branch itself is not deleted. Remove it manually with `git branch -d <branch-name>` if needed.

### Example

```bash
cd ~/projects/my-app
cleanup-worktree feature-xyz
# Removes worktree at ~/projects/my-app-feature-xyz
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
# Clone or copy the scripts somewhere in your PATH
cp claude-worktree cleanup-worktree ~/.local/bin/
chmod +x ~/.local/bin/claude-worktree ~/.local/bin/cleanup-worktree
```
