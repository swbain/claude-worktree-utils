#!/bin/bash
set -euo pipefail

# claude-worktree.sh - Create a git worktree with Claude Code configuration

#######################################
# Validate environment and arguments
#######################################

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <branch-name>" >&2
    exit 1
fi

BRANCH_NAME="$1"

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: Not inside a git repository" >&2
    exit 1
fi

# Ensure we're at the repo root
REPO_ROOT="$(git rev-parse --show-toplevel)"
if [[ "$PWD" != "$REPO_ROOT" ]]; then
    echo "Error: Must run from git repository root ($REPO_ROOT)" >&2
    exit 1
fi

# Check for jq dependency
if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed" >&2
    exit 1
fi

#######################################
# Create worktree
#######################################

REPO_NAME="$(basename "$PWD")"
WORKTREE_PATH="$(dirname "$PWD")/${REPO_NAME}-${BRANCH_NAME}"

echo "Creating worktree at: $WORKTREE_PATH"

# Check if branch exists (locally or remotely)
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" || \
   git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; then
    # Branch exists, just add worktree
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
else
    # Branch doesn't exist, create it
    git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH"
fi

#######################################
# Update ~/.claude.json
#######################################

CLAUDE_CONFIG="$HOME/.claude.json"
SOURCE_PROJECT="$PWD"

if [[ -f "$CLAUDE_CONFIG" ]]; then
    echo "Updating Claude configuration..."

    # Create a jq filter to copy project config
    # We read the source project config and copy specific fields to the new project
    jq --arg src "$SOURCE_PROJECT" --arg dest "$WORKTREE_PATH" '
        # Get the source project config (default to empty object if not found)
        (.projects[$src] // {}) as $srcConfig |

        # Build new project config with only the fields we want to copy
        {
            allowedTools: $srcConfig.allowedTools,
            mcpServers: $srcConfig.mcpServers,
            mcpContextUris: $srcConfig.mcpContextUris,
            enabledMcpjsonServers: $srcConfig.enabledMcpjsonServers,
            disabledMcpjsonServers: $srcConfig.disabledMcpjsonServers,
            hasTrustDialogAccepted: true
        } |

        # Remove null values (fields that were not in source config)
        with_entries(select(.value != null)) |

        # Set this as the new project config
        . as $newConfig |

        # Update the main config
        $ARGS.positional[0] | .projects[$dest] = $newConfig
    ' --jsonargs "$CLAUDE_CONFIG" < "$CLAUDE_CONFIG" > "${CLAUDE_CONFIG}.tmp"

    mv "${CLAUDE_CONFIG}.tmp" "$CLAUDE_CONFIG"
    echo "Added project config for: $WORKTREE_PATH"
else
    echo "Warning: $CLAUDE_CONFIG not found, skipping config update"
fi

#######################################
# Copy local settings
#######################################

LOCAL_SETTINGS=".claude/settings.local.json"

if [[ -f "$LOCAL_SETTINGS" ]]; then
    echo "Copying local Claude settings..."
    mkdir -p "$WORKTREE_PATH/.claude"
    cp "$LOCAL_SETTINGS" "$WORKTREE_PATH/$LOCAL_SETTINGS"
    echo "Copied $LOCAL_SETTINGS to worktree"
fi

#######################################
# Done
#######################################

echo ""
echo "Worktree created successfully!"
echo "  Path: $WORKTREE_PATH"
echo "  Branch: $BRANCH_NAME"
echo ""
echo "To enter the worktree:"
echo "  cd $WORKTREE_PATH"
