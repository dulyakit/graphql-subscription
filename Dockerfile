# 1. Base Stage
FROM docker.io/oven/bun:alpine AS base
WORKDIR /usr/src/app
COPY . .

# 2. Dev Dependencies
FROM base AS dev-dependencies
RUN bun install --ignore-scripts

# 3. Unit Test Stage (เป้าหมายสำหรับสแกน)
# FROM dev-dependencies AS unit-test
# RUN bun run test:unit

# 4. Integration Test Stage (เป้าหมายสำหรับสแกน)
# FROM dev-dependencies AS integration-test
# ENV MONGO_URL=mongodb://localhost:27017/testdb
# RUN bun run test:integration

# 5. Builder Stage
FROM dev-dependencies AS builder
RUN bun run build

# 6. Production Dependencies
FROM base AS production-dependencies 
RUN bun install --production --ignore-scripts

# 7. Release Stage
FROM node:22.18-alpine AS release
WORKDIR /usr/src/app
ENV NODE_ENV=production
COPY --from=builder /usr/src/app/dist dist
COPY --from=builder /usr/src/app/package.json package.json
COPY --from=production-dependencies /usr/src/app/node_modules node_modules

CMD ["node", "dist/server.js"]