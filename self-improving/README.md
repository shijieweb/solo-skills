# Self-Improving + Proactive Agent · SOLO 版

自我反思 + 自我批评 + 自我学习 + 自组织记忆系统 — **SOLO (Trae Work) 精简适配版**。

从原始 `self-improving` v1.2.16 (ivangdavila) 移植并精简，已适配 SOLO 环境。

## 特性

- **自我反思**：完成任务后自动评估质量，发现改进机会
- **基于纠正的学习**：如实记录每次用户纠正，3 次同类修正 → 晋升为永久规则
- **三级记忆体系**：HOT（始终加载 ≤100行）/ WARM（按需）/ COLD（归档）
- **无需外部 API**：全部数据存于本地 `~/self-improving/`，纯 Markdown
- **自动降级**：长期不用的模式自动降级归档，不浪费上下文

## 与原始版的区别（SOLO 精简）

| 维度 | 原始版 (v1.2.16) | SOLO 版 (v1.2.16-solo) |
|------|------------------|----------------------|
| SKILL.md 大小 | 8.5 KB | **4.5 KB（-47%）** |
| 内容范围 | 含 Quick Queries / Memory Stats / Common Traps / Related Skills / Feedback | 聚焦核心三件套：HOT 记忆 / Corrections / Self-Reflection |
| MCP 融合 | 无 | 关联 `🧠 self-improving 规范` MCP 实体，跨会话永久留存 |
| 数据文件 | 模板文件 | **已写入真实业务数据** |

## 安装方式

### 通过 skillhub 安装

```bash
skillhub install solo-self-improving --dir <SOLO-skills-dir>
```

### 手动安装

```bash
git clone https://github.com/lcy362/solo-skills.git
# 复制 self-improving/ 整个目录到 SOLO 技能目录
# 首次使用前运行 references/setup.md 中的初始化步骤
```

## 首次初始化

本技能依赖 `~/self-improving/` 目录结构，首次使用需初始化：

```bash
mkdir -p ~/self-improving/{projects,domains,archive}
touch ~/self-improving/memory.md
touch ~/self-improving/corrections.md
touch ~/self-improving/index.md
touch ~/self-improving/heartbeat-state.md
```

## 项目结构

```
self-improving/
├── SKILL.md                    # 核心技能说明（精简版）
├── _meta.json                  # skillhub 元数据
├── README.md                   # 本文件
└── references/
    ├── setup.md                # 初始化指南（完整版）
    ├── operations.md            # 操作指南
    ├── boundaries.md           # 安全边界
    ├── scaling.md              # 扩展策略
    └── memory-template.md      # 记忆模板
```

## License

MIT License — 保留原作者 Iván Dávila (ivangdavila) 版权，SOLO 精简内容同样 MIT。
