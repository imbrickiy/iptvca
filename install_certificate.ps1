# Скрипт для установки сертификата MSIX в систему Windows
# Использование: .\install_certificate.ps1

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Установка сертификата MSIX для IPTVCA" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Проверка наличия сертификата
$certPath = "build\windows\x64\runner\Release\test_certificate.pfx"

if (-not (Test-Path $certPath)) {
    Write-Host "ОШИБКА: Сертификат не найден: $certPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Сначала создайте установщик:" -ForegroundColor Yellow
    Write-Host "  .\build_installer.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Найден сертификат: $certPath" -ForegroundColor Green
Write-Host ""

# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ВНИМАНИЕ: Для установки сертификата требуются права администратора!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Запустите PowerShell от имени администратора и выполните:" -ForegroundColor Yellow
    Write-Host "  .\install_certificate.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Или выполните вручную:" -ForegroundColor Yellow
    Write-Host "  Import-Certificate -FilePath `"$certPath`" -CertStoreLocation Cert:\LocalMachine\TrustedPeople" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# Установка сертификата в хранилище доверенных сертификатов
Write-Host "Установка сертификата в хранилище TrustedPeople..." -ForegroundColor Yellow
try {
    # Импорт сертификата в LocalMachine\TrustedPeople (для всех пользователей)
    Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\TrustedPeople
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "Сертификат успешно установлен!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Теперь вы можете установить MSIX файл:" -ForegroundColor Cyan
    Write-Host "  1. Дважды кликните на iptvca.msix" -ForegroundColor Cyan
    Write-Host "  2. Кнопка 'Install' должна быть активна" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "ОШИБКА: Не удалось установить сертификат" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Попробуйте установить вручную:" -ForegroundColor Yellow
    Write-Host "  Import-Certificate -FilePath `"$certPath`" -CertStoreLocation Cert:\LocalMachine\TrustedPeople" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

