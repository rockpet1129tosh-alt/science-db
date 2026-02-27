$ErrorActionPreference = 'Stop'

$base = "C:\Users\selec\Documents\tex_all\physics-db\university_exam\physics-standard"
Set-Location $base

function Update-TextFile {
    param(
        [string]$Path,
        [scriptblock]$Transform
    )
    if (!(Test-Path $Path)) { return }
    $content = Get-Content $Path -Raw -Encoding UTF8
    $newContent = & $Transform $content
    if ($newContent -ne $content) {
        Set-Content -Path $Path -Value $newContent -Encoding UTF8 -NoNewline
        Write-Host "updated: $Path" -ForegroundColor Green
    }
}

function Ensure-Dir {
    param([string]$Path)
    if (!(Test-Path $Path)) { New-Item -Path $Path -ItemType Directory -Force | Out-Null }
}

$subDirs = Get-ChildItem -Path "questions" -Directory | Where-Object { $_.Name -like "sub_*" } | Select-Object -ExpandProperty Name

foreach ($subDir in $subDirs) {
    $subName = $subDir -replace '^sub_', ''
    $questionSubRoot = Join-Path $base ("questions\" + $subDir)
    $answerSubRoot = Join-Path $base ("answers\" + $subDir)
    $newSubRoot = Join-Path $base $subDir
    Ensure-Dir $newSubRoot

    $categories = Get-ChildItem -Path $questionSubRoot -Directory | Where-Object { $_.Name -ne 'all' } | Select-Object -ExpandProperty Name

    foreach ($cat in $categories) {
        $newCatRoot = Join-Path $newSubRoot $cat
        Ensure-Dir $newCatRoot

        $oldQParentAll = Join-Path $questionSubRoot ("$cat\\all\\physics-standard_questions_${cat}.tex")
        $oldQParentDirect = Join-Path $questionSubRoot ("$cat\\physics-standard_questions_${cat}.tex")
        $newQParent = Join-Path $newCatRoot ("physics-standard_questions_${cat}.tex")

        if (!(Test-Path $newQParent)) {
            if (Test-Path $oldQParentAll) {
                Move-Item $oldQParentAll $newQParent -Force
                Write-Host "moved parent q: $cat" -ForegroundColor Cyan
            } elseif (Test-Path $oldQParentDirect) {
                Move-Item $oldQParentDirect $newQParent -Force
                Write-Host "moved parent q: $cat" -ForegroundColor Cyan
            }
        }

        $oldAParentAll = Join-Path $answerSubRoot ("$cat\\all\\physics-standard_answers_${cat}.tex")
        $oldAParentDirect = Join-Path $answerSubRoot ("$cat\\physics-standard_answers_${cat}.tex")
        $newAParent = Join-Path $newCatRoot ("physics-standard_answers_${cat}.tex")

        if (!(Test-Path $newAParent)) {
            if (Test-Path $oldAParentAll) {
                Move-Item $oldAParentAll $newAParent -Force
                Write-Host "moved parent a: $cat" -ForegroundColor Cyan
            } elseif (Test-Path $oldAParentDirect) {
                Move-Item $oldAParentDirect $newAParent -Force
                Write-Host "moved parent a: $cat" -ForegroundColor Cyan
            }
        }

        $problemDirs = Get-ChildItem -Path (Join-Path $questionSubRoot $cat) -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^\d{2}_' } |
            Sort-Object Name

        foreach ($prob in $problemDirs) {
            $probName = $prob.Name
            $num = ($probName -split '_')[0]
            $newProbDir = Join-Path $newCatRoot $probName
            Ensure-Dir $newProbDir
            Ensure-Dir (Join-Path $newProbDir 'fig')

            $qSourceDir = Join-Path $questionSubRoot ("$cat\\$probName")
            $qTex = Get-ChildItem -Path $qSourceDir -Filter ("physics-standard_questions_${cat}_*.tex") -File -ErrorAction SilentlyContinue | Select-Object -First 1
            $qDest = Join-Path $newProbDir ("${probName}_q.tex")
            if ($qTex -and !(Test-Path $qDest)) {
                Move-Item $qTex.FullName $qDest -Force
                Write-Host "moved q: $subDir/$cat/$probName" -ForegroundColor Yellow
            }

            $aSourceDir = Join-Path $answerSubRoot ("$cat\\$probName")
            $aTex = Get-ChildItem -Path $aSourceDir -Filter ("physics-standard_answers_${cat}_*.tex") -File -ErrorAction SilentlyContinue | Select-Object -First 1
            $aDest = Join-Path $newProbDir ("${probName}_a.tex")
            if ($aTex -and !(Test-Path $aDest)) {
                Move-Item $aTex.FullName $aDest -Force
                Write-Host "moved a: $subDir/$cat/$probName" -ForegroundColor Yellow
            }

            $figQ = Get-ChildItem -Path (Join-Path $base 'figures') -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like ("q_${cat}_${num}_*") }
            foreach ($f in $figQ) {
                $dest = Join-Path $newProbDir ("fig\\" + $f.Name)
                if (!(Test-Path $dest)) {
                    Move-Item $f.FullName $dest -Force
                }
            }

            $figA = Get-ChildItem -Path (Join-Path $base 'figures') -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like ("a_${cat}_${num}_*") }
            foreach ($f in $figA) {
                $dest = Join-Path $newProbDir ("fig\\" + $f.Name)
                if (!(Test-Path $dest)) {
                    Move-Item $f.FullName $dest -Force
                }
            }

            Update-TextFile -Path $qDest -Transform {
                param($t)
                $t = $t -replace '\\documentclass\[\.\.\/\.\.\/\.\.\/all\/physics-standard_questions_all\.tex\]\{subfiles\}', '\\documentclass[../../../physics-standard_questions_all.tex]{subfiles}'
                $t = $t -replace '\\documentclass\[\.\.\/\.\.\/\.\.\/questions\/all\/physics-standard_questions_all\.tex\]\{subfiles\}', '\\documentclass[../../../physics-standard_questions_all.tex]{subfiles}'
                $t = $t -replace '\\graphicspath\{\{\.\.\/\.\.\/\.\.\/\.\.\/figures\/\}\}', '\\graphicspath{{fig/}{../../../../../figures/}}'
                $t = $t -replace '\\graphicspath\{\{fig\/\}\}', '\\graphicspath{{fig/}{../../../../../figures/}}'
                return $t
            }

            Update-TextFile -Path $aDest -Transform {
                param($t)
                $t = $t -replace '\\documentclass\[\.\.\/\.\.\/\.\.\/all\/physics-standard_answers_all\.tex\]\{subfiles\}', '\\documentclass[../../../physics-standard_answers_all.tex]{subfiles}'
                $t = $t -replace '\\documentclass\[\.\.\/\.\.\/\.\.\/answers\/all\/physics-standard_answers_all\.tex\]\{subfiles\}', '\\documentclass[../../../physics-standard_answers_all.tex]{subfiles}'
                return $t
            }
        }

        Update-TextFile -Path $newQParent -Transform {
            param($t)
            $t = $t -replace '\\documentclass\[\.\.\/\.\.\/\.\.\/all\/physics-standard_questions_all\.tex\]\{subfiles\}', '\\documentclass[../../physics-standard_questions_all.tex]{subfiles}'
            $t = $t -replace '\\documentclass\[\.\.\/\.\.\/physics-standard_questions_all\.tex\]\{subfiles\}', '\\documentclass[../../physics-standard_questions_all.tex]{subfiles}'
            $t = [regex]::Replace($t, '\\subfile\{\.\./([^/]+)/physics-standard_questions_[^}]+\.tex\}', ('\\subfile{{../../' + $subDir + '/' + $cat + '/$1/$1_q.tex}}'))

            $probInNew = Get-ChildItem -Path $newCatRoot -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^\d{2}_' } | Sort-Object Name
            if ($probInNew.Count -gt 0) {
                $gp = "\\graphicspath{{../../figures/}{../../../../figures/}"
                foreach ($p in $probInNew) { $gp += "{" + $p.Name + "/fig/}" }
                $gp += "}"
                if ($t -match '\\graphicspath\{') {
                    $t = [regex]::Replace($t, '\\graphicspath\{[^\n]*\}', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $gp }, 1)
                } else {
                    $t = $t -replace '(\\documentclass\[[^\]]+\]\{subfiles\}\r?\n)', "$1`r`n$gp`r`n"
                }
            }
            return $t
        }

        Update-TextFile -Path $newAParent -Transform {
            param($t)
            $t = $t -replace '\\documentclass\[\.\.\/\.\.\/\.\.\/all\/physics-standard_answers_all\.tex\]\{subfiles\}', '\\documentclass[../../physics-standard_answers_all.tex]{subfiles}'
            $t = $t -replace '\\documentclass\[\.\.\/\.\.\/physics-standard_answers_all\.tex\]\{subfiles\}', '\\documentclass[../../physics-standard_answers_all.tex]{subfiles}'
            $t = [regex]::Replace($t, '\\subfile\{\.\./([^/]+)/physics-standard_answers_[^}]+\.tex\}', ('\\subfile{{../../' + $subDir + '/' + $cat + '/$1/$1_a.tex}}'))
            if ($t -match '\\graphicspath\{') {
                $t = [regex]::Replace($t, '\\graphicspath\{[^\n]*\}', '\\graphicspath{{../../figures/}{../../../../figures/}}', 1)
            } else {
                $t = $t -replace '(\\documentclass\[[^\]]+\]\{subfiles\}\r?\n)', "$1`r`n\\graphicspath{{../../figures/}{../../../../figures/}}`r`n"
            }
            return $t
        }
    }

    $oldQSubAll = Join-Path $questionSubRoot ("all\\physics-standard_questions_${subName}_all.tex")
    $newQSubAll = Join-Path $newSubRoot ("physics-standard_questions_${subName}_all.tex")
    if (!(Test-Path $newQSubAll) -and (Test-Path $oldQSubAll)) {
        Move-Item $oldQSubAll $newQSubAll -Force
        Write-Host "moved sub parent q: $subDir" -ForegroundColor Magenta
    }

    $oldASubAll = Join-Path $answerSubRoot ("all\\physics-standard_answers_${subName}_all.tex")
    $newASubAll = Join-Path $newSubRoot ("physics-standard_answers_${subName}_all.tex")
    if (!(Test-Path $newASubAll) -and (Test-Path $oldASubAll)) {
        Move-Item $oldASubAll $newASubAll -Force
        Write-Host "moved sub parent a: $subDir" -ForegroundColor Magenta
    }

    Update-TextFile -Path $newQSubAll -Transform {
        param($t)
        $t = $t -replace '\\documentclass\[\.\.\/\.\.\/all\/physics-standard_questions_all\.tex\]\{subfiles\}', '\\documentclass[../physics-standard_questions_all.tex]{subfiles}'
        $t = $t -replace '\\graphicspath\{\{\.\.\/\.\.\/\.\.\/figures\/\}\}', '\\graphicspath{{../figures/}}'
        $t = [regex]::Replace($t, '\\subfile\{\.\./([^/]+)/(?:all/)?physics-standard_questions_([^}]+)\.tex\}', '\\subfile{$1/physics-standard_questions_$2.tex}')
        return $t
    }

    Update-TextFile -Path $newASubAll -Transform {
        param($t)
        $t = $t -replace '\\documentclass\[\.\.\/\.\.\/all\/physics-standard_answers_all\.tex\]\{subfiles\}', '\\documentclass[../physics-standard_answers_all.tex]{subfiles}'
        $t = $t -replace '\\graphicspath\{\{\.\.\/\.\.\/\.\.\/figures\/\}\}', '\\graphicspath{{../figures/}}'
        $t = [regex]::Replace($t, '\\subfile\{\.\./([^/]+)/(?:all/)?physics-standard_answers_([^}]+)\.tex\}', '\\subfile{$1/physics-standard_answers_$2.tex}')
        return $t
    }
}

