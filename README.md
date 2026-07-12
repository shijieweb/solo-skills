# 🧰 SOLO Skills

**Made with ❤️ for SOLO (Trae Work) Ecosystem**

---

> **⛔ 红线警告：提交前必须先读 README！**
> 
> 所有 MCP Agent / 协作者在执行任何提交操作前：
> 1. **必须先阅读本 README** 了解操作规则和三库导航
> 2. **必须遵守"返回链接+摘要"的强制约定**（见下方 MCP 操作规则）
> 3. 未遵守规则的提交视为违规操作，将被记录追溯
> 
> **一句话约定：提交前先看 README，否则算违规**

---

精选、适配、开箱即用的 SOLO 技能集合。所有技能均经过本地化适配，修正了开源版本的兼容性问题，并增加了 SOLO 专有特性增强。

---

## 📦 包含的技能

| 技能 | 版本 | 说明 | 来源 |
|------|------|------|------|
| 🔍 **find-skills** | v2.0.0-solo | 场景驱动+关键词双模式技能发现引擎，6 层联合搜索，11 级优先级排序 | 基于 SkillHub 社区版适配 |
| 🧠 **self-improving** | v1.2.16-solo | Agent 自我改进框架：HOT/WARM/COLD 记忆分层、纠错学习、Self-Reflection、自动晋升/降级 | 基于 ivangdavila/self-improving 适配 |
| 📥 **douyin-xiazai** | v1.0.0-solo | 抖音无水印视频下载与去水印工具，浏览器提取+curl下载，支持视频贴纸水印去除 | 原创 |

---

## 🚀 安装

### 方式一：一键安装全部

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.ps1 | iex
```

**macOS / Linux:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.sh)"
```

### 方式二：安装单个技能

**Windows — 仅安装 find-skills:**
```powershell
$skill = "find-skills"; iex "& { $(irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.ps1) } -SkillName $skill"
```

**Windows — 仅安装 self-improving:**
```powershell
$skill = "self-improving"; iex "& { $(irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.ps1) } -SkillName $skill"
```

**macOS / Linux — 仅安装 find-skills:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.sh)" -s -- find-skills
```

**macOS / Linux — 仅安装 self-improving:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.sh)" -s -- self-improving
```

> 💡 安装完成后，**重启 SOLO 会话** 技能即可生效。

---

## ☁️ 云端安装（Web/Cloud SOLO）

**一句话安装单个技能 — 直接告诉 AI：**
> 去 GitHub `shijieweb/solo-skills` 安装 **find-skills** 这个技能

或者用一键命令：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.sh)" -s -- find-skills
```

**安装全部技能:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.sh)"
```

云端环境与本地安装命令完全一致。安装脚本会自动检测 `.trae-cn/skills` 目录位置。

---

## 🔌 MCP 兼容性说明

> ⚠️ **重要：云端环境通常不加载 MCP（Model Context Protocol）**

| 技能 | 是否依赖 MCP | 云端运行表现 |
|------|-------------|-------------|
| **find-skills** | ❌ 不依赖 | 完全正常运行，所有 6 层搜索通道正常 |
| **self-improving** | ❌ 不依赖 | 完全正常运行，记忆存储在本地文件，无需 MCP |
| **douyin-xiazai** | ⚠️ 依赖 MCP Browser | 下载功能需 MCP browser 提取视频 URL；去水印仅需 OpenCV + ffmpeg |

**详细解释：**

- **find-skills** 的所有搜索功能内置在 SKILL.md 中，通过 Tavily 网络搜索实现，不依赖 MCP Memory。MCP 仅作为可选的额外搜索来源。
- **self-improving** 的记忆系统完全基于本地文件（`~/self-improving/`），HOT/WARM/COLD 分层、纠错学习、自我反思等核心功能不需要 MCP。MCP Memory 仅作为可选的"热升级"通道（promotes_to 关联），缺失时自动降级为纯文件模式。

**结论：云端环境无 MCP 也不影响任何技能的核心功能，自动降级运行。**

---

## 🔄 版本更新

所有技能支持版本更新检查。在 SOLO 中运行：
> 检查所有技能更新

脚本会从原始来源（SkillHub / GitHub）拉取最新版本号，与本地安装版本对比，并在有更新时提示。

---

## 📂 仓库结构

```
solo-skills/
├── find-skills/           # 🔍 技能发现引擎
│   ├── SKILL.md           #   技能定义（核心）
│   └── _meta.json         #   元数据
├── self-improving/        # 🧠 自我改进框架
│   ├── SKILL.md           #   技能定义（核心）
│   ├── _meta.json         #   元数据
│   └── references/        #   参考文档
├── douyin-xiazai/         # 📥 抖音无水印下载
│   ├── SKILL.md           #   技能定义（核心）
│   └── _meta.json         #   元数据
├── docs/
│   └── skill-dev.md       #   SOLO 技能适配开发指南
├── install.sh             #   macOS/Linux 安装脚本
├── install.ps1            #   Windows 安装脚本
└── README.md              #   本文件
```

---

## 📌 MCP 操作规则

> **本仓库是技能源仓库，每次通过 MCP 执行文件操作后，必须立即返回给用户：**
> 1. **文件链接**（GitHub 页面链接）— 用户可直接点击打开阅读
> 2. **操作摘要**（创建了什么 / 修改了什么 / 删除了什么）— 简明扼要
>
> 格式示例：
> ✅ 已更新 [README.md](https://github.com/shijieweb/solo-skills/blob/main/README.md) — 补充了 MCP 操作规则

---

## 🛠️ 本地开发

详见 [docs/skill-dev.md](docs/skill-dev.md)。

---

## 📜 许可

本仓库内所有技能均为开源项目，遵循各自上游项目的开源协议。SOLO 适配修改部分仅供学习交流使用。