# syntax=docker/dockerfile:1

FROM node:14.15.4

ENV NODE_ENV=production

WORKDIR /app

COPY ["package.json", "package-lock.json*", "./"]

RUN npm install

COPY . .

CMD [ "node", "src/app.js" ]

