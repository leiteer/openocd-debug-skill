# Debug Probe Reference Guide

Complete reference for all debug probes supported by OpenOCD. Use this to pick the right probe for your target and understand each probe's capabilities, pinouts, and quirks.

---

## ST-LINK (STMicroelectronics)

### Variants

| Model | SWD Speed | JTAG | VCP | MSD | Notes |
|-------|-----------|------|-----|-----|-------|
| ST-LINK/V1 | 500 kHz | Yes | No | No | Discontinued; rare |
| ST-LINK/V2 | 1800 kHz | Yes | No | No | Most common clone target |
| ST-LINK/V2-1 | 1800-4800 kHz | No | Yes | Yes | Built into Nucleo/Discovery boards |
| ST-LINK/V3 | 4800-24000 kHz | Yes | Yes | Yes | Newest; current production |

### Interface Config

```
interface/stlink.cfg           # Default (auto-detect v2/v2-1/v3)
interface/stlink-v2.cfg        # Force V2
interface/stlink-v2-1.cfg      # Force V2-1
interface/stlink-v3.cfg        # Force V3
```

### Pinout (SWD mode)

```
ST-LINK/V2 (20-pin header):
Pin 1  VCC_TARGET (sense)
Pin 2  SWCLK / TCK
Pin 3  GND
Pin 4  SWDIO / TMS
Pin 5  GND
Pin 9  SWO (optional, serial wire viewer)
Pin 15 NRST (optional, reset)

ST-LINK/V2-1 (6-pin CN2 on Nucleo/Discovery):
Pin 1  VCC_TARGET
Pin 2  SWCLK
Pin 3  GND
Pin 4  SWDIO
Pin 5  NRST
Pin 6  SWO
```

### Quirks

1. **ST-LINK/V2 clones** (common on AliExpress) often fail at speeds >500 kHz. If you see random communication errors, drop to `adapter speed 100`.
2. **ST-LINK/V2-1** on Nucleo boards: the SWD header is shared with the onboard STM32F103 (ST-LINK MCU). To debug an external target, remove the two ST-LINK jumpers (CN2) and connect your external board.
3. **VCP (Virtual COM Port)**: on V2-1/V3, the ST-LINK provides a UART bridge. This is NOT required for debugging — it's only for your application's UART output.
4. **MSD (Mass Storage Device)**: dragging a .bin file onto the ST-LINK drive auto-flashes it. This uses a different mechanism (not OpenOCD) and is less reliable for large binaries.

---

## J-Link (Segger)

### Variants

| Model | Max Speed | JTAG | SWD | ETM | Notes |
|-------|-----------|------|-----|-----|-------|
| J-Link EDU / EDU Mini | 15 MHz | Yes | Yes | No | Educational use only |
| J-Link BASE | 15 MHz | Yes | Yes | No | Commercial entry-level |
| J-Link PLUS | 15 MHz | Yes | Yes | Yes | Full commercial |
| J-Link ULTRA+ | 50 MHz | Yes | Yes | Yes | High-speed commercial |
| J-Link PRO | 50 MHz | Yes | Yes | Yes | Ethernet, highest end |

### Interface Config

```
interface/jlink.cfg            # Standard
interface/jlink_swd.cfg        # Force SWD mode
```

### OpenOCD-Specific Notes

J-Link requires additional `-c` commands for optimal setup:

```bash
openocd ... -f interface/jlink.cfg -f target/stm32f4x.cfg \
  -c "adapter speed 4000" \
  -c "transport select swd" \       # Explicitly select SWD
  -c "jlink device STM32F407VG"    # Tell J-Link the exact chip
```

### Quirks

1. **J-Link software required**: OpenOCD communicates with the J-Link via Segger's shared library (libjlinkarm). On Linux/macOS, install the J-Link Software Pack from segger.com.
2. **EDU model legal restriction**: J-Link EDU can only be used for non-commercial/educational purposes. The hardware is identical to BASE.
3. **Serial number**: if you have multiple J-Links connected, use `-c "jlink serial 123456789"`.
4. **Speed**: J-Link can reliably run at 4000-12000 kHz in SWD mode, making it 4-20x faster than ST-LINK/V2 for flash writes.

