@echo off
chcp 65001 >nul
echo ================================================
echo Сборка установщика Windows для IPTVCA
echo ================================================
echo.

REM Проверка наличия Flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ОШИБКА: Flutter не найден в PATH
    echo Установите Flutter и добавьте его в PATH
    pause
    exit /b 1
)

REM Установка зависимостей
echo [1/4] Установка зависимостей...
call flutter pub get
if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось установить зависимости
    pause
    exit /b 1
)

REM Сборка приложения
echo.
echo [2/4] Сборка Windows приложения...
call flutter build windows --release
if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось собрать приложение
    pause
    exit /b 1
)

REM Создание MSIX установщика
echo.
echo [3/4] Создание MSIX установщика...
echo N|call dart run msix:create
if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось создать MSIX установщик
    echo Убедитесь, что msix установлен: flutter pub get
    pause
    exit /b 1
)

REM Поиск созданного файла
echo.
echo [4/4] Поиск созданного установщика...
set MSIX_FILE=
for %%f in (build\windows\x64\runner\Release\*.msix) do set MSIX_FILE=%%f

if exist "%MSIX_FILE%" (
    echo.
    echo ================================================
    echo УСПЕШНО! Установщик создан:
    echo %MSIX_FILE%
    echo ================================================
    echo.
    echo Для установки дважды кликните на файл .msix
    echo.
) else (
    echo ПРЕДУПРЕЖДЕНИЕ: Файл установщика не найден
    echo Проверьте папку build\windows\x64\runner\Release\
)

pause

