# OpenOCD Universal Debug Skill | OpenOCD 通用调试技能

[English](#english) | [中文](#中文)

---

## English

<p align="center">
  <img src="https://img.shields.io/badge/AI-Powered-blue?style=flat-square" alt="AI Powered">
  <img src="https://img.shields.io/badge/Universal-Compatible-green?style=flat-square" alt="Universal Compatible">
  <img src="https://img.shields.io/badge/Cortex-M-RISC--V-orange?style=flat-square" alt="Cortex-M">
  <img src="https://img.shields.io/github/license/leiteer/openocd-debug-skill?style=flat-square" alt="MIT License">
</p>

<p align="center">
  <strong>🤖 AI-Driven Embedded Debugging | AI 驱动的嵌入式调试</strong><br>
  A universal OpenOCD knowledge base that empowers <strong>ANY AI assistant</strong> to debug embedded hardware.<br>
  通用的 OpenOCD 知识库，让<strong>任何 AI 助手</strong>都能调试嵌入式硬件。
</p>

<p align="center">
  <strong>✅ Compatible with | 兼容:</strong>
  <img src="https://img.shields.io/badge/WorkBuddy-00A86B?style=flat&logo=robot" alt="WorkBuddy">
  <img src="https://img.shields.io/badge/Claude-CC785C?style=flat&logo=anthropic" alt="Claude">
  <img src="https://img.shields.io/badge/ChatGPT-74AA9C?style=flat&logo=openai" alt="ChatGPT">
  <img src="https://img.shields.io/badge/Copilot-0078D4?style=flat&logo=githubcopilot" alt="Copilot">
  <img src="https://img.shields.io/badge/Any_AI-Agent-6B46E8?style=flat" alt="Any AI Agent">
</p>

---

### 🌟 Why This Skill? | 为什么需要这个技能？

#### The Problem | 痛点

Traditional embedded debugging is **painful**:

| Task | Traditional Way | Time Cost |
|-------|-----------------|------------|
| Find chip datasheet | Manual search | 10-30 min |
| Configure OpenOCD | Trial and error | 1-2 hours |
| Decode HardFault | Read ARM RM, guess | 2-4 hours |
| Find register address | Search PDF, calculate | 30-60 min |
| Recover bricked chip | Try commands manually | 1-2 hours |

**Total: 5-10 hours just to start debugging!**

#### The AI Way | AI 方式

With this skill, just tell AI:

```
"My STM32F103C8T6 is crashing. 
The LED stops blinking after 5 seconds. 
Help me debug it."
```

AI will automatically:

1. ✅ Detect your chip and debug probe
2. ✅ Flash the firmware
3. ✅ Read CPU registers and fault status
4. ✅ Decode HardFault (CFSR/HFSR/BFAR)
5. ✅ Tell you **exactly** what went wrong
6. ✅ Suggest fix and re-flash

**Total: 5-10 minutes!**

---

### 🚀 What AI Can Do | AI 能做什么？

This skill enables AI to **fully automate** embedded debugging:

#### 1. Hardware Debugging | 硬件调试

```
You: "My nRF52840 crashes when BLE advertising starts."
AI:  
  → Auto-detects nRF52840 + J-Link
  → Reads CFSR = 0x00020000 (INVSTATE)
  → Decodes: "ISR returned to invalid state"
  → Checks stack overflow: "Stack high water mark = 0!"
  → Fix: "Increase stack size to 2048"
```

#### 2. Register Inspection | 寄存器检查

```
You: "Show me all GPIOA registers on this STM32H7."
AI:
  → Reads GPIOA_CRL/CRH/IDR/ODR/BSRR/BRR/LCKR
  → Displays in hex + binary + bit-field table
  → Highlights which pins are input/output
```

#### 3. Fault Diagnosis | 故障诊断

```
You: "My chip keeps resetting."
AI:
  → Reads SCB->CFSR, HFSR, SHCSR
  → Finds: "MemFault at address 0x00000000"
  → Decodes: "You jumped to a NULL function pointer"
  → Shows exact line in your source code
```

#### 4. Firmware Recovery | 固件恢复

```
You: "I enabled read-protection and now can't flash."
AI:
  → Detects chip is locked
  → Runs mass erase with connect_assert_srst
  → Unlocks flash
  → Re-flashes firmware
  → "Chip recovered successfully!"
```

#### 5. Performance Optimization | 性能优化

```
You: "My SPI is running slower than expected."
AI:
  → Reads SPIx->CR1/CR2/SR
  → Finds: "BR[2:0] = 0b111 (256 divider)"
  → Suggests: "Change to BR=0b001 (/4 divider) for 12MHz"
  → Modifies code and re-flashes
```

---

### 💡 AI + OpenOCD = Full-Stack Embedded Capability | AI + OpenOCD = 全栈嵌入式能力

With this skill, AI becomes your **embedded expert**:

| Traditional Role | AI Replaces | How |
|-----------------|---------------|------|
| Hardware Engineer | ✅ | Reads schematics, checks pin configurations |
| Firmware Engineer | ✅ | Writes drivers, debugs crashes |
| Debugging Engineer | ✅ | Decodes faults, analyzes timing |
| Performance Engineer | ✅ | Profiles code, optimizes peripherals |
| Technical Writer | ✅ | Generates documentation automatically |

**One AI, all roles!**

---

### ✨ Features | 功能特性

- ✅ **All ARM Cortex-M**: STM32 (F0~H7/L0~U5/WB/WL/MP1), NXP (i.MX RT/Kinetis/LPC), Nordic (nRF51/52/53/91), TI, Atmel SAM, GD32, Nuvoton, RP2040
- ✅ **RISC-V**: GD32V, ESP32-C3/S3/H2
- ✅ **All Debug Probes**: ST-LINK (V1/V2/V2-1/V3), J-Link (EDU/BASE/PLUS/PRO), CMSIS-DAP (v1/v2), FTDI, RPi GPIO, and more
- ✅ **4 Debug Workflows**: Flash firmware, Read registers, Mass erase, GDB debug
- ✅ **Fault Diagnosis**: Auto-decode HardFault/MemFault/BusFault/UsageFault
- ✅ **TCL Automation**: Custom scripts for batch operations
- ✅ **AI-Native**: Structured knowledge base for ANY AI assistant

---

### 🤖 How to Use with AI Assistants | 如何在 AI 助手上使用

This is a **universal knowledge base** - any AI can use it!

#### Method 1: Clone and Let AI Read | 方法 1：克隆并让 AI 读取

```bash
# Clone this repo
git clone https://github.com/leiteer/openocd-debug-skill.git

# Then tell your AI:
# "Read the SKILL.md file in openocd-debug-skill/ and help me debug my STM32F103"
```

#### Method 2: Copy to AI's Knowledge Base | 方法 2：复制到 AI 的知识库

**WorkBuddy**:
```bash
cp -r openocd-debug-skill ~/.workbuddy/skills/
```

**Claude Projects / ChatGPT Projects**:
1. Upload `SKILL.md` and `references/*.md` to your Project's knowledge base
2. Ask: "Use the OpenOCD debug knowledge to help me flash my firmware"

**Local AI Agents (AutoGPT, LangChain, etc.)**:
```python
# Load SKILL.md as system prompt context
with open('openocd-debug-skill/SKILL.md', 'r') as f:
    system_context = f.read()
```

#### Method 3: Direct Question | 方法 3：直接提问

Even without installing, you can:
1. Open `SKILL.md` or `docs/en-us.md`
2. Copy the relevant section
3. Paste into ANY AI chat with your question

---

### 📦 Installation | 安装

#### Prerequisites | 前置条件

1. **OpenOCD** (v0.11.0+)
   ```bash
   # Install via package manager
   # macOS:
   brew install openocd
   
   # Linux:
   sudo apt install openocd
   
   # Windows:
   choco install openocd
   
   # Or download from: https://openocd.org
   ```

2. **Debug Probe Driver**
   - ST-LINK: Install STSW-LINK009
   - J-Link: Install J-Link Software Package
   - CMSIS-DAP: No driver needed (HID)

#### Quick Install for AI Agents | AI 代理快速安装

```bash
# WorkBuddy
cd ~/.workbuddy/skills/
git clone https://github.com/leiteer/openocd-debug-skill.git

# Claude Projects (manual upload)
# Upload all .md files to Project Knowledge

# ChatGPT Projects (manual upload)
# Upload all .md files to Project Files
```

---

### 🚀 Quick Start | 快速开始

#### Example 1: Flash and Debug | 烧录并调试

```
You: "Flash this firmware to my STM32F103 and check if GPIOA is configured correctly."

AI will:
  1. Run: ./scripts/flash_fw.sh -i stlink -t stm32f1x -f firmware.elf
  2. Read: GPIOA_CRL (0x40010800)
  3. Decode: "PA0-PA7 are inputs (0x44444444), but your code expects PA0 as output"
  4. Fix: Overwrites GPIOA_CRL to 0x44444443
  5. Verify: Reads back and confirms PA0 is now output
```

#### Example 2: Diagnose Crash | 诊断崩溃

```
You: "My chip crashes when I call printf(). Why?"

AI will:
  1. Connect via OpenOCD
  2. Halt the chip
  3. Read CFSR = 0x01000000 (DIVBYZERO)
  4. Read BFAR = 0x00000000
  5. Decode: "You divided by zero in printf() internal buffer calc"
  6. Suggest: "Enable DIV_0_TRP in CCR or check your buffer size"
```

#### Example 3: Recover Bricked Chip | 恢复砖化芯片

```
You: "I enabled read-protection and now can't connect. Help!"

AI will:
  1. Detect: "Chip is locked (RDP Level 1)"
  2. Run: ./scripts/mass_erase.sh -i stlink -t stm32f4x
  3. Use connect_assert_srst to break the lock
  4. Mass erase the flash
  5. Verify: "Chip is now unlocked and erased"
  6. Ask: "Want me to re-flash your firmware?"
```

---

### 📚 Documentation | 文档

| Document | English | 中文 |
|----------|---------|------|
| **User Guide** | [docs/en-us.md](docs/en-us.md) | [docs/zh-cn.md](docs/zh-cn.md) |
| **Skill Definition** | [SKILL.md](SKILL.md) | - |
| **Register Guide** | [references/register_guide.md](references/register_guide.md) | - |
| **Probe Configs** | [references/probe_configs.md](references/probe_configs.md) | - |
| **Chip Targets** | [references/chip_targets.md](references/chip_targets.md) | - |

---

### 🤝 Contributing | 贡献

Contributions are welcome! This skill aims to make AI the **ultimate embedded debugging expert**.

Ideas for contribution:

- 🆕 Add support for more chips (ESP32, RISC-V, etc.)
- 🆕 Add more workflow templates (profiling, power analysis, etc.)
- 🆕 Improve fault diagnosis (add more patterns)
- 🆕 Add TCL scripts for common tasks
- 📝 Improve documentation (more examples, diagrams, etc.)

---

### 📄 License | 许可证

MIT License - see [LICENSE](LICENSE) for details.

---

### 🙏 Support | 支持

- **GitHub Issues**: https://github.com/leiteer/openocd-debug-skill/issues
- **OpenOCD Documentation**: http://openocd.org/doc/doxygen/index.html

---

## 中文

<p align="center">
  <img src="https://img.shields.io/badge/AI-驱动-blue?style=flat-square" alt="AI 驱动">
  <img src="https://img.shields.io/badge/通用-兼容-green?style=flat-square" alt="通用兼容">
  <img src="https://img.shields.io/badge/Cortex-M-RISC--V-orange?style=flat-square" alt="Cortex-M">
  <img src="https://img.shields.io/github/license/leiteer/openocd-debug-skill?style=flat-square" alt="MIT 许可证">
</p>

<p align="center">
  <strong>🤖 AI 驱动的嵌入式调试 | 让 AI 帮你搞定硬件调试</strong><br>
  通用的 OpenOCD 知识库，让<strong>任何 AI 助手</strong>都能调试嵌入式硬件。<br>
  从硬件调试到软件优化，AI 一站式解决。
</p>

<p align="center">
  <strong>✅ 兼容 AI 平台 | Compatible with:</strong>
  <img src="https://img.shields.io/badge/WorkBuddy-00A86B?style=flat&logo=robot" alt="WorkBuddy">
  <img src="https://img.shields.io/badge/Claude-CC785C?style=flat&logo=anthropic" alt="Claude">
  <img src="https://img.shields.io/badge/ChatGPT-74AA9C?style=flat&logo=openai" alt="ChatGPT">
  <img src="https://img.shields.io/badge/Copilot-0078D4?style=flat&logo=githubcopilot" alt="Copilot">
  <img src="https://img.shields.io/badge/任何AI代理-6B46E8?style=flat" alt="任何 AI 代理">
</p>

---

### 🌟 为什么需要这个技能？ | Why This Skill?

#### 传统嵌入式调试的痛点

嵌入式开发最痛苦的不是写代码，而是**调硬件**：

| 任务 | 传统方式 | 时间成本 |
|-------|----------|----------|
| 找芯片数据手册 | 手动搜索 | 10-30 分钟 |
| 配置 OpenOCD | 试错 | 1-2 小时 |
| 解码 HardFault | 读 ARM RM，猜原因 | 2-4 小时 |
| 查寄存器地址 | 搜 PDF，算偏移 | 30-60 分钟 |
| 恢复砖化芯片 | 手动试命令 | 1-2 小时 |

**总计：光是开始调试就要 5-10 小时！**

#### AI 方式来拯救

有了这个技能包，只需要告诉 AI：

```
"我的 STM32F103C8T6 崩溃了。
LED 在运行 5 秒后停止闪烁。
帮我调试。"
```

AI 会自动完成：

1. ✅ 自动检测你的芯片和调试探针
2. ✅ 烧录固件
3. ✅ 读取 CPU 寄存器和故障状态
4. ✅ 解码 HardFault（CFSR/HFSR/BFAR）
5. ✅ **精确**告诉你哪里出错了（源码行号）
6. ✅ 建议修复方案并重新烧录

**总计：5-10 分钟！**

---

### 🚀 AI 能做什么？ | What AI Can Do?

这个技能包让 AI 能够**全自动**完成嵌入式调试：

#### 1. 硬件调试 | Hardware Debugging

```
你："我的 nRF52840 在 BLE 广播开始时崩溃。"
AI:
  → 自动检测 nRF52840 + J-Link
  → 读取 CFSR = 0x00020000 (INVSTATE)
  → 解码："ISR 返回到无效状态"
  → 检查栈溢出："栈高水位线 = 0！"
  → 修复："将栈大小增加到 2048"
```

#### 2. 寄存器检查 | Register Inspection

```
你："显示这个 STM32H7 的所有 GPIOA 寄存器。"
AI:
  → 读取 GPIOA_CRL/CRH/IDR/ODR/BSRR/BRR/LCKR
  → 用十六进制 + 二进制 + 位域表格显示
  → 高亮显示哪些引脚是输入/输出
```

#### 3. 故障诊断 | Fault Diagnosis

```
你："我的芯片不断复位。"
AI:
  → 读取 SCB->CFSR, HFSR, SHCSR
  → 发现："MemFault 在地址 0x00000000"
  → 解码："你跳转到了空函数指针"
  → 显示源码中的确切行号
```

#### 4. 固件恢复 | Firmware Recovery

```
你："我启用了读保护，现在无法烧录。"
AI:
  → 检测到芯片被锁定
  → 用 connect_assert_srst 运行批量擦除
  → 解锁 Flash
  → 重新烧录固件
  → "芯片恢复成功！"
```

#### 5. 性能优化 | Performance Optimization

```
你："我的 SPI 运行比预期慢。"
AI:
  → 读取 SPIx->CR1/CR2/SR
  → 发现："BR[2:0] = 0b111 (256 分频)"
  → 建议："改为 BR=0b001 (/4 分频) 以达到 12MHz"
  → 修改代码并重新烧录
```

---

### 💡 AI + OpenOCD = 全栈嵌入式能力

有了这个技能包，AI 成为你的**嵌入式专家**：

| 传统角色 | AI 替代 | 如何实现 |
|----------|----------|----------|
| 硬件工程师 | ✅ | 读取原理图，检查引脚配置 |
| 固件工程师 | ✅ | 编写驱动，调试崩溃 |
| 调试工程师 | ✅ | 解码故障，分析时序 |
| 性能工程师 | ✅ | 性能分析，优化外设 |
| 技术文档工程师 | ✅ | 自动生成文档 |

**一个 AI，所有角色！**

---

### ✨ 功能特性

- ✅ **所有 ARM Cortex-M**: STM32 (F0~H7/L0~U5/WB/WL/MP1)、NXP (i.MX RT/Kinetis/LPC)、Nordic (nRF51/52/53/91)、TI、Atmel SAM、兆易创新 GD32、新唐科技、RP2040
- ✅ **RISC-V**: GD32V、ESP32-C3/S3/H2
- ✅ **所有调试探针**: ST-LINK (V1/V2/V2-1/V3)、J-Link (EDU/BASE/PLUS/PRO)、CMSIS-DAP (v1/v2)、FTDI、树莓派 GPIO 等
- ✅ **4 大调试工作流**: 烧录固件、读取寄存器、批量擦除、GDB 调试
- ✅ **故障诊断**: 自动解码 HardFault/MemFault/BusFault/UsageFault
- ✅ **TCL 自动化**: 自定义脚本进行批量操作
- ✅ **AI 原生**: 为任何 AI 助手设计的结构化知识库

---

### 🤖 如何在 AI 助手上使用

这是一个**通用知识库** - 任何 AI 都能用！

#### 方法 1：克隆并让 AI 读取 | Method 1: Clone and Let AI Read

```bash
# 克隆仓库
git clone https://github.com/leiteer/openocd-debug-skill.git

# 然后告诉你的 AI：
# "读取 openocd-debug-skill/ 中的 SKILL.md 文件，帮我调试 STM32F103"
```

#### 方法 2：复制到 AI 的知识库 | Method 2: Copy to AI's Knowledge Base

**WorkBuddy**:
```bash
cp -r openocd-debug-skill ~/.workbuddy/skills/
```

**Claude Projects / ChatGPT Projects**:
1. 上传 `SKILL.md` 和 `references/*.md` 到你的 Project 知识库
2. 提问："使用 OpenOCD 调试知识帮我烧录固件"

**本地 AI 代理 (AutoGPT, LangChain 等)**:
```python
# 加载 SKILL.md 作为系统提示上下文
with open('openocd-debug-skill/SKILL.md', 'r') as f:
    system_context = f.read()
```

#### 方法 3：直接提问 | Method 3: Direct Question

即使不安装，你也可以：
1. 打开 `SKILL.md` 或 `docs/zh-cn.md`
2. 复制相关章节
3. 粘贴到任何 AI 聊天框并提问

---

### 📦 安装

#### 前置条件

1. **OpenOCD**（v0.11.0+）
   ```bash
   # macOS:
   brew install openocd
   
   # Linux:
   sudo apt install openocd
   
   # Windows:
   choco install openocd
   
   # 或者从以下地址下载：https://openocd.org
   ```

2. **调试探针驱动**
   - ST-LINK: 安装 STSW-LINK009
   - J-Link: 安装 J-Link Software Package
   - CMSIS-DAP: 无需驱动（HID）

#### AI 代理快速安装

```bash
# WorkBuddy
cd ~/.workbuddy/skills/
git clone https://github.com/leiteer/openocd-debug-skill.git

# Claude Projects (手动上传)
# 上传所有 .md 文件到 Project Knowledge

# ChatGPT Projects (手动上传)
# 上传所有 .md 文件到 Project Files
```

---

### 🚀 快速开始

#### 示例 1：烧录并调试

```
你："把这个固件烧录到我的 STM32F103，并检查 GPIOA 是否配置正确。"

AI 会：
  1. 运行：./scripts/flash_fw.sh -i stlink -t stm32f1x -f firmware.elf
  2. 读取：GPIOA_CRL (0x40010800)
  3. 解码："PA0-PA7 是输入（0x44444444），但你的代码期望 PA0 为输出"
  4. 修复：覆盖 GPIOA_CRL 为 0x44444443
  5. 验证：读回并确认 PA0 现在是输出
```

#### 示例 2：诊断崩溃

```
你："我的芯片在调用 printf() 时崩溃。为什么？"

AI 会：
  1. 通过 OpenOCD 连接
  2. 暂停芯片
  3. 读取 CFSR = 0x01000000 (DIVBYZERO)
  4. 读取 BFAR = 0x00000000
  5. 解码："你在 printf() 内部缓冲区计算中除以零"
  6. 建议："在 CCR 中启用 DIV_0_TRP 或检查缓冲区大小"
```

#### 示例 3：恢复砖化芯片

```
你："我启用了读保护，现在无法连接。救命！"

AI 会：
  1. 检测："芯片被锁定（RDP Level 1）"
  2. 运行：./scripts/mass_erase.sh -i stlink -t stm32f4x
  3. 使用 connect_assert_srst 打破锁定
  4. 批量擦除 Flash
  5. 验证："芯片现已解锁并擦除"
  6. 询问："要我重新烧录你的固件吗？"
```

---

### 📚 文档

| 文档 | English | 中文 |
|------|---------|------|
| **用户指南** | [docs/en-us.md](docs/en-us.md) | [docs/zh-cn.md](docs/zh-cn.md) |
| **技能定义** | [SKILL.md](SKILL.md) | - |
| **寄存器指南** | [references/register_guide.md](references/register_guide.md) | - |
| **探针配置** | [references/probe_configs.md](references/probe_configs.md) | - |
| **芯片目标** | [references/chip_targets.md](references/chip_targets.md) | - |

---

### 🤝 贡献

欢迎贡献！这个技能包的目标是让 AI 成为**终极嵌入式调试专家**。

贡献想法：

- 🆕 添加更多芯片支持（ESP32、RISC-V 等）
- 🆕 添加更多工作流模板（性能分析、功耗分析等）
- 🆕 改进故障诊断（添加更多模式）
- 🆕 添加常用任务的 TCL 脚本
- 📝 改进文档（更多示例、图表等）

---

### 📄 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)。

---

### 🙏 支持

- **GitHub Issues**: https://github.com/leiteer/openocd-debug-skill/issues
- **OpenOCD 文档**: http://openocd.org/doc/doxygen/index.html

---

<p align="center">
  <strong>🤖 Made for ANY AI, by AI, with ❤️ for embedded developers.</strong><br>
  <strong>🤖 为任何 AI 而生，由 AI 制作，为嵌入式开发者献上 ❤️。</strong>
</p>
