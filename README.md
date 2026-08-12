# Chowk

Chowk is a Flutter client backed by the NestJS API in `backend-node`.

## Active stack

- NestJS API: `http://localhost:3001/api/v1`
- PostgreSQL via Prisma
- Redis
- MediaMTX for live streaming

Start the development stack with:

```powershell
docker compose -f docker-compose.dev.yml up --build api postgres redis mediamtx
```

Run that command from `C:\xampp\htdocs\chowk`, or use the absolute path from any PowerShell directory:

```powershell
docker compose -f C:\xampp\htdocs\chowk\docker-compose.dev.yml up --build api postgres redis mediamtx
```

The legacy PHP/MySQL implementation is no longer part of the active runtime. Its schema and migration notes remain only as historical data-migration material.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
