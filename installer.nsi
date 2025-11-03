; NSIS скрипт для создания установщика IPTVCA
; Использование: скомпилируйте этот файл через NSIS Compiler
; ВАЖНО: Используйте Unicode версию NSIS для корректного отображения русского текста

;--------------------------------
; Настройки

; ВАЖНО: Для корректного отображения русского текста используйте Unicode версию NSIS
; Современные версии NSIS по умолчанию Unicode

!define APP_NAME "IPTVCA"
!define APP_VERSION "1.0.0"
!define APP_PUBLISHER "IPTVCA"
!define APP_EXECUTABLE "iptvca.exe"
!define APP_DIR "iptvca"
!define SOURCE_DIR "build\windows\x64\runner\Release"

; Название установщика
Name "${APP_NAME} ${APP_VERSION}"

; Файл установщика
OutFile "${APP_NAME}_Setup_${APP_VERSION}.exe"

; Используемый сжатие
SetCompressor /SOLID lzma

; Используйте интерфейс современного Windows
!include "MUI2.nsh"

;--------------------------------
; Интерфейс

!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Страницы установщика
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Страницы удаления
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Язык
; ВАЖНО: Для корректного отображения русского текста используйте Unicode версию NSIS
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Версия установщика

VIProductVersion "${APP_VERSION}.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "Comments" "IPTV приложение для Windows"
VIAddVersionKey "CompanyName" "${APP_PUBLISHER}"
VIAddVersionKey "LegalCopyright" "© ${APP_PUBLISHER}"
VIAddVersionKey "FileDescription" "${APP_NAME} Installer"
VIAddVersionKey "FileVersion" "${APP_VERSION}"

;--------------------------------
; Установка

InstallDir "$PROGRAMFILES64\${APP_DIR}"
InstallDirRegKey HKCU "Software\${APP_DIR}" ""

RequestExecutionLevel admin

; Функция проверки наличия директории с файлами
Function .onInit
  IfFileExists "${SOURCE_DIR}\${APP_EXECUTABLE}" +3 0
    MessageBox MB_OK|MB_ICONSTOP "Файлы сборки не найдены!$\n$\nСначала соберите приложение:$\n$\nflutter build windows --release"
    Abort
FunctionEnd

; Секция установки
; Используем LangString для корректного отображения русского текста
Section $(NAME_SecMain) SecMain
  SectionIn RO
  
  SetOutPath "$INSTDIR"
  
  ; Копируем основной исполняемый файл
  File "${SOURCE_DIR}\${APP_EXECUTABLE}"
  
  ; Копируем все DLL файлы
  File /r "${SOURCE_DIR}\*.dll"
  
  ; Копируем папку data с ресурсами (включая flutter_assets внутри неё)
  File /r "${SOURCE_DIR}\data"
  
  ; Копируем папку native_assets если существует и не пуста (опционально)
  ; Эта папка может отсутствовать, поэтому используем /nonfatal
  IfFileExists "${SOURCE_DIR}\native_assets" 0 +4
    SetOutPath "$INSTDIR\native_assets"
    File /nonfatal /r "${SOURCE_DIR}\native_assets\*.*"
    SetOutPath "$INSTDIR"
  
  ; Создаем записи в реестре для удаления
  WriteRegStr HKCU "Software\${APP_DIR}" "" $INSTDIR
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_DIR}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_DIR}" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_DIR}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_DIR}" "DisplayIcon" "$INSTDIR\${APP_EXECUTABLE}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_DIR}" "Publisher" "${APP_PUBLISHER}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_DIR}" "DisplayVersion" "${APP_VERSION}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_DIR}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_DIR}" "NoRepair" 1
  
  ; Создаем файл удаления
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

; Секция ярлыков
; Используем LangString для корректного отображения русского текста
Section $(NAME_SecShortcuts) SecShortcuts
  ; Ярлык на рабочем столе
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXECUTABLE}"
  
  ; Ярлык в меню Пуск
  CreateDirectory "$SMPROGRAMS\${APP_DIR}"
  CreateShortcut "$SMPROGRAMS\${APP_DIR}\${APP_NAME}.lnk" "$INSTDIR\${APP_EXECUTABLE}"
  CreateShortcut "$SMPROGRAMS\${APP_DIR}\Удалить ${APP_NAME}.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
; Описания секций

; Названия секций
LangString NAME_SecMain ${LANG_RUSSIAN} "Основная программа"
LangString NAME_SecMain ${LANG_ENGLISH} "Main Program"

LangString NAME_SecShortcuts ${LANG_RUSSIAN} "Ярлыки"
LangString NAME_SecShortcuts ${LANG_ENGLISH} "Shortcuts"

; Описания секций
LangString DESC_SecMain ${LANG_RUSSIAN} "Устанавливает основные файлы приложения."
LangString DESC_SecShortcuts ${LANG_RUSSIAN} "Создаёт ярлыки на рабочем столе и в меню Пуск."

LangString DESC_SecMain ${LANG_ENGLISH} "Installs the main application files."
LangString DESC_SecShortcuts ${LANG_ENGLISH} "Creates shortcuts on desktop and in Start menu."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} $(DESC_SecShortcuts)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Удаление

Section "Uninstall"
  ; Удаляем файлы
  Delete "$INSTDIR\${APP_EXECUTABLE}"
  Delete "$INSTDIR\Uninstall.exe"
  Delete "$INSTDIR\*.dll"
  RMDir /r "$INSTDIR\data"
  RMDir /r /REBOOTOK "$INSTDIR\native_assets"
  
  ; Удаляем директорию если пуста
  RMDir "$INSTDIR"
  
  ; Удаляем ярлыки
  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_DIR}\*.*"
  RMDir "$SMPROGRAMS\${APP_DIR}"
  
  ; Удаляем записи из реестра
  DeleteRegKey HKCU "Software\${APP_DIR}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_DIR}"
SectionEnd

