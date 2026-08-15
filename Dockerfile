FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY backend-node/package.json backend-node/package-lock.json ./

RUN npm install

COPY backend-node/prisma ./prisma
RUN npx prisma generate

COPY backend-node/tsconfig.json backend-node/nest-cli.json ./
COPY backend-node/src ./src

RUN npm run build

EXPOSE 3000
ENV NODE_ENV=production

CMD ["node", "dist/main.js"]
