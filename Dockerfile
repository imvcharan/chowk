FROM node:20-alpine AS build
WORKDIR /app

# Install build dependencies for native modules
RUN apk add --no-cache python3 make g++ cairo-dev jpeg-dev pango-dev giflib-dev pixman-dev

COPY backend-node/package*.json ./
RUN npm ci --legacy-peer-deps

COPY backend-node/prisma ./prisma
RUN npx prisma generate

COPY backend-node/tsconfig.json backend-node/nest-cli.json ./
COPY backend-node/src ./src
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
ENV NODE_OPTIONS=""

# Install only runtime dependencies for native modules
RUN apk add --no-cache cairo jpeg pango giflib pixman

COPY backend-node/package*.json ./
RUN npm ci --legacy-peer-deps --only=production && npm cache clean --force

COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=build /app/dist ./dist
COPY backend-node/prisma ./prisma

EXPOSE 3000
CMD ["node", "dist/main.js"]
