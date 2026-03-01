# Standalone図ファイルを全てコンパイルして動作確認

param(
    [string]$RepoRoot = "c:\Users\selec\Documents\tex_all\physics-db"
)

$ErrorActionPreference = 'Continue'

# 全てのstandalone図ファイルを取得
$figFiles = Get-ChildItem "$RepoRoot\university_exam" -Recurse -Filter "fig_*.tex" | Sort-Object FullName

Write-Host "=== Standalone図ファイル 一括コンパイル ===" -ForegroundColor Cyan
Write-Host "対象ファイル数: $($figFiles.Count)" -ForegroundColor White
Write-Host ""

$succeeded = 0
$failed = 0
$errors = @()

foreach ($file in $figFiles) {
    $relativePath = $file.FullName.Replace("$RepoRoot\university_exam\physics-standard\", "")
    Write-Host "コンパイル中: $($file.Name)" -ForegroundColor Yellow -NoNewline
    
    # ファイルのディレクトリに移動してコンパイル
    Push-Location $file.Directory
    
    # lualatexでコンパイル（エラー時は停止、出力を抑制）
    $output = & lualatex -interaction=nonstopmode -halt-on-error $file.Name 2>&1
    
    # PDF生成を確認
    $pdfPath = $file.FullName -replace '\.tex$', '.pdf'
    if (Test-Path $pdfPath) {
        Write-Host " ✓" -ForegroundColor Green
        $succeeded++
    }
    else {
        Write-Host " ✗" -ForegroundColor Red
        $failed++
        $errors += [PSCustomObject]@{
            File = $file.Name
            Path = $relativePath
            Error = ($output | Select-String "^!" | Select-Object -First 5) -join "`n"
        }
    }
    
    Pop-Location
}

Write-Host ""
Write-Host "=== 結果 ===" -ForegroundColor Cyan
Write-Host "成功: $succeeded / $($figFiles.Count)" -ForegroundColor Green
Write-Host "失敗: $failed / $($figFiles.Count)" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if ($failed -gt 0) {
    Write-Host ""
    Write-Host "=== エラー詳細 ===" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host ""
        Write-Host "$($err.File)" -ForegroundColor Yellow
        Write-Host "  パス: $($err.Path)" -ForegroundColor Gray
        if ($err.Error) {
            Write-Host "  エラー:" -ForegroundColor Red
            Write-Host $err.Error -ForegroundColor Gray
        }
    }
}
else {
    Write-Host ""
    Write-Host "全てのstandalone図のコンパイルに成功しました！" -ForegroundColor Green
}
