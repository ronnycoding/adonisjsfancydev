# [Docker image for Adonisjs developers (ronnf89/adonisjsfancydev)](https://hub.docker.com/r/ronnf89/adonisjsfancydev/)

This image extends [node:latest](https://hub.docker.com/_/node/) oficial image and adds:
- [Adonis CLI](https://github.com/adonisjs/adonis-cli)
- [adonisjs/ignitor](https://github.com/adonisjs/adonis-ignitor)
- [node-postgres](https://www.npmjs.com/package/pg)
- [sqlite3](https://www.npmjs.com/package/sqlite3)
- [mysql](https://www.npmjs.com/package/mysql)

# How to use this image
The basic pattern for starting an Adonisjs instance is:
```sh
$ docker run --name some-adonisjs -d ronnf89/adonisjsfancydev
```
If you'd like to be able to access the instance from the host without the container's IP, standard port mappings can be used:
```sh
$ docker run --name some-adonisjs -p 8080:80 -d ronnf89/adonisjsfancydev
```
Then, access it via http://localhost:8080 or http://host-ip:8080 in a browser.

There are multiple database types supported by this image, most easily used via standard container linking. In the default configuration, SQLite can be used to avoid a second container and write to flat-files. More detailed instructions for different (more production-ready) database types follow.

When first accessing the webserver provided by this image, it will go through a brief setup process. The details provided below are specifically for the "Set up database" step of that configuration process.

# Adonisjs CLI
By default, this image includes composer. Run Adonis CLI into a running container as the following command:

```sh
$ docker exec CONTAINER_ID adonis --help
```

# MySQL
```sh
$ docker run --name some-adonisjs --link some-mysql:mysql -d ronnf89/adonisjsfancydev
```
- Database type: MySQL, MariaDB, or equivalent
- Database name/username/password: <details for accessing your MySQL instance> (MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE; see environment variables in the description for mysql)
- ADVANCED OPTIONS; Database host: mysql (for using the /etc/hosts entry added by --link to access the linked container's MySQL instance)

# PostgreSQL
```sh
$ docker run --name some-adonisjs --link some-postgres:postgres -d ronnf89/adonisjsfancydev
```
- Database type: PostgreSQL
- Database name/username/password: <details for accessing your PostgreSQL instance> (POSTGRES_USER, POSTGRES_PASSWORD; see environment variables in the description for postgres)
- ADVANCED OPTIONS; Database host: postgres (for using the /etc/hosts entry added by --link to access the linked container's PostgreSQL instance)

# Volumes
By default, this image does not include any volumes.

This can be bind-mounted into a new container:

```sh
$ docker run --name some-adonisjs --link some-postgres:postgres -d \
    -v /path/on/host/app:/var/www/app \
    -v /path/on/host/config:/var/www/config \
    -v /path/on/host/database:/var/www/database \
    -v /path/on/host/public:/var/www/public \
    -v /path/on/host/resources:/var/www/resources \
    -v /path/on/host/start:/var/www/start \
    ronnf89/adonisjsfancydev
```

# [Docker Compose](https://github.com/docker/compose)

- add .env file at the root of your project with the following lines

```sh
DOMAIN=adonisjs
HOST=0.0.0.0
PORT=80
NODE_ENV=development
APP_URL=http://${HOST}:${PORT}
CACHE_VIEWS=false
APP_KEY=[YOUR APP KEY GENERATED BY COMMAND "adonis key:generate"]
DB_CONNECTION=pg
DB_HOST=db
DB_PORT=5432
DB_USER=adonis
DB_PASSWORD=adonis
DB_DATABASE=adonis
SESSION_DRIVER=cookie
HASH_DRIVER=bcrypt
```

- add docker-compose.yml file at the root of your project with the following lines.

```sh
version: '3.1'

networks:
  adonisjs:
    external: false

services:
  traefik:
    container_name: ${DOMAIN}-traefik
    image: traefik
    command: --web --docker --docker.domain=${DOMAIN}.localhost --logLevel=DEBUG
    ports:
      - "82:80"
      - "8082:8080"
      - "8028:8025"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /dev/null:/traefik.toml
    networks:
      - adonisjs

  app:
    container_name: ${DOMAIN}-adonisjs
    image: ronnf89/adonisjsfancydev
    volumes:
      - .:/var/www
      - /var/www/node_modules
    labels:
      - "traefik.backend=app-${DOMAIN}"
      - "traefik.frontend.rule=Host:app.${DOMAIN}.localhost"
    restart: always
    depends_on:
      - postgres
    networks:
      - adonisjs

  postgres:
    container_name: ${DOMAIN}-postgres
    image: postgres:10
    environment:
      - POSTGRES_PGDATA=/var/lib/postgresql/data/pgdata
      - POSTGRES_USER=${DB_USERNAME}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_DATABASE}
    restart: always
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    networks:
      - adonisjs
    labels:
      - "traefik.enable=false"

  adminer:
    container_name: ${DOMAIN}-adminer
    image: adminer
    restart: always
    links:
      - postgres
    labels:
      - "traefik.backend=adminer-${DOMAIN}"
      - "traefik.frontend.rule=Host:adminer.${DOMAIN}.localhost"
      - "traefik.port=8080"
    networks:
      - adonisjs
    
  mailhog:
    container_name: ${DOMAIN}-mailhog
    image: mailhog/mailhog
    labels:
      - "traefik.backend=mail-${DOMAIN}"
      - "traefik.frontend.rule=Host:mail.${DOMAIN}.localhost"
      - "traefik.port=8025"
    networks:
      - adonisjs
  
volumes:
  db:
    driver: local
```

- Run command at your project root:
```sh
$ docker-compose up -d
```

Now you can access to your differents container services.

- Adonisjs: http://app.adonisjs.localhost:82/
- Adminer: http://adminer.adonisjs.localhost:82/
- Mailhog: http://mail.adonisjs.localhost:82/
- Traefik: http://localhost:8082/dashboard/


Thanks for read me, please share me to your adonisjs community.

License
----

MIT


**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)


   [dill]: <https://github.com/joemccann/dillinger>
   [git-repo-url]: <https://github.com/joemccann/dillinger.git>
   [john gruber]: <http://daringfireball.net>
   [df1]: <http://daringfireball.net/projects/markdown/>
   [markdown-it]: <https://github.com/markdown-it/markdown-it>
   [Ace Editor]: <http://ace.ajax.org>
   [node.js]: <http://nodejs.org>
   [Twitter Bootstrap]: <http://twitter.github.com/bootstrap/>
   [jQuery]: <http://jquery.com>
   [@tjholowaychuk]: <http://twitter.com/tjholowaychuk>
   [express]: <http://expressjs.com>
   [AngularJS]: <http://angularjs.org>
   [Gulp]: <http://gulpjs.com>

   [PlDb]: <https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md>
   [PlGh]: <https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md>
   [PlGd]: <https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md>
   [PlOd]: <https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md>
   [PlMe]: <https://github.com/joemccann/dillinger/tree/master/plugins/medium/README.md>
   [PlGa]: <https://github.com/RahulHP/dillinger/blob/master/plugins/googleanalytics/README.md>