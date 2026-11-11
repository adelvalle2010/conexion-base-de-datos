# 🛠️ Instalación de MySQL y Workbench

En este módulo vamos a dejar la computadora lista para trabajar: instalar el servidor de base de datos, instalar el programa con el que le vamos a escribir, y comprobar que los dos se entienden.

## ¿Por qué lo necesitamos?

Hasta ahora diseñamos en papel. Para crear las tablas del liceo de verdad hacen falta **dos programas distintos**, y conviene no confundirlos:

| Programa | Qué es | Analogía |
| -------- | ------ | -------- |
| **MySQL Server** | El SGBD: guarda los datos y responde las consultas. No tiene ventanas; trabaja "de fondo" | La cocina del restaurante |
| **MySQL Workbench** | Un cliente gráfico: la ventana donde escribimos SQL y vemos los resultados | El mozo que lleva el pedido y trae el plato |

> 💡 Workbench **no** es la base de datos. Si desinstalás Workbench, tus datos siguen en el servidor. Si el servidor está apagado, Workbench no tiene con quién hablar.

## Requisitos que vamos a necesitar

1. Una computadora con Windows 10 u 11 de 64 bits (más abajo hay indicaciones para Linux y macOS).
2. Permisos de administrador para instalar programas.
3. Conexión a internet para la descarga.

## ¿Qué versión instalar?

En la página de descargas vas a ver varias versiones. La que usamos en esta wiki es **MySQL 8.4 LTS**.

| Lo que dice la página | Qué significa | ¿La elegimos? |
| --------------------- | ------------- | ------------- |
| **LTS** (por ejemplo 8.4) | Versión de soporte largo: estable, solo recibe correcciones | ✅ Sí |
| **Innovation** | Versión con las novedades más recientes, cambia cada pocos meses | ❌ No para aprender |
| 8.0 | Versión anterior, ya sin soporte | ❌ No |

> 📌 **Nota:** si en tu centro ya está instalada otra versión LTS más nueva, sirve igual: todo lo que vemos en este curso es SQL que funciona en cualquiera de ellas.

---

## Paso 1 — Descargar MySQL Server

