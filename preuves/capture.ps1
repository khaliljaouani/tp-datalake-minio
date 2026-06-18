param(
  [Parameter(Mandatory=$true)][string]$TitleLike,
  [Parameter(Mandatory=$true)][string]$Out
)
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
}
"@
Add-Type -AssemblyName System.Windows.Forms,System.Drawing

# Trouver la fenetre par titre
$proc = Get-Process | Where-Object { $_.MainWindowTitle -like "*$TitleLike*" -and $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $proc) { Write-Host "Fenetre '$TitleLike' introuvable"; exit 1 }
$h = $proc.MainWindowHandle
[Win32]::ShowWindow($h, 3) | Out-Null   # 3 = SW_MAXIMIZE
Start-Sleep -Milliseconds 400
[Win32]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 900

$b = [System.Windows.Forms.SystemInformation]::VirtualScreen
$bmp = New-Object System.Drawing.Bitmap($b.Width,$b.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($b.X,$b.Y,0,0,$bmp.Size)
$bmp.Save($Out)
$g.Dispose(); $bmp.Dispose()
Write-Host "Capture OK -> $Out ($((Get-Item $Out).Length) octets) [fenetre: $($proc.MainWindowTitle)]"
