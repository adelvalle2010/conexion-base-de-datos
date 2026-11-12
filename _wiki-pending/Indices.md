> 🗄️ **Base de datos:** `liceo_grande` (Módulo 9 — Rendimiento y Transacciones) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo9/liceo_grande.sql)

# ⚡ Índices

En este módulo vamos a ocuparnos de dos cosas que no se notan con 10 estudiantes y sí con 100.000: que las consultas sigan siendo **rápidas** y que los datos sigan siendo **correctos** cuando varias personas los modifican a la vez. Empezamos por la velocidad.

## Requisitos que vamos a necesitar

1. MySQL 8 y Workbench funcionando ([Instalación de MySQL y Workbench](Instalacion-de-MySQL-y-Workbench)).
2. Saber consultar con `WHERE`, `ORDER BY` y `JOIN` (Módulos 7 y 8).
3. Cargar el script `liceo_grande.sql`: abrirlo en Workbench (**File → Open SQL Script**) y ejecutarlo completo con el rayo ⚡. Tarda unos segundos.

`liceo_grande` tiene **las mismas tablas** que `liceo`, con muchos más datos:

```sql
SELECT (SELECT COUNT(*) FROM grupo)       AS grupos,
       (SELECT COUNT(*) FROM docente)     AS docentes,
       (SELECT COUNT(*) FROM asignatura)  AS asignaturas,
       (SELECT COUNT(*) FROM estudiante)  AS estudiantes,
       (SELECT COUNT(*) FROM inscripcion) AS inscripciones;
```

**Resultado:**

| grupos | docentes | asignaturas | estudiantes | inscripciones |
| ------ | -------- | ----------- | ----------- | ------------- |
| 120 | 30 | 12 | 100000 | 400000 |

> 📌 **Nota:** los datos se generan con fórmulas, no al azar, así que todos tenemos exactamente las mismas filas. Los nombres se repiten mucho: hay 50 apellidos y 40 nombres combinados.

## ¿Por qué lo necesitamos?

¿Cuántos estudiantes se apellidan Núñez?

```sql
SELECT COUNT(*) AS cantidad
FROM estudiante
WHERE apellido = 'Núñez';
```

**Resultado:**

| cantidad |
| -------- |
| 2000 |

Para responder, MySQL tuvo que leer **las 100.000 filas**, una por una, y fijarse en el apellido de cada una. No tiene otra forma de saber dónde están los Núñez: la tabla está ordenada por `id_estudiante`, no por apellido.

Es como buscar en un libro todas las páginas que hablan de "normalización" sin usar el índice del final: hay que leerlo entero. Con el índice alfabético se va directo a la palabra, que dice "páginas 41, 42 y 57".

> **¿Qué es un índice?** Es una estructura aparte de la tabla que guarda los valores de una o más columnas **ordenados**, y junto a cada valor, la ubicación de la fila a la que pertenece. Como está ordenado, MySQL encuentra un valor en pocos pasos en lugar de recorrer toda la tabla.

```text
 Índice sobre apellido (ordenado)                Tabla estudiante (ordenada por id)
┌───────────┬───────────────┐                   ┌───────────────┬──────────┬───────────┐
│ apellido  │ id_estudiante │                   │ id_estudiante │ nombre   │ apellido  │
├───────────┼───────────────┤                   ├───────────────┼──────────┼───────────┤
│ Acosta    │ 17            │                   │ 1             │ Mateo    │ Castro    │
│ Acosta    │ 67            │              ┌──▶ │ 37            │ Sebastián│ Núñez     │
│ ...       │ ...           │              │    │ ...           │ ...      │ ...       │
│ Núñez     │ 37  ──────────┼──────────────┘┌─▶ │ 87            │ Martina  │ Núñez     │
│ Núñez     │ 87  ──────────┼───────────────┘   │ ...           │ ...      │ ...       │
│ ...       │ ...           │                   │ 100000        │ ...      │ ...       │
└───────────┴───────────────┘                   └───────────────┴──────────┴───────────┘
  salto directo a "Núñez"                         solo se leen las filas que sirven
```

**Ventajas:**

- Las búsquedas, los `JOIN` y los ordenamientos por esa columna leen muchas menos filas.
- No cambia nada en las consultas: se escriben igual, MySQL decide solo cuándo usar el índice.

---

## Sintaxis

```sql
CREATE INDEX <nombre_indice> ON <tabla> (<columna>);
```

