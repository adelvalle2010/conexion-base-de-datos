> 🗄️ **Base de datos:** `liceo_grande` (Módulo 9 — Rendimiento y Transacciones) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo9/liceo_grande.sql)

# 🔬 EXPLAIN: cómo resuelve MySQL una consulta

## ¿Por qué lo necesitamos?

En SQL decimos **qué** queremos, no **cómo** conseguirlo. El "cómo" lo decide una parte de MySQL llamada **optimizador**: qué tabla leer primero, qué índice usar, si hace falta ordenar. Cuando una consulta tarda, mirar el reloj no alcanza: dice que es lenta, no **por qué**.

```sql
-- ❌ Sabemos cuánto tarda, pero no qué está haciendo
SELECT *
FROM estudiante
WHERE nombre = 'Sofía';
```

```sql
-- ✅ MySQL nos cuenta su plan
EXPLAIN
SELECT *
FROM estudiante
WHERE nombre = 'Sofía';
```

**Resultado** (columnas principales):

| table | type | possible_keys | key | rows | Extra |
| ----- | ---- | ------------- | --- | ---- | ----- |
| estudiante | ALL | NULL | NULL | 100165 | Using where |

> **¿Qué es un plan de ejecución?** Es la secuencia de pasos que MySQL eligió para resolver una consulta. `EXPLAIN` lo muestra **sin ejecutar** la consulta: es instantáneo aunque la consulta tarde minutos.

Esta página sigue con la base como quedó al final de [Índices](Indices). Si volviste a cargar el script, creá de nuevo estos dos:

```sql
CREATE INDEX idx_estudiante_apellido_nombre ON estudiante (apellido, nombre);
CREATE INDEX idx_estudiante_fecha ON estudiante (fecha_nacimiento);
```

---

## Sintaxis

```sql
EXPLAIN
<consulta SELECT, UPDATE o DELETE>;
```

| Forma | Qué hace |
| ----- | -------- |
| `EXPLAIN SELECT …` | Muestra el plan en forma de tabla, sin ejecutar |
| `EXPLAIN ANALYZE SELECT …` | **Ejecuta** la consulta y muestra el plan con los tiempos y filas reales |
| `EXPLAIN FORMAT=TREE SELECT …` | Muestra el plan como un árbol de pasos, sin ejecutar |

> 📌 **Nota:** en Workbench, el botón del rayo con lupa (**Query → Explain Current Statement**) dibuja el mismo plan como un diagrama de cajas: rojo para un recorrido completo, verde para un acceso por índice.

---

## Paso 1 — Leer la salida completa

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido = 'Núñez'
  AND nombre = 'Agustín';
