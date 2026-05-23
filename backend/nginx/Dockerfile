# syntax=docker/dockerfile:1.7
# Multi-stage: build the React app, then copy the dist into the nginx image.
# Build context is the repo root (set in docker-compose.yml).

FROM node:22-alpine AS build
WORKDIR /app
COPY frontend-app/package.json frontend-app/package-lock.json* ./
RUN --mount=type=cache,target=/root/.npm \
    npm install --no-audit --no-fund

COPY frontend-app/. ./
RUN npm run build

FROM nginx:1.27-alpine
COPY --from=build /app/dist /usr/share/nginx/html
# nginx.conf comes in via bind mount (still editable without rebuild).
EXPOSE 80
