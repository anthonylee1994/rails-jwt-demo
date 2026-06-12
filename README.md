# Rails JWT Demo

A small Rails API app that demonstrates username/password authentication with JWTs and user-scoped task management.

The app exposes two public auth endpoints and a protected task CRUD API. Every
task request is scoped to the authenticated user.

Live demo: https://lane-api.on99.app/

## Stack

- Ruby 4.0.5
- Rails 8.1.3
- SQLite (with separate primary / cache / queue / cable databases)
- RSpec
- JWT authentication (HS256, 24h expiry)
- Rack CORS
- Solid Queue / Solid Cache / Solid Cable
- Kamal for deployment
- RuboCop (rubocop-rails-omakase) + Brakeman + bundler-audit

## Setup

```sh
bundle install
bundle exec rails db:setup
```

Run the server:

```sh
bundle exec rails server
```

For the local server, the examples below use `http://localhost:3000`.

## Test & Lint

```sh
bundle exec rspec           # Run the test suite
bundle exec rubocop         # Omakase Ruby styling
bundle exec brakeman        # Security static analysis
bundle exec bundler-audit   # Gem vulnerability check
```

## Project Layout

```
app/
  controllers/
    application_controller.rb   # JWT auth filter + sliding-session header refresh
    auth_controller.rb         # /auth/register, /auth/login
    tasks_controller.rb        # User-scoped task CRUD
  models/
    user.rb                    # username format + has_secure_password, owns #token
    task.rb                    # scoped to user, boolean completed
  services/
    json_web_token.rb          # Thin wrapper around the `jwt` gem
```

## Authentication

Register and login both return a JWT token. The token is signed with
`Rails.application.secret_key_base`, uses `HS256`, and expires after 24 hours.

```json
{
  "token": "jwt-token"
}
```

Use the token on task requests. The `Bearer` prefix is required — anything else
returns `401 Unauthorized`:

```http
Authorization: Bearer jwt-token
```

Authenticated task responses include a refreshed token in the response header
(sliding session — keep using the most recent token from the response):

```http
Authorization: Bearer refreshed-jwt-token
```

The CORS middleware allows two origins (production frontend + local dev) and
exposes the `Authorization` response header so browser clients can read
refreshed tokens:

- `https://lane.on99.app` (production frontend)
- `http://localhost:5173` (local dev)

### Register

```sh
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"anthony","password":"password123"}'
```

Usernames are normalized to lowercase and must match this format:

- 5 to 20 characters
- starts and ends with a letter or number
- may contain letters, numbers, `.`, `_`, and `-`

Passwords must be at least 8 characters.

Validation errors return `422 Unprocessable Content`:

```json
{
  "errors": ["Username can't be blank"]
}
```

### Login

```sh
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"anthony","password":"password123"}'
```

Invalid credentials return:

```json
{
  "error": "Invalid username or password"
}
```

## Tasks

All task endpoints require `Authorization: Bearer <token>`. Tasks are scoped to the logged-in user, so users cannot list, show, update, or delete another user's tasks.

Unauthenticated, expired, or otherwise invalid tokens return:

```json
{
  "error": "Unauthorized"
}
```

Looking up another user's task through `/tasks/:id` returns `404 Not Found`.

Task JSON uses this shape:

```json
{
  "id": "uuid",
  "name": "Build API",
  "completed": false,
  "user_id": "user-uuid",
  "created_at": "2026-06-11T00:00:00.000Z",
  "updated_at": "2026-06-11T00:00:00.000Z"
}
```

### List Tasks

Tasks are returned newest first.

```sh
curl http://localhost:3000/tasks \
  -H "Authorization: Bearer jwt-token"
```

### Show Task

```sh
curl http://localhost:3000/tasks/:id \
  -H "Authorization: Bearer jwt-token"
```

### Create Task

`completed` defaults to `false`. `name` is required, and `completed` must be
either `true` or `false` (omitting it returns `422`).

```sh
curl -X POST http://localhost:3000/tasks \
  -H "Authorization: Bearer jwt-token" \
  -H "Content-Type: application/json" \
  -d '{"name":"Build API"}'
```

### Update Task

Only `name` and `completed` are accepted.

```sh
curl -X PUT http://localhost:3000/tasks/:id \
  -H "Authorization: Bearer jwt-token" \
  -H "Content-Type: application/json" \
  -d '{"name":"Ship API","completed":true}'
```

`PATCH /tasks/:id` is also available through Rails resource routing.

### Delete Task

```sh
curl -X DELETE http://localhost:3000/tasks/:id \
  -H "Authorization: Bearer jwt-token"
```

## API Summary

| Method | Path             | Auth | Description                |
| ------ | ---------------- | ---- | -------------------------- |
| POST   | `/auth/register` | No   | Create user and return JWT |
| POST   | `/auth/login`    | No   | Login and return JWT       |
| GET    | `/up`            | No   | Rails health check         |
| GET    | `/tasks`         | Yes  | List current user's tasks  |
| GET    | `/tasks/:id`     | Yes  | Show current user's task   |
| POST   | `/tasks`         | Yes  | Create current user's task |
| PUT    | `/tasks/:id`     | Yes  | Update current user's task |
| PATCH  | `/tasks/:id`     | Yes  | Update current user's task |
| DELETE | `/tasks/:id`     | Yes  | Delete current user's task |

## Deploy

The project ships with a `Dockerfile` and `config/deploy.yml` for [Kamal](https://kamal-deploy.org).
Persistent state (the SQLite databases) lives under `storage/` and is mounted
as a Docker volume in `config/deploy.yml`.

```sh
kamal setup    # First-time deploy
kamal deploy   # Subsequent deploys
kamal logs     # Tail production logs
```

## Notes

- Passwords are stored with `has_secure_password` (bcrypt, min 8 chars).
- JWT payloads include `sub` with the user id and `username` with the normalized username.
- The `Authorization` request header must be prefixed with `Bearer `; tokens without the prefix are rejected.
- Task `completed` defaults to `false` and must be `true` or `false` (not `nil`).
- Task ids and user ids are UUID v7 strings.
- The app exposes `Authorization` through CORS for frontend refresh-token flows.
- CORS is restricted to `https://lane.on99.app` and `http://localhost:5173`. Add new origins to `config/initializers/cors.rb`.
