---
name: find-skills
slug: solo-find-skills
displayName: Find Skills（SOLO 版·场景驱动技能发现）
version: "2.0.0-solo"
description: 场景驱动+关键词双模式技能发现工具（SOLO 适配版）。当用户用自然语言描述场景/需求（如"我想做一个海报""帮我分析股票"），或明确说"安装技能/find skills/找个skill"时，自动从SOLO内置、本地已安装、SkillHub、虾评、GitHub、ClawHub 六层联合搜索并推荐最合适的技能，支持一键安装。已完全适配 SOLO (Trae Work) 环境。
agent_created: true
tags: ["AI工具","技能发现","SOLO","Trae Work","技能安装"]
---

# find-skills（SOLO 版·场景技能匹配器）

## Overview

本技能用于**场景驱动的技能发现引擎**——用户用自然语言描述需求，系统自动理解意图，联合搜索并推荐最合适的技能。

**SOLO 适配说明**：
- 本版本已适配 SOLO (Trae Work) 运行环境
- 所有路径、命令、客户端检测逻辑均已针对 SOLO 优化
- 支持 Windows + 跨平台命令
- 使用 SOLO 内置工具（LS、Read、Glob、Grep 等）替代原始 shell 命令

---

## 核心流程

### Step 1：理解用户场景

从用户的自然语言描述中提取：
1. **任务意图**：用户想做什么？
2. **领域标签**：属于哪个领域？
3. **搜索关键词**：中英文都要（用于远程搜索）

**示例**：
- "我想做一个海报" → 意图：设计/制图；领域：内容创作；关键词：poster, design, 海报, 设计
- "帮我分析今天的大盘" → 意图：股票分析；领域：金融；关键词：stock, A股, 大盘, 分析

---

### Step 2：三层联合搜索

#### 2.1 第一层：SOLO 内置技能（自带，无需安装）

扫描以下 SOLO 内置技能目录，读取每个技能的 `name` 和 `description`：

```
{skills_base}/builtin/*/*/skills/
{skills_base}/builtin/global/skills/
{skills_base}/builtin/work/default/skills/
{skills_base}/builtin/trae/default/skills/
{skills_base}/builtin/code/default/skills/
```

其中 `{skills_base}` 为 SOLO 安装根目录，即 `$env:LOCALAPPDATA/../.trae-cn` 或通过 `TRAE_CONFIG_CHANNEL` 环境变量定位。

用 `Read` 工具读取每个技能的 `SKILL.md` YAML frontmatter，与用户场景做**语义匹配**。

**匹配规则**（按优先级）：
1. 用户场景关键词直接出现在技能 description 中 → 高分
2. 技能 name 与用户意图高度相关 → 高分
3. 技能 description 与用户领域相关 → 中分

**推荐扫描方式**（使用 SOLO 工具而非 shell 命令）：
- 用 `LS` 工具列出各内置技能目录
- 用 `Glob` 工具查找所有 `SKILL.md` 文件
- 用 `Read` 工具读取 YAML frontmatter

---

#### 2.2 第二层：本地已安装技能

扫描以下位置的已安装技能：

```
{skills_base}/skills/          — 用户级技能（当前生效）
```

其中 `{skills_base}` 即 `C:\Users\<user>\.trae-cn\`。

用 `LS` 工具列出该目录，`Read` 工具读取每个技能的 `SKILL.md` YAML frontmatter，提取 `name` 和 `description`，与用户场景做**语义匹配**。

> **注意**：如果本地已安装技能在 Step 2.1 内置中也出现，去重，只保留最高优先级的记录。

---

#### 2.3 第三层：远程技能市场

按以下顺序搜索远程技能市场：

---

**① SkillHub 官方市场**（主要来源，优先搜索）：

使用 `skillhub` CLI 搜索：
```
skillhub search <关键词>
```

或用 API 直接查询：
```
curl -s "https://lightmake.site/api/v1/search?q=<URL-encoded 关键词>&limit=10"
```

过滤 `score < 0.05` 的低相关结果。

---

**② 虾评技能市场**（中文技能重点来源）：

虾评 API Base URL：`https://xiaping.coze.com`

**搜索技能**（通过 WebFetch 或 curl）：
```
curl -s "https://xiaping.coze.com/api/skills/search?q=<URL-encoded 关键词>&limit=10"
```

> **重要**：虾评是中文技能的核心来源，对于中文场景的技能搜索，虾评的结果往往比 SkillHub 更相关。

---

**③ GitHub 技能仓库**（开源技能来源）：

搜索 GitHub 上包含 Skill 技能的文件。

