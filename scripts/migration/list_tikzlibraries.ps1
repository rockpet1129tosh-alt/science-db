# Standalone図ファイル tikzlibrary完全リスト

param(
    [string]$RepoRoot = "c:\Users\selec\Documents\tex_all\physics-db"
)

# 全てのstandalone図ファイルを取得
$figFiles = Get-ChildItem "$RepoRoot\university_exam" -Recurse -Filter "fig_*.tex" | Sort-Object FullName

Write-Host "=== Standalone図ファイル tikzlibrary完全リスト ===" -ForegroundColor Cyan
Write-Host ""

$report = @()

foreach ($file in $figFiles) {
    $content = Get-Content $file.FullName -Raw
    $relativePath = $file.FullName.Replace("$RepoRoot\university_exam\physics-standard\", "")
    
    # \usetikzlibrary行を抽出
    if ($content -match '\\usetikzlibrary\{([^}]+)\}') {
        $libraries = $matches[1] -split ',' | ForEach-Object { $_.Trim() }
        $libList = ($libraries | Sort-Object) -join ', '
        
        $report += [PSCustomObject]@{
            File = $file.Name
            Path = $relativePath
            Libraries = $libList
            Count = $libraries.Count
        }
        
        Write-Host "$($file.Name)" -ForegroundColor Green
        Write-Host "  → $libList" -ForegroundColor White
    }
    else {
        $report += [PSCustomObject]@{
            File = $file.Name
            Path = $relativePath
            Libraries = "(なし)"
            Count = 0
        }
        
        Write-Host "$($file.Name)" -ForegroundColor Yellow
        Write-Host "  → tikzlibrary なし" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== 集計 ===" -ForegroundColor Cyan

# ライブラリ別の使用回数を集計
$allLibs = $report | Where-Object { $_.Libraries -ne "(なし)" } | 
    ForEach-Object { $_.Libraries -split ', ' } | 
    Group-Object | Sort-Object Count -Descending

Write-Host ""
Write-Host "ライブラリ別使用回数:" -ForegroundColor White
foreach ($lib in $allLibs) {
    Write-Host "  $($lib.Name): $($lib.Count)回" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "総ファイル数: $($figFiles.Count)" -ForegroundColor White

# Markdown出力
$mdPath = "$RepoRoot\scripts\migration\tikzlibrary_complete_list.md"
$md = @"
# Standalone図ファイル tikzlibrary完全リスト

**生成日時:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**総ファイル数:** $($figFiles.Count)

---

## ファイル別ライブラリリスト

"@

foreach ($item in $report) {
    $md += @"

### $($item.File)
**パス:** ``$($item.Path)``  
**ライブラリ:** $($item.Libraries)  
**使用数:** $($item.Count)

"@
}

$md += @"

---

## 統計情報

### ライブラリ別使用回数

| ライブラリ | 使用回数 |
|-----------|---------|
"@

foreach ($lib in $allLibs) {
    $md += @"

| ``$($lib.Name)`` | $($lib.Count)回 |
"@
}

$md += @"


### ライブラリ数別ファイル分布

"@

$groupedByCount = $report | Group-Object Count | Sort-Object Name
foreach ($group in $groupedByCount) {
    $count = if ($group.Name -eq "0") { "0 (なし)" } else { $group.Name }
    $md += @"

- **$count ライブラリ:** $($group.Count)ファイル
"@
}

Set-Content $mdPath -Value $md -Encoding UTF8
Write-Host ""
Write-Host "Markdownレポートを生成: $mdPath" -ForegroundColor Green
