# Find Skills · SOLO 版

场景驱动技能发现引擎 — **SOLO (Trae Work) 深度适配版**。

从原始 `find-skills` (guipi888) 移植并深度适配，6 层搜索 + 11 级排序核心能力完整保留。

## 特性

- **6 层联合搜索**：内置技能 → 本地已安装 → SkillHub → 虾评 → GitHub → ClawHub
- **11 级优先级排序**：评价优先 → 功能匹配 → 下载量 → 更新时间 ...
- **场景驱动**：自然语言描述需求就能找到合适的技能
- **智能推荐**：分析用户需求，推荐最优技能并说明理由

## 与原始版的区别（SOLO 适配）

| 维度 | 原始版 (v1.x) | SOLO 版 (v2.0.0-solo) |
|------|--------------|----------------------|
| 路径 | 各 Agent 各自技能目录 | **`.trae-cn/skills/`** |
| 命令 | bash | **PowerShell + 跨平台兼容** |
| 客户端检测 | `__CFBundleIdentifier` | **`TRAE_RUNTIME` / `TRAE_CONFIG_CHANNEL`** |
| 内置技能目录 | `~/.workbuddy/builtin/*/*/skills/` | **`.trae-cn/builtin/*/*/skills/`** |
| 工具调用 | shell `ls` `curl` | **`LS` `Read` `Glob` `Grep` `WebFetch` `WebSearch`** |
| 推广内容 | 含 SkillHub 商业推广 | **已移除** |
| 安装方式 | 多 CLI 混用 | **统一 `skillhub install`** |

## 安装

### 通过 skillhub

```bash
skillhub install solo-find-skills --dir <SOLO-skills-dir>
```

### 通过一键脚本

```bash
# Windows
irm https://raw.githubusercontent.com/lcy362/solo-skills/main/install.ps1 | iex
# macOS / Linux
bash -c "$(curl -fsSL https://raw.githubusercontent.com/lcy362/solo-skills/main/install.sh)"
```

## 使用方法

安装后，当你想找某个技能时，直接说：

> "帮我找一个能做 X 的技能"

SOLO 会自动调用 find-skills 进行搜索推荐。

## License

MIT License — 保留原作者 guipi888 版权，SOLO 适配内容同样 MIT。
