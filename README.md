# 🧰 SOLO Skills

**Made with ❤️ for SOLO (Trae Work) Ecosystem**

---

> **⛔ 红线警告：提交前必须先读 README！**
> 
> 所有 MCP Agent / 协作者在执行任何提交操作前：
> 1. **必须先阅读本 README** 了解操作规则和三库导航
> 2. **必须遵守"返回链接+摘要"的强制约定**（见下方 MCP 操作规则）
> 3. **必须遵守技能提交规范**（见下方 📐 技能提交规范）
> 4. 未遵守规则的提交视为违规操作，将被记录追溯
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

## 📐 技能提交规范

> **所有提交技能的 Agent/协作者必须遵守以下规范，否则视为违规。**

### 🆕 提交新技能

每个技能必须包含以下文件结构：

```
<skill-name>/
├── SKILL.md        # 技能定义（必需）
└── _meta.json      # 元数据（必需）
```

### 📋 _meta.json 必填字段

```json
{
  "ownerId": "solo-skills",
  "slug": "solo-<skill-name>",
  "version": "<版本号>-solo",
  "publishedAt": <提交时间戳>,
  "homepage": "https://github.com/shijieweb/solo-skills/tree/main/<skill-name>",
  "source": {
    "type": "<来源类型>",
    "url": "<原始来源 URL>",
    "author": "<原作者/团队>",
    "license": "<原始协议>",
    "upstreamVersion": "<上游版本号>"
  }
}
```

### 🏷️ source.type 来源类型说明

| source.type | 含义 | source.url 要求 | 示例 |
|-------------|------|-----------------|------|
| `original` | 完全原创，无外部参考 | 可留空 `""` | 自行编写的新技能 |
| `adapted` | 基于外部项目适配/修改 | **必填**，指向原始仓库或文档 URL | 基于 SkillHub 社区版适配 |
| `inspired` | 受外部项目启发，但核心代码自写 | 建议填写，指向灵感来源 | 参考某工具思路但自行实现 |
| `forked` | 直接 fork 后微调 | **必填**，指向 fork 的原始仓库 | fork 某 GitHub 仓库后修改 |

### 📝 来源追踪规则

1. **原创技能**（`source.type: original`）：
   - `source.url` 可留空
   - `source.author` 填写创作者名称
   - `source.license` 填写本技能发布的协议

2. **适配/修改技能**（`source.type: adapted/forked`）：
   - `source.url` **必须填写**，指向原始项目地址
   - `source.author` 填写原作者（不是适配者）
   - `source.license` 填写原始项目协议
   - `source.upstreamVersion` 填写适配时基于的上游版本号
   - **SKILL.md 顶部必须注明**：`> 🔗 本技能基于 [项目名](url) v版本 适配，SOLO 适配修改由 <适配者> 完成`

3. **灵感来源技能**（`source.type: inspired`）：
   - `source.url` 建议填写灵感来源
   - 在 SKILL.md 中说明灵感来源即可

### 🔄 更新已有技能

1. **更新 `_meta.json`**：
   - 递增 `version` 版本号（小改 1.0.0→1.1.0，大改 1.0.0→2.0.0）
   - 如果上游有新版本，更新 `source.upstreamVersion`

2. **在 SKILL.md 底部添加更新日志**：
   ```markdown
   ---
   ## 📋 更新日志
   
   | 版本 | 日期 | 更新者 | 变更说明 |
   |------|------|--------|----------|
   | v1.1.0-solo | 2026-07-12 | Agent-A | 修复 XXX 兼容性问题 |
   ```

3. **commit message 格式**：
   - 新增：`🆕 新增技能 <skill-name> v1.0.0-solo`
   - 更新：`🔄 更新 <skill-name> v1.0.0→v1.1.0：<一句话描述>`
   - 适配上游：`🔄 适配上游 <skill-name> 至 v2.0（上游 v1.5→v2.0）`

### 📊 README 技能表更新

每次新增/更新技能时，**必须同步更新本 README 的「📦 包含的技能」表格**：
- 新增技能：添加一行
- 更新版本：更新版本号列
- 来源列格式：`基于 <项目名> 适配` / `原创` / `fork 自 <项目名>` / `灵感来自 <项目名>`

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