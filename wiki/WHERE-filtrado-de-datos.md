> 🗄️ **Base de datos:** `liceo` (Módulo 7 — Consultas Básicas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🎯 WHERE: Filtrado de datos

## ¿Por qué lo necesitamos?

Con lo que sabemos, cada consulta devuelve **todas** las filas de la tabla. Con diez estudiantes se puede buscar a ojo; con mil, no. Casi siempre queremos una parte: los estudiantes de un grupo, las notas altas, quienes nacieron antes de cierta fecha.

`WHERE` agrega una **condición**. MySQL revisa las filas una por una y se queda solo con aquellas en las que la condición es verdadera. Limitar las filas se llama **selección**.

Ya lo usaste en `UPDATE` y `DELETE` para elegir qué filas modificar. Acá funciona igual, pero solo para mirar.

---

## Sintaxis

```sql
SELECT <columnas>
FROM <tabla>
WHERE <condición>;
```

### Anatomía de la sentencia

```text
SELECT nombre, apellido
FROM estudiante
WHERE id_grupo = 1;
      ────┬─── ┬ ┬
          │    │ └── valor con el que se compara
          │    └──── operador de comparación
          └───────── columna
```

| Operador | Significado | Ejemplo |
| -------- | ----------- | ------- |
| `=` | Igual | `id_grupo = 1` |
| `<>` (o `!=`) | Distinto | `turno <> 'matutino'` |
| `>` | Mayor | `nota > 9` |
| `>=` | Mayor o igual | `nota >= 9` |
| `<` | Menor | `fecha_nacimiento < '2009-01-01'` |
| `<=` | Menor o igual | `nota <= 6` |

---

## Paso 1 — Comparar con un número

¿Quiénes están en el grupo 1 (3ºA)?

```sql
SELECT nombre, apellido
FROM estudiante
WHERE id_grupo = 1;
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Lucía | Fernández |
| Valentina | Rodríguez |
| Santiago | Pérez |

> 📌 Por ahora filtramos por `id_grupo`, que es el número guardado en `estudiante`. Para escribir "3ºA" en la condición hay que combinar dos tablas, y eso llega con [INNER JOIN: Uniendo tablas](INNER-JOIN).

---

## Paso 2 — Mayor, menor y distinto

¿Qué inscripciones tienen nota 9 o más?

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE nota >= 9;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 10 | 9.50 |
| 1 | 14 | 11.00 |
| 3 | 12 | 10.00 |
| 5 | 10 | 12.00 |
| 5 | 12 | 9.00 |
| 7 | 10 | 10.00 |
| 7 | 14 | 9.00 |

¿Qué asignaturas **no** dicta el docente 4?

```sql
SELECT nombre, id_docente
FROM asignatura
WHERE id_docente <> 4;
```

**Resultado:**

| nombre | id_docente |
| ------ | ---------- |
| Matemática | 1 |
| Física | 2 |
| Historia | 3 |
| Filosofía | 3 |

---

## Paso 3 — Comparar textos

```sql
SELECT nombre, turno
FROM grupo
WHERE turno = 'matutino';
```

**Resultado:**

| nombre | turno |
| ------ | ----- |
| 3ºA | matutino |
| 2ºA | matutino |

**Elementos clave:**

- Los textos van entre **comillas simples**. Sin comillas, MySQL cree que `matutino` es el nombre de una columna y da el `Error 1054`.
- Con la colación que elegimos al crear la base (`utf8mb4_unicode_ci`), la comparación **no distingue mayúsculas ni tildes**:

```sql
SELECT nombre, apellido
FROM estudiante
WHERE nombre = 'lucia';
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Lucía | Fernández |

Se escribió `'lucia'` y encontró a "Lucía". Es práctico para buscar, pero conviene saberlo: en otros motores, o con otra colación, esta consulta no devolvería nada.

---

## Paso 4 — Comparar fechas

¿Quiénes nacieron antes de 2009?

```sql
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
WHERE fecha_nacimiento < '2009-01-01';
```

**Resultado:**

| nombre | apellido | fecha_nacimiento |
| ------ | -------- | ---------------- |
| Mateo | Silva | 2008-11-02 |
| Camila | González | 2008-09-09 |
| Agustín | Núñez | 2008-04-18 |

Las fechas se escriben entre comillas, con el formato `'AAAA-MM-DD'`. "Menor" significa "anterior" y "mayor", "posterior".

---

## Paso 5 — La condición puede usar columnas que no se muestran

```sql
SELECT nombre
FROM asignatura
WHERE id_docente = 3;
```

**Resultado:**

| nombre |
| ------ |
| Historia |
| Filosofía |

`id_docente` no está en el `SELECT`, pero sí en la tabla, y eso alcanza para usarlo en el `WHERE`.

---

## El orden en que MySQL trabaja

Las cláusulas se **escriben** en un orden y se **ejecutan** en otro:

```text
Se escribe:   SELECT ──▶ FROM ──▶ WHERE
Se ejecuta:   FROM   ──▶ WHERE ──▶ SELECT

  1. FROM    toma la tabla completa
  2. WHERE   descarta las filas que no cumplen la condición
  3. SELECT  de las filas que quedan, arma las columnas pedidas
```

Esto explica un error muy común: un alias definido en el `SELECT` **no existe todavía** cuando se evalúa el `WHERE`.

```sql
-- ❌ Error 1054: Unknown column 'anio' in 'where clause'
SELECT nombre, YEAR(fecha_nacimiento) AS anio
FROM estudiante
WHERE anio = 2010;
```

```sql
-- ✅ En el WHERE se repite la expresión
SELECT nombre, YEAR(fecha_nacimiento) AS anio
FROM estudiante
WHERE YEAR(fecha_nacimiento) = 2010;
```

**Resultado:**

| nombre | anio |
| ------ | ---- |
| Joaquín | 2010 |
| Sofía | 2010 |
| Benjamín | 2010 |

---

## Diferencia clave: Selección vs Proyección

| Aspecto | Selección | Proyección |
| ------- | --------- | ---------- |
| Qué limita | Las filas | Las columnas |
| Cláusula | `WHERE` | La lista del `SELECT` |
| Pregunta que responde | ¿De quiénes? | ¿Qué datos? |
| Ejemplo | `WHERE id_grupo = 1` | `SELECT nombre, apellido` |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1054: Unknown column 'matutino' in 'where clause'` | El texto no está entre comillas | `WHERE turno = 'matutino'` |
| `Error 1054: Unknown column 'anio' in 'where clause'` | Se usó un alias del `SELECT` en el `WHERE` | Repetir la expresión en el `WHERE` |
| No devuelve filas y debería | El valor no coincide (un espacio de más, otro formato de fecha) | Mirar los valores reales con un `SELECT` sin `WHERE` |
| `WHERE nota = NULL` no devuelve nada | `NULL` no se compara con `=` | Usar `IS NULL`: lo vemos en [LIKE, IN, BETWEEN e IS NULL](LIKE-IN-BETWEEN-e-IS-NULL) |
| `Error 1064` cerca de `WHERE` | El `WHERE` está antes del `FROM` | El orden es `SELECT … FROM … WHERE …` |
| `WHERE id_grupo = '1'` funciona igual | MySQL convierte el texto a número | Funciona, pero conviene escribir los números sin comillas |

---

Continuamos por cómo combinar varias condiciones → [Operadores Lógicos (AND, OR, NOT)](Operadores-logicos)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Mostrá nombre y apellido de los estudiantes del grupo 3.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido
FROM estudiante
WHERE id_grupo = 3;
```

| nombre | apellido |
| ------ | -------- |
| Joaquín | Martínez |
| Sofía | López |
| Benjamín | Castro |

💡 El grupo 3 es 2ºA; para saberlo hay que mirar la tabla `grupo`.
</details>

**2.** Mostrá las inscripciones con nota menor que 6.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE nota < 6;
```

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 2 | 13 | 5.00 |
| 4 | 10 | 4.00 |
| 8 | 11 | 3.00 |

💡 Las inscripciones sin nota (`NULL`) no aparecen: un valor desconocido no es "menor que 6".
</details>

**3.** Mostrá los grupos que no son del turno matutino.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, turno
FROM grupo
WHERE turno <> 'matutino';
```

| nombre | turno |
| ------ | ----- |
| 3ºB | vespertino |
| 2ºB | nocturno |

💡 `<>` y `!=` son equivalentes; `<>` es la forma del estándar SQL.
</details>

**4.** Mostrá nombre, apellido y fecha de nacimiento de quienes nacieron del 1.º de enero de 2010 en adelante.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
WHERE fecha_nacimiento >= '2010-01-01';
```

| nombre | apellido | fecha_nacimiento |
| ------ | -------- | ---------------- |
| Joaquín | Martínez | 2010-05-17 |
| Sofía | López | 2010-02-03 |
| Benjamín | Castro | 2010-12-25 |

💡 "En adelante" incluye ese día, por eso `>=` y no `>`.
</details>

---

## 📋 Palabras clave

`WHERE` · `condición` · `selección` · `operador de comparación` · `=` · `<>` · `>=` · `comillas simples` · `colación` · `fecha` · `orden de ejecución` · `alias` · `Error 1054` · `filtro`

---

🧠 **[Autoevaluación — Módulo 7](auto-modulo7)**

---

← [SELECT: Sintaxis básica](SELECT-sintaxis-basica) · [🏠 Inicio](Home) · [Operadores Lógicos (AND, OR, NOT) →](Operadores-logicos)
