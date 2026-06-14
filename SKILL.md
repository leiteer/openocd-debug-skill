---
name: openocd-debug
description: Universal OpenOCD-based firmware debugging. Flash, read registers, diagnose faults, and remote GDB-debug ANY chip that OpenOCD supports — STM32 (all families), NXP i.MX RT/Kinetis/LPC, Nordic nRF, TI CCxx, Atmel SAM, GigaDevice GD32, Nuvoton, RISC-V, and more. Works with ST-LINK, J-Link, CMSIS-DAP, FTDI-based probes. Covers Cortex-M standard fault diagnosis (CFSR/HFSR/BFAR/MMFAR) that applies to ALL ARM vendors, plus TCL scripting for automation.
agent_created: true
---

# OpenOCD Universal Debug

## Overview

OpenOCD (Open On-Chip Debugger) is the **universal debug bridge** for embedded systems. Think of it as a translator sitting between your PC and the chip's internal debug port — it speaks GDB/telnet on the host side and SWD/JTAG bit-banging on the target side.

```
┌─────────────────────────────────────────────────────────────────┐
│                     OPENOCD ARCHITECTURE                         │
│                                                                  │
│  HOST LAYER         CORE LAYER            TARGET LAYER           │
│  ┌─────────┐       ┌──────────┐          ┌──────────────┐       │
│  │  GDB    │──3333─│          │          │ STM32F4      │       │
│  │ (debug) │       │  TCL     │  SWD/    │ STM32H7      │       │
│  ├─────────┤       │  Engine  │  JTAG    │ nRF52840     │       │
│  │ Telnet  │──4444─│          │◄────────►│ i.MX RT1064  │       │
│  │(interact│       │  Flash   │  Bit-    │ GD32F450     │       │
│  ├─────────┤       │  Drivers │  bang    │ SAM D51      │       │
│  │  TCL    │──CLI──│          │          │ RISC-V       │       │
│  │ Scripts │       │  Target  │          │ ESP32 (JTAG) │       │
│  └─────────┘       │  Drivers │          └──────────────┘       │
│                     └──────────┘                                 │
│                          ▲                                       │
│                     ┌────┴────┐                                  │
│                     │ ADAPTER │                                  │
│                     │ ST-LINK │                                  │
│                     │ J-Link  │                                  │
│                     │CMSIS-DAP│                                  │
│                     │ FTDI    │                                  │
│                     └─────────┘                                  │
└─────────────────────────────────────────────────────────────────┘
```

The key insight: OpenOCD is **chip-agnostic at the command level**. Whether you're debugging an STM32F4, an nRF52840, or an i.MX RT1064, the commands for reading memory (`mdw`), halting the CPU (`halt`), or writing flash (`flash write_image`) are **identical**. Only two things change per project:

1. **Interface config** (`-f interface/<probe>.cfg`) — your debug probe hardware
2. **Target config** (`-f target/<chip>.cfg`) — your MCU/SOC

Everything else — fault diagnosis, register inspection, breakpoints — is universal across Cortex-M (and largely across all ARM/RISC-V).

## Quick Start — Flash Firmware in 1 Minute

```bash
# Step 1: Find your OpenOCD scripts directory
ls /usr/share/openocd/scripts/interface/   # Linux
dir D:\Zephyr\zephyr-sdk-*/sysroots/*/usr/share/openocd/scripts/interface/  # Windows Zephyr

# Step 2: Pick your probe (e.g., stlink, jlink, cmsis-dap) and chip (e.g., stm32f4x, nrf52, imxrt1060)
# Step 3: Flash
openocd -s <scripts_dir> \
  -f interface/stlink.cfg \
  -f target/stm32f4x.cfg \
  -c "adapter speed 500" \
  -c "init" -c "halt" \
  -c "flash write_image erase build/zephyr/zephyr.elf" \
  -c "reset run" -c "shutdown"
```

Replace `interface/stlink.cfg` and `target/stm32f4x.cfg` with your hardware — see sections below.

## Universal Command Template

The base template for ALL OpenOCD operations:

```bash
openocd \
  -s <OPENOCD_SCRIPTS_DIR> \            # Path to .../share/openocd/scripts
  -f <INTERFACE_CONFIG>    \            # Debug probe (interface/stlink.cfg, etc.)
  -f <TARGET_CONFIG>       \            # Your chip (target/stm32f4x.cfg, etc.)
  -c "<command_1>"          \           # TCL commands, executed in order
  -c "<command_2>"          \
  -c "shutdown"                         # Clean exit (omit for interactive)
```

The `-c` commands are TCL — not shell. They execute inside OpenOCD's interpreter after target connection.

---

## Supported Debug Probes

| Probe | Interface Config | Speed | Notes |
|-------|-----------------|-------|-------|
| **ST-LINK v2/v2-1/v3** | `interface/stlink.cfg` | 500-4800 kHz | Most common for STM32; v2-1 includes VCP+MSD |
| **J-Link** | `interface/jlink.cfg` | 1000-15000 kHz | Fastest; requires J-Link software |
| **CMSIS-DAP / DAPLink** | `interface/cmsis-dap.cfg` | 100-1000 kHz | Open standard; ARM Mbed DAPLink, MCU-Link, LPC-Link2 |
| **FTDI FT2232H/FT232H** | `interface/ftdi/<board>.cfg` | Up to 30000 kHz | High-speed; used on dev boards with onboard FTDI |
| **Raspberry Pi GPIO** | `interface/raspberrypi2-native.cfg` | ~1000 kHz | Bit-bang SWD via GPIO |
| **Remote Bitbang** | `interface/remote_bitbang.cfg` | Varies | Network-based; connects to simulators or remote HW |
| **OpenJTAG** | `interface/openjtag.cfg` | 500 kHz | USB-JTAG adapter |
| **Bus Pirate** | `interface/buspirate.cfg` | ~100 kHz | Low-cost, slow |
| **ULINK (Keil)** | `interface/ulink.cfg` | 500-1000 kHz | Keil debug probe |
| **xds110 (TI)** | `interface/xds110.cfg` | 500-1000 kHz | Texas Instruments XDS110 |

