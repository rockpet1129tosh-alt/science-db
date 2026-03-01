# hs-exam ファイル追加リネーム
# answers → a, questions → q

param(
    [string]$SourceDir = "C:\Users\selec\Documents\hs-exam"
)

Write-Host "=== hs-exam 追加リネーム ===" -ForegroundColor Cyan
Write-Host "answers → a, questions → q" -ForegroundColor White
Write-Host ""

$renameCount = 0

# answers → a
$answerItems = Get-ChildItem $SourceDir -Filter "*_answers.pdf"
foreach ($item in $answerItems) {
    $newName = $item.Name -replace '_answers\.pdf', '_a.pdf'
    
    Rename-Item -Path $item.FullName -NewName $newName
    Write-Host "$($item.Name) → $newName" -ForegroundColor Green
    $renameCount++
}

Write-Host ""

# questions → q
$questionItems = Get-ChildItem $SourceDir -Filter "*_questions.pdf"
foreach ($item in $questionItems) {
    $newName = $item.Name -replace '_questions\.pdf', '_q.pdf'
    
    Rename-Item -Path $item.FullName -NewName $newName
    Write-Host "$($item.Name) → $newName" -ForegroundColor Green
    $renameCount++
}

Write-Host ""
Write-Host "完了: $renameCount ファイルをリネームしました" -ForegroundColor Cyan
