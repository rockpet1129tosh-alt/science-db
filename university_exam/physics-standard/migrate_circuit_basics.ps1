# circuit-basicsの残り問題を新構造に移行するスクリプト

$baseDir = "C:\Users\selec\Documents\tex_all\physics-db\university_exam\physics-standard"
Set-Location $baseDir

# 処理する問題リスト（01は完了済み）
$problems = @(
    @{num="02"; name="charge-conservation-1"},
    @{num="03"; name="charge-conservation-2"},
    @{num="04"; name="capacitor-charging"},
    @{num="05"; name="capacitor-internal-1"},
    @{num="06"; name="capacitor-internal-2"},
    @{num="07"; name="capacitor-internal-3"},
    @{num="08"; name="add-battery-resistor"},
    @{num="09"; name="add-battery-capacitor"},
    @{num="10"; name="add-capacitor-discharge"},
    @{num="11"; name="add-three-plates"},
    @{num="12"; name="add-four-plates"}
)

foreach ($prob in $problems) {
    $num = $prob.num
    $name = $prob.name
    $folderName = "${num}_${name}"
    
    Write-Host "`n==== Processing: $folderName ====" -ForegroundColor Cyan
    
    # 1. 新フォルダ作成
    $newDir = "sub_electromagnetism/circuit-basics/$folderName"
    New-Item -Path $newDir -ItemType Directory -Force | Out-Null
    New-Item -Path "$newDir/fig" -ItemType Directory -Force | Out-Null
    
    # 2. 問題・解答ファイル移動
    $qOld = "questions/sub_electromagnetism/circuit-basics/$folderName/physics-standard_questions_circuit-basics_$num.tex"
    $qNew = "$newDir/${folderName}_q.tex"
    
    $aOld = "answers/sub_electromagnetism/circuit-basics/$folderName/physics-standard_answers_circuit-basics_$num.tex"
    $aNew = "$newDir/${folderName}_a.tex"
    
    if (Test-Path $qOld) {
        git mv $qOld $qNew
        Write-Host "  Moved: $qNew" -ForegroundColor Green
    }
    
    if (Test-Path $aOld) {
        git mv $aOld $aNew
        Write-Host "  Moved: $aNew" -ForegroundColor Green
    }
    
    # 3. 図フォルダ移動
    $figPattern = "figures/*circuit-basics_${num}_*"
    $figFolders = Get-ChildItem -Path "figures" -Directory | Where-Object { $_.Name -like "*circuit-basics_${num}_*" }
    
    foreach ($figFolder in $figFolders) {
        $figOld = "figures/$($figFolder.Name)"
        $figNew = "$newDir/fig/$($figFolder.Name)"
        git mv $figOld $figNew
        Write-Host "  Moved fig: $($figFolder.Name)" -ForegroundColor Green
    }
    
    # 4. .texファイルの相対パス修正
    if (Test-Path $qNew) {
        $content = Get-Content $qNew -Raw -Encoding UTF8
        $content = $content -replace '\\documentclass\[\.\.\/\.\.\/\.\.\/all\/physics-standard_questions_all\.tex\]', '\documentclass[../../../questions/all/physics-standard_questions_all.tex]'
        $content = $content -replace '\\graphicspath\{\{\.\.\/\.\.\/\.\.\/\.\.\/figures\/\}\}', '\graphicspath{{fig/}}'
        Set-Content $qNew -Value $content -Encoding UTF8 -NoNewline
    }
    
    if (Test-Path $aNew) {
        $content = Get-Content $aNew -Raw -Encoding UTF8
        $content = $content -replace '\\documentclass\[\.\.\/\.\.\/\.\.\/all\/physics-standard_answers_all\.tex\]', '\documentclass[../../../answers/all/physics-standard_answers_all.tex]'
        Set-Content $aNew -Value $content -Encoding UTF8 -NoNewline
    }
}

Write-Host "`n==== Migration Complete ====" -ForegroundColor Green
Write-Host "Next: Update parent file subfile paths."
