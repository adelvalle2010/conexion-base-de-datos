# 🧠 Autoevaluación — Módulo 5

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

¿Qué hace `CREATE TABLE docente ( ... );`?

- A) Crea la tabla y carga los docentes del liceo
- B) Crea la estructura de la tabla, sin ninguna fila
- C) Crea la base de datos `docente`
- D) Muestra las columnas de la tabla `docente`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Crea la estructura de la tabla, sin ninguna fila**

💡 `CREATE TABLE` define columnas, tipos y restricciones: es DDL. Las filas se cargan después con `INSERT`, que es DML.

</details>

---

### Pregunta 2

¿Cuál es la clave primaria de esta tabla?

```sql
CREATE TABLE inscripcion (
    id_estudiante INT NOT NULL,
    id_asignatura INT NOT NULL,
    nota          DECIMAL(4,2),
    CONSTRAINT pk_inscripcion PRIMARY KEY (id_estudiante, id_asignatura)
);
```

- A) `id_estudiante`
- B) Tiene dos claves primarias: `id_estudiante` e `id_asignatura`
- C) `nota`
- D) Una sola clave primaria, formada por la pareja (`id_estudiante`, `id_asignatura`)

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Una sola clave primaria, formada por la pareja (`id_estudiante`, `id_asignatura`)**

💡 Una tabla tiene una única clave primaria, que puede abarcar varias columnas. Cada columna por separado se puede repetir; la combinación, no.

</details>

---

### Pregunta 3

Al ejecutar un `CREATE TABLE asignatura` con una FK hacia `docente`, MySQL responde `Error 1824: Failed to open the referenced table 'docente'`. ¿Cuál es la causa?

- A) La tabla `docente` todavía no existe
- B) La tabla `docente` está vacía
- C) La columna `id_docente` no es `AUTO_INCREMENT`
- D) Falta el `ON DELETE CASCADE`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) La tabla `docente` todavía no existe**

💡 La tabla referenciada tiene que existir antes. Que esté vacía no es problema para **crear** la FK; sí lo sería para insertar una asignatura.

</details>

---

### Pregunta 4

La FK de `inscripcion` hacia `estudiante` se definió con `ON DELETE CASCADE`. ¿Qué pasa al borrar un estudiante que tiene tres inscripciones?

- A) MySQL rechaza el borrado con el error 1451
- B) Se borra el estudiante y las inscripciones quedan con `id_estudiante` en `NULL`
- C) Se borran el estudiante y sus tres inscripciones
- D) Se borra el estudiante y las inscripciones quedan apuntando a un estudiante inexistente

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Se borran el estudiante y sus tres inscripciones**

💡 `CASCADE` propaga el borrado a las filas hijas. Rechazar es lo que hace `RESTRICT`, el comportamiento por defecto, y dejar `NULL` es `SET NULL`.

</details>

---

### Pregunta 5

¿Cuál es una diferencia entre `PRIMARY KEY` y `UNIQUE`?

- A) `UNIQUE` admite valores repetidos y `PRIMARY KEY` no
- B) Una tabla puede tener varias restricciones `UNIQUE`, pero una sola `PRIMARY KEY`
- C) `PRIMARY KEY` admite `NULL` y `UNIQUE` no
- D) No hay diferencia: son sinónimos

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Una tabla puede tener varias restricciones `UNIQUE`, pero una sola `PRIMARY KEY`**

💡 Las dos impiden repetidos. La PK además no admite `NULL` y es única por tabla; `UNIQUE` sirve para las claves alternativas, como el nombre del grupo.

</details>

---

### Pregunta 6

La tabla `grupo` define `turno VARCHAR(10) NOT NULL DEFAULT 'matutino'`. ¿Qué pasa al ejecutar `INSERT INTO grupo (nombre) VALUES ('4ºA');`?

- A) Da error 1364, porque `turno` es `NOT NULL`
- B) Se guarda la fila con `turno` en `NULL`
- C) Da error 3819, porque no se cumple el `CHECK`
- D) Se guarda la fila con `turno = 'matutino'`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Se guarda la fila con `turno = 'matutino'`**

💡 Cuando la columna no se menciona, MySQL usa el `DEFAULT`. El error 1364 aparecería si fuera `NOT NULL` y **no** tuviera valor por defecto.

</details>

---

### Pregunta 7

Después de cargar tres filas en una tabla con `AUTO_INCREMENT`, se ejecuta `TRUNCATE TABLE` y se inserta una fila nueva. ¿Qué identificador recibe?

- A) 1, porque `TRUNCATE` reinicia el contador
- B) 4, porque el contador sigue donde estaba
- C) 0, porque la tabla quedó vacía
- D) Da error: la tabla ya no existe

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) 1, porque `TRUNCATE` reinicia el contador**

💡 `TRUNCATE` vacía la tabla y reinicia `AUTO_INCREMENT`. Con `DELETE` el contador no se reinicia y la fila nueva sería la 4. La tabla sigue existiendo: eliminarla es `DROP`.

</details>

---

### Pregunta 8

Se quiere eliminar la columna `grupo` de la tabla `estudiante` sin borrar la tabla. ¿Qué sentencia corresponde?

- A) `DROP TABLE estudiante;`
- B) `DELETE FROM estudiante WHERE grupo IS NOT NULL;`
- C) `ALTER TABLE estudiante DROP COLUMN grupo;`
- D) `TRUNCATE TABLE estudiante;`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) `ALTER TABLE estudiante DROP COLUMN grupo;`**

💡 Cambiar la estructura de una tabla existente es trabajo de `ALTER TABLE`. `DELETE` y `TRUNCATE` quitan filas, no columnas, y `DROP TABLE` elimina la tabla completa.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 5](Resumen-Modulo5)
