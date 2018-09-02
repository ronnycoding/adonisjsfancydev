FROM node:latest

RUN npm i -g @adonisjs/cli \
    && npm i --save pg sqlite3 mysql @adonisjs/ignitor

WORKDIR /var/www

RUN adonis new .

ENV HOST=0.0.0.0

ENV PORT=80

CMD ["adonis","serve","--dev"]