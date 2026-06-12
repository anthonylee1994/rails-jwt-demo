# Rails JWT Demo

A small Rails API app that demonstrates username/password authentication with JWTs and user-scoped task management.

The app exposes two public auth endpoints and a protected task CRUD API. Every
task request is scoped to the authenticated user.

## Stack

- Ruby 4.0.5
- Rails 8.1.3
- SQLite
- RSpec
- JWT authentication
- Rack CORS

## Setup

```sh
bundle install
bundle exec rails db:setup
```

Run the server:

```sh
bundle exec rails server
```

Run the test suite:

```sh
bundle exec rspec
```

## Authentication

Register and login both return a JWT token. The token is signed with
`Rails.application.secret_key_base`, uses `HS256`, and expires after 24 hours.

```json
{
  "token": "jwt-token"
}
```

Use the token on task requests:

```http
Authorization: Bearer jwt-token
```

Authenticated task responses include a refreshed token in the response header:

```http
Authorization: Bearer refreshed-jwt-token
```

The CORS middleware allows all origins and exposes the `Authorization` response
header so browser clients can read refreshed tokens.

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

Unauthenticated or invalid-token requests return:

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
either `true` or `false`.

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

## Notes

- Passwords are stored with `has_secure_password`.
- JWT payloads include `sub` with the user id and `username` with the normalized username.
- Task `completed` defaults to `false`.
- Task ids and user ids are UUID strings.
- The app exposes `Authorization` through CORS for frontend refresh-token flows.
