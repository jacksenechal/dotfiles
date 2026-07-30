#!/bin/bash
INPUT=$(cat)

# Extract tool name, command, and target file path
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# 1. Block the Bun bootstrapper and known payload executions.
#    Never bypassable - no legitimate workflow needs these.
if echo "$COMMAND" | grep -E -q 'bun run index\.js|node setup\.mjs|node \.claude/setup\.mjs'; then
    echo "Blocked: Mini Shai-Hulud execution pattern detected." >&2
    exit 2
fi

# 1b. Operator bypass request: escalate to the real permission prompt.
#     The agent can propose the bypass; only a human keystroke grants it.
if [ "$TOOL_NAME" = "Bash" ] && echo "$COMMAND" | grep -E -q \
        '^[[:space:]]*(~|\$HOME|'"$HOME"')/\.claude/hooks/request-bypass([[:space:]]+[0-9]+)?[[:space:]]*$'; then
    jq -n --arg cmd "$COMMAND" '{
        hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "ask",
            permissionDecisionReason: ("OPERATOR BYPASS REQUEST: this temporarily disables " +
                "agent/IDE config-write protection (.claude/hooks, skills, agents, commands, " +
                "settings.json, mcp.json). Approve only if you asked for a change in there. " +
                "Command: " + $cmd)
        }
    }'
    exit 0
fi

# 1c. Active bypass sentinel (expiring). Set only by request-bypass, above.
BYPASS="$HOME/.claude/hooks/.bypass"
if [ -f "$BYPASS" ]; then
    exp=$(cat "$BYPASS" 2>/dev/null)
    case "$exp" in ''|*[!0-9]*) exp=0 ;; esac
    if [ "$exp" -gt "$(date +%s)" ]; then
        exit 0
    fi
    rm -f "$BYPASS"   # expired
fi

# 1b-ii. With no active bypass, any other PATH-QUALIFIED reference to
#        request-bypass is denied. The escalation above is anchored to the bare
#        invocation, so this stops a compound command from smuggling the grant
#        past the prompt.
#        Requires a slash before the name: the script is not on PATH, so every
#        real invocation is path-qualified, while prose that merely names it
#        (commit messages, docs, this comment) is not. Matching the bare word
#        blocked ordinary work and taught nothing.
#        Deliberately placed AFTER the sentinel check: once a human has approved
#        a bypass, file operations naming this script must not stay blocked.
if [ "$TOOL_NAME" = "Bash" ] && echo "$COMMAND" | grep -E -q '[^[:space:];&|"'"'"']*/request-bypass'; then
    echo "Blocked: request-bypass must be run as a bare command with an optional minutes argument, nothing else on the line." >&2
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
        echo "Blocked: Attempted modification of agent/IDE configuration. If this was intended, run: ~/.claude/hooks/request-bypass 30" >&2
        exit 2
    fi
elif [ "$TOOL_NAME" = "Bash" ]; then
    # Only block Bash invocations where a write operator and a config path
    # appear together in the same clause (same line, not separated by a
    # pipe/semicolon/&), so unrelated redirects elsewhere in a multi-line
    # command don't combine with an unrelated path mention to false-block.
    # ln is in the list because symlink-swapping a hook replaces its contents
    # just as effectively as writing to it.
    WRITE_OP_WITH_PATH_RE="(>>?[^&|;]*($CONFIG_PATH_RE))|((^|[;&|][[:space:]]*)(cp|mv|rm|chmod|chown|touch|install|ln|dd|truncate)[[:space:]]+[^|;&]*($CONFIG_PATH_RE))|(sed[[:space:]]+-i[^|;&]*($CONFIG_PATH_RE))|([[:space:]]tee[[:space:]]+[^|;&]*($CONFIG_PATH_RE))"
    if echo "$COMMAND" | grep -E -q "$WRITE_OP_WITH_PATH_RE"; then
        echo "Blocked: Attempted modification of agent/IDE configuration. If this was intended, run: ~/.claude/hooks/request-bypass 30" >&2
        exit 2
    fi
fi

exit 0
