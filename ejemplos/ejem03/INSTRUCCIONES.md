# EJEM03 - WordPress + MariaDB con Redes Personalizadas (MEJOR PRÁCTICA)

## Estado: ✅ LISTO PARA EJECUTAR

## Objetivos de la Práctica

1. Aprender redes personalizadas de Docker
2. Comparar con ejem02 (`--link` deprecated)
3. Entender mejor comunicación entre contenedores
4. Prepararse para Docker Compose y producción
5. Evaluar problemas de portabilidad de scripts

## Mejoras respecto a EJEM02

| Aspecto | EJEM02 (--link) | EJEM03 (Redes) |
|--------|-----------------|----------------|
| **Método comunicación** | --link (deprecated) | Red personalizada |
| **Escalabilidad** | 1-a-1 | Múltiples contenedores |
| **DNS interno** | Modificaba /etc/hosts | DNS automático |
| **Best practice** | ❌ No recomendado | ✅ Estándar actual |
| **Complejidad** | Simplista | Más robusto |

## Estructura de Contenedores con Red

```
┌─────────────────────────────────────────┐
│   Docker Host                           │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │     Red: "mi-network"            │  │
│  │                                  │  │
│  │  ┌──────────────┐  ┌──────────┐ │  │
│  │  │  wordpress   │  │wordpress-│ │  │
│  │  │  - IP auto   │  │db        │ │  │
│  │  │  - Alias:    │  │- IP auto │ │  │
│  │  │    wordpress │  │- Alias:  │ │  │
│  │  │              │  │  wordpress│ │  │
│  │  └──────────────┘  │  -db     │ │  │
│  │       ▲             └──────────┘ │  │
│  │       │ DNS automático: wordpress-db│  │
│  │  ┌────┴─────────────────────────┐  │  │
│  │  │ Puerto 8080:80               │  │  │
│  └──┼──────────────────────────────┘  │
│     │ Único puerto mapeado al host    │
└─────┼─────────────────────────────────┘
      │
http://localhost:8080
```

## Análisis del Script run.sh

### Paso 1: Crear Directorio WordPress
```bash
mkdir wordpress
```

### Paso 2: CREAR NETWORK PERSONALIZADA
```bash
docker network create mi-network
```

**Explicación:**
- Crea red puente personalizada
- Los contenedores en esta red pueden descubrirse por nombre
- Docker proporciona DNS interno automático

**Ver redes:**
```bash
docker network ls
```

Output:
```
NETWORK ID     NAME           DRIVER    SCOPE
abc123...      mi-network     bridge    local
xyz789...      bridge         bridge    local
```

### Paso 3: Crear Contenedor MariaDB con Red

```bash
docker run -d --name wordpress-db \
    --net=mi-network \
    --mount source=wordpress-db,target=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=wordpress \
    -e MYSQL_USER=manager \
    -e MYSQL_PASSWORD=secret \
    mariadb:10.3.9
```

**Diferencias respecto a ejem02:**
- ❌ NO usa `--link wordpress-db:mysql`
- ✅ Usa `--net=mi-network` en lugar

**Significado:**
- Contenedor de BD está EN la red mi-network
- Su nombre "wordpress-db" es su DNS alias automático
- Otros contenedores en la misma red pueden usarlo

### Paso 4: Crear Contenedor WordPress con Red

```bash
docker run -d --name wordpress \
    --net=mi-network \
    --link wordpress-db:mysql \
    --mount type=bind,source="$(pwd)"/wordpress,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8080:80 \
    wordpress:4.9.8
```

**Nota especial:**
- Aunque usa `--link`, está dentro de red personalizada
- El `--link` aquí es redundante pero mantiene compatibilidad
- **IMPORTANTE:** `--link` dentro de red personalizada es seguro de usar

**Cómo se conecta:**
```
wordpress → wordpress-db (resuelve por DNS en la red)
         ↓
    Conexión exitosa
```

## Cómo Ejecutar

### Opción A: Ejecutar Script Completo

```bash
cd ejemplos/ejem03
bash run.sh
```

### Opción B: Paso a Paso (Educativo)

**Paso 1:** Navegar
```bash
cd ejemplos/ejem03
mkdir -p wordpress
```

**Paso 2:** Crear red
```bash
docker network create mi-network
docker network ls  # Verificar
```

**Paso 3:** Crear BD
```bash
docker run -d --name wordpress-db \
    --net=mi-network \
    --mount source=wordpress-db,target=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=wordpress \
    -e MYSQL_USER=manager \
    -e MYSQL_PASSWORD=secret \
    mariadb:10.3.9
```

**Verificar:**
```bash
docker ps | grep wordpress-db
docker logs wordpress-db
```

**Paso 4:** Esperar 20 segundos
```bash
sleep 20
```

