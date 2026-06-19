# Power HAL Bootloop — MSM8937

## Problem
DerpFest 13 build boots to bootanimation but never reaches launcher.
System stuck in bootloop: zygote → system_server → watchdog kill → repeat.

## Root Cause
PowerManagerService.nativeInit() blocks waiting for
android.hardware.power.IPower/default AIDL service.

The device tree ships android.hardware.power-service-qti (QTI AIDL v3 power HAL).
This binary exists in vendor/bin/hw/ and is declared in VINTF manifest, but the
service never starts on MSM8937:

```
Unable to set property "ctl.interface_start" error 0x20
```

ServiceManager finds the entry but can't lazy-start the service. After 3+ minutes
of PowerManagerService blocking, Watchdog kills system_server, which triggers
zygote restart → perpetual bootloop.

## Investigation
- Logcat: 8470 lines from logcat_bootloop.txt
- Key log lines:
  - PowerManagerService.nativeInit() → waiting for IPower/default
  - ServiceManager: find → found (lazy)
  - ServiceManager: Unable to set property "ctl.interface_start" error 0x20
  - Watchdog: WATCHDOG KILLING SYSTEM PROCESS
- ADB access: enabled via persist.sys.usb.config=mtp,adb in system.prop

## Solution
Replace QTI power HAL with AOSP stub HAL in device.mk:
- Remove: android.hardware.power-service-qti
- Add: android.hardware.power-service.example

The AOSP example power HAL provides a minimal AIDL implementation that satisfies
the PowerManagerService requirement without needing QTI-specific kernel interfaces.

## Why QTI HAL Fails on MSM8937
- QTI power HAL AIDL v3 expects modern kernel power interfaces
- MSM8937 (kernel 4.9) has older QTI power management sysfs nodes
- The AIDL service binary crashes or fails to register before system_server queries it
- ctl.interface_start property fails → service never comes online

## Lessons Learned
1. AIDL power HAL requires matching kernel support — old SoCs often can't run QTI AIDL v3
2. AOSP stub HAL is a safe fallback for legacy devices
3. persist.sys.usb.config=mtp,adb is critical — without it, can't get logcat from bootloop
4. Watchdog timeout → look for blocked native init calls
