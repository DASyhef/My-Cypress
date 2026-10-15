 
Write-Host "=== Verification et installation des prerequis (Windows) ===" -ForegroundColor Cyan

# 1. Verification / Installation de Task
if (-not (Get-Command task -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Task n'est pas installe. Installation via winget..." -ForegroundColor Yellow
    winget install Task.Task
} else {
    Write-Host "[OK] Task est installe." -ForegroundColor Green
}

# 2. Verification de Flutter
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Flutter absent ou non accessible dans le PATH." -ForegroundColor Red
    Write-Host "Installation : https://docs.flutter.dev/get-started/install"
    exit 1
} else {
    Write-Host "[OK] Flutter est installe." -ForegroundColor Green
}

# 3. Licences Android
Write-Host "=== Acceptation des licences Android ===" -ForegroundColor Cyan
try {
    1..20 | ForEach-Object { "y" } | flutter doctor --android-licenses
} catch {
    Write-Host "[!] Impossible d'accepter les licences Android automatiquement." -ForegroundColor Yellow
    Write-Host "    Installez 'Android SDK Command-line Tools' via Android Studio (SDK Manager > SDK Tools)."
}

# 4. Visual Studio (necessaire uniquement pour les apps Windows desktop)
Write-Host "=== Verification de Visual Studio ===" -ForegroundColor Cyan
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsInstalled = $false
if (Test-Path $vswhere) {
    $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Workload.NativeDesktop -property installationPath
    if ($vsPath) { $vsInstalled = $true }
}

if ($vsInstalled) {
    Write-Host "[OK] Visual Studio avec la charge de travail C++ est installe." -ForegroundColor Green
} else {
    Write-Host "[!] Visual Studio (Desktop development with C++) est absent." -ForegroundColor Yellow
    $reponse = Read-Host "Installer Visual Studio 2022 Community maintenant ? (o/N) [uniquement pour cibler Windows]"
    if ($reponse -match '^[oOyY]') {
        winget install Microsoft.VisualStudio.2022.Community --override "--add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --passive --norestart"
    } else {
        Write-Host "Installation ignoree (inutile pour Android / Web)." -ForegroundColor DarkGray
    }
}

# 5. Diagnostic Flutter
Write-Host "=== Diagnostic Flutter Doctor ===" -ForegroundColor Cyan
flutter doctor