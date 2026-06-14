# Universal Register Discovery & Reference

This guide teaches you **how to find ANY peripheral register address** for ANY chip that OpenOCD supports. No more guessing hex addresses — learn the universal method.

---

## The Universal Method: From Datasheet to OpenOCD Command

```
Reference Manual (from chip vendor)
  └── Chapter 2~3: "Memory Map" / "Memory and Bus Architecture"
       └── Find: <peripheral> base address
            └── Chapter for that peripheral: "Register Description" table
                 └── Offset + Base = Full address → mdw in OpenOCD
```

### Worked Example: STM32F407 GPIOB ODR

1. Download **RM0090** (STM32F4 Reference Manual) from st.com
2. **Section 2.3 "Memory Map"** → Table 2: "STM32F40x register boundary addresses"
   - AHB1 peripherals start at 0x4002 0000
   - GPIOB starts at 0x4002 0400
3. **Section 8.4 "GPIO registers"** → GPIO register map table:
   - ODR offset = 0x14
4. **Calculation**: 0x40020400 + 0x14 = **0x40020414**

OpenOCD command:
```tcl
mdw 0x40020414
```

### Worked Example: nRF52840 GPIO P0 OUT

1. Download **nRF52840 Product Specification v1.7** from nordicsemi.com
2. **Section 5 "Memory"** → Instantiation table:
   - P0 base = 0x50000000
3. **Section 6.8.2 "Registers"** → GPIO registers:
   - OUT offset = 0x504
4. **Calculation**: 0x50000000 + 0x504 = **0x50000504**

OpenOCD command:
```tcl
mdw 0x50000504
```

### Worked Example: i.MX RT1064 GPIO1 DR

1. Download **i.MX RT1060 Reference Manual** from nxp.com
2. **Chapter 2 "Memory Maps"** → AIPS-1 peripherals:
   - GPIO1 base = 0x401B8000
3. **Chapter 28 "GPIO"** → Register descriptions:
   - DR (Data Register) offset = 0x0
   - GDIR (Direction) offset = 0x4
   - PSR (Pad Status) offset = 0x8
4. **Calculation**: 0x401B8000 + 0 = **0x401B8000**

OpenOCD command:
```tcl
mdw 0x401B8000
```

---

## ARM Cortex-M Standard Registers

These registers have the **IDENTICAL address** on ALL Cortex-M chips (M0/M0+/M3/M4/M4F/M7/M23/M33/M55) — regardless of whether it's STM32, NXP, Nordic, TI, Microchip, GigaDevice, Nuvoton, or any other vendor. This is guaranteed by the ARMv6-M/v7-M/v8-M architecture specification.

### System Control Block (SCB) — 0xE000ED00

| Register | Address | Access | Description |
|----------|---------|--------|-------------|
| CPUID | 0xE000ED00 | RO | CPU identifier + implementer + variant |
| ICSR | 0xE000ED04 | RW | Interrupt Control and State |
| VTOR | 0xE000ED08 | RW | Vector Table Offset Register |
| AIRCR | 0xE000ED0C | RW | Application Interrupt and Reset Control |
| SCR | 0xE000ED10 | RW | System Control Register |
| CCR | 0xE000ED14 | RW | Configuration and Control Register |
| SHPR1 | 0xE000ED18 | RW | System Handler Priority 1 (MemManage, BusFault, UsageFault) |
| SHPR2 | 0xE000ED1C | RW | System Handler Priority 2 (SVCall) |
| SHPR3 | 0xE000ED20 | RW | System Handler Priority 3 (SysTick, PendSV) |
| SHCSR | 0xE000ED24 | RW | System Handler Control and State |
| CFSR | 0xE000ED28 | RW | Configurable Fault Status (byte 0=MFSR, byte 1=BFSR, byte 2=UFSR) |
| HFSR | 0xE000ED2C | RW | HardFault Status Register |
| DFSR | 0xE000ED30 | RW | Debug Fault Status Register |
| MMFAR | 0xE000ED34 | RW | MemManage Fault Address Register |
| BFAR | 0xE000ED38 | RW | BusFault Address Register |
| AFSR | 0xE000ED3C | RW | Auxiliary Fault Status Register |

