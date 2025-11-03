# Инструкция по публикации на GitHub

## Шаги для загрузки проекта на GitHub

1. **Создайте репозиторий на GitHub**
   - Перейдите на https://github.com/new
   - Введите имя репозитория (например, `iptvca`)
   - Выберите Public или Private
   - Не добавляйте README, .gitignore или LICENSE (они уже есть в проекте)

2. **Подключите локальный репозиторий к GitHub**
   ```bash
   git remote add origin https://github.com/ваш-username/iptvca.git
   ```

3. **Добавьте все файлы**
   ```bash
   git add .
   ```

4. **Создайте первый коммит**
   ```bash
   git commit -m "Initial commit"
   ```

5. **Заливайте код на GitHub**
   ```bash
   git branch -M main
   git push -u origin main
   ```

## Важные замечания

- ✅ Все секретные файлы (local.properties, .env) игнорируются
- ✅ Build папки и временные файлы исключены из репозитория
- ✅ README.md и LICENSE уже созданы

## После публикации

Не забудьте обновить ссылку на репозиторий в README.md в секции "Установка".

