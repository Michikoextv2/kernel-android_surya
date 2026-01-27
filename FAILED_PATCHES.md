# Failed/Skipped Patches from linux-5.10.y

This document lists patches that could not be directly backported to kernel 4.14.

## Patches with Conflicts (Would require manual conflict resolution)

| Commit | Title | Reason |
|--------|-------|--------|
| ccde2b7ac396 | powercap: fix race condition in register_control_type() | File structure changed |
| c4896f5fd836 | bpf, sockmap: Don't let sock_map_{close,destroy,unhash} call itself | API changes |
| 27202452b0bc | ext4: fix out-of-bound read in ext4_xattr_inode_dec_ref_all() | Complex ext4 structure |
| e7e1d15d2bd8 | btrfs: do not clean up repair bio if submit fails | Btrfs refactored |
| 9af0f5987d23 | lockd: fix vfs_test_lock() calls | Multiple file conflicts |
| 49bcbe531f79 | net/mlx5e: Avoid field-overflowing memcpy() | Driver restructured |
| 4c49e86fdcbb | i40e: fix scheduling in set_rx_mode | I40e driver changes |
| b957366f5611 | mlxsw: spectrum_mr: Fix use-after-free when updating multicast route stats | File deleted |
| 34147477eeab | net: atlantic: fix fragment overflow handling in RX path | Atlantic driver changes |
| ac171c3c7554 | net: sxgbe: fix potential NULL dereference in sxgbe_rx() | Status unclear |
| 10c16687513e | net/mlx5e: Fix validation logic in rate limiting | MLX5 refactoring |
| 7ae9de859590 | net: aquantia: Add missing descriptor cache invalidation on ATL2 | ATL2 file deleted |
| 43fb1cf4e781 | efi/cper: Fix cper_bits_to_str buffer handling and return value | EFI changes |
| 5397ea6d21c3 | net: usb: pegasus: fix memory leak in update_eth_regs_async() | Already applied |
| 02ac5975f06f | powercap: fix sscanf() error return value handling | Already applied |
| 88dd6be7ebb3 | net: sock: fix hardened usercopy panic in sock_recv_errqueue | Already applied |

## Patches with Missing Files

| Commit | Title | Reason |
|--------|-------|--------|
| 5522e64e4ff7 | lib/crypto: aes: Fix missing MMU protection for AES S-box | lib/crypto/aes.c missing |
| bd1dcfba72aa | cpufreq: scmi: Fix null-ptr-deref in scmi_cpufreq_get_rate() | scmi-cpufreq.c deleted |
| 49b4a4e2a8d3 | PCI: brcmstb: Fix disabling L0s capability | pcie-brcmstb.c deleted |
| 01324c032818 | powerpc/64s/slb: Fix SLB multihit issue during SLB preload | Multiple files deleted |
| 073cc1466ea9 | media: mediatek: vcodec: Fix a reference leak in mtk_vcodec_fw_vpu_init() | mtk_vcodec_fw_vpu.c deleted |
| 96fa4c8c3b31 | drm/msm/a6xx: Fix out of bound IO access in a6xx_get_gmu_registers | a6xx_gpu_state.c deleted |
| f98cf0ccc112 | xhci: dbgtty: fix device unregister | xhci-dbgtty.c deleted |

## Patches with Complex Dependencies

| Commit | Title | Reason |
|--------|-------|--------|
| 886db0c506f3 | NFS: add barriers when testing for NFS_FSDATA_BLOCKED | NFS changes |
| 2972aec3bf4f | NFS: unlink/rmdir shouldn't call d_delete() twice on ENOENT | NFS changes |
| ca97360860eb | nfsd: provide locking for v4_end_grace | NFSD refactoring |
| 24ba80efaf6e | blk-throttle: Set BIO_THROTTLED when bio has been throttled | Block layer changes |
| 281f713d73f5 | NFS: Fix up the automount fs_context to use the correct cred | NFS refactoring |
| 06081bae0cc8 | scsi: Revert "scsi: libsas: Fix exp-attached device scan after probe failure" | SAS changes |
| e1e8f554d86c | usb: gadget: lpc32xx_udc: fix clock imbalance in error path | LPC32xx changes |
| 25504f7fe600 | net: ethtool: fix the error condition in ethtool_get_phy_stats_ethtool() | ethtool changes |
| f210ea4e7a79 | scsi: core: ufs: Fix a hang in the error handler | UFS refactoring |
| 816b2eac151a | Revert "iommu/amd: Skip enabling command/event buffers for kdump" | AMD IOMMU changes |
| 688247af779a | pwm: bcm2835: Make sure the channel is enabled after pwm_request() | BCM2835 changes |
| 81b098aab86f | drm/gma500: Remove unused helper psb_fbdev_fb_setcolreg() | GMA500 changes |
| 690665ec52ea | f2fs: fix to propagate error from f2fs_enable_checkpoint() | F2FS refactoring |
| 9480d7449b9f | f2fs: fix to detect recoverable inode during dryrun of find_fsync_dnodes() | F2FS refactoring |
| 6d90a061c091 | xfs: fix a memory leak in xfs_buf_item_init() | XFS changes |
| 52ac96c4a2dd | ext4: fix string copying in parse_apply_sb_mount_options() | ext4 changes |
| 97c6be8df3c1 | ASoC: stm32: sai: fix clk prepare imbalance on probe failure | STM32 SAI changes |
| 3332212e93d0 | drm/vmwgfx: Fix error handling | VMWGFX changes |
| 2d12774ca5ce | virtio_console: fix order of fields cols and rows | virtio_console changes |
| ba467b6870ea | RDMA/core: Fix "KASAN: slab-use-after-free Read in ib_register_device" | RDMA changes |
| 9f152cad3cc0 | mm/balloon_compaction: we cannot have isolated pages in the balloon list | balloon_compaction changes |
| 590665ec52ea | f2fs: fix to propagate error from f2fs_enable_checkpoint() | F2FS changes |
| c104478fc92c | iommu/qcom: fix device leak on of_xlate() | QCOM IOMMU changes |
| e125c8e346e4 | crypto: af_alg - zero initialize memory allocated via sock_kmalloc | AF_ALG changes |
| a8f1e445ce35 | SUNRPC: svcauth_gss: avoid NULL deref on zero length gss_token | SUNRPC changes |
| 9f48638b2f7e | jbd2: fix the inconsistency between checksum and data in memory | JBD2 changes |

## Recommendations

To backport these patches, you would need to:

1. **For file conflicts**: Manually resolve conflicts in the conflicting files
2. **For missing files**: Check if functionality exists in different form in 4.14, or implement equivalent fixes
3. **For complex dependencies**: Backport prerequisite patches first
4. **For deleted files**: Determine if the subsystem has been refactored and find equivalent code locations

## Statistics

- **Total attempted**: ~100+ patches
- **Successfully backported**: 35 patches
- **Failed/Conflicted**: ~65 patches
- **Success rate**: ~35%

This is a normal success rate when backporting from newer to much older kernels due to API changes and structural refactoring.

