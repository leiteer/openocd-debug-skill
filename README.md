# OpenOCD Universal Debug Skill

Universal OpenOCD debugging skill for WorkBuddy AI assistant. Supports **all ARM Cortex-M chips** and **all major debug probes**.

## 🎯 Features

- **Universal chip support**: STM32 (F0/G0/F1/F2/F3/F4/F7/G4/H7/L0/L1/L4/L5/U5/WB/WL), NXP (i.MX RT/Kinetis/LPC), Nordic (nRF51/52/53/91), TI, Atmel SAM, GigaDevice, Nuvoton, ESP32, RP2040, RISC-V
- **All major probes**: ST-LINK (V1/V2/V2-1/V3), J-Link (EDU/BASE/PLUS/PRO), CMSIS-DAP (v1/v2), FTDI (FT2232H/FT232H), Raspberry Pi GPIO, and more
- **4 debugging workflows**:
  1. Flash firmware
  2. Read/modify registers
  3. Mass erase (unlock locked chips)
  4. GDB remote debugging

## 📦 Installation

### Prerequisites

- OpenOCD installed (included in Zephyr SDK or install separately)
- Debug probe connected to target board

### Install via WorkBuddy

```bash
# In WorkBuddy, ask AI to install the skill
"Install openocd-debug-skill from GitHub"
```

Or manually:
```bash
# Clone to WorkBuddy skills directory
git clone https://github.com/YOUR_USERNAME/openocd-debug-skill.git \
  ~/.workbuddy/skills/openocd-debug-skill/
```

## 🚀 Usage

After installation, just ask WorkBuddy AI:

```
"Flash my firmware.elf to STM32F407 using ST-LINK"
"Read GPIOA registers on my nRF52840"
"My STM32F103 is locked, mass erase it"
"Debug STM32H7 with J-Link GDB server"
```

The AI will automatically:
1. Detect your chip and probe
2. Generate correct OpenOCD commands
3. Execute and explain results

## 📚 Documentation

### Quick Reference

| Command | Description |
|---------|-------------|
| `mdw addr [count]` | Read 32-bit memory words |
| `mww addr value` | Write 32-bit memory word |
| `reg` | Dump all CPU registers |
| `reset halt` | Reset and halt CPU |
| `reset run` | Reset and run |
| `halt` | Halt running CPU |
| `step` | Single-step instruction |
| `bp addr` | Set breakpoint |
| `wp addr` | Set watchpoint |

### Supported Chips

See [chip_targets.md](references/chip_targets.md) for complete list of target configs.

### Supported Probes

See [probe_configs.md](references/probe_configs.md) for interface configs and speed limits.

### Register Debugging Guide

See [register_guide.md](references/register_guide.md) for:
- How to find peripheral addresses from datasheets
- Cortex-M standard register map (SCB/NVIC/SysTick)
- Common peripheral layouts (GPIO/UART/SPI/I2C/TIM)
- Fault diagnosis (CFSR/HFSR/MMFAR/BFAR)

## 🛠️ Scripts Included

| Script | Purpose |
|--------|---------|
| `scripts/flash_fw.sh` | Universal firmware flashing (accepts interface + target as args) |
| `scripts/mass_erase.sh` | Mass erase with auto-detect (20+ chip families) |
| `scripts/read_regs.sh` | Interactive register read with command reference |
| `scripts/find_scripts.sh` | Auto-detect OpenOCD scripts directory |

## 🔧 Manual OpenOCD Commands

### Flash firmware
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "program firmware.elf verify reset exit"
```

### Read registers
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "init; reset halt; mdw 0x40020000 16; shutdown"
```

### GDB debugging
```bash
# Terminal 1: Start OpenOCD GDB server
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg

# Terminal 2: Connect with GDB
arm-none-eabi-gdb firmware.elf
(gdb) target remote localhost:3333
(gdb) monitor reset halt
(gdb) continue
```

## 🐛 Troubleshooting

### ST-LINK not detected
- Check USB connection
- Try different USB port
- Install ST-LINK drivers: https://www.st.com/en/development-tools/stsw-link009.html

### Flash write timeout
- MCU may be in HardFault loop
- Use `connect_assert_srst` mode:
  ```bash
  openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
    -c "reset_config srst_only connect_assert_srst" \
    -c "adapter speed 500" -c "init" -c "halt" \
    -c "flash write_image erase firmware.elf" -c "reset run" -c "shutdown"
  ```

### Mass erase fails
- Some chips require `connect_assert_srst`
- Check if chip is read-protected (RDP level > 0)
- Try lower SWD speed: `adapter speed 100`

## 📖 Learn More

- OpenOCD Official Docs: https://openocd.org/doc/doxygen/html/index.html
- OpenOCD Config Files: `/usr/share/openocd/scripts/` (Linux) or check with `find_scripts.sh`
- STM32 Reference Manuals: https://www.st.com/en/microcontrollers-microprocessors/stm32-32-bit-arm-cortex-mcus.html

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repo
2. Add support for more chips/probes
3. Improve documentation
4. Submit pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## ✨ Author

Created by Embedded Debugging Enthusiasts for WorkBuddy AI assistant.

---

**⚠️ Disclaimer**: This skill is for development/debugging purposes. Always backup your firmware before mass erase or flash operations.
