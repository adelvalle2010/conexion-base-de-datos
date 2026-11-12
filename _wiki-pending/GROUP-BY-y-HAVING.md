> 🗄️ **Base de datos:** `liceo` (Módulo 8 — Consultas Avanzadas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🗂️ GROUP BY y HAVING

## ¿Por qué lo necesitamos?

Ya sabemos calcular el promedio de **una** asignatura. Para tener el de todas, con lo visto hasta ahora habría que escribir una consulta por cada una:

```sql
-- ❌ Una consulta por asignatura, y hay que saber cuáles existen
SELECT ROUND(AVG(nota), 2) FROM inscripcion WHERE id_asignatura = 10;
SELECT ROUND(AVG(nota), 2) FROM inscripcion WHERE id_asignatura = 11;
SELECT ROUND(AVG(nota), 2) FROM inscripcion WHERE id_asignatura = 12;
-- ...
```

`GROUP BY` arma los grupos solo y calcula el resumen de cada uno:

```sql
-- ✅ Una fila por asignatura
SELECT id_asignatura,
       ROUND(AVG(nota), 2) AS promedio
FROM inscripcion
GROUP BY id_asignatura
ORDER BY id_asignatura;
```

**Resultado:**

| id_asignatura | promedio |
| ------------- | -------- |
| 10 | 8.21 |
| 11 | 5.33 |
| 12 | 8.33 |
| 13 | 6.83 |
| 14 | 10.00 |

**Ventajas:**

- Una sola consulta, sin importar cuántas asignaturas haya.
- Si mañana se agrega una asignatura, aparece sola en el resultado.

---

## Sintaxis

```sql
SELECT <columna de agrupación>, <FUNCIÓN>(<columna>)
FROM <tabla>
WHERE <condición sobre las filas>
GROUP BY <columna de agrupación>
HAVING <condición sobre los grupos>
ORDER BY <columna>;
```

### Anatomía de la sentencia

```text
 inscripcion                        GROUP BY id_asignatura            SELECT
┌──────────────┬──────┐            ┌─────────────────────┐           ┌──────────────┬──────────┐
│ id_asignatura│ nota │            │ 11 →  7.00          │           │ id_asignatura│ promedio │
├──────────────┼──────┤            │       6.00          │  AVG      ├──────────────┼──────────┤
│ 11           │ 7.00 │  ───────▶  │       3.00          │ ───────▶  │ 11           │ 5.33     │
│ 13           │ 5.00 │            ├─────────────────────┤           │ 13           │ 6.83     │
│ 11           │ 6.00 │            │ 13 →  5.00          │           └──────────────┴──────────┘
│ 13           │ 8.50 │            │       8.50          │
│ 11           │ 3.00 │            │       7.00          │            una fila por grupo
│ 13           │ 7.00 │            └─────────────────────┘
└──────────────┴──────┘
```

| Parte | Descripción |
| ----- | ----------- |
| `GROUP BY columna` | Junta en un grupo las filas que tienen el mismo valor en esa columna |
| Función de agrupación | Se calcula **una vez por grupo** |
| `HAVING` | Filtra **grupos** ya armados |

---

## Paso 1 — Agrupar por una columna

¿Cuántos estudiantes hay en cada grupo?

```sql
SELECT id_grupo,
       COUNT(*) AS cantidad
FROM estudiante
GROUP BY id_grupo
ORDER BY id_grupo;
```

**Resultado:**

| id_grupo | cantidad |
| -------- | -------- |
| 1 | 3 |
| 2 | 4 |
| 3 | 3 |

El grupo 4 no aparece: no tiene estudiantes, así que no hay ninguna fila con `id_grupo = 4` para agrupar. `GROUP BY` solo arma grupos con lo que **existe** en la tabla.

---

## Paso 2 — Varias funciones a la vez

Un resumen completo por asignatura:

```sql
SELECT id_asignatura,
       COUNT(*)            AS inscriptos,
       COUNT(nota)         AS con_nota,
       ROUND(AVG(nota), 2) AS promedio,
       MAX(nota)           AS mejor,
       MIN(nota)           AS peor
FROM inscripcion
GROUP BY id_asignatura
ORDER BY id_asignatura;
```

**Resultado:**

| id_asignatura | inscriptos | con_nota | promedio | mejor | peor |
| ------------- | ---------- | -------- | -------- | ----- | ---- |
| 10 | 7 | 7 | 8.21 | 12.00 | 4.00 |
| 11 | 3 | 3 | 5.33 | 7.00 | 3.00 |
| 12 | 4 | 3 | 8.33 | 10.00 | 6.00 |
| 13 | 3 | 3 | 6.83 | 8.50 | 5.00 |
| 14 | 4 | 2 | 10.00 | 11.00 | 9.00 |

---

## Paso 3 — La regla de oro del SELECT

En una consulta con `GROUP BY`, en el `SELECT` solo pueden ir:

1. Las columnas que están en el `GROUP BY`.
2. Funciones de agrupación.

```sql
-- ❌ Error 1055: ¿la nota de cuál de las 7 filas del grupo?
SELECT id_asignatura, nota
FROM inscripcion
GROUP BY id_asignatura;
```

```sql
-- ✅ Cada columna es de agrupación o está resumida
SELECT id_asignatura, MAX(nota) AS mejor
FROM inscripcion
GROUP BY id_asignatura;
```

Cada grupo se convierte en **una** fila. Una columna que tiene valores diferentes dentro del grupo no entra en una sola celda, salvo que se la resuma.

---

## Paso 4 — Ordenar por el resumen

Las asignaturas, de la que tiene más inscriptos a la que tiene menos:

```sql
SELECT id_asignatura,
       COUNT(*) AS inscriptos
FROM inscripcion
GROUP BY id_asignatura
ORDER BY inscriptos DESC, id_asignatura;
```

**Resultado:**

| id_asignatura | inscriptos |
| ------------- | ---------- |
| 10 | 7 |
| 12 | 4 |
| 14 | 4 |
| 11 | 3 |
| 13 | 3 |

---

## Paso 5 — WHERE filtra filas antes de agrupar

¿Cuántos aprobados (nota de 6 o más) tiene cada asignatura?

```sql
SELECT id_asignatura,
       COUNT(*) AS aprobados
FROM inscripcion
WHERE nota >= 6
GROUP BY id_asignatura
ORDER BY id_asignatura;
```

**Resultado:**

| id_asignatura | aprobados |
| ------------- | --------- |
| 10 | 6 |
| 11 | 2 |
| 12 | 3 |
| 13 | 2 |
| 14 | 2 |

Primero el `WHERE` descarta las notas bajas y las inscripciones sin nota. Recién después se arman los grupos con lo que quedó.

---

## Paso 6 — HAVING filtra grupos ya armados

¿Qué asignaturas tienen promedio de 8 o más? La condición es sobre el **promedio**, que no existe hasta que el grupo está armado. Por eso no puede ir en el `WHERE`:

```sql
-- ❌ Error 1111: el WHERE mira fila por fila, todavía no hay promedios
SELECT id_asignatura, AVG(nota)
FROM inscripcion
WHERE AVG(nota) >= 8
GROUP BY id_asignatura;
```

```sql
-- ✅ HAVING se evalúa después de agrupar
SELECT id_asignatura,
       ROUND(AVG(nota), 2) AS promedio
FROM inscripcion
GROUP BY id_asignatura
HAVING AVG(nota) >= 8
ORDER BY promedio DESC;
```

**Resultado:**

| id_asignatura | promedio |
| ------------- | -------- |
| 14 | 10.00 |
| 12 | 8.33 |
| 10 | 8.21 |

Otro caso: los estudiantes inscriptos en tres o más asignaturas.

```sql
SELECT id_estudiante,
       COUNT(*) AS asignaturas
FROM inscripcion
GROUP BY id_estudiante
HAVING COUNT(*) >= 3
ORDER BY id_estudiante;
```

**Resultado:**

| id_estudiante | asignaturas |
| ------------- | ----------- |
| 1 | 3 |
| 4 | 3 |
| 5 | 3 |

---

## Paso 7 — WHERE y HAVING juntos

De las asignaturas 10 a 13, ¿cuáles tienen más de dos aprobados?

```sql
SELECT id_asignatura,
       COUNT(*) AS aprobados
FROM inscripcion
WHERE nota >= 6
  AND id_asignatura BETWEEN 10 AND 13
GROUP BY id_asignatura
HAVING COUNT(*) > 2
ORDER BY aprobados DESC;
```

**Resultado:**

| id_asignatura | aprobados |
| ------------- | --------- |
| 10 | 6 |
| 12 | 3 |

---

## Paso 8 — Agrupar por más de una columna

El grupo se forma con la **combinación** de valores. ¿Cuántos estudiantes de cada grupo nacieron en cada año?

```sql
SELECT id_grupo,
       YEAR(fecha_nacimiento) AS anio,
       COUNT(*)               AS cantidad
FROM estudiante
GROUP BY id_grupo, YEAR(fecha_nacimiento)
ORDER BY id_grupo, anio;
```

**Resultado:**

| id_grupo | anio | cantidad |
| -------- | ---- | -------- |
| 1 | 2009 | 3 |
| 2 | 2008 | 3 |
| 2 | 2009 | 1 |
| 3 | 2010 | 3 |

---

## El orden completo de las cláusulas

```text
Se escribe:   SELECT ─▶ FROM ─▶ WHERE ─▶ GROUP BY ─▶ HAVING ─▶ ORDER BY ─▶ LIMIT
Se ejecuta:   FROM ─▶ WHERE ─▶ GROUP BY ─▶ HAVING ─▶ SELECT ─▶ ORDER BY ─▶ LIMIT

  1. FROM       toma la tabla
  2. WHERE      descarta filas
  3. GROUP BY   arma los grupos
  4. HAVING     descarta grupos
  5. SELECT     calcula las columnas de cada grupo
  6. ORDER BY   ordena
  7. LIMIT      recorta
```

## Diferencia clave: WHERE vs HAVING

| Aspecto | `WHERE` | `HAVING` |
| ------- | ------- | -------- |
| Filtra | Filas | Grupos |
| Se evalúa | Antes de agrupar | Después de agrupar |
| ¿Admite funciones de agrupación? | No | Sí |
| Necesita `GROUP BY` | No | Casi siempre |
| Ejemplo | `WHERE nota >= 6` | `HAVING AVG(nota) >= 8` |

> 💡 Si una condición se puede escribir en el `WHERE`, va en el `WHERE`: descarta filas antes y la consulta trabaja menos. El `HAVING` queda para lo que depende de un `COUNT`, `SUM`, `AVG`, `MAX` o `MIN`.

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1055`: *…isn't in GROUP BY* | En el `SELECT` hay una columna que no está en el `GROUP BY` ni dentro de una función | Agregarla al `GROUP BY` o resumirla |
| `Error 1111`: *Invalid use of group function* | Función de agrupación dentro del `WHERE` | Pasar esa condición al `HAVING` |
| `Error 1064` cerca de `GROUP BY` | El `GROUP BY` quedó antes del `WHERE` o después del `ORDER BY` | Orden: `WHERE` → `GROUP BY` → `HAVING` → `ORDER BY` |
| Falta un grupo en el resultado | No hay filas de ese grupo en la tabla (el grupo 4, Filosofía) | Se resuelve con `LEFT JOIN`, más adelante en este módulo |
| Los grupos salen en cualquier orden | `GROUP BY` no ordena | Agregar `ORDER BY` |
| Sale una fila por cada registro | Se agrupó por la clave primaria | Agrupar por la columna que realmente define el grupo |

---

Continuamos por cómo mostrar el **nombre** de la asignatura en lugar de su número → [INNER JOIN: Uniendo tablas](INNER-JOIN)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** ¿Cuántas asignaturas dicta cada docente? Mostrá el `id_docente` y la cantidad.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_docente,
       COUNT(*) AS asignaturas
FROM asignatura
GROUP BY id_docente
ORDER BY id_docente;
```

| id_docente | asignaturas |
| ---------- | ----------- |
| 1 | 1 |
| 2 | 1 |
| 3 | 2 |
| 4 | 2 |

💡 La docente 5 no aparece: no dicta ninguna asignatura, así que no hay filas suyas en `asignatura`.
</details>

**2.** Mostrá el promedio de cada estudiante, del más alto al más bajo.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_estudiante,
       ROUND(AVG(nota), 2) AS promedio
FROM inscripcion
GROUP BY id_estudiante
ORDER BY promedio DESC, id_estudiante;
```

| id_estudiante | promedio |
| ------------- | -------- |
| 5 | 9.83 |
| 7 | 9.50 |
| 1 | 9.17 |
| 3 | 8.25 |
| 6 | 7.50 |
| 9 | 7.00 |
| 2 | 6.50 |
| 4 | 5.00 |
| 8 | 4.50 |

💡 En el `ORDER BY` se puede usar el alias `promedio`.
</details>

**3.** ¿Qué asignaturas tienen alguna inscripción sin nota, y cuántas?

<details>
<summary>Ver solución</summary>

```sql
SELECT id_asignatura,
       COUNT(*) AS sin_nota
FROM inscripcion
WHERE nota IS NULL
GROUP BY id_asignatura
ORDER BY id_asignatura;
```

| id_asignatura | sin_nota |
| ------------- | -------- |
| 12 | 1 |
| 14 | 2 |

💡 La condición es sobre cada fila (`nota IS NULL`), por eso va en el `WHERE`.
</details>

**4.** Mostrá los estudiantes cuya peor nota es 7 o más.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_estudiante,
       MIN(nota) AS peor_nota
FROM inscripcion
GROUP BY id_estudiante
HAVING MIN(nota) >= 7
ORDER BY id_estudiante;
```

| id_estudiante | peor_nota |
| ------------- | --------- |
| 1 | 7.00 |
| 5 | 8.50 |
| 6 | 7.50 |
| 7 | 9.00 |
| 9 | 7.00 |

💡 La condición es sobre un resumen (`MIN`), por eso va en el `HAVING`.
</details>

**5.** ¿Cuántos grupos hay en cada turno?

<details>
<summary>Ver solución</summary>

```sql
SELECT turno,
       COUNT(*) AS grupos
FROM grupo
GROUP BY turno
ORDER BY grupos DESC, turno;
```

| turno | grupos |
| ----- | ------ |
| matutino | 2 |
| nocturno | 1 |
| vespertino | 1 |

💡 Se puede agrupar por cualquier columna, no solo por identificadores.
</details>

**6.** Considerando solo las inscripciones con nota, mostrá las asignaturas donde la diferencia entre la mejor y la peor nota es mayor que 4.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_asignatura,
       MAX(nota) - MIN(nota) AS diferencia
FROM inscripcion
WHERE nota IS NOT NULL
GROUP BY id_asignatura
HAVING MAX(nota) - MIN(nota) > 4
ORDER BY diferencia DESC;
```

| id_asignatura | diferencia |
| ------------- | ---------- |
| 10 | 8.00 |

💡 El `WHERE` acá no cambia el resultado (las funciones ya ignoran los `NULL`), pero deja clara la intención.
</details>

---

## 📋 Palabras clave

`GROUP BY` · `HAVING` · `grupo` · `columna de agrupación` · `función de agrupación` · `WHERE vs HAVING` · `orden de ejecución` · `COUNT` · `AVG` · `resumen por grupo` · `Error 1055` · `Error 1111` · `ONLY_FULL_GROUP_BY`

---

🧠 **[Autoevaluación — Módulo 8](auto-modulo8)**

---

← [Funciones de Agrupación (SUM, COUNT, AVG)](Funciones-de-agrupacion) · [🏠 Inicio](Home) · [INNER JOIN: Uniendo tablas →](INNER-JOIN)
