# 🧠 Autoevaluación — Módulo 6

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

¿Qué valor recibe `turno` al ejecutar esta sentencia, si la columna se definió como `NOT NULL DEFAULT 'matutino'`?

```sql
INSERT INTO grupo (nombre)
VALUES ('1ºA');
```

- A) `NULL`
- B) Un texto vacío
- C) `'matutino'`
- D) Ninguno: da el error 1364

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) `'matutino'`**

💡 Una columna que no aparece en la lista recibe su `DEFAULT`. El error 1364 aparece cuando la columna es `NOT NULL` y no tiene valor por defecto.

</details>

---

### Pregunta 2

La tabla `docente` tiene las columnas `id_docente`, `nombre` y `apellido`. ¿Qué pasa con `INSERT INTO docente VALUES ('Pablo', 'Ruiz');`?

- A) Da el error 1136, porque sin lista de columnas hay que dar las tres
- B) Se inserta y `id_docente` se completa solo
- C) Se inserta con `id_docente = 'Pablo'`
- D) Da el error 1062 por valor duplicado

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Da el error 1136, porque sin lista de columnas hay que dar las tres**

💡 Sin lista de columnas, MySQL espera un valor para cada columna, en el orden de la tabla. Por eso conviene escribir siempre la lista: `(nombre, apellido)`.

</details>

---

### Pregunta 3

¿En qué orden hay que cargar las tablas del liceo?

- A) `inscripcion`, `estudiante`, `asignatura`, `docente`, `grupo`
- B) `estudiante`, `grupo`, `inscripcion`, `docente`, `asignatura`
- C) Da lo mismo: MySQL las ordena solo
- D) `grupo` y `docente`; después `estudiante` y `asignatura`; al final `inscripcion`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) `grupo` y `docente`; después `estudiante` y `asignatura`; al final `inscripcion`**

💡 Primero las tablas padre y después las que tienen claves foráneas hacia ellas. Si no, cada `INSERT` falla con el error 1452.

</details>

---

### Pregunta 4

¿Qué hace `UPDATE docente SET apellido = 'Giménez';`?

- A) Cambia el apellido del primer docente
- B) Les pone el apellido 'Giménez' a todos los docentes
- C) Da error porque falta el `WHERE`
- D) Cambia solo los apellidos que decían 'Gimenez'

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Les pone el apellido 'Giménez' a todos los docentes**

💡 El `WHERE` es opcional para SQL: sin él, la sentencia se aplica a todas las filas. En Workbench el modo seguro lo frenaría con el error 1175, pero en la consola o desde una aplicación se ejecuta.

</details>

---

### Pregunta 5

La clave primaria de `inscripcion` es (`id_estudiante`, `id_asignatura`). ¿Cuál es la sentencia correcta para cambiar la nota de la estudiante 5 en la asignatura 10?

- A) `UPDATE inscripcion SET nota = 12 WHERE id_estudiante = 5;`
- B) `UPDATE inscripcion SET nota = 12 WHERE id_asignatura = 10;`
- C) `UPDATE inscripcion SET nota = 12 WHERE id_estudiante = 5 AND id_asignatura = 10;`
- D) `UPDATE inscripcion SET nota = 12, id_estudiante = 5, id_asignatura = 10;`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) `UPDATE inscripcion SET nota = 12 WHERE id_estudiante = 5 AND id_asignatura = 10;`**

💡 Con clave compuesta hacen falta las dos columnas para apuntar a una sola fila. La primera opción cambiaría todas las notas de la estudiante; la segunda, las de toda la clase.

</details>

---

### Pregunta 6

En Workbench aparece `Error 1175: You are using safe update mode…`. ¿Qué significa?

- A) Que el servidor está apagado
- B) Que la tabla está bloqueada por otro usuario
- C) Que la sentencia tiene un error de sintaxis
- D) Que el `WHERE` del `UPDATE` o `DELETE` no usa una columna clave

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Que el `WHERE` del `UPDATE` o `DELETE` no usa una columna clave**

💡 Es una protección de Workbench contra modificaciones masivas por accidente. Se resuelve filtrando por la clave primaria o, si es intencional, con `SET SQL_SAFE_UPDATES = 0;`.

</details>

---

### Pregunta 7

Se ejecuta `DELETE FROM docente WHERE id_docente = 1;` y la docente 1 dicta una asignatura. La FK de `asignatura` no tiene `ON DELETE`. ¿Qué pasa?

- A) MySQL rechaza el borrado con el error 1451
- B) Se borra la docente y también su asignatura
- C) Se borra la docente y la asignatura queda con `id_docente` en `NULL`
- D) Se borra la docente y la asignatura queda apuntando a un docente inexistente

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) MySQL rechaza el borrado con el error 1451**

💡 Sin `ON DELETE`, se aplica `RESTRICT`. Borrar también la asignatura sería `CASCADE`, y dejarla en `NULL` sería `SET NULL`. La última opción es justo lo que la integridad referencial impide.

</details>

---

### Pregunta 8

Agustín sigue cursando Matemática, pero se quiere indicar que todavía no tiene nota. ¿Qué sentencia corresponde?

- A) `DELETE FROM inscripcion WHERE id_estudiante = 10 AND id_asignatura = 10;`
- B) `UPDATE inscripcion SET nota = NULL WHERE id_estudiante = 10 AND id_asignatura = 10;`
- C) `DELETE nota FROM inscripcion WHERE id_estudiante = 10;`
- D) `UPDATE inscripcion SET nota = 0 WHERE id_estudiante = 10 AND id_asignatura = 10;`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) `UPDATE inscripcion SET nota = NULL WHERE id_estudiante = 10 AND id_asignatura = 10;`**

💡 `DELETE` elimina la fila entera: Agustín dejaría de estar inscripto. Para vaciar un valor se usa `UPDATE … SET columna = NULL`. Un 0 no sirve: no es "sin nota" y además viola el `CHECK`.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 6](Resumen-Modulo6)
