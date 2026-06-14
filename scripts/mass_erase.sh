#!/usr/bin/env bash
# ============================================================
# OpenOCD Mass Erase — Universal (any chip, any probe)
# 整片擦除 Flash，用于芯片"变砖"（卡 HardFault）时的恢复
#
# 用法:
#   ./mass_erase.sh <interface> <target> [scripts_dir] [force]
#
# 示例:
#   ./mass_erase.sh stlink stm32f4x
#   ./mass_erase.sh cmsis-dap nrf52 /usr/share/openocd/scripts yes
#   ./mass_erase.sh jlink imxrt1060
#
# 注意: 擦除后芯片为空，需要重新烧录固件
#
# Mass erase 命令因芯片而异。脚本会尝试常见变体，
# 如果失败会提示手动指定正确的命令。
# ============================================================
set -euo pipefail

INTERFACE="${1:?Usage: mass_erase.sh <interface> <target> [scripts_dir] [force]}"
TARGET="${2:?Missing target config}"
FORCE="${4:-no}"

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

# --- Mass erase command auto-detection ---
# Maps target config names to known mass_erase commands.
# Falls back to generic patterns if not found.
get_erase_cmd() {
    case "${TARGET,,}" in
        # STM32 families
        stm32f0x|stm32f1x|stm32f2x|stm32f3x|stm32f4x|stm32f7x)
            echo "stm32f2x mass_erase 0" ;;
        stm32g0x|stm32g4x)
            echo "stm32g0x mass_erase 0" ;;
        stm32h7*|stm32h74*)
            echo "stm32h7x mass_erase 0" ;;
        stm32l0)
            echo "stm32l0 mass_erase 0" ;;
        stm32l1)
            echo "stm32l1 mass_erase 0" ;;
        stm32l4*)
            echo "stm32l4x mass_erase 0" ;;
        stm32l5*)
            echo "stm32l5x mass_erase 0" ;;
        stm32u5*)
            echo "stm32u5x mass_erase 0" ;;
        stm32wb*)
            echo "stm32wbx mass_erase 0" ;;
        stm32wl*)
            echo "stm32wlx mass_erase 0" ;;
        # Nordic
        nrf51)
            echo "nrf51 mass_erase" ;;
        nrf52|nrf52832|nrf52840)
            echo "nrf52 mass_erase" ;;
        nrf53*)
            echo "nrf53 mass_erase" ;;
        nrf91*)
            echo "nrf91 mass_erase" ;;
        # NXP
        imxrt10*|imxrt105*|imxrt106*)
            echo "imxrt mass_erase 0" ;;
        imxrt11*|imxrt117*)
            echo "imxrt mass_erase 0" ;;
        kinetis|kx|klx)
            echo "kinetis mass_erase 0" ;;
        lpc*)
            echo "lpc2000 mass_erase 0" ;;
        # Atmel / Microchip
        atsamd21|atsamd51|atsame*|atsamv*|atsams*)
            echo "atsamv mass_erase 0" ;;
        # GigaDevice
        gd32*)
            echo "gd32vf103 mass_erase 0" ;;
        # RP2040
        rp2040)
            echo "rp2040 mass_erase 0" ;;
        *)
            # Generic fallback — will likely fail but better than nothing
            echo "flash erase_sector 0 0 11" ;;
    esac
}

ERASE_CMD=$(get_erase_cmd)

# --- scripts dir ---
find_scripts_dir() {
    if [ -n "${3:-}" ] && [ -d "${3}" ]; then echo "${3}"; return; fi
    for sdk in "$HOME/zephyr-sdk-"* "/opt/zephyr-sdk-"* "D:/Zephyr/zephyr-sdk-"*; do
        local c=$(ls -d "$sdk"/sysroots/*/usr/share/openocd/scripts 2>/dev/null | head -1)
        if [ -n "${c:-}" ] && [ -d "$c" ]; then echo "$c"; return; fi
    done
    for dir in /usr/share/openocd/scripts /usr/local/share/openocd/scripts /mingw64/share/openocd/scripts; do
        if [ -d "$dir" ]; then echo "$dir"; return; fi
    done
    if [ -n "${OPENOCD_SCRIPTS:-}" ] && [ -d "$OPENOCD_SCRIPTS" ]; then echo "$OPENOCD_SCRIPTS"; return; fi
    echo ""
}

OPENOCD_SCRIPTS=$(find_scripts_dir)
if [ -z "$OPENOCD_SCRIPTS" ]; then
    echo "ERROR: Cannot find OpenOCD scripts directory."
    exit 1
fi

echo "============================================"
echo " OpenOCD Mass Erase (UNIVERSAL)"
echo "============================================"
echo " WARNING: This will ERASE ALL flash content!"
echo " Probe    : ${INTERFACE} (${IFACE_CFG})"
echo " Target   : ${TARGET}"
echo " Command  : ${ERASE_CMD}"
echo " Scripts  : ${OPENOCD_SCRIPTS}"
echo "============================================"

if [ "$FORCE" != "yes" ]; then
    echo ""
    echo "Run with 'yes' as the last argument to proceed:"
    echo "  ./mass_erase.sh ${INTERFACE} ${TARGET} [scripts_dir] yes"
    echo "Or press Ctrl+C to cancel."
    read -rp "Type 'ERASE' to confirm: " answer
    if [ "$answer" != "ERASE" ]; then
        echo "Cancelled."
        exit 0
    fi
fi

echo ""
echo "Erasing..."

openocd \
    -s "${OPENOCD_SCRIPTS}" \
    -f "${IFACE_CFG}" \
    -f "${TARGET_CFG}" \
    -c "adapter speed 100" \
    -c "init" \
    -c "sleep 200" \
    -c "halt" \
    -c "${ERASE_CMD}" \
    -c "shutdown"

echo ""
echo "Mass erase complete. Flash is now blank."
echo "Run flash_fw.sh to flash new firmware."
echo ""
echo "If the erase command was wrong for your chip, find the"
echo "correct command by starting an interactive session and"
echo "running 'flash banks' to see the flash driver name."
