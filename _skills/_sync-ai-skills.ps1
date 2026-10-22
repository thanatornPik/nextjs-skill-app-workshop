<#
.SYNOPSIS
    Sync ทุก skill จาก _skills/ ไปยัง .claude/skills/ และ .agents/skills/

.DESCRIPTION
    โครงสร้างต้นทางคือโฟลเดอร์ต่อ 1 skill และต้องมี SKILL.md อยู่ข้างใน:

        _skills/<skill-name>/SKILL.md
        _skills/<skill-name>/... (references, rules, scripts, assets ฯลฯ)

    สคริปต์จะ copy ทั้งโฟลเดอร์ (รวมไฟล์ซ้อนและไฟล์ hidden) ไปที่:

        .claude/skills/<skill-name>/
        .agents/skills/<skill-name>/

    ค่าเริ่มต้นจะลบ skill ที่ไม่มีอยู่ใน _skills/ แล้วออกจากปลายทางด้วย
    เพื่อไม่ให้เหลือ skill เก่าค้างหลังเปลี่ยนชื่อ/ลบ skill

.PARAMETER SkipClean
    ไม่ต้องลบ skill เก่าที่ไม่มีอยู่ใน _skills/ (เก็บไว้เฉย ๆ)

.EXAMPLE
    npm run skills

.EXAMPLE
    npm run skills -- -SkipClean
#>
[CmdletBinding()]
param(
    [switch]$SkipClean
)

$ErrorActionPreference = "Stop"

# ใช้ตำแหน่งของสคริปต์เป็นหลัก เพื่อให้รันจากโฟลเดอร์ไหนก็ได้
$scriptDir = if ($PSScriptRoot) {
    $PSScriptRoot
} elseif ($MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    (Get-Location).Path
}

$projectRoot = Split-Path -Parent $scriptDir
$sourceRoot = Join-Path $projectRoot "_skills"

$targets = @(
    [pscustomobject]@{ Label = ".claude/skills"; Path = (Join-Path $projectRoot ".claude/skills") },
    [pscustomobject]@{ Label = ".agents/skills"; Path = (Join-Path $projectRoot ".agents/skills") }
)

function Get-SkillMetadata {
    param([Parameter(Mandatory = $true)][string]$SkillFile)

    $meta = [pscustomobject]@{ Name = $null; Description = $null }
    $lines = @(Get-Content -LiteralPath $SkillFile -TotalCount 50 -ErrorAction Stop)

    if ($lines.Count -eq 0 -or $lines[0].Trim() -ne "---") {
        return $meta
    }

    for ($i = 1; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line.Trim() -eq "---") { break }

        if ($line -match '^\s*name\s*:\s*(.+?)\s*$') {
            $meta.Name = $Matches[1].Trim().Trim('"', "'")
        } elseif ($line -match '^\s*description\s*:\s*(.+?)\s*$') {
            $meta.Description = $Matches[1].Trim().Trim('"', "'")
        }
    }

    return $meta
}

function Copy-DirectoryTree {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    New-Item -ItemType Directory -Force -Path $Destination | Out-Null

    # -Force เพื่อให้ได้ไฟล์ hidden (เช่น .env.example) มาด้วย
    foreach ($item in Get-ChildItem -LiteralPath $Source -Force) {
        $target = Join-Path $Destination $item.Name
        if ($item.PSIsContainer) {
            Copy-DirectoryTree -Source $item.FullName -Destination $target
        } else {
            Copy-Item -LiteralPath $item.FullName -Destination $target -Force
        }
    }
}

