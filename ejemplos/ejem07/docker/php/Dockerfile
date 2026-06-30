# Imagen de PHP
FROM php:8.2-fpm

RUN apt-get update && \
    apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev default-mysql-client && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install mysqli pdo pdo_mysql gd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*