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

## Requirements

- `jq` - for JSON manipulation
- Must be run from a git repository root

## Installation

```bash
# Clone or copy the script somewhere in your PATH
cp claude-worktree.sh ~/.local/bin/
chmod +x ~/.local/bin/claude-worktree.sh
```
