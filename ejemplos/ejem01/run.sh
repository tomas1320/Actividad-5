#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

mkdir -p src

docker rm -f miapache-php >/dev/null 2>&1 || true
docker rmi -f miapache-php >/dev/null 2>&1 || true

docker build -t miapache-php .

docker run -dit --name miapache-php \
  -p 5555:80 \
  --mount type=bind,source="$SCRIPT_DIR/src",target=/var/www/html \
  miapache-php

echo "Contenedor listo en http://localhost:5555"
echo "Para editar: docker exec -it miapache-php bash"