Update-TextFile -Path (Join-Path $base 'physics-standard_questions_all.tex') -Transform {
    param($t)
    $t = $t -replace '\\subfile\{questions/sub_mechanics/all/physics-standard_questions_mechanics_all\.tex\}', '\\subfile{sub_mechanics/physics-standard_questions_mechanics_all.tex}'
    $t = $t -replace '\\subfile\{questions/sub_thermodynamics/all/physics-standard_questions_thermodynamics_all\.tex\}', '\\subfile{sub_thermodynamics/physics-standard_questions_thermodynamics_all.tex}'
    $t = $t -replace '\\subfile\{questions/sub_wave/all/physics-standard_questions_wave_all\.tex\}', '\\subfile{sub_wave/physics-standard_questions_wave_all.tex}'
    $t = $t -replace '\\subfile\{questions/sub_modernphysics/all/physics-standard_questions_modernphysics_all\.tex\}', '\\subfile{sub_modernphysics/physics-standard_questions_modernphysics_all.tex}'
    return $t
}

Update-TextFile -Path (Join-Path $base 'physics-standard_answers_all.tex') -Transform {
    param($t)
    $t = $t -replace '\\subfile\{answers/sub_mechanics/all/physics-standard_answers_mechanics_all\.tex\}', '\\subfile{sub_mechanics/physics-standard_answers_mechanics_all.tex}'
    $t = $t -replace '\\subfile\{answers/sub_thermodynamics/all/physics-standard_answers_thermodynamics_all\.tex\}', '\\subfile{sub_thermodynamics/physics-standard_answers_thermodynamics_all.tex}'
    $t = $t -replace '\\subfile\{answers/sub_wave/all/physics-standard_answers_wave_all\.tex\}', '\\subfile{sub_wave/physics-standard_answers_wave_all.tex}'
    $t = $t -replace '\\subfile\{answers/sub_modernphysics/all/physics-standard_answers_modernphysics_all\.tex\}', '\\subfile{sub_modernphysics/physics-standard_answers_modernphysics_all.tex}'
    return $t
}

Write-Host "structure migration done" -ForegroundColor Green
