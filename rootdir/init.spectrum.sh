#!/system/bin/sh
# Spectrum Kernel Manager — Luuvy Kernel C.4.0
# Profile initialization script

if [ "$(cat /proc/version | grep -c Luuvy)" -eq "1" ]; then
   # Enable Spectrum profile support
   setprop spectrum.support 1
   # Enable Franco Kernel Manager support
   setprop fku.profiles 1
   # Add kernel name
   setprop persist.spectrum.kernel Luuvy.C.
   # Set default profile (Balance)
   setprop persist.spectrum.profile 0
fi
