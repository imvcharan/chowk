FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY backend-node/package*.json ./

RUN npm ci --legacy-peer-deps --no-audit --no-fund

COPY backend-node/prisma ./prisma
RUN npx prisma generate

COPY backend-node/tsconfig.json backend-node/nest-cli.json ./
COPY backend-node/src ./src

RUN npm run build

EXPOSE 3000
ENV NODE_ENV=production

CMD ["node", "dist/main.js"]
