# SOLO Skills Installer (Windows)
# 一键安装 SOLO 适配技能
# 用法:
#   安装全部:  irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.ps1 | iex
#   安装单个:  $skill = "find-skills"; iex "& { $(irm https://raw.githubusercontent.com/shijieweb/solo-skills/main/install.ps1) } -SkillName $skill"

param(
    [string]$SkillName = ""   # 留空 = 安装全部，指定技能名 = 安装单个
)

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

# 确定安装模式
if ($SkillName) {
    $skillList = @($SkillName)
    Write-Color "🔧 模式: 安装单个技能「$SkillName」`n" "Cyan"
} else {
    $skillList = @("find-skills", "self-improving", "douyin-xiazai")
    Write-Color "🔧 模式: 安装全部技能`n" "Cyan"
}

# 创建临时目录
$tmpDir = Join-Path $env:TEMP "solo-skills-install"
if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force }
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

try {
    # 克隆仓库
    Write-Color "📥 下载技能仓库..." "Yellow"
    git clone --depth 1 https://github.com/shijieweb/solo-skills.git "$tmpDir" 2>&1 | Out-Null

    if (-not (Test-Path $tmpDir)) {
        throw "仓库下载失败"
    }

    # 安装技能
    $installed = @()
    foreach ($name in $skillList) {
        $src = Join-Path $tmpDir $name
        $target = Join-Path $skillsDir $name

        if (-not (Test-Path $src)) {
            Write-Color "  ❌ $name — 仓库中未找到此技能" "Red"
            continue
        }

        if (Test-Path $target) {
            Write-Color "  ⏭️  $name — 已存在，跳过" "Gray"
            continue
        }

        Copy-Item -Path $src -Destination $target -Recurse -Force
        $installed += $name
        Write-Color "  ✅ $name — 安装成功" "Green"
    }

    Write-Color "`n📊 安装摘要:" "Cyan"
    Write-Color "   目录: $skillsDir" "White"
    Write-Color "   安装: $($installed.Count) 个技能" "Green"
    foreach ($s in $installed) {
        Write-Color "     ✅ $s" "Green"
    }

    Write-Color "`n🎉 安装完成！重启 SOLO 会话后技能生效。" "Cyan"
    Write-Color "   提示：运行 '检查所有技能更新' 可以检查新版本。" "Yellow"
    Write-Color "   云端环境：部分技能依赖 MCP，云端若缺失 MCP 会自动降级运行。`n" "Yellow"

} catch {
    Write-Color "❌ 安装失败: $_" "Red"
    exit 1
} finally {
    # 清理临时文件
    if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue }
}
