### Статус Github Actions:
[![Actions Status](https://github.com/Raadius/rails-developer-project-66/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Raadius/rails-developer-project-66/actions)

# Анализатор качества репозиториев

Приложение доступно по этому URL: https://quiality-app.onrender.com/

Веб-приложение для автоматической проверки качества кода в GitHub-репозиториях. Подключи свой репозиторий — и при каждом push сервис запустит линтер, сохранит результат и пришлёт письмо, если нашлись нарушения.

## Возможности

- Авторизация через GitHub (OAuth)
- Добавление Ruby и JavaScript репозиториев из своего GitHub-аккаунта
- Ручной запуск проверки через интерфейс
- Автоматическая проверка при push через GitHub Webhooks
- Проверка Ruby-кода с помощью RuboCop
- Проверка JavaScript-кода с помощью ESLint
- Просмотр детального отчёта: список файлов, нарушений, строки
- Ссылки на файлы и коммиты прямо на GitHub
- Email-уведомление при наличии ошибок

## Как это работает

1. Пользователь входит через GitHub и добавляет репозиторий
2. При добавлении автоматически устанавливается webhook на GitHub
3. При каждом `git push` GitHub отправляет событие на `POST /api/checks`
4. Сервис клонирует репозиторий во временную папку и запускает линтер (RuboCop или ESLint — в зависимости от языка)
5. Результат сохраняется, временная папка удаляется
6. Если есть нарушения — пользователь получает письмо на email

## Стек

- **Ruby on Rails 7.2**, Slim, simple_form, Bootstrap 5
- **PostgreSQL** (production), SQLite (development)
- **Octokit** — работа с GitHub API
- **AASM** — машина состояний для проверок (pending → running → finished/failed)
- **dry-container** — dependency injection (подмена клиентов/линтеров в тестах)
- **RuboCop** / **ESLint** — линтеры
- **Pundit** — авторизация
- **WebMock** — блокировка HTTP в тестах

## Локальная разработка

### Требования

- Ruby 3.x
- Node.js + Yarn
- SQLite3

### Установка

```bash
git clone https://github.com/Raadius/rails-developer-project-66.git
cd rails-developer-project-66

bundle install
yarn install

cp .env.example .env  # заполни переменные (см. ниже)

rails db:setup
rails assets:precompile  # или: yarn build && yarn build:css
```

### Переменные окружения

Создай файл `.env` в корне проекта:

```
# GitHub OAuth (https://github.com/settings/applications/new)
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret

# Внешний адрес для webhooks (только при использовании ngrok)
BASE_URL=abc123.ngrok-free.app

# Email (Mailtrap — https://mailtrap.io, вкладка SMTP Settings)
MAILTRAP_USER=your_mailtrap_username
MAILTRAP_PASSWORD=your_mailtrap_password
```

### Запуск

```bash
rails server
```

Приложение будет доступно на `http://localhost:3000`.

### Тесты

```bash
rails test
```

### Webhooks в локальной разработке

Чтобы GitHub мог слать webhooks на локальный сервер, нужен HTTP-туннель:

```bash
# Установка
brew install ngrok/ngrok/ngrok

# Запуск туннеля
ngrok http 3000
```

Скопируй выданный адрес (например `abc123.ngrok-free.app`) в `.env`:
```
BASE_URL=abc123.ngrok-free.app
```

И перезапусти сервер. Теперь при добавлении репозитория webhook будет установлен с правильным URL.

## Деплой на Render

1. Создай новый **Web Service**, подключи репозиторий
2. Укажи команду запуска: `bundle exec rails server -p $PORT`
3. Добавь **PostgreSQL** базу данных (или внешнюю, например [neon.tech](https://neon.tech))
4. В **Environment Variables** добавь все переменные из `.env`, плюс:
   ```
   RAILS_ENV=production
   DATABASE_URL=...        # строка подключения к PostgreSQL
   SECRET_KEY_BASE=...     # rails secret
   BASE_URL=your-app.onrender.com
   ```
5. В **Build Command** укажи:
   ```
   bundle install && yarn install && yarn build && yarn build:css && rails assets:precompile && rails db:migrate
   ```
