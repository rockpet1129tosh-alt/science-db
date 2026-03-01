# Standalone図ファイルの不要なtikzlibraryを削除するスクリプト

param(
    [string]$RepoRoot = "c:\Users\selec\Documents\tex_all\physics-db"
)

$ErrorActionPreference = 'Stop'

# 全てのstandalone図ファイルを取得
$figFiles = Get-ChildItem "$RepoRoot\university_exam" -Recurse -Filter "fig_*.tex"

Write-Host "=== Standalone図ファイルのtikzlibrary最適化 ===" -ForegroundColor Cyan
Write-Host "対象ファイル数: $($figFiles.Count)" -ForegroundColor White
Write-Host ""

$totalCleaned = 0

foreach ($file in $figFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # \usetikzlibrary行を抽出
    if ($content -match '\\usetikzlibrary\{([^}]+)\}') {
        $libraries = $matches[1] -split ',' | ForEach-Object { $_.Trim() }
        $usedLibraries = @()
        
        # 各ライブラリの使用状況をチェック
        foreach ($lib in $libraries) {
            $used = $false
            
            switch ($lib) {
                'angles' {
                    if ($content -match '(pic\{angle|angle eccentricity|angle radius)') {
                        $used = $true
                    }
                }
                'quotes' {
                    if ($content -match 'pic\["') {
                        $used = $true
                    }
                }
                'arrows.meta' {
                    if ($content -match '(-\{|Stealth|Triangle|Latex|arrows\.meta)') {
                        $used = $true
                    }
                }
                'calc' {
                    if ($content -match '\(\$.*\$\)') {
                        $used = $true
                    }
                }
                'patterns' {
                    if ($content -match 'pattern\s*=') {
                        $used = $true
                    }
                }
                'decorations.markings' {
                    if ($content -match '(decorate|decoration\s*=|markings)') {
                        $used = $true
                    }
                }
                'shapes.geometric' {
                    if ($content -match '(ellipse|diamond|trapezium|semicircle|regular polygon)') {
                        $used = $true
                    }
                }
                default {
                    # その他のライブラリは保持
                    $used = $true
                }
            }
            
            if ($used) {
                $usedLibraries += $lib
            }
        }
        
        # 削除されたライブラリがあれば更新
        $removed = $libraries | Where-Object { $_ -notin $usedLibraries }
        if ($removed.Count -gt 0) {
            $newLibLine = if ($usedLibraries.Count -gt 0) {
                "\usetikzlibrary{$($usedLibraries -join ',')}"
            } else {
                ""
            }
            
            $newContent = $content -replace '\\usetikzlibrary\{[^}]+\}', $newLibLine
            Set-Content $file.FullName -Value $newContent -NoNewline
            
            $relativePath = $file.FullName.Replace("$RepoRoot\", "")
            Write-Host "✓ $relativePath" -ForegroundColor Green
            Write-Host "  削除: $($removed -join ', ')" -ForegroundColor Yellow
            $totalCleaned++
        }
    }
}

Write-Host ""
Write-Host "完了: $totalCleaned ファイルを最適化しました" -ForegroundColor Cyan
