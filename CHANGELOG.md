# Changelog — DerpFest 13 Santoni

All notable changes to this device tree are documented here.

## [v1] — 2026-06-20

### Fix duplicate sysprop error (#5)

**Problem:**
- `ro.adb.secure=0` and `ro.secure=0` in system.prop duplicate build system defaults → build error

**Fix:**
- Removed `ro.adb.secure=0` and `ro.secure=0` from system.prop
- `persist.sys.usb.config=mtp,adb` is sufficient for ADB by default

**Files:**
- `system.prop`

---

### Enable USB debugging by default (#3)

**Fix:**
- Added `persist.sys.usb.config=mtp,adb` — USB mode MTP + ADB
- Added `ro.adb.secure=0` — skip RSA authorization prompt  
- Added `ro.secure=0` — allow ADB root access

**Files:**
- `system.prop`

**Impact:**
- ADB ready immediately after boot, no manual setup needed

---

### Fix build for DerpFest 13 (#1)

**Problem:**
1. Build failed: `zyc_clang` not found in AOSP prebuilts
2. System partition full — system image 3040 MB > 3072 MB (3GB) partition limit with GApps

**Fix:**
1. Switch to AOSP clang (`r450784d`) instead of custom `zyc_clang`
2. Remove custom cross-compile paths (use AOSP defaults)
3. Set `WITH_GMS := false` — vanilla build (3GB partition too small for built-in GApps)

**Files:**
- `BoardConfig.mk` — AOSP clang r450784d, removed custom clang/cross-compile paths
- `derp_santoni.mk` — `WITH_GMS := false`

**Impact:**
- Build completes successfully (885 MB ZIP)
- Users flash GApps (Pico/Nano/Full) separately via recovery

---

## [v0] — 2026-06-19

### Initial device tree adaptation

- Adapted from [androidsantoni/device_xiaomi_santoni](https://github.com/androidsantoni/device_xiaomi_santoni) (RisingOS 13)
- Converted to DerpFest 13 conventions:
  - Lunch target: `derp_santoni-userdebug`
  - Vendor inherit: `vendor/derp/config/common_full_phone.mk`
  - Build target: `mka derp`
  - Buildtype: `Unofficial`
- Enabled Aperture camera, Face Unlock
- Disabled blur effects (low-end device)
