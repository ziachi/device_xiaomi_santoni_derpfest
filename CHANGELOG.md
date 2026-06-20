# Changelog — DerpFest 13 Santoni

All notable changes to this device tree are documented here.

## [v4] — 2026-06-20

### Integrate Luuvy C.4.0 prebuilt kernel (#14)

**Problem:**
- Source-compiled kernel (msm8937 4.9) lacks Luuvy-specific optimizations
- Old Spectrum profiles used interactive governor (not optimal for Luuvy kernel)

**Fix:**
- Switch to Luuvy C.4.0 EOL prebuilt `Image.gz-dtb`
- Replace Spectrum profiles with Luuvy native profiles:
  - Balance: schedutil + GPU msm-adreno-tz
  - Performance: performance governor + GPU performance
  - Battery: powersave + GPU powersave
  - Gaming: performance + GPU msm-adreno-tz (higher GPU floor)
- Property chain: `persist.spectrum.profile` → `persist.luuvy.profile` → tuning
- FKU (Franco Kernel Manager) bridge supported
- ZRAM: 2 GB fixed (was fstab 50%)
- SELinux: init sysfs writes (gpu, cpu freq, zram, workqueue)

**Files:**
- BoardConfig.mk, device.mk, prebuilt/Image.gz-dtb
- rootdir/init.spectrum.rc, rootdir/init.spectrum.sh
- sepolicy/vendor/init.te, sepolicy/vendor/property_contexts

**Impact:**
- Better kernel performance with Luuvy-optimized tuning per profile
- QS tile continues to work via property bridge

---


### Fix prebuilt kernel build (#16)

**Problem:**
- 3 build errors when using prebuilt kernel:
  1. `generated_kernel_includes` needs `TARGET_KERNEL_SOURCE` for kernel headers
  2. `kernel.mk` enforces `TARGET_KERNEL_CONFIG` even with prebuilt
  3. SEPolicy neverallow: init cannot write generic `sysfs` or `execute_no_trans`

**Fix:**
- `TARGET_FORCE_PREBUILT_KERNEL := true` (skip source compile, use prebuilt)
- Created `sysfs_workqueue` SELinux type + genfscon label
- Removed `init.spectrum.sh` (set default profile via setprop in .rc)
- Removed `vendor_shell_exec` `execute_no_trans` rule

**Files:**
- BoardConfig.mk, device.mk, rootdir/init.spectrum.rc
- rootdir/init.spectrum.sh (deleted)
- sepolicy/vendor/init.te, sysfs_workqueue.te, genfs_contexts

**Impact:**
- Build compiles successfully with prebuilt Luuvy kernel

---


## [v3] — 2026-06-20

### Fix blank screen after bootanimation (#10)

**Problem:**
- After bootanimation, device stuck on blank screen (FallbackHome)
- Settings.Global.DEVICE_PROVISIONED never set to 1
- NikGapps Core (Play Store + Play Services only) has no Setup Wizard
- AOSP Provision app exists but FallbackHome intercepts HOME intent first

**Fix:**
- Set ro.setupwizard.mode=OPTIONAL in system.prop
- System auto-provisions when no Setup Wizard found

**Files:**
- system.prop

**Impact:**
- Device boots to homescreen instead of blank screen (with or without GApps)

---

### Disable LiveDisplay HAL (#11)

**Problem:**
- vendor.lineage.livedisplay@2.0::IDisplayModes/default not registered
- hwservicemanager polls every 1 second infinitely (491+ times in logcat)
- MSM8937 does not have SDM LiveDisplay HAL support

**Fix:**
- Remove LiveDisplay HAL block from manifest.xml
- Remove vendor.lineage.livedisplay@2.0-service-sdm from device.mk

**Files:**
- configs/manifests/manifest.xml
- device.mk

**Impact:**
- Eliminates infinite HAL polling, reduces CPU waste and log spam

---

### Fix SystemUI Reticker crash (frameworks/base)

**Problem:**
- RetickerAnimations.revealAnimationHide() calls createCircularReveal() on detached view
- IllegalStateException: Cannot start this animator on a detached view!
- SystemUI crashes once on boot then auto-restarts

**Fix:**
- Add isAttachedToWindow() guard before createCircularReveal()
- Skip animation and set visibility directly when view is detached

**Files:**
- frameworks/base/packages/SystemUI/src/com/android/systemui/RetickerAnimations.java

**Impact:**
- Prevents SystemUI crash during notification ticker animation

---

## [v2] — 2026-06-20

### Add Spectrum kernel profiles (#8)

**Problem:**
- No kernel performance profile switching from UI

**Fix:**
- Added Spectrum kernel profile system with QS tile (frameworks/base fork)
- 4 profiles: Balance, Performance, Battery, Gaming
- Tuning per profile: CPU governor/freq, GPU clock/governor, I/O scheduler, VM params, core control, LPM
- All values tuned for MSM8937 (Snapdragon 435)

**Files:**
- `rootdir/init.spectrum.rc` — 4 kernel profile trigger blocks
- `device.mk` — include init.spectrum.rc
- `system.prop` — `persist.spectrum.kernel=1`, `persist.spectrum.profile=0`
- `sepolicy/vendor/property_contexts` — `persist.spectrum.` property context
- `sepolicy/vendor/platform_app.te` — QS tile property access
- `frameworks/base` fork: `SpectrumTile.java`, icons, strings, Dagger binding

**Impact:**
- Users can switch kernel profiles from Quick Settings panel

---

### Fix bootloop - use AOSP power HAL (#7)

**Problem:**
- `system_server` hangs waiting for `android.hardware.power.IPower/default` AIDL service
- QTI power HAL AIDL v3 incompatible with MSM8937 kernel 4.9
- Watchdog kills system_server after 3+ min → zygote restart → bootloop

**Fix:**
- Replace `android.hardware.power-service-qti` with `android.hardware.power-service.example` (AOSP stub HAL)
- Same concept proven on MSM8937 in other projects

**Files:**
- `device.mk`

**Impact:**
- Fixes bootloop, system boots to launcher

---


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
