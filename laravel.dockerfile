#FROM composer:latest as composer

#ENV APP_KERNEL_NAMESPACE=App\Http
#ARG version=dev-master
#ARG http_version=dev-master


#${version} :${http_version}

FROM ubuntu:18.10

ARG DEBIAN_FRONTEND=noninteractive

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
#ENV APP_KERNEL_NAMESPACE=App\Http

RUN apt-get update -yqq && apt-get install -yqq software-properties-common > /dev/null
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -yqq > /dev/null && \
    apt-get install -yqq nginx git unzip php7.3 php7.3-common php7.3-cgi php7.3-cli php7.3-fpm php7.3-mysql   > /dev/null
RUN apt-get install -yqq php7.3-mbstring php7.3-xml  > /dev/null

RUN apt-get install -yqq composer > /dev/null

#COPY deploy/conf/* /etc/php/7.3/fpm/
#COPY deploy/conf/php.ini /etc/php/7.3/cgi/



ADD ./ /laravel
WORKDIR /laravel

ADD etc/php.ini /etc/php7/php.ini
ADD etc/php.ini /etc/php7.3/php.ini
COPY etc/php.ini /etc/php/7.3/cgi/
COPY etc/php.ini /etc/php7.3/cgi/

ADD etc/nginx_default.conf /etc/nginx/sites-enabled/default
ADD etc/nginx.conf /etc/nginx/nginx.conf

RUN mkdir /ppm && cd /ppm && composer require php-pm/php-pm && composer require php-pm/httpkernel-adapter
#COPY --from=composer /ppm /ppm

#RUN if [ $(nproc) = 2 ]; then sed -i "s|pm.max_children = 1024|pm.max_children = 512|g" /etc/php/7.3/fpm/php-fpm.conf ; fi;

RUN mkdir -p /laravel/bootstrap/cache
RUN mkdir -p /laravel/storage/framework/sessions
RUN mkdir -p /laravel/storage/framework/views
RUN mkdir -p /laravel/storage/framework/cache

RUN chmod -R 777 /laravel

RUN composer install --optimize-autoloader --classmap-authoritative --no-dev --quiet

RUN php artisan config:cache
RUN php artisan route:cache

ADD /etc/run-nginx.sh /etc/app/run.sh

RUN chmod -R 777 /laravel



#CMD service php7.3-fpm start && \
#    nginx -c /laravel/deploy/nginx.conf -g "daemon off;"

EXPOSE 8080


ENTRYPOINT ["/bin/bash","/etc/app/run.sh"]