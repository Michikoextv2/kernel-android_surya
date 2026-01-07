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

        # Prefer schedutil governor for balanced performance/energy
        if command -v cpufreq-info >/dev/null 2>&1; then
            for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
                g=$cpu/cpufreq/scaling_governor
                if [ -f "$g" ]; then
                    echo schedutil > "$g" || true
                fi
            done
        fi

        # Optional: tune schedutil rate limits (microseconds)
        # Use 20000us (20ms) default to avoid frequent DVFS churn which can
        # cause extra power/perf overhead on mobile devices.
        for f in /sys/devices/system/cpu/cpufreq/*/schedutil_* 2>/dev/null; do
            echo 20000 > "$f" 2>/dev/null || true
        done

        echo "gaming-mode: enabled"

        # When gaming mode is enabled we prioritize responsiveness: disable deep-sleep helper
        if command -v /usr/local/sbin/deepsleep-apply.sh >/dev/null 2>&1; then
            /usr/local/sbin/deepsleep-apply.sh disable || true
        fi
        ;;
    disable)
        echo 0 > $SYS/gaming_mode || true

        # When gaming mode is disabled, re-enable deeper sleep policies
        if command -v /usr/local/sbin/deepsleep-apply.sh >/dev/null 2>&1; then
            /usr/local/sbin/deepsleep-apply.sh enable || true
        fi
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