### Alternative: J-Link GDB Server

Segger's own GDB server (`JLinkGDBServer`) is often faster than OpenOCD+J-Link for pure debugging. Use OpenOCD when you need both flash and GDB or when you want the OpenOCD command set.

```bash
# Start J-Link GDB Server (separate from OpenOCD)
JLinkGDBServer -device STM32F407VG -if SWD -speed 4000
# Connect GDB to port 2331
```

---

## CMSIS-DAP / DAPLink

### Variants

| Probe | Topology | Speed | Interface |
|-------|----------|-------|-----------|
| DAPLink (ARM Mbed) | CMSIS-DAP v1 (HID) | ~64-128 kHz | SWD only |
| DAPLink v2 (CMSIS-DAP v2) | USB Bulk | Up to 1000 kHz | SWD, JTAG |
| MCU-Link (NXP) | CMSIS-DAP v2 | Up to 1000 kHz | SWD, JTAG |
| MCU-Link Pro (NXP) | CMSIS-DAP v2 | Up to 5000 kHz | SWD, JTAG, ETM |
| LPC-Link2 (NXP) | CMSIS-DAP v1/v2 | Up to 1000 kHz | SWD, JTAG |
| on-board debuggers (many dev kits) | CMSIS-DAP v1 (HID) | ~64 kHz | SWD |

### Interface Config

```
interface/cmsis-dap.cfg            # Standard
interface/cmsis-dap_swd.cfg        # Force SWD mode (often needed)
```

### Quirks