```

**Resultado:**

| id | select_type | table | type | possible_keys | key | key_len | ref | rows | filtered | Extra |
| --- | ----------- | ----- | ---- | ------------- | --- | ------- | --- | ---- | -------- | ----- |
| 1 | SIMPLE | estudiante | ref | idx_estudiante_apellido_nombre | idx_estudiante_apellido_nombre | 404 | const,const | 50 | 100.0 | NULL |

Cada fila de la salida es **una tabla** de la consulta. Las columnas:

| Columna | Qué significa | Qué mirar |
| ------- | ------------- | --------- |
| `id` | Número de `SELECT` al que pertenece la fila | Más de un número: hay subconsultas o `UNION` |
| `select_type` | `SIMPLE` (sin subconsultas), `PRIMARY`, `SUBQUERY`, `DERIVED`, `UNION` | — |
| `table` | Tabla (o alias) que se lee en ese paso | El orden de las filas es el orden en que se leen |
| **`type`** | **Cómo** se accede a la tabla | La columna más importante: ver Paso 2 |
| `possible_keys` | Índices que **podrían** servir | `NULL`: no hay ninguno útil |
| **`key`** | Índice que **eligió** | `NULL`: no usa índice |
| `key_len` | Bytes del índice que usa | En un índice compuesto, indica cuántas columnas aprovechó |
| `ref` | Con qué se compara el índice | `const` (un valor fijo) o una columna de otra tabla |
| **`rows`** | Filas que **estima** leer | Cuanto más chico, mejor |
| `filtered` | Porcentaje de esas filas que estima que pasan el `WHERE` | 100 es ideal: no lee filas de más |
| **`Extra`** | Información adicional | Ver Paso 4 |

En este caso: usa el índice compuesto, comparando sus dos columnas con valores fijos (`const,const`), y espera leer 50 filas, todas útiles.

---

## Paso 2 — La columna type: de mejor a peor

**`const`**: una sola fila, encontrada por clave primaria o índice único.

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE id_estudiante = 54321;
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | const | PRIMARY | 1 | NULL |

**`ref`**: todas las filas que coinciden con un valor, en un índice que admite repetidos.

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE id_grupo = 7;
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ref | fk_estudiante_grupo | 833 | NULL |

**`range`**: un tramo del índice (`BETWEEN`, `>`, `<`, `LIKE 'abc%'`, `IN`).

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE fecha_nacimiento BETWEEN '2009-03-01' AND '2009-03-31';
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | range | idx_estudiante_fecha | 1416 | Using index condition |

**`index`**: recorre **todo el índice**. Lee tantas entradas como filas tiene la tabla, pero el índice es más chico que la tabla y ya está ordenado.

```sql
EXPLAIN
SELECT apellido, COUNT(*)
FROM estudiante
GROUP BY apellido;
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | index | idx_estudiante_apellido_nombre | 100165 | Using index |

**`ALL`**: recorre **toda la tabla**.

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE nombre = 'Sofía';
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ALL | NULL | 100165 | Using where |

### La escalera completa

| `type` | Cómo accede | Filas que lee | Valoración |
| ------ | ----------- | ------------- | ---------- |
| `const` | Clave primaria o única = valor | 1 | 🟢 Ideal |
| `eq_ref` | En un `JOIN`: una fila por PK o índice único | 1 por cada fila anterior | 🟢 Ideal |
| `ref` | Índice común = valor | Las que coinciden | 🟢 Bueno |
| `range` | Tramo de un índice | Las del rango | 🟢 Bueno |
| `index` | Todo el índice | Todas | 🟡 Regular |
| `ALL` | Toda la tabla | Todas | 🔴 Revisar |

> 📌 **Nota:** `ALL` no siempre es un problema. En una tabla de 120 filas como `grupo`, recorrerla entera es lo más rápido que hay. Preocupa cuando la tabla es grande y la consulta devuelve pocas filas.

---

## Paso 3 — Leer el plan de un JOIN

Las notas de los estudiantes que se llaman Agustín Núñez:

```sql
EXPLAIN
SELECT e.nombre, e.apellido, a.nombre AS asignatura, i.nota
FROM estudiante AS e
INNER JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
INNER JOIN asignatura  AS a ON a.id_asignatura = i.id_asignatura
WHERE e.apellido = 'Núñez'
  AND e.nombre = 'Agustín';
```

**Resultado:**

| table | type | key | ref | rows |
| ----- | ---- | --- | --- | ---- |
| e | ref | idx_estudiante_apellido_nombre | const,const | 50 |
| i | ref | PRIMARY | liceo_grande.e.id_estudiante | 3 |
| a | eq_ref | PRIMARY | liceo_grande.i.id_asignatura | 1 |

Se lee de arriba hacia abajo, como un `for` dentro de otro:

```text
1. e   ref      Busca en el índice a los Agustín Núñez            →  50 estudiantes
2. i   ref        Para CADA uno, sus inscripciones (por PRIMARY)  →   3 o 4 por estudiante
3. a   eq_ref       Para CADA inscripción, su asignatura (por PK) →   1 por inscripción

   Filas leídas en total ≈ 50 × 4 × 1 = 200
```

**Elementos clave:**