| Sentencia | Para qué sirve |
| --------- | -------------- |
| `CREATE INDEX nombre ON tabla (columna)` | Crea un índice |
| `CREATE INDEX nombre ON tabla (col1, col2)` | Crea un índice compuesto |
| `CREATE UNIQUE INDEX nombre ON tabla (columna)` | Crea un índice que además prohíbe repetidos |
| `ALTER TABLE tabla ADD INDEX nombre (columna)` | Otra forma de crear un índice |
| `SHOW INDEX FROM tabla` | Lista los índices de la tabla |
| `DROP INDEX nombre ON tabla` | Elimina el índice (los datos no se tocan) |

> 📌 **Nota:** en este curso los índices se llaman `idx_<tabla>_<columna>`, y los únicos, `uq_<tabla>_<columna>`.

---

## Paso 1 — Los índices que ya existen

```sql
SHOW INDEX FROM estudiante;
```

**Resultado** (columnas principales):

| Table | Non_unique | Key_name | Seq_in_index | Column_name |
| ----- | ---------- | -------- | ------------ | ----------- |
| estudiante | 0 | PRIMARY | 1 | id_estudiante |
| estudiante | 1 | fk_estudiante_grupo | 1 | id_grupo |

Sin que lo pidiéramos, la tabla ya tiene dos índices:

- **`PRIMARY`**: toda clave primaria tiene un índice. Por eso buscar por `id_estudiante` siempre fue instantáneo.
- **`fk_estudiante_grupo`**: MySQL crea un índice para cada clave foránea, para que los `JOIN` sean rápidos.

Las restricciones `UNIQUE` también generan uno. `Non_unique = 0` significa que el índice no admite valores repetidos.

---

## Paso 2 — Ver cómo trabaja MySQL sin índice

Anteponiendo `EXPLAIN` a una consulta, MySQL no la ejecuta: cuenta **cómo piensa resolverla**. La página siguiente está dedicada a esta herramienta; por ahora miramos tres columnas.

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido = 'Núñez';
```

**Resultado** (columnas principales):

| table | type | possible_keys | key | rows |
| ----- | ---- | ------------- | --- | ---- |
| estudiante | ALL | NULL | NULL | 100165 |

| Columna | Qué dice |
| ------- | -------- |
| `type = ALL` | Va a recorrer **toda** la tabla |
| `key = NULL` | No usa ningún índice |
| `rows` | Cuántas filas calcula que tiene que leer: todas |

> 📌 **Nota:** `rows` es una estimación. Puede que en tu equipo no diga exactamente lo mismo; lo que importa es el orden de magnitud.

Comparemos con una búsqueda por clave primaria:

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE id_estudiante = 54321;
```

**Resultado:**

| table | type | possible_keys | key | rows |
| ----- | ---- | ------------- | --- | ---- |
| estudiante | const | PRIMARY | PRIMARY | 1 |

Una sola fila leída, gracias al índice `PRIMARY`.

---

## Paso 3 — Crear un índice

```sql
CREATE INDEX idx_estudiante_apellido ON estudiante (apellido);
```

La misma consulta de antes:

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido = 'Núñez';
```

**Resultado:**

| table | type | possible_keys | key | rows |
| ----- | ---- | ------------- | --- | ---- |
| estudiante | ref | idx_estudiante_apellido | idx_estudiante_apellido | 2000 |

De 100.000 filas leídas a 2.000, que son exactamente las que hay que devolver. El `type` pasó de `ALL` a `ref`: búsqueda por un valor en un índice.

---

## Paso 4 — Índice compuesto

Ahora buscamos por apellido **y** nombre:

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido = 'Núñez'
  AND nombre = 'Agustín';
```

**Resultado:**

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ref | idx_estudiante_apellido | 2000 | Using where |

El índice ayuda a llegar a los 2.000 Núñez, pero después hay que leerlos todos para quedarse con los Agustín (`Using where`). Un **índice compuesto** ordena por las dos columnas a la vez:

```sql
CREATE INDEX idx_estudiante_apellido_nombre ON estudiante (apellido, nombre);
```

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido = 'Núñez'
  AND nombre = 'Agustín';