**Choosing adapter speed:**
- Start conservative: 500 kHz for ST-LINK, 100 kHz for CMSIS-DAP
- Increase after stable connection: 1800-4000 kHz for ST-LINK v2-1/v3
- If you see `Error: JTAG-DP STICKY ERROR` or `SWD ack NOT OK` → drop speed

## Supported Chip Families

OpenOCD ships with hundreds of target configs. Here are the most common:

### STM32 (STMicroelectronics)
| Family | Target Config | Core | Notes |
|--------|--------------|------|-------|
| STM32F0 | `target/stm32f0x.cfg` | Cortex-M0 | |
| STM32F1 | `target/stm32f1x.cfg` | Cortex-M3 | |
| STM32F2 | `target/stm32f2x.cfg` | Cortex-M3 | |
| STM32F3 | `target/stm32f3x.cfg` | Cortex-M4F | |
| STM32F4 | `target/stm32f4x.cfg` | Cortex-M4F | |
| STM32F7 | `target/stm32f7x.cfg` | Cortex-M7 | |
| STM32G0 | `target/stm32g0x.cfg` | Cortex-M0+ | |
| STM32G4 | `target/stm32g4x.cfg` | Cortex-M4F | |
| STM32H7 (single) | `target/stm32h7x.cfg` | Cortex-M7 | Single-core |
| STM32H7 (dual) | `target/stm32h745.cfg` | M7+M4 | Dual-core configs |
| STM32L0 | `target/stm32l0.cfg` | Cortex-M0+ | |
| STM32L1 | `target/stm32l1.cfg` | Cortex-M3 | |
| STM32L4 | `target/stm32l4x.cfg` | Cortex-M4F | |
| STM32L5 | `target/stm32l5x.cfg` | Cortex-M33 | TrustZone |
| STM32WB | `target/stm32wbx.cfg` | M4+M0+ | Wireless |
| STM32WL | `target/stm32wlx.cfg` | M4+M0+ | LoRa |
| STM32U5 | `target/stm32u5x.cfg` | Cortex-M33 | Ultra-low-power |
| STM32MP15 | `target/stm32mp15x.cfg` | M4+CA7 | Multi-core MPU |

### NXP
| Family | Target Config | Core |
|--------|--------------|------|
| i.MX RT10xx (RT1050/1060/1064) | `target/imxrt1050.cfg` or `imxrt1060.cfg` | Cortex-M7 |
| i.MX RT11xx (RT1170) | `target/imxrt1170.cfg` | Cortex-M7+M4 |
| Kinetis K series | `target/kx.cfg` | Cortex-M4F |
| Kinetis KL series | `target/klx.cfg` | Cortex-M0+ |
| LPC17xx | `target/lpc17xx.cfg` | Cortex-M3 |
| LPC43xx | `target/lpc4350.cfg` | M4+M0 |
| LPC8xx | `target/lpc8xx.cfg` | Cortex-M0+ |
| LPC55xx | `target/lpc55s69.cfg` | Cortex-M33 |

### Nordic Semiconductor
| Family | Target Config | Core |
|--------|--------------|------|
| nRF51 | `target/nrf51.cfg` | Cortex-M0 |
| nRF52 (52832/52840) | `target/nrf52.cfg` | Cortex-M4F |
| nRF53 | `target/nrf53.cfg` | Cortex-M33 |
| nRF91 | `target/nrf91.cfg` | Cortex-M33 |

### Texas Instruments
| Family | Target Config | Core |
|--------|--------------|------|
| CC13xx/CC26xx | `target/ti_cc13x2.cfg`, `ti_cc26x2.cfg` | Cortex-M4F |
| MSP432 | `target/msp432p4.cfg` | Cortex-M4F |
| TM4C (Tiva C) | `target/tm4c123.cfg`, `tm4c129.cfg` | Cortex-M4F |
| AM335x (BeagleBone) | `target/am335x.cfg` | Cortex-A8 |

### Microchip / Atmel
| Family | Target Config | Core |
|--------|--------------|------|
| SAM D (D21/D51) | `target/atsamd21.cfg`, `atsamd51.cfg` | Cortex-M0+/M4F |
| SAM E (E53/E54/E70) | `target/atsame53.cfg`, `atsame70.cfg` | Cortex-M4F/M7 |
| SAM V7 | `target/atsamv71.cfg` | Cortex-M7 |
| SAMA5 | `target/sama5d2.cfg`, `sama5d3.cfg` | Cortex-A5 |

### GigaDevice
| Family | Target Config | Core |
|--------|--------------|------|
| GD32VF103 (RISC-V) | `target/gd32vf103.cfg` | Bumblebee RISC-V |
| GD32F1x0 | `target/gd32f1x0.cfg` | Cortex-M3 |
| GD32F3x0 | `target/gd32f3x0.cfg` | Cortex-M4F |
| GD32F4xx | `target/gd32f4xx.cfg` | Cortex-M4F |
| GD32E23x | `target/gd32e23x.cfg` | Cortex-M23 |

