# ============================================================
#  agentmemory 一键安装脚本
#  用法：
#    powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/agentmemory/agentmemory-oneclick.ps1 | iex"
#
#  或手动下载运行：
#    powershell -ExecutionPolicy Bypass -File agentmemory-oneclick.ps1
# ============================================================
param(
    [switch]$SkipOps    # 跳过运维脚本（仅安装技能核心）
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ─── 配色 ───
$Cyan   = [ConsoleColor]::Cyan
$Green  = [ConsoleColor]::Green
$Yellow = [ConsoleColor]::Yellow
$Red    = [ConsoleColor]::Red
$Magenta= [ConsoleColor]::Magenta

function Write-Step { param($n,$t) Write-Host " [$n/4] $t" -ForegroundColor $Cyan }
function Write-OK   { param($t) Write-Host "       ✅ $t" -ForegroundColor $Green }
function Write-Warn { param($t) Write-Host "       ⚠️  $t" -ForegroundColor $Yellow }
function Write-Err  { param($t) Write-Host "       ❌ $t" -ForegroundColor $Red }
function Write-Info { param($t) Write-Host "       ℹ️  $t" -ForegroundColor $Magenta }

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor $Cyan
Write-Host "║   🧠 agentmemory 一键安装                    ║" -ForegroundColor $Cyan
Write-Host "║   SOLO Agent 自我进化记忆系统 v1.0           ║" -ForegroundColor $Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor $Cyan
Write-Host ""

# ─── 环境变量 ───
$SkillsDir  = "$env:USERPROFILE\.trae-cn\skills\agentmemory"
$McpDir     = "$env:USERPROFILE\.trae-cn\mcps"
$WorkDir    = "$env:USERPROFILE\Documents\Traework"
$OpsDir     = "$SkillsDir\references\ops"
$GitHubRaw  = "https://raw.githubusercontent.com/shijieweb/solo-skills/main/agentmemory"

# ─── Step 1: 下载技能核心文件 ───
Write-Step 1 "安装 agentmemory 技能到 .trae-cn/skills/"

$files = @(
    @{Path="$SkillsDir\SKILL.md";      Url="$GitHubRaw/SKILL.md"},
    @{Path="$SkillsDir\_meta.json";    Url="$GitHubRaw/_meta.json"},
    @{Path="$SkillsDir\references\install-guide.md"; Url="$GitHubRaw/references/install-guide.md"}
)

# 确保目录存在
$dirs = @($SkillsDir, "$SkillsDir\references")
foreach ($d in $dirs) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

foreach ($f in $files) {
    $dir = Split-Path $f.Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    
    try {
        Invoke-WebRequest -Uri $f.Url -OutFile $f.Path -UseBasicParsing -ErrorAction Stop
        Write-OK "下载: $(Split-Path $f.Path -Leaf)"
    } catch {
        Write-Err "下载失败: $($f.Url)"
        Write-Err "请检查网络连接后重试"
        exit 1
    }
}

# ─── Step 2: MCP 配置自动检查 ───
Write-Step 2 "MCP agentmemory 配置"
$mcpFound = $false

# 检查 MCP 目录下是否已有 agentmemory 配置
Get-ChildItem $McpDir -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -eq "mcp_agentmemory" -or $_.Name -eq "agentmemory"
} | ForEach-Object {
    $mcpFound = $true
}

if ($mcpFound) {
    Write-OK "MCP agentmemory 配置已存在"
} else {
    Write-Warn "未检测到 MCP agentmemory 配置"
    Write-Info "SOLO 重启后会自动扫描 .trae-cn/skills/agentmemory/SKILL.md 中的 MCP 声明并连接"
    Write-Info "如果重启后仍未连接，请在 SOLO → Settings → MCP 管理 → 搜索启用 'agentmemory'"
}

# ─── Step 3: Ops 运维脚本（可选） ───
Write-Step 3 "运维脚本（审查、备份、保活、恢复）"

