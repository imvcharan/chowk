# Chowk NestJS Backend

This is the NestJS backend for Chowk. The Flutter client uses this API; the legacy PHP API is no longer a runtime dependency. MediaMTX owns the video transport.

## Local development

1. Copy `.env.example` to `.env` or create `.env.local` and set a long `JWT_ACCESS_SECRET`.
2. Start PostgreSQL, Redis, and MediaMTX from the root Docker Compose file.
3. Install dependencies with `npm install`.
4. Generate the Prisma client with `npm run prisma:generate`.
5. Apply the schema in a development database with `npx prisma db push`.
6. Start the API with `npm run start:dev`.

For local testing, apply the schema and create the development admin account:

```powershell
$env:DATABASE_URL = "postgresql://chowk:chowk@localhost:5432/chowk?schema=public"
npx prisma db push
npm run seed:admin
```

Development admin login: `admin@chowk.local` / `Chowk@12345`.

Health check: `GET http://localhost:3001/api/v1/health`.

With Docker Compose, build and start the API with `docker compose -f ../docker-compose.dev.yml up --build api postgres redis mediamtx`. Apply the Prisma schema once from this directory with `npx prisma db push` using the PostgreSQL URL from `.env`.

## Current API

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/auth/profile`
- `GET /api/v1/news`, `GET /api/v1/news/:id`
- `GET /api/v1/search?q=...`
- `GET /api/v1/trending?limit=...`
- `GET /api/v1/categories`
- `GET /api/v1/bookmarks`, `/api/v1/comments/:id`, `/api/v1/likes/:id`
- `GET /api/v1/live`, `POST/PUT/DELETE /api/v1/live`
- `POST /api/v1/reports`, `GET /api/v1/reports`
- `GET /api/v1/user/profile`
- `POST /api/v1/media`
- `GET/POST /api/v1/admin` (compatibility actions for the existing browser admin)
- `GET/PATCH/POST/DELETE /api/v1/admin/{users,categories,articles,media}`
- `GET /api/v1/streams`
- `POST /api/v1/streams` (JWT and publisher role required)
- `PATCH /api/v1/streams/:id` (JWT and publisher role required)

The Flutter client base URL is `http://localhost:3000/api/v1` on web and desktop, and `http://10.0.2.2:3000/api/v1` on the Android emulator.

## Legacy backend status

The legacy PHP backend and its migration-only files are no longer part of this workspace. The Flutter runtime uses this NestJS backend with PostgreSQL, Redis, and MediaMTX exclusively.