#!/bin/bash
INPUT=$(cat)

# Extract the tool command and target file path
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# 1. Block the Bun bootstrapper and known payload executions
if echo "$COMMAND" | grep -E -q 'bun run index\.js|node setup\.mjs|node \.claude/setup\.mjs'; then
    echo "Blocked: Mini Shai-Hulud execution pattern detected."
    exit 1
fi

# 2. Block persistence injections into the agent's own config
if echo "$FILE_PATH" | grep -E -q '\.claude/|\.vscode/tasks\.json'; then
    echo "Blocked: Attempted modification of agent/IDE configuration."
    exit 1
fi

exit 0
