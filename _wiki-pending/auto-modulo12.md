# 🧠 Autoevaluación — Módulo 12

Responde cada pregunta antes de ver la respuesta. Son sobre el Proyecto Integrador y repasan todo el curso.

---

### Pregunta 1
En la biblioteca, ¿por qué se separan **LIBRO** y **EJEMPLAR** en dos entidades distintas?

- A) Porque un libro siempre tiene un solo ejemplar
- B) Porque un libro (el título) puede tener varias copias físicas, y el préstamo es de una copia concreta
- C) Porque así se ahorra espacio en disco
- D) Porque MySQL no permite más de un dato por tabla

<details>
<summary>Ver respuesta</summary>

✅ **B) Porque un libro (el título) puede tener varias copias físicas, y el préstamo es de una copia concreta**

💡 *La tregua* es un libro; de él puede haber dos ejemplares. El estudiante pide prestado **un ejemplar**, no el título en abstracto. Es una relación 1:N entre libro y ejemplar.
</details>

---

### Pregunta 2
La relación entre `libro` y `autor` es N:M. ¿Cómo se representa en el modelo relacional?

- A) Con una columna `autor` de texto dentro de `libro`
- B) Con una clave foránea de `autor` dentro de `libro`
- C) Con una tabla intermedia `libro_autor` que tiene las dos claves
- D) No se puede representar

<details>
<summary>Ver respuesta</summary>

✅ **C) Con una tabla intermedia `libro_autor` que tiene las dos claves**

💡 Toda relación N:M se resuelve con una tabla intermedia. `libro_autor(id_libro, id_autor)` tiene clave primaria compuesta, así un autor no se repite dos veces en el mismo libro.
</details>

---

### Pregunta 3
Al crear las tablas, ¿cuál se debe crear **antes**?

- A) `libro`, porque es la más importante
- B) `categoria`, porque `libro` tiene una FK que apunta a ella
- C) `prestamo`, porque junta todo
- D) El orden no importa

<details>
<summary>Ver respuesta</summary>

✅ **B) `categoria`, porque `libro` tiene una FK que apunta a ella**

💡 Una clave foránea no puede apuntar a una tabla que todavía no existe. Primero las tablas "padre" (sin FK), después las "hijas".
</details>

---

### Pregunta 4
¿Qué hace el trigger `trg_prestamo_after_insert`?

- A) Borra el préstamo después de insertarlo
- B) Marca el ejemplar como `prestado` cada vez que se inserta un préstamo
- C) Impide insertar préstamos
- D) Crea una copia de seguridad

<details>
<summary>Ver respuesta</summary>

✅ **B) Marca el ejemplar como `prestado` cada vez que se inserta un préstamo**

💡 El trigger se dispara `AFTER INSERT ON prestamo` y hace el `UPDATE` del estado del ejemplar automáticamente, para que nadie se olvide de hacerlo.
</details>

---

### Pregunta 5
El procedimiento `sp_prestar` rechaza prestar un ejemplar que no está disponible usando:

- A) Un `SELECT`
- B) Un `COMMIT`
- C) Un `SIGNAL SQLSTATE '45000'` que lanza un error
- D) Un `DROP TABLE`

<details>
<summary>Ver respuesta</summary>

✅ **C) Un `SIGNAL SQLSTATE '45000'` que lanza un error**

💡 `SIGNAL` lanza un error controlado con un mensaje propio ("El ejemplar no está disponible"). Así el procedimiento corta la operación antes de insertar el préstamo.
</details>

---

### Pregunta 6
Para saber qué libros **no tienen ningún ejemplar disponible**, la herramienta más natural es:

- A) Un `INNER JOIN` simple
- B) Una subconsulta con `NOT IN`
- C) Un `ORDER BY`
- D) Un `GROUP BY` sin más

<details>
<summary>Ver respuesta</summary>

✅ **B) Una subconsulta con `NOT IN`**

💡 Se listan los libros cuyo `id_libro` **no aparece** entre los que tienen algún ejemplar disponible: `WHERE id_libro NOT IN (SELECT ... WHERE estado = 'disponible')`.
</details>

---

### Pregunta 7
La vista `v_ejemplares_disponibles` sirve para:

- A) Guardar los datos en otro disco
- B) Reusar una consulta con `JOIN` sin tener que reescribirla cada vez
- C) Acelerar los `INSERT`
- D) Borrar ejemplares prestados

<details>
<summary>Ver respuesta</summary>

✅ **B) Reusar una consulta con `JOIN` sin tener que reescribirla cada vez**

💡 Una vista es una consulta guardada con nombre. La bibliotecaria consulta `v_ejemplares_disponibles` como si fuera una tabla, sin escribir los `JOIN` cada vez.
</details>

---

### Pregunta 8
¿En qué forma normal está el diseño de la biblioteca?

- A) En ninguna, está sin normalizar
- B) Solo en 1FN
- C) En 3FN: campos atómicos, sin dependencias parciales ni transitivas
- D) En 5FN

<details>
<summary>Ver respuesta</summary>

✅ **C) En 3FN: campos atómicos, sin dependencias parciales ni transitivas**

💡 Los autores están en su tabla (1FN), cada tabla tiene PK y sus atributos dependen de ella entera (2FN), y no hay datos derivados ni categorías repetidas como texto (3FN).
</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a la Introducción](Introduccion-Proyecto-Integrador) · [🏠 Inicio](Home)
