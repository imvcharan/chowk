FROM node:20-alpine

# Fresh build - no cache
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++ cairo-dev jpeg-dev pango-dev giflib-dev pixman-dev

# Copy npm config
COPY .npmrc ./
COPY backend-node/.npmrc ./

# Copy backend code
COPY backend-node/package*.json ./
COPY backend-node/prisma ./prisma
COPY backend-node/tsconfig.json backend-node/nest-cli.json ./
COPY backend-node/src ./src

# Install dependencies with force flag
RUN npm install --force && npm cache clean --force

# Generate Prisma
RUN npx prisma generate

# Build app
RUN npm run build

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "dist/main.js"]
