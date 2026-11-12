# 📖 Anexo: Glosario

Los términos del curso, en una línea cada uno. Ordenados alfabéticamente para buscar rápido.

> 🗒️ Si un término tiene su propia página, está enlazado.

---

## A
- **Atributo** — una característica de una entidad (ej. el `nombre` de un estudiante). En las tablas, una columna.
- **AUTO_INCREMENT** — propiedad de MySQL que numera sola una columna (1, 2, 3…), usada en las claves primarias.
- **Alias** — nombre corto que se le da a una tabla o columna en una consulta con `AS` (ej. `estudiante AS e`).

## B
- **Base de datos** — conjunto organizado de datos relacionados, guardados sin repetirlos.
- **BCNF** — forma normal de Boyce-Codd, una versión más estricta de la 3FN.

## C
- **Cardinalidad** — cuántas filas de una tabla se relacionan con otra: 1:1, 1:N o N:M.
- **CHECK** — restricción que obliga a que un valor cumpla una condición (ej. `anio BETWEEN 1400 AND 2100`).
- **Clave primaria (PK)** — columna(s) que identifican de forma única cada fila.
- **Clave foránea (FK)** — columna que apunta a la clave primaria de otra tabla, creando la relación.
- **Clave compuesta** — clave primaria formada por más de una columna (ej. `libro_autor`).
- **Consulta** — una instrucción `SELECT` que pide datos a la base.

## D
- **DDL** — *Data Definition Language*: las sentencias que definen la estructura (`CREATE`, `ALTER`, `DROP`).
- **DML** — *Data Manipulation Language*: las que mueven datos (`INSERT`, `UPDATE`, `DELETE`).
- **DQL** — *Data Query Language*: la consulta (`SELECT`).
- **Dato** — un valor suelto sin contexto (ej. "15"). La **información** es el dato interpretado ("15 años").

## E
- **Entidad** — una cosa del mundo real de la que guardamos datos (ej. `ESTUDIANTE`). En las tablas, una tabla.
- **Entidad débil** — entidad que no existe sin otra (ej. un `EJEMPLAR` sin su `LIBRO`).

## F
- **Forma normal (1FN, 2FN, 3FN)** — reglas para organizar las tablas y evitar datos repetidos.

## G
- **GROUP BY** — agrupa filas que comparten un valor para aplicarles una función (`COUNT`, `SUM`…).

## H
- **HAVING** — filtra **grupos** después de un `GROUP BY` (mientras que `WHERE` filtra filas).

## I
- **Índice** — estructura que acelera las búsquedas en una columna, como el índice de un libro.
- **InnoDB** — el motor de almacenamiento de MySQL que soporta claves foráneas y transacciones.

## J
- **JOIN** — combina filas de dos o más tablas. `INNER` (solo coincidencias), `LEFT`/`RIGHT` (incluye las no coincidentes de un lado).

## M
- **MER** — Modelo Entidad-Relación: el diagrama del diseño conceptual (ver [Notaciones de diagramas](Anexo-Notaciones-de-diagramas)).
- **MySQL** — el sistema gestor de bases de datos (SGBD) que usamos en el curso.

## N
- **N:M** — relación "muchos a muchos"; al pasar a tablas se resuelve con una **tabla intermedia**.
- **NOT NULL** — restricción que obliga a que una columna tenga siempre un valor.
- **Normalización** — proceso de organizar las tablas aplicando las formas normales.
- **NULL** — ausencia de valor (no es cero ni vacío). Se compara con `IS NULL`.

## P
- **Procedimiento almacenado** — bloque de SQL guardado en la base con un nombre, que se ejecuta con `CALL` (ej. `sp_prestar`).

## R
- **Registro** — una fila de una tabla.
- **Relación** — vínculo entre entidades (ej. un estudiante *presta* un ejemplar).
- **ROLLBACK** — deshace los cambios de una transacción.
- **Restricción (constraint)** — regla que protege los datos (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`).

## S
- **SGBD** — Sistema Gestor de Base de Datos (ej. MySQL, PostgreSQL).
- **SQL** — *Structured Query Language*, el lenguaje para hablar con la base.
- **Subconsulta** — una consulta dentro de otra, entre paréntesis.

## T
- **Tabla** — estructura de filas y columnas donde se guardan los datos de una entidad.
- **Tabla intermedia** — tabla que resuelve una relación N:M (ej. `libro_autor`, `prestamo`).
- **Transacción** — grupo de operaciones que se confirman juntas (`COMMIT`) o se deshacen juntas (`ROLLBACK`).
- **Trigger (disparador)** — bloque de SQL que se ejecuta solo ante un evento (ej. al insertar un préstamo).
- **TRUNCATE** — vacía una tabla por completo (más rápido que `DELETE` sin `WHERE`).

## U
- **UNIQUE** — restricción que impide valores repetidos en una columna.
- **UPDATE** — modifica datos ya existentes (¡siempre con `WHERE`!).

## V
- **Vista (view)** — consulta guardada con nombre, que se usa como si fuera una tabla.

---

← [Buenas prácticas](Anexo-Buenas-practicas) · [🏠 Inicio](Home)
