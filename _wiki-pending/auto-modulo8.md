# 🧠 Autoevaluación — Módulo 8

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

En la base `liceo` hay 21 inscripciones y 3 de ellas no tienen nota. ¿Qué devuelve esta consulta?

```sql
SELECT COUNT(*) AS a, COUNT(nota) AS b
FROM inscripcion;
```

- A) `a = 21`, `b = 21`
- B) `a = 21`, `b = 18`
- C) `a = 18`, `b = 18`
- D) `a = 18`, `b = 21`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) `a = 21`, `b = 18`**

💡 `COUNT(*)` cuenta filas; `COUNT(nota)` cuenta solo las filas donde `nota` tiene un valor. La diferencia son los `NULL`.

</details>

---

### Pregunta 2

Se quieren las asignaturas con promedio de 8 o más. ¿Cuál es la consulta correcta?

- A) `SELECT id_asignatura FROM inscripcion WHERE AVG(nota) >= 8 GROUP BY id_asignatura;`
- B) `SELECT id_asignatura FROM inscripcion GROUP BY id_asignatura WHERE AVG(nota) >= 8;`
- C) `SELECT id_asignatura FROM inscripcion HAVING AVG(nota) >= 8 GROUP BY id_asignatura;`
- D) `SELECT id_asignatura FROM inscripcion GROUP BY id_asignatura HAVING AVG(nota) >= 8;`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) `SELECT id_asignatura FROM inscripcion GROUP BY id_asignatura HAVING AVG(nota) >= 8;`**

💡 La condición es sobre un promedio, que recién existe después de agrupar: va en el `HAVING`, y el `HAVING` se escribe después del `GROUP BY`. La opción A da `Error 1111`: el `WHERE` no admite funciones de agrupación.

</details>

---

### Pregunta 3

¿Por qué falla esta consulta?

```sql
SELECT id_asignatura, id_estudiante, AVG(nota)
FROM inscripcion
GROUP BY id_asignatura;
```

- A) Porque `id_estudiante` no está en el `GROUP BY` ni dentro de una función de agrupación
- B) Porque `AVG` necesita un alias
- C) Porque falta el `HAVING`
- D) Porque no se puede agrupar por una clave foránea

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Porque `id_estudiante` no está en el `GROUP BY` ni dentro de una función de agrupación**

💡 Cada asignatura se convierte en una sola fila, pero tiene varios estudiantes: MySQL no sabe cuál mostrar y devuelve `Error 1055`.

</details>

---

### Pregunta 4

La base tiene 5 docentes; una de ellas, Marta Giménez, no dicta ninguna asignatura. Hay 6 asignaturas, todas con docente. ¿Cuántas filas devuelve cada consulta?

```sql
-- Consulta 1
SELECT d.apellido, a.nombre
FROM docente AS d
INNER JOIN asignatura AS a ON a.id_docente = d.id_docente;

-- Consulta 2
SELECT d.apellido, a.nombre
FROM docente AS d
LEFT JOIN asignatura AS a ON a.id_docente = d.id_docente;
```

- A) 5 y 6
- B) 6 y 6
- C) 6 y 7
- D) 5 y 5

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) 6 y 7**

💡 El `INNER JOIN` devuelve una fila por cada coincidencia: las 6 asignaturas con su docente. El `LEFT JOIN` agrega a Giménez, con `NULL` en la columna de la asignatura.

</details>

---

### Pregunta 5

¿Cuál de estas consultas muestra los estudiantes que **no** tienen ninguna inscripción?

- A) `SELECT e.nombre FROM estudiante AS e INNER JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante WHERE i.id_estudiante IS NULL;`
- B) `SELECT e.nombre FROM estudiante AS e LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante WHERE i.id_estudiante IS NULL;`
- C) `SELECT e.nombre FROM estudiante AS e LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante WHERE i.nota IS NULL;`
- D) `SELECT e.nombre FROM estudiante AS e LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante WHERE i.id_estudiante = NULL;`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) `SELECT e.nombre FROM estudiante AS e LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante WHERE i.id_estudiante IS NULL;`**

💡 El `LEFT JOIN` conserva a todos los estudiantes y el `IS NULL` sobre la clave de `inscripcion` deja solo a los que no encontraron pareja. Con `INNER JOIN` esas filas nunca llegan al `WHERE`, y preguntar por `i.nota` trae también a quienes están inscriptos pero todavía no tienen nota.

</details>

---

### Pregunta 6

¿Qué error tiene esta consulta?

```sql
SELECT nombre, apellido
FROM estudiante
WHERE id_estudiante = (SELECT id_estudiante
                       FROM inscripcion
                       WHERE id_asignatura = 14);
```

- A) Una subconsulta no puede usar `WHERE`
- B) Falta un alias después del paréntesis
- C) No se puede usar la misma columna adentro y afuera
- D) La subconsulta devuelve varias filas y `=` solo acepta un valor

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) La subconsulta devuelve varias filas y `=` solo acepta un valor**

💡 Programación tiene cuatro inscriptos, así que la subconsulta devuelve cuatro filas y MySQL responde `Error 1242`. Para comparar contra una lista se usa `IN`. El alias es obligatorio solo cuando la subconsulta va en el `FROM`.

</details>

---

### Pregunta 7

¿Cuál es la diferencia entre `UNION` y `UNION ALL`?

- A) `UNION` elimina las filas repetidas; `UNION ALL` las conserva
- B) `UNION` junta columnas y `UNION ALL` junta filas
- C) `UNION ALL` permite que las consultas tengan distinta cantidad de columnas
- D) `UNION ALL` ordena el resultado y `UNION` no

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) `UNION` elimina las filas repetidas; `UNION ALL` las conserva**

💡 Los dos apilan filas y los dos exigen la misma cantidad de columnas. `UNION ALL` es más rápido porque no tiene que buscar duplicados. Ninguno ordena: para eso va un `ORDER BY` al final.

</details>

---

### Pregunta 8

Se crea la vista `v_notas` y al día siguiente se carga una nota nueva en la tabla `inscripcion`. ¿Qué muestra `SELECT * FROM v_notas`?

- A) Los datos del día en que se creó la vista
- B) Un error, porque la vista quedó desactualizada
- C) Los datos actuales, incluida la nota nueva
- D) Los datos actuales, pero solo después de ejecutar `CREATE OR REPLACE VIEW`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Los datos actuales, incluida la nota nueva**

💡 Una vista no guarda datos: guarda la consulta, y esa consulta se ejecuta sobre las tablas reales cada vez que se usa la vista.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 8](Resumen-Modulo8)
