# DerpFest 13 — Xiaomi Redmi 4X (santoni)

Device tree for building [DerpFest](https://github.com/DerpFest-AOSP) Android 13 for Xiaomi Redmi 4X (santoni).

## Repositories

| Component | Repository | Branch |
|:----------|:-----------|:-------|
| **Device Tree** | [ziachi/device_xiaomi_santoni_derpfest](https://github.com/ziachi/device_xiaomi_santoni_derpfest) | `derp-13-dev` |
| **Kernel** | [ziachi/kernel_xiaomi_msm8937_derpfest](https://github.com/ziachi/kernel_xiaomi_msm8937_derpfest) | `derp-13-dev` |
| **Vendor** | [ziachi/vendor_xiaomi_santoni_derpfest](https://github.com/ziachi/vendor_xiaomi_santoni_derpfest) | `derp-13-dev` |
| **Frameworks Base** | [ziachi/frameworks_base_derpfest](https://github.com/ziachi/frameworks_base_derpfest/tree/derp-13-dev) | `derp-13-dev` |

## Build Notes

- **Vanilla build** — no GApps included (3GB system partition too small)
- Flash GApps (Pico/Nano/Full) separately via recovery after installing ROM
- Uses AOSP clang `r450784d` for kernel compilation
- SELinux: **Enforcing**
- **Spectrum kernel profiles** — Balance, Performance, Battery, Gaming (QS tile)

## Spec Sheet

| Feature                 | Specification                     |
| :---------------------- | :-------------------------------- |
| CPU                     | Octa-core 1.4 GHz Cortex-A53      |
| Chipset                 | Qualcomm MSM8940 Snapdragon 435   |
| GPU                     | Adreno 505                        |
| Memory                  | 2/3 GB                            |
| Shipped Android Version | 6.0.1                             |
| Storage                 | 16/32 GB                          |
| MicroSD                 | Up to 256 GB                      |
| Battery                 | 4100 mAh (non-removable)          |
| Dimensions              | 139 x 69 x 8.65 mm                |
| Display                 | 720 x 1280 pixels, 5" (~294 PPI)   |
| Rear Camera             | 13 MP, LED flash                  |
| Front Camera            | 5 MP                              |
| Release Date            | May 2017                          |

## Setup Guide

### 1. Initialize DerpFest manifest

```bash
repo init -u https://github.com/DerpFest-AOSP/manifest.git -b 13 --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

### 2. Clone device repos

```bash
# Device tree
git clone -b derp-13-dev https://github.com/ziachi/device_xiaomi_santoni_derpfest.git \
  device/xiaomi/santoni

# Kernel
git clone -b derp-13-dev https://github.com/ziachi/kernel_xiaomi_msm8937_derpfest.git \
  kernel/xiaomi/msm8937

# Vendor
git clone -b derp-13-dev https://github.com/ziachi/vendor_xiaomi_santoni_derpfest.git \
  vendor/xiaomi/santoni
```

### 3. Build

```bash
source build/envsetup.sh
lunch derp_santoni-userdebug
mka derp
```

> **Note:** This is a vanilla build. Flash GApps package after installing the ROM ZIP.

## Device Picture

![Redmi 4X](https://cdn.tgdd.vn/Products/Images/42/99145/xiaomi-redmi-4x-400-400x460.png "Redmi 4X")

## Credits

- [androidsantoni](https://github.com/androidsantoni) — Original device tree (risingos-13-dev base)
- [DerpFest-AOSP](https://github.com/DerpFest-AOSP) — ROM source

## Changelog

See [CHANGELOG.md](CHANGELOG.md)
