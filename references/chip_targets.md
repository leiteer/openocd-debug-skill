# OpenOCD Target Config Reference

Comprehensive listing of OpenOCD target configs organized by vendor and family. Use this to find the correct `-f target/<name>.cfg` for your chip.

---

## How to Find Your Exact Config

```bash
# List all available targets
ls <openocd_scripts>/target/ | grep -v "^Makefile\|^test\|^xilinx\|^altera"

# Search for your vendor
ls <openocd_scripts>/target/ | grep -i "stm32"
ls <openocd_scripts>/target/ | grep -i "nrf"
ls <openocd_scripts>/target/ | grep -i "imx"
ls <openocd_scripts>/target/ | grep -i "sam"
ls <openocd_scripts>/target/ | grep -i "lpc"
ls <openocd_scripts>/target/ | grep -i "gd32"
```

If multiple configs exist for your family, pick the most specific one. Generic configs (e.g., `stm32f4x.cfg`) work for most chips in that family; chip-specific configs (e.g., `stm32f407vg.cfg`) may have more precise flash/clock settings.

---

## STMicroelectronics (STM32)

### STM32F0 (Cortex-M0)
```
target/stm32f0x.cfg            # Generic F0 family
target/stm32f030c8.cfg
target/stm32f051_discovery.cfg
target/stm32f072xb.cfg
```

### STM32F1 (Cortex-M3)
```
target/stm32f1x.cfg            # Generic F1 family
target/stm32f103c8_sram.cfg    # F103 "bluepill" SRAM boot
target/stm32f103_hybrid.cfg
```

### STM32F2 (Cortex-M3)
```
target/stm32f2x.cfg
```

### STM32F3 (Cortex-M4F)
```
target/stm32f3x.cfg            # Generic F3 family
target/stm32f3discovery.cfg    # STM32F3 Discovery board
target/stm32f334.cfg
```

### STM32F4 (Cortex-M4F)
```
target/stm32f4x.cfg            # Generic F4 family (most common)
target/stm32f427.cfg
target/stm32f429.cfg
target/stm32f446.cfg
target/stm32f469.cfg
target/stm32f4discovery.cfg    # STM32F4 Discovery board
target/stm32f429discovery.cfg
```

- Flash driver command: `stm32f2x` (covers F1/F2/F3/F4)
- Mass erase: `stm32f2x mass_erase 0`

### STM32F7 (Cortex-M7)
```
target/stm32f7x.cfg            # Generic F7 family
target/stm32f746g.cfg
target/stm32f7discovery.cfg
target/stm32f7 nucleo
```

- Flash driver: `stm32f2x`
- Mass erase: `stm32f2x mass_erase 0`

### STM32G0 (Cortex-M0+)
```
target/stm32g0x.cfg
target/stm32g0b1x.cfg
```

- Flash driver: `stm32g0x`
- Mass erase: `stm32g0x mass_erase 0`

### STM32G4 (Cortex-M4F)
```
target/stm32g4x.cfg
```

- Flash driver: `stm32g0x`
- Mass erase: `stm32g0x mass_erase 0`

### STM32H7 (Cortex-M7 / M7+M4)
```
# Single-core H7
target/stm32h7x.cfg
target/stm32h747.cfg

# Dual-core H7 (H745/H755/H747/H757)
target/stm32h745.cfg
target/stm32h745_dual_bank.cfg
target/stm32h747.cfg
target/stm32h7b3x.cfg
target/stm32h7b3_discovery.cfg
```

- Flash driver: `stm32h7x`
- Dual-core note: use `targets` to list both cores, `targets <name>` to switch
- Mass erase: `stm32h7x mass_erase 0`

### STM32L0 (Cortex-M0+)
```
target/stm32l0.cfg
target/stm32l011x.cfg
target/stm32l053x.cfg
target/stm32l073z.cfg
```

- Flash driver: `stm32l0`
- Mass erase: `stm32l0 mass_erase 0`

### STM32L1 (Cortex-M3)
```
target/stm32l1.cfg
```

- Flash driver: `stm32l1`
- Mass erase: `stm32l1 mass_erase 0`

### STM32L4 (Cortex-M4F)
```
target/stm32l4x.cfg
target/stm32l476g.cfg
target/stm32l4p5g.cfg
target/stm32l4r5.cfg
```

- Flash driver: `stm32l4x`
- Mass erase: `stm32l4x mass_erase 0`

### STM32L5 (Cortex-M33, TrustZone)
```
target/stm32l5x.cfg
```

- Flash driver: `stm32l5x`
- Mass erase: `stm32l5x mass_erase 0`

### STM32U5 (Cortex-M33, Ultra-low-power)
```
target/stm32u5x.cfg
target/stm32u59x_ultra.cfg
```

- Flash driver: `stm32u5x`
- Mass erase: `stm32u5x mass_erase 0`