1. Entrá a [dev.mysql.com/downloads/mysql](https://dev.mysql.com/downloads/mysql/).
2. En **Select Version** elegí la versión **8.4 LTS**.
3. En **Select Operating System** elegí **Microsoft Windows**.
4. Descargá el **MSI Installer**.
5. La página ofrece crear una cuenta de Oracle. No hace falta: hacé clic en **No thanks, just start my download**.

<!-- CAPTURA PENDIENTE: quitar este comentario cuando exista la imagen
<p align="center">
  <img src="https://github.com/adelvalle2010/conexion-base-de-datos/raw/main/imagenes-wiki/parte2-sql/instalacion/01-descarga-mysql.png?raw=true" alt="Página de descargas de MySQL Community Server con la versión 8.4 LTS y el instalador MSI para Windows seleccionados" width="600">
</p>
-->

---

## Paso 2 — Instalar el servidor

1. Abrí el archivo `.msi` descargado.
2. Aceptá la licencia y elegí el tipo de instalación **Typical**.
3. Hacé clic en **Install** y esperá.
4. En la última pantalla dejá marcada la opción **Run MySQL Configurator** y hacé clic en **Finish**.

> ⚠️ **Si el instalador pide "Microsoft Visual C++ Redistributable":** es un componente de Windows que MySQL necesita. Instalalo desde la página de Microsoft y volvé a ejecutar el `.msi`.

---

## Paso 3 — Configurar el servidor

El servidor no arranca hasta que se configura. De eso se encarga **MySQL Configurator**, que se abre solo al terminar el paso anterior (también queda en el menú Inicio).

| Pantalla | Qué elegir | Por qué |
| -------- | ---------- | ------- |
| Data Directory | Dejar la carpeta propuesta | Es donde se guardan las bases |
| Type and Networking | **Development Computer**, puerto **3306** | Usa pocos recursos; 3306 es el puerto estándar de MySQL |
| Accounts and Roles | Escribir una contraseña para **root** | `root` es el usuario administrador |
| Windows Service | Dejar marcado **Start the MySQL Server at System Startup** | El servidor arranca solo con Windows |
| Apply Configuration | **Execute** | Aplica todo; cada paso debe quedar con un tilde verde |

<!-- CAPTURA PENDIENTE: quitar este comentario cuando exista la imagen
<p align="center">
  <img src="https://github.com/adelvalle2010/conexion-base-de-datos/raw/main/imagenes-wiki/parte2-sql/instalacion/02-configurator-root.png?raw=true" alt="Pantalla Accounts and Roles de MySQL Configurator con el campo para definir la contraseña del usuario root" width="600">
</p>
-->

> ⚠️ **Anotá la contraseña de root.** No hay un "olvidé mi contraseña" sencillo: si la perdés, lo más práctico suele ser reconfigurar o reinstalar. En el laboratorio, usá la que indique tu docente.

---

## Paso 4 — Instalar MySQL Workbench

1. Entrá a [dev.mysql.com/downloads/workbench](https://dev.mysql.com/downloads/workbench/).
2. Elegí **Microsoft Windows** y descargá el instalador MSI (otra vez, **No thanks, just start my download**).
3. Ejecutalo con las opciones por defecto: **Next** → **Complete** → **Install** → **Finish**.

<!-- CAPTURA PENDIENTE: quitar este comentario cuando exista la imagen
<p align="center">
  <img src="https://github.com/adelvalle2010/conexion-base-de-datos/raw/main/imagenes-wiki/parte2-sql/instalacion/03-workbench-inicio.png?raw=true" alt="Pantalla de inicio de MySQL Workbench con la conexión Local instance en la sección MySQL Connections" width="600">
</p>
-->

---

## Paso 5 — Comprobar que el servidor está funcionando

1. Presioná `Windows + R`, escribí `services.msc` y aceptá.
2. Buscá el servicio cuyo nombre empieza con **MySQL** (por ejemplo `MySQL84`).
3. En la columna **Estado** debe decir **En ejecución**.

Si dice otra cosa, hacé clic derecho sobre el servicio → **Iniciar**.

---

## Otros sistemas operativos

| Sistema | Servidor | Workbench |
| ------- | -------- | --------- |
| Ubuntu / Debian | `sudo apt install mysql-server` | Paquete `.deb` desde la página de descargas de Workbench |
| macOS | Archivo DMG desde la página de descargas | Archivo DMG desde la página de descargas |

```bash
# Ubuntu / Debian: instalar y comprobar que el servicio está activo
sudo apt update
sudo apt install mysql-server
sudo systemctl status mysql
```

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| El instalador se cierra pidiendo Visual C++ | Falta el componente de Microsoft | Instalar "Microsoft Visual C++ Redistributable" y reintentar |
| Configurator avisa que el puerto 3306 está en uso | Ya hay otro MySQL o MariaDB instalado (por ejemplo, el de XAMPP) | Detener el otro servidor o usar otro puerto, como 3307, y recordarlo al conectar |
| El servicio MySQL no aparece en `services.msc` | No se ejecutó MySQL Configurator | Abrir **MySQL Configurator** desde el menú Inicio y completar el paso 3 |
| Workbench abre pero no hay ninguna conexión | Se instaló Workbench antes que el servidor | Crear la conexión a mano: lo vemos en la página siguiente |

Continuamos por la primera conexión → [Conexión al servidor y primeros pasos](Conexion-al-servidor-y-primeros-pasos)

---

## 📋 Palabras clave

`MySQL Server` · `MySQL Workbench` · `servidor` · `cliente` · `LTS` · `Innovation` · `MSI` · `MySQL Configurator` · `root` · `puerto 3306` · `servicio de Windows` · `services.msc` · `Development Computer`

---

🧠 **[Autoevaluación — Módulo 4](auto-modulo4)**

---

← [Resumen del Módulo 3](Resumen-Modulo3) · [🏠 Inicio](Home) · [Conexión al servidor y primeros pasos →](Conexion-al-servidor-y-primeros-pasos)
