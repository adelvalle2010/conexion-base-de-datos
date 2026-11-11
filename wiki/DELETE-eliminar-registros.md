> 🗄️ **Base de datos:** `liceo` (Módulo 6 — Manipulación de Datos) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo6/liceo_dml.sql)

# 🗑️ DELETE: Eliminar registros

## ¿Por qué lo necesitamos?

Quedan tres cosas por limpiar en el liceo:

- Agustín se dio de baja de Matemática.
- El estudiante "Prueba Prueba" no existe: se cargó para probar.
- La asignatura "Taller" tampoco se va a dictar.

`DELETE` elimina **filas completas**. No sirve para vaciar una celda (eso es un `UPDATE ... SET columna = NULL`) ni para quitar una columna (eso es `ALTER TABLE ... DROP COLUMN`).

---

## Sintaxis

```sql
DELETE FROM <tabla>
WHERE <condición>;
```

```text
DELETE FROM inscripcion        ← de qué tabla
WHERE id_estudiante = 10       ← qué filas
  AND id_asignatura = 10;
```

> ⚠️ **Un `DELETE` sin `WHERE` elimina TODAS las filas de la tabla.** `DELETE FROM inscripcion;` borraría las 24 inscripciones. La estructura de la tabla queda, pero los datos no se recuperan salvo que haya un respaldo.

---

## Paso 1 — Eliminar una fila

Primero miramos, después borramos:

```sql
SELECT *
FROM inscripcion
WHERE id_estudiante = 10
  AND id_asignatura = 10;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 10 | 10 | NULL |

Es la fila que queremos. Mismo `WHERE`, ahora con `DELETE`:

```sql
DELETE FROM inscripcion
WHERE id_estudiante = 10
  AND id_asignatura = 10;
```

Output muestra `1 row(s) affected`. Agustín sigue existiendo en `estudiante`: lo que se eliminó es su inscripción.

---

## Paso 2 — Eliminar una fila que tiene "hijas": CASCADE

El estudiante de prueba (11) tiene dos inscripciones:

```sql
SELECT *
FROM inscripcion
WHERE id_estudiante = 11;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 11 | 10 | 1.00 |
| 11 | 11 | 1.00 |

```sql
DELETE FROM estudiante
WHERE id_estudiante = 11;
```

```sql
SELECT COUNT(*) AS inscripciones
FROM inscripcion;
```

**Resultado:**

| inscripciones |
| ------------- |
| 21 |

**¿Qué hace exactamente?**

- Había 23 inscripciones (24 menos la de Agustín). Ahora hay 21: se fueron las dos del estudiante de prueba.
- Nadie las borró a mano. Lo hizo la regla `ON DELETE CASCADE` que definimos en la clave foránea de `inscripcion` hacia `estudiante`.
- Output solo informa `1 row(s) affected`: cuenta la fila de `estudiante`, no las que cayeron en cascada.

---

## Paso 3 — Cuando MySQL no deja borrar: RESTRICT

```sql
-- ❌ Ana dicta Matemática
DELETE FROM docente
WHERE id_docente = 1;
```

```text
Error 1451: Cannot delete or update a parent row: a foreign key constraint fails
(`liceo`.`asignatura`, CONSTRAINT `fk_asignatura_docente` FOREIGN KEY (`id_docente`)
REFERENCES `docente` (`id_docente`))
```

La clave foránea de `asignatura` hacia `docente` no tiene `ON DELETE`, así que aplica `RESTRICT`: mientras haya asignaturas que apunten a Ana, no se la puede eliminar. Es la integridad referencial haciendo su trabajo.

**¿Cuándo usar cada camino?** Para eliminar a un docente que dicta asignaturas hay que decidir antes qué pasa con ellas:

- **Reasignarlas** a otro docente con un `UPDATE`, y después borrar.
- **Eliminarlas** primero (si no tienen inscriptos), y después borrar.

---

## Paso 4 — Eliminar en el orden correcto

"Taller" (16) no tiene inscriptos, porque los dos que tenía eran del estudiante de prueba:

```sql
DELETE FROM asignatura
WHERE id_asignatura = 16;
```

Si hubiéramos intentado esto **antes** del paso 2, habría fallado con el `Error 1451`, porque había inscripciones apuntando a Taller.

```text
Orden para eliminar:   inscripcion ──▶ estudiante / asignatura ──▶ grupo / docente
                       (hijas primero, padres al final)
```

---

## Cómo quedó el liceo

