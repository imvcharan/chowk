# Quick Start: Render Deployment for Windows

## ⚡ 5-Minute Setup

### Step 1: Generate JWT Secret (PowerShell)
```powershell
node -e "console.log('JWT_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"
```
Copy the output - you'll need it in Step 4.

### Step 2: Push to GitHub
```powershell
cd backend-node
git add .
git commit -m "chore: prepare for Render deployment"
git push origin main
```

### Step 3: Create Database on Render
1. Go to https://dashboard.render.com
2. Click **"New"** → **"PostgreSQL"**
3. Fill in:
   - **Name:** `chowk-db`
   - **Database:** `chowk_production`
   - **User:** `chowk_user`
   - **Region:** Ohio
   - **Plan:** Free
4. Click **Create Database**
5. ⚠️ **Copy the Internal Database URL** (looks like: `postgresql://...`)

### Step 4: Create Web Service on Render
1. Click **"New"** → **"Web Service"**
2. Select your GitHub repository
3. Configure:
   - **Name:** `chowk-backend`
   - **Environment:** Node
   - **Build Command:** `npm ci && npx prisma generate && npm run build`
   - **Start Command:** `npm start`
   - **Plan:** Starter
4. Click **Create Web Service**

### Step 5: Add Environment Variables
In the Web Service:
1. Go to **Environment** tab
2. Add these variables:

| Key | Value |
|-----|-------|
| `NODE_ENV` | `production` |
| `PORT` | `3000` |
| `DATABASE_URL` | Paste from Step 3 ↑ |
| `JWT_SECRET` | Paste from Step 1 ↑ |
| `JWT_EXPIRATION` | `24h` |
| `REFRESH_TOKEN_EXPIRATION` | `7d` |
| `API_PREFIX` | `api/v1` |
| `CORS_ORIGIN` | `*` (or your frontend URL) |

3. Click **Save**

### Step 6: Deploy 🚀
The deployment starts automatically! Monitor in the **Logs** tab.

---

## ✅ Verify Deployment

### Check if running:
```powershell
# Replace with your Render URL
$url = "https://chowk-backend.onrender.com/api/v1/health"
Invoke-WebRequest -Uri $url
```

### View logs:
1. Go to Web Service → **Logs** tab
2. Look for: `NestJS application is running on port 3000`

---

## 🔧 Run Database Migrations

After first deployment:

1. Go to Web Service → **Shell** tab
2. Run:
   ```bash
   npx prisma migrate deploy
   ```

3. (Optional) Seed initial admin:
   ```bash
   npm run seed:admin
   ```

---

## 📝 Your Deployment Details

```
Frontend: https://your-frontend-domain.com
Backend API: https://chowk-backend.onrender.com
API Route Prefix: /api/v1
Database: PostgreSQL on Render
```

Update your frontend to use: `https://chowk-backend.onrender.com/api/v1`

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Build fails | Check logs, run `npm run build` locally |
| App crashes | Check `DATABASE_URL` is correct |
| Database connection error | Verify database service is running |
| CORS errors | Add frontend URL to `CORS_ORIGIN` |
| API returns 404 | Ensure `API_PREFIX=api/v1` is set |

---

## 📚 Full Documentation
See [RENDER_DEPLOYMENT.md](./RENDER_DEPLOYMENT.md) for detailed guide.
