FROM node:20-alpine AS build
WORKDIR /app

# Install build dependencies for native modules
RUN apk add --no-cache python3 make g++ cairo-dev jpeg-dev pango-dev giflib-dev pixman-dev

COPY package*.json ./
RUN npm ci --legacy-peer-deps

COPY prisma ./prisma
RUN npx prisma generate

COPY tsconfig.json nest-cli.json ./
COPY src ./src
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
ENV NODE_OPTIONS=""

# Install only runtime dependencies for native modules
RUN apk add --no-cache cairo jpeg pango giflib pixman

COPY package*.json ./
RUN npm ci --legacy-peer-deps --only=production && npm cache clean --force

COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=build /app/dist ./dist
COPY prisma ./prisma

EXPOSE 3000
CMD ["sh", "-c", "npx prisma generate && npx prisma migrate deploy && node dist/main.js"]