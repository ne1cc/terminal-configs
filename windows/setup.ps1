<#
.SYNOPSIS
    Automated zero-to-hero setup script for Windows (Host / VM) in the terminal-configs ecosystem.
.DESCRIPTION
    Configures the Windows developer environment:
    1. Installs / links managed Microsoft.PowerShell_profile.ps1 for Windows PowerShell and pwsh 7.
    2. Configures Git cross-platform optimizations (autocrlf, eol, filemode, symlinks, safe.directory).
    3. Starts and sets VirtIO-FS service (VirtioFsSvc) to Automatic if running in a VM.
    4. Sets Windows Terminal default starting directory to X:\Github.
    5. Adds Windows Defender I/O exclusions for X:\ and Z:\ for maximum indexing performance.
    6. Enables Developer Mode for unprivileged symlinks.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\windows\setup.ps1
#>

[CmdletBinding()]
param(
    [string]$GithubRoot = "X:\Github",
    [switch]$SkipDefender,
    [switch]$SkipTerminal
)

$ErrorActionPreference = "Continue"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Windows Developer Environment Setup     " -ForegroundColor Cyan
Write-Host " terminal-configs automated provisioning  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ManagedProfileSource = Join-Path $ScriptDir "Microsoft.PowerShell_profile.ps1"

# ------------------------------------------------------------------------------
# 1. Developer Mode (Registry)
# ------------------------------------------------------------------------------
Write-Host "`n[1/6] Enabling Windows Developer Mode (Unprivileged Symlinks)..." -ForegroundColor Yellow
try {
    $devKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path $devKey)) {
        New-Item -Path $devKey -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Set-ItemProperty -Path $devKey -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "  Developer Mode checked." -ForegroundColor Green
} catch {
    Write-Host "  Note: Run as Administrator to toggle Developer Mode if unprivileged symlinks fail." -ForegroundColor Gray
}

# ------------------------------------------------------------------------------
# 2. VirtIO-FS Service (for VM Guests with shared drives)
# ------------------------------------------------------------------------------
Write-Host "`n[2/6] Checking VirtIO-FS Service (VirtioFsSvc)..." -ForegroundColor Yellow
$service = Get-Service -Name "VirtioFsSvc" -ErrorAction SilentlyContinue
if ($null -ne $service) {
    Write-Host "  VirtioFsSvc detected. Status: $($service.Status)" -ForegroundColor Green
    if ($service.Status -ne "Running") {
        Write-Host "  Starting VirtioFsSvc..." -ForegroundColor Green
        Set-Service -Name "VirtioFsSvc" -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "VirtioFsSvc" -ErrorAction SilentlyContinue
    } else {
        Set-Service -Name "VirtioFsSvc" -StartupType Automatic -ErrorAction SilentlyContinue
        Write-Host "  VirtioFsSvc is active." -ForegroundColor Green
    }
} else {
    Write-Host "  VirtioFsSvc not present (standard bare-metal or Hyper-V host)." -ForegroundColor Gray
}

# ------------------------------------------------------------------------------
# 3. Configure Git Global Optimizations
# ------------------------------------------------------------------------------
Write-Host "`n[3/6] Configuring Git Cross-Platform Compatibility..." -ForegroundColor Yellow
if (Get-Command git -ErrorAction SilentlyContinue) {
    git config --global core.autocrlf input
    git config --global core.eol lf
    git config --global core.filemode false
    git config --global core.symlinks true
    git config --global --add safe.directory "*"
    Write-Host "  Git global config updated:" -ForegroundColor Green
    Write-Host "    core.autocrlf = input" -ForegroundColor Gray
    Write-Host "    core.eol      = lf" -ForegroundColor Gray
    Write-Host "    core.filemode = false" -ForegroundColor Gray
    Write-Host "    core.symlinks = true" -ForegroundColor Gray
    Write-Host "    safe.directory = *" -ForegroundColor Gray
} else {
    Write-Warning "  Git not detected in PATH. Install Git for Windows and re-run."
}

