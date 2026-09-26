# ==============================================================================
# Microsoft.PowerShell_profile.ps1 — Windows PowerShell & pwsh 7 profile
# Managed by terminal-configs (https://github.com/ne1cc/terminal-configs)
# ==============================================================================

# 1. Aliases & Core Shortcuts
if (Test-Path Alias:gc) { Remove-Item Alias:gc -Force }
function gc { git clone @args }
function g  { git @args }
function d  { docker @args }
function dc { docker compose @args }

# Antigravity YOLO mode (all permissions auto-approved)
function agyy { agy --dangerously-skip-permissions @args }

# 2. Chocolatey Profile Integration
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# 3. PSReadLine History & ListView Prediction
$psReadlineCmd = Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue
if ($psReadlineCmd -and $psReadlineCmd.Parameters.ContainsKey('PredictionSource')) {
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
}

# ==============================================================================
# 4. GitHub Workspace Navigation & Sync
# Mirrors macOS / WSL terminal-configs workflow for ne1cc repositories
# ==============================================================================
if (-not $env:GITHUB_ROOT) {
    if (Test-Path "X:\Github") {
        $env:GITHUB_ROOT = "X:\Github"
    } elseif (Test-Path "D:\Github") {
        $env:GITHUB_ROOT = "D:\Github"
    } else {
        $env:GITHUB_ROOT = Join-Path $HOME "Github"
    }
}
$env:NE1CC_DIR = Join-Path $env:GITHUB_ROOT "ne1cc"

function ghroot { Set-Location $env:GITHUB_ROOT }
function ghex   { Set-Location "$env:GITHUB_ROOT\explore" }
function ghws   { Set-Location "$env:GITHUB_ROOT\workspace" }
function ghcfg  { Set-Location "$env:GITHUB_ROOT\config" }

# Navigation function to jump to any repo in ~/Github/ne1cc
function ghn {
    param(
        [Parameter(Position=0)]
        [string]$Repo
    )
    if (-not $Repo) {
        Set-Location $env:NE1CC_DIR
        return
    }
    $exactPath = Join-Path $env:NE1CC_DIR $Repo
    if (Test-Path $exactPath) {
        Set-Location $exactPath
        return
    }
    $match = Get-ChildItem -Path $env:NE1CC_DIR -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$Repo*" } | Select-Object -First 1
    if ($match) {
        Set-Location $match.FullName
    } else {
        Write-Warning "No repository matching '$Repo' found in $env:NE1CC_DIR"
    }
}
Set-Alias ghr ghn

# Dynamic tab-completion for ghn and ghr
if (Get-Command Register-ArgumentCompleter -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -CommandName @('ghn', 'ghr') -Native -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        if (Test-Path $env:NE1CC_DIR) {
            Get-ChildItem -Path $env:NE1CC_DIR -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like "*$wordToComplete*" } |
                ForEach-Object { [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name) }
        }
    }
}

# Fast repository status listing
function ghsync-list {
    Write-Host "Local ne1cc repos in $env:NE1CC_DIR`:" -ForegroundColor Cyan
    if (-not (Test-Path $env:NE1CC_DIR)) {
        Write-Warning "Directory not found: $env:NE1CC_DIR"
        return
    }
    Get-ChildItem -Path $env:NE1CC_DIR -Directory | ForEach-Object {
        $repoPath = $_.FullName
        $gitDir = Join-Path $repoPath ".git"
        if (Test-Path $gitDir) {
            $branch = git -C $repoPath branch --show-current 2>$null
            $dirty = ""
            $status = git -C $repoPath status --porcelain 2>$null
            if ($status) { $dirty = " *" }
            Write-Host "  [ok] $($_.Name) ($branch)$dirty" -ForegroundColor Green
        }
    }
}

# Fast repository pull
function ghsync-pull {
    Write-Host "Pulling ne1cc repos in $env:NE1CC_DIR`..." -ForegroundColor Cyan
    if (-not (Test-Path $env:NE1CC_DIR)) {
        Write-Warning "Directory not found: $env:NE1CC_DIR"
        return
    }
    Get-ChildItem -Path $env:NE1CC_DIR -Directory | ForEach-Object {
        $repoPath = $_.FullName
        $gitDir = Join-Path $repoPath ".git"
        if (Test-Path $gitDir) {
            Write-Host ">> pull $($_.Name)" -ForegroundColor Yellow
            git -C $repoPath pull --ff-only 2>$null
        }
    }
    Write-Host "Done." -ForegroundColor Green
}

# Unified ghsync wrapper with WSL bridge fallback
function ghsync {
    param(
        [switch]$List,
        [switch]$Pull,
        [Parameter(ValueFromRemainingArguments=$true)][string[]]$RemainingArgs
    )
    if ($List) { ghsync-list; return }
    if ($Pull) { ghsync-pull; return }
    ghsync-pull
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        Write-Host "Checking remote sync via WSL engine..." -ForegroundColor Cyan
        wsl.exe -e sync-ne1cc @RemainingArgs
    }
}
