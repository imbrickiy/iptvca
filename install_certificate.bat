@echo off
chcp 65001 >nul
echo ================================================
echo Установка сертификата MSIX для IPTVCA
echo ================================================
echo.

REM Проверка наличия сертификата
set CERT_PATH=build\windows\x64\runner\Release\test_certificate.pfx

if not exist "%CERT_PATH%" (
    echo ОШИБКА: Сертификат не найден: %CERT_PATH%
    echo.
    echo Сначала создайте установщик:
    echo   build_installer.bat
    echo.
    pause
    exit /b 1
)

echo Найден сертификат: %CERT_PATH%
echo.
echo ВНИМАНИЕ: Для установки сертификата требуются права администратора!
echo.
echo Запустите эту команду от имени администратора в PowerShell:
echo.
echo   Import-Certificate -FilePath "%CERT_PATH%" -CertStoreLocation Cert:\LocalMachine\TrustedPeople
echo.
echo Или запустите PowerShell от имени администратора и выполните:
echo   .\install_certificate.ps1
echo.
pause

