> 🗄️ **Base de datos:** `liceo` (Módulo 8 — Consultas Avanzadas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🔗 INNER JOIN: Uniendo tablas

## ¿Por qué lo necesitamos?

Al normalizar repartimos la información en varias tablas para no repetir datos. El costo es que cada tabla, sola, dice poco:

```sql
-- ❌ ¿Quién es el estudiante 5? ¿Qué asignatura es la 10?
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE nota >= 10
ORDER BY nota DESC, id_estudiante;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 5 | 10 | 12.00 |
| 1 | 14 | 11.00 |
| 3 | 12 | 10.00 |
| 7 | 10 | 10.00 |

Los nombres están en `estudiante` y en `asignatura`. Un **JOIN** vuelve a juntar, en el momento de consultar, lo que el diseño separó:

```sql
-- ✅ Los mismos datos, con nombres
SELECT e.nombre, e.apellido, a.nombre AS asignatura, i.nota
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
WHERE i.nota >= 10
ORDER BY i.nota DESC, e.id_estudiante;
```

**Resultado:**

| nombre | apellido | asignatura | nota |
| ------ | -------- | ---------- | ---- |
| Camila | González | Matemática | 12.00 |
| Lucía | Fernández | Programación | 11.00 |
| Valentina | Rodríguez | Historia | 10.00 |
| Sofía | López | Matemática | 10.00 |

> **¿Qué es un JOIN?** Es la operación que combina filas de dos tablas usando una condición, casi siempre "la clave foránea de una es igual a la clave primaria de la otra". El `INNER JOIN` devuelve solo las combinaciones donde **hay coincidencia en las dos tablas**.

**Ventajas:**

- Los datos siguen guardados una sola vez (sin redundancia).
- El resultado se lee como si fuera una sola tabla.

---

## Sintaxis

```sql
SELECT <columnas>
FROM <tabla1>
INNER JOIN <tabla2> ON <tabla1>.<columna> = <tabla2>.<columna>;
```

### Anatomía de la sentencia

```text
 estudiante                                grupo
┌───────────────┬───────────┬──────────┐  ┌──────────┬────────┬────────────┐
│ id_estudiante │ nombre    │ id_grupo │  │ id_grupo │ nombre │ turno      │
├───────────────┼───────────┼──────────┤  ├──────────┼────────┼────────────┤
│ 1             │ Lucía     │ 1  ──────┼─▶│ 1        │ 3ºA    │ matutino   │
│ 2             │ Mateo     │ 2  ──────┼─▶│ 2        │ 3ºB    │ vespertino │
│ 6             │ Joaquín   │ 3  ──────┼─▶│ 3        │ 2ºA    │ matutino   │
└───────────────┴───────────┴──────────┘  │ 4        │ 2ºB    │ nocturno   │ ← sin pareja:
          FK                              └──────────┴────────┴────────────┘   no aparece
                    ON estudiante.id_grupo = grupo.id_grupo
```

| Parte | Descripción |
| ----- | ----------- |
| `FROM tabla1` | La primera tabla |
| `INNER JOIN tabla2` | La tabla que se suma |
| `ON …` | La condición que dice qué fila va con cuál: FK = PK |
| `tabla.columna` | Aclara de qué tabla es la columna cuando el nombre se repite |

---

## Paso 1 — Unir dos tablas

Cada estudiante con el nombre de su grupo:

```sql
SELECT estudiante.nombre, estudiante.apellido, grupo.nombre, grupo.turno
FROM estudiante
INNER JOIN grupo ON estudiante.id_grupo = grupo.id_grupo
ORDER BY estudiante.id_estudiante
LIMIT 5;
```

**Resultado:**

| nombre | apellido | nombre | turno |
| ------ | -------- | ------ | ----- |
| Lucía | Fernández | 3ºA | matutino |
| Mateo | Silva | 3ºB | vespertino |
| Valentina | Rodríguez | 3ºA | matutino |
| Santiago | Pérez | 3ºA | matutino |
| Camila | González | 3ºB | vespertino |

MySQL recorre los estudiantes y, para cada uno, busca en `grupo` la fila cuyo `id_grupo` coincide. Hay dos columnas que se llaman `nombre`, por eso hay que escribir `estudiante.nombre` y `grupo.nombre`.

---

## Paso 2 — Alias de tabla

Repetir el nombre completo de la tabla cansa. Con `AS` se le pone un apodo corto que vale solo dentro de la consulta:

```sql
SELECT e.nombre, e.apellido, g.nombre AS grupo, g.turno
FROM estudiante AS e
INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo
WHERE g.turno = 'matutino'
ORDER BY e.apellido;
```

**Resultado:**

| nombre | apellido | grupo | turno |
| ------ | -------- | ----- | ----- |
| Benjamín | Castro | 2ºA | matutino |
| Lucía | Fernández | 3ºA | matutino |
| Sofía | López | 2ºA | matutino |
| Joaquín | Martínez | 2ºA | matutino |
| Santiago | Pérez | 3ºA | matutino |
| Valentina | Rodríguez | 3ºA | matutino |

**Elementos clave:**

- `estudiante AS e`: desde ahí, la tabla se llama `e` en toda la consulta.
- `g.nombre AS grupo`: alias de **columna**, para que el resultado no tenga dos columnas llamadas `nombre`.
- Después del `JOIN` se puede usar `WHERE`, `ORDER BY` y `LIMIT` como siempre, con columnas de cualquiera de las dos tablas.

---

## Paso 3 — Otra relación 1:N

Cada asignatura con su docente:

```sql
SELECT a.nombre AS asignatura,
       d.nombre,
       d.apellido
FROM asignatura AS a
INNER JOIN docente AS d ON d.id_docente = a.id_docente
ORDER BY a.nombre;
```

**Resultado:**

| asignatura | nombre | apellido |
| ---------- | ------ | -------- |
| Filosofía | Laura | Sosa |
| Física | Carlos | Méndez |
| Historia | Laura | Sosa |
| Matemática | Ana | Pereira |
| Programación | Diego | Olivera |
| Química | Diego | Olivera |

Laura Sosa y Diego Olivera aparecen dos veces porque dictan dos asignaturas. Marta Giménez no aparece: no dicta ninguna, así que ninguna fila de `asignatura` coincide con ella.

> 📌 **Nota:** eso es lo que significa *inner*: solo salen las filas que tienen pareja. Las que no coinciden con nada quedan afuera, de los dos lados.

---

## Paso 4 — Unir tres tablas (relación N:N)

`inscripcion` es la tabla intermedia entre `estudiante` y `asignatura`. Para ir de un extremo al otro hay que pasar por ella, con un `JOIN` por cada salto:

```text
estudiante ──▶ inscripcion ──▶ asignatura
        id_estudiante     id_asignatura
```

Las notas de Lucía Fernández:

```sql
SELECT e.nombre, a.nombre AS asignatura, i.nota
FROM estudiante AS e
INNER JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
INNER JOIN asignatura  AS a ON a.id_asignatura = i.id_asignatura
WHERE e.id_estudiante = 1
ORDER BY a.nombre;
```

**Resultado:**

| nombre | asignatura | nota |
| ------ | ---------- | ---- |
| Lucía | Física | 7.00 |
| Lucía | Matemática | 9.50 |
| Lucía | Programación | 11.00 |

> 💡 Para unir `n` tablas hacen falta `n - 1` condiciones `ON`. Tres tablas, dos `JOIN`.

---

## Paso 5 — Cuatro tablas

¿Qué docente le da clase a cada estudiante del grupo 3ºB?

```sql
SELECT e.apellido AS estudiante,
       a.nombre   AS asignatura,
       d.apellido AS docente
FROM estudiante AS e
INNER JOIN grupo       AS g ON g.id_grupo = e.id_grupo
INNER JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
INNER JOIN asignatura  AS a ON a.id_asignatura = i.id_asignatura
INNER JOIN docente     AS d ON d.id_docente = a.id_docente
WHERE g.nombre = '3ºB'
ORDER BY e.apellido, a.nombre;
```

**Resultado:**

| estudiante | asignatura | docente |
| ---------- | ---------- | ------- |
| González | Historia | Sosa |
| González | Matemática | Pereira |
| González | Química | Olivera |
| Silva | Matemática | Pereira |
| Silva | Química | Olivera |
| Suárez | Programación | Olivera |
| Suárez | Química | Olivera |

Agustín Núñez es de 3ºB y no está en el resultado: no tiene inscripciones, y el `INNER JOIN` lo deja afuera.

---

## Paso 6 — JOIN con GROUP BY

Ahora sí, el promedio por asignatura con nombre en lugar de número:

```sql
SELECT a.nombre            AS asignatura,
       COUNT(*)            AS inscriptos,
       ROUND(AVG(i.nota), 2) AS promedio
FROM asignatura AS a
INNER JOIN inscripcion AS i ON i.id_asignatura = a.id_asignatura
GROUP BY a.id_asignatura, a.nombre
ORDER BY promedio DESC;
```

**Resultado:**

| asignatura | inscriptos | promedio |
| ---------- | ---------- | -------- |
| Programación | 4 | 10.00 |
| Historia | 4 | 8.33 |
| Matemática | 7 | 8.21 |
| Química | 3 | 6.83 |
| Física | 3 | 5.33 |

Primero se arma la tabla unida y después se agrupa. Y el promedio de cada grupo de estudiantes:

```sql
SELECT g.nombre              AS grupo,
       ROUND(AVG(i.nota), 2) AS promedio
FROM grupo AS g
INNER JOIN estudiante  AS e ON e.id_grupo = g.id_grupo
INNER JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
GROUP BY g.id_grupo, g.nombre
ORDER BY promedio DESC;
```

**Resultado:**

| grupo | promedio |
| ----- | -------- |
| 3ºB | 8.25 |
| 3ºA | 7.71 |
| 2ºA | 7.10 |

---

## ¿Qué pasa si falta el ON?

Sin condición, MySQL combina **cada** fila de una tabla con **todas** las de la otra. Se llama **producto cartesiano**:

```sql
SELECT COUNT(*) AS filas
FROM estudiante
INNER JOIN grupo;
```

**Resultado:**

| filas |
| ----- |
| 40 |

Son 10 estudiantes × 4 grupos. Casi todas esas filas son mentira: dicen que Lucía está en los cuatro grupos a la vez.

> ⚠️ **Cuidado:** un `JOIN` sin `ON` no da error, da un resultado enorme y equivocado. Con tablas grandes puede dejar el servidor trabajando varios minutos.

## Diferencia clave: JOIN explícito vs JOIN en el WHERE

Vas a encontrar consultas viejas escritas así:

```sql
-- Sintaxis antigua
SELECT e.nombre, g.nombre
FROM estudiante AS e, grupo AS g
WHERE e.id_grupo = g.id_grupo;
```

| Aspecto | `INNER JOIN … ON` | Tablas con coma + `WHERE` |
| ------- | ----------------- | ------------------------- |
| Resultado | El mismo | El mismo |
| Dónde va la unión | En el `ON` | Mezclada con los filtros |
| Si me olvido de la condición | Se nota enseguida | Producto cartesiano sin aviso |
| Admite `LEFT JOIN` | Sí | No |
| Recomendado | ✅ | Solo para leer código viejo |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1052`: *Column 'nombre' in field list is ambiguous* | La columna existe en dos tablas y no se dijo de cuál es | Anteponer la tabla o el alias: `e.nombre` |
| `Error 1054`: *Unknown column 'estudiante.nombre'* | Se definió un alias y después se usó el nombre completo | Si hay alias, usar siempre el alias |
| Salen muchísimas filas, todas combinadas | Falta el `ON`, o la condición es incorrecta | Revisar que haya un `ON` por cada `JOIN` |
| Faltan filas (un estudiante, un docente) | No tienen coincidencia en la otra tabla | Es lo esperado en un `INNER JOIN`; para verlas, `LEFT JOIN` |
| `Error 1066`: *Not unique table/alias* | Se usó el mismo alias para dos tablas | Un alias distinto para cada una |
| Los totales dan más de lo real | Al unir, las filas se multiplicaron (1:N) y se sumó un dato repetido | Contar con `COUNT(DISTINCT …)` o resumir antes de unir |

---

Continuamos por cómo mostrar también las filas que **no** tienen pareja → [LEFT JOIN y RIGHT JOIN](LEFT-JOIN-y-RIGHT-JOIN)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Mostrá el nombre y apellido de los estudiantes del turno vespertino.

<details>
<summary>Ver solución</summary>

```sql
SELECT e.nombre, e.apellido
FROM estudiante AS e
INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo
WHERE g.turno = 'vespertino'
ORDER BY e.apellido;
```

| nombre | apellido |
| ------ | -------- |
| Camila | González |
| Agustín | Núñez |
| Mateo | Silva |
| Martina | Suárez |

💡 Se puede filtrar por una columna de `grupo` aunque no se muestre.
</details>

**2.** Mostrá las asignaturas que dicta el docente de apellido Olivera.

<details>
<summary>Ver solución</summary>

```sql
SELECT a.nombre AS asignatura
FROM asignatura AS a
INNER JOIN docente AS d ON d.id_docente = a.id_docente
WHERE d.apellido = 'Olivera'
ORDER BY a.nombre;
```

| asignatura |
| ---------- |
| Programación |
| Química |

💡 No hace falta saber que Olivera es el docente 4: el `JOIN` lo resuelve.
</details>

**3.** Mostrá nombre, apellido y nota de los inscriptos en Historia, de la mejor nota a la peor.

<details>
<summary>Ver solución</summary>

```sql
SELECT e.nombre, e.apellido, i.nota
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
WHERE a.nombre = 'Historia'
ORDER BY i.nota DESC;
```

| nombre | apellido | nota |
| ------ | -------- | ---- |
| Valentina | Rodríguez | 10.00 |
| Camila | González | 9.00 |
| Benjamín | Castro | 6.00 |
| Joaquín | Martínez | NULL |

💡 En orden descendente, el `NULL` queda último.
</details>

**4.** ¿En cuántas asignaturas está inscripto cada estudiante? Mostrá nombre, apellido y cantidad, de mayor a menor.

<details>
<summary>Ver solución</summary>

```sql
SELECT e.nombre, e.apellido,
       COUNT(*) AS asignaturas
FROM estudiante AS e
INNER JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
GROUP BY e.id_estudiante, e.nombre, e.apellido
ORDER BY asignaturas DESC, e.apellido;
```

| nombre | apellido | asignaturas |
| ------ | -------- | ----------- |
| Lucía | Fernández | 3 |
| Camila | González | 3 |
| Santiago | Pérez | 3 |
| Benjamín | Castro | 2 |
| Sofía | López | 2 |
| Joaquín | Martínez | 2 |
| Valentina | Rodríguez | 2 |
| Mateo | Silva | 2 |
| Martina | Suárez | 2 |

💡 Salen 9 estudiantes y el liceo tiene 10: el que no tiene inscripciones no aparece. Lo arreglamos en la página siguiente.
</details>

**5.** ¿Cuántos estudiantes diferentes tiene cada docente? Mostrá el apellido del docente y la cantidad.

<details>
<summary>Ver solución</summary>

```sql
SELECT d.apellido,
       COUNT(DISTINCT i.id_estudiante) AS estudiantes
FROM docente AS d
INNER JOIN asignatura  AS a ON a.id_docente = d.id_docente
INNER JOIN inscripcion AS i ON i.id_asignatura = a.id_asignatura
GROUP BY d.id_docente, d.apellido
ORDER BY estudiantes DESC, d.apellido;
```

| apellido | estudiantes |
| -------- | ----------- |
| Pereira | 7 |
| Olivera | 6 |
| Sosa | 4 |
| Méndez | 3 |

💡 Hace falta `DISTINCT`: un estudiante inscripto en dos asignaturas del mismo docente se contaría dos veces.
</details>

**6.** Mostrá los docentes que tienen algún estudiante con nota menor que 6: apellido del docente, asignatura, apellido del estudiante y nota.

<details>
<summary>Ver solución</summary>

```sql
SELECT d.apellido AS docente,
       a.nombre   AS asignatura,
       e.apellido AS estudiante,
       i.nota
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
INNER JOIN docente    AS d ON d.id_docente = a.id_docente
WHERE i.nota < 6
ORDER BY i.nota;
```

| docente | asignatura | estudiante | nota |
| ------- | ---------- | ---------- | ---- |
| Méndez | Física | Castro | 3.00 |
| Pereira | Matemática | Pérez | 4.00 |
| Olivera | Química | Silva | 5.00 |

💡 Cuatro tablas, tres `JOIN`. Conviene empezar el `FROM` por la tabla "del medio" (`inscripcion`) y salir hacia los costados.
</details>

---

## 📋 Palabras clave

`JOIN` · `INNER JOIN` · `ON` · `clave foránea` · `clave primaria` · `alias de tabla` · `tabla.columna` · `columna ambigua` · `producto cartesiano` · `tabla intermedia` · `relación N:N` · `coincidencia` · `Error 1052`

---

🧠 **[Autoevaluación — Módulo 8](auto-modulo8)**

---

← [GROUP BY y HAVING](GROUP-BY-y-HAVING) · [🏠 Inicio](Home) · [LEFT JOIN y RIGHT JOIN →](LEFT-JOIN-y-RIGHT-JOIN)
