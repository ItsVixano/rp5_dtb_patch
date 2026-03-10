#!/bin/bash

# Extract boot
rm -rf _boot.img.extracted patched-boot.img
(mkdir _boot.img.extracted; cd _boot.img.extracted; ../bin/magiskboot unpack ../boot.img)

## START PATCHES
# Apply device-tree overlay
kona_dtb="_boot.img.extracted/dtb"
dtc -q -@ -I dts -O dtb -o kona-overlay.dto kona-overlay.dts
fdtoverlay -i $kona_dtb -o $kona_dtb kona-overlay.dto
# Overclock the GPU (905 MHz) (part 2)
fdtput -r $kona_dtb /soc/gpu-opp-table_v2/opp-670000000
fdtput -r $kona_dtb /soc/gpu-opp-table_v2/opp-587000000
fdtput -r $kona_dtb /soc/gpu-opp-table_v2/opp-525000000
fdtput -r $kona_dtb /soc/gpu-opp-table_v2/opp-490000000
fdtput -d $kona_dtb /soc/qcom,kgsl-3d0@3d00000/qcom,gpu-pwrlevel-bins/qcom,gpu-pwrlevels-0/qcom,gpu-pwrlevel@7 qcom,bus-freq
fdtput -d $kona_dtb /soc/qcom,kgsl-3d0@3d00000/qcom,gpu-pwrlevel-bins/qcom,gpu-pwrlevels-0/qcom,gpu-pwrlevel@7 qcom,bus-min
fdtput -d $kona_dtb /soc/qcom,kgsl-3d0@3d00000/qcom,gpu-pwrlevel-bins/qcom,gpu-pwrlevels-0/qcom,gpu-pwrlevel@7 qcom,bus-max
# Disable watchdog during suspend
fdtput -d $kona_dtb /soc/qcom,wdt@17c10000 qcom,wakeup-enable
# Remove display ramdump memory region
fdtput -r $kona_dtb /reserved-memory/disp_rdump_region@9c000000
## END PATCHES

# Repack boot
(cd _boot.img.extracted; ../bin/magiskboot repack ../boot.img ../patched-boot.img)
