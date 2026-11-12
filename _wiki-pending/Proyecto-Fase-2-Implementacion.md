> 🗄️ **Base de datos:** `biblioteca_liceo` (Módulo 12 — Proyecto Integrador) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo12/proyecto_integrador.sql)

# 🛠️ Fase 2 — Implementación: crear y poblar la base

Con el diseño de la Fase 1 listo, lo convertimos en SQL (Módulos 4 y 5). Lo importante acá es el **orden**: primero las tablas sin claves foráneas, después las que dependen de ellas.

## Paso 1 — Crear la base

```sql
DROP DATABASE IF EXISTS biblioteca_liceo;
CREATE DATABASE biblioteca_liceo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE biblioteca_liceo;
```

> ⚠️ `DROP DATABASE` borra **toda** la base si existe. Acá lo queremos (el script se puede correr muchas veces), pero nunca lo ejecutes contra una base real sin estar seguro.

## Paso 2 — Tablas sin dependencias primero

`grupo`, `categoria` y `autor` no tienen claves foráneas, así que van primero:

```sql
CREATE TABLE grupo (
    id_grupo INT         NOT NULL AUTO_INCREMENT,
    nombre   VARCHAR(10) NOT NULL,
    turno    VARCHAR(10) NOT NULL DEFAULT 'matutino',
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT uq_grupo_nombre UNIQUE (nombre)
);

CREATE TABLE categoria (
    id_categoria INT         NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(50) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
);

CREATE TABLE autor (
    id_autor INT         NOT NULL AUTO_INCREMENT,
    nombre   VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    CONSTRAINT pk_autor PRIMARY KEY (id_autor)
);
```

## Paso 3 — Tablas con claves foráneas

`estudiante` apunta a `grupo`; `libro` apunta a `categoria`. Las restricciones les ponen nombre (`fk_...`) para que el error sea legible:

```sql
CREATE TABLE estudiante (
    id_estudiante INT         NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(50) NOT NULL,
    apellido      VARCHAR(50) NOT NULL,
    id_grupo      INT         NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT fk_estudiante_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
);

CREATE TABLE libro (
    id_libro     INT          NOT NULL AUTO_INCREMENT,
    titulo       VARCHAR(120) NOT NULL,
    anio         INT,
    id_categoria INT          NOT NULL,
    CONSTRAINT pk_libro PRIMARY KEY (id_libro),
    CONSTRAINT fk_libro_categoria FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria),
    CONSTRAINT chk_libro_anio CHECK (anio BETWEEN 1400 AND 2100)
);
```

## Paso 4 — La tabla intermedia N:M y el resto

`libro_autor` resuelve el N:M con **clave primaria compuesta**. `ejemplar` y `prestamo` cierran el modelo, con un `CHECK` para los estados y otro para las fechas:

```sql
CREATE TABLE libro_autor (
    id_libro INT NOT NULL,
    id_autor INT NOT NULL,
    CONSTRAINT pk_libro_autor PRIMARY KEY (id_libro, id_autor),
    CONSTRAINT fk_la_libro FOREIGN KEY (id_libro) REFERENCES libro (id_libro) ON DELETE CASCADE,
    CONSTRAINT fk_la_autor FOREIGN KEY (id_autor) REFERENCES autor (id_autor)
);

CREATE TABLE ejemplar (
    id_ejemplar INT         NOT NULL AUTO_INCREMENT,
    id_libro    INT         NOT NULL,
    estado      VARCHAR(12) NOT NULL DEFAULT 'disponible',
    CONSTRAINT pk_ejemplar PRIMARY KEY (id_ejemplar),
    CONSTRAINT fk_ejemplar_libro FOREIGN KEY (id_libro) REFERENCES libro (id_libro),
    CONSTRAINT chk_ejemplar_estado CHECK (estado IN ('disponible', 'prestado', 'baja'))
);

CREATE TABLE prestamo (
    id_prestamo              INT  NOT NULL AUTO_INCREMENT,
    id_ejemplar              INT  NOT NULL,
    id_estudiante            INT  NOT NULL,
    fecha_prestamo           DATE NOT NULL,
    fecha_devolucion_pactada DATE NOT NULL,
    fecha_devolucion_real    DATE,
    CONSTRAINT pk_prestamo PRIMARY KEY (id_prestamo),
    CONSTRAINT fk_prestamo_ejemplar   FOREIGN KEY (id_ejemplar)   REFERENCES ejemplar (id_ejemplar),
    CONSTRAINT fk_prestamo_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante (id_estudiante),
    CONSTRAINT chk_prestamo_fechas CHECK (fecha_devolucion_pactada >= fecha_prestamo)
);
```

