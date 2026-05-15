FROM node:20-bookworm-slim

WORKDIR /app

ENV NODE_ENV=development \
    USER_BACKEND_ENV=dev

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --chown=node:node . .

USER node

EXPOSE 8002

CMD ["node", "src/server.js"]