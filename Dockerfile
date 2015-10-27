FROM centos:centos7
MAINTAINER Jura Berg <contact@mceith.com>
RUN yum update -y && yum install -y epel-release
RUN yum install -y nginx \
    php \
    php-mysql \
    php-pecl-redis \
    php-fpm
ADD run.sh /run.sh

RUN mkdir -p /var/www/example.com/public_html
COPY index.php /var/www/example.com/public_html/index.php

ENV PHP_USER nginx
ENV DOMAIN example.com
ENV OC_PORT_6379_TCP_ADDR 127.0.0.1

VOLUME ["/var/www/example.com/public_html", "/var/wwwlogs", "/var/log/nginx"]

EXPOSE 80
ENTRYPOINT /run.sh
