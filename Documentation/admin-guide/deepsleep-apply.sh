#!/bin/sh
# Apply safe deep-sleep friendly runtime/power settings.
# Install to /usr/local/sbin/deepsleep-apply.sh and make executable (chmod +x)

set -e
SYSFS_OK=0

log() { echo "deepsleep-apply: $@"; }

# Helper: write value to file if it exists
write_if() {
    local f="$1" val="$2"
    if [ -e "$f" ]; then
        echo "$val" > "$f" 2>/dev/null || true
        SYSFS_OK=1
    fi
}

case "$1" in
    enable)
        log "Applying deepsleep-friendly settings..."

        # Enable runtime autosuspend for USB devices and set a reasonable delay
        for d in /sys/bus/usb/devices/*/power/autosuspend_delay_ms; do
            write_if "$d" 2000
        done
        for d in /sys/bus/usb/devices/*/power/control; do
            write_if "$d" auto
        done

        # Network devices: prefer autosuspend where available
        for dev in /sys/class/net/*; do
            if [ -e "$dev/device/power/autosuspend_delay_ms" ]; then
                write_if "$dev/device/power/autosuspend_delay_ms" 2000
            fi
            if [ -e "$dev/device/power/control" ]; then
                write_if "$dev/device/power/control" auto
            fi
        done

        # MMC/SD cards: allow autosuspend where supported
        for d in /sys/bus/mmc/devices/*/power/autosuspend_delay_ms; do
            write_if "$d" 2000
        done
        for d in /sys/bus/mmc/devices/*/power/control; do
            write_if "$d" auto
        done

        # Bluetooth (if present)
        for d in /sys/class/bluetooth/*/device/power/control; do
            write_if "$d" auto
        done

        # Ensure cpuidle deepest states are enabled (for each CPU)
        for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
            # On newer kernels cpuidle state names may include 'name' files; prefer to only touch disable nodes
            for s in "$cpu"/cpuidle/state*/disable; do
                # if file exists, clear disable (set 0) to enable the state
                # Avoid forcing states closed if vendor policy hides deepest state; only write if writable
                if [ -w "$s" ]; then
                    write_if "$s" 0
                fi
            done
        done

        # Lower conservative min freq for small cluster if available (non-destructive)
        for cpuf in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do
            # Only set if present and higher than 400000
            if [ -f "$cpuf" ]; then
                cur=$(cat "$cpuf" 2>/dev/null || echo 0)
                if [ "$cur" -gt 400000 ]; then
                    write_if "$cpuf" 384000
                fi
            fi
        done

        # Enable device autosuspend (global helper)
        if [ -e /sys/module/usbcore/parameters/autosuspend ]; then
            write_if /sys/module/usbcore/parameters/autosuspend 2
        fi

        [ "$SYSFS_OK" -eq 1 ] && log "deepsleep settings applied" || log "No deepsleep-capable sysfs nodes found"
        ;;
    disable)
        log "Restoring default (performance-friendly) settings..."

        # Revert many controls to 'on' or '0' so devices stay active by default
        for d in /sys/bus/usb/devices/*/power/control; do
            write_if "$d" on
        done
        for d in /sys/bus/usb/devices/*/power/autosuspend_delay_ms; do
            write_if "$d" 0
        done
        for dev in /sys/class/net/*; do
            if [ -e "$dev/device/power/control" ]; then
                write_if "$dev/device/power/control" on
            fi
            if [ -e "$dev/device/power/autosuspend_delay_ms" ]; then
                write_if "$dev/device/power/autosuspend_delay_ms" 0
            fi
        done

        # Allow cpuidle policy unchanged; do not force-enable deep states when disabling
        log "deepsleep settings cleared"
        ;;
    status)
        echo "--- deepsleep candidate sysfs checks ---"
        echo "USB autosuspend entries:"
        ls -1 /sys/bus/usb/devices/*/power/control 2>/dev/null | head -n 20 || true
        echo "CPU idle state disable flags (showing first CPU):"
        for s in /sys/devices/system/cpu/cpu0/cpuidle/state*/disable; do
            echo "$s: $(cat $s 2>/dev/null || echo N/A)"
        done
        ;;
    *)
        echo "Usage: $0 {enable|disable|status}" >&2
        exit 2
        ;;
esac

exit 0
