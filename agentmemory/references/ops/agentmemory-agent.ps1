# agentmemory 统一守护 Agent
# 功能：保活 + 数据同步 + 日志清理 + 防重复启动锁
# 由 agentmemory-startup.ps1 自动启动

$scriptDir = "C:\Users\67972\Documents\Traework"
$agentmemoryDir = "$env:USERPROFILE\.agentmemory"
$logDir = "$agentmemoryDir\logs"
$lockFile = "$agentmemoryDir\agents.lock"
$agentLog = "$agentmemoryDir\agent.log"
$REST_PORT = 3111

# ─── 锁机制 ───
$myPid = [System.Diagnostics.Process]::GetCurrentProcess().Id
$existingLock = @()
if (Test-Path $lockFile) {
    $lockPids = Get-Content $lockFile -ErrorAction SilentlyContinue
    foreach ($pid in $lockPids) {
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($proc) {
            $existingLock += $pid
        }
    }
}
# 写锁（覆盖旧 PID）
$existingLock + $myPid | Sort-Object -Unique | Out-File $lockFile -Encoding UTF8 -Force

function Write-Log {
    param($msg)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts - $msg" | Add-Content $agentLog -Encoding UTF8
}

# ─── 首次启动日志 ───
Write-Log "Agent 启动 (PID: $myPid)"

# ─── 初始化：确保 logs 目录存在 ───
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

# ─── 循环计数器 ───
$backupCounter = 0
$selfReviewCounter = 0

while ($true) {
    # === 1. 保活检查（每次循环） ===
    $listening = netstat -ano | Select-String "LISTENING" | Select-String ":$REST_PORT "
    if (-not $listening) {
        Write-Log "REST 挂了，正在重启..."
        try {
            & "$scriptDir\agentmemory-startup.ps1" -Manual *>$null
            Start-Sleep -Seconds 20
            & python "$scriptDir\agentmemory_restore.py" *>$null
            Write-Log "重启+恢复完成"
        } catch {
            Write-Log "重启失败: $_"
        }
    }

    # === 2. 数据同步到 standalone.json（每 5 次循环 ≈ 10 分钟） ===
    $backupCounter++
    if ($backupCounter -ge 5) {
        $backupCounter = 0
        $syncScript = "$scriptDir\agentmemory-sync.py"
        if (Test-Path $syncScript) {
            try {
                $result = & python $syncScript 2>&1
                if ($LASTEXITCODE -eq 0 -and $result -ne "NO_DATA") {
                    Write-Log "数据同步: $result"
                }
            } catch {
                Write-Log "数据同步失败: $_"
            }
        }
    }

    # === 3. 自我审查循环（每 15 次循环 ≈ 30 分钟） ===
    $selfReviewCounter++
    if ($selfReviewCounter -ge 15) {
        $selfReviewCounter = 0
        Write-Log "开始自我审查..."
        try {
            $reviewScript = "$scriptDir\agentmemory-self-review.py"
            if (Test-Path $reviewScript) {
                $reviewResult = & python $reviewScript 2>&1
                if ($LASTEXITCODE -eq 0 -and $reviewResult -ne "NO_PATTERN") {
                    Write-Log "自我审查结果: $reviewResult"
                }
            }
        } catch {
            Write-Log "自我审查失败: $_"
        }
    }

    # === 4. 日志清理 ===
    try {
        if ((Test-Path $agentLog) -and ((Get-Item $agentLog).Length -gt 1MB)) {
            $oldLog = "$agentLog.$(Get-Date -Format 'yyyyMMdd')"
            Rename-Item $agentLog $oldLog -Force -ErrorAction SilentlyContinue
        }
        $cutoff = (Get-Date).AddDays(-7)
        Get-ChildItem $logDir -Filter "*.log*" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoff } | Remove-Item -Force -ErrorAction SilentlyContinue
    } catch {
        # 日志清理失败不影响核心功能
    }

    Start-Sleep -Seconds 120
}