### Nuvoton
| Family | Target Config | Core |
|--------|--------------|------|
| NuMicro M0 (M032/M051/M058S) | `target/numicro.cfg` | Cortex-M0 |
| NuMicro M4 (M480) | `target/numicroM4.cfg` | Cortex-M4F |
| NuMicro M23 (M2351) | `target/numicroM23x.cfg` | Cortex-M23 |
| NUC970 | `target/nuc970.cfg` | ARM926EJ-S |

### Other Notable Targets
| Chip | Target Config | Core |
|------|--------------|------|
| ESP32 | `target/esp32.cfg` | Xtensa LX6 (JTAG only) |
| ESP32-S2 | `target/esp32s2.cfg` | Xtensa LX7 |
| ESP32-S3 | `target/esp32s3.cfg` | Xtensa LX7 |
| Raspberry Pi Pico (RP2040) | `target/rp2040.cfg` | Cortex-M0+ dual |
| Raspberry Pi 3/4 (BCM2837) | Target via JTAG pins | Cortex-A53 |
| FE310 (SiFive RISC-V) | `target/sifive-freedom.cfg` | RISC-V E31 |
| MAX32xxx | `target/max32xxx.cfg` | RISC-V |

### Finding Your Target Config

To list ALL available target configs:

```bash
ls <scripts_dir>/target/ | grep -v "^Makefile\|^test\|^xilinx\|^altera"
```

Or search for your chip:

```bash
ls <scripts_dir>/target/ | grep -i "stm32\|nrf\|imx\|sam\|lpc\|kinetis"
```

---

## Universal Command Reference

These commands work across **ALL chips** that OpenOCD supports. They execute inside OpenOCD's TCL interpreter (use with `-c "command"` or interactively).

### Memory Access

| Command | Description | Example |
|---------|-------------|---------|
| `mdw <addr> [count]` | Read 32-bit words | `mdw 0x40020000 4` — read 4 words from GPIOA MODER |
| `mdh <addr> [count]` | Read 16-bit half-words | `mdh 0x40020000 8` |
| `mdb <addr> [count]` | Read 8-bit bytes | `mdb 0x20000000 256` — dump 256 bytes of SRAM |
| `mww <addr> <value>` | Write 32-bit word | `mww 0x40020414 0x8000` — set GPIOB bit15 |
| `mwh <addr> <value>` | Write 16-bit half-word | `mwh 0x40020000 0x5555` |
| `mwb <addr> <value>` | Write 8-bit byte | `mwb 0x40020414 0x80` |

**Physical vs Virtual addresses:** Use `mdw phys <addr>` for physical addresses on chips with MMU (Cortex-A).

### CPU Register Access

| Command | Description |
|---------|-------------|
| `reg` | Dump ALL CPU core registers |
| `reg pc` | Read Program Counter |
| `reg sp` | Read Stack Pointer |
| `reg lr` | Read Link Register |
| `reg xPSR` | Read Program Status Register |
| `reg r0`-`r12` | Read general-purpose registers |
| `reg msp` | Read Main Stack Pointer |
| `reg psp` | Read Process Stack Pointer (RTOS) |
| `reg primask` | Read interrupt mask |
| `reg faultmask` | Read fault mask |
| `reg basepri` | Read base priority |
| `reg control` | Read CONTROL register |

### Reset Control

| Command | Description |
|---------|-------------|
| `reset` | Full reset (run mode after) |
| `reset halt` | Reset and halt at reset vector |
| `reset run` | Reset and start running |
| `reset init` | Reset + board-specific init sequence |
| `reset_config <mode>` | Configure reset behavior (see below) |

**Reset modes** (`reset_config`):
- `srst_only` — Use only system reset (NRST pin)
- `trst_only` — Use only TAP reset (JTAG TRST)
- `srst_only connect_assert_srst` — Assert NRST during connect (break dead loops)
- `srst_nogate` — Don't gate NRST with JTAG operations (more reliable on some boards)

### Execution Control

| Command | Description |
|---------|-------------|
| `halt` | Halt the target CPU |
| `resume` | Resume execution |
| `step [count]` | Single-step N instructions |
| `poll` | Check target state (running/halted) |
| `wait_halt [ms]` | Wait up to ms for target to halt |

### Flash Operations

| Command | Description |
|---------|-------------|
| `flash banks` | List all flash banks (core command) |
| `flash list` | Alternative listing |
| `flash probe <bank>` | Re-probe flash bank |
| `flash info <bank>` | Detailed flash info |
| `flash erase_sector <bank> <first> <last>` | Erase sector range |
| `flash write_image [erase] <file> [offset]` | Write firmware (ELF/HEX/BIN) |
| `flash fillb <addr> <pattern> <len>` | Fill flash with byte pattern |
| `flash fillw <addr> <pattern> <len>` | Fill flash with word pattern |
| `flash verify_image <file>` | Verify flash against image |
| `flash read_bank <bank> <file> [offset] [len]` | Dump flash to file |

### Breakpoints & Watchpoints (OpenOCD native)

| Command | Description |
|---------|-------------|
| `bp <addr> <len> <hw>` | Set hardware breakpoint |
| `rbp <addr>` | Remove breakpoint |
| `wp <addr> <len> <type> <value>` | Set watchpoint |
| `rwp <addr>` | Remove watchpoint |
| `bp list` | List all breakpoints |
| `wp list` | List all watchpoints |

Breakpoint type: 0=write, 1=read, 2=access.

### Low-Level Debug Access (DAP)

For advanced debugging — direct SWD/JTAG Debug Port access:

