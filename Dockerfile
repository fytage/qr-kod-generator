# Stage 1: Build (Zero-CVE hardened Node image from Chainguard)
FROM cgr.dev/chainguard/node:latest-dev AS build

WORKDIR /app

# Ensure proper permissions for the non-root node user in Chainguard
COPY --chown=node:node package.json package-lock.json* ./
RUN npm ci

COPY --chown=node:node . .
RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine AS production

# Upgrade Alpine system packages to resolve any base image CVEs
RUN apk upgrade --no-cache

# Copy built assets
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
