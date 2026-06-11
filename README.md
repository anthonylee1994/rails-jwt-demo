# Rails JWT Demo

A small Rails API app that demonstrates username/password authentication with JWTs and user-scoped task management.

## Stack

- Ruby 4.0.5
- Rails 8.1.3
- SQLite
- RSpec
- JWT authentication

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

Register and login both return a JWT token:

```json
{
  "token": "jwt-token"
}
```

Use the token on task requests:

```http
Authorization: Bearer jwt-token
```

### Register

```sh
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"anthony","password":"password123"}'
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

All task endpoints require `Authorization: Bearer <token>`. Tasks are scoped to the logged-in user.

### List Tasks

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

`completed` defaults to `false`.

```sh
curl -X POST http://localhost:3000/tasks \
  -H "Authorization: Bearer jwt-token" \
  -H "Content-Type: application/json" \
  -d '{"name":"Build API"}'
```

### Update Task

```sh
curl -X PUT http://localhost:3000/tasks/:id \
  -H "Authorization: Bearer jwt-token" \
  -H "Content-Type: application/json" \
  -d '{"name":"Ship API","completed":true}'
```

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
| GET    | `/tasks`         | Yes  | List current user's tasks  |
| GET    | `/tasks/:id`     | Yes  | Show current user's task   |
| POST   | `/tasks`         | Yes  | Create current user's task |
| PUT    | `/tasks/:id`     | Yes  | Update current user's task |
| DELETE | `/tasks/:id`     | Yes  | Delete current user's task |

## Notes

- Passwords are stored with `has_secure_password`.
- JWTs are signed with `Rails.application.secret_key_base`.
- Task `completed` defaults to `false`.
