# Imagen a usar
FROM php:8.2-apache

# Actualizar repositorios e instalar Vim
RUN apt-get update && \
    apt-get install -y vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copiamos los ficheros al directorio web
COPY src/ /var/www/html/

# Exponemos el puerto 80
EXPOSE 80

# Quien lo ha realizado
LABEL maintainer="JL Gonzalez <jlgs@cifpvirgendegracia.com>"