### STM32WB (Cortex-M4+M0+, Wireless)
```
target/stm32wbx.cfg
target/stm32wb55.cfg
```

- Flash driver: `stm32wbx`
- Mass erase: `stm32wbx mass_erase 0`

### STM32WL (Cortex-M4+M0+, LoRa)
```
target/stm32wlx.cfg
```

- Flash driver: `stm32wlx`
- Mass erase: `stm32wlx mass_erase 0`

### STM32MP1 (Cortex-M4 + Cortex-A7)
```
target/stm32mp15x.cfg
```

- Multi-core: M4 is typically target 0, A7 targets accessible via DAP
- Note: for A7 debug, you'll typically use OpenOCD just to load firmware to the M4

---

## NXP Semiconductors

### i.MX RT (Cortex-M7 / M7+M4)
```
# RT10xx (M7 only)
target/imxrt1050.cfg
target/imxrt1060.cfg
target/imxrt1064.cfg
target/imxrt1020.cfg

# RT11xx (M7+M4 dual core)
target/imxrt1170.cfg

# RT6xx (M33+M33 dual core)
target/imxrt600.cfg
```

- Flash driver: `imxrt`
- Mass erase: `imxrt mass_erase 0`
- Key quirk: i.MX RT has no internal flash. It boots from external QSPI/HyperFlash. OpenOCD can write to external flash if the SEMC/QSPI is configured.

### Kinetis (Cortex-M4F / M0+)
```
target/kx.cfg                    # Generic K series (M4F)
target/klx.cfg                   # Generic KL series (M0+)
target/kw41z.cfg
target/k82f25615.cfg
target/ke04.cfg
```

- Flash driver: `kinetis`
- Mass erase: `kinetis mass_erase 0`

### LPC (Various cores)
```
# LPC17xx (Cortex-M3)
target/lpc17xx.cfg
target/lpc1768.cfg

# LPC8xx (Cortex-M0+)
target/lpc8xx.cfg
target/lpc812.cfg

# LPC43xx (M4+M0 dual core)
target/lpc4350.cfg
target/lpc4370.cfg

# LPC11xx (Cortex-M0)
target/lpc11xx.cfg

# LPC13xx (Cortex-M3)
target/lpc13xx.cfg

# LPC40xx (Cortex-M4F)
target/lpc40xx.cfg

# LPC54xx (Cortex-M4F)
target/lpc54628.cfg
target/lpc5411x.cfg

# LPC55xx (Cortex-M33, TrustZone)
target/lpc55s69.cfg
target/lpc55s69_ns.cfg        # Non-secure mode
target/lpc55s28.cfg
```

- Flash driver: `lpc2000`
- Mass erase: `lpc2000 mass_erase 0`

---

## Nordic Semiconductor

### nRF51 (Cortex-M0)
```
target/nrf51.cfg
```

- Flash driver: `nrf51`
- Mass erase: `nrf51 mass_erase`
- Note: no `0` argument for nRF51 mass erase

### nRF52 (Cortex-M4F)
```
target/nrf52.cfg               # Generic nRF52
target/nrf52810.cfg
target/nrf52832.cfg
target/nrf52833.cfg
target/nrf52840.cfg
```

- Flash driver: `nrf52`
- Mass erase: `nrf52 mass_erase`
- Key quirk: nRF52 has readback protection (APPROTECT). If readback is enabled, the debug port is disabled. Use `nrf52_recover` command or `nrfjprog --recover` to regain access.

### nRF53 (Cortex-M33 dual-core)
```
target/nrf53.cfg
target/nrf5340.cfg
```

- Flash driver: `nrf53`
- Mass erase: `nrf53 mass_erase`
- Dual-core: app core (M33) + network core (M33). Core 0 = app, core 1 = net.

### nRF91 (Cortex-M33, cellular)
```
target/nrf91.cfg
target/nrf9160.cfg
```

- Flash driver: `nrf91`
- Mass erase: `nrf91 mass_erase`

---

## Texas Instruments

### CC13xx / CC26xx (Cortex-M4F, wireless)
```
target/ti_cc13x2.cfg
target/ti_cc26x2.cfg
target/ti_cc13x0.cfg
target/ti_cc26x0.cfg
```

- Flash driver: `cc26xx`
- Interface: `interface/xds110.cfg` (LaunchPad onboard debugger) or `interface/cmsis-dap.cfg`

### MSP432 (Cortex-M4F)
```
target/msp432p4.cfg
```

### TM4C (Tiva C, Cortex-M4F)
```
target/tm4c123.cfg
target/tm4c129.cfg
```

### AM335x (Cortex-A8, BeagleBone)
```
target/am335x.cfg
target/am335xevmsk.cfg
target/am335xgpevm.cfg
```

### Hercules (Cortex-R4F/R5F, safety)
```
target/ti_hercules.cfg
```

---

