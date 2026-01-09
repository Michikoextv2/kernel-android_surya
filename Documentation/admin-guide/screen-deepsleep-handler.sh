#!/bin/sh
# Poll-based screen off handler to toggle deepsleep settings.
# Install to /usr/local/sbin/screen-deepsleep-handler.sh and make executable (chmod +x)

POLL_INTERVAL=${POLL_INTERVAL:-2}
BRIGHTNESS_PATH=${BRIGHTNESS_PATH:-$(ls -1 /sys/class/backlight/*/brightness 2>/dev/null | head -n1)}
OFF_THRESHOLD=${OFF_THRESHOLD:-0}

if [ -z "$BRIGHTNESS_PATH" ]; then
    echo "screen-deepsleep: no brightness path found" >&2
    exit 1
fi

log() { echo "screen-deepsleep: $@"; }

prev_state=unknown
while true; do
    val=$(cat "$BRIGHTNESS_PATH" 2>/dev/null || echo 0)
    if [ -z "$val" ]; then val=0; fi

    if [ "$val" -le "$OFF_THRESHOLD" ]; then
        state=off
    else
        state=on
    fi

    if [ "$state" != "$prev_state" ]; then
        if [ "$state" = "off" ]; then
            log "screen off detected (brightness=$val): enabling deepsleep"
            /usr/local/sbin/deepsleep-apply.sh enable >/dev/null 2>&1 || true
        else
            log "screen on detected (brightness=$val): disabling deepsleep"
            /usr/local/sbin/deepsleep-apply.sh disable >/dev/null 2>&1 || true
        fi
        prev_state=$state
    fi

    sleep "$POLL_INTERVAL"
done