| Command | Description |
|---------|-------------|
| `dap info` | List Debug Access Ports |
| `dap apreg <ap> <reg>` | Read AP register |
| `dap apid <ap>` | Read AP IDR |
| `dap dpreg <reg>` | Read DP register |
| `dap memaccess <value>` | Set memory access size |

### Target Management

| Command | Description |
|---------|-------------|
| `targets` | List all targets and their state |
| `target names` | List target names only |
| `target current` | Print current target |
| `targets <name>` | Switch to named target (multi-core) |
| `init` | Initialize OpenOCD and connect |
| `shutdown` | Exit OpenOCD |
| `sleep <ms>` | Wait N milliseconds |
| `adapter list` | List available adapter drivers |
| `adapter speed <khz>` | Set/get adapter clock |
| `adapter name` | Print current adapter name |

---

## Workflow 1: Flash Firmware to Any Chip

### Decision Tree

```
MCU running normally? Or unknown state?
  ├── Running normally → Simplified flash (skip connect_assert_srst)
  └── UNKNOWN / stuck / crashed → Full flash with connect_assert_srst
```

### Full Flash (safe — always use this)

```bash
openocd -s <scripts_dir> \
  -f interface/<probe>.cfg \
  -f target/<chip>.cfg \
  -c "reset_config srst_only connect_assert_srst" \
  -c "adapter speed 500" \
  -c "init" \
  -c "sleep 200" \
  -c "halt" \
  -c "flash write_image erase <firmware.elf>" \
  -c "reset run" \
  -c "shutdown"
```

The `connect_assert_srst` flag pulls NRST low for ~20ms during connection, hardware-resetting the MCU. This breaks any dead loop (HardFault, MemManage, busy-wait, or hung state).

**Important**: NRST must be physically connected from the debug probe to the MCU's NRST pin. Some boards (e.g., STM32 Discovery, Nucleo) include this by default; for custom boards or minimal SWD headers (SWDIO/SWCLK/GND/VCC only), you'll need to add a separate NRST connection or skip `connect_assert_srst`.

### Simplified Flash (MCU known-good)

```bash
openocd -s <scripts_dir> \
  -f interface/<probe>.cfg \
  -f target/<chip>.cfg \
  -c "adapter speed 500" \
  -c "init" \
  -c "halt" \
  -c "flash write_image erase <firmware.elf>" \
  -c "reset run" \
  -c "shutdown"
```

### Using the Generalized Script

```bash
# Syntax: flash_fw.sh <elf_path> <interface_config> <target_config> [scripts_dir] [speed]
./scripts/flash_fw.sh build/zephyr/zephyr.elf stlink stm32f4x
./scripts/flash_fw.sh firmware.elf cmsis-dap nrf52 /usr/share/openocd/scripts 1000
./scripts/flash_fw.sh firmware.elf jlink imxrt1060
```

### Common Flash Failure Modes

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| `Error: init mode failed` | Target not responding | Use `connect_assert_srst` |
| `Error connecting DP: cannot read IDR` | Debug port locked by running code | Add `connect_assert_srst` or power-cycle |
| `JTAG-DP STICKY ERROR` | SWD communication corruption | Drop adapter speed (`adapter speed 100`) |
| `flash 'stm32f2x' found at 0x..., size reports 0` | Flash geometry unresolved | Add `-c "halt"` before flash operations |
| `Error: timeout waiting for algorithm` | Flash driver algorithm hung | Mass-erase first, then flash |
| Flash writes but firmware doesn't run | Boot config mismatch / corrupted flash | Mass erase, re-flash, check BOOT pins |
| `Error: Unknown flash type` / driver mismatch | Wrong target config | Verify `-f target/xxx.cfg` matches your chip |

---

## Workflow 2: Read Any Peripheral Register

### Finding Register Addresses for ANY Chip

The universal method — works for all MCUs:

1. **Download the Reference Manual (RM)** for your chip from the vendor website
2. **Find the "Memory Map" section** — usually early in the RM (Chapter 2-3)
3. **Locate your peripheral's base address**
4. **Add the register offset** from the peripheral's register description table

**Example: STM32F4 GPIOB ODR**

From STM32F4 RM0090:
- Memory map → AHB1 peripherals → GPIOB base = 0x4002 0400
- GPIO register map → ODR offset = 0x14
- GPIOB ODR = 0x40020400 + 0x14 = 0x40020414

```bash
openocd -s <scripts_dir> -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "adapter speed 500" -c "init" -c "halt" \
  -c "mdw 0x40020414" -c "shutdown"
```

**Example: nRF52840 GPIO P0 OUT**

From nRF52840 PS v1.1:
- Memory map → P0 base = 0x50000000
- OUT offset = 0x504
- P0 OUT = 0x50000504

```bash
openocd -s <scripts_dir> -f interface/cmsis-dap.cfg -f target/nrf52.cfg \
  -c "adapter speed 500" -c "init" -c "halt" \
  -c "mdw 0x50000504" -c "shutdown"
```

### ARM Cortex-M Generic Registers (ALL Vendors)

These registers have the **identical address** across EVERY Cortex-M chip (M3/M4/M7/M33), regardless of vendor. This is a contract defined by the ARM architecture:

