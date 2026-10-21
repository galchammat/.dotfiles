#!/usr/bin/env bash
# bar-hud: on-demand waybar visibility — bar appears while ALT is held.
#
# waybar's SIGUSR1 is a *toggle*; to avoid state drift we never trust a
# remembered state and instead read ground truth from `hyprctl layers`
# before deciding whether to send it.
#
# Usage: bar-hud.sh start|down|up|toggle
#   start   launch waybar (hidden) — called from hyprland autostart
#   down    ALT key pressed — schedule a show after DELAY (debounce)
#   up      ALT key released — cancel pending show, hide if visible
#   toggle  manual flip (recovery bind / pin the bar open)

DELAY=0.3
RUNDIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
TIMER="$RUNDIR/bar-hud.timer"

visible() {
    hyprctl layers 2>/dev/null | grep -q "namespace: waybar"
}

show_if_hidden() {
    visible || pkill -SIGUSR1 waybar
}

hide_if_visible() {
    visible && pkill -SIGUSR1 waybar
}

case "$1" in
    start)
        if ! pgrep -x waybar >/dev/null; then
            (waybar >/dev/null 2>&1 &)
            sleep 0.5
        fi
        # waybar starts visible; hide it so the default state is hidden
        hide_if_visible
        ;;
    down)
        if [ ! -e "$TIMER" ]; then
            (
                sleep "$DELAY"
                rm -f "$TIMER"
                show_if_hidden
            ) &
            echo $! >"$TIMER"
        fi
        ;;
    up)
        if [ -e "$TIMER" ]; then
            kill "$(cat "$TIMER")" 2>/dev/null
            rm -f "$TIMER"
        fi
        hide_if_visible
        ;;
    toggle)
        rm -f "$TIMER"
        pkill -SIGUSR1 waybar
        ;;
esac
