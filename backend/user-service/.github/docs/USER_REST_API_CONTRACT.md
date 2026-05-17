# User Service REST API Contract

## Service Metadata
- Service: User Service
- Framework: Express.js
- Base API mount: `/api/v1/users`

## Authentication Contract
- Header: `Authorization: Bearer <jwt>`
- JWT secret: `JWT_SECRET_KEY`
- JWT payload fields consumed by middleware:
  - `userId`
  - `role`
- Protected endpoints require:
  - valid JWT
  - existing user

## Rate Limiting Contract
- Global limiter on `/api`: 100 requests / 15 minutes
- Auth limiter on selected auth routes: 10 requests / 15 minutes
- Forgot/reset limiter on selected routes: 3 requests / hour
- Exceeded limit response: `429` with API error format

## Content Type
- Request: `application/json`
- Response: `application/json`

## Endpoint Contract
All paths below are relative to `/api/v1/users`.

### POST /register
- Auth: Public
- Middleware: `authLimiter`, `registerValidator`
- Request body:
```json
{
  "email": "user@example.com",
  "password": "StrongPass1!",
  "passwordConfirm": "StrongPass1!",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+12125550123",
  "role": "learner|instructor",
  "dateOfBirth": "YYYY-MM-DD",
  "street": "string",
  "city": "string",
  "state": "string",
  "country": "US",
  "zipCode": "string"
}
```
- Response 201:
```json
{
  "status": "success",
  "message": "User registered successfully."
}
```

### POST /login
- Auth: Public
- Middleware: `authLimiter`, `loginValidator`
- Request body:
```json
{
  "email": "user@example.com",
  "password": "StrongPass1!"
}
```
- Response 200:
```json
{
  "status": "success",
  "data": {
    "_id": "mongo-id",
    "email": "user@example.com",
    "role": "learner|instructor",
    "profile": {
      "firstName": "John",
      "lastName": "Doe",
      "phone": "+12125550123",
      "avatar": "http://.../media/users/default-avatar.jpg",
      "dateOfBirth": "datetime"
    },
    "address": {
      "street": "string",
      "city": "string",
      "state": "string",
      "country": "US",
      "zipCode": "string"
    },
    "lastLogin": "datetime"
  },
  "token": "jwt"
}
```

### GET /me
- Auth: Private (`protect` middleware)
- Response 200:
```json
{
  "status": "success",
  "data": {
    "_id": "mongo-id",
    "email": "user@example.com",
    "role": "learner|instructor",
    "profile": {
      "firstName": "John",
      "lastName": "Doe",
      "phone": "+12125550123",
      "avatar": "http://...",
      "dateOfBirth": "datetime"
    },
    "address": {
      "street": "string",
      "city": "string",
      "state": "string",
      "country": "US",
      "zipCode": "string"
    }
  }
}
```

### PUT /update-me
- Auth: Private
- Middleware: `updateMeValidator`
- Request body: any subset of profile/address fields
```json
{
  "firstName": "string",
  "lastName": "string",
  "phone": "+12125550123",
  "dateOfBirth": "YYYY-MM-DD",
  "street": "string",
  "city": "string",
  "state": "string",
  "country": "US",
  "zipCode": "string"
}
```
- Response 200:
```json
{
  "status": "success",
  "data": {
    "_id": "mongo-id",
    "email": "user@example.com",
    "role": "learner|instructor"
  }
}
```

## Error Contract

### Validation errors
- Status: `400`
- Shape:
```json
{
  "errors": [
    {
      "type": "field",
      "msg": "Validation error message",
      "path": "fieldName",
      "location": "body|params"
    }
  ]
}
```

### API/business/auth errors
- Status: varies (`400`, `401`, `403`, `404`, `429`, `500`)
- Shape (production):
```json
{
  "status": "fail|error",
  "message": "Human-readable message"
}
```
