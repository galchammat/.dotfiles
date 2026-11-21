#!/usr/bin/env bash
# One approval per session, then no more (the user, 2026-11-21: "if it hits one block, it should ask me ... should we go
# into bypass mode? And an approval message should pop up"). Sessions start in auto mode. The first time auto mode
# blocks something, the next tool call is put to the user as one approval prompt; once approved, every later call of
# that session is allowed without the classifier or a prompt, as bypass mode would.
#
#   elevate.sh denied   PermissionDenied: auto mode blocked a call. Mark the session, and let the model retry.
#   elevate.sh pre      PreToolUse: allow everything in an elevated session; after a block, ask once.
#   elevate.sh ran      PostToolUse: the call that was asked about ran, so the user approved: elevate the session.
#
# State: ~/.claude/state/elevate/{blocked,asked,elevated}/<session id>, swept after 7 days.
input=$(cat)
session=$(jq -r '.session_id // ""' <<<"$input" | tr -cd '[:alnum:]_-')
call=$(jq -r '.tool_use_id // ""' <<<"$input")
[ -n "$session" ] || exit 0
state=$HOME/.claude/state/elevate
mkdir -p "$state/blocked" "$state/asked" "$state/elevated"
find "$state" -type f -mtime +7 -delete 2>/dev/null

case "${1:-}" in
denied)
    touch "$state/blocked/$session"
    jq -n '{hookSpecificOutput: {hookEventName: "PermissionDenied", retry: true}}'
    ;;
pre)
    if [ -f "$state/elevated/$session" ]; then
        jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "allow",
            permissionDecisionReason: "This session was approved for bypass after its first block."}}'
    elif [ -f "$state/blocked/$session" ]; then
        rm -f "$state/blocked/$session"
        printf '%s' "$call" >"$state/asked/$session"
        jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask",
            permissionDecisionReason: "Auto mode blocked something in this session. Approve this one and the rest of the session runs without asking (bypass)."}}'
    fi
    ;;
ran)
    if [ -f "$state/asked/$session" ] && [ "$(cat "$state/asked/$session")" = "$call" ]; then
        rm -f "$state/asked/$session"
        touch "$state/elevated/$session"
    fi
    ;;
esac
exit 0
