# hs-exam 科目名短縮リネーム
# english → eng, japanese → jpn, math → mat, science → sci, social-studies → soc

param(
    [string]$SourceDir = "C:\Users\selec\Documents\hs-exam"
)

Write-Host "=== hs-exam 科目名短縮リネーム ===" -ForegroundColor Cyan
Write-Host "english → eng, japanese → jpn, math → mat, science → sci, social-studies → soc" -ForegroundColor White
Write-Host ""

$renameCount = 0

# リネームマッピング
$renameMap = @{
    'english' = 'eng'
    'japanese' = 'jpn'
    'math' = 'mat'
    'science' = 'sci'
    'social-studies' = 'soc'
}

foreach ($oldName in $renameMap.Keys) {
    $newName = $renameMap[$oldName]
    $items = Get-ChildItem $SourceDir -Filter "$oldName*"
    
    foreach ($item in $items) {
        $renamed = $item.Name -replace "^$oldName", $newName
        
        Rename-Item -Path $item.FullName -NewName $renamed
        Write-Host "$($item.Name) → $renamed" -ForegroundColor Green
        $renameCount++
    }
}

Write-Host ""
Write-Host "完了: $renameCount ファイルをリネームしました" -ForegroundColor Cyan
