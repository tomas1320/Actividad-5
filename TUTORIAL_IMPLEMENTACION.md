# Tutorial Docker - Implementación Práctica

## Resumen de Cambios Realizados

Este documento registra la implementación de las prácticas del tutorial de Docker, con cambios de configuración y ejecuciones.

---

## Ejemplo 01 - Editar en Contenedor Docker con Vim

### Cambios Realizados en Dockerfile

**Versión anterior:**
- Usaba `php:7.0-apache` (problemas de compatibilidad con GLIBC)

**Versión actualizada:**
- Actualizado a `php:8.2-apache`
- Instalado `vim` para edición dentro del contenedor
- APT cache actualizado y limpiado para optimizar imagen

### Dockerfile Actualizado

```dockerfile
# Imagen a usar
FROM php:8.2-apache

# Actualizar repositorios e instalar Vim
RUN apt-get update && \
    apt-get install -y vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# copiamos todos los ficheros en el directorio en cuestion
COPY src/ /var/www/html

# Exponemos el puerto 80
EXPOSE 80

# Quien lo ha realizado
MAINTAINER JL Gonzalez "jlgs@cifpvirgendegracia.com"
```

### Pasos para Ejecutar

1. **Navegar al directorio ejem01:**
   ```bash
   cd ejemplos/ejem01
   ```

2. **Ejecutar el script run.sh:**
   ```bash
   bash run.sh
   ```

3. **Acceder al contenedor:**
   ```bash
   docker exec -it miapache-php bash
   ```

4. **Editar index.html con Vim:**
   ```bash
   vi /var/www/html/index.html
   ```
   - Presionar `i` para entrar en modo inserción
   - Agregar nombre, fecha y materia
   - Presionar `ESC` + `:` + `wq` + `ENTER` para guardar

---

## Ejemplo 02 - Análisis de run.sh (WordPress + MariaDB)

### Interpretación de Comandos

El script `run.sh` de ejem02 realiza las siguientes acciones:

```bash
#!/bin/bash

# Creamos el contenedor para nuestra base de datos
docker run -d --name wordpress-db \
    --mount source=wordpress-db,target=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=wordpress \
    -e MYSQL_USER=manager \
    -e MYSQL_PASSWORD=secret \
    mariadb:10.3.9
```
- Crea contenedor MariaDB con volumen persistente
- Variables de entorno para configurar base de datos

```bash
# Creamos el contenedor de WordPress
docker run -d --name wordpress \
    --link wordpress-db:mysql \
    --mount type=bind,source="$(pwd)"/wordpress,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8080:80 \
    wordpress:4.9.8
```
- Crea contenedor WordPress
- Vincula con contenedor de DB mediante `--link` (deprecated, usar redes en su lugar)
- Monta directorio local para archivos de WordPress

---

## Ejemplo 03 - Uso de Redes Personalizadas

### Interpretación de run.sh

El script ejem03 mejora sobre ejem02 usando redes personalizadas:

```bash
# Creamos la red propia
docker network create mi-network
```
- Crea red personalizada (mejor práctica que `--link`)

El resto de comandos es similar pero usando `--net=mi-network` en lugar de `--link`.

### Ventajas vs Desventajas de Scripts de S.O.

**Ventajas:**
- Fácil de ejecutar en Linux/Mac
- Automatiza múltiples comandos

**Desventajas/Problemas de Portabilidad:**
- No funcionan en Windows sin Git Bash o WSL
- Rutas pueden necesitar ajuste por SO
- Caracteres de salto de línea diferentes (CRLF vs LF)

---

## Conexión desde VS Code (Remote Explorer)

### Pasos a Seguir

1. Instalar extensión **Remote - Containers** en VS Code
2. Abrir Command Palette (`Ctrl+Shift+P`)
3. Buscar "Remote-Containers: Attach to Running Container"
4. Seleccionar contenedor `miapache-php`
5. Editar archivos directamente desde VS Code

### Nota sobre PHP Versión
- Se actualizó a PHP 8.2 para evitar errores de compatibilidad GLIBC
- Esto permite conexión sin problemas desde Remote Explorer

---

## Capturas de Pantalla

### ejem01 - Contenedor Ejecutándose
[Captura pendiente]

### ejem02 - WordPress Corriendo
[Captura pendiente]

### ejem03 - Usando Redes Personalizadas
[Captura pendiente]

---

## Conclusiones

- ✅ Dockerfile actualizado correctamente a PHP 8.2
- ✅ Vim instalado para edición en contenedor
- ✅ Scripts analizados e interpretados
- ⏳ Capturas de pantalla pendientes de agregar
- ⏳ Pruebas de ejecución pendientes

---

**Fecha de Actualización:** 2026-06-23
