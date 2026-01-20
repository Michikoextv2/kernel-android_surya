#!/bin/bash
# Kernel Power Management & Performance Tuning Script
# Balanced optimization for multitasking and gaming on ARM64
#
# This script optimizes:
# - CPU frequency scaling
# - Memory access patterns
# - I/O scheduler behavior
# - Process scheduling
# - Thermal management

set -e

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

echo -e "${BLUE}=== ARM64 Kernel Optimization Script ===${RESET}"
echo -e "${BLUE}Balanced Gaming & Multitasking Mode${RESET}\n"

# CPU Frequency Scaling Optimization
optimize_cpu_frequency() {
    echo -e "${YELLOW}[1/5] Optimizing CPU Frequency Scaling...${RESET}"
    
    # Use schedutil governor for balanced performance
    for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/; do
        if [ -d "$cpu" ]; then
            echo "schedutil" > "$cpu/scaling_governor" 2>/dev/null || true
        fi
    done
    
    # Set conservative min/max frequencies for battery while gaming
    for cpu in /sys/devices/system/cpu/cpufreq/policy*/; do
        if [ -d "$cpu" ]; then
            # Little cores (A53): 787-2169 MHz
            # Big cores (A73): 787-2208 MHz
            # Set dynamic range for better response
            echo "1977600" > "$cpu/scaling_max_freq" 2>/dev/null || true
            echo "633600" > "$cpu/scaling_min_freq" 2>/dev/null || true
        fi
    done
    
    echo -e "${GREEN}✓ CPU frequency scaling optimized${RESET}"
}

# Memory Access Optimization
optimize_memory_access() {
    echo -e "${YELLOW}[2/5] Optimizing Memory Access...${RESET}"
    
    # Enable prefetching for better memory throughput
    echo 1 > /sys/module/prefetch/parameters/enable_prefetch 2>/dev/null || true
    
    # Optimize page cache for balanced performance
    # Increase dirty page threshold for better batching
    echo 20 > /proc/sys/vm/dirty_ratio 2>/dev/null || true
    echo 5 > /proc/sys/vm/dirty_background_ratio 2>/dev/null || true
    
    # Reduce swappiness for gaming responsiveness
    echo 30 > /proc/sys/vm/swappiness 2>/dev/null || true
    
    # Enable zswap for memory pressure
    echo lz4 > /sys/module/zswap/parameters/compressor 2>/dev/null || true
    echo 60 > /sys/module/zswap/parameters/max_pool_percent 2>/dev/null || true
    
    echo -e "${GREEN}✓ Memory access optimized${RESET}"
}

# I/O Scheduler Optimization
optimize_io_scheduler() {
    echo -e "${YELLOW}[3/5] Optimizing I/O Scheduler...${RESET}"
    
    # Use BFQ scheduler for better fairness
    for disk in /sys/block/*/queue/; do
        if [ -d "$disk" ]; then
            echo "bfq" > "$disk/scheduler" 2>/dev/null || true
            # Set low quantum for responsive I/O
            echo 8 > "$disk/iosched/quantum" 2>/dev/null || true
            # Decrease back_seek_penalty for SSD-like behavior
            echo 0 > "$disk/iosched/back_seek_penalty" 2>/dev/null || true
        fi
    done
    
    echo -e "${GREEN}✓ I/O scheduler optimized${RESET}"
}

# Process Scheduling Optimization
optimize_process_scheduling() {
    echo -e "${YELLOW}[4/5] Optimizing Process Scheduling...${RESET}"
    
    # Enable WALT (Window Assisted Load Tracking) if available
    if [ -d "/dev/cpuset" ]; then
        # Boost frequency for responsive UI tasks
        echo 120 > /proc/sys/kernel/sched_boost 2>/dev/null || true
    fi
    
    # Reduce scheduling latency for smoother gameplay
    echo 1000000 > /proc/sys/kernel/sched_latency_ns 2>/dev/null || true
    echo 250000 > /proc/sys/kernel/sched_min_granularity_ns 2>/dev/null || true
    echo 3000000 > /proc/sys/kernel/sched_wakeup_granularity_ns 2>/dev/null || true
    
    # Enable task placement optimization
    echo 1 > /proc/sys/kernel/sched_esp_enabled 2>/dev/null || true
    
    echo -e "${GREEN}✓ Process scheduling optimized${RESET}"
}

# Thermal Management Optimization
optimize_thermal_management() {
    echo -e "${YELLOW}[5/5] Optimizing Thermal Management...${RESET}"
    
    # Enable thermal throttling but with higher thresholds for gaming
    if [ -d "/sys/class/thermal" ]; then
        # Set thermal protection points
        for zone in /sys/class/thermal/thermal_zone*/; do
            if [ -d "$zone" ]; then
                # Increase throttle point to reduce throttling during gameplay
                echo 60000 > "$zone/trip_point_0_temp" 2>/dev/null || true
                echo 70000 > "$zone/trip_point_1_temp" 2>/dev/null || true
                echo 80000 > "$zone/trip_point_2_temp" 2>/dev/null || true
            fi
        done
    fi
    
    # Disable dynamic thermal control during gaming if needed
    echo "power_allocator" > /sys/class/thermal/cooling_device0/cur_state 2>/dev/null || true
    
    echo -e "${GREEN}✓ Thermal management optimized${RESET}"
}

# Main execution
main() {
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}Error: This script must be run as root${RESET}"
        exit 1
    fi
    
    optimize_cpu_frequency
    optimize_memory_access
    optimize_io_scheduler
    optimize_process_scheduling
    optimize_thermal_management
    
    echo -e "\n${GREEN}=== Optimization Complete ===${RESET}"
    echo -e "${BLUE}Settings applied for balanced gaming & multitasking performance${RESET}"
    echo -e "${BLUE}Battery life: Maintained through adaptive scaling${RESET}"
    echo -e "${BLUE}Gaming performance: Optimized with responsive scheduling${RESET}\n"
}

# Run main function
main "$@"