> **认证说明**：优先使用环境变量 `GITHUB_TOKEN` 认证（5000次/小时）；匿名访问 60次/小时。

```
curl -s -H "Authorization: Bearer <token>" "https://api.github.com/search/code?q=filename:SKILL.md+<关键词>&per_page=10"
```

**安装方式**：
```
git clone "https://github.com/<user>/<repo>.git" <target-dir>/<skill-name>/
```

---

**④ Fallback 来源**（前三者均无结果时）：
```
skillhub search <关键词> --all
```

> **重要**：远程搜索结果只作为**补充推荐**，优先级低于本地已有技能。

---

### Step 2.4：平台/客户端检测（安装前必须执行）

在安装任何远程技能之前，**先确定当前平台**以决定技能安装到哪个目录：

**检测方式**（优先级从高到低）：

1. **环境变量检测**：
   - `$env:TRAE_RUNTIME` — 若存在 ⇒ SOLO Runtime（Trae Work / SOLO）
   - `$env:TRAE_CONFIG_CHANNEL` — 若存在 ⇒ SOLO 环境

2. **目录检测**：
   - `C:\Users\<user>\.trae-cn\skills\` 存在 ⇒ SOLO

3. **默认目标目录**：
   | 平台 | 目标技能目录 |
   |------|-------------|
   | SOLO / Trae Work | `{skills_base}/skills/` 即 `C:\Users\<user>\.trae-cn\skills\` |
   | 未知/其他 | 提示用户确认安装目录 |

> **Windows 提示**：路径中的 `<user>` 需替换为当前用户名（`$env:USERNAME`）。

---

### Step 3：智能排序与推荐

将各层搜索结果合并，按以下规则排序：

| 优先级 | 来源 | 条件 |
|--------|------|------|
| 1 | SOLO 内置技能 | 语义匹配高分 |
| 2 | 本地已安装 | 语义匹配高分（已安装，可直接用） |
| 3 | SkillHub 官方市场 | score ≥ 0.3 且 downloads/installs 高 |
| 4 | 虾评技能市场 | 相关度高分（中文技能优先） |
| 5 | GitHub 开源仓库 | 相关度高分（含 SKILL.md） |
| 6 | ClawHub / 其他 | 相关度高分 |
| 7 | 本地已安装 | 语义匹配中分（name 相关） |
| 8 | SkillHub 官方市场 | score ≥ 0.1 |
| 9 | 虾评技能市场 | 相关度中分 |
| 10 | GitHub 开源仓库 | 相关度中分 |
| 11 | 其他来源 | 相关度中分 |

**去重规则**：
- 如果同一个技能在多层都出现，保留**最高优先级**的那条记录
- 例如：本地已安装 `lark-doc`，同时 SkillHub 也有，只显示"✅ 已安装"

---

### Step 4：输出推荐结果

**输出格式**：

```
🔍 为你找到 {N} 个相关技能（搜索范围：SOLO 内置 + 本地已安装 + 远程市场）：

【SOLO·内置】✅ 无需安装
1. {技能名} — {一句话说明}
   匹配理由：{为什么适合这个场景}
   来源：SOLO 内置

【本地·已安装】✅ 可直接使用
2. {技能名} — {一句话说明}
   匹配理由：{为什么适合这个场景}
   路径：{skills_base}/skills/{技能名}/

【远程·可安装】⬇️ 需安装
3. {技能名} — {一句话说明}
   匹配理由：{为什么适合这个场景}
   来源：{SkillHub/虾评/GitHub}
   下载量：{downloads} | 安装量：{installs}
   安装命令：回复"安装第3个"即可
