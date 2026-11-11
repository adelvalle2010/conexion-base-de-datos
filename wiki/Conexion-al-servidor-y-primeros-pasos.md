# 🔌 Conexión al servidor y primeros pasos

## ¿Por qué lo necesitamos?

El servidor ya está funcionando, pero todavía no le dijimos nada. Para hablarle hay que **conectarse**: decirle en qué computadora está, por qué puerto escucha y quiénes somos.

| Dato | Valor en nuestra instalación | Qué significa |
| ---- | ---------------------------- | ------------- |
| Hostname | `localhost` (o `127.0.0.1`) | El servidor está en esta misma computadora |
| Port | `3306` | La "puerta" por la que escucha MySQL |
| Username | `root` | El usuario administrador |
| Password | La que definiste al configurar | Demuestra que sos ese usuario |

---

## Paso 1 — Abrir la conexión en Workbench

1. Abrí **MySQL Workbench**.
2. En **MySQL Connections** hacé clic en **Local instance MySQL**.
3. Escribí la contraseña de `root`. Podés marcar **Save password in vault** para que no la pida cada vez (solo en tu computadora personal).

Si no aparece ninguna conexión, creala con el botón **+**: nombre `Liceo local`, hostname `localhost`, port `3306`, username `root` → **Test Connection** → **OK**.

> 📌 **Nota:** Workbench puede mostrar un aviso de que la versión del servidor es más nueva que la que él conoce. Para lo que hacemos en este curso alcanza con elegir **Continue Anyway**.

<!-- CAPTURA PENDIENTE: quitar este comentario cuando exista la imagen
<p align="center">
  <img src="https://github.com/adelvalle2010/conexion-base-de-datos/raw/main/imagenes-wiki/parte2-sql/conexion/01-conexion-local.png?raw=true" alt="Cuadro Setup New Connection de MySQL Workbench con hostname localhost, puerto 3306 y usuario root" width="600">
</p>
-->

---

## Paso 2 — Reconocer la pantalla

```text
┌─────────────────────────────────────────────────────────────────┐
│  Barra de herramientas:  📂 abrir   💾 guardar   ⚡ ejecutar     │
├──────────────┬──────────────────────────────────────────────────┤
│  NAVIGATOR   │  EDITOR (Query 1)                                │
│              │  Acá se escribe el SQL                           │
│  SCHEMAS     │                                                  │
│   ▸ sys      ├──────────────────────────────────────────────────┤
│              │  RESULT GRID                                     │
│              │  Acá aparece el resultado, como una tabla        │
├──────────────┴──────────────────────────────────────────────────┤
│  OUTPUT:  ✔ tilde verde = salió bien   ✖ cruz roja = error      │
└─────────────────────────────────────────────────────────────────┘
```

| Zona | Para qué sirve |
| ---- | -------------- |
| **Navigator → Schemas** | Lista de bases de datos del servidor. En MySQL, *schema* y *base de datos* son lo mismo |
| **Editor** | Donde escribimos las sentencias |
| **Result Grid** | El resultado de la última consulta |
| **Output** | El historial: qué se ejecutó, si funcionó y el mensaje de error si falló |

**Cómo ejecutar:**

| Botón | Atajo | Qué ejecuta |
| ----- | ----- | ----------- |
| ⚡ (rayo) | `Ctrl + Shift + Enter` | Todo el editor, o lo que esté seleccionado |
| ⚡ con cursor | `Ctrl + Enter` | Solo la sentencia donde está el cursor |

---

## Paso 3 — Las primeras sentencias

Escribí cada una en el editor y ejecutala con `Ctrl + Enter`.

```sql
SELECT VERSION();
```

**Resultado:** (el número exacto depende de tu instalación)

| VERSION() |
| --------- |
| 8.4.13 |

```sql
SELECT 2 + 3 AS suma;
```

**Resultado:**

| suma |
| ---- |
| 5 |

```sql
SHOW DATABASES;
```

**Resultado:**

| Database |
| -------- |
| information_schema |
| mysql |
| performance_schema |
| sys |

**¿Qué hace exactamente?**

- `SELECT VERSION();` le pregunta al servidor qué versión es. Si responde, la conexión funciona.
- `SELECT 2 + 3 AS suma;` muestra que el servidor también calcula; `AS suma` le pone nombre a la columna del resultado.
- `SHOW DATABASES;` lista las bases que existen. Esas cuatro vienen con MySQL y las usa él para funcionar.
- Cada sentencia termina con **punto y coma**.

> ⚠️ **No toques las bases del sistema** (`mysql`, `sys`, `information_schema`, `performance_schema`). Borrar o modificar algo ahí puede dejar el servidor sin funcionar.

---

## Paso 4 — Ejecutar un script completo

Un **script** es un archivo `.sql` con muchas sentencias. Vamos a cargar el del módulo anterior: [⬇️ liceo_sin_normalizar.sql](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo3/liceo_sin_normalizar.sql).