| Register | Address | Description |
|----------|---------|-------------|
| CPUID | 0xE000ED00 | CPU ID register |
| ICSR | 0xE000ED04 | Interrupt Control State |
| VTOR | 0xE000ED08 | Vector Table Offset |
| AIRCR | 0xE000ED0C | Application Interrupt/Reset Control |
| SCR | 0xE000ED10 | System Control |
| CCR | 0xE000ED14 | Configuration and Control |
| SHPR1-3 | 0xE000ED18-20 | System Handler Priority |
| SHCSR | 0xE000ED24 | System Handler Control & State |
| CFSR | 0xE000ED28 | Configurable Fault Status (MFSR+BFSR+UFSR) |
| HFSR | 0xE000ED2C | HardFault Status |
| DFSR | 0xE000ED30 | Debug Fault Status |
| MMFAR | 0xE000ED34 | MemManage Fault Address |
| BFAR | 0xE000ED38 | BusFault Address |
| AFSR | 0xE000ED3C | Auxiliary Fault Status |
| STIR | 0xE000EF00 | Software Trigger Interrupt |
| FPCCR | 0xE000EF34 | Floating-point Context Control (M4F/M7) |
| FPCAR | 0xE000EF38 | Floating-point Context Address (M4F/M7) |
| FPSCR | 0xE000EF3C | Floating-point Status (M4F/M7) |

NVIC (Nested Vectored Interrupt Controller):
| Register | Address | Description |
|----------|---------|-------------|
| NVIC_ISER0 | 0xE000E100 | Interrupt Set-Enable |
| NVIC_ICER0 | 0xE000E180 | Interrupt Clear-Enable |
| NVIC_ISPR0 | 0xE000E200 | Interrupt Set-Pending |
| NVIC_ICPR0 | 0xE000E280 | Interrupt Clear-Pending |
| NVIC_IABR0 | 0xE000E300 | Interrupt Active Bit |
| NVIC_IPR0 | 0xE000E400 | Interrupt Priority (8-bit per IRQ) |

SysTick:
| Register | Address | Description |
|----------|---------|-------------|
| SYST_CSR | 0xE000E010 | SysTick Control & Status |
| SYST_RVR | 0xE000E014 | SysTick Reload Value |
| SYST_CVR | 0xE000E018 | SysTick Current Value |
| SYST_CALIB | 0xE000E01C | SysTick Calibration |

### Interactive Register Inspection

Use the generalized interactive script:

```bash
./scripts/read_regs.sh stlink stm32f4x [scripts_dir]
```

This starts an interactive OpenOCD session where you can type `mdw`, `mdb`, `reg` commands directly.

---

## Workflow 3: Mass Erase Any Chip

### Per-Family Commands

Mass erase commands differ per vendor/family — the command name ties to the target driver:

| Chip Family | OpenOCD Command |
|-------------|----------------|
| STM32F0/F1/F2/F3/F4/F7 | `stm32f2x mass_erase 0` |
| STM32G0/G4 | `stm32g0x mass_erase 0` |
| STM32H7 | `stm32h7x mass_erase 0` |
| STM32L0/L1 | `stm32l0 mass_erase 0` / `stm32l1 mass_erase 0` |
| STM32L4/L5/U5 | `stm32l4x mass_erase 0` / `stm32l5x mass_erase 0` |
| nRF51/nRF52 | `nrf51 mass_erase` / `nrf52 mass_erase` |
| i.MX RT | `imxrt mass_erase 0` |
| Kinetis | `kinetis mass_erase 0` |
| LPC | `lpc2000 mass_erase 0` |
| SAM D/E/V | `atsamv mass_erase 0` |
| GD32 (Cortex-M) | `gd32vf103 mass_erase 0` |
| RP2040 | `rp2040 mass_erase 0` |

### How to find the right command for your chip

```bash
# 1. Start interactive OpenOCD with your config
openocd -s <scripts_dir> -f interface/<probe>.cfg -f target/<chip>.cfg -c "adapter speed 500" -c "init" -c "halt"

# 2. In the OpenOCD prompt, type:
flash banks
# This lists all flash banks and their driver names

# 3. The driver name tells you the command prefix.
# Example: "stm32f2x" → use "stm32f2x mass_erase 0"
```

### Two-Step Recovery

```bash
# Step 1: Erase everything
./scripts/mass_erase.sh stlink stm32f4x

# Step 2: Flash fresh firmware
./scripts/flash_fw.sh build/zephyr/zephyr.elf stlink stm32f4x
```

If mass erase itself fails:
- Unplug/replug the debug probe USB cable
- Power-cycle the board
- Retry at lower speed (`adapter speed 100`)

---

## Workflow 4: GDB Remote Debugging

This works identically for **all ARM Cortex-M chips**.

### Setup

**Terminal 1** — Start OpenOCD as GDB server:

```bash
openocd -s <scripts_dir> \
  -f interface/<probe>.cfg \
  -f target/<chip>.cfg \
  -c "adapter speed 500" \
  -c "init" \
  -c "halt"
# OpenOCD is now listening on :3333 (GDB) and :4444 (telnet)
```

**Terminal 2** — Connect GDB:

```bash
arm-none-eabi-gdb build/zephyr/zephyr.elf
(gdb) target extended-remote :3333
(gdb) monitor reset halt
(gdb) break main
(gdb) continue
```

### Complete GDB Remote Commands

| Category | GDB Command | OpenOCD `monitor` |
|----------|-------------|-------------------|
| **Reset** | — | `monitor reset halt` / `monitor reset run` |
| **Memory read** | `x/4xw 0x40020400` | `monitor mdw 0x40020400 4` |
| **Memory write** | `set *(uint32_t*)0x40020414=0x8000` | `monitor mww 0x40020414 0x8000` |
| **Breakpoint** | `break func_name` / `break file.c:123` | `monitor bp 0x08000100 2 hw` |
| **Watch** | `watch var` / `rwatch var` | `monitor wp 0x20000010 4 r` |
| **Step** | `step` / `s` (step into), `next` / `n` (step over) | — |
| **Continue** | `continue` / `c` | — |
| **Inspect** | `print expr`, `info locals`, `info registers`, `bt` | — |
| **Disasm** | `disassemble`, `x/10i $pc` | — |
| **Flash write** | `load` | `monitor flash write_image erase build/zephyr/zephyr.elf` |
| **Flash erase** | — | `monitor flash erase_sector 0 0 11` |
| **Flash info** | — | `monitor flash banks` |
| **Registers** | `info registers`, `p/x $pc` | `monitor reg` |