1. **HID vs Bulk**: CMSIS-DAP v1 uses USB HID (slow, ~64 KB/s). v2 uses USB Bulk (faster). If your flash is >64KB, v1 will be painfully slow.
2. **Speed ceiling**: CMSIS-DAP v1 caps at ~128 kHz adapter speed. v2 caps at ~1000 kHz (unless it's a premium probe like MCU-Link Pro).
3. **Multiple probes**: use `-c "cmsis_dap_serial 0123456789"` or `-c "cmsis_dap_backend hid"` to select.
4. **NXP MCU-Link**: ships as CMSIS-DAP v2; firmware can be updated to J-Link mode (LPCScrypt tool).
5. **NXP LPC-Link2**: can run as CMSIS-DAP or J-Link depending on firmware flashed to its LPC4370.

---

## FTDI-based Probes

### Supported Chips

| Chip | Config | Max Speed | Notes |
|------|--------|-----------|-------|
| FT2232H | `interface/ftdi/ft2232h.cfg` | 30000 kHz | Most common |
| FT232H | `interface/ftdi/ft232h.cfg` | 30000 kHz | Single-channel |
| FT4232H | `interface/ftdi/ft4232h.cfg` | 30000 kHz | 4-channel |

### Device-Specific Configs

OpenOCD ships with pre-configured layouts for many boards that use onboard FTDI chips:

```
interface/ftdi/digilent-hs1.cfg        # Digilent HS1 JTAG
interface/ftdi/olimex-arm-usb-ocd.cfg  # Olimex ARM-USB-OCD
interface/ftdi/olimex-arm-usb-ocd-h.cfg
interface/ftdi/olimex-arm-usb-tiny-h.cfg
interface/ftdi/redbee-econotag.cfg
interface/ftdi/redbee-usb.cfg
interface/ftdi/um232h.cfg
interface/ftdi/tumpa.cfg
```

### Quirks

1. **Driver conflict**: on Linux, FTDI chips appear as `/dev/ttyUSBx`. You MUST unload the `ftdi_sio` kernel module or set the udev rule to let OpenOCD access the raw USB device.
2. **VID/PID**: custom boards may need `-c "ftdi_vid_pid 0x0403 0x6014"`.
3. **Layout config**: `-c "ftdi_layout_init 0x0008 0x000b"` sets the pin mux.

---

## Raspberry Pi GPIO Bit-bang

### Requirements

- Raspberry Pi (any model with 40-pin GPIO header)
- Linux with `linuxgpiod` driver support
- GPIO pins connected directly to target SWD (with level shifters if target is 1.8V or 5V)

### Interface Config

```
interface/raspberrypi2-native.cfg
```

### Pin Connections

```
Raspberry Pi GPIO        Target SWD
Pin 22 (BCM 25)     →    SWCLK
Pin 18 (BCM 24)     →    SWDIO
Pin 20 (GND)        →    GND
Optional:
Pin 16 (BCM 23)     →    NRST
Pin 12 (BCM 18)     →    SWO
```

### Quirks

1. **Speed**: max ~1000 kHz, but 500 kHz is more reliable.
2. **Voltage**: Raspberry Pi GPIOs are 3.3V. If your target is 1.8V or 5V, you MUST use level shifters.
3. **CPU load**: the bit-bang driver runs in userspace and consumes significant CPU during fast SWD transfers.

---

## Remote Bitbang

Used for connecting OpenOCD to a remote target via TCP socket — common with Verilator, QEMU, or remote hardware servers.

### Interface Config

```
interface/remote_bitbang.cfg
```

### Usage

```bash
# Start the remote bitbang server first, then:
openocd -f interface/remote_bitbang.cfg -c "remote_bitbang_port 5555" -c "remote_bitbang_host 192.168.1.100"
```

---

## Other Probes

### Bus Pirate

```
interface/buspirate.cfg
```
- Low speed (~100 kHz), inexpensive, universal
- Good for slow debugging or rare/one-off use

### OpenJTAG

```
interface/openjtag.cfg
```
- USB-JTAG adapter using FTDI + CPLD
- Moderate speed (~500 kHz)

### xds110 (Texas Instruments)

```
interface/xds110.cfg
```
- Built into TI LaunchPad boards
- Primarily for TI CC13xx/CC26xx/MSP432
- Requires TI xds110 firmware driver

### ULINK (Keil)

```
interface/ulink.cfg
```
- Keil MDK debug probe
- Limited OpenOCD support (some ULINK versions work, some don't)

---

## Speed Selection Guide

**Recommended starting speeds (conservative) → tested maximum:**

| Probe | Conservative | Tested Max |
|-------|-------------|------------|
| ST-LINK/V2 | 500 kHz | 1800 kHz |
| ST-LINK/V2-1 | 500 kHz | 4800 kHz |
| ST-LINK/V3 | 1000 kHz | 24000 kHz |
| ST-LINK/V2 clone | 100 kHz | 500 kHz |
| J-Link | 1000 kHz | 15000 kHz |
| CMSIS-DAP v1 (HID) | 64 kHz | 128 kHz |
| CMSIS-DAP v2 | 500 kHz | 1000 kHz |
| MCU-Link Pro | 1000 kHz | 5000 kHz |
| FT2232H | 1000 kHz | 30000 kHz |
| Raspberry Pi GPIO | 100 kHz | 1000 kHz |
| Bus Pirate | 100 kHz | 100 kHz |

**Rule of thumb**: start at the conservative speed. If flash and register reads work reliably, double it and retry. Stop when you see communication errors.

---

## Troubleshooting Probe Issues

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `Error: open failed` | Permission denied on USB device | Linux: add udev rule. Windows: install WinUSB driver via Zadig |
| `Error: LIBUSB_ERROR_ACCESS` | Another process has the probe | Kill other debug servers (JLinkGDBServer, pyOCD, etc.) |
| `Error: init mode failed` | Target not responding | Check physical connections; try `connect_assert_srst` |
| `SWD ack NOT OK` / `DAP transaction stalled` | SWD signal integrity | Reduce adapter speed; check wiring length (<10cm) |
| `Error: JTAG-DP STICKY ERROR` | SWD communication error | Reduce speed; check power; reseat connector |
| Adapter not detected (USB) | Missing driver | Linux: `lsusb`, check udev. Windows: Zadig to install WinUSB |
