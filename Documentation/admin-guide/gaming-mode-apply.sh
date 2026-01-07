#!/bin/sh
# Simple helper script to enable/disable gaming mode sysctls
# Install to /usr/local/sbin/gaming-mode-apply.sh and make executable (chmod +x)

SYS=/proc/sys/gaming
if [ ! -d "$SYS" ]; then
    echo "gaming-mode sysctl not found at $SYS" >&2
    exit 1
fi

case "$1" in
    enable)
        echo 1 > $SYS/gaming_mode || true
        # enable uclamp helpers if present
        [ -f $SYS/uclamp_enable ] && echo 1 > $SYS/uclamp_enable || true
        [ -f $SYS/uclamp_assist ] && echo 1 > $SYS/uclamp_assist || true
        echo "gaming-mode: enabled"
        ;;
    disable)
        echo 0 > $SYS/gaming_mode || true
        echo "gaming-mode: disabled"
        ;;
    status)
        echo "--- /proc/sys/gaming ---"
        ls -1 $SYS || true
        echo "Values:"
        for f in $SYS/*; do
            echo "$(basename $f): $(cat $f 2>/dev/null || echo '(unreadable)')"
        done
        ;;
    *)
        echo "Usage: $0 {enable|disable|status}" >&2
        exit 2
        ;;
esac
