# Инструкция по созданию установщика Windows

Это руководство поможет вам создать установщик Windows для приложения IPTVCA.

## Вариант 1: MSIX установщик (Рекомендуется)

MSIX - это современный формат установщика для Windows 10/11, рекомендованный Microsoft.

### Преимущества MSIX:
- ✅ Современный формат для Windows 10/11
- ✅ Автоматические обновления
- ✅ Безопасная установка через контейнеризацию
- ✅ Простое создание

### Требования:
- Windows 10 (версия 1809 или новее) или Windows 11
- Flutter SDK установлен
- Dart SDK установлен

### Шаги:

1. **Установите зависимости:**
   ```bash
   flutter pub get
   ```

2. **Соберите приложение:**
   ```bash
   flutter build windows --release
   ```

3. **Создайте MSIX установщик:**
   ```bash
   dart run msix:create
   ```

   Или используйте автоматический скрипт:
   ```bash
   # Windows (CMD)
   build_installer.bat
   
   # Windows (PowerShell)
   .\build_installer.ps1
   ```

4. **Найдите установщик:**
   Файл `.msix` будет создан в папке `build/windows/x64/runner/Release/`

5. **Установка сертификата (ВАЖНО!):**
   
   Для установки MSIX необходимо сначала установить тестовый сертификат в систему:
   
   **Вариант A: Автоматическая установка (рекомендуется)**
   ```powershell
   # Запустите PowerShell от имени администратора
   .\install_certificate.ps1
   ```
   
   **Вариант B: Ручная установка**
   ```powershell
   # Запустите PowerShell от имени администратора
   $certPath = "build\windows\x64\runner\Release\test_certificate.pfx"
   Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\TrustedPeople
   ```

6. **Установка приложения:**
   - После установки сертификата дважды кликните на файл `.msix`
   - Кнопка "Install" должна быть активна
   - Нажмите "Install" для установки приложения

### Настройка конфигурации MSIX:

Редактируйте секцию `msix_config` в файле `pubspec.yaml`:

```yaml
msix_config:
  display_name: IPTVCA                    # Отображаемое имя приложения
  publisher_display_name: IPTVCA          # Имя издателя
  identity_name: com.iptvca.app          # Уникальный идентификатор
  publisher: CN=IPTVCA                     # Издатель (CN=Имя)
  msix_version: 1.0.0.0                    # Версия установщика (формат: X.Y.Z.W)
  logo_path: assets/icon.png              # Путь к иконке (PNG/JPG)
```

**Примечание:** В версии 3.x пакета msix некоторые поля могут иметь другой формат или не поддерживаться. Для минимальной рабочей конфигурации используйте только основные поля, показанные выше.

### Подпись установщика (для продакшена):

Для публикации в Microsoft Store или для распространения без предупреждений нужен сертификат:

1. **Создайте самоподписанный сертификат (для тестирования):**
   ```powershell
   New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=IPTVCA" -KeyExportPolicy Exportable -CertStoreLocation Cert:\CurrentUser\My
   ```

2. **Используйте сертификат в конфигурации:**
   ```yaml
   msix_config:
     certificate_path: path/to/certificate.pfx
     certificate_password: your_password
   ```

## Вариант 2: Традиционный установщик (NSIS/Inno Setup)

Если вам нужен традиционный `.exe` установщик, можно использовать NSIS или Inno Setup.

### NSIS (Nullsoft Scriptable Install System)

NSIS создает традиционный `.exe` установщик, который не требует установки сертификатов.

**Преимущества NSIS:**
- ✅ Не требует установки сертификатов
- ✅ Работает на всех версиях Windows
- ✅ Простая установка для конечного пользователя
- ✅ Возможность настройки процесса установки

**Шаги:**

1. **Установите NSIS:**
   - Скачайте с https://nsis.sourceforge.io/Download
   - Установите NSIS
   - Добавьте NSIS в PATH (обычно: `C:\Program Files (x86)\NSIS`)

2. **Создайте установщик:**

   **Автоматически (рекомендуется):**
   ```bash
   # Windows CMD
   build_nsis_installer.bat
   
   # Windows PowerShell
   .\build_nsis_installer.ps1
   ```
   
   **Вручную:**
   ```bash
   # 1. Соберите приложение
   flutter build windows --release
   
   # 2. Скомпилируйте установщик через NSIS
   makensis installer.nsi
   ```

3. **Найдите установщик:**
   Файл `IPTVCA_Setup_1.0.0.exe` будет создан в корне проекта

4. **Установка:**
   - Запустите файл `IPTVCA_Setup_*.exe`
   - Следуйте инструкциям установщика
   - Ярлыки будут созданы автоматически

**Настройка скрипта NSIS:**

Отредактируйте файл `installer.nsi` для настройки:
- Название приложения и версия
- Иконки установщика
- Пути установки
- Дополнительные опции установки

### Inno Setup

1. Установите Inno Setup: https://jrsoftware.org/isdl.php
2. Используйте мастер создания скрипта
3. Укажите папку сборки: `build\windows\x64\runner\Release`

## Решение проблем

### Ошибка: "msix не найден"
```bash
flutter pub get
```

### Ошибка: "Не удалось создать сертификат"
Для тестирования MSIX создает временный сертификат автоматически. Для продакшена создайте сертификат вручную (см. раздел "Подпись установщика").

### Ошибка: "This app package's publisher certificate could not be verified" (0x800B010A)
**Проблема:** Кнопка "Install" неактивна, появляется ошибка о сертификате.

**Решение:** Необходимо установить тестовый сертификат в систему Windows:
1. Найдите файл `test_certificate.pfx` в папке `build\windows\x64\runner\Release\`
2. Запустите PowerShell от имени администратора
3. Выполните: `.\install_certificate.ps1`
   
   Или вручную:
   ```powershell
   Import-Certificate -FilePath "build\windows\x64\runner\Release\test_certificate.pfx" -CertStoreLocation Cert:\LocalMachine\TrustedPeople
   ```
4. После установки сертификата кнопка "Install" станет активной

**Важно:** Сертификат нужно устанавливать на каждом компьютере, где будет устанавливаться приложение, или использовать доверенный сертификат от центра сертификации для продакшена.

### Установщик не создается
Убедитесь, что:
- Собрано release-приложение: `flutter build windows --release`
- Установлены все зависимости: `flutter pub get`
- Иконка существует по указанному пути в `msix_config`

## Публикация

### Microsoft Store:
1. Получите сертификат от Microsoft
2. Создайте учетную запись разработчика
3. Загрузите `.msix` через Partner Center

### Собственный сайт:
- Загрузите `.msix` файл на ваш сайт
- Пользователи могут скачать и установить его напрямую
- Для избежания предупреждений используйте подписанный сертификат

## Дополнительная информация

- [Документация MSIX](https://docs.microsoft.com/windows/msix/)
- [Пакет msix для Flutter](https://pub.dev/packages/msix)
- [Flutter Windows документация](https://docs.flutter.dev/deployment/windows)

