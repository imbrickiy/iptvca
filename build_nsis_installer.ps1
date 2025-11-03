# Скрипт PowerShell для сборки NSIS установщика Windows
# Использование: .\build_nsis_installer.ps1

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Сборка NSIS установщика Windows для IPTVCA" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Проверка наличия Flutter
try {
    $null = Get-Command flutter -ErrorAction Stop
} catch {
    Write-Host "ОШИБКА: Flutter не найден в PATH" -ForegroundColor Red
    Write-Host "Установите Flutter и добавьте его в PATH" -ForegroundColor Red
    exit 1
}

# Проверка наличия NSIS
$nsisPath = $null
$possiblePaths = @(
    "C:\Program Files (x86)\NSIS\makensis.exe",
    "C:\Program Files\NSIS\makensis.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $nsisPath = $path
        break
    }
}

try {
    $null = Get-Command makensis -ErrorAction Stop
    $nsisPath = "makensis"
} catch {
    if (-not $nsisPath) {
        Write-Host "ОШИБКА: NSIS не найден" -ForegroundColor Red
        Write-Host ""
        Write-Host "Установите NSIS:" -ForegroundColor Yellow
        Write-Host "1. Скачайте с https://nsis.sourceforge.io/Download" -ForegroundColor Yellow
        Write-Host "2. Установите NSIS" -ForegroundColor Yellow
        Write-Host "3. Добавьте NSIS в PATH (обычно: C:\Program Files (x86)\NSIS)" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
}

# Установка зависимостей
Write-Host "[1/3] Установка зависимостей..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось установить зависимости" -ForegroundColor Red
    exit 1
}

# Сборка приложения
Write-Host ""
Write-Host "[2/3] Сборка Windows приложения..." -ForegroundColor Yellow
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось собрать приложение" -ForegroundColor Red
    exit 1
}

# Компиляция NSIS установщика
Write-Host ""
Write-Host "[3/3] Создание NSIS установщика..." -ForegroundColor Yellow
Write-Host "Используется NSIS: $nsisPath" -ForegroundColor Gray

# Проверяем, что используется Unicode версия NSIS
if ($nsisPath -notmatch "makensis\.exe" -and $nsisPath -notmatch "makensisw\.exe") {
    Write-Host "ВНИМАНИЕ: Убедитесь, что используется Unicode версия NSIS" -ForegroundColor Yellow
}

& $nsisPath installer.nsi
if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось создать NSIS установщик" -ForegroundColor Red
    Write-Host "Убедитесь, что NSIS установлен и доступен в PATH" -ForegroundColor Yellow
    Write-Host "ВАЖНО: Используйте Unicode версию NSIS для корректного отображения русского текста!" -ForegroundColor Yellow
    exit 1
}

# Поиск созданного файла
Write-Host ""
$installerFiles = Get-ChildItem -Path "." -Filter "IPTVCA_Setup_*.exe" -ErrorAction SilentlyContinue

if ($installerFiles) {
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "УСПЕШНО! Установщик создан:" -ForegroundColor Green
    foreach ($file in $installerFiles) {
        Write-Host $file.FullName -ForegroundColor Green
    }
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Для установки запустите файл IPTVCA_Setup_[версия].exe" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "ПРЕДУПРЕЖДЕНИЕ: Файл установщика не найден" -ForegroundColor Yellow
}

