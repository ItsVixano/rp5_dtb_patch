#!/bin/bash

# Extract boot
rm -rf _boot.img.extracted patched-boot.img
(mkdir _boot.img.extracted; cd _boot.img.extracted; ../bin/magiskboot unpack -h ../boot.img)

## START PATCHES
# Cleanup boot.img cmdline header
new_cmdline="androidboot.hardware=qcom androidboot.memcg=1 lpm_levels.sleep_disabled=1 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 loop.max_part=7 cgroup.memory=nokmem,nosocket reboot=panic_warm buildvariant=user"
sed -i "s|^cmdline=.*|cmdline=${new_cmdline}|" _boot.img.extracted/header
# Apply device-tree overlay
kona_dtb="_boot.img.extracted/dtb"
dtc -q -@ -I dts -O dtb -o kona-overlay.dto kona-overlay.dts
fdtoverlay -i $kona_dtb -o $kona_dtb kona-overlay.dto
# Overclock the GPU (905 MHz) (part 2)
fdtput -r $kona_dtb \
    /soc/gpu-opp-table_v2/opp-670000000 \
    /soc/gpu-opp-table_v2/opp-587000000 \
    /soc/gpu-opp-table_v2/opp-525000000 \
    /soc/gpu-opp-table_v2/opp-490000000