| Tabla | Filas |
| ----- | ----- |
| `grupo` | 4 |
| `docente` | 5 |
| `asignatura` | 6 |
| `estudiante` | 10 |
| `inscripcion` | 21 |

Estos son los datos con los que vamos a trabajar en todos los módulos de consultas.

> 💡 **Borrado lógico:** en muchos sistemas reales las filas no se eliminan. Se agrega una columna (por ejemplo `activo`, con 1 o 0) y "dar de baja" es un `UPDATE`. Así se conserva el historial: un estudiante que egresó sigue teniendo sus notas.

## Diferencia clave: DELETE vs UPDATE a NULL

| Aspecto | `DELETE` | `UPDATE … SET columna = NULL` |
| ------- | -------- | ----------------------------- |
| Qué elimina | La fila entera | El valor de una columna |
| La fila | Deja de existir | Sigue existiendo |
| Ejemplo | Agustín ya no cursa Matemática | Agustín cursa Matemática, pero aún no tiene nota |
| Claves foráneas | Puede fallar (1451) o propagarse (`CASCADE`) | No afecta a otras tablas |

Para comparar `DELETE` con `TRUNCATE` y `DROP`, ver la tabla de [ALTER, DROP y TRUNCATE](ALTER-DROP-y-TRUNCATE).

---

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| La tabla quedó vacía | Faltó el `WHERE` | Sin respaldo no tiene arreglo: hacer siempre el `SELECT` previo |
| `Error 1451: Cannot delete or update a parent row` | Otras filas referencian a la que se quiere borrar | Borrar o reasignar antes las filas hijas |
| `Error 1175: You are using safe update mode…` | El `WHERE` no usa una columna clave | Filtrar por la PK, o desactivar el modo seguro si es intencional |
| `0 row(s) affected` | Ninguna fila cumple la condición | Revisar los valores del `WHERE` |
| Se borraron filas de otra tabla "solas" | Una FK con `ON DELETE CASCADE` | Es el comportamiento definido; revisar las FK con `SHOW CREATE TABLE` |
| `Error 1064` cerca de `*` | Se escribió `DELETE * FROM tabla` | `DELETE` no lleva asterisco: `DELETE FROM tabla WHERE …` |
| Después de borrar la fila 11, la siguiente es la 12 | `DELETE` no reinicia `AUTO_INCREMENT` | Es normal: los identificadores no se reutilizan |

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Usá la base `practica`, con las tablas `socio`, `categoria` y `multa` que quedaron de los ejercicios del Módulo 5.

**1.** Eliminá la categoría Poesía.

<details>
<summary>Ver solución</summary>

```sql
DELETE FROM categoria
WHERE nombre = 'Poesía';
```

💡 `nombre` tiene restricción `UNIQUE`, así que identifica una sola fila y el modo seguro de Workbench lo acepta.
</details>

**2.** Eliminá todas las multas que ya fueron pagadas. Antes, comprobá cuáles son.

<details>
<summary>Ver solución</summary>

```sql
SELECT *
FROM multa
WHERE pagada = 1;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM multa
WHERE pagada = 1;

SET SQL_SAFE_UPDATES = 1;
```

💡 El `SELECT` muestra una sola fila (la multa 2). Como `pagada` no es clave, en Workbench hay que desactivar el modo seguro.
</details>

**3.** En la base `liceo`: sin ejecutarlo, ¿qué pasaría con `DELETE FROM grupo WHERE id_grupo = 1;`? ¿Y con `id_grupo = 4`?

<details>
<summary>Ver solución</summary>

- Con `id_grupo = 1`: `Error 1451`, porque hay estudiantes en 3ºA y la FK `fk_estudiante_grupo` no tiene `ON DELETE`.
- Con `id_grupo = 4`: se elimina, porque 2ºB no tiene estudiantes.

💡 No lo ejecutes: el grupo 2ºB se usa más adelante, en los ejemplos de `LEFT JOIN`.
</details>

---

## 📋 Palabras clave

`DELETE FROM` · `WHERE` · `fila` · `ON DELETE CASCADE` · `RESTRICT` · `Error 1451` · `tabla padre` · `tabla hija` · `orden de borrado` · `borrado lógico` · `modo seguro` · `SELECT previo` · `AUTO_INCREMENT` · `irreversible`

---

🧠 **[Autoevaluación — Módulo 6](auto-modulo6)**

---

← [UPDATE: Actualizar datos](UPDATE-actualizar-datos) · [🏠 Inicio](Home) · [Resumen del Módulo 6 →](Resumen-Modulo6)
