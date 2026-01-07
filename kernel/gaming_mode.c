// SPDX-License-Identifier: GPL-2.0
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/sysctl.h>
#include <linux/init.h>
#include <net/tcp.h>
#include <linux/sched/sysctl.h>
#include <net/sock.h>

/* normalized_sysctl_sched_latency is defined in kernel/sched/fair.c */
extern unsigned int normalized_sysctl_sched_latency;

/* Fast charge override - drivers may check this exported variable */
int fast_charge_boost;
EXPORT_SYMBOL(fast_charge_boost);

int gaming_mode;
int uclamp_enable = 1;               /* enable uclamp helper */
int uclamp_boost_percent = 20;      /* additional boost applied (percent) */
int uclamp_bucket_default = 0;      /* default bucket index (0 = disabled) */
int uclamp_bucket0 = 0;             /* bucket values scaled 0..1024 */
int uclamp_bucket1 = 128;
int uclamp_bucket2 = 256;
int uclamp_bucket3 = 512;
static int old_tcp_slow_start_after_idle;
static unsigned int old_sched_latency;
static unsigned int old_normalized_sched_latency;
static unsigned int old_min_granularity;

static void apply_gaming_mode(bool enable)
{
    if (enable) {
        /* save and apply */
        old_tcp_slow_start_after_idle = sysctl_tcp_slow_start_after_idle;
        old_sched_latency = sysctl_sched_latency;
        old_normalized_sched_latency = normalized_sysctl_sched_latency;
        old_min_granularity = sysctl_sched_min_granularity;

        sysctl_tcp_slow_start_after_idle = 0;
        sysctl_sched_latency = 6000000U; /* 6ms */
        normalized_sysctl_sched_latency = 6000000U;
        sysctl_sched_min_granularity = 600000U; /* 0.6ms */

        pr_info("gaming_mode: enabled - applied low-latency networking/sched tweaks\n");
    } else {
        /* restore */
        sysctl_tcp_slow_start_after_idle = old_tcp_slow_start_after_idle;
        sysctl_sched_latency = old_sched_latency;
        normalized_sysctl_sched_latency = old_normalized_sched_latency;
        sysctl_sched_min_granularity = old_min_granularity;

        pr_info("gaming_mode: disabled - restored previous settings\n");
    }
}

static int gaming_mode_handler(struct ctl_table *table, int write,
                               void __user *buffer, size_t *lenp,
                               loff_t *ppos)
{
    int ret, old = gaming_mode;

    ret = proc_dointvec(table, write, buffer, lenp, ppos);
    if (ret != 0)
        return ret;

    if (write) {
        if (gaming_mode && !old)
            apply_gaming_mode(true);
        else if (!gaming_mode && old)
            apply_gaming_mode(false);
    }
    return 0;
}

static struct ctl_table gaming_table[] = {
    {
        .procname = "gaming_mode",
        .data = &gaming_mode,
        .maxlen = sizeof(int),
        .mode = 0644,
        .proc_handler = gaming_mode_handler,
    },
    {
        .procname = "fast_charge_boost",
        .data = &fast_charge_boost,
        .maxlen = sizeof(int),
        .mode = 0644,
        .proc_handler = proc_dointvec,
    },
    {
        .procname = "uclamp_enable",
        .data = &uclamp_enable,
        .maxlen = sizeof(int),
        .mode = 0644,
        .proc_handler = proc_dointvec,
    },
    {
        .procname = "uclamp_boost_percent",
        .data = &uclamp_boost_percent,
        .maxlen = sizeof(int),
        .mode = 0644,
        .proc_handler = proc_dointvec,
    },
    {
        .procname = "uclamp_bucket_default",
        .data = &uclamp_bucket_default,
        .maxlen = sizeof(int),
        .mode = 0644,
        .proc_handler = proc_dointvec,
    },
    {
        .procname = "uclamp_bucket0",
        .data = &uclamp_bucket0,
        .maxlen = sizeof(int),
        .mode = 0644,
        .proc_handler = proc_dointvec,
    },
    {
        .procname = "uclamp_bucket1",
        .data = &uclamp_bucket1,
        .maxlen = sizeof(int),
        .mode = 0644,
        .proc_handler = proc_dointvec,
    },
    {
        .procname = "uclamp_bucket2",
        .data = &uclamp_bucket2,
        .maxlen = sizeof(int),
        .mode = 0644,
        .proc_handler = proc_dointvec,
    },
    {
        .procname = "uclamp_bucket3",
        .data = &uclamp_bucket3,
        .maxlen = sizeof(int),
        .mode = 0644,
        .proc_handler = proc_dointvec,
    },
    { }
};

static struct ctl_table gaming_dir[] = {
    {
        .procname = "gaming",
        .mode = 0555,
        .child = gaming_table,
    },
    { }
};

static struct ctl_table_header *gaming_sysctl_header;

static int __init gaming_mode_init(void)
{
    gaming_sysctl_header = register_sysctl_table(gaming_dir);
    if (!gaming_sysctl_header) {
        pr_err("gaming_mode: failed to register sysctl table\n");
        return -ENOMEM;
    }

    pr_info("gaming_mode: sysctl registered at /proc/sys/gaming/\n");
    return 0;
}
module_init(gaming_mode_init);

static void __exit gaming_mode_exit(void)
{
    if (gaming_sysctl_header)
        unregister_sysctl_table(gaming_sysctl_header);

    /* restore if still enabled */
    if (gaming_mode)
        apply_gaming_mode(false);

    pr_info("gaming_mode: unloaded\n");
}
module_exit(gaming_mode_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("GitHub Copilot");
MODULE_DESCRIPTION("Simple gaming mode sysctl (low-impact tweaks for latency and fast charge override)");
