FROM alpine:latest

RUN service mysql start
RUN mysql --version

COPY setup.sh .

RUN chmod +x setup.sh

CMD setup.sh