# AOSP Calendar FragmentManager Type Mismatch

## Problem
Vanilla build (without GApps) failed compiling AOSP Calendar:
```
GeneralPreferences.kt:142:14: error: none of the following functions can be called with the arguments supplied:
public open fun show(p0: FragmentManager, p1: String?): Unit
```

## Root Cause
With GApps enabled, `CalendarGooglePrebuilt` replaces AOSP Calendar. Without GApps, AOSP Calendar is built instead, but it has a bug:
- `GeneralPreferences.kt` imports `android.app.FragmentManager` (deprecated)
- `TimeZonePickerDialog` extends `androidx.fragment.app.DialogFragment`
- `show()` method expects `androidx.fragment.app.FragmentManager`
- Type mismatch: old API vs AndroidX

## Solution
In `packages/apps/Calendar/src/com/android/calendar/GeneralPreferences.kt`:
```kotlin
// Changed import
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentActivity

// Changed calls (class extends PreferenceFragment, not AndroidX)
val fm: FragmentManager = (activity as FragmentActivity).supportFragmentManager
```

Cast `activity` to `FragmentActivity` to access `supportFragmentManager`.

**Note:** This is a local AOSP source fix, not committed to device tree repos.

## Lessons
- Vanilla builds expose bugs hidden by GApps prebuilts
- AOSP apps may have broken AndroidX migrations that are never caught because Google prebuilts replace them
- Always test vanilla build separately
