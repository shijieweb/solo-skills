$port = 3111
$startupScript = "C:\Users\67972\Documents\Traework\agentmemory-startup.ps1"
$restoreScript = "C:\Users\67972\Documents\Traework\agentmemory_restore.py"
$logFile = "$env:USERPROFILE\.agentmemory\keepalive.log"

while ($true) {
    $listening = netstat -ano | Select-String "LISTENING" | Select-String ":$port "
    if (-not $listening) {
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$ts - REST 挂了，正在重启..." | Add-Content $logFile
        try {
            & $startupScript -Manual *>$null
            Start-Sleep -Seconds 20
            & python $restoreScript *>$null
            "$ts - 重启+恢复完成" | Add-Content $logFile
        } catch {
            "$ts - 重启失败: $_" | Add-Content $logFile
        }
    }
    Start-Sleep -Seconds 120
}
