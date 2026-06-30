#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

mkdir -p wordpress

docker rm -f wordpress-db wordpress >/dev/null 2>&1 || true

docker volume rm wordpress-db >/dev/null 2>&1 || true

docker run -d --name wordpress-db \
  --mount source=wordpress-db,target=/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=manager \
  -e MYSQL_PASSWORD=secret \
  mariadb:10.3.9

echo "Esperando a MariaDB..."
sleep 15

docker run -d --name wordpress \
  --link wordpress-db:mysql \
  --mount type=bind,source="$SCRIPT_DIR/wordpress",target=/var/www/html \
  -e WORDPRESS_DB_USER=manager \
  -e WORDPRESS_DB_PASSWORD=secret \
  -p 8080:80 \
  wordpress:4.9.8

echo "WordPress listo en http://localhost:8080"