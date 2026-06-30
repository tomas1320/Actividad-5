# Guía de Ejecución Práctica - Tutorial Docker

## EJEM01 - Editar Contenedor Docker con Vim

### Objetivo
Editar archivos HTML dentro de un contenedor Docker usando Vim, agregando nombre, fecha y materia.

### Pasos

#### 1. Construir y ejecutar el contenedor
```bash
cd ejemplos/ejem01
bash run.sh
```

**¿Qué hace este script?**
- Elimina contenedores/imágenes previas
- Construye la imagen `miapache-php` con PHP 8.2 y Vim
- Corre el contenedor exponiendo puerto 5555 (maps a 80 interno)
- Monta el directorio `src/` para cambios en vivo

#### 2. Verificar que el contenedor está corriendo
```bash
docker ps | grep miapache-php
```

#### 3. Acceder al contenedor
```bash
docker exec -it miapache-php bash
```

#### 4. Editar index.html con Vim
```bash
vi /var/www/html/index.html
```

**Comandos Vim:**
| Acción | Tecla(s) |
|--------|----------|
| Entrar en modo edición | `i` |
| Guardar y salir | `ESC` → `:` → `wq` → `ENTER` |
| Salir sin guardar | `ESC` → `:` → `q!` → `ENTER` |

**Ejemplo de edición:**
- Buscar la línea `<h1>¡Hola 2DAW, mundo!</h1>`
- Cambiarla a: `<h1>¡Hola 2DAW, mundo! - [Tu Nombre] - [Fecha] - [Materia]</h1>`

#### 5. Verificar cambios
```bash
cat /var/www/html/index.html
```

#### 6. Acceder desde navegador
```
http://localhost:5555
```

#### 7. Captura de pantalla
- Captura la pantalla del navegador mostrando tu contenido editado
- Guarda como `ejem01-captura.png`

#### 8. Salir del contenedor
```bash
exit
```

---

## EJEM02 - Análisis de Script run.sh (WordPress + MariaDB)

### Objetivo
Entender qué hace el script y ejecutar manualmente cada comando.

### Análisis del Script

```bash
#!/bin/bash

# Paso 1: Crear contenedor de base de datos
docker run -d --name wordpress-db \
    --mount source=wordpress-db,target=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=wordpress \
    -e MYSQL_USER=manager \
    -e MYSQL_PASSWORD=secret \
    mariadb:10.3.9
```

| Parámetro | Significado |
|-----------|-------------|
| `-d` | Ejecutar en background (daemon) |
| `--name wordpress-db` | Nombre del contenedor |
| `--mount source=wordpress-db` | Crear volumen con nombre |
| `-e MYSQL_ROOT_PASSWORD=secret` | Variable de entorno: contraseña root |
| `mariadb:10.3.9` | Imagen y versión a usar |

```bash
# Paso 2: Crear contenedor de WordPress
docker run -d --name wordpress \
    --link wordpress-db:mysql \
    --mount type=bind,source="$(pwd)"/wordpress,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8080:80 \
    wordpress:4.9.8
```

| Parámetro | Significado |
|-----------|-------------|
| `--link wordpress-db:mysql` | Conectar a DB (alias: mysql) - **DEPRECATED** |
| `--mount type=bind` | Montar directorio del host |
| `source="$(pwd)"/wordpress` | Directorio local actual + /wordpress |
| `target=/var/www/html` | Ruta dentro del contenedor |
| `-p 8080:80` | Map puerto 8080 (host) → 80 (contenedor) |

### Ejecución Manual

#### Opción A: Ejecutar el script completo
```bash
cd ejemplos/ejem02
bash run.sh
```

#### Opción B: Ejecutar paso a paso (más educativo)
```bash
cd ejemplos/ejem02

# Crear el directorio de wordpress si no existe
mkdir -p wordpress

# Paso 1: Contenedor MariaDB
docker run -d --name wordpress-db \
    --mount source=wordpress-db,target=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=wordpress \
    -e MYSQL_USER=manager \
    -e MYSQL_PASSWORD=secret \
    mariadb:10.3.9

# Esperar a que MariaDB inicie (aproximadamente 15-20 segundos)
sleep 20

# Paso 2: Contenedor WordPress
docker run -d --name wordpress \
    --link wordpress-db:mysql \
    --mount type=bind,source="$(pwd)"/wordpress,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8080:80 \
    wordpress:4.9.8

# Esperar a que WordPress inicie
sleep 15

# Ver logs
docker logs wordpress
```

#### Verificación
```bash
# Ver contenedores corriendo
docker ps

# Acceder a WordPress
# Abrir navegador: http://localhost:8080
```

