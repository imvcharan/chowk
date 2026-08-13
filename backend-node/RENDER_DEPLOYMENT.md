# Render Cloud Deployment Guide - Chowk Backend

## Overview
This guide walks through deploying your NestJS backend to Render Cloud with PostgreSQL database.

## Prerequisites
- ✅ Render account (appdeveloperpro4@gmail.com)
- ✅ GitHub repository with your code
- ✅ Docker configured (already have Dockerfile)
- ✅ NestJS backend built and tested

---

## Step 1: Prepare Your GitHub Repository

1. **Commit all changes to GitHub:**
   ```bash
   git add .
   git commit -m "chore: prepare for Render deployment"
   git push origin main
   ```

2. **Ensure these files are in root of backend-node:**
   - `Dockerfile` ✅
   - `render.yaml` ✅
   - `package.json` ✅
   - `tsconfig.json` ✅
   - `prisma/schema.prisma` ✅

---

## Step 2: Create Render Services

### 2.1 Create PostgreSQL Database
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New"** → **"PostgreSQL"**
3. Configure:
   - **Name:** `chowk-db`
   - **Database:** `chowk_production`
   - **User:** `chowk_user`
   - **Region:** Ohio (or your preferred region)
   - **Version:** Latest stable
   - **Plan:** Free or Standard (based on needs)

4. **Save the connection string** (you'll need it for the API service)

### 2.2 Create Web Service
1. Click **"New"** → **"Web Service"**
2. Configure:
   - **Repository:** Select your GitHub repo
   - **Branch:** `main`
   - **Build Command:** `npm ci && npx prisma generate && npm run build`
   - **Start Command:** `npm start`
   - **Environment:** Node
   - **Region:** Ohio (same as database)
   - **Plan:** Starter (or paid plan)

---

## Step 3: Configure Environment Variables

In the **Web Service** settings → **Environment**:

```
NODE_ENV=production
PORT=3000
DATABASE_URL=<paste_from_database_service>
JWT_SECRET=<generate_strong_secret>
JWT_EXPIRATION=24h
REFRESH_TOKEN_EXPIRATION=7d
API_PREFIX=api/v1
CORS_ORIGIN=<your_frontend_domain>
```

### Generate Strong JWT Secret:
```bash
# Option 1: Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Option 2: Using OpenSSL
openssl rand -hex 32
```

---

## Step 4: Deploy

### Option A: Automatic Deploy (Recommended)
1. Render automatically deploys when you push to `main`
2. Monitor deployment in **Render Dashboard** → **Deployments**

### Option B: Manual Deploy
1. Go to **Web Service** → **Manual Deploy**
2. Click **"Deploy latest commit"**

---

## Step 5: Run Database Migrations

After initial deployment:

1. Go to **Web Service** → **Shell**
2. Run migrations:
   ```bash
   npx prisma migrate deploy
   ```

3. Seed initial data (if you have seed script):
   ```bash
   npm run seed:admin
   ```

---

## Step 6: Verify Deployment

1. **Check logs:**
   - Go to **Web Service** → **Logs**
   - Look for: `NestJS application is running on port 3000`

2. **Test API health:**
   ```bash
   curl https://your-render-url.onrender.com/api/v1/health
   ```

3. **Test database connection:**
   - Check logs for successful Prisma connection

---

## Environment Variables Reference

| Variable | Example | Notes |
|----------|---------|-------|
| `NODE_ENV` | `production` | Required |
| `PORT` | `3000` | Render assigns automatically |
| `DATABASE_URL` | `postgresql://...` | From database service |
| `JWT_SECRET` | `<random_hex>` | Generate strong secret |
| `JWT_EXPIRATION` | `24h` | Token expiration time |
| `REFRESH_TOKEN_EXPIRATION` | `7d` | Refresh token lifetime |
| `API_PREFIX` | `api/v1` | API route prefix |
| `CORS_ORIGIN` | `https://your-frontend.com` | Frontend domain |

---

## Troubleshooting

### Deployment Fails
- Check **Logs** for errors
- Verify `Dockerfile` is correct
- Ensure `package.json` has all dependencies

### Database Connection Failed
- Verify `DATABASE_URL` is correct
- Check database service is running
- Ensure credentials are accurate

### Build Fails
- Run `npm ci && npm run build` locally to test
- Check `tsconfig.json` is valid
- Verify all dependencies are listed in `package.json`

### Application Crashes
- Check **Logs** for error messages
- Verify environment variables are set
- Ensure Prisma migrations ran successfully

---

## Useful Commands

```bash
# View build logs
curl https://api.render.com/v1/services/{SERVICE_ID}/events

# Test API locally before deploying
npm run start:dev

# Build for production
npm run build

# Run Prisma studio
npx prisma studio
```

---

## Security Checklist

- ✅ JWT_SECRET is strong and unique
- ✅ DATABASE_URL is not hardcoded
- ✅ CORS_ORIGIN is set to your frontend domain
- ✅ Environment variables are secrets in Render dashboard
- ✅ Database backups are configured (if using paid plan)
- ✅ SSL/TLS is enabled (Render does this automatically)

---

## Next Steps After Deployment

1. Update frontend API endpoint to Render URL
2. Configure custom domain (optional)
3. Set up monitoring and alerts
4. Configure automatic scaling (if needed)
5. Set up CI/CD pipeline for auto-deployment

---

## Support & Docs

- [Render Docs](https://render.com/docs)
- [Prisma Database Guide](https://www.prisma.io/docs/orm/overview/databases)
- [NestJS Deployment](https://docs.nestjs.com/deployment)
