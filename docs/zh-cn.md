# OpenOCD 通用调试技能 - 中文指南

适用于 WorkBuddy AI 助手的通用 OpenOCD 调试技能包。支持所有 ARM Cortex-M 芯片和所有主流调试探针。

## 目录

1. [概述](#概述)
2. [架构](#架构)
3. [安装](#安装)
4. [快速开始](#快速开始)
5. [支持的硬件](#支持的硬件)
6. [调试工作流](#调试工作流)
7. [命令参考](#命令参考)
8. [故障诊断](#故障诊断)
9. [TCL 脚本自动化](#tcl-脚本自动化)
10. [故障排查](#故障排查)

---

## 概述

这个技能包让 WorkBuddy AI 能够调试 OpenOCD 支持的**任何**微控制器：

- ✅ **所有 ARM Cortex-M**: STM32 (F0/F1/F2/F3/F4/F7/G0/G4/H7/L0/L1/L4/L5/U5/WB/WL/MP1)、NXP (i.MX RT, Kinetis, LPC)、Nordic (nRF51/52/53/91)、TI (CC13xx/CC26xx/MSP432/TM4C)、Atmel SAM、兆易创新 GD32、新唐科技
- ✅ **RISC-V**: GD32V、ESP32-C3/S3/H2
- ✅ **所有调试探针**: ST-LINK (V1/V2/V2-1/V3)、J-Link (EDU/BASE/PLUS/PRO)、CMSIS-DAP (v1/v2)、FTDI (FT2232H/FT232H)、树莓派 GPIO、Remote Bitbang、Bus Pirate、xds110、ULINK

### 核心功能

| 功能 | 说明 |
|------|------|
| **烧录固件** | 编译 → 烧录 → 校验 → 复位，一条命令完成 |
| **读取寄存器** | 交互式寄存器浏览器，支持自动发现 |
| **批量擦除** | 恢复砖化的芯片（包括读保护状态） |
| **GDB 调试** | 启动 GDB 服务器 + 连接进行源码级调试 |
| **故障诊断** | 自动解码 HardFault、MemFault、BusFault、UsageFault |
| **TCL 自动化** | 编写自定义 TCL 脚本进行批量操作 |

---

## 架构

OpenOCD 使用**三层架构**：

```
┌─────────────────────────────────────────────────────┐
│              主机（你的电脑）                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ GDB       │  │ telnet   │  │ TCL      │      │
│  │ 客户端    │  │ 客户端   │  │ 脚本     │      │
│  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘  │
│        │                │                │       │
└────────│────────────────│────────────────│───────┘
         │                │                │
         ▼                ▼                ▼
┌─────────────────────────────────────────────────────┐
│         OpenOCD 守护进程（TCL 引擎）                │
│  ┌──────────────┐  ┌──────────────┐             │
│  │ Flash 驱动   │  │ Target 驱动  │            │
│  └──────────────┘  └──────────────┘             │
└─────────────────────┬───────────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │   调试适配器（探针）      │
         │  ST-LINK / J-Link / ...  │
         └────────────┬─────────────┘
                      │ SWD/JTAG
         ┌────────────┴─────────────┐
         │   目标 MCU（芯片）        │
         │  STM32 / nRF52 / ...      │
         └───────────────────────────┘
```

### 连接方式

| 协议 | 速度 | 使用场景 |
|------|------|----------|
| **SWD** | 4 MHz (ST-LINK V3) | 现代 Cortex-M 调试 |
| **JTAG** | 12 MHz (J-Link Pro) | 多芯片菊花链 |
| **cJTAG** | 2-wire | 空间受限的设计 |

---

## 安装

### 前置条件

1. **OpenOCD**（推荐 v0.11.0+）
   - Zephyr SDK: `D:/Zephyr/zephyr-sdk-0.16.8/...`
   - Chocolatey: `choco install openocd`
   - 手动下载: https://openocd.org

2. **调试探针驱动**
   - ST-LINK: 安装 STSW-LINK009
   - J-Link: 安装 J-Link Software Package
   - CMSIS-DAP: 无需驱动（HID）

### 在 WorkBuddy 中安装技能

```bash
# 方式 1：从 GitHub 克隆（发布后）
cd ~/.workbuddy/skills/
git clone https://github.com/YOUR_USERNAME/openocd-debug-skill.git

# 方式 2：手动复制
# 将整个技能文件夹复制到 ~/.workbuddy/skills/
```

---

## 快速开始

### 1. 烧录固件

```bash
# 自动检测 OpenOCD 脚本目录
./scripts/flash_fw.sh -i stlink -t stm32f4x -f build/zephyr/zephyr.elf

# 手动指定脚本目录
./scripts/flash_fw.sh -i stlink -t stm32f4x -s /path/to/openocd/scripts -f firmware.elf
```

**参数说明：**
- `-i`: 接口配置（stlink, jlink, cmsis-dap, ftdi, rpi）
- `-t`: 目标配置（stm32f4x, stm32f1x, nrf52, imxrt 等）
- `-s`: 脚本目录（可选，自动检测）
- `-f`: 固件文件（.elf/.hex/.bin）

### 2. 读取寄存器

```bash
./scripts/read_regs.sh -i stlink -t stm32f4x
```

然后使用交互式菜单：
```
=== OpenOCD 寄存器读取器 ===
1. 读取内存（mdw/mdh/mdb）
2. 写入内存（mww/mwh/mwb）
3. 读取 CPU 寄存器
4. 诊断故障
5. 自定义 OpenOCD 命令
q. 退出
```

### 3. 批量擦除（恢复砖化芯片）

```bash
./scripts/mass_erase.sh -i stlink -t stm32f4x
```

⚠️ **警告**：这将擦除整个 Flash，包括任何读保护设置。

### 4. GDB 调试

```bash
# 终端 1：启动 OpenOCD GDB 服务器
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg

# 终端 2：用 GDB 连接
arm-none-eabi-gdb build/zephyr/zephyr.elf
(gdb) target remote localhost:3333
(gdb) monitor reset halt
(gdb) break main
(gdb) continue
```

---

## 支持的硬件

### 调试探针

| 探针 | 配置文件 | 速度 | 接口 |
|------|----------|------|------|
| ST-LINK V1 | `interface/stlink.cfg` | 1.8 MHz | SWD |
| ST-LINK V2 | `interface/stlink.cfg` | 3.6 MHz | SWD |
| ST-LINK V2-1 | `interface/stlink.cfg` | 3.6 MHz | SWD + VCP |
| ST-LINK V3 | `interface/stlink.cfg` | **4 MHz** | SWD + VCP + Bridge |
| J-Link | `interface/jlink.cfg` | 12 MHz | JTAG/SWD |
| CMSIS-DAP v1 | `interface/cmsis-dap.cfg` | 1.5 MHz | SWD |
| CMSIS-DAP v2 | `interface/cmsis-dap.cfg` | 3.5 MHz | SWD + CDC |
| FTDI FT2232H | `interface/ftdi/um232h.cfg` | 16 MHz | JTAG/SWD |
| 树莓派 GPIO | `interface/sysfsgpio-raspberrypi.cfg` | 1 MHz | SWD |

👉 **完整列表**：参见 [`references/probe_configs.md`](references/probe_configs.md)

### 目标芯片

| 厂商 | 系列 | 目标配置 | Flash 驱动 |
|------|------|----------|-------------|
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
| 兆易创新 | GD32F4 | `target/stm32f4x.cfg` | `stm32f4x` |

👉 **完整列表**：参见 [`references/chip_targets.md`](references/chip_targets.md)

---

## 调试工作流

### 工作流 1：烧录固件

**步骤：**
1. 检测 OpenOCD 脚本目录
2. 验证接口/目标配置文件
3. 烧录固件（带校验）
4. 复位并运行

**自动检测脚本目录：**
```bash
# 脚本将按以下顺序搜索：
# 1. Zephyr SDK: D:/Zephyr/zephyr-sdk-0.16.8/.../openocd/scripts
# 2. 系统包: /usr/share/openocd/scripts
# 3. 环境变量: $OPENOCD_SCRIPTS
# 4. 常见位置: C:/Program Files/...
```

### 工作流 2：读取寄存器

**交互模式命令：**

| 命令 | 说明 | 示例 |
|------|------|------|
| `mdw addr [count]` | 读取 32 位字 | `mdw 0x4001080C 4` |
| `mdh addr [count]` | 读取 16 位半字 | `mdh 0x40010800 2` |
| `mdb addr [count]` | 读取 8 位字节 | `mdb 0x20000000 16` |
| `mww addr value` | 写入 32 位字 | `mww 0x4001080C 0x00000001` |
| `mwh addr value` | 写入 16 位半字 | `mwh 0x40010800 0x44444443` |
| `mwb addr value` | 写入 8 位字节 | `mwb 0x4001080C 0x01` |
| `reg` | 显示所有 CPU 寄存器 | `reg` |
| `reg pc` | 显示特定寄存器 | `reg pc` |

### 工作流 3：批量擦除

**为何需要：**
- 芯片启用读保护（RDP Level 1/2）
- Flash 被选项字节锁定
- 固件损坏（无法启动）

**支持的芯片：**

| 芯片系列 | 批量擦除命令 |
|----------|---------------------|
| STM32F0/F1/F2/F3/L0/L1 | `stm32f1x mass_erase 0` |
| STM32F4/F7/G0/G4/L4/L5 | `stm32f4x mass_erase 0` |
| STM32H7 | `stm32h7x mass_erase 0` |
| nRF52 | `nrf52 mass_erase` |
| i.MX RT | `imxrt mass_erase 0` |
| NXP Kinetis | `kinetis mdm mass_erase` |

### 工作流 4：GDB 调试

**步骤 1：启动 OpenOCD GDB 服务器**
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
```

**步骤 2：用 GDB 连接**
```bash
arm-none-eabi-gdb build/zephyr/zephyr.elf
(gdb) target remote localhost:3333
```

**步骤 3：调试命令**
```gdb
(gdb) monitor reset halt       # 复位并暂停芯片
(gdb) break main              # 在 main() 设置断点
(gdb) break 0x08000123       # 在地址设置断点
(gdb) continue                # 运行直到断点
(gdb) step                    # 单步执行（进入函数）
(gdb) next                    # 单步执行（跳过函数）
(gdb) print my_variable      # 打印变量值
(gdb) backtrace              # 显示调用栈
(gdb) info registers          # 显示所有寄存器
```

---

## 命令参考

### 内存访问

| 命令 | 位宽 | 示例 | 结果 |
|------|------|------|------|
| `mdw` | 32 位 | `mdw 0x4001080C 1` | `0x4001080c: 0000a001` |
| `mdh` | 16 位 | `mdh 0x40010800 2` | `0x40010800: 4444 4443` |
| `mdb` | 8 位 | `mdb 0x20000000 4` | `0x20000000: 12 34 56 78` |
| `mww` | 32 位 | `mww 0x4001080C 0x1` | PA0 = 高电平 |
| `mwh` | 16 位 | `mwh 0x40010800 0x4443` | 设置 PA0 为输出 |
| `mwb` | 8 位 | `mwb 0x4001080C 0x1` | 设置 PA0 为高 |

### CPU 寄存器

| 寄存器 | 说明 | 示例值 |
|--------|------|--------|
| `pc` | 程序计数器 | `0x0800016c` |
| `sp` | 栈指针（MSP） | `0x20000660` |
| `msp` | 主栈指针 | `0x20000660` |
| `psp` | 进程栈指针 | `0x00000000` |
| `xPSR` | 程序状态寄存器 | `0x01000000`（运行中） |
| `primask` | 优先级掩码 | `0x00`（中断已启用） |
| `basepri` | 基础优先级 | `0x00`（无掩码） |
| `faultmask` | 故障掩码 | `0x00`（故障已启用） |
| `control` | 控制寄存器 | `0x00`（线程模式，MSP） |

### Flash 命令

| 命令 | 说明 |
|------|------|
| `flash write_image erase firmware.elf` | 烧录并自动擦除 |
| `flash verify_image firmware.elf` | 校验烧录的固件 |
| `flash erase_sector 0 0 3` | 擦除扇区 0-3 |
| `flash protect 0 off 0 3` | 取消扇区 0-3 保护 |

### 复位与控制

| 命令 | 说明 |
|------|------|
| `reset halt` | 复位并暂停在第一条指令 |
| `reset run` | 复位并运行 |
| `reset init` | 复位并运行初始化脚本 |
| `halt` | 暂停目标 |
| `resume` | 恢复执行 |
| `step` | 单步执行一条指令 |

---

## 故障诊断

### Cortex-M 故障类型

| 故障 | 优先级 | 说明 |
|------|--------|------|
| **HardFault** | -1 | 所有故障（如果未单独启用） |
| **MemFault** | -1 | MPU 违规，非法非特权访问 |
| **BusFault** | -1 | 无效内存访问（错误地址） |
| **UsageFault** | -1 | 未定义指令，未对齐访问 |
| **SVCall** | -2 | SVC 指令（系统调用） |
| **PendSV** | -3 | PendSV（上下文切换） |
| **SysTick** | -4 | SysTick 定时器中断 |

### 故障诊断工作流

**步骤 1：暂停芯片**
```bash
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "reset halt; shutdown"
```

**步骤 2：读取故障寄存器**
```bash
# 在 OpenOCD telnet 中（telnet localhost 4444）：
mdw 0xE000ED28 1   # CFSR - 可配置故障状态寄存器
mdw 0xE000ED2C 1   # HFSR - HardFault 状态寄存器
mdw 0xE000ED34 1   # MMFAR - MemManage 故障地址
mdw 0xE000ED38 1   # BFAR - BusFault 地址寄存器
```

**步骤 3：解码 CFSR（3 字节）**

| 字节 | 寄存器 | 关键位 |
|------|--------|--------|
| 低字节 (7:0) | **MFSR**（MemFault） | BIT0=IACCVIOL, BIT1=DACCVIOL, BIT3=MUNSTKERR |
| 中字节 (15:8) | **BFSR**（BusFault） | BIT0=IBUSERR, BIT1=PRECISERR, BIT2=IMPRECISERR |
| 高字节 (23:16) | **UFSR**（UsageFault） | BIT0=UNDEFINSTR, BIT1=INVSTATE, BIT8=DIVBYZERO |

### 常见故障模式

| 症状 | CFSR 值 | 根本原因 | 修复方法 |
|------|----------|----------|----------|
| PC=0x00000000 | `0x00000001` (MFSR.IACCVIOL) | 跳转到空函数指针 | 检查函数指针初始化 |
| 随机地址 | `0x00000200` (BFSR.PRECISERR) | 写入无效地址 | 启用 BFARVALID，检查 BFAR |
| 中断后 | `0x00010000` (UFSR.INVSTATE) | ISR 中非法指令 | 检查栈溢出 |
| 除零错误 | `0x01000000` (UFSR.DIVBYZERO) | 整数除零 | 在 CCR 中启用 DIV_0_TRP |

👉 **完整寄存器映射**：参见 [`references/register_guide.md`](references/register_guide.md)

---

## TCL 脚本自动化

你可以用 TCL 脚本自动化 OpenOCD 操作。

### 示例 1：编译后自动烧录

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

# 用法：openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -f flash_on_build.tcl -c "flash_on_build firmware.elf"
```

### 示例 2：批量寄存器转储

```tcl
# dump_regs.tcl
init
reset halt

echo "=== GPIOA ==="
mdw 0x40010800 2

echo "=== RCC ==="
mdw 0x40021000 2
mdw 0x40021018 1

echo "=== 故障状态 ==="
mdw 0xE000ED28 1
mdw 0xE000ED2C 1

shutdown
```

### 示例 3：失败时重试烧录

```tcl
# retry_flash.tcl
proc retry_flash {elf_file max_retries} {
    set retry_count 0
    while {$retry_count < $max_retries} {
        catch {flash write_image erase $elf_file} result
        if {[string match "*OK*" $result]} {
            echo "烧录成功！"
            break
        }
        echo "烧录失败，重试 [expr {$retry_count + 1}]..."
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

## 故障排查

### 错误："找不到 OpenOCD 脚本目录"

**解决方案：**
```bash
# 方式 1：设置环境变量
export OPENOCD_SCRIPTS=/path/to/openocd/scripts

# 方式 2：手动指定
./scripts/flash_fw.sh -i stlink -t stm32f4x -s /path/to/openocd/scripts -f firmware.elf

# 方式 3：使用 find_scripts.sh
./scripts/find_scripts.sh
```

### 错误：需要 "connect_assert_srst"

**症状：** MCU 卡在 HardFault 中，无法连接。

**解决方案：**
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

### 错误："Flash 写入错误，地址 ..."

**可能原因：**
1. **读保护已启用** → 运行 `mass_erase.sh`
2. **Flash 驱动不正确** → 检查 `references/chip_targets.md`
3. **电源供应不足** → 使用外部电源，不要用 USB 供电

### 错误："JTAG/SWD 连接失败"

**检查清单：**
- [ ] 电缆连接牢固
- [ ] 目标板已上电（用万用表测量 VCC）
- [ ] 复位电路正确（NRST 上有 10k 上拉电阻）
- [ ] 尝试降低速度：`adapter speed 100`
- [ ] 尝试 `connect_assert_srst`

---

## 参考资料

| 文档 | 说明 |
|------|------|
| [`SKILL.md`](SKILL.md) | WorkBuddy 技能定义（英文） |
| [`references/register_guide.md`](references/register_guide.md) | 通用寄存器发现指南 |
| [`references/probe_configs.md`](references/probe_configs.md) | 所有支持的调试探针 |
| [`references/chip_targets.md`](references/chip_targets.md) | 所有支持的目标芯片 |
| [`scripts/flash_fw.sh`](scripts/flash_fw.sh) | 烧录固件脚本 |
| [`scripts/mass_erase.sh`](scripts/mass_erase.sh) | 批量擦除脚本 |
| [`scripts/read_regs.sh`](scripts/read_regs.sh) | 交互式寄存器读取器 |
| [`scripts/find_scripts.sh`](scripts/find_scripts.sh) | 自动检测脚本目录 |

---

## 贡献

欢迎贡献！请：

1. Fork 本仓库
2. 创建功能分支（`git checkout -b feature/新功能名称`）
3. 提交更改（`git commit -m '添加新功能'`）
4. 推送到分支（`git push origin feature/新功能名称`）
5. 创建 Pull Request

---

## 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)。

---

## 支持

- **GitHub Issues**：https://github.com/YOUR_USERNAME/openocd-debug-skill/issues
- **OpenOCD 文档**：http://openocd.org/doc/doxygen/index.html
- **WorkBuddy 社区**：https://workbuddy.ai/community
