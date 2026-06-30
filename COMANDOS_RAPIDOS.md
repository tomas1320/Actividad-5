# Comandos Rápidos - Tutorial Docker

## 🔥 Quick Copy-Paste Commands

### EJEM01 - Vim Editor en Docker

#### Construcción y Ejecución
```bash
cd ejemplos/ejem01
bash run.sh
```

#### Editar con Vim
```bash
docker exec -it miapache-php bash
vi /var/www/html/index.html
```

**Dentro de Vim:**
- Presionar: `i` (insert mode)
- Editar el archivo
- Presionar: `ESC` → `:` → `wq` → `ENTER`

#### Ver en Navegador
```
http://localhost:5555
```

#### Salir del Contenedor
```bash
exit
```

---

### EJEM02 - WordPress + MariaDB (Paso a Paso)

#### Preparación
```bash
cd ejemplos/ejem02
mkdir -p wordpress
```

#### Crear Base de Datos
```bash
docker run -d --name wordpress-db \
    --mount source=wordpress-db,target=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=wordpress \
    -e MYSQL_USER=manager \
    -e MYSQL_PASSWORD=secret \
    mariadb:10.3.9
```

#### Esperar
```bash
sleep 20
docker logs wordpress-db
```

#### Crear WordPress
```bash
docker run -d --name wordpress \
    --link wordpress-db:mysql \
    --mount type=bind,source="$(pwd)"/wordpress,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8080:80 \
    wordpress:4.9.8
```

#### Esperar e Acceder
```bash
sleep 15
docker logs wordpress
```

#### Ver en Navegador
```
http://localhost:8080
```

#### O ejecutar Script Completo
```bash
cd ejemplos/ejem02
bash run.sh
```

---

### EJEM03 - Networks (Paso a Paso)

#### Preparación
```bash
cd ejemplos/ejem03
mkdir -p wordpress
```

#### Crear Red
```bash
docker network create mi-network
docker network ls
```

#### Base de Datos en Red
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

#### Esperar
```bash
sleep 20
docker logs wordpress-db
```

#### WordPress en Red
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

#### Verificar Red
```bash
sleep 15
docker network inspect mi-network
docker logs wordpress
```

#### Ver en Navegador
```
http://localhost:8080
```

#### O ejecutar Script Completo
```bash
cd ejemplos/ejem03
bash run.sh
```

---

## 🔍 Verificación y Monitoreo

### Ver Contenedores Activos
```bash
docker ps
```

### Ver Logs de Contenedor
```bash
docker logs miapache-php
docker logs wordpress
docker logs wordpress-db

# Ver logs en vivo (Ctrl+C para salir)
docker logs -f wordpress
```

### Ver Redes
```bash
docker network ls
docker network inspect mi-network
```

### Inspeccionar Contenedor
```bash
docker inspect wordpress
docker inspect wordpress-db
```

### Conectarse Interactivamente
```bash
docker exec -it miapache-php bash
docker exec -it wordpress bash
docker exec -it wordpress-db bash
```

---

## 🧹 Limpieza

### Detener Contenedores
```bash
docker stop miapache-php
docker stop wordpress
docker stop wordpress-db
```

### Eliminar Contenedores
```bash
docker rm miapache-php
docker rm wordpress
docker rm wordpress-db
```

### Eliminar Red
```bash
docker network rm mi-network
```

### Eliminar Volúmenes (⚠️ Elimina datos)
```bash
docker volume rm wordpress-db
```

### Limpiar Todo de una vez
```bash
# Eliminar todos los contenedores (cuidado!)
docker rm -f $(docker ps -aq)

# Eliminar todas las redes personalizadas
docker network prune

# Eliminar todos los volúmenes no usados
docker volume prune
```

---

## 🐛 Troubleshooting

### Puerto ya en uso
```bash
# Ver qué usa el puerto
netstat -ano | findstr :5555
netstat -ano | findstr :8080

# Cambiar puerto en docker run:
# Cambiar: -p 5555:80 → -p 5556:80
```