# ---------------------------------------------------------------------------
# 1. ตรวจหา skill ต้นทาง
# ---------------------------------------------------------------------------
if (!(Test-Path -LiteralPath $sourceRoot)) {
    Write-Host "❌ Source folder not found: $sourceRoot" -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Starting AI skills sync..." -ForegroundColor Cyan
Write-Host "   source : $sourceRoot"

$skills = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[string]

foreach ($dir in Get-ChildItem -LiteralPath $sourceRoot -Directory | Sort-Object Name) {
    $skillFile = Join-Path $dir.FullName "SKILL.md"

    if (!(Test-Path -LiteralPath $skillFile)) {
        $warnings.Add("ข้าม '$($dir.Name)': ไม่พบ SKILL.md")
        continue
    }

    $meta = Get-SkillMetadata -SkillFile $skillFile

    if ([string]::IsNullOrWhiteSpace($meta.Name)) {
        $warnings.Add("'$($dir.Name)': frontmatter ไม่มี name")
    } elseif ($meta.Name -ne $dir.Name) {
        $warnings.Add("'$($dir.Name)': name ใน frontmatter คือ '$($meta.Name)' ไม่ตรงกับชื่อโฟลเดอร์")
    }

    if ([string]::IsNullOrWhiteSpace($meta.Description)) {
        $warnings.Add("'$($dir.Name)': frontmatter ไม่มี description (agent อาจไม่โหลด skill นี้)")
    }

    $skills.Add([pscustomobject]@{
        Name   = $dir.Name
        Source = $dir.FullName
    })
}

if ($skills.Count -eq 0) {
    Write-Host "⚠️  No skills found in _skills/<skill-name>/SKILL.md" -ForegroundColor Yellow
    exit 0
}

foreach ($w in $warnings) {
    Write-Host "⚠️  $w" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# 2. Copy ไปยังปลายทางทั้งหมด
# ---------------------------------------------------------------------------
$errors = New-Object System.Collections.Generic.List[string]
$names = @($skills | ForEach-Object { $_.Name })

foreach ($target in $targets) {
    New-Item -ItemType Directory -Force -Path $target.Path | Out-Null
    Write-Host ""
    Write-Host "📁 $($target.Label)" -ForegroundColor White

    foreach ($skill in $skills) {
        $dest = Join-Path $target.Path $skill.Name

        try {
            if (Test-Path -LiteralPath $dest) {
                Remove-Item -LiteralPath $dest -Recurse -Force
            }

            Copy-DirectoryTree -Source $skill.Source -Destination $dest

            $fileCount = @(Get-ChildItem -LiteralPath $dest -Recurse -File -Force).Count
            Write-Host ("   ✅ {0} ({1} files)" -f $skill.Name, $fileCount) -ForegroundColor Green
        } catch {
            $errors.Add("$($target.Label)/$($skill.Name): $($_.Exception.Message)")
            Write-Host "   ❌ $($skill.Name) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ลบ skill ที่ไม่มีอยู่ใน _skills/ เพื่อไม่ให้ค้าง
    if (!$SkipClean) {
        foreach ($dir in Get-ChildItem -LiteralPath $target.Path -Directory -Force) {
            if ($names -contains $dir.Name) { continue }

            $hasSkillFile = Test-Path -LiteralPath (Join-Path $dir.FullName "SKILL.md")
            $isEmpty = @(Get-ChildItem -LiteralPath $dir.FullName -Force).Count -eq 0

            if ($hasSkillFile -or $isEmpty) {
                try {
                    Remove-Item -LiteralPath $dir.FullName -Recurse -Force
                    Write-Host "   🧹 removed stale: $($dir.Name)" -ForegroundColor DarkYellow
                } catch {
                    $errors.Add("$($target.Label)/$($dir.Name): $($_.Exception.Message)")
                }
            } else {
                Write-Host "   ⚠️  skipped unknown folder: $($dir.Name)" -ForegroundColor Yellow
            }
        }
    }
}

# ---------------------------------------------------------------------------
# 3. สรุปผล
# ---------------------------------------------------------------------------
Write-Host ""
if ($errors.Count -gt 0) {
    Write-Host "❌ Sync finished with $($errors.Count) error(s):" -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "   - $e" -ForegroundColor Red
    }
    exit 1
}

Write-Host "🎉 AI skills sync completed: $($skills.Count) skill(s) -> .claude/skills + .agents/skills" -ForegroundColor Cyan
exit 0
