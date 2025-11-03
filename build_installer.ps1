# Скрипт PowerShell для сборки установщика Windows
# Использование: .\build_installer.ps1

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Сборка установщика Windows для IPTVCA" -ForegroundColor Cyan
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

# Установка зависимостей
Write-Host "[1/4] Установка зависимостей..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось установить зависимости" -ForegroundColor Red
    exit 1
}

# Сборка приложения
Write-Host ""
Write-Host "[2/4] Сборка Windows приложения..." -ForegroundColor Yellow
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось собрать приложение" -ForegroundColor Red
    exit 1
}

# Создание MSIX установщика
Write-Host ""
Write-Host "[3/4] Создание MSIX установщика..." -ForegroundColor Yellow
# Автоматически отвечаем "N" на вопрос об установке сертификата
echo "N" | dart run msix:create
if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось создать MSIX установщик" -ForegroundColor Red
    Write-Host "Убедитесь, что msix установлен: flutter pub get" -ForegroundColor Yellow
    exit 1
}

# Поиск созданного файла
Write-Host ""
Write-Host "[4/4] Поиск созданного установщика..." -ForegroundColor Yellow
$msixFiles = Get-ChildItem -Path "build\windows\x64\runner\Release\*.msix" -ErrorAction SilentlyContinue

if ($msixFiles) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "УСПЕШНО! Установщик создан:" -ForegroundColor Green
    foreach ($file in $msixFiles) {
        Write-Host $file.FullName -ForegroundColor Green
    }
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Для установки дважды кликните на файл .msix" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "ПРЕДУПРЕЖДЕНИЕ: Файл установщика не найден" -ForegroundColor Yellow
    Write-Host "Проверьте папку build\windows\x64\runner\Release\" -ForegroundColor Yellow
}

