> 🗄️ **Base de datos:** `liceo` (Módulo 6 — Manipulación de Datos) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo6/liceo_dml.sql)

# ✏️ UPDATE: Actualizar datos

## ¿Por qué lo necesitamos?

En la carga quedaron cuatro cosas mal:

| Problema | Tabla |
| -------- | ----- |
| El apellido de Marta es "Giménez", con tilde | `docente` |
| El grupo 2ºB es nocturno, no matutino | `grupo` |
| Agustín va en el grupo 2 (3ºB), no en el 1 | `estudiante` |
| A Camila le recorrigieron la prueba de Matemática: tiene un punto más | `inscripcion` |

Borrar la fila y volver a insertarla no es una opción: cambiaría el identificador y, si otras tablas la referencian, MySQL no dejaría borrarla. Para cambiar valores de una fila que ya existe se usa `UPDATE`.

---

## Sintaxis

```sql
UPDATE <tabla>
SET <columna_1> = <valor_1>,
    <columna_2> = <valor_2>
WHERE <condición>;
```

### Anatomía de la sentencia

```text
UPDATE docente               ← en qué tabla
SET apellido = 'Giménez'     ← qué columna cambia y cuál es el valor nuevo
WHERE id_docente = 5;        ← en qué filas (¡la parte más importante!)
```

> ⚠️ **Un `UPDATE` sin `WHERE` modifica TODAS las filas de la tabla.** `UPDATE docente SET apellido = 'Giménez';` dejaría a los cinco docentes con el mismo apellido, y no hay forma de deshacerlo. Antes de ejecutar, comprobá siempre que el `WHERE` esté escrito.

---

## Paso 1 — Cambiar un valor de una fila

```sql
UPDATE docente
SET apellido = 'Giménez'
WHERE id_docente = 5;

SELECT *
FROM docente
WHERE id_docente = 5;
```

**Resultado:**

| id_docente | nombre | apellido |
| ---------- | ------ | -------- |
| 5 | Marta | Giménez |

**¿Qué hace exactamente?**

- El `WHERE` usa la **clave primaria**: es la forma más segura de asegurarse de tocar una sola fila.
- Output muestra `1 row(s) affected  Rows matched: 1  Changed: 1`.
- Las demás columnas y las demás filas no cambian.

```sql
UPDATE grupo
SET turno = 'nocturno'
WHERE id_grupo = 4;
```

---

## Paso 2 — Cambiar una clave foránea

Mover a Agustín de grupo es cambiar el valor de su `id_grupo`:

```sql
UPDATE estudiante
SET id_grupo = 2
WHERE id_estudiante = 10;
```

El valor nuevo tiene que existir en `grupo`. Si pusiéramos `id_grupo = 9`, MySQL respondería con el `Error 1452`, igual que en un `INSERT`.

---

## Paso 3 — Calcular el valor nuevo a partir del actual

```sql
UPDATE inscripcion
SET nota = nota + 1
WHERE id_estudiante = 5
  AND id_asignatura = 10;

SELECT *
FROM inscripcion
WHERE id_estudiante = 5;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 5 | 10 | 12.00 |
| 5 | 12 | 9.00 |
| 5 | 13 | 8.50 |

**Elementos clave:**

- `nota = nota + 1` toma el valor que había (11.00) y guarda el resultado (12.00).
- Como la clave primaria es compuesta, el `WHERE` necesita **las dos** columnas, unidas con `AND`. Con solo `id_estudiante = 5` habrían cambiado las tres notas de Camila.
- Los `CHECK` también se comprueban: sumarle otro punto daría 13 y MySQL lo rechazaría con el `Error 3819`.

---

## Paso 4 — Cambiar varias columnas a la vez

```sql
UPDATE estudiante
SET nombre = 'Agustín',
    apellido = 'Núñez'
