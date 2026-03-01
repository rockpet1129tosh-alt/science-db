# TeX パッケージ・ライブラリ使用状況分析スクリプト

param(
    [string]$RepoRoot = "c:\Users\selec\Documents\tex_all\physics-db"
)

$ErrorActionPreference = 'Continue'

# プリアンブルで読み込んでいるパッケージ
$packages = @{
    'enumitem' = @('\setlist', '\enumerate', '\itemize')
    'circuitikz' = @('\circuitikz', '\ctikzset', '\begin{circuitikz}')
    'lua-ul' = @('\underLine', '\strikeThrough', '\highLight')
    'autobreak' = @('\allowbreak')
    'physics' = @('\abs', '\norm', '\eval', '\order', '\comm', '\acomm', '\pb', '\dd', '\dv', '\pdv', '\grad', '\div', '\curl', '\laplacian')
    'ulem' = @('\uline', '\uuline', '\uwave', '\sout', '\xout', '\dashuline', '\dotuline')
    'fancybox' = @('\shadowbox', '\doublebox', '\ovalbox', '\Ovalbox', '\cornersize')
    'needspace' = @('\needspace', '\Needspace')
    'float' = @('\floatstyle', '\restylefloat', '\newfloat', '[H]')
    'caption' = @('\caption', '\captionsetup', '\captionof')
    'titleps' = @('\newpagestyle', '\sethead', '\setfoot', '\pagestyle')
}

# tikzlibrary の使用パターン
$tikzlibs = @{
    'patterns' = @('pattern=', 'pattern color=')
    'angles' = @('\pic{angle', 'pic[angle')
    'quotes' = @('"[')
    'arrows.meta' = @('arrows.meta', '-{', '}-', '->')
    'calc' = @('($', ')\$')
    'shapes.geometric' = @('ellipse', 'diamond', 'trapezium', 'semicircle', 'regular polygon')
}

Write-Host "=== パッケージ使用状況分析 ===" -ForegroundColor Cyan
Write-Host ""

# 全 .tex ファイルを取得（logo関連は除外）
$texFiles = Get-ChildItem "$RepoRoot\university_exam" -Filter "*.tex" -Recurse

# 各パッケージの使用状況を調査
foreach ($pkg in $packages.Keys | Sort-Object) {
    $patterns = $packages[$pkg]
    $found = $false
    $foundFiles = @()
    
    foreach ($pattern in $patterns) {
        $matches = $texFiles | Select-String -Pattern ([regex]::Escape($pattern))
        if ($matches) {
            $found = $true
            $foundFiles += $matches.Path | Select-Object -Unique
        }
    }
    
    if ($found) {
        Write-Host "✓ $pkg" -ForegroundColor Green -NoNewline
        Write-Host " - 使用あり ($(($foundFiles | Select-Object -Unique).Count) files)"
    } else {
        Write-Host "✗ $pkg" -ForegroundColor Yellow -NoNewline
        Write-Host " - 使用なし（削除候補）"
    }
}

Write-Host ""
Write-Host "=== tikzlibrary 使用状況分析 ===" -ForegroundColor Cyan
Write-Host ""

foreach ($lib in $tikzlibs.Keys | Sort-Object) {
    $patterns = $tikzlibs[$lib]
    $found = $false
    $foundFiles = @()
    
    foreach ($pattern in $patterns) {
        try {
            $escapedPattern = [regex]::Escape($pattern)
            $matches = $texFiles | Select-String -Pattern $escapedPattern
            if ($matches) {
                $found = $true
                $foundFiles += $matches.Path | Select-Object -Unique
            }
        }
        catch {
            # パターンエラーは無視
        }
    }
    
    if ($found) {
        Write-Host "✓ $lib" -ForegroundColor Green -NoNewline
        Write-Host " - 使用あり ($(($foundFiles | Select-Object -Unique).Count) files)"
    } else {
        Write-Host "✗ $lib" -ForegroundColor Yellow -NoNewline
        Write-Host " - 使用なし（削除候補）"
    }
}

Write-Host ""
Write-Host "分析完了" -ForegroundColor Cyan
