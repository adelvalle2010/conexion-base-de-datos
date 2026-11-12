# 🧠 Autoevaluación — Módulo 9

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

¿Qué es un índice?

- A) Una copia de seguridad de la tabla
- B) Una restricción que impide valores nulos
- C) Una estructura ordenada, aparte de la tabla, que permite encontrar filas sin recorrerla entera
- D) Una vista que muestra las columnas más consultadas

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Una estructura ordenada, aparte de la tabla, que permite encontrar filas sin recorrerla entera**

💡 Funciona como el índice alfabético de un libro: guarda los valores ordenados y, junto a cada uno, dónde está la fila.

</details>

---

### Pregunta 2

La tabla `estudiante` tiene un índice sobre `(apellido, nombre)`. ¿Cuál de estas consultas **no** puede aprovecharlo?

- A) `SELECT * FROM estudiante WHERE apellido = 'López';`
- B) `SELECT * FROM estudiante WHERE nombre = 'Sofía';`
- C) `SELECT * FROM estudiante WHERE apellido = 'López' AND nombre = 'Sofía';`
- D) `SELECT * FROM estudiante WHERE apellido LIKE 'Ló%';`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) `SELECT * FROM estudiante WHERE nombre = 'Sofía';`**

💡 Regla del prefijo izquierdo: el índice está ordenado primero por apellido. Las Sofía están repartidas entre todos los apellidos, como en una guía telefónica.

</details>

---

### Pregunta 3

Hay un índice sobre `fecha_nacimiento`. ¿Por qué esta consulta recorre toda la tabla?

```sql
SELECT *
FROM estudiante
WHERE YEAR(fecha_nacimiento) = 2011
  AND MONTH(fecha_nacimiento) = 12;
```

- A) Porque los índices no funcionan con fechas
- B) Porque falta un `ORDER BY`
- C) Porque el índice debería ser único
- D) Porque la columna está dentro de una función, y el índice guarda fechas, no años ni meses

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Porque la columna está dentro de una función, y el índice guarda fechas, no años ni meses**

💡 Se resuelve comparando la columna directamente: `WHERE fecha_nacimiento BETWEEN '2011-12-01' AND '2011-12-31'`.

</details>

---

### Pregunta 4

Un `EXPLAIN` sobre una tabla de 100.000 filas devuelve esto. ¿Qué indica?

| table | type | key | rows | Extra |
| ----- | ---- | --- | ---- | ----- |
| estudiante | ALL | NULL | 100165 | Using where |

- A) Que recorre toda la tabla, sin usar ningún índice
- B) Que usa todos los índices de la tabla
- C) Que la consulta devuelve 100.165 filas
- D) Que la consulta tiene un error de sintaxis

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Que recorre toda la tabla, sin usar ningún índice**

💡 `type = ALL` y `key = NULL` son la señal de un recorrido completo. `rows` es la cantidad de filas que estima **leer**, no las que devuelve.

</details>

---

### Pregunta 5

¿Cuál es la diferencia entre `EXPLAIN` y `EXPLAIN ANALYZE`?

- A) `EXPLAIN ANALYZE` solo funciona con `UPDATE` y `DELETE`
- B) `EXPLAIN ANALYZE` ejecuta la consulta y muestra filas y tiempos reales; `EXPLAIN` solo muestra el plan estimado
- C) `EXPLAIN` ejecuta la consulta y `EXPLAIN ANALYZE` no
- D) Ninguna: son dos formas de escribir lo mismo

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) `EXPLAIN ANALYZE` ejecuta la consulta y muestra filas y tiempos reales; `EXPLAIN` solo muestra el plan estimado**

💡 Por eso `EXPLAIN` es instantáneo y `EXPLAIN ANALYZE` tarda lo mismo que la consulta. Sobre un `UPDATE` o `DELETE`, además, modifica los datos.

</details>

---

### Pregunta 6

¿Qué queda en la tabla `docente` después de ejecutar esto?

```sql
START TRANSACTION;
INSERT INTO docente (id_docente, nombre, apellido) VALUES (6, 'Pablo', 'Rivas');
SAVEPOINT uno;
INSERT INTO docente (id_docente, nombre, apellido) VALUES (7, 'Rosa', 'Lema');
ROLLBACK TO uno;
COMMIT;
```

- A) Ninguno de los dos docentes nuevos
- B) Los dos docentes nuevos
- C) Solo Rosa Lema
- D) Solo Pablo Rivas

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Solo Pablo Rivas**

💡 `ROLLBACK TO uno` deshace lo que vino después del marcador y deja la transacción abierta. El `COMMIT` confirma lo que quedó: el primer `INSERT`.

</details>

---

### Pregunta 7

Dentro de una transacción, un `DELETE` se ejecuta bien y el `INSERT` siguiente da error de clave foránea. ¿Qué hace MySQL?

- A) Anula solo el `INSERT`; la transacción sigue abierta con el `DELETE` pendiente
- B) Deshace toda la transacción automáticamente
- C) Confirma el `DELETE` automáticamente
- D) Cierra la conexión

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Anula solo el `INSERT`; la transacción sigue abierta con el `DELETE` pendiente**

💡 La decisión es nuestra. Lo correcto es `ROLLBACK`; un `COMMIT` dejaría confirmada la mitad de la operación.

</details>

---

### Pregunta 8

La Sesión A abre una transacción y modifica la nota de un estudiante, sin confirmar. La Sesión B, con el nivel de aislamiento por defecto de MySQL, intenta primero **leer** esa nota y después **modificarla**. ¿Qué ocurre?

- A) B lee el valor nuevo y lo modifica sin esperar
- B) B recibe un error al intentar leer
- C) B lee el valor anterior sin esperar; al modificar, queda esperando a que A termine
- D) B queda esperando tanto para leer como para modificar

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) B lee el valor anterior sin esperar; al modificar, queda esperando a que A termine**

💡 Las lecturas comunes no se bloquean: ven la última versión confirmada. Las escrituras sobre una fila bloqueada esperan, hasta 50 segundos; después dan `Error 1205`.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 9](Resumen-Modulo9)
