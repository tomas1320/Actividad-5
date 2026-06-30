# EJEM01 - Edición en contenedor Docker con Vim

## Estado: ✅ LISTO PARA EJECUTAR

## Qué se ha dejado preparado
- Imagen basada en PHP 8.2 y Apache.
- Vim instalado dentro del contenedor.
- Archivo de ejemplo editado con datos de la práctica.
- Script para levantar el contenedor en el puerto 5555.

## Pasos

### 1. Levantar el ejemplo
```bash
cd ejemplos/ejem01
bash run.sh
```

### 2. Entrar dentro del contenedor
```bash
docker exec -it miapache-php bash
```

### 3. Editar con Vim
```bash
vi /var/www/html/index.html
```

Pasos para guardar:
1. Pulsar `i` para entrar en modo inserción.
2. Editar el contenido.
3. Pulsar `Esc`.
4. Escribir `:wq` y pulsar Enter.

### 4. Ver el resultado en navegador
Abrir: http://localhost:5555

### 5. Editar desde VS Code
- Instalar la extensión Remote Explorer o Remote - Containers.
- Conectar a Docker y seleccionar el contenedor `miapache-php`.
- Abrir la carpeta `/var/www/html`.
- Editar el archivo `index.html` desde el editor.

## Nota importante
Si aparece un error relacionado con GLIBC o con versiones antiguas de PHP, la imagen ya usa PHP 8.2 para evitarlo.