# ------------------------------------------------------------------------------
# 4. Install Managed PowerShell Profile
# ------------------------------------------------------------------------------
Write-Host "`n[4/6] Installing Managed PowerShell Profiles..." -ForegroundColor Yellow

$profileTargets = @(
    "$HOME\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
)

# Also check current running profile
if ($PROFILE -and ($profileTargets -notcontains $PROFILE)) {
    $profileTargets += $PROFILE
}

$installedCount = 0
foreach ($target in $profileTargets) {
    $parentDir = Split-Path -Parent $target
    # Only target directories that exist or belong to standard locations
    if (Test-Path (Split-Path -Parent $parentDir)) {
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }

        # Backup existing if not already backed up
        if ((Test-Path $target) -and (-not (Test-Path "$target.bak"))) {
            Copy-Item -Path $target -Destination "$target.bak" -Force
            Write-Host "  Backed up existing profile: $target -> $target.bak" -ForegroundColor Gray
        }

        Copy-Item -Path $ManagedProfileSource -Destination $target -Force
        Write-Host "  Installed profile: $target" -ForegroundColor Green
        $installedCount++
    }
}

if ($installedCount -eq 0) {
    Write-Warning "  Could not find standard PowerShell profile directory. Checked: $($profileTargets -join ', ')"
}

# ------------------------------------------------------------------------------
# 5. Windows Defender Exclusions
# ------------------------------------------------------------------------------
if (-not $SkipDefender) {
    Write-Host "`n[5/6] Adding Windows Defender Dev Drive Exclusions..." -ForegroundColor Yellow
    try {
        if (Test-Path "X:\") {
            Add-MpPreference -ExclusionPath "X:\" -ErrorAction SilentlyContinue
            Write-Host "  Exclusion added for X:\" -ForegroundColor Green
        }
        if (Test-Path "Z:\") {
            Add-MpPreference -ExclusionPath "Z:\" -ErrorAction SilentlyContinue
            Write-Host "  Exclusion added for Z:\" -ForegroundColor Green
        }
    } catch {
        Write-Warning "  Could not add Defender exclusions (requires Administrator privilege): $_"
    }
} else {
    Write-Host "`n[5/6] Skipping Defender exclusions (--SkipDefender requested)." -ForegroundColor Gray
}

# ------------------------------------------------------------------------------
# 6. Windows Terminal Default Starting Directory
# ------------------------------------------------------------------------------
if (-not $SkipTerminal) {
    Write-Host "`n[6/6] Configuring Windows Terminal Default Starting Directory..." -ForegroundColor Yellow
    $wtPackageDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $wtSettingsFile = "$wtPackageDir\settings.json"

    if (Test-Path $wtSettingsFile) {
        try {
            $json = Get-Content -Raw $wtSettingsFile | ConvertFrom-Json
            if ($json.profiles.defaults) {
                $json.profiles.defaults | Add-Member -NotePropertyName "startingDirectory" -NotePropertyValue $GithubRoot -Force
                $json | ConvertTo-Json -Depth 32 | Set-Content $wtSettingsFile -Encoding utf8
                Write-Host "  Windows Terminal default starting directory set to $GithubRoot." -ForegroundColor Green
            }
        } catch {
            Write-Warning "  Could not update Windows Terminal settings JSON: $_"
        }
    } else {
        Write-Host "  Windows Terminal settings file not found at default package path." -ForegroundColor Gray
    }
} else {
    Write-Host "`n[6/6] Skipping Windows Terminal configuration (--SkipTerminal requested)." -ForegroundColor Gray
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host " Windows Provisioning Complete!           " -ForegroundColor Cyan
Write-Host " Open a new PowerShell or Terminal window " -ForegroundColor Cyan
Write-Host " and test: ghn, ghroot, ghsync-list       " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
