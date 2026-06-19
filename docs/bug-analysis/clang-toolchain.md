# Clang Toolchain Not Found

## Problem
Build failed at kernel compilation:
```
zyc_clang/bin/clang: not found
```

## Root Cause
Device tree was adapted from RisingOS which uses custom `zyc_clang` toolchain. DerpFest AOSP source only ships standard AOSP clang in `prebuilts/clang/host/linux-x86/`.

Original BoardConfig.mk:
```makefile
TARGET_KERNEL_CLANG_VERSION := zyc_clang
TARGET_KERNEL_CLANG_PATH := $(shell pwd)/prebuilts/clang/host/linux-x86/$(TARGET_KERNEL_CLANG_VERSION)
TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(TARGET_KERNEL_CLANG_PATH)/bin/aarch64-linux-gnu-
TARGET_KERNEL_CROSS_COMPILE_ARM32_PREFIX := $(TARGET_KERNEL_CLANG_PATH)/bin/arm-linux-gnueabi-
```

## Solution
Switch to AOSP clang and remove custom paths:
```makefile
TARGET_KERNEL_CLANG_VERSION := r450784d
```
AOSP build system auto-resolves the clang path and cross-compile prefixes.

**Note:** First attempt used `clang-r450784d` which resolved to `clang-clang-r450784d` (double prefix). Correct value is just `r450784d`.

## Lessons
- When adapting device trees between ROMs, always check toolchain availability
- AOSP clang version = directory name under `prebuilts/clang/host/linux-x86/` (without `clang-` prefix)
- Custom cross-compile paths not needed — AOSP build system handles it
