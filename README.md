# Ejemplo 1 del index.html
<img width="1545" height="924" alt="image" src="https://github.com/user-attachments/assets/e9f69a12-b69f-4f2e-9f57-779ce96cdf17" />

# Ejemplo 2 Corriendo
<img width="1914" height="995" alt="image" src="https://github.com/user-attachments/assets/3132437b-ba7a-4543-b7d7-a86b509b60f2" />


# Evaluación de Portabilidad de `ejem03/run.sh`

## Análisis

El script `ejem03/run.sh` presenta varios inconvenientes para ejecutarse en sistemas operativos distintos de Linux o macOS, principalmente debido a su dependencia de Bash y de comandos específicos de entornos POSIX.

### 1. Dependencia de Bash

El script comienza con:

```bash
#!/bin/bash
```

Esto obliga a que exista un intérprete **Bash** para poder ejecutarlo.

- ✅ Funciona en Linux.
- ✅ Funciona en macOS.
- ⚠️ En Windows no funciona de forma nativa con CMD o PowerShell.
- Para ejecutarlo en Windows es necesario utilizar:
  - WSL (Windows Subsystem for Linux)
  - Git Bash
  - Cygwin
  - MSYS2

---

### 2. Uso de comandos específicos del shell

El script utiliza varias instrucciones propias de Bash/POSIX, entre ellas:

```bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p
rm -f
sleep 15
```

Estas construcciones no son compatibles con CMD ni PowerShell sin modificaciones, por lo que reducen la portabilidad del proyecto.

---

### 3. Rutas y montaje de directorios (Bind Mount)

El script utiliza el directorio del proyecto para montar archivos dentro de los contenedores:

```bash
--mount type=bind,source="$SCRIPT_DIR/wordpress",target=/var/www/html
```

En Linux esto funciona correctamente, pero en Windows pueden surgir problemas debido a las diferencias en el formato de las rutas:

- Linux:
  ```
  /home/usuario/proyecto
  ```

- Windows:
  ```
  C:\Users\User\Proyecto
  ```

Aunque Docker Desktop con WSL suele realizar la conversión automáticamente, el script depende de un entorno POSIX para obtener la ruta mediante `pwd`, por lo que no resulta completamente portable.

---

### 4. Dependencia del estado previo

Antes de crear los nuevos contenedores, el script elimina recursos existentes:

```bash
docker rm -f wordpress-db wordpress
docker volume rm wordpress-db
docker network rm mi-network
```

Esta limpieza evita conflictos al volver a ejecutar el script.

Sin embargo:

- si algún recurso está siendo utilizado puede producir errores;
- depende del estado previo del sistema;
- el manejo de estos recursos sería más sencillo utilizando Docker Compose.

---

### 5. Uso de red manual y `--link`

El script crea una red manualmente:

```bash
docker network create mi-network
```

y además conecta los contenedores utilizando:

```bash
--link wordpress-db:mysql
```

Aunque este método continúa funcionando, actualmente se considera una práctica antigua.

Docker Compose administra automáticamente:

- redes
- nombres de contenedores
- dependencias entre servicios

sin necesidad de utilizar `--link`.

---

# Conclusión

El principal problema de portabilidad de `ejem03/run.sh` es que está desarrollado como un script de **Bash**, lo que limita su ejecución a sistemas que dispongan de un entorno POSIX.

Esto implica que:

- ✅ En Linux funciona directamente.
- ✅ En macOS funciona directamente.
- ⚠️ En Windows requiere WSL, Git Bash o un entorno equivalente.
- ❌ No puede ejecutarse directamente desde CMD o PowerShell.

---

# Recomendación

Para mejorar la portabilidad del proyecto se recomienda reemplazar el script por un archivo **`docker-compose.yml`**.

Esto permitiría:

- eliminar la lógica específica de Bash;
- definir servicios, redes y volúmenes mediante YAML;
- ejecutar el proyecto con un único comando:

```bash
docker compose up -d
```

## Ventajas de utilizar Docker Compose

- Compatible con Linux, macOS y Windows.
- No depende de Bash.
- Mejor administración de redes y volúmenes.
- Configuración más clara y fácil de mantener.
- Reduce la cantidad de scripts específicos del sistema operativo.
- Facilita la reutilización y despliegue del proyecto.


# Ejemplo 7 index.php
<img width="1917" height="965" alt="image" src="https://github.com/user-attachments/assets/8928e61b-2309-4be6-937e-874f68909075" />

# Creacion de Tabla
<img width="1919" height="959" alt="image" src="https://github.com/user-attachments/assets/3f28ab02-f266-48b9-b9ff-d19af4ca297d" />
