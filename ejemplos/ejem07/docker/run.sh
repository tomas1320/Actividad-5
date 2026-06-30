#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "*** Iniciando stack LEMP ***"
docker compose down >/dev/null 2>&1 || true
docker compose up -d --build
echo "Stack LEMP listo"
echo "- http://localhost:8080"
echo "- http://localhost:8081"
