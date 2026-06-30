# EJEM02 - WordPress + MariaDB con --link (Method Deprecated)

## Estado: ✅ LISTO PARA EJECUTAR

## Objetivos de la Práctica

1. Entender la ejecución de scripts bash en Docker
2. Ejecutar múltiples contenedores que se comunican
3. Usar volúmenes para persistencia
4. Aprender sobre `--link` (aunque deprecated)
5. Acceder a aplicación web desde navegador

## Estructura de Contenedores

```
┌─────────────────────────────────────┐
│   Docker Host (tu máquina)          │
│                                     │
│  ┌──────────────────────┐           │
│  │  wordpress (Apache)  │           │
│  │  - Puerto: 8080      │◄──────────┼── http://localhost:8080
│  │  - DB: wordpress-db  │           │
│  │  - Vol: ./wordpress  │           │
│  └──────────────────────┘           │
│           │ --link                  │
│           ▼                         │
│  ┌──────────────────────┐           │
│  │  wordpress-db        │           │
│  │  (MariaDB)           │           │
│  │  - Puerto: 3306      │           │
│  │  - Vol: wordpress-db │           │
│  └──────────────────────┘           │
│                                     │
└─────────────────────────────────────┘
```

## Análisis del Script run.sh

### Componente 1: Base de Datos MariaDB

```bash
docker run -d --name wordpress-db \
    --mount source=wordpress-db,target=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=wordpress \
    -e MYSQL_USER=manager \
    -e MYSQL_PASSWORD=secret \
    mariadb:10.3.9
```

**Desglose:**
| Opción | Explicación |
|--------|-------------|
| `run` | Crear y ejecutar contenedor |
| `-d` | Detached (background) - no bloquea terminal |
| `--name wordpress-db` | Identificador único del contenedor |
| `--mount source=wordpress-db` | Crear volumen con nombre 'wordpress-db' |
| `target=/var/lib/mysql` | Ruta dentro del contenedor donde monta volumen |
| `-e MYSQL_ROOT_PASSWORD=secret` | Variable de entorno: password root |
| `-e MYSQL_DATABASE=wordpress` | Crea base de datos 'wordpress' al iniciar |
| `-e MYSQL_USER=manager` | Crea usuario 'manager' |
| `-e MYSQL_PASSWORD=secret` | Password del usuario 'manager' |
| `mariadb:10.3.9` | Imagen:versión a descargar |

**Propósito:** 
- Persistencia de datos (volumen)
- Configuración automática mediante variables de entorno

### Componente 2: WordPress (Web)

```bash
docker run -d --name wordpress \
    --link wordpress-db:mysql \
    --mount type=bind,source="$(pwd)"/wordpress,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8080:80 \
    wordpress:4.9.8
```

**Desglose:**
| Opción | Explicación |
|--------|-------------|
| `--link wordpress-db:mysql` | **DEPRECATED** - Conecta a otro contenedor como alias 'mysql' |
| `--mount type=bind,source=...` | Monta directorio del host (bindmount, no volumen) |
| `source="$(pwd)"/wordpress` | Usa directorio actual + /wordpress |
| `target=/var/www/html` | Donde WordPress escribe archivos |
| `-e WORDPRESS_DB_USER=manager` | Usuario para conectar a DB |
| `-e WORDPRESS_DB_PASSWORD=secret` | Password para DB |
| `-p 8080:80` | **Puerto importante**: 8080 (host) → 80 (contenedor) |
| `wordpress:4.9.8` | Imagen de WordPress (vieja, para ejemplo) |

**Propósito:**
- Ejecutar aplicación web
- Conectar a DB usando `--link`
- Hacer accesible desde navegador

## Cómo Ejecutar

### Opción A: Ejecutar Script Completo (Recomendado para principiantes)

```bash
cd ejemplos/ejem02
bash run.sh
```

**El script hace:**
1. Crea contenedor MariaDB
2. Crea contenedor WordPress
3. Abre automáticamente para acceso

### Opción B: Ejecutar Paso a Paso (Recomendado para entender)

**Paso 1:** Ir al directorio
```bash
cd ejemplos/ejem02
```

**Paso 2:** Crear directorio para WordPress
```bash
mkdir -p wordpress
```

