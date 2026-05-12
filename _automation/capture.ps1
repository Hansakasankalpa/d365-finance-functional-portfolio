# D365 Portfolio - Screenshot Capture Daemon
# Usage:
#   .\capture.ps1 -Module 01
# Hotkeys (while running):
#   Ctrl+Alt+S  -> force-capture the current active window
#   Ctrl+Alt+X  -> stop the daemon
# Behavior:
#   - Polls active window title every 2s
#   - Auto-captures on browser window-title change (page navigation)
#   - Auto-captures every 10s on stationary pages
#   - Hash-dedupes identical frames
#   - Saves PNG to .\<module-folder>\_inbox\

param(
    [Parameter(Mandatory=$true)]
    [string]$Module
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$repoRoot   = Split-Path -Parent $PSScriptRoot
$moduleDirs = Get-ChildItem -Path $repoRoot -Directory | Where-Object { $_.Name -match "^$Module-" }
if (-not $moduleDirs) { Write-Error "No module folder found matching prefix '$Module-' in $repoRoot"; exit 1 }
$inbox = Join-Path $moduleDirs[0].FullName "_inbox"
if (-not (Test-Path $inbox)) { New-Item -ItemType Directory -Path $inbox | Out-Null }

# Win32: active window + key state
$sig = @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class Win32 {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
}
"@
Add-Type -TypeDefinition $sig -ReferencedAssemblies System.Runtime.InteropServices

function Get-ActiveWindow {
    $h = [Win32]::GetForegroundWindow()
    $sb = New-Object System.Text.StringBuilder 512
    [Win32]::GetWindowText($h, $sb, 512) | Out-Null
    $r = New-Object Win32+RECT
    [Win32]::GetWindowRect($h, [ref]$r) | Out-Null
    [PSCustomObject]@{ Title=$sb.ToString(); Rect=$r }
}

function Capture-Window {
    param($win, $reason)
    $w = $win.Rect.Right  - $win.Rect.Left
    $h = $win.Rect.Bottom - $win.Rect.Top
    if ($w -le 100 -or $h -le 100) { return $null }
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($win.Rect.Left, $win.Rect.Top, 0, 0, (New-Object System.Drawing.Size $w, $h))
    $g.Dispose()

    # Hash for dedup (sample 256 pixels diagonally)
    $hash = New-Object System.Text.StringBuilder
    for ($i=0; $i -lt 256; $i++) {
        $x = [int]($w * $i / 256); $y = [int]($h * $i / 256)
        $null = $hash.Append($bmp.GetPixel($x, $y).ToArgb().ToString("X8"))
    }
    $h32 = $hash.ToString()

    if ($script:lastHash -eq $h32) { $bmp.Dispose(); return $null }
    $script:lastHash = $h32

    $ts   = (Get-Date).ToString("HHmmss")
    $page = ($win.Title -split " - ")[0] -replace "[^A-Za-z0-9]+","_" -replace "_+$","" -replace "^_+",""
    if ([string]::IsNullOrWhiteSpace($page)) { $page = "frame" }
    if ($page.Length -gt 50) { $page = $page.Substring(0,50) }
    $name = "{0}_{1}_{2}_{3}.png" -f $ts, $script:seq.ToString("000"), $reason, $page
    $path = Join-Path $inbox $name
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $script:seq++
    Write-Host "[$ts] $reason -> $name"
    return $path
}

$script:seq = 1
$script:lastHash = ""
$script:lastTitle = ""
$script:lastCaptureTime = Get-Date

$D365_TITLE_MATCH = "(Dynamics 365|Finance and Operations|Microsoft Edge|Chrome|Firefox)"
$POLL_MS = 2000
$STATIONARY_MS = 10000

Write-Host "================================================================"
Write-Host " D365 Capture Daemon  |  Module: $Module"
Write-Host " Inbox: $inbox"
Write-Host " Ctrl+Alt+S = force-capture   Ctrl+Alt+X = stop"
Write-Host "================================================================"

while ($true) {
    Start-Sleep -Milliseconds $POLL_MS

    # Hotkey check
    if ([Win32]::GetAsyncKeyState(0x58) -band 0x8000) {           # X
        if (([Win32]::GetAsyncKeyState(0x11) -band 0x8000) -and ([Win32]::GetAsyncKeyState(0x12) -band 0x8000)) {
            Write-Host "Stop hotkey received."
            break
        }
    }
    $force = $false
    if ([Win32]::GetAsyncKeyState(0x53) -band 0x8000) {           # S
        if (([Win32]::GetAsyncKeyState(0x11) -band 0x8000) -and ([Win32]::GetAsyncKeyState(0x12) -band 0x8000)) {
            $force = $true
        }
    }

    $win = Get-ActiveWindow
    $isBrowser = $win.Title -match $D365_TITLE_MATCH
    if (-not $isBrowser -and -not $force) { continue }

    $titleChanged = ($win.Title -ne $script:lastTitle)
    $stationary   = ((Get-Date) - $script:lastCaptureTime).TotalMilliseconds -ge $STATIONARY_MS

    $reason = $null
    if ($force)        { $reason = "FORCE" }
    elseif ($titleChanged) { $reason = "NAV" }
    elseif ($stationary)   { $reason = "STAT" }

    if ($reason) {
        $r = Capture-Window -win $win -reason $reason
        if ($r) { $script:lastCaptureTime = Get-Date }
        $script:lastTitle = $win.Title
    }
}

Write-Host "`nSession complete. Files in:"
Write-Host "  $inbox"
Write-Host "Hand off to Claude for post-processing."
