# agentmemory 后台守护三件套：备份 + 日志清理 + 防重复启动锁
# 用法：由 agentmemory-startup.ps1 自动启动，或手动：
#   Start-Process powershell -WindowStyle Hidden -File agentmemory-backup-agent.ps1

$scriptDir = "C:\Users\67972\Documents\Traework"
$agentmemoryDir = "$env:USERPROFILE\.agentmemory"
$logDir = "$agentmemoryDir\logs"
$lockFile = "$agentmemoryDir\agents.lock"
$backupLog = "$agentmemoryDir\backup-agent.log"

# ─── 锁机制：防止重复启动 ───
$myPid = [System.Diagnostics.Process]::GetCurrentProcess().Id
if (Test-Path $lockFile) {
    $existingPids = Get-Content $lockFile -ErrorAction SilentlyContinue
    $runningPids = @()
    foreach ($pid in $existingPids) {
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($proc -and $proc.CommandLine -like "*backup-agent*") {
            $runningPids += $pid
        }
    }
    if ($runningPids.Count -gt 0) {
        # 已有实例在跑，退出
        exit 0
    }
}
# 写自己的 PID
$myPid.ToString() | Out-File $lockFile -Encoding UTF8 -Force

# ─── 日志函数 ───
function Write-Log {
    param($msg)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts - $msg" | Add-Content $backupLog -Encoding UTF8
}

# ─── 从 standalone.json 修复 viewer 端口 ───
function Fix-ViewerPort {
    param($port)
    # 如果 3113 已被占用，往后顺延
    $testPort = 3113
    while ($testPort -le 3150) {
        $inUse = netstat -ano | Select-String "LISTENING" | Select-String ":$testPort "
        if (-not $inUse) {
            return $testPort
        }
        $testPort++
    }
    return 3113
}

Write-Log "backup-agent 启动 (PID: $myPid)"

# ─── 主循环 ───
while ($true) {
    # 1. 同步 MS 数据到 standalone.json（每 10 分钟）
    try {
        $env:AGENTMEMORY_URL = "http://localhost:3111"
        $env:AGENTMEMORY_TOOLS = "all"
        
        # 使用 Python 同步脚本
        $syncScript = "$scriptDir\agentmemory-sync.py"
        if (Test-Path $syncScript) {
            $result = & python $syncScript 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "数据同步完成"
            }
        }
    } catch {
        Write-Log "数据同步失败: $_"
    }

    # 2. 日志清理（保留最近 7 天）
    try {
        $cutoff = (Get-Date).AddDays(-7)
        Get-ChildItem $logDir -Filter "*.log" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoff } | Remove-Item -Force -ErrorAction SilentlyContinue
        # 清理 backup-agent.log（超过 1MB 则截断）
        if ((Test-Path $backupLog) -and ((Get-Item $backupLog).Length -gt 1MB)) {
            Get-Content $backupLog -Tail 500 | Set-Content $backupLog -Force
        }
    } catch {
        Write-Log "日志清理失败: $_"
    }

    # 3. 保活检查（每 120 秒）
    Start-Sleep -Seconds 120
}
