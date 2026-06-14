# OpenOCD Universal Debug Skill | OpenOCD 通用调试技能

[English](#english) | [中文](#中文)

---

## English

Universal OpenOCD debugging skill for WorkBuddy AI Assistant. Supports **all** ARM Cortex-M chips and **all** major debug probes.

### ✨ Features | 功能特性

- ✅ **All ARM Cortex-M**: STM32 (F0~H7/L0~U5/WB/WL/MP1), NXP (i.MX RT/Kinetis/LPC), Nordic (nRF51/52/53/91), TI, Atmel SAM, GD32, Nuvoton, RP2040
- ✅ **RISC-V**: GD32V, ESP32-C3/S3/H2
- ✅ **All Debug Probes**: ST-LINK (V1/V2/V2-1/V3), J-Link (EDU/BASE/PLUS/PRO), CMSIS-DAP (v1/v2), FTDI, RPi GPIO, and more
- ✅ **4 Debug Workflows**: Flash firmware, Read registers, Mass erase, GDB debug
- ✅ **Fault Diagnosis**: Auto-decode HardFault/MemFault/BusFault/UsageFault
- ✅ **TCL Automation**: Custom scripts for batch operations

### 📦 Installation | 安装

#### Option 1: Clone from GitHub (Recommended | 推荐)

```bash
cd ~/.workbuddy/skills/
git clone https://github.com/YOUR_USERNAME/openocd-debug-skill.git
```

#### Option 2: Manual Copy | 手动复制

Copy the entire skill folder to `~/.workbuddy/skills/`.

#### Prerequisites | 前置条件

1. **OpenOCD** (v0.11.0+)
   - Zephyr SDK: `D:/Zephyr/zephyr-sdk-0.16.8/...`
   - Chocolatey: `choco install openocd`
   - Manual: Download from https://openocd.org

2. **Debug Probe Driver | 调试探针驱动**
   - ST-LINK: Install STSW-LINK009
   - J-Link: Install J-Link Software Package
   - CMSIS-DAP: No driver needed (HID)

### 🚀 Quick Start | 快速开始

#### 1. Flash Firmware | 烧录固件

```bash
cd ~/.workbuddy/skills/openocd-debug-skill
./scripts/flash_fw.sh -i stlink -t stm32f4x -f build/zephyr/zephyr.elf
```

**Parameters | 参数说明:**
- `-i`: Interface config (stlink, jlink, cmsis-dap, ftdi, rpi)
- `-t`: Target config (stm32f4x, stm32f1x, nrf52, imxrt, etc.)
- `-s`: Scripts directory (optional, auto-detect)
- `-f`: Firmware file (.elf/.hex/.bin)

#### 2. Read Registers | 读取寄存器

```bash
./scripts/read_regs.sh -i stlink -t stm32f4x
```

#### 3. Mass Erase (Recover Bricked Chip) | 批量擦除（恢复砖化芯片）

```bash
./scripts/mass_erase.sh -i stlink -t stm32f4x
```

⚠️ **WARNING**: This erases the entire flash, including any read-protection settings.

#### 4. GDB Debug | GDB 调试

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

### 📚 Documentation | 文档

| Document | English | 中文 |
|----------|---------|------|
| **User Guide | 用户指南** | [docs/en-us.md](docs/en-us.md) | [docs/zh-cn.md](docs/zh-cn.md) |
| **Skill Definition | 技能定义** | [SKILL.md](SKILL.md) | - |
| **Register Guide | 寄存器指南** | [references/register_guide.md](references/register_guide.md) | - |
| **Probe Configs | 探针配置** | [references/probe_configs.md](references/probe_configs.md) | - |
| **Chip Targets | 芯片目标** | [references/chip_targets.md](references/chip_targets.md) | - |

### 🔧 Scripts | 脚本

| Script | Description | 说明 |
|--------|-------------|------|
| `scripts/flash_fw.sh` | Flash firmware | 烧录固件 |
| `scripts/mass_erase.sh` | Mass erase chip | 批量擦除芯片 |
| `scripts/read_regs.sh` | Interactive register reader | 交互式寄存器读取器 |
| `scripts/find_scripts.sh` | Auto-detect OpenOCD scripts dir | 自动检测 OpenOCD 脚本目录 |

### 🐛 Supported Hardware | 支持的硬件

#### Debug Probes | 调试探针

| Probe | Speed | Interface |
|-------|-------|-----------|
| ST-LINK V3 | **4 MHz** | SWD + VCP + Bridge |
| J-Link Pro | 12 MHz | JTAG/SWD |
| CMSIS-DAP v2 | 3.5 MHz | SWD + CDC |
| FTDI FT2232H | 16 MHz | JTAG/SWD |

👉 **Full list | 完整列表**: See [references/probe_configs.md](references/probe_configs.md)

#### Target Chips | 目标芯片

| Vendor | Family | Target Config |
|--------|--------|---------------|
| ST | STM32F1 | `target/stm32f1x.cfg` |
| ST | STM32F4 | `target/stm32f4x.cfg` |
| ST | STM32H7 | `target/stm32h7x.cfg` |
| NXP | i.MX RT1064 | `target/imxrt1064.cfg` |
| Nordic | nRF52840 | `target/nrf52840.cfg` |

👉 **Full list | 完整列表**: See [references/chip_targets.md](references/chip_targets.md)

### 💡 Example Workflows | 示例工作流

#### Flash and Debug STM32F103C8T6 | 烧录并调试 STM32F103C8T6

```bash
# Step 1: Flash firmware
./scripts/flash_fw.sh -i stlink -t stm32f1x -f Project.axf

# Step 2: Read GPIOA registers
./scripts/read_regs.sh -i stlink -t stm32f1x
# In interactive menu, choose "1. Read memory"
# Enter: mdw 0x4001080C 1

# Step 3: Diagnose if chip crashes
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "reset halt; mdw 0xE000ED28 1; shutdown"
```

#### Debug nRF52840 with J-Link | 用 J-Link 调试 nRF52840

```bash
# Start GDB server
openocd -f interface/jlink.cfg -f target/nrf52840.cfg

# In another terminal
arm-none-eabi-gdb firmware.elf
(gdb) target remote localhost:3333
(gdb) monitor reset halt
(gdb) break ble_stack_init
(gdb) continue
```

### 🤝 Contributing | 贡献

Contributions are welcome! | 欢迎贡献！

1. Fork the repository | Fork 本仓库
2. Create a feature branch | 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. Commit your changes | 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch | 推送到分支 (`git push origin feature/AmazingFeature`)
5. Open a Pull Request | 创建 Pull Request

### 📄 License | 许可证

MIT License - see [LICENSE](LICENSE) for details. | MIT 许可证 - 详见 [LICENSE](LICENSE)。

### 🆘 Support | 支持

- **GitHub Issues**: https://github.com/YOUR_USERNAME/openocd-debug-skill/issues
- **OpenOCD Documentation | OpenOCD 文档**: http://openocd.org/doc/doxygen/index.html
- **WorkBuddy Community | WorkBuddy 社区**: https://workbuddy.ai/community

---

## 中文

适用于 WorkBuddy AI 助手的通用 OpenOCD 调试技能包。支持**所有** ARM Cortex-M 芯片和**所有**主流调试探针。

### ✨ 功能特性

- ✅ **所有 ARM Cortex-M**: STM32 (F0~H7/L0~U5/WB/WL/MP1)、NXP (i.MX RT/Kinetis/LPC)、Nordic (nRF51/52/53/91)、TI、Atmel SAM、兆易创新 GD32、新唐科技、RP2040
- ✅ **RISC-V**: GD32V、ESP32-C3/S3/H2
- ✅ **所有调试探针**: ST-LINK (V1/V2/V2-1/V3)、J-Link (EDU/BASE/PLUS/PRO)、CMSIS-DAP (v1/v2)、FTDI、树莓派 GPIO 等
- ✅ **4 大调试工作流**: 烧录固件、读取寄存器、批量擦除、GDB 调试
- ✅ **故障诊断**: 自动解码 HardFault/MemFault/BusFault/UsageFault
- ✅ **TCL 自动化**: 自定义脚本进行批量操作

### 📦 安装

#### 方式 1：从 GitHub 克隆（推荐）

```bash
cd ~/.workbuddy/skills/
git clone https://github.com/YOUR_USERNAME/openocd-debug-skill.git
```

#### 方式 2：手动复制

将整个技能文件夹复制到 `~/.workbuddy/skills/`。

#### 前置条件

1. **OpenOCD**（v0.11.0+）
   - Zephyr SDK: `D:/Zephyr/zephyr-sdk-0.16.8/...`
   - Chocolatey: `choco install openocd`
   - 手动下载: https://openocd.org

2. **调试探针驱动**
   - ST-LINK: 安装 STSW-LINK009
   - J-Link: 安装 J-Link Software Package
   - CMSIS-DAP: 无需驱动（HID）

### 🚀 快速开始

#### 1. 烧录固件

```bash
cd ~/.workbuddy/skills/openocd-debug-skill
./scripts/flash_fw.sh -i stlink -t stm32f4x -f build/zephyr/zephyr.elf
```

**参数说明:**
- `-i`: 接口配置（stlink, jlink, cmsis-dap, ftdi, rpi）
- `-t`: 目标配置（stm32f4x, stm32f1x, nrf52, imxrt 等）
- `-s`: 脚本目录（可选，自动检测）
- `-f`: 固件文件（.elf/.hex/.bin）

#### 2. 读取寄存器

```bash
./scripts/read_regs.sh -i stlink -t stm32f4x
```

#### 3. 批量擦除（恢复砖化芯片）

```bash
./scripts/mass_erase.sh -i stlink -t stm32f4x
```

⚠️ **警告**：这将擦除整个 Flash，包括任何读保护设置。

#### 4. GDB 调试

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

### 📚 文档

| 文档 | English | 中文 |
|------|---------|------|
| **用户指南** | [docs/en-us.md](docs/en-us.md) | [docs/zh-cn.md](docs/zh-cn.md) |
| **技能定义** | [SKILL.md](SKILL.md) | - |
| **寄存器指南** | [references/register_guide.md](references/register_guide.md) | - |
| **探针配置** | [references/probe_configs.md](references/probe_configs.md) | - |
| **芯片目标** | [references/chip_targets.md](references/chip_targets.md) | - |

### 🔧 脚本

| 脚本 | 说明 |
|------|------|
| `scripts/flash_fw.sh` | 烧录固件 |
| `scripts/mass_erase.sh` | 批量擦除芯片 |
| `scripts/read_regs.sh` | 交互式寄存器读取器 |
| `scripts/find_scripts.sh` | 自动检测 OpenOCD 脚本目录 |

### 🐛 支持的硬件

#### 调试探针

| 探针 | 速度 | 接口 |
|------|------|------|
| ST-LINK V3 | **4 MHz** | SWD + VCP + Bridge |
| J-Link Pro | 12 MHz | JTAG/SWD |
| CMSIS-DAP v2 | 3.5 MHz | SWD + CDC |
| FTDI FT2232H | 16 MHz | JTAG/SWD |

👉 **完整列表**: 参见 [references/probe_configs.md](references/probe_configs.md)

#### 目标芯片

| 厂商 | 系列 | 目标配置 |
|------|------|----------|
| ST | STM32F1 | `target/stm32f1x.cfg` |
| ST | STM32F4 | `target/stm32f4x.cfg` |
| ST | STM32H7 | `target/stm32h7x.cfg` |
| NXP | i.MX RT1064 | `target/imxrt1064.cfg` |
| Nordic | nRF52840 | `target/nrf52840.cfg` |

👉 **完整列表**: 参见 [references/chip_targets.md](references/chip_targets.md)

### 💡 示例工作流

#### 烧录并调试 STM32F103C8T6

```bash
# 步骤 1：烧录固件
./scripts/flash_fw.sh -i stlink -t stm32f1x -f Project.axf

# 步骤 2：读取 GPIOA 寄存器
./scripts/read_regs.sh -i stlink -t stm32f1x
# 在交互式菜单中，选择 "1. 读取内存"
# 输入：mdw 0x4001080C 1

# 步骤 3：诊断芯片是否崩溃
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "reset halt; mdw 0xE000ED28 1; shutdown"
```

#### 用 J-Link 调试 nRF52840

```bash
# 启动 GDB 服务器
openocd -f interface/jlink.cfg -f target/nrf52840.cfg

# 在另一个终端
arm-none-eabi-gdb firmware.elf
(gdb) target remote localhost:3333
(gdb) monitor reset halt
(gdb) break ble_stack_init
(gdb) continue
```

### 🤝 贡献

欢迎贡献！

1. Fork 本仓库
2. 创建功能分支（`git checkout -b feature/新功能名称`）
3. 提交更改（`git commit -m '添加新功能'`）
4. 推送到分支（`git push origin feature/新功能名称`）
5. 创建 Pull Request

### 📄 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)。

### 🆘 支持

- **GitHub Issues**: https://github.com/YOUR_USERNAME/openocd-debug-skill/issues
- **OpenOCD 文档**: http://openocd.org/doc/doxygen/index.html
- **WorkBuddy 社区**: https://workbuddy.ai/community
