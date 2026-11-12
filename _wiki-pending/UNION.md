> 🗄️ **Base de datos:** `liceo` (Módulo 8 — Consultas Avanzadas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🧱 UNION: Combinar resultados

## ¿Por qué lo necesitamos?

La dirección del liceo quiere una lista única con **todas las personas**: estudiantes y docentes. Están en dos tablas distintas y no hay ninguna relación directa entre ellas, así que un `JOIN` no sirve: no hay nada que "hacer coincidir".

```sql
-- ❌ Dos consultas, dos resultados separados
SELECT nombre, apellido FROM docente;
SELECT nombre, apellido FROM estudiante;
```

`UNION` pone el resultado de una consulta **debajo** del de la otra:

```sql
-- ✅ Un solo resultado
SELECT nombre, apellido, 'docente' AS rol
FROM docente
UNION
SELECT nombre, apellido, 'estudiante'
FROM estudiante
WHERE id_grupo = 1
ORDER BY rol, apellido;
```

**Resultado:**

| nombre | apellido | rol |
| ------ | -------- | --- |
| Marta | Giménez | docente |
| Carlos | Méndez | docente |
| Diego | Olivera | docente |
| Ana | Pereira | docente |
| Laura | Sosa | docente |
| Lucía | Fernández | estudiante |
| Santiago | Pérez | estudiante |
| Valentina | Rodríguez | estudiante |

> **¿Qué es UNION?** Es un operador que junta las **filas** de dos o más consultas en un único resultado. Un `JOIN` suma columnas (une "a lo ancho"); un `UNION` suma filas (une "a lo largo").

---

## Sintaxis

```sql
SELECT <columnas>
FROM <tabla1>
UNION [ALL]
SELECT <columnas>
FROM <tabla2>
ORDER BY <columna>;
```

### Anatomía de la sentencia

```text
        JOIN: a lo ancho                    UNION: a lo largo
  ┌─────────┐   ┌─────────┐                  ┌─────────┐
  │ tabla A │ + │ tabla B │                  │consulta1│
  └─────────┘   └─────────┘                  ├─────────┤
       ▼                                     │consulta2│
  ┌─────────┬─────────┐                      └─────────┘
  │ cols A  │ cols B  │                    mismas columnas,
  └─────────┴─────────┘                       más filas
```

**Reglas que deben cumplir las consultas:**

1. La **misma cantidad** de columnas.
2. Tipos de datos **compatibles** en cada posición (texto con texto, número con número).
3. Los nombres de columna del resultado salen de la **primera** consulta.
4. Un solo `ORDER BY`, al final, que ordena el resultado completo.

---

## Paso 1 — UNION elimina los repetidos

¿Qué años de nacimiento hay entre los estudiantes de los grupos 1 y 2?

```sql
SELECT YEAR(fecha_nacimiento) AS anio
FROM estudiante
WHERE id_grupo = 1
UNION
SELECT YEAR(fecha_nacimiento)
FROM estudiante
WHERE id_grupo = 2
ORDER BY anio;
```

**Resultado:**

| anio |
| ---- |
| 2008 |
| 2009 |

Entre los dos grupos hay siete estudiantes, pero el resultado tiene dos filas: `UNION` deja cada valor una sola vez, como un `DISTINCT`.

---

## Paso 2 — UNION ALL conserva todo

```sql
SELECT YEAR(fecha_nacimiento) AS anio
FROM estudiante
WHERE id_grupo = 1
UNION ALL
SELECT YEAR(fecha_nacimiento)
FROM estudiante
WHERE id_grupo = 2
ORDER BY anio;
```

**Resultado:**

| anio |
| ---- |
| 2008 |
| 2008 |
| 2008 |
| 2009 |
| 2009 |
| 2009 |
| 2009 |

**¿Cuándo usar cada uno?**

- **`UNION`**: se quiere una lista sin repetidos.
- **`UNION ALL`**: se sabe que no hay repetidos, o se los quiere ver. Es más rápido, porque MySQL no tiene que compararlos.

---

## Paso 3 — Una columna fija para saber de dónde viene cada fila

Al mezclar tablas se pierde el origen. Se soluciona agregando un texto constante como columna:

```sql
SELECT 'Mejor nota' AS dato, MAX(nota) AS valor
FROM inscripcion
UNION ALL
SELECT 'Peor nota', MIN(nota)
FROM inscripcion
UNION ALL
SELECT 'Promedio', ROUND(AVG(nota), 2)
FROM inscripcion;
```

**Resultado:**

| dato | valor |
| ---- | ----- |
| Mejor nota | 12.00 |
| Peor nota | 3.00 |
| Promedio | 7.72 |

Se pueden encadenar todas las consultas que hagan falta. Acá `UNION` sirve para armar un pequeño informe "en vertical".

---

## Paso 4 — Agregar una fila de total

El promedio de cada asignatura y, al final, el general:

```sql
SELECT 1                     AS orden,
       a.nombre              AS asignatura,
       ROUND(AVG(i.nota), 2) AS promedio
FROM asignatura AS a
INNER JOIN inscripcion AS i ON i.id_asignatura = a.id_asignatura
GROUP BY a.id_asignatura, a.nombre
UNION ALL
SELECT 2,
       '— GENERAL —',
       ROUND(AVG(nota), 2)
FROM inscripcion
ORDER BY orden, asignatura;
```

**Resultado:**

| orden | asignatura | promedio |
| ----- | ---------- | -------- |
| 1 | Física | 5.33 |
| 1 | Historia | 8.33 |
| 1 | Matemática | 8.21 |
| 1 | Programación | 10.00 |
| 1 | Química | 6.83 |
| 2 | — GENERAL — | 7.72 |

La columna `orden` es un truco: vale 1 en las filas de detalle y 2 en la del total, y al ordenar por ella el total queda siempre último. Sin `ORDER BY`, el orden de las filas de un `UNION` no está garantizado.

---

## Paso 5 — Todas las filas de los dos lados (FULL OUTER JOIN)

MySQL no tiene `FULL OUTER JOIN`. Se consigue uniendo un `LEFT JOIN` con un `RIGHT JOIN`. Todos los docentes y todas las asignaturas, tengan pareja o no:

```sql
SELECT d.apellido AS docente, a.nombre AS asignatura
FROM docente AS d
LEFT JOIN asignatura AS a ON a.id_docente = d.id_docente
UNION
SELECT d.apellido, a.nombre
FROM docente AS d
RIGHT JOIN asignatura AS a ON a.id_docente = d.id_docente
ORDER BY docente, asignatura;
```

**Resultado:**

| docente | asignatura |
| ------- | ---------- |
| Giménez | NULL |
| Méndez | Física |
| Olivera | Programación |
| Olivera | Química |
| Pereira | Matemática |
| Sosa | Filosofía |
| Sosa | Historia |

El `LEFT` aporta a los docentes sin asignatura; el `RIGHT`, a las asignaturas sin docente; y `UNION` (sin `ALL`) elimina las filas que aparecen en las dos mitades.

> 📌 **Nota:** en nuestra base toda asignatura tiene docente (`id_docente` es `NOT NULL`), así que la segunda mitad no agrega filas nuevas. El patrón es el mismo para cualquier par de tablas.

---

## Diferencia clave: UNION vs UNION ALL vs JOIN

| Aspecto | `UNION` | `UNION ALL` | `JOIN` |
| ------- | ------- | ----------- | ------ |
| Combina | Filas | Filas | Columnas |
| Repetidos | Los elimina | Los conserva | — |
| Velocidad | Más lento | Más rápido | — |
| Requiere | Misma cantidad y tipo de columnas | Misma cantidad y tipo de columnas | Una condición `ON` |
| Las tablas tienen que estar relacionadas | No | No | Sí |

> 📌 **Nota:** desde la versión 8.0.31, MySQL también tiene `INTERSECT` (las filas que están en las dos consultas) y `EXCEPT` (las que están en la primera y no en la segunda). En versiones anteriores se resuelven con `IN` y `NOT IN`.

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1222`: *The used SELECT statements have a different number of columns* | Las consultas no tienen la misma cantidad de columnas | Igualarlas; si falta un dato, completar con `NULL` o un texto fijo |
| `Error 1221`: *Incorrect usage of UNION and ORDER BY* | Un `ORDER BY` en una consulta del medio | Dejar un solo `ORDER BY`, al final |
| `Error 1054` en el `ORDER BY` | Se ordenó por un nombre de columna de la segunda consulta | Usar los nombres (o alias) de la **primera** |
| Faltan filas que deberían repetirse | `UNION` eliminó los duplicados | Usar `UNION ALL` |
| Datos mezclados: apellidos en la columna de nombres | Las columnas están en distinto orden en cada consulta | `UNION` une **por posición**, no por nombre: respetar el orden |
| Números ordenados como texto | En una posición se mezcló un número con un texto y todo pasó a texto | Mantener el mismo tipo en cada posición |

---

Continuamos por cómo guardar una consulta para usarla como si fuera una tabla → [Vistas](Vistas)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Armá una lista única con los apellidos de todos los docentes y de los estudiantes del grupo 3, en orden alfabético.

<details>
<summary>Ver solución</summary>

```sql
SELECT apellido
FROM docente
UNION
SELECT apellido
FROM estudiante
WHERE id_grupo = 3
ORDER BY apellido;
```

| apellido |
| -------- |
| Castro |
| Giménez |
| López |
| Martínez |
| Méndez |
| Olivera |
| Pereira |
| Sosa |

💡 El `ORDER BY` va una sola vez, al final, y ordena todo.
</details>

**2.** Mostrá en una sola lista los nombres de las asignaturas y de los grupos, indicando en una segunda columna qué es cada cosa.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, 'asignatura' AS tipo
FROM asignatura
UNION ALL
SELECT nombre, 'grupo'
FROM grupo
ORDER BY tipo, nombre;
```

| nombre | tipo |
| ------ | ---- |
| Filosofía | asignatura |
| Física | asignatura |
| Historia | asignatura |
| Matemática | asignatura |
| Programación | asignatura |
| Química | asignatura |
| 2ºA | grupo |
| 2ºB | grupo |
| 3ºA | grupo |
| 3ºB | grupo |

💡 No puede haber repetidos entre las dos mitades (la columna `tipo` los diferencia), así que alcanza con `UNION ALL`.
</details>

**3.** Mostrá los `id_estudiante` que tienen alguna nota de 10 o más, junto con los que tienen alguna inscripción sin nota. Cada uno una sola vez.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_estudiante
FROM inscripcion
WHERE nota >= 10
UNION
SELECT id_estudiante
FROM inscripcion
WHERE nota IS NULL
ORDER BY id_estudiante;
```

| id_estudiante |
| ------------- |
| 1 |
| 3 |
| 4 |
| 5 |
| 6 |
| 7 |
| 9 |

💡 Sobre una misma tabla, esto equivale a `SELECT DISTINCT … WHERE nota >= 10 OR nota IS NULL`. `UNION` se vuelve necesario cuando las mitades vienen de tablas diferentes.
</details>

**4.** Armá un informe de tres filas con la cantidad de estudiantes, de docentes y de asignaturas del liceo.

<details>
<summary>Ver solución</summary>

```sql
SELECT 'Estudiantes' AS dato, COUNT(*) AS cantidad
FROM estudiante
UNION ALL
SELECT 'Docentes', COUNT(*)
FROM docente
UNION ALL
SELECT 'Asignaturas', COUNT(*)
FROM asignatura;
```

| dato | cantidad |
| ---- | -------- |
| Estudiantes | 10 |
| Docentes | 5 |
| Asignaturas | 6 |

💡 Tres consultas de una fila cada una, apiladas.
</details>

**5.** Mostrá la cantidad de estudiantes por grupo (solo los grupos con estudiantes) y agregá una última fila con el total.

<details>
<summary>Ver solución</summary>

```sql
SELECT 1        AS orden,
       g.nombre AS grupo,
       COUNT(*) AS estudiantes
FROM grupo AS g
INNER JOIN estudiante AS e ON e.id_grupo = g.id_grupo
GROUP BY g.id_grupo, g.nombre
UNION ALL
SELECT 2, 'TOTAL', COUNT(*)
FROM estudiante
ORDER BY orden, grupo;
```

| orden | grupo | estudiantes |
| ----- | ----- | ----------- |
| 1 | 2ºA | 3 |
| 1 | 3ºA | 3 |
| 1 | 3ºB | 4 |
| 2 | TOTAL | 10 |

💡 La fila de total es otra consulta, con un texto fijo en lugar del nombre. La columna `orden` la deja al final.
</details>

---

## 📋 Palabras clave

`UNION` · `UNION ALL` · `duplicados` · `combinar resultados` · `misma cantidad de columnas` · `tipos compatibles` · `unión por posición` · `columna constante` · `fila de total` · `FULL OUTER JOIN` · `INTERSECT` · `EXCEPT` · `Error 1222`

---

🧠 **[Autoevaluación — Módulo 8](auto-modulo8)**

---

← [Subconsultas](Subconsultas) · [🏠 Inicio](Home) · [Vistas →](Vistas)