### Contenedor se detiene inmediatamente
```bash
docker logs <nombre-contenedor>
# Ver por qué falló

docker run -it <imagen> bash
# Entrar al contenedor interactivamente para debuggear
```

### No puede conectarse a BD
```bash
# Verificar que BD está corriendo
docker ps | grep wordpress-db

# Ver logs de BD
docker logs wordpress-db

# Esperar más tiempo (algunos sistemas son lentos)
sleep 30
```

### Vim no está disponible en contenedor
```bash
# Instalar dentro del contenedor
docker exec -it miapache-php bash
apt-get update
apt-get install -y vim
exit

# O reconstruir con Dockerfile correcto
```

---

## 📱 Remote Explorer (VS Code)

### Instalación
1. Abrir VS Code
2. Presionar: `Ctrl+Shift+X`
3. Buscar: "Remote - Containers"
4. Instalar

### Conectar a Contenedor
1. Presionar: `Ctrl+Shift+P`
2. Buscar: "Remote-Containers: Attach to Running Container"
3. Seleccionar contenedor
4. Esperar conexión
5. Abrir carpeta: `/var/www/html`

### Editar Archivos
- Los cambios se sincronizan automáticamente
- Puedes usar terminal integrada
- Debugging es posible

---

## 📖 Documentación Referencia

### Archivos Principales
- `RESUMEN_IMPLEMENTACION.md` - Overview general
- `GUIA_EJECUCION.md` - Guía paso a paso
- `TUTORIAL_IMPLEMENTACION.md` - Conceptos técnicos

### Archivos por Ejemplo
- `ejemplos/ejem01/INSTRUCCIONES.md`
- `ejemplos/ejem02/INSTRUCCIONES.md`
- `ejemplos/ejem03/INSTRUCCIONES.md`

---

## 🎯 Checklist de Ejecución

### EJEM01
- [ ] Ejecutar `bash run.sh`
- [ ] Acceder con `docker exec -it miapache-php bash`
- [ ] Editar con `vi /var/www/html/index.html`
- [ ] Ver en http://localhost:5555
- [ ] Capturar pantalla

### EJEM02
- [ ] Crear directorio: `mkdir -p wordpress`
- [ ] Ejecutar `bash run.sh`
- [ ] Esperar 30-40 segundos
- [ ] Ver en http://localhost:8080
- [ ] Capturar pantalla
- [ ] O ejecutar paso a paso

### EJEM03
- [ ] Crear directorio: `mkdir -p wordpress`
- [ ] Ejecutar `bash run.sh`
- [ ] Verificar red: `docker network ls`
- [ ] Ver en http://localhost:8080
- [ ] Capturar pantalla de network
- [ ] Documentar problemas portabilidad

### VS Code Remote Explorer
- [ ] Instalar extensión
- [ ] Conectar a contenedor
- [ ] Editar archivos
- [ ] Validar sincronización

---

## 🌐 URLs de Acceso

| Ejemplo | Puerto | URL |
|---------|--------|-----|
| EJEM01 | 5555 | http://localhost:5555 |
| EJEM02 | 8080 | http://localhost:8080 |
| EJEM03 | 8080 | http://localhost:8080 |

---

## 💾 Credenciales (EJEM02/EJEM03)

| Componente | Usuario | Password | BD |
|-----------|---------|----------|-----|
| MariaDB | manager | secret | wordpress |
| MariaDB Root | root | secret | - |
| WordPress | (configurar en instalación) | - | wordpress |

---

## 🚀 Pro Tips

### Reutilizar Puerto si Falla
```bash
# Usar puerto diferente
docker run -d --name wordpress \
    -p 8888:80 \
    ...
# Acceder a: http://localhost:8888
```

### Ver Tamaño de Contenedores
```bash
docker ps -s
```

### Limpiar todo sin perder datos importantes
```bash
docker system prune -a --volumes
```

### Usar bash alternativo si falla shebang
```bash
bash -x run.sh  # Con debugging
```

### Ver cambios en tiempo real
```bash
docker logs -f wordpress
```

---

**Última actualización:** 2026-06-23

💡 **Tip:** Guarda este archivo para referencias rápidas
