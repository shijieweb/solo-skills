# Solo Skills Manager - All-Skills Installer for Windows
# ════════════════════════════════════════════════════════
# One-click to install ALL skills currently in this repo.
# Run: powershell -ExecutionPolicy Bypass -File install.ps1
# Output: Each skill lands in %USERPROFILE%\.trae-cn\skills\<slug>
# ════════════════════════════════════════════════════════

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Base = "$env:USERPROFILE\.trae-cn\skills"
$Repo  = "https://github.com/shijieweb/solo-skills/archive/refs/heads/main.zip"
$Temp  = "$env:TEMP\solo-skills-main.zip"
$Extract = "$env:TEMP\solo-skills-main"

# ── Skill list (keep in sync with README.md 技能表) ──
# All skills are downloaded together; set $skillList to filter:
$skillList = @("find-skills", "self-improving", "douyin-xiazai", "agentmemory")

Write-Host "🚀 Solo Skills Manager - All-Skills Installer" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Download the whole repo as zip
Write-Host "[1/3] Downloading latest solo-skills from GitHub..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $Repo -OutFile $Temp -UseBasicParsing
    Write-Host "      ✅ Downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "      ❌ Download failed: $_" -ForegroundColor Red
    exit 1
}

# 2. Extract zip
Write-Host "[2/3] Extracting..." -ForegroundColor Yellow
try {
    if (Test-Path $Extract) { Remove-Item -Recurse -Force $Extract }
    Expand-Archive -Path $Temp -DestinationPath "$env:TEMP" -Force
    Write-Host "      ✅ Extracted to $Extract" -ForegroundColor Green
} catch {
    Write-Host "      ❌ Extraction failed: $_" -ForegroundColor Red
    exit 1
}

# 3. Copy skills
Write-Host "[3/3] Installing skills..." -ForegroundColor Yellow
$installed = @()
$skipped   = @()

# First pass: if $skillList is non-empty, install only those
if ($skillList.Count -gt 0) {
    foreach ($slug in $skillList) {
        $src = Join-Path $Extract "solo-skills-main\$slug"
        $dst = Join-Path $Base $slug
        if (Test-Path $src) {
            Write-Host "      📦 $slug ..." -NoNewline
            if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
            Copy-Item -Recurse $src $dst
            Write-Host " ✅" -ForegroundColor Green
            $installed += $slug
        } else {
            Write-Host "      ⚠️ $slug not found in repo" -ForegroundColor DarkYellow
            $skipped += $slug
        }
    }
} else {
    # No filter → install all top-level skill directories
    Get-ChildItem "$Extract\solo-skills-main" -Directory | ForEach-Object {
        $slug = $_.Name
        # Skip non-skill directories
        if ($slug -in @(".github", "_shared", "references", "assets", "node_modules")) { return }
        $src = $_.FullName
        $dst = Join-Path $Base $slug
        Write-Host "      📦 $slug ..." -NoNewline
        if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
        Copy-Item -Recurse $src $dst
        Write-Host " ✅" -ForegroundColor Green
        $installed += $slug
    }
}

# 4. Cleanup
Remove-Item $Temp -Force -ErrorAction SilentlyContinue
Remove-Item $Extract -Recurse -Force -ErrorAction SilentlyContinue

# 5. Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  ✅ Installed: $($installed.Count) skills" -ForegroundColor Green
if ($installed.Count -gt 0) {
    Write-Host "     $($installed -join ', ')" -ForegroundColor Green
}

# ── MCP Server Guidance ──
Write-Host ""
Write-Host "📡 MCP Server Setup (for skills with MCP):" -ForegroundColor Magenta
Write-Host "   Skills requiring MCP servers need additional configuration."
Write-Host "   See each skill's references/install-guide.md for details."
Write-Host ""

# ── Quick-install hints ──
if ($installed -contains "agentmemory") {
    Write-Host "🧠 agentmemory: MCP Server detected!" -ForegroundColor Magenta
    Write-Host "   Run for full setup: Get-Content $env:USERPROFILE\.trae-cn\skills\agentmemory\references\install-guide.md" -ForegroundColor DarkGray
}

Write-Host "Done! 🎉" -ForegroundColor Cyan