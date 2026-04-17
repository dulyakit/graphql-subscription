FROM node:20-alpine

WORKDIR /app
RUN chown -R node:node /app

COPY --chown=node:node package*.json ./
COPY --chown=node:node yarn.lock* ./

USER node

RUN npm install

COPY --chown=node:node . .

EXPOSE 4000

CMD ["npm", "start"]