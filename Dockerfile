FROM node:20-alpine

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++ cairo-dev jpeg-dev pango-dev giflib-dev pixman-dev

# Copy backend code
COPY backend-node/package*.json ./
COPY backend-node/prisma ./prisma
COPY backend-node/tsconfig.json backend-node/nest-cli.json ./
COPY backend-node/src ./src

# Install dependencies
RUN npm install --legacy-peer-deps

# Generate Prisma
RUN npx prisma generate

# Build app
RUN npm run build

# Remove dev dependencies
RUN npm prune --omit=dev

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "dist/main.js"]