- Cada estudiante tiene exactamente 4 inscripciones; que `rows` diga 3 o 4 recuerda que es una **estimación**.
- La columna `ref` de las filas 2 y 3 ya no dice `const`: dice con qué columna de la tabla **anterior** se busca.
- `eq_ref` es el mejor tipo posible en un `JOIN`: exactamente una fila por cada fila anterior. Aparece cuando se une contra una clave primaria.
- Para estimar el trabajo total se **multiplican** los `rows`. Un `ALL` de 100.000 en la segunda fila de un plan significa 100.000 lecturas **por cada** fila de la primera.
- MySQL puede leer las tablas en un orden distinto al del `FROM`. Empieza por la que le permite descartar más filas.

---

## Paso 4 — La columna Extra

**`Using where`**: después de leer las filas, descarta algunas con el `WHERE`. Ya lo vimos junto a `ALL`.

**`Using index`**: la consulta se responde **solo con el índice**, sin tocar la tabla. Se llama índice de cobertura y es lo más rápido que hay.

```sql
EXPLAIN
SELECT apellido, nombre
FROM estudiante
WHERE apellido = 'Núñez';
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ref | idx_estudiante_apellido_nombre | 2000 | Using index |

Las dos columnas pedidas están dentro del índice `(apellido, nombre)`. Con `SELECT *` habría que ir a la tabla a buscar la fecha y el grupo: una razón más para no pedir columnas que no se usan.

**`Using filesort`**: MySQL tiene que **ordenar** el resultado por su cuenta, porque ningún índice se lo da ordenado.

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE id_grupo = 7
ORDER BY fecha_nacimiento;
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ref | fk_estudiante_grupo | 833 | Using filesort |

**`Using temporary`**: necesita armar una **tabla temporal** para resolver la consulta. Es típico de `GROUP BY` y `DISTINCT` sobre columnas sin índice adecuado.

```sql
EXPLAIN
SELECT nombre, COUNT(*) AS cantidad
FROM estudiante
GROUP BY nombre
ORDER BY cantidad DESC;
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | index | idx_estudiante_apellido_nombre | 100165 | Using index; Using temporary; Using filesort |

| `Extra` | Significa | Valoración |
| ------- | --------- | ---------- |
| `Using index` | Responde solo con el índice | 🟢 Excelente |
| `Using index condition` | Filtra dentro del índice antes de ir a la tabla | 🟢 Bueno |
| `Using where` | Filtra filas después de leerlas | 🟡 Normal; malo si viene con `ALL` y muchas filas |
| `Using filesort` | Ordena aparte | 🟡 Costoso con muchas filas |
| `Using temporary` | Arma una tabla temporal | 🟡 Costoso con muchas filas |
| `Backward index scan` | Lee el índice de atrás para adelante | 🟢 Bueno |

> 📌 **Nota:** `filesort` no quiere decir que use un archivo: es el nombre histórico del algoritmo de ordenamiento. Con pocas filas ocurre en memoria y no se nota.

---

## Paso 5 — EXPLAIN ANALYZE: lo estimado contra lo real

`EXPLAIN` muestra estimaciones. `EXPLAIN ANALYZE` **ejecuta** la consulta y agrega lo que pasó de verdad:

```sql
EXPLAIN ANALYZE
SELECT *
FROM estudiante
WHERE nombre = 'Sofía';
```

```text
-> Filter: (estudiante.nombre = 'Sofía')  (cost=10105 rows=10017) (actual time=0.08..24.0 rows=2500 loops=1)
    -> Table scan on estudiante  (cost=10105 rows=100165) (actual time=0.08..19.0 rows=100000 loops=1)
```

Se lee de adentro hacia afuera (la línea más indentada se ejecuta primero):

| Parte | Significa |
| ----- | --------- |
| `Table scan on estudiante` | Recorrido completo: el `ALL` de antes |
| `rows=100165` (primer paréntesis) | Lo que **estimaba** leer |
| `actual time=0.08..19.0` | Milisegundos reales: hasta la primera fila .. hasta la última |
| `rows=100000` (segundo paréntesis) | Filas que leyó **de verdad** |
| `Filter … rows=2500` | Después del `WHERE` quedaron 2.500 |

Leyó 100.000 filas para devolver 2.500. Los tiempos van a ser distintos en cada equipo; la relación entre filas leídas y filas devueltas, no.

