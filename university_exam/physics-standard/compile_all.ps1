# Compile all LaTeX files with lualatex
# Usage: .\compile_all.ps1

$ErrorActionPreference = "Continue"
$baseDir = $PSScriptRoot

# Statistics
$totalFiles = 0
$successCount = 0
$failedFiles = @()

Write-Host "=== Starting LaTeX Compilation ===" -ForegroundColor Cyan
Write-Host "Base Directory: $baseDir" -ForegroundColor Gray
Write-Host ""

# Function to compile a single file
function Compile-TexFile {
    param(
        [string]$FilePath
    )
    
    $relativePath = $FilePath.Replace($baseDir, "").TrimStart('\')
    $dir = Split-Path $FilePath -Parent
    $fileName = Split-Path $FilePath -Leaf
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    
    Write-Host "[$script:totalFiles] Compiling: $relativePath" -NoNewline
    
    Push-Location $dir
    try {
        # Run lualatex with minimal output
        $result = lualatex -interaction=nonstopmode -halt-on-error $fileName 2>&1 | Out-String
        
        # Check if PDF was created
        if (Test-Path "${baseName}.pdf") {
            Write-Host " [OK]" -ForegroundColor Green
            $script:successCount++
        }
        else {
            Write-Host " [FAIL] (PDF not generated)" -ForegroundColor Red
            $script:failedFiles += $relativePath
        }
    }
    catch {
        Write-Host " [ERROR] (Exception: $($_.Exception.Message))" -ForegroundColor Red
        $script:failedFiles += $relativePath
    }
    finally {
        Pop-Location
    }
    
    $script:totalFiles++
}

# Step 1: Compile top-level parent files
Write-Host "Step 1: Top-level parent files" -ForegroundColor Yellow
Get-ChildItem -Path $baseDir -Filter "ps_*.tex" -File | ForEach-Object {
    Compile-TexFile -FilePath $_.FullName
}

Write-Host ""

# Step 2: Compile domain-level parent files
Write-Host "Step 2: Domain-level parent files" -ForegroundColor Yellow
Get-ChildItem -Path $baseDir -Recurse -Filter "ps_*.tex" -File | Where-Object {
    $_.Directory.Name -match "^(em_|me_|th_|mp_|wa_)"
} | ForEach-Object {
    Compile-TexFile -FilePath $_.FullName
}

Write-Host ""

# Step 3: Compile child files (problems)
Write-Host "Step 3: Child files (individual problems)" -ForegroundColor Yellow
Get-ChildItem -Path $baseDir -Recurse -Filter "ps_*.tex" -File | Where-Object {
    $_.Directory.Name -notmatch "^(em_|me_|th_|mp_|wa_)" -and
    $_.Directory.FullName -ne $baseDir
} | ForEach-Object {
    Compile-TexFile -FilePath $_.FullName
}

Write-Host ""
Write-Host "=== Compilation Summary ===" -ForegroundColor Cyan
Write-Host "Total files: $totalFiles" -ForegroundColor White
Write-Host "Success: $successCount" -ForegroundColor Green
Write-Host "Failed: $($failedFiles.Count)" -ForegroundColor Red

if ($failedFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Failed files:" -ForegroundColor Red
    $failedFiles | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Cyan
