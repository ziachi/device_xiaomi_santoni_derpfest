# LiveDisplay HAL Infinite Polling

## Symptom
Logcat flooded with (every 1 second, indefinitely):
```
hwservicemanager: Since vendor.lineage.livedisplay@2.0::IDisplayModes/default is not registered, trying to start it as a lazy HAL.
```
491+ occurrences in a single boot logcat. Wastes CPU cycles and floods log buffer.

## Root Cause
Device manifest (configs/manifests/manifest.xml) declares LiveDisplay HAL:
```xml
<hal format="hidl">
    <name>vendor.lineage.livedisplay</name>
    <version>2.0</version>
    <interface><name>IDisplayModes</name><instance>default</instance></interface>
    <interface><name>IPictureAdjustment</name><instance>default</instance></interface>
</hal>
```

And device.mk includes the service binary:
```
vendor.lineage.livedisplay@2.0-service-sdm
```

But MSM8937 (Snapdragon 435) does NOT support the SDM (Snapdragon Display Manager)
LiveDisplay backend. The service binary starts but fails to register the HAL.
hwservicemanager sees it declared in manifest but not registered, so it keeps polling.

## Fix
Remove LiveDisplay HAL from both manifest and device.mk. MSM8937 does not have
the hardware backing for SDM display modes/picture adjustment.

## Lessons
- Only declare HALs in device manifest if the hardware actually supports them
- LiveDisplay SDM requires Snapdragon 600+ series (SDM630+) with proper display stack
- Undeclared HALs that are also not packaged will not cause polling — the issue is the manifest declaring what does not exist