> ⚠️ **Cuidado:** `EXPLAIN ANALYZE` ejecuta la consulta completa. Si tarda diez minutos, el `EXPLAIN ANALYZE` tarda diez minutos. Y sobre un `UPDATE` o `DELETE`, **modifica los datos**.

---

## Paso 6 — Optimizar una consulta, de principio a fin

El método tiene cinco pasos, y ya hicimos los tres primeros con la búsqueda por nombre:

```text
1. Medir       →  la consulta lee 100.000 filas para devolver 2.500
2. EXPLAIN     →  type = ALL, key = NULL
3. Diagnóstico →  no hay índice que empiece por "nombre"
4. Corregir    →  crear el índice, o reescribir la consulta
5. Volver a medir
```

Paso 4:

```sql
CREATE INDEX idx_estudiante_nombre ON estudiante (nombre);
```

Paso 5:

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE nombre = 'Sofía';
```

**Resultado:**

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ref | idx_estudiante_nombre | 2500 | NULL |

De `ALL` con 100.000 filas a `ref` con 2.500: lee exactamente las que devuelve.

> 💡 No toda consulta lenta se arregla con un índice. A veces el `EXPLAIN` muestra que el problema es una función sobre la columna, un `LIKE '%…'` o un `SELECT *` que impide usar un índice de cobertura, y lo que hay que cambiar es la consulta.

---

## Diferencia clave: EXPLAIN vs EXPLAIN ANALYZE

| Aspecto | `EXPLAIN` | `EXPLAIN ANALYZE` |
| ------- | --------- | ----------------- |
| ¿Ejecuta la consulta? | No | Sí |
| Tiempo que tarda | Instantáneo | Lo que tarde la consulta |
| Filas | Estimadas | Estimadas **y** reales |
| Tiempos | No muestra | Reales, por cada paso |
| Formato | Tabla | Árbol de texto |
| Riesgo con `UPDATE` / `DELETE` | Ninguno | Modifica los datos |
| Disponible desde | Siempre | MySQL 8.0.18 |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `rows` no coincide con la cantidad real de filas | Es una estimación basada en estadísticas | Usar `EXPLAIN ANALYZE` para ver el valor real |
| `rows` muy alejado de la realidad | Estadísticas viejas, después de cargar o borrar muchos datos | `ANALYZE TABLE tabla;` para recalcularlas |
| `possible_keys` muestra un índice y `key` es `NULL` | El optimizador calculó que recorrer la tabla es más barato | Suele tener razón: la condición trae demasiadas filas |
| Aparece `ALL` y la consulta es rápida igual | La tabla es chica | No hay nada que arreglar |
| `Error 1064` con `EXPLAIN ANALYZE` | Versión de MySQL anterior a 8.0.18 | Usar `EXPLAIN` común o actualizar |
| Se creó el índice y el plan no cambió | El índice no empieza por la columna del `WHERE`, o hay una función sobre ella | Revisar el orden de columnas y la condición |

---

Continuamos por el otro gran tema del módulo: que los datos sigan siendo correctos cuando algo falla a mitad de camino → [Transacciones y propiedades ACID](Transacciones)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Mirá el plan de esta consulta. ¿Por qué el `type` es `const` si no se busca por clave primaria?

```sql
SELECT *
FROM asignatura
WHERE nombre = 'Historia';
```

<details>
<summary>Ver solución</summary>

```sql
EXPLAIN
SELECT *
FROM asignatura
WHERE nombre = 'Historia';
```

| table | type | key | rows |
| ----- | ---- | --- | ---- |
| asignatura | const | uq_asignatura_nombre | 1 |

💡 `nombre` tiene la restricción `UNIQUE` (`uq_asignatura_nombre`), que es un índice único. MySQL sabe que a lo sumo hay una fila con ese valor.
</details>

**2.** Explicá, fila por fila, el plan de la consulta que muestra los estudiantes del grupo `3ºB`.

```sql
SELECT e.nombre, e.apellido
FROM estudiante AS e
INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo
WHERE g.nombre = '3ºB';
```

<details>
<summary>Ver solución</summary>

```sql
EXPLAIN
SELECT e.nombre, e.apellido
FROM estudiante AS e
INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo
WHERE g.nombre = '3ºB';
```

| table | type | key | ref | rows |
| ----- | ---- | --- | --- | ---- |
| g | const | uq_grupo_nombre | const | 1 |
| e | ref | fk_estudiante_grupo | const | 833 |

💡 Aunque el `FROM` empieza por `estudiante`, MySQL lee primero `grupo`: por el índice único del nombre encuentra un solo grupo (`const`). Después, con el índice de la clave foránea, va directo a los estudiantes de ese grupo (`ref`). Total: unas 830 filas en lugar de 100.000.
</details>

**3.** ¿Qué problema muestra el plan de esta consulta? ¿Qué índice propondrías? (No hace falta crearlo.)

```sql
SELECT *
FROM inscripcion
WHERE nota IS NULL;
```

<details>
<summary>Ver solución</summary>

```sql
EXPLAIN
SELECT *
FROM inscripcion
WHERE nota IS NULL;
```

| table | type | possible_keys | key | Extra |
| ----- | ---- | ------------- | --- | ----- |
| inscripcion | ALL | NULL | NULL | Using where |

💡 `ALL` sobre una tabla de 400.000 filas, sin ningún índice candidato. Un índice sobre `nota` lo resuelve: los índices de MySQL también guardan los `NULL`, así que `IS NULL` puede usarlos.
</details>

**4.** Estas dos consultas devuelven lo mismo. Compará sus planes: ¿cuál tiene `Using filesort` y por qué?

```sql
SELECT * FROM estudiante WHERE apellido = 'Núñez' ORDER BY nombre;
SELECT * FROM estudiante WHERE apellido = 'Núñez' ORDER BY fecha_nacimiento;
```

<details>
<summary>Ver solución</summary>

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido = 'Núñez'
ORDER BY nombre;
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ref | idx_estudiante_apellido_nombre | 2000 | NULL |

```sql
EXPLAIN
SELECT *
FROM estudiante
WHERE apellido = 'Núñez'
ORDER BY fecha_nacimiento;
```

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ref | idx_estudiante_apellido_nombre | 2000 | Using filesort |

💡 En el índice `(apellido, nombre)`, los Núñez ya están ordenados por nombre: la primera consulta sale ordenada sin trabajo extra. Para ordenarlos por fecha no hay nada preparado y MySQL tiene que ordenar las 2.000 filas.
</details>

**5.** ¿Cuántas filas leerá en total, aproximadamente, una consulta con este plan?

| table | type | key | rows |
| ----- | ---- | --- | ---- |
| g | ALL | NULL | 120 |
| e | ref | fk_estudiante_grupo | 833 |
| i | ref | PRIMARY | 4 |

<details>
<summary>Ver solución</summary>

120 × 833 × 4 ≈ **400.000** filas.

💡 Los `rows` de un `JOIN` se multiplican: por cada grupo lee sus 833 estudiantes, y por cada estudiante, sus 4 inscripciones. Acá es razonable, porque la consulta recorre todas las inscripciones del liceo.
</details>

**6.** Eliminá el índice creado en el Paso 6.

<details>
<summary>Ver solución</summary>

```sql
DROP INDEX idx_estudiante_nombre ON estudiante;
```

💡 La base vuelve a quedar como al final de la página de Índices.
</details>

---

## 📋 Palabras clave

`EXPLAIN` · `EXPLAIN ANALYZE` · `plan de ejecución` · `optimizador` · `type` · `const` · `eq_ref` · `ref` · `range` · `ALL` · `rows` · `Using index` · `Using filesort` · `Using temporary` · `índice de cobertura` · `ANALYZE TABLE`

---

🧠 **[Autoevaluación — Módulo 9](auto-modulo9)**

---

← [Índices](Indices) · [🏠 Inicio](Home) · [Transacciones →](Transacciones)
