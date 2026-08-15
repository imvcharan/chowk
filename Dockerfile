FROM node:18-alpine

# Force cache invalidation - 2026-08-15 5:55PM
WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY backend-node/package.json backend-node/package-lock.json ./

RUN npm install --legacy-peer-deps --no-audit --no-fund

COPY backend-node/prisma ./prisma
RUN npx prisma generate

COPY backend-node/tsconfig.json backend-node/nest-cli.json ./
COPY backend-node/src ./src

RUN npm run build

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "dist/main.js"]
