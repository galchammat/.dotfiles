#!/usr/bin/env bash
# bar-hud: on-demand waybar visibility — bar appears while ALT is held.
#
# waybar is configured with on-sigusr1=show and on-sigusr2=hide, so both
# signals are idempotent and this script never has to remember state.
#
# Usage: bar-hud.sh start|down|up|toggle
#   start   launch waybar (starts hidden) — called from hyprland autostart
#   down    ALT key pressed — schedule a show after DELAY (debounce)
#   up      ALT key released — cancel pending show, hide
#   toggle  manual flip (pin the bar open without holding ALT)

DELAY=0.3
RUNDIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
TIMER="$RUNDIR/bar-hud.timer"

show() { pkill -SIGUSR1 -x waybar; }
hide() { pkill -SIGUSR2 -x waybar; }

# A hidden waybar keeps its layer surface but drops to the bottom layer;
# a shown one sits on the overlay layer.
visible() {
    hyprctl layers | awk '/Layer level/ { lvl = $3 } /namespace: waybar/ && lvl == "3" { found = 1 } END { exit !found }'
}

cancel_timer() {
    if [ -e "$TIMER" ]; then
        kill "$(cat "$TIMER")" 2>/dev/null
        rm -f "$TIMER"
    fi
}

case "$1" in
    start)
        pgrep -x waybar >/dev/null || (waybar >/dev/null 2>&1 &)
        ;;
    down)
        if [ ! -e "$TIMER" ]; then
            (
                sleep "$DELAY"
                rm -f "$TIMER"
                show
            ) &
            echo $! >"$TIMER"
        fi
        ;;
    up)
        cancel_timer
        hide
        ;;
    toggle)
        cancel_timer
        if visible; then hide; else show; fi
        ;;
esac