if ($SkipOps) {
    Write-Info "已跳过运维脚本（参数 -SkipOps）"
} else {
    $opsDirCreated = $false
    if (-not (Test-Path $OpsDir)) { 
        New-Item -ItemType Directory -Path $OpsDir -Force | Out-Null
        $opsDirCreated = $true
    }

    $opsFiles = @(
        "agentmemory-self-review.py",
        "agentmemory-agent.ps1",
        "agentmemory-startup.ps1",
        "agentmemory-keepalive.ps1",
        "agentmemory-backup-agent.ps1",
        "agentmemory-sync.py",
        "agentmemory_restore.py"
    )

    $downloaded = 0
    foreach ($fn in $opsFiles) {
        try {
            $url = "$GitHubRaw/references/ops/$fn"
            $out = "$OpsDir\$fn"
            Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -ErrorAction Stop
            $downloaded++
        } catch {
            Write-Warn "下载失败(可跳过): $fn"
        }
    }
    Write-OK "运维脚本已下载: $downloaded / $($opsFiles.Count)"

    # 复制一份到 Traework 方便直接使用
    foreach ($fn in $opsFiles) {
        $src = "$OpsDir\$fn"
        $dst = "$WorkDir\$fn"
        if (Test-Path $src) {
            try { Copy-Item $src $dst -Force -ErrorAction Stop } catch { }
        }
    }
    Write-OK "已同步到 $WorkDir"
}

# ─── Step 4: 注册 Windows Task Scheduler（开机启动+保活） ───
Write-Step 4 "开机自启 + 守护进程"

if ($SkipOps) {
    Write-Info "已跳过（参数 -SkipOps）"
} else {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Warn "非管理员权限，跳过 Task Scheduler 注册"
        Write-Info "如需开机自启，请以管理员身份运行此脚本"
        Write-Info "手动注册命令:"
        Write-Info "  powershell -Command `"Start-Process powershell -Verb RunAs -ArgumentList '-File $OpsDir\agentmemory-startup.ps1 -Setup'`""
    } else {
        try {
            $startupScript = "$OpsDir\agentmemory-startup.ps1"
            if (Test-Path $startupScript) {
                & $startupScript -Setup
                Write-OK "开机自启任务已注册 (Task: SOLO-agentmemory)"
            } else {
                Write-Warn "startup.ps1 未下载，跳过"
            }
        } catch {
            Write-Warn "Task Scheduler 注册失败: $_"
        }
    }
}

# ─── 安装完成 ───
Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor $Green
Write-Host "║   ✅ agentmemory 安装完成！                 ║" -ForegroundColor $Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor $Green
Write-Host ""
Write-Host "📁 技能位置: $SkillsDir" -ForegroundColor $Cyan
Write-Host ""

# ─── 关键：引导重启 ───
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor $Magenta
Write-Host "║   🔄 下一步：重启 SOLO 会话                 ║" -ForegroundColor $Magenta
Write-Host "╠════════════════════════════════════════════╣" -ForegroundColor $Magenta
Write-Host "║  技能文件已落位，但 SOLO 需要在下次会话      ║" -ForegroundColor $Magenta
Write-Host "║  启动时加载 SKILL.md 并自动连接 MCP。        ║" -ForegroundColor $Magenta
Write-Host "║                                             ║" -ForegroundColor $Magenta
Write-Host "║  操作：关闭当前 SOLO 窗口，重新打开即可。      ║" -ForegroundColor $Magenta
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor $Magenta
Write-Host ""

# ─── 验证提示 ───
Write-Host "🔍 安装验证：" -ForegroundColor $Cyan
Write-Host "   重启 SOLO 后，发送以下消息测试：" -ForegroundColor $Cyan
Write-Host "   '帮我查一下记忆里老板规则是什么'" -ForegroundColor $Yellow
Write-Host "   SOLO 应回复记忆中的老板规则内容。" -ForegroundColor $Cyan
Write-Host ""

Write-Host "📚 完整文档: https://github.com/shijieweb/solo-skills/tree/main/agentmemory" -ForegroundColor $Green

# ─── 返回安装清单摘要 ───
$summary = @{
    "SKILL.md"       = Test-Path "$SkillsDir\SKILL.md"
    "_meta.json"     = Test-Path "$SkillsDir\_meta.json"
    "install-guide"  = Test-Path "$SkillsDir\references\install-guide.md"
    "ops-scripts"    = (Test-Path $OpsDir) -and ((Get-ChildItem $OpsDir -File).Count -gt 0)
    "mcp-config"     = $mcpFound
    "task-scheduler" = (Get-ScheduledTask -TaskName "SOLO-agentmemory" -ErrorAction SilentlyContinue) -ne $null
}

Write-Host ""
Write-Host "📋 安装清单:" -ForegroundColor $Cyan
foreach ($k in $summary.Keys) {
    $status = if ($summary[$k]) { "✅" } else { "⏳ 需重启后生效" }
    Write-Host "   $status $k"
}

Write-Host ""
Write-Host "🎉 搞定！重启 SOLO 即可使用。" -ForegroundColor $Green