#### Captura de pantalla
- Captura la página inicial de WordPress
- Muestra que está corriendo en el puerto 8080

---

## EJEM03 - Script con Redes Personalizadas

### Objetivo
Ejecutar el script y analizar las diferencias con ejem02.

### Diferencias Principales

**ejem02:**
```bash
docker run -d --name wordpress \
    --link wordpress-db:mysql \
    ...
```
- Usa `--link` (deprecated desde Docker 1.9)
- Comunicación 1-a-1
- Modificaba /etc/hosts del contenedor

**ejem03:**
```bash
docker network create mi-network

docker run -d --name wordpress \
    --net=mi-network \
    ...
```
- Crea red personalizada (mejor práctica)
- Todos los contenedores en la red se pueden descubrir por nombre
- DNS interno automático

### Ejecución

```bash
cd ejemplos/ejem03
bash run.sh
```

#### Verificar redes
```bash
docker network ls
docker network inspect mi-network
```

#### Acceder a WordPress
```
http://localhost:8080
```

#### Captura de pantalla
- Muestra `docker network ls` en terminal
- Muestra WordPress funcionando

### Análisis de Portabilidad

#### Problemas de Scripts de S.O.

| Problema | Impacto | Solución |
|----------|---------|----------|
| **Shebang `#!/bin/bash`** | No funciona en Windows nativo | Usar WSL, Git Bash, o PowerShell |
| **Rutas con `/`** | Windows usa `\` | Docker Compose (multiplataforma) |
| **Variables `$(pwd)`** | PowerShell usa sintaxis diferente | Usar Docker Compose en lugar de scripts |
| **Saltos de línea CRLF/LF** | Errores "command not found" | Convertir a LF con `dos2unix` |
| **Comandos Unix** | No existen en Windows | PowerShell alternativas o WSL |

#### Mejora Recomendada: Docker Compose

En lugar de scripts bash, usar `docker-compose.yml`:

```yaml
version: '3.8'

services:
  wordpress-db:
    image: mariadb:10.3.9
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: wordpress
      MYSQL_USER: manager
      MYSQL_PASSWORD: secret
    volumes:
      - wordpress-db:/var/lib/mysql
    networks:
      - mi-network

  wordpress:
    image: wordpress:4.9.8
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: wordpress-db
      WORDPRESS_DB_USER: manager
      WORDPRESS_DB_PASSWORD: secret
    volumes:
      - ./wordpress:/var/www/html
    depends_on:
      - wordpress-db
    networks:
      - mi-network

networks:
  mi-network:

volumes:
  wordpress-db:
```

**Ventajas:**
- Funciona igual en Windows, Mac, Linux
- Declarativo y fácil de entender
- Versionable en Git
- Mejor para CI/CD

---

## Instalación de Remote Explorer en VS Code

### Pasos

1. **Abrir VS Code**

2. **Abrir Extensions**
   - Presionar `Ctrl+Shift+X` o click en ícono de extensiones

3. **Buscar "Remote"**
   - Buscar: `ms-vscode-remote.remote-containers`
   - O instalar "Remote - Containers" directamente

4. **Click en Install**

5. **Recargar VS Code** si es necesario

### Conectar a Contenedor Docker

1. **Abrir Command Palette**
   - `Ctrl+Shift+P`

2. **Escribir:** `Remote-Containers: Attach to Running Container`

3. **Seleccionar contenedor:** `miapache-php` (ejem01)

4. **Esperar a que se conecte** (primero build, luego conexión)

5. **Abrir carpeta:** `/var/www/html`

6. **Editar archivos directamente**
   - Los cambios se sincronizan al contenedor automáticamente

### Nota Importante
- Asegúrate de que Docker está corriendo
- La versión PHP debe ser 8.2+ (ya actualizada en el Dockerfile)
- Los contenedores deben estar en ejecución

---

## Checklist de Tareas

- [ ] ejem01: Dockerfile actualizado a PHP 8.2 con Vim
- [ ] ejem01: Contenedor ejecutado y archivos editados
- [ ] ejem01: Captura de pantalla en navegador
- [ ] ejem02: Script analizado y ejecutado manualmente paso a paso
- [ ] ejem02: Captura de pantalla de WordPress corriendo
- [ ] ejem03: Script ejecutado
- [ ] ejem03: Redes verificadas con `docker network ls`
- [ ] ejem03: Captura de pantalla
- [ ] ejem03: Problemas de portabilidad documentados
- [ ] Remote Explorer: Instalado en VS Code
- [ ] Remote Explorer: Conectado a contenedor Docker

---

**Última actualización:** 2026-06-23