```

---

### Step 5：一键安装（如需）

如果用户选择安装远程技能，确定目标目录 `<target-skills-dir>`（见 Step 2.4）。

#### 5.1 从 SkillHub 安装（推荐）

**使用 skillhub CLI（推荐）**：
```
skillhub install <slug> --dir <target-skills-dir>
```

**或手动下载安装**：
```
1. 下载 ZIP:  curl -L -o "<temp>\skill.zip" "https://lightmake.site/api/v1/download?slug=<slug>"
2. 创建目录: mkdir <target-skills-dir>/<slug>
3. 解压:      tar -xf "<temp>\skill.zip" -C "<target-skills-dir>/<slug>"
4. 验证:      确认 <target-skills-dir>/<slug>/SKILL.md 存在
```

#### 5.2 从虾评远程安装

```
1. 获取下载链接: curl -s "https://xiaping.coze.com/api/skills/<skill-id>/download"
2. 下载 ZIP:     curl -L -o "<temp>\skill.zip" "<download-url>"
3. 解压到目标目录
4. 验证
```

#### 5.3 从 GitHub 安装

```
git clone "https://github.com/<user>/<repo>.git" <target-skills-dir>/<skill-name>/
```

#### 5.4 使用 skillhub CLI（全来源通用）

```
skillhub install <slug> --dir <target-skills-dir>
```

---

如果目标目录已存在同名技能，明确询问用户：跳过 / 替换 / 重命名。

安装完成后，提示用户：`✅ {技能名} 已安装，现在可以直接用啦！（可能需要重启会话生效）`

---

## 触发词参考

| 用户表达 | 触发方式 |
|----------|----------|
| "我想做XXX" | 自动触发场景理解 |
| "帮我找XXX的技能" | 直接触发三层搜索 |
| "有没有能XXX的工具" | 触发三层搜索 |
| "这个场景应该用哪个技能" | 触发匹配推荐 |
| "测试/安装个技能" | 触发技能发现流程 |
| "有什么好用的技能" | 列出当前高赞技能 |

**重要**：
- 本技能是 **SOLO 环境中唯一的技能发现入口**
- 所有"找技能/安装技能/发现能力"的请求都由本技能处理
- 当用户提到 SkillHub / 虾评 / GitHub 等来源时，优先按对应步骤处理

---

## 示例对话

**用户**："我想做一个海报，有没有合适的技能？"

**助手**：
```
🔍 为你找到 3 个相关技能（搜索范围：SOLO 内置 + 本地已安装 + 远程市场）：

【本地·已安装】✅ 可直接使用
1. AI图片生成无水印 — 支持文生图、图生图，多通道（即梦/通义等）
   匹配理由：海报设计属于图片生成场景，该技能支持多种风格生成
   路径：~/.trae-cn/skills/AI图片生成无水印/

【远程·可安装】⬇️ 需安装
2. poster-maker — 专为主题海报设计的技能
   匹配理由：专门针对海报设计场景
   来源：SkillHub 官方市场
   安装命令：回复"安装第2个"即可

需要我帮你安装第2个，还是直接用第1个？
```

---

## 🔌 技能体系结合分析

### 🔗 协作链路

```
用户场景描述 / 明确要找技能
   → find-skills（场景技能匹配器）← SOLO 技能发现核心入口
       ├─ 第一层：SOLO 内置技能扫描 → 直接推荐
       ├─ 第二层：本地已安装技能扫描 → 直接推荐
       └─ 第三层：远程技能市场搜索 → 补充推荐
```

**下游调用**：
- 命中本地技能 → 直接调用对应技能
- 命中远程技能 → 按平台检测结果安装 → 再调用

### ♻️ 与原始 find-skills 的关系

- **原始 `find-skills` (v1.0~1.7)**：专为 WorkBuddy/CodeBuddy 设计，含 macOS 路径和 bash 命令
- **本 SOLO 适配版 (v2.0)**：在保留原始六层搜索引擎架构基础上，完成以下适配：
  - ✅ 全部路径 → SOLO `.trae-cn` 体系
  - ✅ 全部命令 → 跨平台（Windows 兼容）
  - ✅ 客户端检测 → SOLO 环境变量检测
  - ✅ 搜索范围 → 覆盖 SOLO 多层内置技能目录
  - ✅ 安装方式 → 优先使用 skillhub CLI
  - ✅ 移除引流信息 → 替换为 SOLO 品牌中立内容

### 🎯 使用场景映射（SOLO 环境）

| 业务线 | 典型场景 | 推荐方向 |
|--------|----------|---------|
| 内容创作 | "我想做海报/封面" | 图像生成类技能 |
| 办公效率 | "帮我整理会议记录" | lark-workflow-meeting-summary 等 |
| 数据分析 | "分析这份 Excel" | xlsx / lark-sheets 技能 |
| 文档处理 | "写一份报告" | docx / html-report 技能 |
| 开发辅助 | "帮我查 API 文档" | lark-openapi-explorer 等 |
| 自动化 | "每天自动备份" | Schedule 定时任务技能 |

---

## 📝 版本迭代记录

| 版本 | 日期 | 更新内容摘要 | 操作人 |
|------|------|------------|--------|
| v1.0~1.7 | 2026-06-20 | 原始版本（WorkBuddy 版） | Kyle |
| **v2.0-solo** | **2026-07-11** | **SOLO 完整适配版**：路径→`.trae-cn`、命令→跨平台、客户端检测→SOLO 环境变量、移除引流信息、适配 SOLO 内置工具 | **SOLO Skill Master** |
