# DOCKER Tutorial

2DAW Tutorial de Docker para el desarrollo avanzado de código.

![GitHub](https://img.shields.io/github/last-commit/joseluisgs/docker-tutorial)

![assets/image.png](https://laenredadera.net/wp-content/uploads/2018/01/docker.png)

- [DOCKER Tutorial](#docker-tutorial)
  - [Acerca de](#acerca-de)
  - [Contenidos](#contenidos)
  - [Colaborar o nuevos contenidos o ejemplos](#colaborar-o-nuevos-contenidos-o-ejemplos)
    - [¿Cómo colaborar o corregir un cambio?](#cómo-colaborar-o-corregir-un-cambio)
  - [Autor](#autor)
    - [Contacto](#contacto)
  - [Licencia](#licencia)

## Acerca de

Tutorial de Docker de supervivencia a 2DAW. Ejemplos usados en clase.
Aprenderemos a manejar imagenes y contenedores y cómo aplicarlos para mejorar en el desarrollo de software.
Siempre con el objetivo de poder crear un entorno que podamos comaprtir y facilitar el despliegue de nuestro proyecto.

## Contenidos
- ¿Qué es Docker?
- Instalación
- Comandos básicos
- Ejecutando contenedores
- Dockerfile y nuestras imágenes
- Persistencia de datos
- Enlazando contenedores
- Docker Compose
- Docker Hub
- Despliegue con Docker Hub y GitHub
- Trucos y consejos
- Optimización
- Herramientas para Docker
- Docker Swarm


## Colaborar o nuevos contenidos o ejemplos

### ¿Cómo colaborar o corregir un cambio?

Para solicitar un cambio o ayudarme a pulir errores o a mejorar el contenido del curso y las transparencias lo podéis hacer de la siguiente manera:

- Siempre debéis hacer un fork del proyecto para trabajar con él.
- Lo primero es crear una rama con tu nombre de usuario de GitHub (vamos a ser ordenados)
- En la carpeta updates de tu rama añadís un fichero con vuestro nombre de GitHub para que en dicho fichero vayáis actualizando con las cosas que queráis aportar. Este fichero debe estar redactado usando [markdown](https://www.markdownguide.org/basic-syntax/).
  - Indicáis el número de la página de la presentación (por ejemplo página 34). Indicáis el texto y remarcáis la palabra o error detectado.
  - De la misma manera si queréis incorporar un gráfico o figura lo indicáis en qué página, o si es nueva donde iría y subís ese recurso en la carpeta updates.
  - También podéis aportar referencias, herramientas y cosas útiles que os han servidor para dominar Git y GitHub.
- Posteriormente hacéis un commit en vuestro repositorio y luego un pull request de los cambios indicados en tu rama y en la conversación me detallas algo de información y si el cambio se aprueba lo verás en la próxima versión Mira este [vídeo](https://www.youtube.com/watch?v=_M8oalUyz10) y este [otro](https://www.youtube.com/watch?v=QntLv5BjUr0).

Gracias por colaborar y entre todos mejoramos usando GitHub. Espero vuestros pull requests :smile:

## Autor

Codificado con :sparkling_heart: por [José Luis González Sánchez](https://twitter.com/joseluisgonsan)

[![Twitter](https://img.shields.io/twitter/follow/joseluisgonsan?style=social)](https://twitter.com/joseluisgonsan)
[![GitHub](https://img.shields.io/github/followers/joseluisgs?style=social)](https://github.com/joseluisgs)

### Contacto
<p>
  Cualquier cosa que necesites házmelo saber por si puedo ayudarte 💬.
</p>
<p>
    <a href="https://twitter.com/joseluisgonsan" target="_blank">
        <img src="https://pitlochryfestivaltheatre.com/wp-content/uploads/2020/04/2-27646_twitter-logo-png-transparent-background-logo-twitter-png.png" 
    height="30">
    </a> &nbsp;&nbsp;
    <a href="https://github.com/joseluisgs" target="_blank">
        <img src="https://cdn.iconscout.com/icon/free/png-256/github-153-675523.png" 
    height="30">
    </a> &nbsp;&nbsp;
    <a href="https://www.linkedin.com/in/joseluisgonsan" target="_blank">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/LinkedIn_logo_initials.png/768px-LinkedIn_logo_initials.png" 
    height="30">
    </a>  &nbsp;&nbsp;
    <a href="https://joseluisgs.github.io/" target="_blank">
        <img src="https://www.lazaroamor.es/img/develop.png" 
    height="30">
    </a>
</p>

## Licencia

Este proyecto esta licenciado bajo licencia **MIT**, si desea saber más, visite el fichero
[LICENSE](./LICENSE) para su uso docente y educativo.

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

# Ejemplo 2 Corriendo
<img width="1914" height="995" alt="image" src="https://github.com/user-attachments/assets/3132437b-ba7a-4543-b7d7-a86b509b60f2" />

# Ejemplo 1 del index.html
<img width="1545" height="924" alt="image" src="https://github.com/user-attachments/assets/e9f69a12-b69f-4f2e-9f57-779ce96cdf17" />

#Ejemplo 7 index.php
<img width="1917" height="965" alt="image" src="https://github.com/user-attachments/assets/8928e61b-2309-4be6-937e-874f68909075" />

#Creacion de Tabla
<img width="1919" height="959" alt="image" src="https://github.com/user-attachments/assets/3f28ab02-f266-48b9-b9ff-d19af4ca297d" />