**Paso 3:** Crear contenedor de Base de Datos
```bash
docker run -d --name wordpress-db \
    --mount source=wordpress-db,target=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=wordpress \
    -e MYSQL_USER=manager \
    -e MYSQL_PASSWORD=secret \
    mariadb:10.3.9
```

**Verificación:**
```bash
docker ps | grep wordpress-db
```

**Paso 4:** ESPERAR a que MariaDB esté lista (importante)
```bash
# Espera ~20 segundos y verificar logs
sleep 20
docker logs wordpress-db
```

Busca línea similar a:
```
[System] [MY-000000] [Server] ready for connections.
```

**Paso 5:** Crear contenedor de WordPress
```bash
docker run -d --name wordpress \
    --link wordpress-db:mysql \
    --mount type=bind,source="$(pwd)"/wordpress,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8080:80 \
    wordpress:4.9.8
```

**Paso 6:** ESPERAR a que WordPress esté listo
```bash
sleep 15
docker logs wordpress | tail -20
```

### Acceder a WordPress

1. **En navegador:**
   ```
   http://localhost:8080
   ```

2. **Deberías ver:**
   - Página de configuración inicial de WordPress
   - O WordPress ya instalado (dependiendo de contenedor)

3. **Captura de pantalla:** 📸
   - Toma captura de la página de WordPress corriendo
   - Muestra que está en puerto 8080

## Verificación y Monitoreo

### Ver Ambos Contenedores Corriendo
```bash
docker ps
```

Output esperado:
```
CONTAINER ID   IMAGE              STATUS      PORTS           NAMES
xxx111         wordpress:4.9.8    Up 2 min    0.0.0.0:8080->80/tcp   wordpress
xxx222         mariadb:10.3.9     Up 3 min    3306/tcp                wordpress-db
```

### Ver Logs del Contenedor
```bash
# Logs de WordPress
docker logs wordpress

# Logs de MariaDB
docker logs wordpress-db

# Seguir logs en vivo (Ctrl+C para salir)
docker logs -f wordpress
```

### Conectarse a MariaDB desde Host
```bash
# Necesita cliente MySQL/MariaDB instalado
mysql -h 127.0.0.1 -u manager -psecret -D wordpress

# Dentro de MySQL:
SHOW TABLES;
SELECT user_login FROM wp_users;
EXIT;
```

### Inspeccionar Contenedor
```bash
docker inspect wordpress
docker inspect wordpress-db
```

## Limpieza

### Detener Contenedores
```bash
docker stop wordpress
docker stop wordpress-db
```

### Eliminar Contenedores
```bash
docker rm wordpress
docker rm wordpress-db
```

### Eliminar Volumen (¡CUIDADO! Elimina datos)
```bash
docker volume rm wordpress-db
```

## Problemas Comunes

### Error: "Port 8080 already in use"
```bash
# Cambiar puerto en comando run
docker run -d --name wordpress \
    --link wordpress-db:mysql \
    --mount type=bind,source="$(pwd)"/wordpress,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8888:80 \   # ← Cambiar 8888 por otro puerto libre
    wordpress:4.9.8

# Acceder a: http://localhost:8888
```

### Error: "WordPress can't connect to database"
- Verificar que wordpress-db container está corriendo: `docker ps`
- Verificar que esperaste tiempo suficiente (20+ segundos)
- Ver logs: `docker logs wordpress`
- Revisar credenciales de BD

### Base de datos no inicializa
- Es normal tomar 20-30 segundos la primera vez
- Ver logs: `docker logs wordpress-db`
- A veces hay que esperar más: `sleep 30` y luego correr WordPress

## Conceptos Clave

| Concepto | Nota |
|----------|------|
| **--link** | Deprecated - Usar redes personalizadas en nuevos proyectos |
| **--mount** | Montar volúmenes o directorios |
| **Volúmenes** | Persistencia de datos entre reinicians |
| **Bind Mounts** | Sincroniza directorio del host |
| **-e (ENV vars)** | Configuración mediante variables de entorno |
| **-p (Port Mapping)** | Expone puerto contenedor al host |
| **-d (Detached)** | Corre en background |

## Por Qué Está Deprecated --link

- ❌ No es escalable
- ❌ Funciona solo con 2 contenedores
- ❌ Modifica /etc/hosts (hack)
- ❌ Limitado a comunicación de contenedor a contenedor
- ✅ Mejor alternativa: **Redes personalizadas** (ver ejem03)

---

**Última actualización:** 2026-06-23