#### CPUID (0xE000ED00) Implementation Codes

| Value | Core | Example Chips |
|-------|------|---------------|
| 0x410CC200 | Cortex-M0 r0p0 | STM32F0, NXP LPC11xx |
| 0x410CC601 | Cortex-M0+ r0p1 | STM32G0, NXP Kinetis L |
| 0x410FC231 | Cortex-M3 r1p1 | STM32F1, NXP LPC17xx |
| 0x410FC240 | Cortex-M4 r0p0 | STM32F3/F4, nRF52840, GD32F4xx |
| 0x410FC241 | Cortex-M4 r0p1 | STM32F4 (rev 3+) |
| 0x410FC270 | Cortex-M7 r0p0 | STM32F746 |
| 0x410FC271 | Cortex-M7 r0p1 | STM32F7/H7, i.MX RT1064 |
| 0x410FD210 | Cortex-M23 r0p0 | Nuvoton M2351 |
| 0x410FD213 | Cortex-M33 r0p3 | STM32L5/U5, nRF5340, LPC55S69 |
| 0x410FD220 | Cortex-M55 r0p0 | Newest M-profile |

#### SHCSR (0xE000ED24) — Fault Handler Enable Bits

| Bit | Name | Meaning |
|-----|------|---------|
| 15 | USGFAULTENA | UsageFault Handler Enabled |
| 16 | BUSFAULTENA | BusFault Handler Enabled |
| 17 | MEMFAULTENA | MemManage Handler Enabled |
| 18 | SVCALLPENDED | SVCall is pending |

**Diagnostic**: If a fault escalates to HardFault, check SHCSR bits 15-17. If they're 0, the detailed fault handlers aren't enabled — the core escalates to generic HardFault.

#### CFSR (0xE000ED28) — Fault Status Breakdown

CFSR is a 32-bit register consisting of 3 sub-registers:

```
Bits [31:16]: UFSR (UsageFault Status)
Bits [15:8]:  BFSR (BusFault Status)
Bits [7:0]:   MFSR (MemManage Status)
```

**MFSR (byte 0, bits 7:0)** — MemManage Fault:

| Bit | Name | Meaning |
|-----|------|---------|
| 0 | IACCVIOL | Instruction access violation. PC points to non-executable or protected code region |
| 1 | DACCVIOL | Data access violation. Load/store to MPU-protected data region |
| 3 | MUNSTKERR | Unstacking error. Stack corrupt during exception return |
| 4 | MSTKERR | Stacking error. Stack corrupt during exception entry |
| 5 | MLSPERR | FPU lazy state preservation error |
| 7 | MMARVALID | If 1, MMFAR holds valid faulting address |

**BFSR (byte 1, bits 15:8)** — BusFault:

| Bit | Name | Meaning |
|-----|------|---------|
| 8 | IBUSERR | Instruction bus error (prefetch abort) |
| 9 | PRECISERR | Precise data bus error. BFAR holds valid address |
| 10 | IMPRECISERR | Imprecise bus error. BFAR invalid — harder to debug |
| 11 | UNSTKERR | Bus error during unstacking |
| 12 | STKERR | Bus error during stacking |
| 13 | LSPERR | Bus error during FPU lazy state |
| 15 | BFARVALID | If 1, BFAR holds valid faulting address |

**UFSR (bytes 2-3, bits 31:16)** — UsageFault:

| Bit | Name | Meaning |
|-----|------|---------|
| 16 | UNDEFINSTR | Undefined instruction executed |
| 17 | INVSTATE | Invalid processor state (EPSR.T=0, or illegal interworking) |
| 18 | INVPC | Invalid PC load (EXC_RETURN misused, PC loaded with non-halfword-aligned address) |
| 19 | NOCP | No Coprocessor. FPU instruction while FPU disabled |
| 24 | UNALIGNED | Unaligned memory access (with UNALIGN_TRP=1) |
| 25 | DIVBYZERO | Integer divide by zero (with DIV_0_TRP=1) |

