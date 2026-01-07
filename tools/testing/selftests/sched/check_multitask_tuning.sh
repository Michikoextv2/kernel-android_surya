#!/bin/sh
# Simple runtime check for multitask tuning defaults.
# This script is non-fatal and intended for humans to inspect.
set -eu

KSYSCTL=/proc/sys/kernel
GAMING=/proc/sys/gaming

printf "Checking kernel scheduler tunables...\n"
if [ -r "$KSYSCTL/sched_latency_ns" ]; then
    latency=$(cat "$KSYSCTL/sched_latency_ns")
    min_gran=$(cat "$KSYSCTL/sched_min_granularity_ns" 2>/dev/null || echo "N/A")
    printf "  sched_latency_ns = %s\n" "$latency"
    printf "  sched_min_granularity_ns = %s\n" "$min_gran"
    if [ "$latency" != "N/A" ] && [ "$latency" -le 5000000 ]; then
        printf "  ✅ latency is <= 5 ms (expected conservative default).\n"
    else
        printf "  ⚠️ latency seems > 5 ms; platform may have different defaults.\n"
    fi
else
    printf "  ⚠️ %s/sched_latency_ns not available on this kernel.\n" "$KSYSCTL"
fi

if [ -d "$GAMING" ]; then
    printf "\n/proc/sys/gaming exists; runtime gaming tunables:\n"
    for f in "$GAMING"/*; do
        printf "  %s = %s\n" "$(basename "$f")" "$(cat "$f")"
    done
else
    printf "\n/proc/sys/gaming not found; kernel may not have CONFIG_GAMING_MODE enabled.\n"
fi

printf "\nNote: This script is informational; run benchmarks to validate changes on real hardware.\n"
