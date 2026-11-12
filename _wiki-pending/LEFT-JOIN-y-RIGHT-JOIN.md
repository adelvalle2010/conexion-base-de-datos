> 🗄️ **Base de datos:** `liceo` (Módulo 8 — Consultas Avanzadas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# ↔️ LEFT JOIN y RIGHT JOIN

## ¿Por qué lo necesitamos?

El `INNER JOIN` deja afuera todo lo que no tiene pareja. Muchas veces eso es justo lo que queremos ver: el grupo sin estudiantes, la docente sin asignaturas, el estudiante que no se inscribió.

```sql
-- ❌ El liceo tiene 4 grupos, pero acá salen 3
SELECT g.nombre AS grupo,
       COUNT(*) AS estudiantes
FROM grupo AS g
INNER JOIN estudiante AS e ON e.id_grupo = g.id_grupo
GROUP BY g.id_grupo, g.nombre
ORDER BY g.id_grupo;
```

**Resultado:**

| grupo | estudiantes |
| ----- | ----------- |
| 3ºA | 3 |
| 3ºB | 4 |
| 2ºA | 3 |

```sql
-- ✅ Los 4 grupos, aunque alguno esté vacío
SELECT g.nombre                AS grupo,
       COUNT(e.id_estudiante) AS estudiantes
FROM grupo AS g
LEFT JOIN estudiante AS e ON e.id_grupo = g.id_grupo
GROUP BY g.id_grupo, g.nombre
ORDER BY g.id_grupo;
```

**Resultado:**

| grupo | estudiantes |
| ----- | ----------- |
| 3ºA | 3 |
| 3ºB | 4 |
| 2ºA | 3 |
| 2ºB | 0 |

> **¿Qué es un LEFT JOIN?** Es un JOIN que devuelve **todas** las filas de la tabla de la izquierda (la del `FROM`), tengan o no coincidencia en la de la derecha. Donde no hay coincidencia, las columnas de la derecha se completan con `NULL`.

---

## Sintaxis

```sql
SELECT <columnas>
FROM <tabla_izquierda>
LEFT JOIN <tabla_derecha> ON <condición>;
```

### Anatomía de la sentencia

```text
 docente (izquierda)              asignatura (derecha)
 ┌──────────┐                     ┌────────────┐
 │ Pereira  │ ──────────────────▶ │ Matemática │
 │ Méndez   │ ──────────────────▶ │ Física     │
 │ Giménez  │ ───── sin pareja    └────────────┘
 └──────────┘

 INNER JOIN  →  Pereira–Matemática · Méndez–Física
 LEFT JOIN   →  Pereira–Matemática · Méndez–Física · Giménez–NULL
```

| Parte | Descripción |
| ----- | ----------- |
| Tabla izquierda | La que se escribe **antes** de la palabra `JOIN` |
| Tabla derecha | La que se escribe **después** |
| `LEFT JOIN` | Conserva todas las filas de la izquierda |
| `RIGHT JOIN` | Conserva todas las filas de la derecha |
| `LEFT OUTER JOIN` | Lo mismo que `LEFT JOIN`; la palabra `OUTER` es opcional |

---

## Paso 1 — Ver las filas sin pareja

Todos los docentes con las asignaturas que dictan:

```sql
SELECT d.nombre, d.apellido, a.nombre AS asignatura
FROM docente AS d
LEFT JOIN asignatura AS a ON a.id_docente = d.id_docente
ORDER BY d.id_docente, a.nombre;
```

**Resultado:**

| nombre | apellido | asignatura |
| ------ | -------- | ---------- |
| Ana | Pereira | Matemática |
| Carlos | Méndez | Física |
| Laura | Sosa | Filosofía |
| Laura | Sosa | Historia |
| Diego | Olivera | Programación |
| Diego | Olivera | Química |
| Marta | Giménez | NULL |

Marta Giménez ahora aparece. Como no hay ninguna asignatura suya, la columna que viene de `asignatura` queda en `NULL`.

---

## Paso 2 — Quedarse solo con las que NO tienen pareja

Ese `NULL` sirve para preguntar "¿quién no tiene…?". ¿Qué estudiantes no se inscribieron a ninguna asignatura?

```sql
SELECT e.id_estudiante, e.nombre, e.apellido
FROM estudiante AS e
LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
WHERE i.id_estudiante IS NULL;
```

**Resultado:**

| id_estudiante | nombre | apellido |
| ------------- | ------ | -------- |
| 10 | Agustín | Núñez |

Era el estudiante que nos faltaba desde la primera página del módulo.

**Elementos clave:**

- El `LEFT JOIN` trae a todos los estudiantes.
- Los que no tienen inscripciones quedan con `NULL` en las columnas de `inscripcion`.
- El `WHERE … IS NULL` se queda solo con esos.
- Se pregunta por una columna de la derecha que **nunca** es `NULL` cuando hay coincidencia: la clave. Preguntar por `i.nota IS NULL` estaría mal, porque también hay inscripciones reales sin nota.

Lo mismo con las asignaturas sin inscriptos:

```sql
SELECT a.nombre AS asignatura_sin_inscriptos
FROM asignatura AS a
LEFT JOIN inscripcion AS i ON i.id_asignatura = a.id_asignatura
WHERE i.id_asignatura IS NULL;
```

**Resultado:**

| asignatura_sin_inscriptos |
| ------------------------- |
| Filosofía |

---

## Paso 3 — Contar con LEFT JOIN: cuidado con COUNT(*)

¿En cuántas asignaturas está inscripto cada estudiante de 3ºB, incluyendo al que no tiene ninguna?

```sql
SELECT e.nombre, e.apellido,
       COUNT(*)               AS con_asterisco,
       COUNT(i.id_asignatura) AS con_columna
FROM estudiante AS e
LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
WHERE e.id_grupo = 2
GROUP BY e.id_estudiante, e.nombre, e.apellido
ORDER BY e.apellido;
```

**Resultado:**

| nombre | apellido | con_asterisco | con_columna |
| ------ | -------- | ------------- | ----------- |
| Camila | González | 3 | 3 |
| Agustín | Núñez | 1 | 0 |
| Mateo | Silva | 2 | 2 |
| Martina | Suárez | 2 | 2 |

Para Agustín, `COUNT(*)` dice 1 y `COUNT(i.id_asignatura)` dice 0. El correcto es el segundo: Agustín tiene **una fila** en el resultado (la que el `LEFT JOIN` completó con `NULL`), pero **cero** inscripciones.

> ⚠️ **Regla:** con `LEFT JOIN`, contar siempre una columna de la tabla de la derecha, nunca `COUNT(*)`.

---

## Paso 4 — Varios LEFT JOIN encadenados

El promedio de cada asignatura, incluida la que no tiene inscriptos, con su docente:

```sql
SELECT a.nombre               AS asignatura,
       d.apellido             AS docente,
       COUNT(i.id_estudiante) AS inscriptos,
       ROUND(AVG(i.nota), 2)  AS promedio
FROM asignatura AS a
INNER JOIN docente    AS d ON d.id_docente = a.id_docente
LEFT JOIN inscripcion AS i ON i.id_asignatura = a.id_asignatura
GROUP BY a.id_asignatura, a.nombre, d.apellido
ORDER BY a.nombre;
```

**Resultado:**

| asignatura | docente | inscriptos | promedio |
| ---------- | ------- | ---------- | -------- |
| Filosofía | Sosa | 0 | NULL |
| Física | Méndez | 3 | 5.33 |
| Historia | Sosa | 4 | 8.33 |
| Matemática | Pereira | 7 | 8.21 |
| Programación | Olivera | 4 | 10.00 |
| Química | Olivera | 3 | 6.83 |

Se pueden mezclar tipos de JOIN: toda asignatura tiene docente (la columna es `NOT NULL`), así que ahí alcanza con `INNER`. Las inscripciones pueden faltar, y ahí va el `LEFT`.

Para mostrar un texto en lugar del `NULL`, `IFNULL(valor, reemplazo)`:

```sql
SELECT d.apellido                             AS docente,
       IFNULL(a.nombre, '(sin asignaturas)') AS asignatura
FROM docente AS d
LEFT JOIN asignatura AS a ON a.id_docente = d.id_docente
WHERE d.id_docente >= 4
ORDER BY d.id_docente, a.nombre;
```

**Resultado:**

| docente | asignatura |
| ------- | ---------- |
| Olivera | Programación |
| Olivera | Química |
| Giménez | (sin asignaturas) |

---

## Paso 5 — Filtrar la tabla derecha: ON no es lo mismo que WHERE

Queremos **todos** los estudiantes del grupo 1 y, si la tienen, su nota de Física (11).

```sql
-- ❌ El WHERE elimina a quienes no cursan Física
SELECT e.nombre, i.nota
FROM estudiante AS e
LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
WHERE e.id_grupo = 1
  AND i.id_asignatura = 11
ORDER BY e.id_estudiante;
```

**Resultado:**

| nombre | nota |
| ------ | ---- |
| Lucía | 7.00 |
| Santiago | 6.00 |

```sql
-- ✅ La condición sobre la tabla derecha va en el ON
SELECT e.nombre, i.nota
FROM estudiante AS e
LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
                          AND i.id_asignatura = 11
WHERE e.id_grupo = 1
ORDER BY e.id_estudiante;
```

**Resultado:**

| nombre | nota |
| ------ | ---- |
| Lucía | 7.00 |
| Valentina | NULL |
| Santiago | 6.00 |

En la primera, Valentina llega al `WHERE` con sus inscripciones a otras asignaturas, ninguna cumple `id_asignatura = 11` y se va. En la segunda, la condición decide **qué inscripciones se unen**; si ninguna sirve, Valentina queda igual, con `NULL`.

> 💡 En un `LEFT JOIN`: lo que va en el `ON` decide **con qué se une**; lo que va en el `WHERE` decide **qué filas quedan** al final.

---

## Paso 6 — RIGHT JOIN

Es el espejo: conserva todas las filas de la tabla de la **derecha**.

```sql
SELECT a.nombre AS asignatura, d.apellido AS docente
FROM asignatura AS a
RIGHT JOIN docente AS d ON d.id_docente = a.id_docente
ORDER BY d.id_docente, a.nombre;
```

**Resultado:**

| asignatura | docente |
| ---------- | ------- |
| Matemática | Pereira |
| Física | Méndez |
| Filosofía | Sosa |
| Historia | Sosa |
| Programación | Olivera |
| Química | Olivera |
| NULL | Giménez |

Es el mismo resultado del Paso 1 con las tablas escritas en el otro orden. Cualquier `RIGHT JOIN` se puede reescribir como `LEFT JOIN` dando vuelta las tablas, y por eso en la práctica casi siempre se usa `LEFT`: se lee de izquierda a derecha, "todos estos, con lo que tengan de aquello".

> 📌 **Nota:** otros motores tienen `FULL OUTER JOIN`, que conserva las filas sin pareja de **los dos** lados. MySQL no lo tiene; se arma con un `LEFT JOIN`, un `RIGHT JOIN` y `UNION`, que vemos en [UNION: Combinar resultados](UNION).

---

## Diferencia clave: INNER JOIN vs LEFT JOIN vs RIGHT JOIN

| Aspecto | `INNER JOIN` | `LEFT JOIN` | `RIGHT JOIN` |
| ------- | ------------ | ----------- | ------------ |
| Filas con coincidencia | Sí | Sí | Sí |
| Filas de la izquierda sin pareja | No | Sí, con `NULL` a la derecha | No |
| Filas de la derecha sin pareja | No | No | Sí, con `NULL` a la izquierda |
| ¿Importa el orden de las tablas? | No | Sí | Sí |
| Pregunta típica | Notas con nombre | Todos los grupos, aunque estén vacíos | (igual que `LEFT`, al revés) |

**¿Cuándo usar cada uno?**

- **`INNER JOIN`**: solo interesa lo que está relacionado.
- **`LEFT JOIN`**: la consigna dice "todos", "incluso los que no", "aunque no tengan".
- **`LEFT JOIN … WHERE … IS NULL`**: la consigna dice "los que no tienen", "sin", "ninguno".

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| El `LEFT JOIN` se comporta como `INNER JOIN` | Hay una condición sobre la tabla derecha en el `WHERE` | Pasarla al `ON` |
| Un grupo vacío figura con 1 estudiante | Se usó `COUNT(*)` | `COUNT(columna_de_la_derecha)` |
| Siguen faltando filas | La tabla que se quería conservar quedó a la derecha | Ponerla en el `FROM`, o usar `RIGHT JOIN` |
| "Los que no tienen" trae filas de más | Se preguntó `IS NULL` sobre una columna que admite nulos (`nota`) | Preguntar por la clave: `i.id_estudiante IS NULL` |
| `Error 1064` cerca de `FULL` | MySQL no tiene `FULL OUTER JOIN` | `LEFT JOIN` + `UNION` + `RIGHT JOIN` |
| Un `LEFT JOIN` seguido de un `INNER JOIN` pierde filas | El `INNER` posterior descarta las filas con `NULL` | Usar `LEFT JOIN` también en los siguientes |

---

Continuamos por consultas que usan el resultado de **otra consulta** → [Subconsultas](Subconsultas)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Mostrá todos los grupos con el apellido de sus estudiantes; los grupos vacíos también deben aparecer.

<details>
<summary>Ver solución</summary>

```sql
SELECT g.nombre AS grupo, e.apellido
FROM grupo AS g
LEFT JOIN estudiante AS e ON e.id_grupo = g.id_grupo
ORDER BY g.id_grupo, e.apellido;
```

| grupo | apellido |
| ----- | -------- |
| 3ºA | Fernández |
| 3ºA | Pérez |
| 3ºA | Rodríguez |
| 3ºB | González |
| 3ºB | Núñez |
| 3ºB | Silva |
| 3ºB | Suárez |
| 2ºA | Castro |
| 2ºA | López |
| 2ºA | Martínez |
| 2ºB | NULL |

💡 "Todos los grupos" indica que `grupo` va a la izquierda.
</details>

**2.** ¿Qué docentes no dictan ninguna asignatura?

<details>
<summary>Ver solución</summary>

```sql
SELECT d.nombre, d.apellido
FROM docente AS d
LEFT JOIN asignatura AS a ON a.id_docente = d.id_docente
WHERE a.id_asignatura IS NULL;
```

| nombre | apellido |
| ------ | -------- |
| Marta | Giménez |

💡 Patrón "los que no tienen": `LEFT JOIN` + `IS NULL` sobre la clave de la derecha.
</details>

**3.** ¿Qué grupos no tienen estudiantes?

<details>
<summary>Ver solución</summary>

```sql
SELECT g.nombre, g.turno
FROM grupo AS g
LEFT JOIN estudiante AS e ON e.id_grupo = g.id_grupo
WHERE e.id_estudiante IS NULL;
```

| nombre | turno |
| ------ | ----- |
| 2ºB | nocturno |

💡 Mismo patrón, otras tablas.
</details>

**4.** Mostrá cuántas asignaturas dicta cada docente, incluyendo a los que no dictan ninguna.

<details>
<summary>Ver solución</summary>

```sql
SELECT d.apellido,
       COUNT(a.id_asignatura) AS asignaturas
FROM docente AS d
LEFT JOIN asignatura AS a ON a.id_docente = d.id_docente
GROUP BY d.id_docente, d.apellido
ORDER BY asignaturas DESC, d.apellido;
```

| apellido | asignaturas |
| -------- | ----------- |
| Olivera | 2 |
| Sosa | 2 |
| Méndez | 1 |
| Pereira | 1 |
| Giménez | 0 |

💡 Con `COUNT(*)`, Giménez figuraría con 1.
</details>

**5.** Mostrá todos los estudiantes del grupo 3 (2ºA) con su nota de Historia (12). Si no la cursan, que igual aparezcan.

<details>
<summary>Ver solución</summary>

```sql
SELECT e.nombre, e.apellido, i.nota
FROM estudiante AS e
LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
                          AND i.id_asignatura = 12
WHERE e.id_grupo = 3
ORDER BY e.apellido;
```

| nombre | apellido | nota |
| ------ | -------- | ---- |
| Benjamín | Castro | 6.00 |
| Sofía | López | NULL |
| Joaquín | Martínez | NULL |

💡 Hay dos `NULL` con significados distintos: Joaquín cursa Historia y todavía no tiene nota; Sofía no la cursa. Para distinguirlos habría que mostrar también `i.id_asignatura`.
</details>

**6.** Mostrá la cantidad de inscripciones por grupo, incluyendo los grupos sin estudiantes.

<details>
<summary>Ver solución</summary>

```sql
SELECT g.nombre                AS grupo,
       COUNT(i.id_asignatura) AS inscripciones
FROM grupo AS g
LEFT JOIN estudiante  AS e ON e.id_grupo = g.id_grupo
LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
GROUP BY g.id_grupo, g.nombre
ORDER BY g.id_grupo;
```

| grupo | inscripciones |
| ----- | ------------- |
| 3ºA | 8 |
| 3ºB | 7 |
| 2ºA | 6 |
| 2ºB | 0 |

💡 El segundo `JOIN` también tiene que ser `LEFT`: con `INNER` se perdería el grupo vacío.
</details>

---

## 📋 Palabras clave

`LEFT JOIN` · `RIGHT JOIN` · `OUTER JOIN` · `INNER JOIN` · `tabla izquierda` · `tabla derecha` · `filas sin pareja` · `NULL` · `IS NULL` · `ON vs WHERE` · `COUNT(columna)` · `IFNULL` · `FULL OUTER JOIN` · `anti-join`

---

🧠 **[Autoevaluación — Módulo 8](auto-modulo8)**

---

← [INNER JOIN: Uniendo tablas](INNER-JOIN) · [🏠 Inicio](Home) · [Subconsultas →](Subconsultas)
