# SOLO 技能开发指南

> 为本仓库贡献新技能或适配上游技能的开发规范。

---

## 技能结构

每个技能是一个**独立的目录**，必须包含：

```
my-skill/
├── SKILL.md          # 核心：技能说明文档（必需）
├── _meta.json        # skillhub 元数据（推荐）
├── README.md         # 技能使用说明（推荐）
└── references/       # 参考文件（可选）
    └── ...
```

## SKILL.md 规范

### YAML Frontmatter（必需）

```yaml
---
name: My Skill Name            # 技能展示名称
slug: my-skill                  # 唯一标识符（用于 skillhub 安装）
version: 1.0.0-solo             # 版本号（SOLO 适配版加 -solo 后缀）
description: "一句话说明技能"    # 简短描述
tags: ["tag1", "tag2"]          # 标签，便于搜索
---
```

### 内容要求

- 清晰说明 **何时使用（When to Use）**
- 详细的操作步骤（分步骤、可执行）
- 如果是对上游技能的适配，应说明适配内容

## 版本号规范

```
{主版本}.{次版本}.{修订}[-solo]
```

- 上游有对应版本时，基版与上游对齐
- `-solo` 后缀表示 SOLO 专有修改
- 纯 SOLO 自研技能从 `1.0.0` 开始

## 适配上游技能的 Checklist

当从其他平台（WorkBuddy / OpenClaw / Claude Code）移植技能时，必须完成以下适配：

- [ ] 路径：`~/.workbuddy/` → `~/.trae-cn/`
- [ ] 命令：`bash` → 跨平台（Windows PowerShell 兼容）
- [ ] 路径风格：macOS `/Users/xxx` → Windows `C:\Users\xxx`
- [ ] 客户端检测：`__CFBundleIdentifier` → `TRAE_RUNTIME` / `TRAE_CONFIG_CHANNEL`
- [ ] 内置技能目录：其他 Agent 路径 → `.trae-cn/builtin/*/*/skills/`
- [ ] 工具调用：shell `ls/curl` → SOLO 内置 `LS/Read/Glob/Grep/WebFetch/WebSearch`
- [ ] 移除引流推广、非中立品牌信息
- [ ] 安装方式：适配 `skillhub install` 命令
- [ ] 版本号加 `-solo` 后缀
- [ ] 更新 `_meta.json` 中的 `ownerId` 和 `slug`

## 发布到本仓库

```bash
# 1. 在仓库创建技能目录
mkdir -p solo-skills/my-skill

# 2. 编写 SKILL.md

# 3. 创建 _meta.json

# 4. 提交 PR
git add my-skill/
git commit -m "feat: add my-skill v1.0.0-solo"
git push origin main
```

## 发布到 SkillHub 注册表

将技能发布到 SkillHub 后，可通过 `skillhub install` 直接安装：

```bash
# 登录 SkillHub
skillhub login

# 发布技能
skillhub publish ./my-skill --version 1.0.0 --changelog "initial release"

# 安装验证
skillhub install my-skill --dir <SOLO-skills-dir>
```

查看 [SkillHub 官方文档](https://skillhub.cn) 获取更多发布信息。
