# Luuvy Kernel C.4.0 Integration

## Overview
Replaced source-compiled kernel (msm8937 4.9) with Luuvy C.4.0 EOL prebuilt kernel.

**Source:** AnyKernel3 ZIP — `Luuvy-C.4.0.eol202601-santoni-Treble-2026-01-29-03.59.35.zip`
**Binary:** `Image.gz-dtb` (12 MB, kernel + DTB appended)

## Why Prebuilt?
- Luuvy kernel is a custom-tuned kernel for santoni with its own spectrum profiles
- Source not available (closed-source binary distribution)
- AnyKernel3 installer extracted, kernel binary integrated into device tree

## Spectrum Profiles (Luuvy Native)

| Profile | CPU Governor | GPU Min-Max | GPU Governor | Power Efficient |
|---------|-------------|-------------|--------------|-----------------|
| Balance | schedutil | 216-475 MHz | msm-adreno-tz | Y |
| Performance | performance | 300-475 MHz | performance | N |
| Battery | powersave | 216-450 MHz | powersave | Y |
| Gaming | performance | 375-475 MHz | msm-adreno-tz | N |

**Note:** CPU freq limits are SAME across all profiles (big 960-1401, little 768-1094).
Only governor, GPU settings, and power_efficient flag differ.

## Property Chain
```
QS Tile writes: persist.spectrum.profile (0/1/2/3)
    ↓ bridge in init.spectrum.rc
persist.luuvy.profile (balance/performance/battery/gaming)
    ↓ triggers Luuvy profile tuning
CPU/GPU/workqueue settings applied
```

FKU (Franco Kernel Manager) also bridges:
```
fku.perf.profile (0/1/2) → persist.spectrum.profile (2/0/1)
```

## ZRAM Configuration
- Luuvy sets 2 GB fixed (was fstab 50% = ~1 GB on 2GB device)
- Reset → disksize → mkswap → swapon sequence at boot

## SELinux
Original Luuvy installer uses magiskpolicy (43 allow rules at flash time).
For ROM build, added targeted rules to `sepolicy/vendor/init.te`:
- sysfs_gpu write (gpu_min_clock, gpu_max_clock)
- sysfs_devices_system_cpu setattr (chmod freq files)
- sysfs_kgsl setattr
- sysfs_zram write (reset, disksize)
- sysfs write (workqueue params)
- vendor_shell_exec (init.spectrum.sh)

## Integration Steps
1. Extract `Image.gz-dtb` from AnyKernel3 ZIP
2. Copy to `prebuilt/Image.gz-dtb`
3. BoardConfig.mk: `TARGET_PREBUILT_KERNEL`, disable source compile
4. Replace init.spectrum.rc with Luuvy's profiles (adapted for ROM)
5. Add init.spectrum.sh for kernel detection at boot
6. Update property_contexts for persist.luuvy., fku., spectrum.
7. SELinux rules in init.te

## Key Differences from Previous Spectrum
| | Old (source kernel) | New (Luuvy prebuilt) |
|---|---|---|
| Governor | interactive | schedutil/performance/powersave |
| CPU freq varies | Yes (per profile) | No (same limits, governor differs) |
| GPU tuning | Basic (max_gpuclk only) | Full (min_clock, max_clock, governor) |
| ZRAM | fstab 50% | 2 GB fixed |
| Core control | Yes | No (managed by kernel) |
| I/O scheduler | Per profile | Kernel default |
| VM tuning | Per profile | Kernel default |