1. Descargá el archivo (botón **Download raw file** en GitHub).
2. En Workbench: **File → Open SQL Script…** y elegí el archivo.
3. Ejecutá todo con el rayo ⚡ (`Ctrl + Shift + Enter`).
4. En **Output** todas las líneas deben quedar con tilde verde.
5. En **Schemas**, hacé clic en el ícono de refrescar 🔄: aparece `liceo_sin_normalizar`.

Ahora elegimos esa base y miramos qué tiene:

```sql
USE liceo_sin_normalizar;
SHOW TABLES;
```

**Resultado:**

| Tables_in_liceo_sin_normalizar |
| ------------------------------ |
| asignatura |
| docente |
| estudiante |
| inscripcion |
| planilla_notas |
| telefono_estudiante |

```sql
SELECT *
FROM estudiante;
```

**Resultado:**

| id_estudiante | nombre | apellido | grupo |
| ------------- | ------ | -------- | ----- |
| 1 | Lucía | Fernández | 3ºA |
| 2 | Mateo | Silva | 3ºB |
| 3 | Valentina | Rodríguez | 3ºA |

**Elementos clave:**

- `USE` indica con qué base vamos a trabajar. En Workbench, la base activa queda en **negrita** en el panel Schemas (también se elige con doble clic).
- `SHOW TABLES;` lista las tablas de la base activa.
- `SELECT * FROM estudiante;` muestra todas las filas y columnas de una tabla. La vamos a estudiar a fondo en [SELECT: Sintaxis básica](SELECT-sintaxis-basica).

---

## La otra forma de conectarse: la consola

Workbench es cómodo, pero no es el único cliente. El servidor trae uno de texto, que se usa mucho en servidores sin entorno gráfico.

En Windows, buscá en el menú Inicio **MySQL 8.4 Command Line Client**. En Linux o macOS, desde la terminal:

```bash
mysql -u root -p
```

```text
Enter password: ********
mysql> SHOW DATABASES;
mysql> exit
```

| Parte | Significado |
| ----- | ----------- |
| `mysql` | El programa cliente de consola |
| `-u root` | Usuario con el que nos conectamos |
| `-p` | Que pida la contraseña |

Un script también se puede cargar desde la terminal del sistema: `mysql -u root -p < liceo_sin_normalizar.sql`

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1045: Access denied for user 'root'@'localhost'` | Contraseña incorrecta | Revisar mayúsculas y volver a escribirla |
| `Error 2003: Can't connect to MySQL server on 'localhost'` | El servidor está apagado o el puerto es otro | Iniciar el servicio en `services.msc`; revisar el puerto de la conexión |
| `Error 1046: No database selected` | Se consultó una tabla sin elegir base | Ejecutar `USE nombre_base;` o hacer doble clic en la base |
| `Error 1049: Unknown database 'liceo'` | La base no existe o está mal escrita | Revisar el nombre con `SHOW DATABASES;` |
| `Error 1064: You have an error in your SQL syntax` | Falta un punto y coma o hay una palabra mal escrita | Mirar la línea que indica el mensaje, y la anterior |
| Se ejecutó una sola línea del script | Se usó `Ctrl + Enter` en vez del rayo | Ejecutar todo con `Ctrl + Shift + Enter` |

Ya nos conectamos y ejecutamos sentencias sin saber del todo qué eran. Continuamos por el mapa del lenguaje → [¿Qué es SQL? El mapa del lenguaje](Que-es-SQL)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Mostrá cuántas tablas tiene la base `liceo_sin_normalizar` usando solo lo que viste en esta página.

<details>
<summary>Ver solución</summary>

```sql
USE liceo_sin_normalizar;
SHOW TABLES;
```

💡 Son seis: la planilla original y las cinco tablas normalizadas.
</details>

**2.** Mostrá todo el contenido de la tabla `docente`.

<details>
<summary>Ver solución</summary>

```sql
SELECT *
FROM docente;
```

| id_docente | nombre | apellido |
| ---------- | ------ | -------- |
| 1 | Ana | Pereira |
| 2 | Carlos | Méndez |
| 3 | Laura | Sosa |

💡 Si aparece el error 1046, faltó el `USE`.
</details>

**3.** Pedile al servidor que calcule cuántos minutos hay en un día, con una columna llamada `minutos`.

<details>
<summary>Ver solución</summary>

```sql
SELECT 24 * 60 AS minutos;
```

| minutos |
| ------- |
| 1440 |

💡 Un `SELECT` no necesita una tabla: también sirve como calculadora.
</details>

---

## 📋 Palabras clave

`conexión` · `localhost` · `puerto 3306` · `root` · `schema` · `editor` · `Result Grid` · `Output` · `script` · `USE` · `SHOW DATABASES` · `SHOW TABLES` · `SELECT` · `punto y coma` · `consola mysql`

---

🧠 **[Autoevaluación — Módulo 4](auto-modulo4)**

---

← [Instalación de MySQL y Workbench](Instalacion-de-MySQL-y-Workbench) · [🏠 Inicio](Home) · [¿Qué es SQL? El mapa del lenguaje →](Que-es-SQL)
