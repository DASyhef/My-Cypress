Write-Host "=== Vérification et installation des prérequis (Windows) ===" -ForegroundColor Cyan

# 1. Vérification / Installation de Task
if (-not (Get-Command task -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Task n'est pas installé. Installation via winget..." -ForegroundColor Yellow
    winget install Task.Task
} else {
    Write-Host "[✓] Task est installé." -ForegroundColor Green
}

# 2. Vérification de Flutter
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[X] Flutter n'est pas installé ou absent du PATH." -ForegroundColor Red
    Write-Host "    Veuillez installer Flutter SDK : https://docs.flutter.dev/get-started/install"
    exit 1
} else {
    Write-Host "[✓] Flutter est installé." -ForegroundColor Green
}

# 3. Diagnostic Flutter
Write-Host "=== Diagnostic Flutter Doctor ===" -ForegroundColor Cyan
flutter doctor