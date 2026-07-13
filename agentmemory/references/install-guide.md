# agentmemory 体系 — 安装复现指南

> 版本：v1.0 | 创建日期：2026-07-14 | 作者：SOLO Agent (Owen)

---

##  发给别人怎么装？

这套体系的核心依赖是 **SOLO (Trae Work) + agentmemory MCP + agentmemory Skill**。

接收方需要有运行 SOLO 的环境（Windows / macOS / Linux / 云端），然后按以下步骤操作。

### 一键最小安装

```powershell
# Windows — 安装 agentmemory 技能
$skill = "agentmemory"; iex "& { $(irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.ps1) } -SkillName $skill"
```

```bash
# macOS / Linux — 安装 agentmemory 技能
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.sh)" -s -- agentmemory
```

### 完整部署流程

```
步骤1: SOLO → Settings → MCP 管理 → 搜索并启用 "agentmemory" MCP
步骤2: 安装 agentmemory 技能（上面的命令）
步骤3: 重启 SOLO 会话
步骤4 (验证): 在 SOLO 中测试 "memory_smart_search 老板规则"
```

###  安装后看什么

| 文档 | 位置 |
|------|------|
| 技能定义 (架构/协议) | GitHub solo-skills/agentmemory/SKILL.md |
| 完整进度报告 (组件清单/时间线/决策) | GitHub solo-docs/discussions/agentmemory体系-完整进度报告-2026-07-14.md |
| 三套方案对比 (技术选型) | GitHub solo-docs/discussions/SOLO记忆系统-方案对比-2026-07-13.md |

##  组件架构

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
    ├── agentmemory-self-review.py (推荐)
    │   └── 30分钟审查 + 双轨审校 + 脉冲信号 + 概念聚类
    └── 运维守护脚本 (推荐)
        ├── agentmemory-agent.ps1 — GitHub同步
        ├── agentmemory-backup-agent.ps1 — 日备份
        ├── agentmemory-startup.ps1 — 开机恢复
        └── agentmemory-keepalive.ps1 — 进程保活
```

##  运维脚本安装 (Windows-only)

运维脚本目前仅支持 Windows（PowerShell + Task Scheduler）。

```powershell
# 从 GitHub 下载运维脚本
curl -o agentmemory-self-review.py https://raw.githubusercontent.com/shijieweb/solo-skills/main/agentmemory/references/agentmemory-self-review.py
curl -o agentmemory-agent.ps1 https://raw.githubusercontent.com/shijieweb/solo-skills/main/agentmemory/references/agentmemory-agent.ps1
# ... (其他脚本同理)

# 注册 Scheduled Task: 30分钟审查
$action = New-ScheduledTaskAction -Execute "python" -Argument "C:\Users\$env:USERNAME\Documents\Traework\agentmemory-self-review.py"
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 30) -At (Get-Date) -Once
Register-ScheduledTask -TaskName "agentmemory-self-review" -Action $action -Trigger $trigger -RunLevel Highest
```

##  常见问题

### Q: 技能安装后不生效？
A: 重启 SOLO 会话。技能在会话启动时加载。

### Q: agentmemory MCP 找不到？
A: 确认 SOLO → Settings → MCP 管理 中 agentmemory 已启用。如果不可见，需要先在 MCP 市场安装。

### Q: 记忆写入后搜不到？
A: 用 memory_smart_search 验证（不是 memory_recall）。semantic search 有索引延迟 1-2 秒。

### Q: 重启后记忆丢失？
A: agentmemory 后端退出一段时间后会挂起。需要安装 agentmemory-keepalive.ps1 守护或手动 `mcp-agentmemory restart`。

##  依赖清单

| 依赖 | 版本要求 | 安装方式 |
|------|----------|----------|
| SOLO (Trae Work) | latest | 官方下载 |
| agentmemory MCP | latest | SOLO MCP 市场 |
| Python (仅审查脚本需要) | >= 3.9 | 系统安装 |
| Git (仅同步脚本需要) | >= 2.0 | 系统安装 |

---

##  更新日志

| 版本 | 日期 | 更新者 | 变更内容 |
|------|------|--------|----------|
| v1.0 | 2026-07-14 | SOLO Agent | 初始创建 |
