# agentmemory 体系 — 安装复现指南

> 版本：v1.1 | 创建日期：2026-07-14 | 作者：SOLO Agent (Owen)

---

## 🚀 发给别人怎么装？（一键安装）

复制下面这一条命令，在 PowerShell 里粘贴回车，等它跑完，重启 SOLO。

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/agentmemory/agentmemory-oneclick.ps1 | iex"
```

**安装包含：**
| 步骤 | 内容 |
|------|------|
| Step 1 | 下载 SKILL.md + _meta.json + install-guide 到 `.trae-cn/skills/agentmemory/` |
| Step 2 | 自动检测 MCP agentmemory 配置状态 |
| Step 3 | 下载 7 个运维脚本到 `references/ops/` |
| Step 4 | 注册 Windows Task Scheduler 开机自启 |
| 提示 | **重启 SOLO 会话**使 MCP 连接生效 |

**仅最小安装（不要运维脚本）：**
```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/agentmemory/agentmemory-oneclick.ps1 | iex" -SkipOps
```

---

## 📋 手动安装（如果一键脚本不可用）

```powershell
# Windows — 安装 agentmemory 技能
$skill = "agentmemory"; iex "& { $(irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.ps1) } -SkillName $skill"
```

```bash
# macOS / Linux — 安装 agentmemory 技能
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.sh)" -s -- agentmemory
```

---

## ✅ 安装后验证

**重启 SOLO 会话**后，发送以下消息测试：
> **"帮我查一下记忆里老板规则是什么"**

SOLO 应回复记忆中存储的老板规则内容。如果报错或找不到，说明 MCP 未连接——在 SOLO → Settings → MCP 管理 → 搜索启用 "agentmemory"。

---

## 📖 安装后看什么

| 文档 | 位置 |
|------|------|
| 技能定义 (架构/协议) | GitHub solo-skills/agentmemory/SKILL.md |
| 完整进度报告 (组件清单/时间线/决策) | GitHub solo-docs/discussions/agentmemory体系-完整进度报告-2026-07-14.md |
| 三套方案对比 (技术选型) | GitHub solo-docs/discussions/SOLO记忆系统-方案对比-2026-07-13.md |

---

## 🧱 组件架构

```
agentmemory 技能 (SKILL.md)
    ├── agentmemory MCP Server (必须)
    │   ├── memory_save - 写入记忆
    │   ├── memory_smart_search - 语义检索
    │   ├── memory_recall - 按ID召回
    │   ├── memory_sessions - 会话管理
    │   ├── memory_export - 导出记忆
    │   ├── memory_audit - 审计报告
    │   └── memory_governance_delete - 治理删除
    ├── Evolution Engine 技能（内嵌 SKILL.md）
    │   └── 三阶八柱：感知→理性→策略 + 元认知 + 契约
    └── 运维守护脚本 (ops/)
        ├── agentmemory-agent.ps1 — 统一守护
        ├── agentmemory-backup-agent.ps1 — 日备份
        ├── agentmemory-startup.ps1 — 开机恢复
        ├── agentmemory-keepalive.ps1 — 进程保活
        ├── agentmemory-self-review.py — 30分钟审查
        ├── agentmemory-sync.py — 数据同步
        └── agentmemory_restore.py — 数据恢复
```

---

## ❓ 常见问题

### Q: 安装后重启 SOLO 还是不生效？
A: 检查 SOLO → Settings → MCP 管理 中 agentmemory 是否已出现。如果未出现，需要在 MCP 管理界面手动搜索启用。

### Q: 记忆写入后搜不到？
A: 用 memory_smart_search 验证（不是 memory_recall）。semantic search 有索引延迟 1-2 秒。

### Q: 重启后记忆丢失？
A: agentmemory 后端退出一段时间后会挂起。需要安装 agentmemory-keepalive.ps1 守护或手动 `mcp-agentmemory restart`。

---

## 📦 依赖清单

| 依赖 | 版本要求 | 安装方式 |
|------|----------|----------|
| SOLO (Trae Work) | latest | 官方下载 |
| agentmemory MCP | latest | 脚本自动配置 / SOLO MCP 管理 |
| Python (仅审查脚本需要) | >= 3.9 | 系统安装 |

---

## 📝 更新日志

| 版本 | 日期 | 更新者 | 变更内容 |
|------|------|--------|----------|
| v1.1 | 2026-07-14 | SOLO Agent | 新增一键安装脚本入口 |
| v1.0 | 2026-07-14 | SOLO Agent | 初始创建 |