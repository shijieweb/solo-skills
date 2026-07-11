# SOLO Skills Installer (Windows)
# 一键安装所有 SOLO 适配技能
# 用法: irm https://raw.githubusercontent.com/lcy362/solo-skills/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

# 颜色函数
function Write-Color($Text, $Color = "White") {
    Write-Host $Text -ForegroundColor $Color
}

Write-Color "`n🧰 SOLO Skills Installer" "Cyan"
Write-Color "========================`n" "Cyan"

# 检测 SOLO 技能目录
$soloBase = Join-Path $env:LOCALAPPDATA "../.trae-cn"
$skillsDir = Join-Path $soloBase "skills"

if (-not (Test-Path $skillsDir)) {
    Write-Color "⚠️ 未找到 SOLO 技能目录: $skillsDir" "Yellow"
    $skillsDir = Read-Host "请输入 SOLO 技能目录路径 (默认: $skillsDir)"
    if (-not $skillsDir) { $skillsDir = Join-Path $env:USERPROFILE ".trae-cn/skills" }
}

Write-Color "📂 目标安装目录: $skillsDir" "Green"

# 创建临时目录
$tmpDir = Join-Path $env:TEMP "solo-skills-install"
if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force }
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

try {
    # 克隆仓库
    Write-Color "`n📥 下载技能仓库..." "Yellow"
    git clone --depth 1 https://github.com/lcy362/solo-skills.git "$tmpDir" 2>&1 | Out-Null
    
    if (-not (Test-Path $tmpDir)) {
        throw "仓库下载失败"
    }
    
    # 安装技能
    $installed = @()
    $skills = Get-ChildItem -Path $tmpDir -Directory | Where-Object {
        Test-Path (Join-Path $_.FullName "SKILL.md")
    }
    
    foreach ($skill in $skills) {
        $targetDir = Join-Path $skillsDir $skill.Name
        
        if (Test-Path $targetDir) {
            Write-Color "  ⏭️  $($skill.Name) — 已存在，跳过" "Gray"
            continue
        }
        
        Copy-Item -Path $skill.FullName -Destination $targetDir -Recurse -Force
        $installed += $skill.Name
        Write-Color "  ✅ $($skill.Name) — 安装成功" "Green"
    }
    
    # 纯净安装只有一个技能目录
    if ($installed.Count -eq 0) {
        # 可能是克隆成功但技能在子目录
        $skillDirs = @("find-skills", "self-improving")
        foreach ($name in $skillDirs) {
            $src = Join-Path $tmpDir $name
            $target = Join-Path $skillsDir $name
            if ((Test-Path $src) -and (-not (Test-Path $target))) {
                Copy-Item -Path $src -Destination $target -Recurse -Force
                $installed += $name
                Write-Color "  ✅ $name — 安装成功" "Green"
            } elseif (Test-Path $target) {
                Write-Color "  ⏭️  $name — 已存在，跳过" "Gray"
            }
        }
    }
    
    Write-Color "`n📊 安装摘要:" "Cyan"
    Write-Color "   目录: $skillsDir" "White"
    Write-Color "   安装: $($installed.Count) 个技能" "Green"
    foreach ($s in $installed) {
        Write-Color "     ✅ $s" "Green"
    }
    
    Write-Color "`n🎉 安装完成！重启 SOLO 会话后技能生效。" "Cyan"
    Write-Color "   提示：运行 '检查所有技能更新' 可以检查新版本。`n" "Yellow"
    
} catch {
    Write-Color "❌ 安装失败: $_" "Red"
    exit 1
} finally {
    # 清理临时文件
    if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue }
}