#### HFSR (0xE000ED2C) — HardFault Status

| Bit | Name | Meaning |
|-----|------|---------|
| 1 | VECTTBL | BusFault during vector table read |
| 30 | FORCED | HardFault was escalated from another fault (check CFSR for actual cause) |
| 31 | DEBUGEVT | Debug event triggered (rare) |

**Key diagnostic**: If `HFSR bit30 == 1`, the actual fault is in CFSR. Enable MemManage/BusFault/UsageFault handlers in SHCSR to catch them directly.

### NVIC — Nested Vectored Interrupt Controller — 0xE000E100

| Register Range | Address | Purpose |
|----------------|---------|---------|
| NVIC_ISER[0..7] | 0xE000E100 | Interrupt Set-Enable |
| NVIC_ICER[0..7] | 0xE000E180 | Interrupt Clear-Enable |
| NVIC_ISPR[0..7] | 0xE000E200 | Interrupt Set-Pending |
| NVIC_ICPR[0..7] | 0xE000E280 | Interrupt Clear-Pending |
| NVIC_IABR[0..7] | 0xE000E300 | Interrupt Active Bit (read-only) |
| NVIC_IPR[0..59] | 0xE000E400 | Interrupt Priority (8 bits per IRQ, only top 4-8 used) |

**Diagnostic**: Read `mdw 0xE000E200` to see all pending interrupts (NVIC_ISPR0 covers IRQ 0-31).

### SysTick — 0xE000E010

| Register | Address | Description |
|----------|---------|-------------|
| SYST_CSR | 0xE000E010 | SysTick Control & Status |
| SYST_RVR | 0xE000E014 | Reload Value |
| SYST_CVR | 0xE000E018 | Current Value |
| SYST_CALIB | 0xE000E01C | Calibration (10ms tick count) |

### Memory Protection Unit (MPU) — optional — 0xE000ED90

| Register | Address | Description |
|----------|---------|-------------|
| MPU_TYPE | 0xE000ED90 | MPU Type (number of regions) |
| MPU_CTRL | 0xE000ED94 | MPU Control (ENABLE, PRIVDEFENA) |
| MPU_RNR | 0xE000ED98 | Region Number |
| MPU_RBAR | 0xE000ED9C | Region Base Address |
| MPU_RASR | 0xE000EDA0 | Region Attribute & Size |

Diagnostic: `mdw 0xE000ED94` → bit0=1 means MPU enabled. If you can't access peripheral memory, check if MPU is blocking it.

---

## Common Peripheral Register Layouts

These are **typical** patterns found across most ARM Cortex-M MCUs. Exact offsets may vary slightly — always verify against the specific chip's Reference Manual.

### GPIO Registers

| Offset | Typical Name | Description |
|--------|-------------|-------------|
| 0x00 | MODER / DIR / CFG | Pin mode (2 bits per pin): 00=input, 01=output, 10=AF, 11=analog |
| 0x04 | OTYPER / TYPE | Output type: 0=push-pull, 1=open-drain |
| 0x08 | OSPEEDR / SPEED | Output speed: 00=low, 01=medium, 10=high, 11=very high |
| 0x0C | PUPDR / PUPD / PIN_CNF | Pull-up/down: 00=none, 01=pull-up, 10=pull-down |
| 0x10 | IDR / IN / DIN | Input data register (read current pin level) |
| 0x14 | ODR / OUT / DOUT | Output data register |
| 0x18 | BSRR / BSC / SET/CLR | Atomic bit set/reset (write 1 to set, write 1<<16 to reset on STM32) |
| 0x20 | AFRL / PMUX[0] | Alternate function for pins 0-7 (4 bits each) |
| 0x24 | AFRH / PMUX[1] | Alternate function for pins 8-15 |

### UART/USART Registers

