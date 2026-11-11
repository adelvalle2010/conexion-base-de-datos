> 🗄️ **Base de datos:** `liceo` (Módulo 5 — Definición de Datos) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo5/liceo_ddl.sql)

# 🏗️ CREATE: Crear Bases de Datos y Tablas

En este módulo vamos a construir la base del liceo: pasar del esquema que diseñamos en papel a tablas reales en MySQL. Todavía no cargamos datos; primero se arma la estructura.

## ¿Por qué lo necesitamos?

Este es el diseño al que llegamos en los módulos anteriores:

```text
docente(id_docente PK, nombre, apellido)
estudiante(id_estudiante PK, nombre, apellido, fecha_nacimiento, grupo)
asignatura(id_asignatura PK, nombre, id_docente FK → docente)
inscripcion(id_estudiante PK/FK → estudiante, id_asignatura PK/FK → asignatura, nota)
```

Por ahora es un texto. Para que MySQL pueda guardar estudiantes hay que decirle qué tablas existen, qué columnas tiene cada una y qué tipo de dato admite cada columna. De eso se ocupa el **DDL** (lenguaje de definición de datos), y su sentencia principal es `CREATE`.

**Ventajas de definir la estructura antes de cargar datos:**

- MySQL rechaza lo que no encaja: una fecha en la columna de la nota, un texto donde va un número.
- Todos los que usan la base ven las mismas columnas con los mismos nombres.
- La estructura queda escrita en un script que se puede volver a ejecutar en otra computadora.

---

## Sintaxis

```sql
CREATE DATABASE <nombre_base>;

CREATE TABLE <nombre_tabla> (
    <columna_1> <TIPO> <restricciones>,
    <columna_2> <TIPO> <restricciones>,
    ...
    <restricciones de tabla>
);
```

### Anatomía de la sentencia

```text
CREATE TABLE docente (                              ← nombre de la tabla, en singular
    id_docente INT         NOT NULL AUTO_INCREMENT, ← columna · tipo · restricciones
    nombre     VARCHAR(50) NOT NULL,                ← las columnas se separan con coma
    apellido   VARCHAR(50) NOT NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_docente)  ← restricción de tabla (sin coma al final)
);                                                  ← paréntesis de cierre y punto y coma
```

| Parte | Descripción |
| ----- | ----------- |
| Nombre de columna | En minúscula, con guion bajo: `fecha_nacimiento` |
| Tipo | Qué clase de valor admite: los viste en [Tipos de Datos en MySQL](Tipos-de-datos-en-MySQL) |
| `NOT NULL` | La columna no puede quedar vacía |
| `CONSTRAINT … PRIMARY KEY` | Indica la clave primaria; la explicamos en la [página siguiente](Claves-primarias-y-foraneas) |

---

## Paso 1 — Crear la base de datos

```sql
CREATE DATABASE liceo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

```sql
SHOW DATABASES;
```

**Resultado:**

| Database |
| -------- |
| information_schema |
| liceo |
| liceo_sin_normalizar |
| mysql |
| performance_schema |
| sys |

**Elementos clave:**

- `CHARACTER SET utf8mb4` indica con qué juego de caracteres se guardan los textos. `utf8mb4` admite tildes, eñes y emojis: con él, "Lucía" y "Rodríguez" se guardan bien.
- `COLLATE utf8mb4_unicode_ci` define cómo se **comparan** y ordenan los textos. La terminación `_ci` significa que no distingue mayúsculas de minúsculas.
- `liceo_sin_normalizar` aparece solo si cargaste el script del Módulo 3.

> 📌 **Nota:** en MySQL 8, `utf8mb4` ya es el juego de caracteres por defecto. Lo escribimos igual para que el script funcione igual en cualquier instalación.

---

## Paso 2 — Elegir la base

```sql
USE liceo;
```

Todo lo que se cree a partir de ahora queda dentro de `liceo`. Si te olvidás de este paso, MySQL responde `Error 1046: No database selected`.

---

## Paso 3 — Crear la primera tabla

Empezamos por `docente`, que no depende de ninguna otra.

```sql
CREATE TABLE docente (
    id_docente INT         NOT NULL AUTO_INCREMENT,
    nombre     VARCHAR(50) NOT NULL,
    apellido   VARCHAR(50) NOT NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_docente)
);
```

Para ver cómo quedó, usamos `DESCRIBE`:

```sql
DESCRIBE docente;
```

**Resultado:**

| Field | Type | Null | Key | Default | Extra |
| ----- | ---- | ---- | --- | ------- | ----- |
| id_docente | int | NO | PRI | NULL | auto_increment |
| nombre | varchar(50) | NO | | NULL | |
| apellido | varchar(50) | NO | | NULL | |

**¿Qué hace exactamente?**

- `Field` y `Type` muestran cada columna con su tipo.
- `Null = NO` significa que la columna es obligatoria (`NOT NULL`).
- `Key = PRI` marca la clave primaria.
- La tabla existe, pero está **vacía**: `CREATE TABLE` crea la estructura, no las filas.

---

## Paso 4 — Una tabla con más tipos de datos

```sql
CREATE TABLE estudiante (
    id_estudiante    INT         NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(50) NOT NULL,
    apellido         VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE        NOT NULL,
    grupo            VARCHAR(10) NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante)
);
```

```sql
SHOW TABLES;
```

**Resultado:**

| Tables_in_liceo |
| --------------- |
| docente |
| estudiante |

**Elementos clave:**

- `DATE` guarda fechas con el formato `'AAAA-MM-DD'`, por ejemplo `'2009-03-14'`.
- `VARCHAR(10)` alcanza para un grupo como `3ºA`. El número es el **máximo** de caracteres, no un largo fijo.
- Alinear tipos y restricciones en columnas no es obligatorio, pero hace que el script se lea de un vistazo.

---

## Paso 5 — Scripts que se pueden volver a ejecutar

Si ejecutás dos veces el mismo `CREATE`, la segunda falla porque el objeto ya existe. Hay dos formas de evitarlo:

```sql
-- ❌ La segunda vez da Error 1050: Table 'docente' already exists
CREATE TABLE docente ( ... );

