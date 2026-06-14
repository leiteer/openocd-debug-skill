#!/usr/bin/env bash
# ============================================================
# OpenOCD Flash Firmware — Universal (any chip, any probe)
# 内置 HardFault 恢复: connect_assert_srst 在连接瞬间拉低 NRST
#
# 用法:
#   ./flash_fw.sh <elf_path> <interface> <target> [scripts_dir] [speed]
#
# 示例:
#   ./flash_fw.sh build/zephyr/zephyr.elf stlink stm32f4x
#   ./flash_fw.sh firmware.elf cmsis-dap nrf52 /usr/share/openocd/scripts 1000
#   ./flash_fw.sh firmware.bin jlink imxrt1060
#
# 参数:
#   elf_path  — .elf / .bin / .hex 固件路径 (必需)
#   interface — 调试探针: stlink, cmsis-dap, jlink, ft2232 等 (必需)
#   target    — 芯片型号: stm32f4x, nrf52, imxrt1060, gd32f4xx 等 (必需)
#   scripts_dir — OpenOCD scripts 目录 (可选, 自动查找)
#   speed     — 适配器速度 kHz (可选, 默认 500)
# ============================================================
set -euo pipefail

ELF="${1:?Usage: flash_fw.sh <elf_path> <interface> <target> [scripts_dir] [speed]}"
INTERFACE="${2:?Missing: interface type (stlink, cmsis-dap, jlink, ...)}"
TARGET="${3:?Missing: target config (stm32f4x, nrf52, imxrt1060, ...)}"

# --- probe config auto-detection ---
get_interface_cfg() {
    case "${INTERFACE,,}" in
        stlink|stlink-v2|stlink-v2-1|stlink-v3) echo "interface/stlink.cfg" ;;
        cmsis-dap|cmsisdap|daplink) echo "interface/cmsis-dap.cfg" ;;
        jlink|j-link) echo "interface/jlink.cfg" ;;
        ft2232|ftdi) echo "interface/ftdi/ft2232h.cfg" ;;
        *) echo "interface/${INTERFACE}.cfg" ;;
    esac
}

IFACE_CFG=$(get_interface_cfg)
TARGET_CFG="target/${TARGET}.cfg"

# --- scripts directory discovery ---
find_scripts_dir() {
    local candidate=""
    # 1. Explicit path
    if [ -n "${4:-}" ]; then
        echo "$4"
        return
    fi
    # 2. Zephyr SDK (highest priority for Zephyr users)
    for sdk in "$HOME/zephyr-sdk-"* "/opt/zephyr-sdk-"* "D:/Zephyr/zephyr-sdk-"*; do
        candidate=$(ls -d "$sdk"/sysroots/*/usr/share/openocd/scripts 2>/dev/null | head -1)
        if [ -d "$candidate" ]; then echo "$candidate"; return; fi
    done
    # 3. System install
    for dir in /usr/share/openocd/scripts /usr/local/share/openocd/scripts /mingw64/share/openocd/scripts; do
        if [ -d "$dir" ]; then echo "$dir"; return; fi
    done
    # 4. $OPENOCD_SCRIPTS env var
    if [ -n "${OPENOCD_SCRIPTS:-}" ] && [ -d "$OPENOCD_SCRIPTS" ]; then
        echo "$OPENOCD_SCRIPTS"
        return
    fi
    echo ""
}

OPENOCD_SCRIPTS=$(find_scripts_dir)
if [ -z "$OPENOCD_SCRIPTS" ]; then
    echo "ERROR: Cannot find OpenOCD scripts directory."
    echo "Set OPENOCD_SCRIPTS env var or pass as 4th argument."
    exit 1
fi

# Verify configs exist
if [ ! -f "$OPENOCD_SCRIPTS/$IFACE_CFG" ]; then
    echo "ERROR: Interface config not found: $OPENOCD_SCRIPTS/$IFACE_CFG"
    echo "Available interfaces:"
    ls "$OPENOCD_SCRIPTS/interface/" | grep -v "^Makefile" || true
    exit 1
fi
if [ ! -f "$OPENOCD_SCRIPTS/$TARGET_CFG" ]; then
    echo "ERROR: Target config not found: $OPENOCD_SCRIPTS/$TARGET_CFG"
    echo "Available targets (filtered):"
    ls "$OPENOCD_SCRIPTS/target/" | grep -v "^Makefile\|^test\|^xilinx\|^altera" | head -30
    echo "... run 'ls $OPENOCD_SCRIPTS/target/' to see all"
    exit 1
fi

SPEED="${5:-500}"

echo "=== OpenOCD Universal Flash ==="
echo "Probe     : ${INTERFACE}  (${IFACE_CFG})"
echo "Target    : ${TARGET}  (${TARGET_CFG})"
echo "Firmware  : ${ELF}"
echo "Speed     : ${SPEED} kHz"
echo "Scripts   : ${OPENOCD_SCRIPTS}"
echo ""

openocd \
    -s "${OPENOCD_SCRIPTS}" \
    -f "${IFACE_CFG}" \
    -f "${TARGET_CFG}" \
    -c "reset_config srst_only connect_assert_srst" \
    -c "adapter speed ${SPEED}" \
    -c "init" \
    -c "sleep 200" \
    -c "halt" \
    -c "flash write_image erase ${ELF}" \
    -c "reset run" \
    -c "shutdown"

echo ""
echo "Flash complete. Board should be running."