```

**Resultado:**

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ref | idx_estudiante_apellido_nombre | 50 | NULL |

Ahora lee solo las 50 filas que hay que devolver.

### El orden de las columnas importa

Un índice sobre `(apellido, nombre)` está ordenado como una guía telefónica: por apellido y, a igual apellido, por nombre.

```text
(Acosta, Abril) (Acosta, Agustín) ... (Núñez, Abril) (Núñez, Agustín) (Núñez, Agustina) ... (Varela, Victoria)
```

Sirve para buscar por apellido, o por apellido y nombre. **No** sirve para buscar solo por nombre: los Agustín están desparramados por toda la guía.

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE nombre = 'Agustín';
```

**Resultado:**

| table | type | possible_keys | key | rows |
| ----- | ---- | ------------- | --- | ---- |
| estudiante | ALL | NULL | NULL | 100165 |

> 💡 **Regla del prefijo izquierdo:** un índice sobre `(a, b, c)` se puede usar para condiciones sobre `a`, sobre `a` y `b`, o sobre `a`, `b` y `c`. No para `b` sola ni para `c` sola.

---

## Paso 5 — Eliminar un índice que sobra

Como el índice compuesto ya sirve para buscar por apellido, el primero que creamos quedó **redundante**:

```sql
DROP INDEX idx_estudiante_apellido ON estudiante;
```

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido = 'Núñez';
```

**Resultado:**

| table | type | key | rows |
| ----- | ---- | --- | ---- |
| estudiante | ref | idx_estudiante_apellido_nombre | 2000 |

La búsqueda por apellido sigue leyendo 2.000 filas, ahora con el índice compuesto.

> ⚠️ **Atención:** `DROP INDEX` no borra datos, pero las consultas que dependían de ese índice vuelven a recorrer toda la tabla. En una base en uso, eso puede volver lento un sistema entero de un momento para otro.

---

## Paso 6 — Rangos y ordenamientos

Como un índice está ordenado, también sirve para buscar **entre dos valores** y para **ordenar**.

```sql
CREATE INDEX idx_estudiante_fecha ON estudiante (fecha_nacimiento);
```

Los nacidos en marzo de 2009:

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE fecha_nacimiento BETWEEN '2009-03-01' AND '2009-03-31';
```

**Resultado:**

| table | type | key | rows |
| ----- | ---- | --- | ---- |
| estudiante | range | idx_estudiante_fecha | 1416 |

`type = range`: recorre solo un tramo del índice. Y los cinco estudiantes más jóvenes:

```sql
EXPLAIN
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
ORDER BY fecha_nacimiento DESC
LIMIT 5;
```

**Resultado:**

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | index | idx_estudiante_fecha | 5 | Backward index scan |

No ordena nada: el índice ya está ordenado por fecha, así que lo lee desde el final (`Backward index scan`) y se detiene en la quinta fila.

---

## Paso 7 — Cuándo MySQL no usa el índice

Tener el índice no garantiza que se use. Hay tres motivos frecuentes.

**1. Una función sobre la columna.** El índice guarda fechas, no años:

```sql
-- ❌ MySQL tiene que calcular YEAR() y MONTH() para las 100.000 filas
EXPLAIN
SELECT *
FROM estudiante
WHERE YEAR(fecha_nacimiento) = 2011
  AND MONTH(fecha_nacimiento) = 12;
```

**Resultado:**

| table | type | key | rows |
| ----- | ---- | --- | ---- |
| estudiante | ALL | NULL | 100165 |

```sql
-- ✅ La misma pregunta, comparando la columna "desnuda"
EXPLAIN
SELECT *
FROM estudiante
WHERE fecha_nacimiento BETWEEN '2011-12-01' AND '2011-12-31';
```

**Resultado:**

| table | type | key | rows |
| ----- | ---- | --- | ---- |
| estudiante | range | idx_estudiante_fecha | 1370 |

**2. Un `LIKE` que empieza con comodín.** En una guía ordenada se puede buscar lo que **empieza** con "Nú", no lo que **termina** en "ez":

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido LIKE 'Nú%';
```

**Resultado:**

| table | type | key | rows |
| ----- | ---- | --- | ---- |
| estudiante | range | idx_estudiante_apellido_nombre | 2000 |

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido LIKE '%ez';
```

**Resultado:**

| table | type | key | rows |
| ----- | ---- | --- | ---- |
| estudiante | ALL | NULL | 100165 |

