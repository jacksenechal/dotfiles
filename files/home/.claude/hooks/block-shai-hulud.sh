#!/bin/bash
INPUT=$(cat)

# Extract tool name, command, and target file path
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# 1. Block the Bun bootstrapper and known payload executions
if echo "$COMMAND" | grep -E -q 'bun run index\.js|node setup\.mjs|node \.claude/setup\.mjs'; then
    echo "Blocked: Mini Shai-Hulud execution pattern detected." >&2
    exit 2
fi

# 2. Block persistence injections into the agent's own config.
#    Only applies to write-class tool calls (Edit, Write, or a writing Bash command).
#    Read is never blocked, and only genuine agent/IDE config paths are in scope
#    (not project docs like .claude/prds/** or .claude/epics/**).
#    In scope: .claude/hooks/, .claude/skills/, .claude/agents/, .claude/commands/ -
#    these hold executable scripts/agent definitions and are persistence vectors.
#    Carve out .claude/projects/*/memory/ - that's Claude's own memory store, not config.
CONFIG_PATH_RE='(^|/)\.claude/(hooks|skills|agents|commands)/|(^|/)settings(\.local)?\.json$|(^|/)\.mcp\.json$|(^|/)mcp\.json$|(^|/)\.claude\.json$|(^|/)keybindings\.json$'

is_write_tool=false
case "$TOOL_NAME" in
    Edit|Write|MultiEdit|NotebookEdit)
        is_write_tool=true
        ;;
esac

if [ "$is_write_tool" = true ]; then
    if echo "$FILE_PATH" | grep -E -q '\.claude/projects/[^/]+/memory/'; then
        exit 0
    fi
    if echo "$FILE_PATH" | grep -E -q "$CONFIG_PATH_RE"; then
        echo "Blocked: Attempted modification of agent/IDE configuration." >&2
        exit 2
    fi
elif [ "$TOOL_NAME" = "Bash" ]; then
    # Only block Bash invocations where a write operator and a config path
    # appear together in the same clause (same line, not separated by a
    # pipe/semicolon/&), so unrelated redirects elsewhere in a multi-line
    # command don't combine with an unrelated path mention to false-block.
    WRITE_OP_WITH_PATH_RE="(>>?[^&|;]*($CONFIG_PATH_RE))|((^|[;&|][[:space:]]*)(cp|mv|rm|chmod|touch|install|dd|truncate)[[:space:]]+[^|;&]*($CONFIG_PATH_RE))|(sed[[:space:]]+-i[^|;&]*($CONFIG_PATH_RE))|([[:space:]]tee[[:space:]]+[^|;&]*($CONFIG_PATH_RE))"
    if echo "$COMMAND" | grep -E -q "$WRITE_OP_WITH_PATH_RE"; then
        echo "Blocked: Attempted modification of agent/IDE configuration." >&2
        exit 2
    fi
fi

exit 0
