#!/usr/bin/env bash
# ============================================================
# OpenOCD Scripts Directory Finder — cross-platform
#
# 用法:
#   ./find_scripts.sh
#
# 自动发现 OpenOCD scripts/ 目录。先查找 Zephyr SDK，
# 再查系统安装路径，最后尝试 locate/find。
# ============================================================

echo "=== Searching for OpenOCD scripts directory ==="
echo ""

found=0

# 1. Zephyr SDK
echo "[1/4] Checking Zephyr SDK..."
for sdk_base in "$HOME/zephyr-sdk-"* "/opt/zephyr-sdk-"* "D:/Zephyr/zephyr-sdk-"*; do
    for candidate in "$sdk_base"/sysroots/*/usr/share/openocd/scripts; do
        if [ -f "$candidate/interface/stlink.cfg" ] 2>/dev/null; then
            echo "  FOUND (Zephyr SDK): $candidate"
            found=1
        fi
    done
done
[ $found -eq 1 ] && echo ""

# 2. System package paths
echo "[2/4] Checking system paths..."
for dir in \
    /usr/share/openocd/scripts \
    /usr/local/share/openocd/scripts \
    /opt/openocd/share/openocd/scripts \
    /opt/homebrew/share/openocd/scripts \
    /mingw64/share/openocd/scripts \
    "C:/OpenOCD/share/openocd/scripts" \
    "C:/Program Files/OpenOCD/share/openocd/scripts"; do
    if [ -f "$dir/interface/stlink.cfg" ] 2>/dev/null; then
        echo "  FOUND: $dir"
        found=1
    fi
done
[ $found -eq 1 ] && echo ""

# 3. Environment variable
echo "[3/4] Checking OPENOCD_SCRIPTS env var..."
if [ -n "${OPENOCD_SCRIPTS:-}" ]; then
    if [ -f "$OPENOCD_SCRIPTS/interface/stlink.cfg" ] 2>/dev/null; then
        echo "  FOUND: $OPENOCD_SCRIPTS"
        found=1
    else
        echo "  OPENOCD_SCRIPTS=$OPENOCD_SCRIPTS but stlink.cfg not found there"
    fi
fi
[ $found -eq 1 ] && echo ""

# 4. locate/find (slow, last resort)
echo "[4/4] Filesystem search (if openocd is installed)..."
if command -v openocd &>/dev/null; then
    echo "  openocd found at: $(which openocd)"
    # Ask openocd where it thinks scripts are
    openocd --search 2>/dev/null | head -3 || true
fi

if [ $found -eq 0 ]; then
    echo ""
    echo "============================================"
    echo " NOT FOUND — Manual Setup Required"
    echo "============================================"
    echo ""
    echo "Install OpenOCD:"
    echo "  Linux:   sudo apt install openocd"
    echo "  macOS:   brew install openocd"
    echo "  Windows: Download from https://openocd.org/"
    echo "           or use Zephyr SDK (includes pre-built openocd)"
    echo ""
    echo "Then run this script again, or set:"
    echo "  export OPENOCD_SCRIPTS=/path/to/openocd/scripts"
fi

echo ""
echo "=== Done ==="
