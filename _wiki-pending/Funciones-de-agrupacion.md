> 🗄️ **Base de datos:** `liceo` (Módulo 8 — Consultas Avanzadas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🧮 Funciones de Agrupación (SUM, COUNT, AVG)

En este módulo vamos a pasar de mirar filas a **sacar conclusiones**: cuántos estudiantes hay, cuál es el promedio de una asignatura, quién no se inscribió a nada. Seguimos con la misma base `liceo` del Módulo 7 y, otra vez, sin modificar ningún dato.

## ¿Por qué lo necesitamos?

Con lo que sabemos, para conocer el promedio de Matemática habría que traer todas las notas y hacer la cuenta a mano:

```sql
-- ❌ Trae 7 filas y la cuenta la hacemos nosotros
SELECT nota
FROM inscripcion
WHERE id_asignatura = 10;
```

Con 7 filas se puede. Con 7.000, no. Las **funciones de agrupación** hacen esa cuenta dentro de la base y devuelven solo el resultado:

```sql
-- ✅ Una sola fila con la respuesta
SELECT ROUND(AVG(nota), 2) AS promedio
FROM inscripcion
WHERE id_asignatura = 10;
```

**Resultado:**

| promedio |
| -------- |
| 8.21 |

> **¿Qué es una función de agrupación?** Es una función que recibe **muchas filas** y devuelve **un solo valor**. También se las llama funciones de agregado o de resumen. Las funciones que vimos hasta ahora, como `YEAR()`, son lo contrario: trabajan fila por fila y devuelven un valor por cada una.

---

## Sintaxis

```sql
SELECT <FUNCIÓN>(<columna>) AS <alias>
FROM <tabla>
WHERE <condición>;
```

| Función | Qué devuelve | Sirve con |
| ------- | ------------ | --------- |
| `COUNT(*)` | Cantidad de filas | Cualquier tabla |
| `COUNT(columna)` | Cantidad de filas donde la columna **no** es `NULL` | Cualquier tipo |
| `COUNT(DISTINCT columna)` | Cantidad de valores distintos | Cualquier tipo |
| `SUM(columna)` | Suma | Números |
| `AVG(columna)` | Promedio | Números |
| `MAX(columna)` | Valor más grande | Números, textos y fechas |
| `MIN(columna)` | Valor más chico | Números, textos y fechas |

---

## Paso 1 — Contar filas con COUNT(*)

¿Cuántos estudiantes tiene el liceo?

```sql
SELECT COUNT(*) AS cantidad_estudiantes
FROM estudiante;
```

**Resultado:**

| cantidad_estudiantes |
| -------------------- |
| 10 |

El `WHERE` se aplica **antes** de contar. ¿Cuántos estudiantes hay en el grupo 1?

```sql
SELECT COUNT(*) AS estudiantes_grupo_1
FROM estudiante
WHERE id_grupo = 1;
```

**Resultado:**

| estudiantes_grupo_1 |
| ------------------- |
| 3 |

---

## Paso 2 — COUNT(*) no es lo mismo que COUNT(columna)

```sql
SELECT COUNT(*)    AS inscripciones,
       COUNT(nota) AS con_nota
FROM inscripcion;
```

**Resultado:**

| inscripciones | con_nota |
| ------------- | -------- |
| 21 | 18 |

Hay 21 inscripciones, pero solo 18 tienen nota. La diferencia son las tres filas con `NULL`.

**Elementos clave:**

- `COUNT(*)` cuenta **filas**, tengan lo que tengan.
- `COUNT(nota)` cuenta las filas donde `nota` **tiene un valor**.
- La resta entre los dos dice cuántos datos faltan.

---

## Paso 3 — Contar valores distintos

¿Cuántos estudiantes están inscriptos en al menos una asignatura?

```sql
SELECT COUNT(id_estudiante)          AS inscripciones,
       COUNT(DISTINCT id_estudiante) AS estudiantes_inscriptos
FROM inscripcion;
```

**Resultado:**

| inscripciones | estudiantes_inscriptos |
| ------------- | ---------------------- |
| 21 | 9 |

Hay 21 inscripciones, pero son de 9 estudiantes diferentes. Como el liceo tiene 10, hay uno que no se inscribió a nada. Más adelante en el módulo vamos a averiguar quién es.

---

## Paso 4 — SUM y AVG

```sql
SELECT SUM(nota)           AS suma,
       ROUND(AVG(nota), 2) AS promedio
FROM inscripcion
WHERE id_asignatura = 11;
```

**Resultado:**

| suma | promedio |
| ---- | -------- |
| 16.00 | 5.33 |

Física tiene tres notas (7, 6 y 3): suman 16 y el promedio es 16 / 3.

> 📌 **Nota:** `AVG` devuelve varios decimales (`5.333333`). Con `ROUND(valor, 2)` lo dejamos en dos, que es como se muestran las notas.

---

## Paso 5 — MAX y MIN

```sql
SELECT MAX(nota) AS mejor_nota,
       MIN(nota) AS peor_nota
FROM inscripcion;
```

**Resultado:**

| mejor_nota | peor_nota |
| ---------- | --------- |
| 12.00 | 3.00 |

Funcionan también con fechas y con textos. La fecha "más chica" es la más antigua:

```sql
SELECT MIN(fecha_nacimiento) AS nacio_primero,
       MAX(fecha_nacimiento) AS nacio_ultimo,
       MIN(apellido)         AS primer_apellido
FROM estudiante;
```

**Resultado:**

| nacio_primero | nacio_ultimo | primer_apellido |
| ------------- | ------------ | --------------- |
| 2008-04-18 | 2010-12-25 | Castro |

---

## Paso 6 — Las funciones de agrupación ignoran los NULL

Programación tiene cuatro inscriptos, pero dos todavía no tienen nota:

```sql
SELECT COUNT(*)            AS inscriptos,
       COUNT(nota)         AS con_nota,
       SUM(nota)           AS suma,
       ROUND(AVG(nota), 2) AS promedio
FROM inscripcion
WHERE id_asignatura = 14;
```

**Resultado:**

| inscriptos | con_nota | suma | promedio |
| ---------- | -------- | ---- | -------- |
| 4 | 2 | 20.00 | 10.00 |

El promedio es 20 / 2, no 20 / 4. `AVG` divide entre la cantidad de filas **con nota**, no entre el total. Es lo correcto: un `NULL` es "todavía no se sabe", no un cero.

¿Y si no hay ninguna fila para resumir? Filosofía (15) no tiene inscriptos:

```sql
SELECT COUNT(*)  AS inscriptos,
       SUM(nota) AS suma,
       AVG(nota) AS promedio
FROM inscripcion
WHERE id_asignatura = 15;
```

**Resultado:**

| inscriptos | suma | promedio |
| ---------- | ---- | -------- |
| 0 | NULL | NULL |

> 💡 Una consulta con funciones de agrupación (y sin `GROUP BY`) devuelve **siempre una fila**, aunque no haya datos. `COUNT` da 0 y las demás dan `NULL`.

---

## Diferencia clave: COUNT(*) vs COUNT(columna) vs COUNT(DISTINCT columna)

| Aspecto | `COUNT(*)` | `COUNT(columna)` | `COUNT(DISTINCT columna)` |
| ------- | ---------- | ---------------- | ------------------------- |
| Cuenta | Filas | Valores no nulos | Valores diferentes no nulos |
| ¿Cuenta los `NULL`? | Sí | No | No |
| ¿Cuenta los repetidos? | Sí | Sí | Una sola vez |
| Pregunta típica | ¿Cuántas inscripciones hay? | ¿Cuántas tienen nota? | ¿Cuántos estudiantes se inscribieron? |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1140`: *In aggregated query without GROUP BY…* | Se mezcló una columna común con una función de agrupación: `SELECT id_asignatura, AVG(nota)` | Quitar la columna o agrupar con `GROUP BY` (página siguiente) |
| `Error 1111`: *Invalid use of group function* | Se usó una función de agrupación en el `WHERE`: `WHERE nota > AVG(nota)` | Usar una subconsulta o `HAVING` (los vemos en este módulo) |
| El promedio da más alto de lo esperado | `AVG` no cuenta las filas con `NULL` | Es el comportamiento correcto. Para tomarlas como cero: `AVG(IFNULL(nota, 0))` |
| `COUNT(nota)` da menos que la cantidad de filas | Hay filas con `NULL` en esa columna | Usar `COUNT(*)` para contar filas |
| `SUM` devuelve `NULL` en vez de 0 | Ninguna fila cumplió el `WHERE` | `IFNULL(SUM(nota), 0)` |
| `Error 1064` cerca de `(` | Espacio entre el nombre de la función y el paréntesis: `COUNT (*)` | Escribirlo pegado: `COUNT(*)` |

---

Continuamos por cómo obtener un resumen **por cada** asignatura o grupo → [GROUP BY y HAVING](GROUP-BY-y-HAVING)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** ¿Cuántas asignaturas se dictan en el liceo?

<details>
<summary>Ver solución</summary>

```sql
SELECT COUNT(*) AS cantidad_asignaturas
FROM asignatura;
```

| cantidad_asignaturas |
| -------------------- |
| 6 |

💡 Para contar filas de una tabla, `COUNT(*)`.
</details>

**2.** ¿Cuál es la mejor y la peor nota de Historia (asignatura 12)?

<details>
<summary>Ver solución</summary>

```sql
SELECT MAX(nota) AS mejor,
       MIN(nota) AS peor
FROM inscripcion
WHERE id_asignatura = 12;
```

| mejor | peor |
| ----- | ---- |
| 10.00 | 6.00 |

💡 La inscripción sin nota no molesta: `MAX` y `MIN` ignoran los `NULL`.
</details>

**3.** ¿Cuántas inscripciones todavía no tienen nota? Resolvelo de dos formas.

<details>
<summary>Ver solución</summary>

```sql
SELECT COUNT(*) - COUNT(nota) AS sin_nota
FROM inscripcion;
```

| sin_nota |
| -------- |
| 3 |

```sql
SELECT COUNT(*) AS sin_nota
FROM inscripcion
WHERE nota IS NULL;
```

| sin_nota |
| -------- |
| 3 |

💡 La primera resta "todas" menos "las que tienen nota". La segunda filtra antes de contar.
</details>

**4.** ¿Cuál es el promedio general de notas del liceo, con dos decimales?

<details>
<summary>Ver solución</summary>

```sql
SELECT ROUND(AVG(nota), 2) AS promedio_general
FROM inscripcion;
```

| promedio_general |
| ---------------- |
| 7.72 |

💡 Sin `WHERE`, la función resume toda la tabla.
</details>

**5.** ¿En cuántas asignaturas diferentes hay al menos un inscripto?

<details>
<summary>Ver solución</summary>

```sql
SELECT COUNT(DISTINCT id_asignatura) AS asignaturas_con_inscriptos
FROM inscripcion;
```

| asignaturas_con_inscriptos |
| -------------------------- |
| 5 |

💡 El liceo dicta 6 asignaturas y solo 5 tienen inscriptos: falta Filosofía.
</details>

**6.** ¿Cuántos estudiantes nacieron en 2009?

<details>
<summary>Ver solución</summary>

```sql
SELECT COUNT(*) AS nacidos_en_2009
FROM estudiante
WHERE YEAR(fecha_nacimiento) = 2009;
```

| nacidos_en_2009 |
| --------------- |
| 4 |

💡 `YEAR()` trabaja fila por fila dentro del `WHERE`; `COUNT(*)` resume lo que quedó.
</details>

---

## 📋 Palabras clave

`función de agrupación` · `función de agregado` · `COUNT(*)` · `COUNT(columna)` · `COUNT(DISTINCT)` · `SUM` · `AVG` · `MAX` · `MIN` · `ROUND` · `IFNULL` · `NULL` · `resumen` · `Error 1140`

---

🧠 **[Autoevaluación — Módulo 8](auto-modulo8)**

---

← [Resumen del Módulo 7](Resumen-Modulo7) · [🏠 Inicio](Home) · [GROUP BY y HAVING →](GROUP-BY-y-HAVING)