| Offset | Typical Name | Description |
|--------|-------------|-------------|
| 0x00 | SR / STAT / STATUS | Status (TXE, RXNE, TC, errors) |
| 0x04 | DR / DATA / RXD | Data register (read=RX, write=TX) |
| 0x08 | BRR / BAUD / BAUDDIV | Baud rate divider |
| 0x0C | CR1 / CTRL / CONFIG | Control 1 (UE, RXNEIE, TE, RE, word length) |
| 0x10 | CR2 | Control 2 (STOP bits, CLK) |
| 0x14 | CR3 | Control 3 (CTS/RTS, DMA) |

### SPI Registers

| Offset | Typical Name | Description |
|--------|-------------|-------------|
| 0x00 | CR1 / CTL / CONFIG | Control 1 (SPE, BR, MSTR, CPOL, CPHA) |
| 0x04 | CR2 / CTL2 | Control 2 (SSOE, TXEIE, RXNEIE) |
| 0x08 | SR / STAT | Status (BSY, TXE, RXNE, error flags) |
| 0x0C | DR / DATA / TXDR | Data register |

### I2C Registers

| Offset | Typical Name | Description |
|--------|-------------|-------------|
| 0x00 | CR1 / CONFIG | Control 1 (PE, START, STOP, ACK) |
| 0x04 | CR2 | Control 2 (FREQ, ITERREN) |
| 0x08 | OAR1 | Own Address 1 |
| 0x0C | OAR2 | Own Address 2 |
| 0x10 | DR / TXDR | Data register |
| 0x14 | SR1 | Status 1 (SB, ADDR, TXE, RXNE, BTF) |
| 0x18 | SR2 | Status 2 (BUSY, MSL) |
| 0x1C | CCR / TIMING | Clock control |

### TIM (General-purpose Timer) Registers

| Offset | Typical Name | Description |
|--------|-------------|-------------|
| 0x00 | CR1 | Control 1 (CEN, UDIS, ARPE) |
| 0x04 | CR2 | Control 2 (MMS, CCDS) |
| 0x08 | SMCR | Slave mode control |
| 0x0C | DIER | DMA/Interrupt enable |
| 0x10 | SR | Status (UIF, CCxIF) |
| 0x14 | EGR | Event generation |
| 0x24 | CNT | Counter current value |
| 0x28 | PSC | Prescaler (division factor) |
| 0x2C | ARR | Auto-reload (period) |
| 0x34 | CCR1 | Capture/Compare channel 1 |
| 0x38 | CCR2 | Capture/Compare channel 2 |
| 0x3C | CCR3 | Capture/Compare channel 3 |
| 0x40 | CCR4 | Capture/Compare channel 4 |

### RCC / Clock Control (STM32-specific)

| Register | Offset from RCC_BASE | Description |
|----------|---------------------|-------------|
| RCC_CR | 0x00 | Clock Control (HSI/HSE/PLL enable & ready) |
| RCC_PLLCFGR | 0x04 | PLL Configuration (source, M/N/P/Q dividers) |
| RCC_CFGR | 0x08 | Clock Configuration (SYSCLK source, AHB/APB prescalers) |
| RCC_CIR | 0x0C | Clock Interrupt |
| RCC_AHB1RSTR | 0x10 | AHB1 peripheral reset |
| RCC_AHB2RSTR | 0x14 | AHB2 peripheral reset |
| RCC_APB1RSTR | 0x20 | APB1 peripheral reset |
| RCC_APB2RSTR | 0x24 | APB2 peripheral reset |
| RCC_AHB1ENR | 0x30 | AHB1 peripheral clock enable |
| RCC_AHB2ENR | 0x34 | AHB2 peripheral clock enable |
| RCC_APB1ENR | 0x40 | APB1 peripheral clock enable |
| RCC_APB2ENR | 0x44 | APB2 peripheral clock enable |
| RCC_BDCR | 0x70 | Backup domain control (RTC, LSE) |
| RCC_CSR | 0x74 | Control/Status (LSI, reset flags) |

---

## Practical OpenOCD Command Translations

### Bit Manipulation from Datasheet to OpenOCD

When a datasheet says: "Register at offset 0x14, bit 7 = TXE (Transmit Empty)"

