FROM node:20.19.0-bookworm-slim AS deps

WORKDIR /app

ENV NODE_ENV=dev \
	USER_BACKEND_ENV=dev

COPY package*.json ./

RUN npm ci --omit=dev && npm cache clean --force

FROM node:20.19.0-bookworm-slim AS runtime

WORKDIR /app

ENV NODE_ENV=dev \
	USER_BACKEND_ENV=dev

COPY --from=deps /app/node_modules ./node_modules

COPY . .

RUN chown -R node:node /app

USER node

EXPOSE 8002

CMD ["node", "src/server.js"]
