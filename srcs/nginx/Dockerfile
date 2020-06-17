FROM alpine:latest

# Install nginx and its dependencies
RUN apk update && apk add nginx && apk add openssl && apk add openssh && apk add bash

#RUN NGINX
RUN mkdir -p /var/www/html
COPY ./index.html /var/www/html/

# Create the file with the ssl key inside
RUN mkdir -p /etc/nginx/ssl && openssl req -newkey rsa:2048 -x509 -days 365 -nodes -keyout /etc/nginx/ssl/services.key -out /etc/nginx/ssl/services.pem -subj "/C=FR/ST=Paris/L=Paris/O=42, Inc./OU=IT/CN=ft_services"

# Nginnx config
RUN rm /etc/nginx/nginx.conf

COPY ./nginx.conf /etc/nginx/nginx.conf