## Microchip (Atmel)

### SAM D (Cortex-M0+)
```
target/atsamd21.cfg
target/atsamd21g18.cfg
target/atsamd21g_xplained_pro.cfg
target/atsamd21j18.cfg
```

### SAM E (Cortex-M4F)
```
target/atsame53.cfg
target/atsame54.cfg
target/atsame70.cfg
```

### SAM V7 (Cortex-M7)
```
target/atsamv71.cfg
target/atsamv71_xplained_ultra.cfg
target/atsamv71q21.cfg
```

### SAM S (Cortex-M4F)
```
target/atsams70.cfg
```

### Flash commands:
- Driver: `atsamv`
- Mass erase: `atsamv mass_erase 0`

### SAMA5 (Cortex-A5, MPU)
```
target/sama5d2.cfg
target/sama5d3.cfg
target/sama5d4.cfg
```

---

## GigaDevice

### GD32 Cortex-M
```
target/gd32f1x0.cfg            # Cortex-M3
target/gd32f3x0.cfg            # Cortex-M4F
target/gd32f4xx.cfg            # Cortex-M4F
target/gd32e23x.cfg            # Cortex-M23
```

### GD32V (RISC-V)
```
target/gd32vf103.cfg           # Bumblebee RISC-V
```

- Flash driver: `gd32vf103`
- Mass erase: `gd32vf103 mass_erase 0`

---

## Nuvoton

```
# Cortex-M0
target/numicro.cfg
target/numicroM05x.cfg
target/numicroM0_iswd.cfg      # Internal SWD config

# Cortex-M4F
target/numicroM4.cfg

# Cortex-M23
target/numicroM23x.cfg

# ARM9 (NUC970)
target/nuc970.cfg
```

---

## Espressif (ESP32)

```
target/esp32.cfg               # ESP32 (Xtensa LX6, JTAG only)
target/esp32s2.cfg             # ESP32-S2 (Xtensa LX7)
target/esp32s3.cfg             # ESP32-S3 (Xtensa LX7)
```

- **JTAG only**: ESP32 does NOT support SWD. You must use JTAG mode.
- Interface: `interface/ftdi/esp32_devkitj_v1.cfg` or `interface/ftdi/esp-wroom-32.cfg`
- `adapter_khz 20000` is typical for FTDI-based ESP32 probes

---

## Raspberry Pi

### RP2040 (Cortex-M0+ dual-core)
```
target/rp2040.cfg
target/rp2040-core0.cfg        # Core 0 only
```

- Dual-core: core 0 and core 1 are separate OpenOCD targets
- Flash driver: `rp2040`
- Mass erase: `rp2040 mass_erase 0`

### BCM2835/2836/2837 (Cortex-A53, Raspberry Pi 2/3/Zero)
```
target/bcm2835.cfg
target/bcm2836.cfg
target/bcm2837.cfg
```

- Requires direct JTAG connection to RPi GPIO (not via USB)

---

## RISC-V

```
target/sifive-freedom.cfg           # SiFive FE310
target/gd32vf103.cfg                # GigaDevice GD32VF103
```

---

## Quick-Lookup: Flash Driver Name → Mass Erase Command

Use this table when you need to do a mass erase but don't know the command:

| Flash Driver (from `flash banks`) | Mass Erase Command |
|-----------------------------------|-------------------|
| `stm32f1x` | `stm32f1x mass_erase 0` |
| `stm32f2x` | `stm32f2x mass_erase 0` |
| `stm32g0x` | `stm32g0x mass_erase 0` |
| `stm32h7x` | `stm32h7x mass_erase 0` |
| `stm32l0` | `stm32l0 mass_erase 0` |
| `stm32l1` | `stm32l1 mass_erase 0` |
| `stm32l4x` | `stm32l4x mass_erase 0` |
| `stm32l5x` | `stm32l5x mass_erase 0` |
| `stm32u5x` | `stm32u5x mass_erase 0` |
| `stm32wbx` | `stm32wbx mass_erase 0` |
| `stm32wlx` | `stm32wlx mass_erase 0` |
| `nrf51` | `nrf51 mass_erase` (no `0`) |
| `nrf52` | `nrf52 mass_erase` (no `0`) |
| `nrf53` | `nrf53 mass_erase` (no `0`) |
| `nrf91` | `nrf91 mass_erase` (no `0`) |
| `imxrt` | `imxrt mass_erase 0` |
| `kinetis` | `kinetis mass_erase 0` |
| `lpc2000` | `lpc2000 mass_erase 0` |
| `atsamv` | `atsamv mass_erase 0` |
| `rp2040` | `rp2040 mass_erase 0` |
| `gd32vf103` | `gd32vf103 mass_erase 0` |
| `cc26xx` | `cc26xx mass_erase 0` |
| `stm32mp15x` | `stm32mp15x mass_erase 0` |
