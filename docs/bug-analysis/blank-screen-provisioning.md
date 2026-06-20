# Blank Screen After Bootanimation — FallbackHome Stuck

## Symptom
After bootanimation ends, device shows blank black screen. No homescreen, no launcher. Not a bootloop — device is fully booted (Boot is finished in logcat at ~113s).

## Root Cause
FallbackHome (from Settings app) is displayed because Settings.Global.DEVICE_PROVISIONED is never set to 1.

### Why Provisioning Fails
1. Vanilla build has Provision app (AOSP, auto-sets provisioned=1)
2. User flashes NikGapps Core (Play Store + Play Services only, NO Setup Wizard)
3. NikGapps adds google.xml sysconfig expecting Google Setup Wizard
4. Google Setup Wizard not installed — provisioning never completes
5. FallbackHome checks DEVICE_PROVISIONED, finds 0, shows blank screen forever

### Key Logcat Evidence
```
RoleControllerServiceImpl: Adding package as default/fallback role holder, package: com.android.provision, role: android.app.role.HOME
ActivityTaskManager: START u0 {...FallbackHome...}
DefaultPermGrantPolicy: Permission not found: com.google.android.setupwizard.SETUP_PROGRESS_SERVICE
DefaultPermGrantPolicy: Permission not found: com.google.android.setupwizard.SETUP_COMPAT_SERVICE
DefaultPermGrantPolicy: No such package: com.google.android.apps.setupwizard.searchselector
KeyguardViewMediator: ICC_ABSENT isn't showing, we need to show the keyguard since the device isn't provisioned yet.
```

### Important Distinction
DEVICE_PROVISIONED=1 in system.prop sets a system property (SystemProperties.get).
This is NOT the same as Settings.Global.DEVICE_PROVISIONED which is in the settings database.
FallbackHome checks the Settings database value, not the system property.

## Fix
Set ro.setupwizard.mode=OPTIONAL in system.prop:
- If Setup Wizard exists, it runs normally
- If no Setup Wizard, system auto-provisions (device_provisioned=1) and launches real launcher
- Works with or without GApps

## Lessons
- DerpFest (and most Lineage-based ROMs) do NOT include their own Setup Wizard
- NikGapps Core does NOT include Google Setup Wizard either
- Always set ro.setupwizard.mode=OPTIONAL for vanilla builds to handle both scenarios
