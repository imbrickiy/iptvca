@echo off
chcp 65001 >nul
echo ================================================
echo Сборка NSIS установщика для IPTVCA
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

REM Проверка наличия NSIS
where makensisw >nul 2>&1
where makensis >nul 2>&1
if %errorlevel% neq 0 (
    echo ОШИБКА: NSIS не найден в PATH
    echo.
    echo Установите NSIS:
    echo 1. Скачайте с https://nsis.sourceforge.io/Download
    echo 2. Установите NSIS
    echo 3. Добавьте NSIS в PATH (обычно: C:\Program Files (x86)\NSIS)
    echo.
    pause
    exit /b 1
)

REM Установка зависимостей
echo [1/3] Установка зависимостей...
call flutter pub get
if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось установить зависимости
    pause
    exit /b 1
)

REM Сборка приложения
echo.
echo [2/3] Сборка Windows приложения...
call flutter build windows --release
if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось собрать приложение
    pause
    exit /b 1
)

REM Компиляция NSIS установщика
echo.
echo [3/3] Создание NSIS установщика...
echo ВАЖНО: Используется Unicode версия NSIS для корректного отображения русского текста
echo.
REM Приоритет: makensis.exe (Unicode версия)
if exist "C:\Program Files (x86)\NSIS\makensis.exe" (
    "C:\Program Files (x86)\NSIS\makensis.exe" installer.nsi
) else if exist "C:\Program Files\NSIS\makensis.exe" (
    "C:\Program Files\NSIS\makensis.exe" installer.nsi
) else if exist "C:\Program Files (x86)\NSIS\makensisw.exe" (
    "C:\Program Files (x86)\NSIS\makensisw.exe" installer.nsi
) else if exist "C:\Program Files\NSIS\makensisw.exe" (
    "C:\Program Files\NSIS\makensisw.exe" installer.nsi
) else (
    makensis installer.nsi
)

if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось создать NSIS установщик
    echo Убедитесь, что NSIS установлен и доступен в PATH
    pause
    exit /b 1
)

REM Поиск созданного файла
echo.
echo ================================================
echo УСПЕШНО! Установщик создан:
echo.
dir /b IPTVCA_Setup_*.exe 2>nul
echo ================================================
echo.
echo Для установки запустите файл IPTVCA_Setup_[версия].exe
echo.

pause

