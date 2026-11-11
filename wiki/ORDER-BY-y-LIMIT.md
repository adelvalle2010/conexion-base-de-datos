> 🗄️ **Base de datos:** `liceo` (Módulo 7 — Consultas Básicas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 📊 ORDER BY y LIMIT

## ¿Por qué lo necesitamos?

Hasta ahora las filas salieron "como estaban". Eso tiene dos problemas:

- Una tabla **no tiene orden propio**. Si no se pide uno, MySQL devuelve las filas como le resulte más cómodo, y ese orden puede cambiar.
- A veces no queremos todas las filas, sino las primeras: las tres mejores notas, el estudiante más joven.

`ORDER BY` ordena el resultado y `LIMIT` lo recorta.

---

## Sintaxis

```sql
SELECT <columnas>
FROM <tabla>
WHERE <condición>
ORDER BY <columna> [ASC | DESC], <columna> [ASC | DESC]
LIMIT <cantidad>;
```

| Parte | Descripción |
| ----- | ----------- |
| `ORDER BY columna` | Ordena por esa columna |
| `ASC` | Ascendente: de menor a mayor, de la A a la Z, de la fecha más antigua a la más nueva. Es el valor por defecto |
| `DESC` | Descendente: al revés |
| `LIMIT n` | Devuelve como máximo `n` filas |

---

## Paso 1 — Ordenar por una columna

```sql
SELECT apellido, nombre
FROM estudiante
ORDER BY apellido;
```

**Resultado:**

| apellido | nombre |
| -------- | ------ |
| Castro | Benjamín |
| Fernández | Lucía |
| González | Camila |
| López | Sofía |
| Martínez | Joaquín |
| Núñez | Agustín |
| Pérez | Santiago |
| Rodríguez | Valentina |
| Silva | Mateo |
| Suárez | Martina |

Con `DESC`, de mayor a menor. Las mejores notas primero:

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE id_asignatura = 10
ORDER BY nota DESC;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 5 | 10 | 12.00 |
| 7 | 10 | 10.00 |
| 1 | 10 | 9.50 |
| 2 | 10 | 8.00 |
| 6 | 10 | 7.50 |
| 3 | 10 | 6.50 |
| 4 | 10 | 4.00 |

---

## Paso 2 — Ordenar por varias columnas

Cuando hay empates en la primera columna, la segunda desempata:

```sql
SELECT id_grupo, apellido, nombre
FROM estudiante
ORDER BY id_grupo, apellido;
```

**Resultado:**

| id_grupo | apellido | nombre |
| -------- | -------- | ------ |
| 1 | Fernández | Lucía |
| 1 | Pérez | Santiago |
| 1 | Rodríguez | Valentina |
| 2 | González | Camila |
| 2 | Núñez | Agustín |
| 2 | Silva | Mateo |
| 2 | Suárez | Martina |
| 3 | Castro | Benjamín |
| 3 | López | Sofía |
| 3 | Martínez | Joaquín |

Primero por grupo; dentro de cada grupo, por apellido. Cada columna puede tener su propio sentido:

```sql
SELECT id_asignatura, id_estudiante, nota
FROM inscripcion
WHERE id_asignatura IN (11, 13)
ORDER BY id_asignatura ASC, nota DESC;
```

**Resultado:**

| id_asignatura | id_estudiante | nota |
| ------------- | ------------- | ---- |
| 11 | 1 | 7.00 |
| 11 | 4 | 6.00 |
| 11 | 8 | 3.00 |
| 13 | 5 | 8.50 |
| 13 | 9 | 7.00 |
| 13 | 2 | 5.00 |

---

## Paso 3 — Ordenar por una columna calculada o un alias

A diferencia del `WHERE`, el `ORDER BY` **sí** puede usar los alias del `SELECT`:

```sql
SELECT nombre, YEAR(fecha_nacimiento) AS anio
FROM estudiante
ORDER BY anio DESC, nombre;
```

**Resultado:**

| nombre | anio |
| ------ | ---- |
| Benjamín | 2010 |
| Joaquín | 2010 |
| Sofía | 2010 |
| Lucía | 2009 |
| Martina | 2009 |
| Santiago | 2009 |
| Valentina | 2009 |
| Agustín | 2008 |
| Camila | 2008 |
| Mateo | 2008 |

También se puede ordenar por una columna que no se muestra, por ejemplo `ORDER BY fecha_nacimiento` en una consulta que solo muestra el nombre.

---

## Paso 4 — ¿Dónde quedan los NULL?

```sql
SELECT id_estudiante, nota
FROM inscripcion
WHERE id_asignatura = 14
ORDER BY nota, id_estudiante;
```

**Resultado:**

| id_estudiante | nota |
| ------------- | ---- |
| 4 | NULL |
| 9 | NULL |
| 7 | 9.00 |
| 1 | 11.00 |

En MySQL, `NULL` se considera **menor que cualquier valor**: en orden ascendente queda primero y en descendente, último.

---

## Paso 5 — LIMIT: quedarse con las primeras

Las dos mejores notas del liceo:

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
ORDER BY nota DESC
LIMIT 2;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 5 | 10 | 12.00 |
| 1 | 14 | 11.00 |

El estudiante más joven:

```sql
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
ORDER BY fecha_nacimiento DESC
LIMIT 1;
```

**Resultado:**

| nombre | apellido | fecha_nacimiento |
| ------ | -------- | ---------------- |
| Benjamín | Castro | 2010-12-25 |

**Elementos clave:**

- `LIMIT` se aplica **al final**, después de ordenar. Por eso "los dos mejores" necesita `ORDER BY ... DESC` y `LIMIT 2` juntos.
- Un `LIMIT` sin `ORDER BY` devuelve "dos filas cualesquiera": no sirve para responder "los primeros".
- Si hay empate en el último lugar, `LIMIT` corta igual. En nuestros datos, la tercera mejor nota es 10.00 y la tienen dos inscripciones: con `LIMIT 3` saldría una sola, y cuál de las dos no está definido. Para que el resultado sea siempre el mismo se agrega un desempate: `ORDER BY nota DESC, id_estudiante`.

> 📌 **Nota:** `LIMIT` es propio de MySQL (y de PostgreSQL y SQLite). En SQL Server se escribe `SELECT TOP 3 …` y el estándar define `FETCH FIRST 3 ROWS ONLY`.

---

## Paso 6 — Paginación: LIMIT con OFFSET

`OFFSET` saltea filas antes de empezar a contar. Es lo que usan los sitios web para mostrar resultados "de a páginas".

```sql
-- Página 1: los primeros 4 estudiantes por apellido
SELECT apellido, nombre
FROM estudiante
ORDER BY apellido
LIMIT 4 OFFSET 0;
```

**Resultado:**

| apellido | nombre |
| -------- | ------ |
| Castro | Benjamín |
| Fernández | Lucía |
| González | Camila |
| López | Sofía |

```sql
-- Página 2: los 4 siguientes
SELECT apellido, nombre
FROM estudiante
ORDER BY apellido
LIMIT 4 OFFSET 4;
```

**Resultado:**

| apellido | nombre |
| -------- | ------ |
| Martínez | Joaquín |
| Núñez | Agustín |
| Pérez | Santiago |
| Rodríguez | Valentina |

Para la página `n` con `t` filas por página: `LIMIT t OFFSET (n - 1) * t`.

---

## El orden completo de las cláusulas

```text
Se escribe:   SELECT ─▶ FROM ─▶ WHERE ─▶ ORDER BY ─▶ LIMIT
Se ejecuta:   FROM ─▶ WHERE ─▶ SELECT ─▶ ORDER BY ─▶ LIMIT

  1. FROM       toma la tabla
  2. WHERE      descarta filas
  3. SELECT     arma las columnas (y los alias)
  4. ORDER BY   ordena lo que quedó  ← por eso acá sí se pueden usar los alias
  5. LIMIT      recorta
```

## Diferencia clave: WHERE vs LIMIT

| Aspecto | `WHERE` | `LIMIT` |
| ------- | ------- | ------- |
| Decide según... | El contenido de cada fila | La posición de la fila en el resultado |
| Pregunta | ¿Cuáles cumplen la condición? | ¿Cuántas quiero ver? |
| Cantidad de filas | Las que cumplan, sean 0 o 1.000 | Como máximo las indicadas |
| Necesita `ORDER BY` | No | Sí, para que tenga sentido |
| Ejemplo | Notas mayores que 10 | Las 3 notas más altas |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1064` cerca de `WHERE` | El `WHERE` se escribió después del `ORDER BY` | Orden: `WHERE` → `ORDER BY` → `LIMIT` |
| Las "tres mejores" no son las mejores | `LIMIT` sin `ORDER BY` | Agregar `ORDER BY nota DESC` |
| Salen primero las peores notas | Falta `DESC` | El orden por defecto es ascendente |
| Los `NULL` aparecen arriba | En orden ascendente, `NULL` va primero | Filtrar con `IS NOT NULL` u ordenar con `DESC` |
| "10" aparece antes que "9" | La columna es de texto y se ordena alfabéticamente | Guardar los números en columnas numéricas |
| El orden cambia entre una ejecución y otra | No hay `ORDER BY`, o hay empates sin desempatar | Agregar una segunda columna al `ORDER BY` |

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Listá las asignaturas en orden alfabético.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre
FROM asignatura
ORDER BY nombre;
```

| nombre |
| ------ |
| Filosofía |
| Física |
| Historia |
| Matemática |
| Programación |
| Química |

💡 `ASC` es el valor por defecto, no hace falta escribirlo.
</details>

**2.** Mostrá los estudiantes del más grande al más chico de edad.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
ORDER BY fecha_nacimiento;
```

| nombre | apellido | fecha_nacimiento |
| ------ | -------- | ---------------- |
| Agustín | Núñez | 2008-04-18 |
| Camila | González | 2008-09-09 |
| Mateo | Silva | 2008-11-02 |
| Santiago | Pérez | 2009-01-30 |
| Lucía | Fernández | 2009-03-14 |
| Martina | Suárez | 2009-06-06 |
| Valentina | Rodríguez | 2009-07-21 |
| Sofía | López | 2010-02-03 |
| Joaquín | Martínez | 2010-05-17 |
| Benjamín | Castro | 2010-12-25 |

💡 El de más edad es el que nació **antes**: orden ascendente por fecha.
</details>

**3.** Mostrá las dos notas más bajas del liceo, sin contar las inscripciones sin nota.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE nota IS NOT NULL
ORDER BY nota
LIMIT 2;
```

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 8 | 11 | 3.00 |
| 4 | 10 | 4.00 |

💡 Sin el `IS NOT NULL`, las dos primeras filas serían inscripciones con `NULL`.
</details>

**4.** Mostrá las inscripciones de Matemática (10) con nota, ordenadas de la mejor a la peor, salteando las tres primeras.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_estudiante, nota
FROM inscripcion
WHERE id_asignatura = 10
  AND nota IS NOT NULL
ORDER BY nota DESC
LIMIT 10 OFFSET 3;
```

| id_estudiante | nota |
| ------------- | ---- |
| 2 | 8.00 |
| 6 | 7.50 |
| 3 | 6.50 |
| 4 | 4.00 |

💡 `OFFSET` necesita un `LIMIT`; se pone un número mayor que la cantidad de filas esperadas.
</details>

**5.** Mostrá los estudiantes ordenados por grupo de mayor a menor y, dentro de cada grupo, por nombre.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_grupo, nombre, apellido
FROM estudiante
ORDER BY id_grupo DESC, nombre;
```

| id_grupo | nombre | apellido |
| -------- | ------ | -------- |
| 3 | Benjamín | Castro |
| 3 | Joaquín | Martínez |
| 3 | Sofía | López |
| 2 | Agustín | Núñez |
| 2 | Camila | González |
| 2 | Martina | Suárez |
| 2 | Mateo | Silva |
| 1 | Lucía | Fernández |
| 1 | Santiago | Pérez |
| 1 | Valentina | Rodríguez |

💡 El `DESC` afecta solo a la columna que lo lleva: `nombre` queda ascendente.
</details>

---

## 📋 Palabras clave

`ORDER BY` · `ASC` · `DESC` · `orden ascendente` · `orden descendente` · `desempate` · `LIMIT` · `OFFSET` · `paginación` · `NULL en el orden` · `alias` · `orden de ejecución` · `top N` · `TOP / FETCH FIRST`

---

🧠 **[Autoevaluación — Módulo 7](auto-modulo7)**

---

← [LIKE, IN, BETWEEN e IS NULL](LIKE-IN-BETWEEN-e-IS-NULL) · [🏠 Inicio](Home) · [Resumen del Módulo 7 →](Resumen-Modulo7)
