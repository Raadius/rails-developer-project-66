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
make prepare-local 
```

### Переменные окружения

Скопируй `.env.example` в `.env` и заполни:

```bash
cp .env.example .env
```

| Переменная | Описание |
|---|---|
| `GITHUB_CLIENT_ID` | OAuth App ID — [github.com/settings/applications/new](https://github.com/settings/applications/new) |
| `GITHUB_CLIENT_SECRET` | OAuth App Secret — там же |
| `BASE_URL` | Домен приложения. Локально — адрес ngrok (например `abc123.ngrok-free.app`) |
| `SMTP_USER` | SMTP username из Mailtrap — [mailtrap.io](https://mailtrap.io) → Inboxes → SMTP Settings |
| `SMTP_PASSWORD` | SMTP password из Mailtrap — там же |

> Email-уведомления в development настроены на Mailtrap. Письма перехватываются и не уходят реальным получателям.

### Запуск

```bash
rails s
```

Приложение будет доступно на `http://localhost:3000`.

### Тесты

```bash
make run-tests
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
   2. Укажи команду сборки: `make render-build`
   3. Укажи команду запуска: `make render-start`
   4. Добавь **PostgreSQL** базу данных (или внешнюю, например [neon.tech](https://neon.tech))
   5. В **Environment Variables** добавь все переменные из `.env`, плюс:
      ```
      RAILS_ENV=production
      DATABASE_URL=...                 # строка подключения к PostgreSQL
      SECRET_KEY_BASE=...              # rails secret
      BASE_URL=your-app.onrender.com   # (без https://)
      GITHUB_CLIENT_ID=...             # айди клиента из приложения на Oauth Github
      GITHUB_CLIENT_SECRET=...         # секрет из приложения на Oauth Github (генерируется)
      SMTP_HOST=...                    # хост smtp-приложения
      SMTP_PASSWORD=...                # твой пароль из smtp
      SMTP_PORT=...                    # порт smtp
      SMTP_USER=...                    # юзернейм из smtp
      ```
   6. В **Build Command** укажи:
      ```
      make render-build
      ```
   7. Для **старта** приложения укажи:
      ```
      make render-start
      ```
