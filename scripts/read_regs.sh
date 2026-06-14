#!/usr/bin/env bash
# ============================================================
# OpenOCD Interactive Register Reader — Universal (any chip)
#
# 用法:
#   ./read_regs.sh <interface> <target> [scripts_dir]
#
# 示例:
#   ./read_regs.sh stlink stm32f4x
#   ./read_regs.sh cmsis-dap nrf52
#
# 启动后会进入 OpenOCD 交互模式，可以直接输入:
#   mdw <addr>      — 读 32 位寄存器
#   mdh <addr>      — 读 16 位寄存器
#   mdb <addr>      — 读 8 位寄存器
#   reg pc          — 读程序计数器
#   reg sp          — 读栈指针
#   mdw 0xE000ED28  — 读 CFSR (故障状态)
#   mdw 0xE000ED2C  — 读 HFSR (HardFault 状态)
#   targets         — 列出目标芯片
#   flash banks     — 列出 Flash bank
#   resume          — 继续运行
#   shutdown        — 退出
# ============================================================
set -euo pipefail

INTERFACE="${1:?Usage: read_regs.sh <interface> <target> [scripts_dir]}"
TARGET="${2:?Missing target config}"

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
echo " OpenOCD Register Reader (UNIVERSAL)"
echo "============================================"
echo " Probe    : ${INTERFACE}"
echo " Target   : ${TARGET}"
echo " Scripts  : ${OPENOCD_SCRIPTS}"
echo "============================================"
echo ""
echo "=== OpenOCD Command Reference ==="
echo ""
echo "--- Memory Access ---"
echo "  mdw <addr> [count]    Read 32-bit word(s)"
echo "  mdh <addr> [count]    Read 16-bit half-word(s)"
echo "  mdb <addr> [count]    Read 8-bit byte(s)"
echo "  mww <addr> <val>      Write 32-bit word"
echo "  mwh <addr> <val>      Write 16-bit half-word"
echo "  mwb <addr> <val>      Write 8-bit byte"
echo ""
echo "--- CPU Registers ---"
echo "  reg                   Dump ALL registers"
echo "  reg pc                Program Counter"
echo "  reg sp                Stack Pointer"
echo "  reg lr                Link Register"
echo "  reg xPSR              Program Status Register"
echo "  reg msp/psp           Stack Pointers (RTOS)"
echo ""
echo "--- Cortex-M Fault Diagnosis (ALL vendors) ---"
echo "  mdw 0xE000ED28        CFSR — WHAT fault?"
echo "  mdw 0xE000ED2C        HFSR — HardFault forced?"
echo "  mdw 0xE000ED34        MMFAR — MemManage fault address"
echo "  mdw 0xE000ED38        BFAR — BusFault address"
echo "  mdw 0xE000ED24        SHCSR — fault handler enabled?"
echo ""
echo "--- Control ---"
echo "  targets               List connected targets"
echo "  flash banks           List flash banks"
echo "  halt                  Halt CPU"
echo "  resume                Resume execution"
echo "  step [n]              Single-step n instructions"
echo "  reset halt            Reset and halt"
echo "  adapter speed 100     Change adapter speed (kHz)"
echo "  shutdown              Exit OpenOCD"
echo ""
echo "=== Session starting... ==="
echo ""

openocd \
    -s "${OPENOCD_SCRIPTS}" \
    -f "${IFACE_CFG}" \
    -f "${TARGET_CFG}" \
    -c "reset_config srst_only connect_assert_srst" \
    -c "adapter speed 500" \
    -c "init" \
    -c "sleep 200" \
    -c "halt"
