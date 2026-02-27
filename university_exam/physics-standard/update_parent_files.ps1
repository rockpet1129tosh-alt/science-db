# 親ファイルのsubfileパスを更新するスクリプト

$baseDir = "C:\Users\selec\Documents\tex_all\physics-db\university_exam\physics-standard"
Set-Location $baseDir

# 問題ファイルの更新
$qFile = "questions/sub_electromagnetism/circuit-basics/all/physics-standard_questions_circuit-basics.tex"
$content = Get-Content $qFile -Raw -Encoding UTF8

# graphicspath更新（全問題の図フォルダを追加）
$graphicsPath = '\graphicspath{{'
for ($i = 1; $i -le 12; $i++) {
    $num = $i.ToString("00")
    $graphicsPath += "../../../../sub_electromagnetism/circuit-basics/*_$num*/fig/"
}
$graphicsPath += '../../../../figures/}}'

$content = $content -replace '\\graphicspath\{[^}]+\}', $graphicsPath

# subfileパス更新（02-12）
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
    
    $oldPath = "\.\./\.\./\.\./\.\./$folderName/physics-standard_questions_circuit-basics_$num\.tex"
    $newPath = "../../../../sub_electromagnetism/circuit-basics/$folderName/${folderName}_q.tex"
    
    $content = $content -replace $oldPath, $newPath
}

Set-Content $qFile -Value $content -Encoding UTF8 -NoNewline
Write-Host "Updated: $qFile" -ForegroundColor Green

# 解答ファイルの更新
$aFile = "answers/sub_electromagnetism/circuit-basics/all/physics-standard_answers_circuit-basics.tex"
$content = Get-Content $aFile -Raw -Encoding UTF8

foreach ($prob in $problems) {
    $num = $prob.num
    $name = $prob.name
    $folderName = "${num}_${name}"
    
    $oldPath = "\.\./\.\./\.\./\.\./$folderName/physics-standard_answers_circuit-basics_$num\.tex"
    $newPath = "../../../../sub_electromagnetism/circuit-basics/$folderName/${folderName}_a.tex"
    
    $content = $content -replace $oldPath, $newPath
}

Set-Content $aFile -Value $content -Encoding UTF8 -NoNewline
Write-Host "Updated: $aFile" -ForegroundColor Green

Write-Host "`nParent file update complete!" -ForegroundColor Cyan
