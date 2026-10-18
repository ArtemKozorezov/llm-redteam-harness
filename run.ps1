# PowerShell runner for AI Security & Red-Teaming Evaluation Suite (Windows)
$ErrorActionPreference = "Continue"

Write-Host "=== 1. Creating required directories ===" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "models", "reports" | Out-Null

Write-Host "=== 2. Running static artifact security scan ===" -ForegroundColor Cyan
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Use binaries from local venv if available, otherwise fallback to PATH
$modelscanExe = if (Test-Path ".\venv\Scripts\modelscan.exe") { ".\venv\Scripts\modelscan.exe" } else { "modelscan" }
$ficklingExe  = if (Test-Path ".\venv\Scripts\fickling.exe") { ".\venv\Scripts\fickling.exe" } else { "fickling" }

try {
    & $modelscanExe -p ./models/ | Out-File -Encoding utf8 reports/modelscan-report.txt
} catch {
    Write-Warning "Modelscan execution warning: $_"
}

if (Test-Path "./models/legacy_classifier.pkl") {
    try {
        & $ficklingExe ./models/legacy_classifier.pkl | Out-File -Encoding utf8 -Append reports/fickling-report.txt
    } catch {
        Write-Warning "Fickling execution warning: $_"
    }
}

Write-Host "=== 3. Running Promptfoo Red-Teaming evaluation ===" -ForegroundColor Cyan
$env:NODE_NO_WARNINGS = "1"
try {
    promptfoo eval --config promptfooconfig.yaml -o reports/vulnerability_report.html -o reports/vulnerability_report.json
} catch {
    Write-Warning "Promptfoo execution warning: $_"
}

Write-Host "=== Done! All reports saved in /reports directory ===" -ForegroundColor Green
