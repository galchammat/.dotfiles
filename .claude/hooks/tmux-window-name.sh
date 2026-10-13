#!/usr/bin/env bash
# Keep the tmux window name in sync with the current Claude Code session name.
#
# Claude Code already writes the session name into the terminal title (e.g.
# "✳ Tmux window name sync") and refreshes it on start, resume, /rename and
# auto-generated topic titles. So instead of renaming the window from a hook
# (which could only fire on hook events), this points tmux's own
# automatic-rename at the pane title: tmux re-evaluates it whenever the title
# changes, so the window name tracks the session name live.
#
# The format strips a leading symbol token ("✳ ", "⚠ ", ...) and clips to 15
# chars, falling back to the running command when the title is empty.
#
# Usage: tmux-window-name.sh on|off   (wired to SessionStart / SessionEnd hooks)
set -u

[ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

FMT='#{?#{==:#{pane_title},},#{pane_current_command},#{=15:#{s/^[^a-zA-Z0-9][^ ]* //:pane_title}}}'

case "${1:-on}" in
on)
	tmux set-option -w -t "$TMUX_PANE" automatic-rename on
	tmux set-option -w -t "$TMUX_PANE" automatic-rename-format "$FMT"
	;;
off)
	tmux set-option -wu -t "$TMUX_PANE" automatic-rename-format
	tmux set-option -wu -t "$TMUX_PANE" automatic-rename
	;;
esac

exit 0
