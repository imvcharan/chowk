FROM node:20-alpine
WORKDIR /app

RUN apk add --no-cache python3 make g++ cairo-dev jpeg-dev pango-dev giflib-dev pixman-dev

COPY backend-node/package*.json ./
RUN npm install --legacy-peer-deps --no-audit --no-fund

COPY backend-node/prisma ./prisma
RUN npx prisma generate

COPY backend-node/tsconfig.json backend-node/nest-cli.json ./
COPY backend-node/src ./src
RUN npm run build

ENV NODE_ENV=production
ENV NODE_OPTIONS=""
EXPOSE 3000

CMD ["sh", "-c", "npx prisma generate && npx prisma migrate deploy && node dist/main.js"]
