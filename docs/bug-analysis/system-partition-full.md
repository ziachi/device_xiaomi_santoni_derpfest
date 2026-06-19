# System Partition Full (3GB Limit)

## Problem
Build failed at 99% during system image packaging:
```
e2fsdroid: Could not allocate block in ext2 filesystem while writing file "TouchGestures.apk"
Tree size: 3040 MB, max image size: 3072 MB (3GB partition)
```

## Root Cause
Santoni has a fixed 3GB system partition (legacy A-only layout). DerpFest 13 with full GApps (`WITH_GMS := true`) produces a system image that exceeds 3GB:
- GApps total: ~1.5 GB in `product/app` + `product/priv-app`
- Top consumers: Velvet (340MB), Photos (127MB), GmsCore (121MB), Gboard (82MB)
- System + product + system_ext all packed into the single system partition

## Solution
Set `WITH_GMS := false` in `derp_santoni.mk` — vanilla build without GApps.
- Required wrapping GMS inherit in `ifeq` conditional in `vendor/derp/config/common.mk` (local change, not committed)
- Users flash GApps separately via recovery (Pico/Nano recommended for 3GB partition)

## Result
- System image: ~1.5 GB (down from 3040 MB) — fits comfortably in 3GB partition
- Final ZIP: 885 MB

## Lessons
- Devices with <=3GB system partition cannot fit full GApps built-in
- Always check `BOARD_SYSTEMIMAGE_PARTITION_SIZE` vs expected system image size before first build
- DerpFest `common.mk` hardcodes `WITH_GMS := true` — needs conditional wrapper for vanilla builds