WHERE id_estudiante = 10;
```

Las asignaciones se separan con comas, y hay un solo `SET`.

> 📌 Si los valores nuevos son iguales a los que ya estaban, Output muestra `0 row(s) affected  Rows matched: 1  Changed: 0`: encontró la fila, pero no había nada que cambiar.

---

## Paso 5 — El modo seguro de Workbench

Workbench trae activada una protección: rechaza los `UPDATE` y `DELETE` cuyo `WHERE` no use una columna clave.

```sql
-- En Workbench, con la configuración por defecto:
UPDATE grupo
SET turno = 'vespertino'
WHERE nombre = '3ºB';
```

Esta sentencia funciona, porque `nombre` tiene una restricción `UNIQUE` (que es un índice). En cambio:

```sql
UPDATE estudiante
SET id_grupo = 2
WHERE apellido = 'Núñez';
```

```text
Error 1175: You are using safe update mode and you tried to update a table
without a WHERE that uses a KEY column.
```

**¿Qué hace exactamente?**

- No es un error de SQL: es Workbench evitando que modifiques muchas filas por accidente.
- La mejor solución es la que venimos usando: filtrar por la clave primaria.
- Si de verdad hace falta, se desactiva **para la sesión actual**:

```sql
SET SQL_SAFE_UPDATES = 0;   -- desactivar
-- ... la sentencia ...
SET SQL_SAFE_UPDATES = 1;   -- volver a activar
```

---

## Mirar antes de cambiar

Un hábito que evita desastres: antes de un `UPDATE`, ejecutar un `SELECT` con **el mismo `WHERE`**.

```sql
-- 1. ¿Qué filas voy a tocar?
SELECT *
FROM inscripcion
WHERE id_estudiante = 5
  AND id_asignatura = 10;

-- 2. Si es lo que esperaba, recién entonces:
UPDATE inscripcion
SET nota = nota + 1
WHERE id_estudiante = 5
  AND id_asignatura = 10;
```

Si el `SELECT` devuelve 300 filas cuando esperabas una, te salvaste.

---

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| Cambiaron todas las filas | Faltó el `WHERE` | No tiene arreglo sin una copia de respaldo: prevenir con el `SELECT` previo |
| `Error 1175: You are using safe update mode…` | El `WHERE` no usa una columna clave | Filtrar por la PK, o desactivar el modo seguro si es intencional |
| `0 row(s) affected`, `Rows matched: 0` | Ninguna fila cumple el `WHERE` | Revisar el valor: ¿existe ese identificador? |
| `Error 1452` al cambiar una FK | El valor nuevo no existe en la tabla padre | Usar un identificador que exista |
| `Error 1062` | El valor nuevo repite una PK o un `UNIQUE` | Elegir otro valor |
| `Error 1064` cerca de `SET` | Se repitió `SET` o se usó `AND` entre asignaciones | Un solo `SET`, asignaciones separadas por comas |
| Se escribió `SET nota = NULL` y borró la nota | `NULL` es un valor válido si la columna lo admite | Correcto si era la intención |

---

Los cuatro errores quedaron corregidos. Continuamos por cómo quitar las filas que sobran → [DELETE: Eliminar registros](DELETE-eliminar-registros)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Usá la base `practica`, con las tablas `socio`, `categoria` y `multa` que quedaron de los ejercicios del Módulo 5.

**1.** Paula (socia 1) informó su correo: `paula@correo.uy`. Registralo.

<details>
<summary>Ver solución</summary>

```sql
UPDATE socio
SET email = 'paula@correo.uy'
WHERE id_socio = 1;
```

💡 Un `UPDATE` también sirve para completar un dato que estaba en `NULL`.
</details>

**2.** La multa número 2 fue pagada. Actualizala.

<details>
<summary>Ver solución</summary>

```sql
UPDATE multa
SET pagada = 1
WHERE id_multa = 2;
```

💡 Filtrando por `id_multa` nos aseguramos de tocar una sola fila.
</details>

**3.** Aumentá un 10 % el monto de todas las multas que no están pagas. ¿Qué pasa en Workbench y por qué?

<details>
<summary>Ver solución</summary>

```sql
SET SQL_SAFE_UPDATES = 0;

UPDATE multa
SET monto = monto * 1.10
WHERE pagada = 0;

SET SQL_SAFE_UPDATES = 1;
```

| id_multa | monto | pagada |
| -------- | ----- | ------ |
| 1 | 165.00 | 0 |
| 2 | 80.50 | 1 |
| 3 | 330.00 | 0 |

💡 Sin desactivar el modo seguro da el `Error 1175`, porque `pagada` no es una columna clave. Acá sí queremos modificar varias filas a la vez.
</details>

---

## 📋 Palabras clave

`UPDATE` · `SET` · `WHERE` · `clave primaria` · `AND` · `fila afectada` · `Rows matched` · `modo seguro` · `SQL_SAFE_UPDATES` · `Error 1175` · `expresión` · `SELECT previo` · `irreversible` · `DML`

---

🧠 **[Autoevaluación — Módulo 6](auto-modulo6)**

---

← [INSERT: Insertar registros](INSERT-insertar-registros) · [🏠 Inicio](Home) · [DELETE: Eliminar registros →](DELETE-eliminar-registros)