### Semihosting (printf via debugger)

Enable semihosting in OpenOCD to capture `printf` without a physical UART:

```bash
openocd ... -c "arm semihosting enable" -c "arm semihosting_fileio enable"
```

Then compile firmware with semihosting support (Zephyr: `CONFIG_ARM_SEMIHOSTING=y`).

### Segger J-Link GDB Server Alternative

If OpenOCD's flash driver is slow for your chip, J-Link has its own GDB server:

```bash
JLinkGDBServer -device STM32F407VG -if SWD -speed 4000
# Then connect GDB: target remote :2331
```

---

## Cortex-M Fault Diagnosis (ALL Vendors)

Fault diagnosis on Cortex-M is **completely vendor-independent**. The ARM SCB (System Control Block) registers have identical addresses and bit definitions on every Cortex-M3/M4/M7/M33 chip — STM32, NXP, Nordic, TI, Atmel, GigaDevice, Nuvoton, all the same.

### The Fault Diagnosis Procedure

When your firmware crashes, halt the target and run:

```tcl
reg pc           # WHERE did it crash?
reg sp           # Stack pointer (for backtrace)
mdw 0xE000ED28   # CFSR — WHAT type of fault?
mdw 0xE000ED2C   # HFSR — Did another fault force HardFault?
mdw 0xE000ED34   # MMFAR — WHERE did MemManage fault happen? (if applicable)
mdw 0xE000ED38   # BFAR — WHERE did BusFault happen? (if applicable)
```

### Interpreting the Crash

**Step 1: Check PC**

| PC Value | Meaning |
|----------|---------|
| `0xFFFFFFFx` | MCU tried to execute from invalid address — corrupted function pointer, stack overflow, or undefined interrupt vector |
| Normal flash address (0x0800xxxx) | Legal code location; use `addr2line` to find source |
| `0x00000000` | Reset vector executed — unexpected reset or watchdog |
| `0x1FFFxxxx` or `0x2000xxxx` | Bootloader/SRAM address — bad jump target |

To get the source line from a valid PC:
```bash
arm-none-eabi-addr2line -e build/zephyr/zephyr.elf -a <pc_value>
```

**Step 2: Read CFSR (0xE000ED28) — 3 sub-registers in 1 word**

```
CFSR byte layout: [UFSR: 16-23] [BFSR: 8-15] [MFSR: 0-7]
```

| Byte | Bit | Name | Meaning |
|------|-----|------|---------|
| MFSR | 0 | IACCVIOL | Instruction access violation (PC points to non-executable address) |
| MFSR | 1 | DACCVIOL | Data access violation (load/store to protected region) |
| MFSR | 3 | MUNSTKERR | Unstacking error (returning from exception, stack corrupted) |
| MFSR | 4 | MSTKERR | Stacking error (entering exception, stack corrupted) |
| MFSR | 5 | MLSPERR | FPU lazy stacking error |
| MFSR | 7 | MMARVALID | MMFAR has valid faulting address |
| BFSR | 8 | IBUSERR | Instruction bus error (often = invalid memory read) |
| BFSR | 9 | PRECISERR | Precise data bus error (BFAR has valid address) |
| BFSR | 10 | IMPRECISERR | Imprecise bus error (BFAR invalid — harder to debug) |
| BFSR | 11 | UNSTKERR | Unstacking bus error |
| BFSR | 12 | STKERR | Stacking bus error |
| BFSR | 13 | LSPERR | FPU lazy state bus error |
| BFSR | 15 | BFARVALID | BFAR has valid faulting address |
| UFSR | 16 | UNDEFINSTR | Undefined instruction |
| UFSR | 17 | INVSTATE | Invalid state (e.g., trying to switch to ARM state on Cortex-M) |
| UFSR | 18 | INVPC | Invalid PC load (e.g., loading 0 to PC via BX) |
| UFSR | 19 | NOCP | No coprocessor (FPU access with FPU disabled) |
| UFSR | 24 | UNALIGNED | Unaligned access (with unaligned traps enabled) |
| UFSR | 25 | DIVBYZERO | Divide by zero (with DIV_0_TRP enabled) |

**Step 3: Read HFSR (0xE000ED2C)**

| Bit | Name | Meaning |
|-----|------|---------|
| 30 | FORCED | This HardFault was forced — another fault escalated (read CFSR to find root cause) |
| 31 | DEBUGEVT | Debug event (rare) |
| 1 | VECTTBL | Vector table read error (bad VTOR or corrupted vector table) |

If HFSR bit30=1 (FORCED): the actual cause is in CFSR. A MemManage or BusFault escalated to HardFault because the corresponding handler was not enabled.

**Step 4: Enable Detailed Fault Handlers (proactive)**

To get MemManage/BusFault/UsageFault directly instead of generic HardFault, enable them in firmware:

```c
// Zephyr: CONFIG_ARM_FAULT_DUMP=y (enables detailed fault output)
// Bare-metal:
SCB->SHCSR |= SCB_SHCSR_MEMFAULTENA_Msk
           | SCB_SHCSR_BUSFAULTENA_Msk
           | SCB_SHCSR_USGFAULTENA_Msk;
```