-- ✅ Si ya existe, no hace nada (y no da error)
CREATE TABLE IF NOT EXISTS docente ( ... );
```

```sql
-- ✅ Al principio de un script: borra y vuelve a crear todo desde cero
DROP DATABASE IF EXISTS liceo;
CREATE DATABASE liceo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE liceo;
```

> ⚠️ **Cuidado con `DROP DATABASE`:** elimina la base con **todas sus tablas y todos sus datos**, sin pedir confirmación y sin papelera. En un script de práctica es cómodo; en una base con datos reales es un desastre. Lo vemos en detalle en [ALTER, DROP y TRUNCATE](ALTER-DROP-y-TRUNCATE).

---

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1007: Can't create database 'liceo'; database exists` | La base ya fue creada | Usar `CREATE DATABASE IF NOT EXISTS` o continuar con `USE liceo;` |
| `Error 1050: Table 'docente' already exists` | La tabla ya fue creada | Usar `IF NOT EXISTS`, o borrar la tabla si se quiere rehacer |
| `Error 1046: No database selected` | Falta el `USE liceo;` | Ejecutarlo antes del `CREATE TABLE` |
| `Error 1064` cerca de `)` | Sobra una coma después de la última línea | La última línea antes del paréntesis de cierre no lleva coma |
| `Error 1064` cerca del nombre de una columna | El nombre es una palabra reservada (`order`, `group`, `key`) | Elegir otro nombre: `grupo`, `orden`, `clave` |
| Los textos con tilde se ven como `LucÃ­a` | La base o la conexión no usan `utf8mb4` | Crear la base con `CHARACTER SET utf8mb4` |

---

Continuamos por lo que hace que las tablas estén conectadas → [Claves Primarias (PK) y Foráneas (FK)](Claves-primarias-y-foraneas)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Trabajá en una base aparte para no mezclar con el liceo:

```sql
CREATE DATABASE IF NOT EXISTS practica;
USE practica;
```

**1.** Creá la tabla `libro` con un identificador entero autonumérico, un título de hasta 100 caracteres y un año de publicación (entero). El título es obligatorio; el año puede faltar.

<details>
<summary>Ver solución</summary>

```sql
CREATE TABLE libro (
    id_libro INT          NOT NULL AUTO_INCREMENT,
    titulo   VARCHAR(100) NOT NULL,
    anio     INT,
    CONSTRAINT pk_libro PRIMARY KEY (id_libro)
);
```

💡 Una columna sin `NOT NULL` admite `NULL`. Se usa `anio` y no `año` para evitar problemas con la eñe en nombres de columnas.
</details>

**2.** Mostrá la estructura de la tabla que acabás de crear.

<details>
<summary>Ver solución</summary>

```sql
DESCRIBE libro;
```

| Field | Type | Null | Key | Default | Extra |
| ----- | ---- | ---- | --- | ------- | ----- |
| id_libro | int | NO | PRI | NULL | auto_increment |
| titulo | varchar(100) | NO | | NULL | |
| anio | int | YES | | NULL | |

💡 `Null = YES` en `anio`: es la única columna opcional.
</details>

**3.** Creá la tabla `socio` con identificador autonumérico, nombre, apellido (ambos obligatorios, hasta 50 caracteres) y fecha de alta obligatoria. Escribila de forma que el script se pueda ejecutar dos veces sin dar error.

<details>
<summary>Ver solución</summary>

```sql
CREATE TABLE IF NOT EXISTS socio (
    id_socio   INT         NOT NULL AUTO_INCREMENT,
    nombre     VARCHAR(50) NOT NULL,
    apellido   VARCHAR(50) NOT NULL,
    fecha_alta DATE        NOT NULL,
    CONSTRAINT pk_socio PRIMARY KEY (id_socio)
);
```

💡 `IF NOT EXISTS` no actualiza la tabla si ya existe con otra estructura: simplemente no hace nada.
</details>

---

## 📋 Palabras clave

`DDL` · `CREATE DATABASE` · `CREATE TABLE` · `USE` · `DESCRIBE` · `SHOW TABLES` · `IF NOT EXISTS` · `DROP DATABASE` · `utf8mb4` · `COLLATE` · `NOT NULL` · `VARCHAR` · `DATE` · `INT` · `script`

---

🧠 **[Autoevaluación — Módulo 5](auto-modulo5)**

---

← [Resumen del Módulo 4](Resumen-Modulo4) · [🏠 Inicio](Home) · [Claves Primarias (PK) y Foráneas (FK) →](Claves-primarias-y-foraneas)
