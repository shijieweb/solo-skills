# 🧰 SOLO Skills

> **SOLO (Trae Work)** 专属技能仓库 — 精心适配、持续维护的高质量技能合集。

本仓库收集了经过 **SOLO 环境适配** 的开源技能，确保在 SOLO (Trae Work) 上开箱即用。每个技能都已针对 Windows 路径、PowerShell 命令、SOLO 内置工具链优化，并保留完整的核心能力。

---

## 📦 技能清单

| 技能 | 版本 | 描述 | 来源 |
|------|------|------|------|
| 🔍 **[find-skills](find-skills/)** | v2.0.0-solo | 场景驱动技能发现引擎 — 自然语言描述需求，六层联合搜索推荐最合适的技能 | [guipi888/find-skills](https://github.com/guipi888/find-skills) |
| 🧠 **[self-improving](self-improving/)** | v1.2.16-solo | 自我反思 + 自我批评 + 自我学习 + 自组织记忆，让 AI 越用越聪明 | [ivangdavila/self-improving](https://clawic.com/skills/self-improving) |

---

## 🚀 快速安装

### 方式一：一键安装脚本

**Windows (PowerShell)**：
```powershell
# 以管理员身份运行
irm https://raw.githubusercontent.com/lcy362/solo-skills/main/install.ps1 | iex
```

**macOS / Linux**：
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/lcy362/solo-skills/main/install.sh)"
```

### 方式二：手动安装单个技能

```bash
# 克隆仓库
git clone https://github.com/lcy362/solo-skills.git

# 复制技能到 SOLO 技能目录
cp -r solo-skills/find-skills ~/.trae-cn/skills/
cp -r solo-skills/self-improving ~/.trae-cn/skills/
```

### 方式三：通过 skillhub CLI 安装

```bash
# 先确保 skillhub CLI 已安装
skillhub install solo-find-skills --dir ~/.trae-cn/skills/
skillhub install solo-self-improving --dir ~/.trae-cn/skills/
```

---

## 🔄 版本策略

### 版本号规范
- **格式**: `{主版本}.{次版本}.{修订}-solo`
- `-solo` 后缀表示这是经过 SOLO 环境适配的版本
- 基版与上游版本号对齐，方便追踪更新

### 更新策略
当上游有新版本时，我们会：
1. 合并上游的 **方法论改进 / Bug 修复**
2. **保留** 所有 SOLO 适配修改（路径、命令、工具链）
3. 更新版本号，保持 `-solo` 后缀

### 当前维护的技能

| 技能 | 上游版本 | 我们的版本 | SOLO 适配内容 |
|------|---------|-----------|-------------|
| find-skills | v1.x | **v2.0.0-solo** | 路径→`.trae-cn`、命令→PowerShell/跨平台、客户端检测→SOLO 环境变量、移除推广内容 |
| self-improving | v1.2.16 | **v1.2.16-solo** | SKILL.md 压缩 47%、MCP 融合、数据文件已写入真实业务 |

---

## 📖 技能开发指南

> 想贡献或自建技能？看 [docs/skill-dev.md](docs/skill-dev.md)。

每个技能是一个独立目录，必须包含：
- `SKILL.md` — 技能说明（核心文件，YAML frontmatter + Markdown 正文）
- `_meta.json` — skillhub 元数据（可选，用于发布到注册表）

---

## 🧪 测试验证

安装新技能后应验证：
1. 技能目录中有 `SKILL.md`
2. `SKILL.md` 包含完整的 YAML frontmatter
3. 重启 SOLO 会话后技能生效
4. 核心功能按预期工作

---

## 📄 License

本仓库中每个技能保留其原始 License（均为 MIT），SOLO 适配内容同样基于 MIT 协议开源。

---

**Made with ❤️ for SOLO (Trae Work) Ecosystem**