Check if they're enabled via OpenOCD:
```tcl
mdw 0xE000ED24   # SHCSR: bits 16-18 should be 1
```

### Common Fault Patterns

```
Pattern 1: PC=0xFFFFFFFx, CFSR bit0=1 (IACCVIOL), HFSR bit30=1
→ Code tried to jump to garbage address. Stack overflow? Corrupted function pointer?

Pattern 2: PC=normal, CFSR bit7=1 (MMARVALID), MMFAR=some address
→ MemManage fault. Usually MPU blocked access. Read MMFAR to see the blocked address.

Pattern 3: PC=normal, CFSR bit15=1 (BFARVALID), BFAR=some address
→ Bus fault accessing BFAR. Usually means the address doesn't exist (no peripheral/RAM mapped there).

Pattern 4: CFSR bit12=1 (STKERR) + bit3=1 (MUNSTKERR)
→ Stack frame corrupted during exception entry/exit. Almost always stack overflow.

Pattern 5: CFSR bit19=1 (NOCP)
→ FPU instruction executed but FPU is disabled or not present. Check startup code for FPU enable.
```

---

## Peripheral Register Discovery Methodology

### How to Find ANY Peripheral Register Address

This is a **universal skill** that works for any MCU, not just STM32:

```
Reference Manual (or Datasheet)
  └── Memory Map Chapter (usually Ch.2 or Ch.3)
       └── Find peripheral block base address (e.g., GPIOB at 0x40020400)
            └── Go to peripheral chapter (e.g., Ch.8 GPIO)
                 └── Find register offset table
                      └── Calculate: BASE + OFFSET = full address
```

### Register Layout Patterns (most MCUs follow these conventions)

**GPIO registers** (almost universal pattern):
```
Offset 0x00: MODER / DIR / CFG   — Mode/pin direction
Offset 0x04: OTYPER / TYPE       — Output type (push-pull / open-drain)
Offset 0x08: OSPEEDR             — Output speed
Offset 0x0C: PUPDR / PUPD        — Pull-up/pull-down
Offset 0x10: IDR / IN            — Input data
Offset 0x14: ODR / OUT           — Output data
Offset 0x18: BSRR / BSC / SET/CLR— Bit set/reset
Offset 0x20: AFRL / PMUX[0]      — Alternate function low (pins 0-7)
Offset 0x24: AFRH / PMUX[1]      — Alternate function high (pins 8-15)
```

**UART/USART registers:**
```
Offset 0x00: SR / STAT  — Status
Offset 0x04: DR / DATA  — Data
Offset 0x08: BRR / BAUD  — Baud rate
Offset 0x0C: CR1 / CTRL  — Control 1
Offset 0x10: CR2         — Control 2
Offset 0x14: CR3         — Control 3
```

**SPI registers:**
```
Offset 0x00: CR1 / CTRL   — Control 1
Offset 0x04: CR2          — Control 2
Offset 0x08: SR / STAT    — Status
Offset 0x0C: DR / DATA    — Data
```

**TIM registers:**
```
Offset 0x00: CR1  — Control 1
Offset 0x04: CR2  — Control 2
Offset 0x08: SMCR — Slave mode control
Offset 0x0C: DIER — DMA/Interrupt enable (sometimes offset 0x0C)
Offset 0x10: SR   — Status
Offset 0x24: CNT  — Counter
Offset 0x28: PSC  — Prescaler
Offset 0x2C: ARR  — Auto-reload
Offset 0x34: CCR1 — Capture/Compare 1
```

### RCC / Clock Control (critical for debugging)

The clock controller's registers are the first thing to check if **anything** isn't working:

```bash
# Common: check if peripheral clock is enabled
# STM32F4: AHB1ENR enables GPIO clocks
mdw 0x40023830   # RCC_AHB1ENR

# If your GPIO bit is 0, your pin won't work no matter what MODER says
```

---

## TCL Scripting in OpenOCD

OpenOCD uses TCL as its embedded scripting language. You can automate multi-step debug procedures.

### Write a Custom Init Script

Create a file `my_init.tcl`:

```tcl
# my_init.tcl — auto-dump fault registers after each halt
proc my_halt_hook {} {
    echo "=== Halted ==="
    echo "PC: "; reg pc
    echo "SP: "; reg sp
    echo "CFSR: "; mdw 0xE000ED28
    echo "HFSR: "; mdw 0xE000ED2C
}

# Add the hook
target_events name $_TARGETNAME event halted my_halt_hook
```

Use it:
```bash
openocd -s <scripts_dir> -f interface/stlink.cfg -f target/stm32f4x.cfg -f my_init.tcl
```

### Bulk Register Dump Script

Save as `dump_periph.tcl`:

```tcl
proc dump_range {base count {label ""}} {
    echo "=== $label ==="
    for {set i 0} {$i < $count} {incr i} {
        set addr [expr {$base + ($i * 4)}]
        echo [format "  [expr {$addr & 0xFFFF}] = 0x%08X" [mdw $addr]]
    }
}

# Usage:
dump_range 0x40020000 8 "GPIOA"
dump_range 0x40020400 8 "GPIOB"
```

Run it:
```bash
openocd -s <scripts_dir> -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -f dump_periph.tcl -c "init" -c "halt"
```

### Automate Multi-Step Workflow