**3. La condición trae demasiadas filas.** Todos los nacidos en 2009 son la sexta parte de la tabla:

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE fecha_nacimiento BETWEEN '2009-01-01' AND '2009-12-31';
```

**Resultado:**

| table | type | possible_keys | key | rows |
| ----- | ---- | ------------- | --- | ---- |
| estudiante | ALL | idx_estudiante_fecha | NULL | 100165 |

MySQL sabe que el índice existe (`possible_keys`) y decide no usarlo (`key = NULL`): para traer tantas filas, saltar del índice a la tabla miles de veces le sale más caro que leer la tabla de corrido. Un índice rinde cuando la condición es **selectiva**, es decir, cuando deja pasar pocas filas.

---

## Paso 8 — Índices únicos

Un índice `UNIQUE` acelera las búsquedas y, además, impide los valores repetidos. No queremos dos docentes con el mismo nombre y apellido:

```sql
CREATE UNIQUE INDEX uq_docente_nombre_apellido ON docente (nombre, apellido);
```

```sql
-- ❌ Ya hay una Ana Pereira
INSERT INTO docente (nombre, apellido)
VALUES ('Ana', 'Pereira');
```

```text
Error Code: 1062. Duplicate entry 'Ana-Pereira' for key 'docente.uq_docente_nombre_apellido'
```

Es lo mismo que la restricción `UNIQUE` del [Módulo 5](Restricciones): una restricción `UNIQUE` **es** un índice único.

> 📌 **Nota:** si la tabla ya tiene valores repetidos, el índice único no se puede crear y MySQL responde con el mismo `Error 1062`.

---

## El costo de un índice

Si los índices aceleran todo, ¿por qué no crear uno por cada columna?

| Costo | Por qué |
| ----- | ------- |
| Las escrituras son más lentas | Cada `INSERT`, `UPDATE` o `DELETE` tiene que actualizar la tabla **y** todos sus índices |
| Ocupan espacio en disco | Cada índice es una copia ordenada de sus columnas |
| Más trabajo para el optimizador | Con muchos índices parecidos, MySQL tarda más en elegir (y puede elegir mal) |

**¿Cuándo crear un índice?**

| Conviene | No conviene |
| -------- | ----------- |
| Columnas que aparecen seguido en `WHERE` | Tablas chicas (cientos de filas): recorrerlas es instantáneo |
| Columnas usadas en `JOIN … ON` (las FK ya lo tienen) | Columnas con pocos valores distintos (`turno`: tres valores) |
| Columnas usadas en `ORDER BY` o `GROUP BY` | Columnas que casi nunca se consultan |
| Columnas con muchos valores distintos (apellido, fecha, documento) | Tablas que reciben muchísimas escrituras y pocas lecturas |

> 💡 Un índice no se crea "por las dudas". Se crea cuando hay una consulta concreta que es lenta, y se comprueba con `EXPLAIN` que la mejora.

## Diferencia clave: índice simple vs compuesto vs único

| Aspecto | Simple | Compuesto | Único |
| ------- | ------ | --------- | ----- |
| Columnas | Una | Dos o más, en un orden | Una o más |
| Admite repetidos | Sí | Sí | No |
| Sirve para buscar por | Esa columna | La primera, o la primera y las siguientes | Sus columnas |
| Ejemplo | `(fecha_nacimiento)` | `(apellido, nombre)` | `(nombre, apellido)` en `docente` |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1061`: *Duplicate key name* | Ya existe un índice con ese nombre en la tabla | Elegir otro nombre o eliminar el anterior |
| `Error 1062`: *Duplicate entry* al crear un índice único | La columna ya tiene valores repetidos | Corregir los datos o crear un índice común |
| `Error 1072`: *Key column doesn't exist in table* | Nombre de columna mal escrito | Revisar con `DESCRIBE tabla` |
| `Error 1091`: *Can't DROP …; check that column/key exists* | El índice no existe o se escribió mal el nombre | Ver los nombres con `SHOW INDEX FROM tabla` |
| `Error 1553`: *Cannot drop index …: needed in a foreign key constraint* | Es el índice que sostiene una clave foránea | No se elimina mientras exista la FK |
| El índice existe y `EXPLAIN` muestra `ALL` | Función sobre la columna, `LIKE '%…'`, condición poco selectiva o columna que no es la primera del índice | Reescribir la condición o crear el índice adecuado |

---

Continuamos por la herramienta que usamos para mirar adentro de MySQL → [EXPLAIN: cómo resuelve MySQL una consulta](EXPLAIN)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Al terminar el ejercicio 5, la base queda con los mismos índices que al final de la página.

