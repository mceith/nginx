FROM centos:centos7
MAINTAINER Jura Berg <contact@mceith.com>
RUN yum install -y http://dev.centos.org/centos/7/systemd-container/systemd-container-EOL-208.21-1.el7.noarch.rpm && yum update -y && yum install -y epel-release
RUN yum install -y nginx \
    php \
    php-mysql \
    php-pecl-redis \
    php-fpm

ADD run.sh /run.sh

ENV PHP_USER nginx
ENV DOMAIN example.com
ENV OC_PORT_6379_TCP_ADDR 127.0.0.1

COPY index.php /index.php

VOLUME ["/var/www", "/var/wwwlogs", "/var/log/nginx"]

EXPOSE 80
ENTRYPOINT /run.sh
