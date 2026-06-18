param([string]$TitleLike, [string]$Out)
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;
public class PW {
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int n);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
  public struct RECT { public int Left, Top, Right, Bottom; }
}
"@ -ReferencedAssemblies System.Drawing
Add-Type -AssemblyName System.Drawing

$proc = Get-Process | Where-Object { $_.MainWindowTitle -like "*$TitleLike*" -and $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $proc) { Write-Host "introuvable: $TitleLike"; exit 1 }
$h = $proc.MainWindowHandle
if ([PW]::IsIconic($h)) { [PW]::ShowWindow($h, 9) | Out-Null; Start-Sleep -Milliseconds 600 }  # restore if minimized
$r = New-Object PW+RECT
[PW]::GetWindowRect($h, [ref]$r) | Out-Null
$w = $r.Right - $r.Left; $ht = $r.Bottom - $r.Top
$bmp = New-Object System.Drawing.Bitmap($w, $ht)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$hdc = $g.GetHdc()
[PW]::PrintWindow($h, $hdc, 2) | Out-Null   # 2 = PW_RENDERFULLCONTENT
$g.ReleaseHdc($hdc); $g.Dispose()
$bmp.Save($Out); $bmp.Dispose()
Write-Host "OK -> $Out (${w}x${ht}) [$($proc.MainWindowTitle)]"
