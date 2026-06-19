# ld Linker Missing in Sbox Sandbox

## Problem
Build failed at ~40%:
```
clang-14: error: unable to execute command: Executable "ld" doesn't exist!
```
Error occurred inside sbox sandbox during kernel header generation and other build steps.

## Root Cause
AOSP build-tools ships `ld.lld` but not `ld`. Some build rules (especially kernel-related) invoke the linker as `ld`. The sbox sandbox restricts PATH to `prebuilts/build-tools/path/linux-x86/`, so system `ld` is not available.

## Solution
Create symlink in build-tools path:
```bash
ln -sf ld.lld prebuilts/build-tools/path/linux-x86/ld
```
Also needed in `out/.path/` (generated path directory).

**Note:** Symlinks may be lost after `make clean` or certain build system regenerations — check if they exist before each build.

## Lessons
- Sbox sandboxes have restricted PATH — cannot rely on system binaries
- AOSP assumes `ld.lld` is the default, but some targets still call `ld`
- This is a local workaround, not committed to any repo
