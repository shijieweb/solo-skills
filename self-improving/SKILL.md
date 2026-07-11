---
name: Self-Improving + Proactive Agent
slug: self-improving
version: 1.2.16-solo
homepage: https://clawic.com/skills/self-improving
description: "Self-reflection + Self-criticism + Self-learning + Self-organizing memory. Agent evaluates its own work, catches mistakes, and improves permanently. Use when (1) a command, tool, API, or operation fails; (2) the user corrects you or rejects your work; (3) you realize your knowledge is outdated or incorrect; (4) you discover a better approach; (5) the user explicitly installs or references the skill for the current task."
changelog: "SOLO 精简版 v1.2.16-solo：去除 Quick Queries/Related Skills 等非核心内容，聚焦 HOT 记忆/Corrections/Self-Reflection 三大核心机制"
metadata: {"clawdbot":{"emoji":"🧠","requires":{"bins":[]},"os":["linux","darwin","win32"],"configPaths":["~/self-improving/"]}}

---

## When to Use

User corrects you or points out mistakes. You complete significant work and want to evaluate the outcome. You notice something in your own output that could be better. Knowledge should compound over time without manual maintenance.

## Architecture

Memory lives in `~/self-improving/` with tiered structure. If `~/self-improving/` does not exist, initialize with `setup.md`.

```
~/self-improving/
├── memory.md          # HOT: ≤100 lines, always loaded
├── index.md           # Topic index with line counts
├── heartbeat-state.md # Heartbeat state
├── projects/          # Per-project learnings
├── domains/           # Domain-specific (code, operations, comms)
├── archive/           # COLD: decayed patterns
└── corrections.md     # Last 50 corrections log
```

## Learning Signals

Log automatically when you notice these patterns:

**Corrections** → add to `corrections.md`, evaluate after 3x for promotion to `memory.md`:
- "No, that's not right..." / "Actually, it should be..." / "You're wrong about..."
- "I prefer X, not Y" / "Remember that I always..." / "Stop doing X"

**Preference signals** → add to `memory.md` if explicit:
- "I like when you..." / "Always do X for me" / "Never do Y" / "My style is..."

**Pattern candidates** → track, promote after 3x:
- Same instruction repeated 3+ times, workflow that works well repeatedly

**Ignore** (don't log): one-time instructions, context-specific ("in this file..."), hypotheticals.

## Self-Reflection

After completing significant work, pause and evaluate:
1. **Did it meet expectations?** — Compare outcome vs intent
2. **What could be better?** — Identify improvements for next time
3. **Is this a pattern?** — If yes, log to `corrections.md`

**Log format:**
```
CONTEXT: [type of task]
REFLECTION: [what I noticed]  
LESSON: [what to do differently]
```

## Core Rules

### 1. Learn from Corrections and Self-Reflection
- Log when user explicitly corrects you or you identify improvements
- Never infer from silence alone
- After 3 identical lessons → ask to confirm as rule, then promote to HOT

### 2. Tiered Storage
| Tier | Location | Size | Behavior |
|------|----------|------|----------|
| HOT | memory.md | ≤100 lines | Always loaded |
| WARM | projects/, domains/ | ≤200 lines each | Load on context match |
| COLD | archive/ | Unlimited | Load on explicit query |

### 3. Automatic Promotion/Demotion
- Pattern used 3x in 7 days → promote to HOT
- Pattern unused 30 days → demote to WARM; 90 days → archive to COLD
- Never delete without asking

### 4. Namespace Isolation
- Project patterns stay in projects/{name}.md; global preferences in HOT
- Cross-namespace inheritance: global → domain → project

### 5. Conflict Resolution
Most specific wins (project > domain > global). Same level: most recent wins. Ambiguous → ask user.

### 6. Compaction
When file exceeds limit: merge similar corrections, archive unused, summarize verbose entries. Never lose confirmed preferences.

### 7. Security Boundaries
Never store credentials, health data, third-party info. See boundaries.md.

### 8. Graceful Degradation
If context limit hit: load only HOT, load WARM on demand. Never fail silently.

## Scope

This skill ONLY:
- Learns from user corrections and self-reflection
- Stores preferences in local files (`~/self-improving/`)
- Reads its own memory files on activation

This skill NEVER:
- Accesses calendar, email, or contacts
- Makes network requests
- Reads files outside `~/self-improving/`
- Infers preferences from silence
- Deletes without asking
- Modifies its own SKILL.md
