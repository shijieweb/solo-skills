# ============================================================
# agentmemory 守护进程 Windows 开机自启动脚本
# 用途：登录后自动拉起 agentmemory，含健康检查 + 崩溃重启
# 部署方式：
#   方案A（推荐）：Task Scheduler 定时任务 - 支持崩溃重启
#   方案B：Startup 文件夹快捷方式 - 简单但不含监控
# ============================================================

param(
    [switch]$Setup,       # --Setup: 创建 Task Scheduler 任务（需管理员权限）
    [switch]$Remove,      # --Remove: 删除已创建的 Task Scheduler 任务
    [switch]$Status,      # --Status: 检查 agentmemory 运行状态
    [switch]$Restart,     # --Restart: 重启 agentmemory
    [switch]$Manual       # --Manual: 前台手动启动（用于调试）
)

$ErrorActionPreference = "Stop"

# ─── 路径配置 ──────────────────────────────────────────────
$NodeExe = "$env:APPDATA\TRAE SOLO CN\ModularData\ai-agent\vm\tools\node\node.exe"
$AgentmemoryCmd = "$env:APPDATA\TRAE SOLO CN\ModularData\ai-agent\vm\tools\node\agentmemory.cmd"
$IiiExe = "$env:USERPROFILE\.local\bin\iii.exe"
$IiiDir = "$env:USERPROFILE\.local\bin"
$AgentmemoryEnv = "$env:USERPROFILE\.agentmemory\.env"
$AgentmemoryData = "$env:USERPROFILE\.agentmemory\data"

# 守护进程端口
$RestPort = 3111
$ViewerPort = 3113

# III 引擎端口
$IiiPort = 49134

# ─── 辅助函数 ──────────────────────────────────────────────
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [$Level] $Message"
    # 同时写入日志文件
    $logDir = "$env:USERPROFILE\.agentmemory\logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    "$ts [$Level] $Message" | Add-Content -Path "$logDir\startup.log" -Encoding UTF8
}

function Test-AgentmemoryHealth {
    try {
        $resp = Invoke-RestMethod -Uri "http://localhost:$RestPort/agentmemory/health" -Method GET -TimeoutSec 5
        return ($resp.status -eq "healthy")
    } catch {
        return $false
    }
}

function Test-IIIEngine {
    try {
        # iii-engine 的 WS 端口通常不直接 HTTP 可访问，检查进程
        $iii = Get-Process -Name "iii" -ErrorAction SilentlyContinue
        return ($null -ne $iii)
    } catch {
        return $false
    }
}

function Stop-Agentmemory {
    Write-Log "正在停止 agentmemory..." "INFO"
    # 终止 agentmemory 进程
    Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -like "*agentmemory*" -or $_.CommandLine -like "*cli.mjs*"
    } | Stop-Process -Force -ErrorAction SilentlyContinue
    # 终止 iii-engine
    Get-Process -Name "iii" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Log "agentmemory 已停止" "INFO"
}

function Start-Agentmemory {
    Write-Log "正在启动 agentmemory..." "INFO"

    # 1. 确保 iii-engine 在 PATH 中
    $env:PATH = "$IiiDir;$env:PATH"

    # 2. 验证 iii.exe 存在
    if (-not (Test-Path $IiiExe)) {
        Write-Log "iii.exe 未找到: $IiiExe - 请先安装 iii-engine" "ERROR"
        Write-Log "  安装命令: 下载 https://github.com/iii-hq/iii/releases/latest 的 Windows 版本到 $IiiDir" "INFO"
        return $false
    }

    # 3. 验证 .env 存在
    if (-not (Test-Path $AgentmemoryEnv)) {
        Write-Log ".env 配置文件未找到: $AgentmemoryEnv" "ERROR"
        return $false
    }

    # 4. 确保数据目录存在
    if (-not (Test-Path $AgentmemoryData)) {
        New-Item -ItemType Directory -Path $AgentmemoryData -Force | Out-Null
    }

    # 5. 检查是否已经在运行
    if (Test-AgentmemoryHealth) {
        Write-Log "agentmemory 已在运行中，跳过启动" "INFO"
        return $true
    }

    # 6. 后台启动 agentmemory
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "$env:APPDATA\TRAE SOLO CN\ModularData\ai-agent\vm\tools\node\agentmemory.cmd"
    $startInfo.Arguments = "serve --port $RestPort"
    $startInfo.UseShellExecute = $false
    $startInfo.WorkingDirectory = "$env:USERPROFILE\.agentmemory"
    $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $startInfo.CreateNoWindow = $true

    # 加载环境变量
    Get-Content $AgentmemoryEnv | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith('#')) {
            $parts = $line -split '=', 2
            if ($parts.Count -eq 2) {
                [Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process')
            }
        }
    }

    $proc = [System.Diagnostics.Process]::Start($startInfo)
    Write-Log "agentmemory 启动中 (PID: $($proc.Id))..." "INFO"

    # 7. 等待健康检查通过
    $maxWait = 30
    for ($i = 1; $i -le $maxWait; $i++) {
        Start-Sleep -Seconds 1
        if (Test-AgentmemoryHealth) {
            Write-Log "agentmemory 健康检查通过! REST: http://localhost:$RestPort, Viewer: http://localhost:$ViewerPort" "OK"
            # 7.1 从 standalone.json 恢复数据
            $restoreScript = "C:\Users\67972\Documents\Traework\agentmemory_restore.py"
            if (Test-Path $restoreScript) {
                try {
                    $restoreOutput = & python $restoreScript 2>&1
                    Write-Log "  记忆恢复结果: $restoreOutput" "INFO"
                } catch {
                    Write-Log "  记忆恢复脚本执行失败: $_" "WARN"
                }
            }
            # 7.2 启动守护 Agent
            $agentScript = "C:\Users\67972\Documents\Traework\agentmemory-agent.ps1"
            $agentRunning = Get-CimInstance -ClassName Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%agentmemory-agent%'" -ErrorAction SilentlyContinue
            if (-not $agentRunning) {
                Start-Process powershell -ArgumentList "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$agentScript`"" -WindowStyle Hidden
                Write-Log "  守护 Agent 已启动" "INFO"
            } else {
                Write-Log "  守护 Agent 已在运行" "INFO"
            }
            return $true
        }
        if ($i % 5 -eq 0) {
            Write-Log " 等待中... ($i/$maxWait 秒)" "INFO"
        }
    }

    Write-Log "agentmemory 启动超时 ($maxWait 秒) - 请检查日志" "WARN"
    return $false
}

