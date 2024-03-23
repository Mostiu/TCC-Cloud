FROM node:alpine

WORKDIR /app

COPY ./backend/package.json ./
COPY ./backend/package-lock.json ./

RUN npm install

COPY ./backend/ ./

EXPOSE 8081

CMD [ "node", "back.js" ]