**1.** Listá los índices de `inscripcion`. ¿De dónde salió cada uno?

<details>
<summary>Ver solución</summary>

```sql
SHOW INDEX FROM inscripcion;
```

| Table | Non_unique | Key_name | Seq_in_index | Column_name |
| ----- | ---------- | -------- | ------------ | ----------- |
| inscripcion | 0 | PRIMARY | 1 | id_estudiante |
| inscripcion | 0 | PRIMARY | 2 | id_asignatura |
| inscripcion | 1 | fk_inscripcion_asignatura | 1 | id_asignatura |

💡 `PRIMARY` es la clave primaria compuesta (dos filas, una por columna, numeradas en `Seq_in_index`). `fk_inscripcion_asignatura` lo creó MySQL para la clave foránea. La otra FK, `id_estudiante`, no necesitó uno propio: es la primera columna de `PRIMARY` (prefijo izquierdo).
</details>

**2.** Mirá con `EXPLAIN` cómo se resuelve la búsqueda de las inscripciones con nota 12. Después creá un índice que la mejore y volvé a mirar.

<details>
<summary>Ver solución</summary>

```sql
EXPLAIN
SELECT *
FROM inscripcion
WHERE nota = 12;
```

| table | type | key |
| ----- | ---- | --- |
| inscripcion | ALL | NULL |

```sql
CREATE INDEX idx_inscripcion_nota ON inscripcion (nota);
```

```sql
EXPLAIN
SELECT *
FROM inscripcion
WHERE nota = 12;
```

| table | type | key |
| ----- | ---- | --- |
| inscripcion | ref | idx_inscripcion_nota |

💡 Pasó de recorrer las 400.000 inscripciones (`ALL`) a ir directo a las que tienen 12 (`ref`).
</details>

**3.** Sin ejecutar nada: ¿cuáles de estas condiciones pueden aprovechar el índice `idx_estudiante_apellido_nombre`, definido sobre `(apellido, nombre)`?

- a) `WHERE apellido = 'López'`
- b) `WHERE nombre = 'Sofía'`
- c) `WHERE apellido = 'López' AND nombre LIKE 'S%'`
- d) `WHERE apellido LIKE '%ez' AND nombre = 'Sofía'`

<details>
<summary>Ver solución</summary>

| Condición | ¿Usa el índice? | `type` | Filas leídas (aprox.) |
| --------- | --------------- | ------ | --------------------- |
| a) | Sí | `ref` | 2.000 |
| b) | No | `ALL` | 100.000 |
| c) | Sí | `range` | 150 |
| d) | No | `ALL` | 100.000 |

💡 En (b) falta la primera columna del índice. En (d) la primera columna está, pero con un `LIKE` que empieza con comodín, que no se puede buscar en algo ordenado. Podés comprobar cada una con `EXPLAIN`.
</details>

**4.** Esta consulta no usa el índice de fecha. Reescribila para que lo use y comprobalo.

```sql
SELECT *
FROM estudiante
WHERE YEAR(fecha_nacimiento) = 2006
  AND MONTH(fecha_nacimiento) = 1;
```

<details>
<summary>Ver solución</summary>

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE fecha_nacimiento BETWEEN '2006-01-01' AND '2006-01-31';
```

| table | type | key | rows |
| ----- | ---- | --- | ---- |
| estudiante | range | idx_estudiante_fecha | 1415 |

💡 La columna queda sin funciones alrededor y la condición pasa a ser un rango, que el índice resuelve.
</details>

**5.** Eliminá el índice creado en el ejercicio 2.

<details>
<summary>Ver solución</summary>

```sql
DROP INDEX idx_inscripcion_nota ON inscripcion;
```

💡 Se indica el nombre del índice **y** la tabla: dos tablas distintas pueden tener índices con el mismo nombre.
</details>

---

## 📋 Palabras clave

`índice` · `CREATE INDEX` · `DROP INDEX` · `SHOW INDEX` · `índice compuesto` · `índice único` · `prefijo izquierdo` · `selectividad` · `recorrido completo` · `EXPLAIN` · `type` · `rows` · `PRIMARY` · `índice redundante`

---

🧠 **[Autoevaluación — Módulo 9](auto-modulo9)**

---

← [Resumen del Módulo 8](Resumen-Modulo8) · [🏠 Inicio](Home) · [EXPLAIN →](EXPLAIN)