```tcl
# Read register
mdw 0x40013814

# Isolate bit 7
# In your head: 0x00000200 & result → non-zero = TXE is set

# OpenOCD can't do bitwise operations directly, so you compare manually:
# If result is 0x00000080, bit 7 is set (= data register empty, ready to transmit)
```

### Reading Multiple Registers in One Shot

```tcl
# Dump 8 consecutive 32-bit registers starting at GPIOA_MODER
mdw 0x40020000 8

# Output:
# 0x40020000: a8000000           ← MODER (PA0-PA15 modes)
# 0x40020004: 00000000           ← OTYPER
# 0x40020008: 00000000           ← OSPEEDR
# 0x4002000c: 00000000           ← PUPDR
# 0x40020010: 00000000           ← IDR (input levels)
# 0x40020014: 00000000           ← ODR (output levels)
# 0x40020018: 00000000           ← BSRR
# 0x4002001c: 00000000           ← LCKR
```

---

## Vendor-Specific Base Addresses (Quick Reference)

### STM32F4 (RM0090)

| Peripheral | Base Address |
|------------|-------------|
| GPIOA | 0x40020000 |
| GPIOB | 0x40020400 |
| GPIOC | 0x40020800 |
| GPIOD | 0x40020C00 |
| GPIOE | 0x40021000 |
| GPIOF | 0x40021400 |
| GPIOG | 0x40021800 |
| GPIOH | 0x40021C00 |
| RCC | 0x40023800 |
| FLASH | 0x40023C00 |
| USART1 | 0x40011000 |
| USART2 | 0x40004400 |
| SPI1 | 0x40013000 |
| SPI2 | 0x40003800 |
| I2C1 | 0x40005400 |
| TIM1 | 0x40010000 |
| TIM2 | 0x40000000 |
| FSMC Bank1 | 0xA0000000 |
| FSMC Bank4 | 0xA0000010 |

### nRF52840

| Peripheral | Base Address |
|------------|-------------|
| P0 (GPIO) | 0x50000000 |
| P1 (GPIO) | 0x50000300 |
| UART0 | 0x40002000 |
| SPI0 | 0x40003000 |
| TWI0 (I2C) | 0x40003000 |
| TIMER0 | 0x40008000 |
| RTC0 | 0x4000B000 |
| CLOCK | 0x40000000 |
| NVMC | 0x4001E000 |

### i.MX RT1064

| Peripheral | Base Address |
|------------|-------------|
| GPIO1 | 0x401B8000 |
| GPIO2 | 0x401BC000 |
| GPIO3 | 0x401C0000 |
| LPUART1 | 0x40184000 |
| LPSPI1 | 0x40194000 |
| LPI2C1 | 0x403FC000 |
| CCM (Clock) | 0x400FC000 |
| CCM_ANALOG | 0x400D8000 |
| GPT1 | 0x401EC000 |
| SEMC (ext mem) | 0x402F0000 |

### STM32F1 (RM0008)

| Peripheral | Base Address |
|------------|-------------|
| GPIOA | 0x40010800 |
| GPIOB | 0x40010C00 |
| GPIOC | 0x40011000 |
| RCC | 0x40021000 |
| USART1 | 0x40013800 |
| USART2 | 0x40004400 |
| SPI1 | 0x40013000 |
| I2C1 | 0x40005400 |
| TIM1 | 0x40012C00 |
| TIM2 | 0x40000000 |
| FSMC | 0xA0000000 |

---

## Key Insight: Why This Works Universally

The OpenOCD `mdw` command writes to the ARM Debug Port, which tunnels a direct AHB/APB bus transaction to the target memory map. This means:

1. **No firmware cooperation required** — you're reading real hardware state, not software abstraction
2. **Works even when firmware is crashed** — the debug port bypasses the CPU core
3. **Identical across all Cortex-M** — SCB/NVIC/SysTick addresses are the same everywhere
4. **Peripheral addresses are from the memory map** — and any vendor's RM tells you those

This is why the same `mdw 0xE000ED28` command reads CFSR on an STM32F4, an nRF52840, or an i.MX RT1064 — because ARM mandates that address.
