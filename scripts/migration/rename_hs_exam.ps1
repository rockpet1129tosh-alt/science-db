# hs-exam ファイル一括リネーム
# A → 1st, B → 2nd

param(
    [string]$SourceDir = "C:\Users\selec\Documents\hs-exam"
)

$items = Get-ChildItem $SourceDir -Filter "*_A_*" -o "*_B_*"

Write-Host "=== hs-exam 一括リネーム ===" -ForegroundColor Cyan
Write-Host "A → 1st, B → 2nd (小文字)" -ForegroundColor White
Write-Host ""

$renameCount = 0

# A → 1st
$aItems = Get-ChildItem $SourceDir -Filter "*_A_*"
foreach ($item in $aItems) {
    $newName = $item.Name -replace '_A_', '_1st_'
    $newPath = Join-Path $SourceDir $newName
    
    Rename-Item -Path $item.FullName -NewName $newName -verbose
    Write-Host "$($item.Name) → $newName" -ForegroundColor Green
    $renameCount++
}

Write-Host ""

# B → 2nd
$bItems = Get-ChildItem $SourceDir -Filter "*_B_*"
foreach ($item in $bItems) {
    $newName = $item.Name -replace '_B_', '_2nd_'
    $newPath = Join-Path $SourceDir $newName
    
    Rename-Item -Path $item.FullName -NewName $newName -verbose
    Write-Host "$($item.Name) → $newName" -ForegroundColor Green
    $renameCount++
}

Write-Host ""
Write-Host "完了: $renameCount ファイルをリネームしました" -ForegroundColor Cyan
