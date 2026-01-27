# Deployment & Testing Guide for linux-5.10.y Backports

## Quick Start

### 1. Checkout the Backport Branch
```bash
git checkout backport-5.10-patches
```

### 2. Verify Branch
```bash
git log --oneline -10
git diff --stat origin/main
```

## Building the Kernel

### Prerequisites
- Clang toolchain available at `../clang-r574158`
- ARM gcc toolchain available
- Build dependencies installed

### Build Command
```bash
./build.sh
```

Or for manual build:
```bash
make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- \
  CC=clang CLANG_TRIPLE=aarch64-linux-gnu- defconfig

make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- \
  CC=clang CLANG_TRIPLE=aarch64-linux-gnu- -j$(nproc)
```

## Testing Recommendations

### Phase 1: Build Verification
1. Ensure kernel compiles without errors
2. Check for warnings in modified files
3. Verify module compilation if applicable

### Phase 2: Boot Testing
Test on Surya device (Snapdragon 732G):
1. Flash compiled kernel
2. Boot device and check for panics
3. Monitor kernel logs: `adb logcat | grep -i kernel`

### Phase 3: Functional Testing

#### Networking Tests
- WiFi connectivity
- Ethernet/USB networking (if applicable)
- Network throughput
- Connection stability under load

#### Wireless Tests
- WiFi scan and connection
- Signal strength reporting
- Roaming between access points
- WiFi power management

#### Stability Tests
- System under load (CPU stress test)
- Memory stability (e.g., memtester)
- Thermal behavior
- Battery impact

#### Storage Tests
- F2FS filesystem operations
- File read/write speed
- Device hotplug

### Phase 4: Security Validation
Test that security patches are working:
1. Check for hardened usercopy protection
2. Verify memory leak fixes don't affect performance
3. Test buffer overflow protections

## Rollback Procedure

If issues occur:

```bash
# Switch back to main branch
git checkout main

# Rebuild
./build.sh
```

## Integration Steps

### If All Tests Pass

1. **Merge into main** (optional):
   ```bash
   git checkout main
   git merge backport-5.10-patches
   ```

2. **Create a release tag**:
   ```bash
   git tag -a v4.14.356-5.10-backport -m "Kernel 4.14 with 5.10.y backports"
   git push origin v4.14.356-5.10-backport
   ```

3. **Document changes**:
   - Update device documentation
   - Note kernel version in release notes
   - List major improvements

## Performance Considerations

### Expected Impact
- Minimal performance impact (patches are mostly security/stability)
- Possible slight overhead from UAF/OOB protections
- Improved network stability may offset any overhead

### Benchmarking
If performance is critical:
```bash
# Run benchmarks on both kernels and compare
# Focus on: network throughput, storage I/O, memory latency
```

## Troubleshooting

### Build Errors
1. Check toolchain paths in build.sh
2. Ensure all cross-compilation tools are available
3. Review detailed build logs

### Runtime Issues
1. Check kernel logs for errors
2. Cross-reference with BACKPORT_NOTES.md for patch details
3. Check if missing dependencies were required

### Performance Regressions
1. Profile before and after
2. Review specific patches that might cause overhead
3. Consider reverting specific patches if necessary

## Maintenance Notes

### Future Kernel Updates
- If upgrading to newer kernel versions, these patches may become obsolete
- Check patch applicability before upgrading
- Consider rebasing on newer stable branches

### Patch Tracking
- Refer to BACKPORT_NOTES.md for complete patch list
- Refer to FAILED_PATCHES.md for patches that couldn't be applied
- Document any additional fixes needed

## Support Resources

### For Questions About Specific Patches
- Upstream commits: https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/
- Linux kernel mailing lists (LKML)
- Check patch author information in git log

### For Kernel Debugging
- kernel.org documentation
- Android kernel documentation
- Device-specific documentation from Qualcomm

## Checklist

- [ ] Branch checked out
- [ ] Kernel builds successfully
- [ ] Device boots without panics
- [ ] Networking functional
- [ ] Wireless functional
- [ ] No obvious performance regressions
- [ ] System stable under load
- [ ] All critical features working

## Timeline Recommendation

1. **Day 1**: Build and initial testing
2. **Day 2**: Functional testing (network, wireless)
3. **Day 3**: Stability and stress testing
4. **Day 4**: Performance benchmarking
5. **Day 5+**: Integration and release

