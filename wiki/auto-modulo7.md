# 🧠 Autoevaluación — Módulo 7

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

¿Qué devuelve esta consulta sobre la base `liceo`?

```sql
SELECT DISTINCT turno
FROM grupo;
```

- A) Cuatro filas, una por cada grupo
- B) Una sola fila con la cantidad de turnos
- C) Tres filas: `matutino`, `vespertino` y `nocturno`
- D) Los nombres de los grupos sin repetir

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Tres filas: `matutino`, `vespertino` y `nocturno`**

💡 Hay cuatro grupos, pero dos son matutinos. `DISTINCT` quita los valores repetidos del resultado; no cuenta nada.

</details>

---

### Pregunta 2

¿Por qué falla esta consulta?

```sql
SELECT nombre, YEAR(fecha_nacimiento) AS anio
FROM estudiante
WHERE anio = 2010;
```

- A) Porque el `WHERE` se evalúa antes que el `SELECT`, y el alias `anio` todavía no existe
- B) Porque `YEAR` no es una función de MySQL
- C) Porque falta `ORDER BY`
- D) Porque `2010` debería ir entre comillas

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Porque el `WHERE` se evalúa antes que el `SELECT`, y el alias `anio` todavía no existe**

💡 MySQL ejecuta `FROM`, después `WHERE` y recién después `SELECT`. En el `WHERE` hay que repetir la expresión; en el `ORDER BY`, en cambio, el alias sí se puede usar.

</details>

---

### Pregunta 3

Se quieren las inscripciones de las asignaturas 10 u 11 con nota de 9 o más. ¿Cuál es la condición correcta?

- A) `WHERE id_asignatura = 10 OR id_asignatura = 11 AND nota >= 9`
- B) `WHERE id_asignatura = 10 AND id_asignatura = 11 AND nota >= 9`
- C) `WHERE id_asignatura = 10 OR 11 AND nota >= 9`
- D) `WHERE (id_asignatura = 10 OR id_asignatura = 11) AND nota >= 9`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) `WHERE (id_asignatura = 10 OR id_asignatura = 11) AND nota >= 9`**

💡 `AND` se evalúa antes que `OR`: sin paréntesis, la primera opción trae todas las inscripciones de la asignatura 10, con cualquier nota. La segunda no devuelve nada: ninguna fila es de dos asignaturas a la vez.

</details>

---

### Pregunta 4

¿Qué apellidos encuentra `WHERE apellido LIKE '%ez'`?

- A) Los que contienen "ez" en cualquier lugar
- B) Los que terminan en "ez"
- C) Los que empiezan con "ez"
- D) Solo el apellido exacto "%ez"

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Los que terminan en "ez"**

💡 El `%` reemplaza cualquier cantidad de caracteres y está solo al principio: puede haber cualquier cosa antes, pero el texto debe terminar en "ez". Para "en cualquier lugar" sería `'%ez%'`.

</details>

---

### Pregunta 5

¿Cuál de estas condiciones encuentra las inscripciones que todavía no tienen nota?

- A) `WHERE nota = NULL`
- B) `WHERE nota = 0`
- C) `WHERE nota IS NULL`
- D) `WHERE nota = ''`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) `WHERE nota IS NULL`**

💡 `NULL` es "valor desconocido", y ninguna comparación con `=` da verdadero contra un valor desconocido. Por eso existe `IS NULL`. Un 0 o un texto vacío son valores, no ausencia de valor.

</details>

---

### Pregunta 6

En la base `liceo` hay 21 inscripciones, 3 de ellas sin nota. ¿Cuántas filas devuelven **en total** estas dos consultas?

```sql
SELECT * FROM inscripcion WHERE nota < 6;
SELECT * FROM inscripcion WHERE nota >= 6;
```

- A) 18
- B) 21
- C) 24
- D) Depende del orden en que se ejecuten

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) 18**

💡 Las inscripciones con `NULL` no cumplen ninguna de las dos condiciones, así que no aparecen en ninguna. Es la forma más silenciosa en que se "pierden" filas.

</details>

---

### Pregunta 7

¿Qué hace `BETWEEN 6 AND 9` aplicado a la columna `nota`?

- A) Incluye las notas mayores que 6 y menores que 9, sin los extremos
- B) Incluye solo las notas 6 y 9
- C) Incluye el 6 pero no el 9
- D) Incluye las notas desde 6 hasta 9, con los dos extremos

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Incluye las notas desde 6 hasta 9, con los dos extremos**

💡 `BETWEEN` es inclusivo: equivale a `nota >= 6 AND nota <= 9`.

</details>

---

### Pregunta 8

Se quiere ver la mejor nota del liceo. ¿Qué consulta lo logra?

- A) `SELECT nota FROM inscripcion LIMIT 1;`
- B) `SELECT nota FROM inscripcion ORDER BY nota DESC LIMIT 1;`
- C) `SELECT nota FROM inscripcion ORDER BY nota LIMIT 1;`
- D) `SELECT nota FROM inscripcion WHERE nota = 'máxima';`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) `SELECT nota FROM inscripcion ORDER BY nota DESC LIMIT 1;`**

💡 `LIMIT` solo recorta; quién queda primero lo decide el `ORDER BY`. Sin orden devuelve una fila cualquiera, y en orden ascendente devolvería un `NULL`, porque en MySQL los `NULL` van primero.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 7](Resumen-Modulo7)
