# Build APK for Khums Yar - one-command script
# Usage:  .\build_apk.ps1
#         .\build_apk.ps1 -Split      (split APKs per ABI)
#         .\build_apk.ps1 -Bundle     (App Bundle for Google Play)

param(
    [switch]$Split,
    [switch]$Bundle
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Set-Location $root

function Fail($msg) {
    Write-Host ""
    Write-Host "FAILED: $msg" -ForegroundColor Red
    exit 1
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "    Khums Yar - Build APK" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# -- Step 1: prerequisites --
Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Cyan

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Fail "Flutter not found in PATH. Install from https://docs.flutter.dev/get-started/install"
}
Write-Host "  OK: flutter found"

$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if (-not $javaCmd) {
    Write-Host "  WARN: java not in PATH (Android Studio may provide it)" -ForegroundColor Yellow
}

# -- Step 2: local.properties --
Write-Host "[2/5] Writing local.properties..." -ForegroundColor Cyan
$localProps = Join-Path $root "android\local.properties"

# Resolve flutter SDK root from the flutter executable path
$flutterExe = $flutterCmd.Source
$flutterBin = Split-Path $flutterExe -Parent
$flutterSdkDir = Split-Path $flutterBin -Parent
$flutterSdkDir = $flutterSdkDir.Replace("\", "/")

$lines = @()
if (Test-Path $localProps) {
    $lines = @(Get-Content $localProps | Where-Object { $_ -notmatch "^flutter\.sdk=" })
}
$lines += "flutter.sdk=$flutterSdkDir"

$sdkRoot = $env:ANDROID_HOME
if (-not $sdkRoot) { $sdkRoot = $env:ANDROID_SDK_ROOT }
if ($sdkRoot) {
    $sdkRoot = $sdkRoot.Replace("\", "/")
    $lines += "sdk.dir=$sdkRoot"
}
Set-Content -Path $localProps -Value $lines -Encoding ASCII
Write-Host "  OK: local.properties written"

# -- Step 3: dependencies --
Write-Host "[3/5] Fetching Dart dependencies..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) { Fail "flutter pub get failed" }
Write-Host "  OK: dependencies ready"

# -- Step 4: analyze + test (non-fatal) --
Write-Host "[4/5] Analyzing and testing..." -ForegroundColor Cyan
flutter analyze --no-fatal-infos 2>&1 | Select-Object -Last 3
flutter test 2>&1 | Select-Object -Last 3

# -- Step 5: build --
Write-Host "[5/5] Building..." -ForegroundColor Cyan
if ($Bundle) {
    Write-Host "  Building App Bundle (Google Play)..."
    flutter build appbundle --release
    $out = "build\app\outputs\bundle\release"
} elseif ($Split) {
    Write-Host "  Building split APKs per ABI..."
    flutter build apk --release --split-per-abi
    $out = "build\app\outputs\flutter-apk"
} else {
    Write-Host "  Building universal APK..."
    flutter build apk --release
    $out = "build\app\outputs\flutter-apk"
}

if ($LASTEXITCODE -ne 0) { Fail "build failed" }

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "    BUILD SUCCEEDED" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output files:" -ForegroundColor Yellow

Get-ChildItem $out -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "\.apk$|\.aab$" } |
    ForEach-Object {
        $mb = [math]::Round($_.Length / 1MB, 1)
        Write-Host "  $($_.FullName)"
        Write-Host "    $mb MB" -ForegroundColor Gray
    }

Write-Host ""
Write-Host "To install on a connected device:" -ForegroundColor Cyan
Write-Host "  flutter install" -ForegroundColor Gray
Write-Host ""