**Paso 5:** Crear WordPress
```bash
docker run -d --name wordpress \
    --net=mi-network \
    --link wordpress-db:mysql \
    --mount type=bind,source="$(pwd)"/wordpress,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8080:80 \
    wordpress:4.9.8
```

**Paso 6:** Esperar 15 segundos
```bash
sleep 15
docker logs wordpress
```

**Paso 7:** Acceder
```
http://localhost:8080
```

## Verificación

### Ver Red y Contenedores Conectados
```bash
docker network inspect mi-network
```

Output (ejemplo):
```json
{
  "Name": "mi-network",
  "Containers": {
    "abc123...": {
      "Name": "wordpress",
      "IPv4Address": "172.18.0.3/16"
    },
    "xyz789...": {
      "Name": "wordpress-db",
      "IPv4Address": "172.18.0.2/16"
    }
  }
}
```

### Prueba de Conectividad DNS
```bash
# Desde dentro del contenedor wordpress
docker exec -it wordpress bash

# Dentro del contenedor, probar DNS
ping wordpress-db
# Output: ping wordpress-db (172.18.0.2) 56(84) bytes ...

exit
```

### Ver Logs de Ambos Contenedores
```bash
docker logs wordpress
docker logs wordpress-db
```

## Análisis: Portabilidad de Scripts

### Problemas Identificados

#### 1. **Shebang y Shell**
```bash
#!/bin/bash  # ← Problema en Windows
```
- ❌ Windows nativo no tiene /bin/bash
- ✅ Solución: Usar WSL, Git Bash, o PowerShell

#### 2. **Rutas con Barras Diagonales**
```bash
source="$(pwd)"/wordpress  # ← Funciona en Linux/Mac
```
- ❌ Windows usa backslashes: `C:\Users\...`
- ✅ Solución: Docker Compose (abstrae esto)

#### 3. **Variables Shell**
```bash
source="$(pwd)"/wordpress  # ← Bash syntax
```
- ❌ En PowerShell: `$PWD` tiene diferente comportamiento
- ✅ Solución: Usar Docker Compose (YAML)

#### 4. **Saltos de Línea (LF vs CRLF)**
```
Script guardado con CRLF (Windows) → Error "command not found"
```
- ❌ Windows usa CRLF (`\r\n`)
- ❌ Linux usa LF (`\n`)
- ✅ Solución: Git configura automáticamente o usar `dos2unix`

#### 5. **Comandos Unix**
- ❌ `mkdir`, `sleep`, pipes - no existen en PowerShell nativo
- ✅ Solución: WSL o Docker Compose

### Matriz de Compatibilidad

| Plataforma | bash script | PowerShell | WSL | Docker Compose |
|-----------|------------|-----------|-----|----------------|
| Windows | ❌ | ✅ | ✅ | ✅✅ |
| macOS | ✅✅ | ✅ | N/A | ✅✅ |
| Linux | ✅✅ | ✅ | ✅ | ✅✅ |

### Solución Recomendada: Docker Compose

En lugar de `bash run.sh`, usar `docker-compose.yml`:

```yaml
version: '3.8'

services:
  wordpress-db:
    image: mariadb:10.3.9
    container_name: wordpress-db
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: wordpress
      MYSQL_USER: manager
      MYSQL_PASSWORD: secret
    volumes:
      - wordpress-db:/var/lib/mysql
    networks:
      - mi-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  wordpress:
    image: wordpress:4.9.8
    container_name: wordpress
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
    driver: bridge

volumes:
  wordpress-db:
```

**Ventajas:**
- ✅ Funciona igual en Windows, Mac, Linux
- ✅ Sintaxis clara y versionable
- ✅ `docker-compose up -d` en cualquier SO
- ✅ Mejor para CI/CD

**Uso:**
```bash
cd ejemplos/ejem03
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down

# Eliminar todo incluyendo volúmenes
docker-compose down -v
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

### Eliminar Red
```bash
docker network rm mi-network
```

### Eliminar Volumen (CUIDADO - datos perdidos)
```bash
docker volume rm wordpress-db
```

## Checklist

- [ ] Ejecutar script `run.sh`
- [ ] Verificar red con `docker network ls`
- [ ] Verificar contenedores en red: `docker network inspect mi-network`
- [ ] Acceder a http://localhost:8080
- [ ] Ver logs de ambos contenedores
- [ ] Probar DNS desde dentro: `docker exec -it wordpress bash → ping wordpress-db`
- [ ] Captura de pantalla de WordPress funcionando
- [ ] Captura de pantalla de `docker network ls`
- [ ] Documentar problemas de portabilidad

## Conclusiones

**EJEM03 vs EJEM02:**
- EJEM03 es más moderno y escalable
- Usa redes personalizadas (mejor práctica actual)
- Prepare para producción
- Más fácil agregar más contenedores

**Portabilidad:**
- Scripts bash tienen limitaciones en Windows
- Docker Compose es la solución multiplataforma
- Es el estándar en industria

---

**Última actualización:** 2026-06-23