```tcl
# flash_recover.tcl — automated flash recovery with infinite retry
set attempts 0
while {1} {
    incr attempts
    echo "--- Attempt $attempts ---"
    reset_config srst_only connect_assert_srst
    adapter speed 100
    init
    sleep 200
    halt
    if {![catch {flash write_image erase build/zephyr/zephyr.elf}]} {
        echo "SUCCESS on attempt $attempts"
        reset run
        shutdown
    }
    echo "FAILED attempt $attempts, retrying..."
    # Power-cycle via external relay/gpio would go here
    sleep 500
}
```

---

## Adapter Path Discovery

Finding the OpenOCD `scripts/` directory on any system:

### Automated Discovery Script

```bash
#!/usr/bin/env bash
# find_openocd_scripts.sh

# Method 1: Check openocd binary's idea of its data dir
if command -v openocd &>/dev/null; then
    OPENOCD_PATH=$(which openocd)
    echo "openocd found at: $OPENOCD_PATH"
    # Try printing a search path hint
    openocd --help 2>&1 | grep -i "search" || true
fi

# Method 2: Common install paths
for dir in \
    /usr/share/openocd/scripts \
    /usr/local/share/openocd/scripts \
    /opt/openocd/share/openocd/scripts \
    "$HOME/.local/share/openocd/scripts"; do
    if [ -d "$dir" ]; then echo "Found: $dir"; fi
done

# Method 3: Zephyr SDK (multiple platforms)
for dir in \
    "$HOME/zephyr-sdk-"*/sysroots/*/usr/share/openocd/scripts \
    "/opt/zephyr-sdk-"*/sysroots/*/usr/share/openocd/scripts \
    "D:/Zephyr/zephyr-sdk-"*/sysroots/*/usr/share/openocd/scripts; do
    if ls $dir/interface/stlink.cfg &>/dev/null 2>&1; then
        echo "Zephyr SDK: $dir"
    fi
done

# Method 4: locate / find
if command -v locate &>/dev/null; then
    locate -b '\stlink.cfg' 2>/dev/null | head -5
else
    find / -name "stlink.cfg" -path "*/interface/*" 2>/dev/null | head -5
fi
```

### Known Paths by Platform

| Platform | Typical Path |
|----------|-------------|
| Linux apt | `/usr/share/openocd/scripts/` |
| Linux manual build | `/usr/local/share/openocd/scripts/` |
| macOS Homebrew | `/opt/homebrew/share/openocd/scripts/` |
| macOS MacPorts | `/opt/local/share/openocd/scripts/` |
| Windows Zephyr SDK | `D:/Zephyr/zephyr-sdk-<ver>/sysroots/AMD64-pokysdk-linux/usr/share/openocd/scripts/` |
| Windows MSYS2 | `/mingw64/share/openocd/scripts/` |
| Windows manual | `C:/OpenOCD/share/openocd/scripts/` |
| ARM GNU Toolchain | `<install>/share/openocd/scripts/` |

---

## Hardware Setup Notes

### SWD Pinout (most common)

```
DEBUG PROBE             TARGET MCU
┌──────────┐          ┌──────────┐
│  VCC  ───┼──────────┤ VDD      │  (optional: target power sensing)
│  GND  ───┼──────────┤ GND      │  (required)
│ SWDIO ───┼──────────┤ SWDIO    │  (required)
│ SWCLK ───┼──────────┤ SWCLK    │  (required)
│  NRST ───┼──────────┤ NRST     │  (recommended: enables connect_assert_srst)
│  SWO  ───┼──────────┤ SWO      │  (optional: SWV trace / ITM printf)
└──────────┘          └──────────┘
```

### JTAG Pinout (20-pin ARM standard)

```
 1 VCC    2 VCC(sense)
 3 TRST   4 GND
 5 TDI    6 GND
 7 TMS    8 GND
 9 TCK   10 GND
11 RTCK  12 GND
13 TDO   14 GND
15 SRST  16 GND
17 DBGRQ 18 GND
19 DBGACK 20 GND
```

### When NRST Is Not Connected

If your debug probe doesn't have NRST wired (common on minimal 4-pin SWD headers):
- **You cannot use `connect_assert_srst`** — the probe has no way to reset the MCU
- Alternative: manually press the board's RESET button while connecting
- Alternative: use `reset_config none` and accept that stuck MCUs need a power cycle

---

## Environment Notes

- All scripts use **bash** (Git Bash on Windows, native bash on Linux/macOS)
- Paths: use forward slashes everywhere (`D:/path/to/file`, not `D:\path\to\file`)
- The debug probe must be USB-connected and the board must be powered
- If using a USB hub, connect the debug probe directly to the computer — hubs can cause SWD glitches
- Some ST-LINK clones report as "ST-LINK/V2" but don't fully implement the protocol — downgrade speed to 100 kHz if you suspect a clone

---

## Scripts Included

| Script | Purpose |
|--------|---------|
| `scripts/flash_fw.sh` | Flash firmware to any chip — accepts interface + target config |
| `scripts/mass_erase.sh` | Mass-erase any chip — accepts interface + target config |
| `scripts/read_regs.sh` | Interactive register inspection — accepts interface + target config |
| `scripts/find_scripts.sh` | Auto-discover OpenOCD scripts directory on any platform |

---

## Reference Files

| File | Content |
|------|---------|
| `references/register_guide.md` | Universal register discovery methodology, Cortex-M standard SCB/NVIC registers, peripheral register layout patterns, and vendor-specific examples |
| `references/probe_configs.md` | Complete debug probe reference: pinouts, capabilities, speed ranges, and specific quirks for each probe type |
| `references/chip_targets.md` | Comprehensive list of OpenOCD target configs organized by vendor/family, with flash driver command names |
