FROM alpine:latest

# installation
RUN apk update \
&& apk add mariadb mariadb-client && apk add --no-cache --upgrade bash \
&& rm -rf /var/cache/apk/*

# RUN service mysql start
RUN mysql --version

COPY setup.sh .

RUN chmod +x setup.sh

CMD setup.sh