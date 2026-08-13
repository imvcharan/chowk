#!/bin/bash
# Render Deployment Quick Setup Script
# Run this to prepare your backend for Render Cloud deployment

echo "🚀 Chowk Backend - Render Deployment Setup"
echo "==========================================="
echo ""

# 1. Check if git is initialized
if [ ! -d .git ]; then
    echo "❌ Git not initialized. Run: git init"
    exit 1
fi

# 2. Check if render.yaml exists
if [ ! -f render.yaml ]; then
    echo "❌ render.yaml not found"
    exit 1
fi

# 3. Verify package.json
if [ ! -f package.json ]; then
    echo "❌ package.json not found"
    exit 1
fi

echo "✅ Git repository found"
echo "✅ render.yaml found"
echo "✅ package.json found"
echo ""

# 4. Test build locally
echo "Testing production build..."
npm run build
if [ $? -ne 0 ]; then
    echo "❌ Build failed. Fix errors before deploying."
    exit 1
fi
echo "✅ Build successful"
echo ""

# 5. Verify Dockerfile
if [ ! -f Dockerfile ]; then
    echo "❌ Dockerfile not found"
    exit 1
fi
echo "✅ Dockerfile found"
echo ""

# 6. Generate JWT Secret
echo "📝 Generating JWT Secret..."
JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
echo "Generated JWT_SECRET: $JWT_SECRET"
echo ""
echo "⚠️  IMPORTANT: Add this to your Render Environment Variables:"
echo "   KEY: JWT_SECRET"
echo "   VALUE: $JWT_SECRET"
echo ""

# 7. Instructions
echo "📋 Next Steps:"
echo "1. Commit and push all changes to GitHub:"
echo "   git add ."
echo "   git commit -m 'chore: prepare for Render deployment'"
echo "   git push origin main"
echo ""
echo "2. Go to Render Dashboard: https://dashboard.render.com"
echo ""
echo "3. Create PostgreSQL Database:"
echo "   - New → PostgreSQL"
echo "   - Name: chowk-db"
echo "   - Database: chowk_production"
echo "   - Region: Ohio"
echo "   - Save the connection string"
echo ""
echo "4. Create Web Service:"
echo "   - New → Web Service"
echo "   - Connect GitHub repository"
echo "   - Build Command: npm ci && npx prisma generate && npm run build"
echo "   - Start Command: npm start"
echo ""
echo "5. Add Environment Variables in Render:"
echo "   - DATABASE_URL: <from database service>"
echo "   - JWT_SECRET: $JWT_SECRET"
echo "   - NODE_ENV: production"
echo "   - PORT: 3000"
echo ""
echo "6. Deploy!"
echo ""
echo "✅ Setup complete! Follow the instructions above to deploy."
