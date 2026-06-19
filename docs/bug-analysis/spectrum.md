# Spectrum Kernel Profiles — DerpFest 13 + MSM8937

## Overview
Spectrum is a kernel profile switching system that changes CPU, GPU, I/O, and
memory parameters at runtime via a QS (Quick Settings) tile.

## Architecture

### Property-based triggering
- QS tile sets persist.spectrum.profile (0-3)
- init.spectrum.rc has on property:persist.spectrum.profile=N triggers
- Each trigger writes to sysfs nodes for CPU/GPU/I/O/VM

### Components

| Component | Location | Purpose |
|-----------|----------|---------|
| SpectrumTile.java | frameworks/base fork | QS tile UI — cycles profiles on tap |
| init.spectrum.rc | device/xiaomi/santoni/rootdir/ | Kernel tuning per profile |
| system.prop | device tree | Default profile + kernel flag |
| SELinux policy | sepolicy/vendor/ | Property context + QS tile access |

### Profile Map (MSM8937)

| Profile | CPU Gov | Big Max | Little Max | GPU Max | GPU Gov | I/O | Swappiness |
|---------|---------|---------|------------|---------|---------|-----|------------|
| 0 Balance | interactive | 1401 MHz | 1094 MHz | 400 MHz | adreno-tz | bfq 128k | 80 |
| 1 Performance | interactive | 1497 MHz | 1209 MHz | 450 MHz | adreno-tz | bfq 256k | 60 |
| 2 Battery | interactive | 1209 MHz | 998 MHz | 400 MHz | adreno-tz | noop 64k | 100 |
| 3 Gaming | performance | 1497 MHz | 1209 MHz | 450 MHz | performance | deadline 512k | 20 |

### DerpFest QS Tile Pattern
- Tile class extends QSTileImpl with public static final String TILE_SPEC
- Registered via Dagger @Binds @IntoMap @StringKey in QSModuleDerpFest.kt
- Icons as vector drawables in res/drawable/
- Strings in res/values/derp_strings.xml
- Tile specs listed in res/values/config.xml

## SELinux
- persist.spectrum. → system_prop in property_contexts
- platform_app needs set_prop(platform_app, system_prop) for QS tile access
