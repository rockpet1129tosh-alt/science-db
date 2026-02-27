$baseDir = "c:\Users\selec\Documents\tex_all\physics-db\university_exam\physics-standard\em_electromagnetism"
$count = 0
$success = 0
$failed = 0

Get-ChildItem $baseDir -Recurse | Where-Object { $_.Name -match '^fig_em_.*_[qa]\.tex$' } | ForEach-Object {
    $count++
    $baseName = $_.BaseName
    $pdfFile = Join-Path $_.DirectoryName "${baseName}.pdf"
    
    # Skip if PDF already exists
    if (Test-Path $pdfFile) {
        Write-Host "[$count] $($_.Name) - SKIP (already exists)"
        $success++
        return
    }
    
    Write-Host "[$count] $($_.Name)"
    Push-Location $_.DirectoryName
    
    lualatex -interaction=nonstopmode $_.Name > $null 2>&1
    
    if (Test-Path "${baseName}.pdf") {
        Write-Host "     OK"
        $success++
    } else {
        Write-Host "     FAILED"
        $failed++
    }
    
    Remove-Item "*.aux", "*.log" -ErrorAction SilentlyContinue
    Pop-Location
}

Write-Host "`n========================================="
Write-Host "Compilation Complete!"
Write-Host "Success: $success"
Write-Host "Failed:  $failed"
Write-Host "Total:   $count"
Write-Host "========================================="