## Paso 5 — Cargar los datos de prueba

Los `INSERT` van en el mismo orden que las tablas. El N:M de ejemplo: *Poemas de amor* figura con **dos** autores.

```sql
INSERT INTO libro_autor (id_libro, id_autor) VALUES
    (1,1), (2,2), (3,3), (4,4), (5,5), (6,6),
    (6,1);   -- "Poemas de amor" con dos autores
```

El script completo (con todos los `INSERT`, los ejemplares y los préstamos) está en el archivo descargable.

## Paso 6 — Verificar que quedó bien cargado

Después de correr el script, un vistazo rápido para confirmar que todo entró:

```sql
SELECT
    (SELECT COUNT(*) FROM estudiante) AS estudiantes,
    (SELECT COUNT(*) FROM libro)      AS libros,
    (SELECT COUNT(*) FROM ejemplar)   AS ejemplares,
    (SELECT COUNT(*) FROM prestamo)   AS prestamos;
```

**Resultado:**

| estudiantes | libros | ejemplares | prestamos |
| ----------- | ------ | ---------- | --------- |
| 10 | 7 | 12 | 6 |

Y contamos los ejemplares por estado, para ver cuántos quedaron marcados como prestados al cargar los préstamos vigentes:

```sql
SELECT estado, COUNT(*) AS cantidad
FROM ejemplar
GROUP BY estado
ORDER BY estado;
```

**Resultado:**

| estado | cantidad |
| ------ | -------- |
| baja | 1 |
| disponible | 8 |
| prestado | 3 |

> 📌 Hay ejemplares `prestado` porque el script, al final de la carga, marca como prestados los ejemplares que tienen un préstamo sin devolver. En la Fase 3 veremos que eso también lo hace solo un **trigger** cuando se registra un préstamo nuevo.

---

Continuamos con las consultas → [Fase 3: Consultas y automatización](Proyecto-Fase-3-Consultas)

---

## ✍️ Ejercicios

**1.** ¿Por qué `categoria` y `autor` se crean **antes** que `libro`?

<details>
<summary>Ver solución</summary>

Porque `libro` tiene una clave foránea a `categoria` (y se relaciona con `autor` vía `libro_autor`). Una FK **no puede apuntar a una tabla que todavía no existe**: MySQL daría error. Siempre se crean primero las tablas "padre" (sin FK) y después las "hijas".
</details>

**2.** Intentá insertar un libro con un año imposible y explicá qué pasa:
```sql
INSERT INTO libro (titulo, anio, id_categoria) VALUES ('Libro raro', 3000, 1);
```

<details>
<summary>Ver solución</summary>

Falla por la restricción `chk_libro_anio CHECK (anio BETWEEN 1400 AND 2100)`. MySQL devuelve el **Error 3819** (*Check constraint is violated*). La restricción protege los datos de valores sin sentido.
</details>

**3.** Agregá una categoría nueva ("Teatro") y un libro de esa categoría.

<details>
<summary>Ver solución</summary>

```sql
INSERT INTO categoria (nombre) VALUES ('Teatro');
INSERT INTO libro (titulo, anio, id_categoria)
VALUES ('El herrero y la muerte', 1981,
        (SELECT id_categoria FROM categoria WHERE nombre = 'Teatro'));
```
💡 La subconsulta busca el `id_categoria` recién creado sin tener que saberlo de memoria.
</details>

---

## 📋 Palabras clave

`CREATE TABLE` · `orden de creación` · `clave foránea` · `clave compuesta` · `CHECK` · `UNIQUE` · `AUTO_INCREMENT` · `INSERT` · `datos de prueba` · `COUNT`

---

🧠 **[Autoevaluación — Módulo 12](auto-modulo12)**

---

← [Fase 1: Diseño](Proyecto-Fase-1-Diseno) · [🏠 Inicio](Home) · [Fase 3: Consultas →](Proyecto-Fase-3-Consultas)