# ─── 命令处理 ──────────────────────────────────────────────

if ($Status) {
    Write-Host "=== agentmemory 状态 ==="
    $healthy = Test-AgentmemoryHealth
    Write-Host "  守护进程: $(if ($healthy) {'✅ 运行中 (healthy)'} else {'❌ 未运行'})"
    if ($healthy) {
        $resp = Invoke-RestMethod -Uri "http://localhost:$RestPort/agentmemory/health" -Method GET -TimeoutSec 5
        Write-Host "  版本: $($resp.version)"
        Write-Host "  运行时间: $([math]::Round($resp.health.uptimeSeconds, 0)) 秒 (约 $([math]::Round($resp.health.uptimeSeconds / 60, 1)) 分钟)"
        Write-Host "  内存 RSS: $([math]::Round($resp.health.memory.rss / 1048576, 1)) MB"
        Write-Host "  Worker 函数: $($resp.health.workers[0].function_count)"
        Write-Host "  REST API: http://localhost:$RestPort"
        Write-Host "  Viewer: http://localhost:$($resp.viewerPort)"
    }
    $iiiRunning = Test-IIIEngine
    Write-Host "  iii-engine: $(if ($iiiRunning) {'✅ 运行中'} else {'❌ 未运行'})"
    exit
}

if ($Restart) {
    Stop-Agentmemory
    Start-Sleep -Seconds 2
    Start-Agentmemory
    exit
}

if ($Remove) {
    Write-Log "正在删除 Task Scheduler 任务..." "INFO"
    try {
        Unregister-ScheduledTask -TaskName "SOLO-agentmemory" -Confirm:$false -ErrorAction Stop
        Write-Log "任务已删除" "OK"
    } catch {
        Write-Log "任务不存在或删除失败: $_" "WARN"
    }
    exit
}

if ($Setup) {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Log "创建 Task Scheduler 任务需要管理员权限" "ERROR"
        exit 1
    }

    Write-Log "正在创建 Task Scheduler 任务..." "INFO"
    $scriptPath = $PSCommandPath
    $taskName = "SOLO-agentmemory"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" -Manual"
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" `
        -LogonType Interactive -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RestartCount 3 `
        -RestartInterval (New-TimeSpan -Minutes 5) `
        -MultipleInstances IgnoreNew

    Register-ScheduledTask -TaskName $taskName `
        -Trigger $trigger `
        -Action $action `
        -Principal $principal `
        -Settings $settings `
        -Description "SOLO Agent 记忆系统 - agentmemory 守护进程自动启动" `
        -Force

    Write-Log "Task Scheduler 任务 '$taskName' 创建成功!" "OK"
    exit
}

if ($Manual) {
    Start-Agentmemory
    exit
}

# ─── 默认：如果没有参数，直接启动 ───────────────────────────
Write-Log "agentmemory 启动脚本 v1.0" "INFO"
$result = Start-Agentmemory
if ($result) {
    Write-Host "✅ agentmemory 启动成功!"
    Write-Host "   REST API: http://localhost:$RestPort"
    Write-Host "   Viewer: http://localhost:$ViewerPort"
} else {
    Write-Host "❌ agentmemory 启动失败，请检查日志: $env:USERPROFILE\.agentmemory\logs\startup.log"
}