fdtput -d $kona_dtb /soc/qcom,kgsl-3d0@3d00000/qcom,gpu-pwrlevel-bins/qcom,gpu-pwrlevels-0/qcom,gpu-pwrlevel@7 qcom,bus-freq
fdtput -d $kona_dtb /soc/qcom,kgsl-3d0@3d00000/qcom,gpu-pwrlevel-bins/qcom,gpu-pwrlevels-0/qcom,gpu-pwrlevel@7 qcom,bus-min
fdtput -d $kona_dtb /soc/qcom,kgsl-3d0@3d00000/qcom,gpu-pwrlevel-bins/qcom,gpu-pwrlevels-0/qcom,gpu-pwrlevel@7 qcom,bus-max
# Disable watchdog during suspend
fdtput -d $kona_dtb /soc/qcom,wdt@17c10000 qcom,wakeup-enable
# Remove display ramdump memory region
fdtput -r $kona_dtb /reserved-memory/disp_rdump_region@9c000000
# Disable PASR
fdtput -r $kona_dtb /mem-offline
# disable coresight for kona
fdtput -r $kona_dtb \
    /soc/replicator@6046000 \
    /soc/replicator@6b06000 \
    /soc/dummy_sink \
    /soc/tmc@6b05000 \
    /soc/funnel@6b04000 \
    /soc/tpda@6b08000 \
    /soc/tpdm@6b09000 \
    /soc/tpdm@6b0a000 \
    /soc/tmc@6048000 \
    /soc/funnel@6045000 \
    /soc/stm@6002000 \
    /soc/csr@6001000 \
    /soc/csr@6b0c000 \
    /soc/funnel@6041000 \
    /soc/funnel@6042000 \
    /soc/funnel@6902000 \
    /soc/tpdm@6900000 \
    /soc/tpda@6004000 \
    /soc/tpdm@6870000 \
    /soc/tpdm@6840000 \
    /soc/tpdm@684c000 \
    /soc/tpdm@6850000 \
    /soc/funnel@6846000 \
    /soc/tpdm@6844000 \
    /soc/tpdm@6ac0000 \
    /soc/tpdm@6b26000 \
    /soc/tpda@6ac1000 \
    /soc/funnel@69c2000 \
    /soc/tpda@69c1000 \
    /soc/tpdm@69c0000 \
    /soc/funnel@6ac2000 \
    /soc/funnel@6c39000 \
    /soc/tpdm@6c47000 \
    /soc/tpdm@6c40000 \
    /soc/tpdm@6c41000 \
    /soc/funnel@6c2d000 \
    /soc/tpdm@6c28000 \
    /soc/tpdm@6c29000 \
    /soc/tpdm@69d0000 \
    /soc/tpda@7863000 \
    /soc/tpdm@78a0000 \
    /soc/tpdm@78b0000 \
    /soc/tpdm@7860000 \
    /soc/tpdm@7861000 \
    /soc/funnel@6c0b000 \
    /soc/funnel@6832000 \
    /soc/tpdm@6830000 \
    /soc/tpdm@6c60000 \
    /soc/tpdm@6c08000 \
    /soc/funnel@6c44000 \
    /soc/funnel@6983000 \
    /soc/tpdm@6980000 \
    /soc/tpdm@69810000 \
    /soc/funnel@6e04000 \
    /soc/funnel@6e12000 \
    /soc/funnel@6e22000 \
    /soc/tpdm@6e10000 \
    /soc/tpdm@6e20000 \
    /soc/tpdm@6e00000 \
    /soc/funnel@6005000 \
    /soc/cti@78e0000 \
    /soc/cti@78f0000 \
    /soc/cti@7900000 \
    /soc/cti@6e01000 \
    /soc/cti@6e02000 \
    /soc/cti@6e03000 \
    /soc/cti@6e0c000 \
    /soc/cti@6e0d000 \
    /soc/cti@6e0e000 \
    /soc/cti@6e11000 \
    /soc/cti@6e21000 \
    /soc/cti@6c09000 \
    /soc/cti@6c0a000 \
    /soc/cti@6c2a000 \
    /soc/cti@6c2b000 \
    /soc/cti@6c2c000 \
    /soc/cti@6010000 \
    /soc/cti@6011000 \
    /soc/cti@6012000 \
    /soc/cti@6013000 \
    /soc/cti@6014000 \
    /soc/cti@6015000 \
    /soc/cti@6016000 \
    /soc/cti@6017000 \
    /soc/cti@6018000 \
    /soc/cti@6019000 \
    /soc/cti@601a000 \
    /soc/cti@601b000 \
    /soc/cti@601c000 \
    /soc/cti@601d000 \
    /soc/cti@601e000 \
    /soc/cti@601f000 \
    /soc/cti@7020000 \
    /soc/cti@7120000 \
    /soc/cti@7220000 \
    /soc/cti@7320000 \
    /soc/cti@7420000 \
    /soc/cti@7520000 \
    /soc/cti@7620000 \
    /soc/cti@7720000 \
    /soc/cti@6962000 \
    /soc/cti@6961000 \
    /soc/cti@6831000 \
    /soc/cti@6845000 \
    /soc/cti@6b21000 \
    /soc/cti@6b2b000 \
    /soc/cti@6c61000 \
    /soc/cti@6c42000 \
    /soc/cti@6c43000 \
    /soc/cti@6c4b000 \
    /soc/cti@6c13000 \
    /soc/cti@6b40000 \
    /soc/cti@6b4b000 \
    /soc/cti@6b41000 \
    /soc/cti@6b4e000 \
    /soc/cti@6b00000 \
    /soc/cti@6b01000 \
    /soc/cti@6b02000 \
    /soc/cti@6b03000 \
    /soc/cti@6982000 \
    /soc/cti@698b000 \
    /soc/cti@6c38000 \
    /soc/tgu@6b0b000 \
    /soc/turing_etm0 \
    /soc/audio_etm0 \
    /soc/ssc_etm0 \
    /soc/npu_etm0 \
    /soc/funnel@7810000 \
    /soc/etm@7040000 \
    /soc/etm@7140000 \
    /soc/etm@7240000 \
    /soc/etm@7340000 \
    /soc/etm@7440000 \
    /soc/etm@7540000 \
    /soc/etm@7640000 \
    /soc/etm@7740000 \
    /soc/funnel@7800000 \
    /soc/hwevent
## END PATCHES

# Repack boot
(cd _boot.img.extracted; ../bin/magiskboot repack ../boot.img ../patched-boot.img)
