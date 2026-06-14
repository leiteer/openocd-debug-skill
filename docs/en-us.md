# OpenOCD Universal Debug Skill - English Guide

Universal OpenOCD debugging skill for WorkBuddy AI Assistant. Supports all ARM Cortex-M chips and all major debug probes.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Installation](#installation)
4. [Quick Start](#quick-start)
5. [Supported Hardware](#supported-hardware)
6. [Debug Workflows](#debug-workflows)
7. [Command Reference](#command-reference)
8. [Fault Diagnosis](#fault-diagnosis)
9. [TCL Scripting](#tcl-scripting)
10. [Troubleshooting](#troubleshooting)

---

## Overview

This skill enables WorkBuddy AI to debug **any** microcontroller that OpenOCD supports:

- ✅ **All ARM Cortex-M**: STM32 (F0/F1/F2/F3/F4/F7/G0/G4/H7/L0/L1/L4/L5/U5/WB/WL/MP1), NXP (i.MX RT, Kinetis, LPC), Nordic (nRF51/52/53/91), TI (CC13xx/CC26xx/MSP432/TM4C), Atmel SAM, GigaDevice GD32, Nuvoton
- ✅ **RISC-V**: GD32V, ESP32-C3/S3/H2
- ✅ **All Debug Probes**: ST-LINK (V1/V2/V2-1/V3), J-Link (EDU/BASE/PLUS/PRO), CMSIS-DAP (v1/v2), FTDI (FT2232H/FT232H), Raspberry Pi GPIO, Remote Bitbang, Bus Pirate, xds110, ULINK

### Key Features

| Feature | Description |
|---------|-------------|
| **Flash Firmware** | Compile → Flash → Verify → Reset in one command |
| **Read Registers** | Interactive register browser with auto-discovery |
| **Mass Erase** | Recover bricked chips (including read-protected) |
| **GDB Debug** | Launch GDB server + connect for source-level debugging |
| **Fault Diagnosis** | Decode HardFault, MemFault, BusFault, UsageFault automatically |
| **TCL Automation** | Write custom TCL scripts for batch operations |

---

## Architecture

OpenOCD uses a **3-layer architecture**:

```
┌─────────────────────────────────────────────────────┐
│              Host (Your Computer)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ GDB       │  │ telnet   │  │ TCL      │      │
│  │ Client    │  │ Client   │  │ Script   │      │
│  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘  │
│        │                │                │       │
└────────│────────────────│────────────────│───────┘
         │                │                │
         ▼                ▼                ▼
┌─────────────────────────────────────────────────────┐
│         OpenOCD Daemon (TCL Engine)                │
│  ┌──────────────┐  ┌──────────────┐             │
│  │ Flash Driver  │  │ Target Driver │            │
│  └──────────────┘  └──────────────┘             │
└─────────────────────┬───────────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │   Debug Adapter (Probe)  │
         │  ST-LINK / J-Link / ...  │
         └────────────┬─────────────┘
                      │ SWD/JTAG
         ┌────────────┴─────────────┐
         │   Target MCU (Chip)       │
         │  STM32 / nRF52 / ...      │
         └───────────────────────────┘
```

### Connection Methods

| Protocol | Speed | Use Case |
|----------|-------|----------|
| **SWD** | 4 MHz (ST-LINK V3) | Modern Cortex-M debugging |
| **JTAG** | 12 MHz (J-Link Pro) | Multi-chip daisy chain |
| **cJTAG** | 2-wire | Space-constrained designs |

---

## Installation

### Prerequisites

1. **OpenOCD** (v0.11.0+ recommended)
   - Zephyr SDK: `D:/Zephyr/zephyr-sdk-0.16.8/...`
   - Chocolatey: `choco install openocd`
   - Manual: Download from https://openocd.org

2. **Debug Probe Driver**
   - ST-LINK: Install STSW-LINK009
   - J-Link: Install J-Link Software Package
   - CMSIS-DAP: No driver needed (HID)

### Install Skill in WorkBuddy

```bash
# Option 1: Clone from GitHub (after published)
cd ~/.workbuddy/skills/
git clone https://github.com/YOUR_USERNAME/openocd-debug-skill.git

# Option 2: Manual copy
# Copy the entire skill folder to ~/.workbuddy/skills/
```

---

## Quick Start

### 1. Flash Firmware

```bash
# Auto-detect OpenOCD scripts directory
./scripts/flash_fw.sh -i stlink -t stm32f4x -f build/zephyr/zephyr.elf

# Manual scripts directory
./scripts/flash_fw.sh -i stlink -t stm32f4x -s /path/to/openocd/scripts -f firmware.elf
```

**Parameters:**
- `-i`: Interface config (stlink, jlink, cmsis-dap, ftdi, rpi)
- `-t`: Target config (stm32f4x, stm32f1x, nrf52, imxrt, etc.)
- `-s`: Scripts directory (optional, auto-detect)
- `-f`: Firmware file (.elf/.hex/.bin)

### 2. Read Registers

```bash
./scripts/read_regs.sh -i stlink -t stm32f4x
```

Then use the interactive menu:
```
=== OpenOCD Register Reader ===
1. Read memory (mdw/mdh/mdb)
2. Write memory (mww/mwh/mwb)
3. Read CPU registers
4. Diagnose faults
5. Custom OpenOCD command
q. Quit
```

### 3. Mass Erase (Recover Bricked Chip)

```bash
./scripts/mass_erase.sh -i stlink -t stm32f4x
```

⚠️ **WARNING**: This erases the entire flash, including any read-protection settings.

### 4. GDB Debug

```bash
# Terminal 1: Start OpenOCD GDB server
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg

# Terminal 2: Connect with GDB
arm-none-eabi-gdb build/zephyr/zephyr.elf
(gdb) target remote localhost:3333
(gdb) monitor reset halt
(gdb) break main
(gdb) continue
```

---

## Supported Hardware

### Debug Probes

| Probe | Config File | Speed | Interface |
|-------|-------------|-------|-----------|
| ST-LINK V1 | `interface/stlink.cfg` | 1.8 MHz | SWD |
| ST-LINK V2 | `interface/stlink.cfg` | 3.6 MHz | SWD |
| ST-LINK V2-1 | `interface/stlink.cfg` | 3.6 MHz | SWD + VCP |
| ST-LINK V3 | `interface/stlink.cfg` | **4 MHz** | SWD + VCP + Bridge |
| J-Link | `interface/jlink.cfg` | 12 MHz | JTAG/SWD |
| CMSIS-DAP v1 | `interface/cmsis-dap.cfg` | 1.5 MHz | SWD |
| CMSIS-DAP v2 | `interface/cmsis-dap.cfg` | 3.5 MHz | SWD + CDC |
| FTDI FT2232H | `interface/ftdi/umm232h.cfg` | 16 MHz | JTAG/SWD |
| RPi GPIO | `interface/sysfsgpio-raspberrypi.cfg` | 1 MHz | SWD |

👉 **Full list**: See [`references/probe_configs.md`](references/probe_configs.md)

### Target Chips

| Vendor | Family | Target Config | Flash Driver |
|--------|--------|---------------|--------------|
| ST | STM32F0 | `target/stm32f0x.cfg` | `stm32f1x` |
| ST | STM32F1 | `target/stm32f1x.cfg` | `stm32f1x` |
| ST | STM32F4 | `target/stm32f4x.cfg` | `stm32f4x` |
| ST | STM32F7 | `target/stm32f7x.cfg` | `stm32f7x` |
| ST | STM32H7 | `target/stm32h7x.cfg` | `stm32h7x` |
| NXP | i.MX RT1050 | `target/imxrt1050.cfg` | `imxrt` |
| NXP | i.MX RT1064 | `target/imxrt1064.cfg` | `imxrt` |
| Nordic | nRF52832 | `target/nrf52.cfg` | `nrf5` |
| Nordic | nRF52840 | `target/nrf52840.cfg` | `nrf5` |
| TI | CC2650 | `target/cc26xx.cfg` | `cc26xx` |
| GigaDevice | GD32F4 | `target/stm32f4x.cfg` | `stm32f4x` |

👉 **Full list**: See [`references/chip_targets.md`](references/chip_targets.md)

---

## Debug Workflows

### Workflow 1: Flash Firmware

**Steps:**
1. Detect OpenOCD scripts directory
2. Validate interface/target config files
3. Flash firmware (with verify)
4. Reset and run

**Auto-detect scripts directory:**
```bash
# The script will search in this order:
# 1. Zephyr SDK: D:/Zephyr/zephyr-sdk-0.16.8/.../openocd/scripts
# 2. System package: /usr/share/openocd/scripts
# 3. Environment variable: $OPENOCD_SCRIPTS
# 4. Common locations: C:/Program Files/...
```

### Workflow 2: Read Registers

**Interactive mode commands:**

| Command | Description | Example |
|---------|-------------|---------|
| `mdw addr [count]` | Read 32-bit words | `mdw 0x4001080C 4` |
| `mdh addr [count]` | Read 16-bit halfwords | `mdh 0x40010800 2` |
| `mdb addr [count]` | Read 8-bit bytes | `mdb 0x20000000 16` |
| `mww addr value` | Write 32-bit word | `mww 0x4001080C 0x00000001` |
| `mwh addr value` | Write 16-bit halfword | `mwh 0x40010800 0x44444443` |
| `mwb addr value` | Write 8-bit byte | `mwb 0x4001080C 0x01` |
| `reg` | Show all CPU registers | `reg` |
| `reg pc` | Show specific register | `reg pc` |

### Workflow 3: Mass Erase

**Why needed:**
- Chip is read-protected (RDP Level 1/2)
- Flash is locked by option bytes
- Firmware is corrupted (won't boot)

**Supported chips:**

| Chip Family | Mass Erase Command |
|-------------|---------------------|
| STM32F0/F1/F2/F3/L0/L1 | `stm32f1x mass_erase 0` |
| STM32F4/F7/G0/G4/L4/L5 | `stm32f4x mass_erase 0` |
| STM32H7 | `stm32h7x mass_erase 0` |
| nRF52 | `nrf52 mass_erase` |
| i.MX RT | `imxrt mass_erase 0` |
| NXP Kinetis | `kinetis mdm mass_erase` |

### Workflow 4: GDB Debug

**Step 1: Start OpenOCD GDB server**
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
```

**Step 2: Connect with GDB**
```bash
arm-none-eabi-gdb build/zephyr/zephyr.elf
(gdb) target remote localhost:3333
```

**Step 3: Debug commands**
```gdb
(gdb) monitor reset halt       # Halt the chip
(gdb) break main              # Set breakpoint at main()
(gdb) break 0x08000123       # Set breakpoint at address
(gdb) continue                # Run until breakpoint
(gdb) step                    # Step one instruction
(gdb) next                    # Step over function call
(gdb) print my_variable      # Print variable value
(gdb) backtrace              # Show call stack
(gdb) info registers          # Show all registers
```

---

## Command Reference

### Memory Access

| Command | Bit Width | Example | Result |
|---------|-----------|---------|--------|
| `mdw` | 32-bit | `mdw 0x4001080C 1` | `0x4001080c: 0000a001` |
| `mdh` | 16-bit | `mdh 0x40010800 2` | `0x40010800: 4444 4443` |
| `mdb` | 8-bit | `mdb 0x20000000 4` | `0x20000000: 12 34 56 78` |
| `mww` | 32-bit | `mww 0x4001080C 0x1` | PA0 = high |
| `mwh` | 16-bit | `mwh 0x40010800 0x4443` | Set PA0 to output |
| `mwb` | 8-bit | `mwb 0x4001080C 0x1` | Set PA0 high |

### CPU Registers

| Register | Description | Example Value |
|----------|-------------|---------------|
| `pc` | Program Counter | `0x0800016c` |
| `sp` | Stack Pointer (MSP) | `0x20000660` |
| `msp` | Main Stack Pointer | `0x20000660` |
| `psp` | Process Stack Pointer | `0x00000000` |
| `xPSR` | Program Status Register | `0x01000000` (running) |
| `primask` | Priority Mask | `0x00` (interrupts enabled) |
| `basepri` | Base Priority | `0x00` (no masking) |
| `faultmask` | Fault Mask | `0x00` (faults enabled) |
| `control` | Control Register | `0x00` (Thread mode, MSP) |

### Flash Commands

| Command | Description |
|---------|-------------|
| `flash write_image erase firmware.elf` | Flash with auto-erase |
| `flash verify_image firmware.elf` | Verify flashed firmware |
| `flash erase_sector 0 0 3` | Erase sectors 0-3 |
| `flash protect 0 off 0 3` | Unprotect sectors 0-3 |

### Reset & Control

| Command | Description |
|---------|-------------|
| `reset halt` | Reset and halt at first instruction |
| `reset run` | Reset and run |
| `reset init` | Reset and run init script |
| `halt` | Halt the target |
| `resume` | Resume execution |
| `step` | Step one instruction |

---

## Fault Diagnosis

### Cortex-M Fault Types

| Fault | Priority | Description |
|-------|----------|-------------|
| **HardFault** | -1 | All faults if not enabled individually |
| **MemFault** | -1 | MPU violation, illegal unprivileged access |
| **BusFault** | -1 | Invalid memory access (wrong address) |
| **UsageFault** | -1 | Undefined instruction, unaligned access |
| **SVCall** | -2 | SVC instruction (system call) |
| **PendSV** | -3 | PendSV (context switch) |
| **SysTick** | -4 | SysTick timer interrupt |

### Fault Diagnosis Workflow

**Step 1: Halt the chip**
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "reset halt; shutdown"
```

**Step 2: Read fault registers**
```bash
# In OpenOCD telnet (telnet localhost 4444):
mdw 0xE000ED28 1   # CFSR - Configurable Fault Status Register
mdw 0xE000ED2C 1   # HFSR - HardFault Status Register
mdw 0xE000ED34 1   # MMFAR - MemManage Fault Address
mdw 0xE000ED38 1   # BFAR - BusFault Address Register
```

**Step 3: Decode CFSR (3 bytes)**

| Byte | Register | Key Bits |
|------|----------|----------|
| Low byte (7:0) | **MFSR** (MemFault) | BIT0=IACCVIOL, BIT1=DACCVIOL, BIT3=MUNSTKERR |
| Mid byte (15:8) | **BFSR** (BusFault) | BIT0=IBUSERR, BIT1=PRECISERR, BIT2=IMPRECISERR |
| High byte (23:16) | **UFSR** (UsageFault) | BIT0=UNDEFINSTR, BIT1=INVSTATE, BIT8=DIVBYZERO |

### Common Fault Patterns

| Symptom | CFSR Value | Root Cause | Fix |
|---------|-------------|-----------|-----|
| PC=0x00000000 | `0x00000001` (MFSR.IACCVIOL) | Jumped to NULL function pointer | Check function pointer init |
| Random address | `0x00000200` (BFSR.PRECISERR) | Write to invalid address | Enable BFARVALID, check BFAR |
| After interrupt | `0x00010000` (UFSR.INVSTATE) | Illegal instruction in ISR | Check stack overflow |
| Divide by zero | `0x01000000` (UFSR.DIVBYZERO) | Integer division by zero | Enable DIV_0_TRP in CCR |

👉 **Full register map**: See [`references/register_guide.md`](references/register_guide.md)

---

## TCL Scripting

You can automate OpenOCD with TCL scripts.

### Example 1: Auto-flash on Build

```tcl
# flash_on_build.tcl
proc flash_on_build {elf_file} {
    init
    reset halt
    flash write_image erase $elf_file
    flash verify_image $elf_file
    reset run
    shutdown
}

# Usage: openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -f flash_on_build.tcl -c "flash_on_build firmware.elf"
```

### Example 2: Batch Register Dump

```tcl
# dump_regs.tcl
init
reset halt

echo "=== GPIOA ==="
mdw 0x40010800 2

echo "=== RCC ==="
mdw 0x40021000 2
mdw 0x40021018 1

echo "=== Fault Status ==="
mdw 0xE000ED28 1
mdw 0xE000ED2C 1

shutdown
```

### Example 3: Retry Flash on Failure

```tcl
# retry_flash.tcl
proc retry_flash {elf_file max_retries} {
    set retry_count 0
    while {$retry_count < $max_retries} {
        catch {flash write_image erase $elf_file} result
        if {[string match "*OK*" $result]} {
            echo "Flash successful!"
            break
        }
        echo "Flash failed, retry [expr {$retry_count + 1}]..."
        incr retry_count
        sleep 1000
    }
}

init
retry_flash "firmware.elf" 3
reset run
shutdown
```

---

## Troubleshooting

### Error: "Could not find OpenOCD scripts directory"

**Solution:**
```bash
# Option 1: Set environment variable
export OPENOCD_SCRIPTS=/path/to/openocd/scripts

# Option 2: Specify manually
./scripts/flash_fw.sh -i stlink -t stm32f4x -s /path/to/openocd/scripts -f firmware.elf

# Option 3: Use find_scripts.sh
./scripts/find_scripts.sh
```

### Error: "connect_assert_srst" needed

**Symptom:** MCU stuck in HardFault, can't connect.

**Solution:**
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "reset_config srst_only connect_assert_srst" \
  -c "adapter speed 500" \
  -c "init" \
  -c "sleep 200" \
  -c "halt" \
  -c "flash write_image erase firmware.elf" \
  -c "reset run" \
  -c "shutdown"
```

### Error: "Flash write error at address ..."

**Possible causes:**
1. **Read protection enabled** → Run `mass_erase.sh`
2. **Incorrect flash driver** → Check `references/chip_targets.md`
3. **Power supply insufficient** → Use external power, not USB

### Error: "JTAG/SWD connection failed"

**Checklist:**
- [ ] Cable is firmly connected
- [ ] Target is powered (measure VCC with multimeter)
- [ ] Reset circuit is correct (10k pull-up on NRST)
- [ ] Try lower speed: `adapter speed 100`
- [ ] Try `connect_assert_srst`

---

## References

| Document | Description |
|----------|-------------|
| [`SKILL.md`](SKILL.md) | WorkBuddy skill definition (English) |
| [`references/register_guide.md`](references/register_guide.md) | Universal register discovery guide |
| [`references/probe_configs.md`](references/probe_configs.md) | All supported debug probes |
| [`references/chip_targets.md`](references/chip_targets.md) | All supported target chips |
| [`scripts/flash_fw.sh`](scripts/flash_fw.sh) | Flash firmware script |
| [`scripts/mass_erase.sh`](scripts/mass_erase.sh) | Mass erase script |
| [`scripts/read_regs.sh`](scripts/read_regs.sh) | Interactive register reader |
| [`scripts/find_scripts.sh`](scripts/find_scripts.sh) | Auto-detect scripts directory |

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Support

- **GitHub Issues**: https://github.com/YOUR_USERNAME/openocd-debug-skill/issues
- **OpenOCD Documentation**: http://openocd.org/doc/doxygen/index.html
- **WorkBuddy Community**: https://workbuddy.ai/community
