> 🗄️ **Base de datos:** `liceo` (Módulo 8 — Consultas Avanzadas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🪆 Subconsultas

## ¿Por qué lo necesitamos?

Hay preguntas que necesitan **dos pasos**. Por ejemplo: ¿qué inscripciones tienen una nota mayor que el promedio del liceo?

```sql
-- ❌ Paso 1: averiguo el promedio...
SELECT ROUND(AVG(nota), 2) AS promedio
FROM inscripcion;
```

**Resultado:**

| promedio |
| -------- |
| 7.72 |

```sql
-- ❌ ...y paso 2: lo copio a mano en otra consulta
SELECT COUNT(*) AS sobre_el_promedio
FROM inscripcion
WHERE nota > 7.72;
```

**Resultado:**

| sobre_el_promedio |
| ----------------- |
| 9 |

Funciona hoy. Mañana alguien carga una nota, el promedio cambia y el `7.72` escrito a mano queda viejo. Una **subconsulta** pone el paso 1 adentro del paso 2:

```sql
-- ✅ El promedio se calcula cada vez
SELECT COUNT(*) AS sobre_el_promedio
FROM inscripcion
WHERE nota > (SELECT AVG(nota)
              FROM inscripcion);
```

**Resultado:**

| sobre_el_promedio |
| ----------------- |
| 9 |

> **¿Qué es una subconsulta?** Es un `SELECT` escrito entre paréntesis **dentro de otra sentencia**. MySQL resuelve primero la de adentro y usa su resultado para resolver la de afuera. También se la llama consulta anidada.

**Ventajas:**

- Una sola sentencia, siempre al día.
- Permite usar funciones de agrupación donde el `WHERE` no las admite.

---

## Sintaxis

```sql
SELECT <columnas>
FROM <tabla>
WHERE <columna> <operador> (SELECT <columna>
                            FROM <otra_tabla>
                            WHERE <condición>);
```

Según lo que devuelve, la subconsulta se puede usar en lugares diferentes:

| La subconsulta devuelve | Se llama | Se usa con | Ejemplo |
| ----------------------- | -------- | ---------- | ------- |
| Un solo valor (1 fila, 1 columna) | Escalar | `=`, `>`, `<`, `>=`, `<=`, `<>` | `nota > (SELECT AVG(nota) …)` |
| Una lista (varias filas, 1 columna) | De lista | `IN`, `NOT IN` | `id_estudiante IN (SELECT …)` |
| Filas, sin importar cuáles | De existencia | `EXISTS`, `NOT EXISTS` | `WHERE EXISTS (SELECT …)` |
| Una tabla (varias filas y columnas) | Tabla derivada | En el `FROM`, con alias | `FROM (SELECT …) AS t` |

---

## Paso 1 — Subconsulta que devuelve un valor

¿Quién tiene la mejor nota del liceo?

```sql
SELECT e.nombre, e.apellido, i.nota
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
WHERE i.nota = (SELECT MAX(nota)
                FROM inscripcion);
```

**Resultado:**

| nombre | apellido | nota |
| ------ | -------- | ---- |
| Camila | González | 12.00 |

La subconsulta devuelve `12.00` y la consulta de afuera queda como `WHERE i.nota = 12.00`. A diferencia de `ORDER BY nota DESC LIMIT 1`, esta forma devuelve **todos** los que empatan en el primer lugar.

Otro caso: los estudiantes más jóvenes que Sofía López (estudiante 7).

```sql
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
WHERE fecha_nacimiento > (SELECT fecha_nacimiento
                          FROM estudiante
                          WHERE id_estudiante = 7)
ORDER BY fecha_nacimiento;
```

**Resultado:**

| nombre | apellido | fecha_nacimiento |
| ------ | -------- | ---------------- |
| Joaquín | Martínez | 2010-05-17 |
| Benjamín | Castro | 2010-12-25 |

---

## Paso 2 — Subconsulta que devuelve una lista: IN

¿Qué estudiantes están inscriptos en Programación (14)?

```sql
SELECT nombre, apellido
FROM estudiante
WHERE id_estudiante IN (SELECT id_estudiante
                        FROM inscripcion
                        WHERE id_asignatura = 14)
ORDER BY apellido;
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Lucía | Fernández |
| Sofía | López |
| Santiago | Pérez |
| Martina | Suárez |

La subconsulta devuelve la lista `1, 4, 7, 9` y la de afuera queda como `WHERE id_estudiante IN (1, 4, 7, 9)`.

Las subconsultas se pueden anidar. Los estudiantes de las asignaturas del docente Olivera:

```sql
SELECT nombre, apellido
FROM estudiante
WHERE id_estudiante IN (SELECT id_estudiante
                        FROM inscripcion
                        WHERE id_asignatura IN (SELECT a.id_asignatura
                                                FROM asignatura AS a
                                                INNER JOIN docente AS d ON d.id_docente = a.id_docente
                                                WHERE d.apellido = 'Olivera'))
ORDER BY apellido;
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Lucía | Fernández |
| Camila | González |
| Sofía | López |
| Santiago | Pérez |
| Mateo | Silva |
| Martina | Suárez |

Se lee de adentro hacia afuera: asignaturas de Olivera → inscripciones en esas asignaturas → estudiantes de esas inscripciones.

---

## Paso 3 — NOT IN: los que no están en la lista

¿Qué asignaturas no tienen ningún inscripto?

```sql
SELECT nombre
FROM asignatura
WHERE id_asignatura NOT IN (SELECT id_asignatura
                            FROM inscripcion);
```

**Resultado:**

| nombre |
| ------ |
| Filosofía |

Es la misma pregunta que resolvimos con `LEFT JOIN … IS NULL`, escrita de otra forma.

> ⚠️ **Cuidado con `NOT IN` y los `NULL`:** si la lista de la subconsulta contiene un solo `NULL`, `NOT IN` no devuelve **ninguna** fila. Acá no pasa porque `id_asignatura` es parte de la clave primaria y no puede ser nulo. Cuando la columna admite nulos, agregar `WHERE columna IS NOT NULL` dentro de la subconsulta o usar `NOT EXISTS`.

---

## Paso 4 — Subconsulta correlacionada

Hasta acá, la subconsulta se podía ejecutar sola. Una subconsulta **correlacionada** usa una columna de la consulta de afuera, así que se evalúa **una vez por cada fila**.

¿Qué inscripciones superan el promedio **de su propia asignatura**?

```sql
SELECT i.id_estudiante, i.id_asignatura, i.nota
FROM inscripcion AS i
WHERE i.nota > (SELECT AVG(i2.nota)
                FROM inscripcion AS i2
                WHERE i2.id_asignatura = i.id_asignatura)
ORDER BY i.id_asignatura, i.nota DESC;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 5 | 10 | 12.00 |
| 7 | 10 | 10.00 |
| 1 | 10 | 9.50 |
| 1 | 11 | 7.00 |
| 4 | 11 | 6.00 |
| 3 | 12 | 10.00 |
| 5 | 12 | 9.00 |
| 5 | 13 | 8.50 |
| 9 | 13 | 7.00 |
| 1 | 14 | 11.00 |

```text
Para cada fila de i (afuera):
   ┌─ tomo su id_asignatura ──────────────┐
   │                                      ▼
   │   calculo el promedio de ESA asignatura (adentro, i2)
   │                                      │
   └─ comparo la nota de la fila con ◀────┘
```

La misma tabla aparece dos veces, por eso lleva dos alias distintos (`i` e `i2`).

---

## Paso 5 — EXISTS y NOT EXISTS

`EXISTS` no mira **qué** devuelve la subconsulta, solo **si devuelve algo**.

¿Qué estudiantes tienen alguna nota menor que 6?

```sql
SELECT e.nombre, e.apellido
FROM estudiante AS e
WHERE EXISTS (SELECT 1
              FROM inscripcion AS i
              WHERE i.id_estudiante = e.id_estudiante
                AND i.nota < 6)
ORDER BY e.apellido;
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Benjamín | Castro |
| Santiago | Pérez |
| Mateo | Silva |

¿Y qué estudiantes no tienen ninguna inscripción?

```sql
SELECT e.nombre, e.apellido
FROM estudiante AS e
WHERE NOT EXISTS (SELECT 1
                  FROM inscripcion AS i
                  WHERE i.id_estudiante = e.id_estudiante);
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Agustín | Núñez |

**Elementos clave:**

- `SELECT 1`: como no importa qué devuelve, se pone una constante.
- `EXISTS` casi siempre es correlacionada: la condición `i.id_estudiante = e.id_estudiante` la ata a la fila de afuera.
- Cada estudiante aparece **una vez**, aunque tenga varias notas bajas. Con un `JOIN` saldría repetido.

---

## Paso 6 — Subconsulta en el FROM: tabla derivada

El resultado de una consulta es una tabla, así que se puede consultar como cualquier otra. ¿Cuál es el promedio de los promedios de los estudiantes?

```sql
SELECT ROUND(AVG(p.promedio), 2) AS promedio_de_promedios,
       ROUND(MAX(p.promedio), 2) AS mejor_promedio
FROM (SELECT id_estudiante,
             AVG(nota) AS promedio
      FROM inscripcion
      GROUP BY id_estudiante) AS p;
```

**Resultado:**

| promedio_de_promedios | mejor_promedio |
| --------------------- | -------------- |
| 7.47 | 9.83 |

La tabla derivada `p` tiene una fila por estudiante; la consulta de afuera la resume. No se puede escribir `AVG(AVG(nota))`: para resumir un resumen hacen falta dos niveles.

También se puede unir con otras tablas. Los estudiantes con promedio de 9 o más, con nombre:

```sql
SELECT e.nombre, e.apellido,
       ROUND(p.promedio, 2) AS promedio
FROM estudiante AS e
INNER JOIN (SELECT id_estudiante,
                   AVG(nota) AS promedio
            FROM inscripcion
            GROUP BY id_estudiante) AS p ON p.id_estudiante = e.id_estudiante
WHERE p.promedio >= 9
ORDER BY p.promedio DESC;
```

**Resultado:**

| nombre | apellido | promedio |
| ------ | -------- | -------- |
| Camila | González | 9.83 |
| Sofía | López | 9.50 |
| Lucía | Fernández | 9.17 |

> 📌 **Nota:** en MySQL, toda tabla derivada **debe** llevar alias (`AS p`), aunque después no se use.

---

## Paso 7 — Subconsulta en el SELECT

Una subconsulta escalar puede ser una columna más. Cada asignatura con su cantidad de inscriptos:

```sql
SELECT a.nombre,
       (SELECT COUNT(*)
        FROM inscripcion AS i
        WHERE i.id_asignatura = a.id_asignatura) AS inscriptos
FROM asignatura AS a
ORDER BY a.nombre;
```

**Resultado:**

| nombre | inscriptos |
| ------ | ---------- |
| Filosofía | 0 |
| Física | 3 |
| Historia | 4 |
| Matemática | 7 |
| Programación | 4 |
| Química | 3 |

Filosofía aparece con 0 sin necesidad de `LEFT JOIN`: la consulta de afuera recorre todas las asignaturas y la de adentro cuenta para cada una.

---

## Diferencia clave: subconsulta vs JOIN

| Aspecto | Subconsulta | `JOIN` |
| ------- | ----------- | ------ |
| Se lee como | Pasos: "primero esto, después aquello" | Una tabla grande combinada |
| Muestra columnas de las dos tablas | No (en el `WHERE`) | Sí |
| Filas repetidas | No genera | Puede generar (relaciones 1:N) |
| Comparar con un resumen (`AVG`, `MAX`) | Es su uso natural | Hace falta una tabla derivada |
| "Los que no tienen" | `NOT IN` / `NOT EXISTS` | `LEFT JOIN … IS NULL` |

**¿Cuándo usar cada uno?**

- **`JOIN`**: hay que **mostrar** datos de varias tablas.
- **Subconsulta**: la otra tabla solo sirve para **filtrar**, o hay que comparar contra un valor calculado.

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1242`: *Subquery returns more than 1 row* | Se comparó con `=` una subconsulta que devuelve varias filas | Usar `IN`, o hacer que devuelva una sola (`MAX`, `LIMIT 1`) |
| `Error 1241`: *Operand should contain 1 column(s)* | La subconsulta del `IN` devuelve más de una columna | Dejar una sola columna en su `SELECT` |
| `Error 1248`: *Every derived table must have its own alias* | Subconsulta en el `FROM` sin alias | Agregar `AS nombre` después del paréntesis |
| `NOT IN` no devuelve nada | La lista contiene un `NULL` | Filtrar los nulos adentro, o usar `NOT EXISTS` |
| `Error 1064` cerca de `SELECT` | Faltan los paréntesis de la subconsulta | Toda subconsulta va entre `( )` |
| El resultado es el mismo para todas las filas | Falta la condición que relaciona la subconsulta con la fila de afuera | Agregar `WHERE adentro.columna = afuera.columna` |

---

Continuamos por cómo apilar el resultado de dos consultas → [UNION: Combinar resultados](UNION)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Mostrá las inscripciones con nota menor que el promedio general del liceo, de la más baja a la más alta.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE nota < (SELECT AVG(nota)
              FROM inscripcion)
ORDER BY nota, id_estudiante;
```

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 8 | 11 | 3.00 |
| 4 | 10 | 4.00 |
| 2 | 13 | 5.00 |
| 4 | 11 | 6.00 |
| 8 | 12 | 6.00 |
| 3 | 10 | 6.50 |
| 1 | 11 | 7.00 |
| 9 | 13 | 7.00 |
| 6 | 10 | 7.50 |

💡 Subconsulta escalar: devuelve un solo número y se compara con `<`.
</details>

**2.** ¿Quién es el estudiante de más edad? Resolvelo sin `LIMIT`.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
WHERE fecha_nacimiento = (SELECT MIN(fecha_nacimiento)
                          FROM estudiante);
```

| nombre | apellido | fecha_nacimiento |
| ------ | -------- | ---------------- |
| Agustín | Núñez | 2008-04-18 |

💡 El de más edad tiene la fecha de nacimiento más chica.
</details>

**3.** Mostrá los estudiantes inscriptos en alguna asignatura de la docente Sosa.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido
FROM estudiante
WHERE id_estudiante IN (SELECT i.id_estudiante
                        FROM inscripcion AS i
                        INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
                        INNER JOIN docente    AS d ON d.id_docente = a.id_docente
                        WHERE d.apellido = 'Sosa')
ORDER BY apellido;
```

| nombre | apellido |
| ------ | -------- |
| Benjamín | Castro |
| Camila | González |
| Joaquín | Martínez |
| Valentina | Rodríguez |

💡 Adentro de una subconsulta se puede usar todo lo aprendido, incluidos los `JOIN`.
</details>

**4.** ¿Qué docentes no dictan ninguna asignatura? Resolvelo con `NOT EXISTS`.

<details>
<summary>Ver solución</summary>

```sql
SELECT d.nombre, d.apellido
FROM docente AS d
WHERE NOT EXISTS (SELECT 1
                  FROM asignatura AS a
                  WHERE a.id_docente = d.id_docente);
```

| nombre | apellido |
| ------ | -------- |
| Marta | Giménez |

💡 Mismo resultado que el `LEFT JOIN … IS NULL` de la página anterior.
</details>

**5.** Mostrá, para cada asignatura con notas, el nombre y apellido de quien tiene la mejor nota.

<details>
<summary>Ver solución</summary>

```sql
SELECT a.nombre AS asignatura, e.nombre, e.apellido, i.nota
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
WHERE i.nota = (SELECT MAX(i2.nota)
                FROM inscripcion AS i2
                WHERE i2.id_asignatura = i.id_asignatura)
ORDER BY a.nombre;
```

| asignatura | nombre | apellido | nota |
| ---------- | ------ | -------- | ---- |
| Física | Lucía | Fernández | 7.00 |
| Historia | Valentina | Rodríguez | 10.00 |
| Matemática | Camila | González | 12.00 |
| Programación | Lucía | Fernández | 11.00 |
| Química | Camila | González | 8.50 |

💡 Subconsulta correlacionada: el máximo se calcula para la asignatura de cada fila.
</details>

**6.** ¿Cuál es la asignatura con más inscriptos? Resolvelo con una tabla derivada, sin `LIMIT`.

<details>
<summary>Ver solución</summary>

```sql
SELECT a.nombre, c.inscriptos
FROM asignatura AS a
INNER JOIN (SELECT id_asignatura,
                   COUNT(*) AS inscriptos
            FROM inscripcion
            GROUP BY id_asignatura) AS c ON c.id_asignatura = a.id_asignatura
WHERE c.inscriptos = (SELECT MAX(c2.inscriptos)
                      FROM (SELECT COUNT(*) AS inscriptos
                            FROM inscripcion
                            GROUP BY id_asignatura) AS c2);
```

| nombre | inscriptos |
| ------ | ---------- |
| Matemática | 7 |

💡 Primero se cuenta por asignatura, después se busca el máximo de esas cuentas, y por último se muestra la que lo alcanza. Repetir la misma tabla derivada dos veces es incómodo: es una buena razón para guardarla como **vista**, que vemos al final del módulo.
</details>

---

## 📋 Palabras clave

`subconsulta` · `consulta anidada` · `subconsulta escalar` · `IN` · `NOT IN` · `EXISTS` · `NOT EXISTS` · `subconsulta correlacionada` · `tabla derivada` · `alias` · `consulta externa` · `consulta interna` · `Error 1242` · `Error 1248`

---

🧠 **[Autoevaluación — Módulo 8](auto-modulo8)**

---

← [LEFT JOIN y RIGHT JOIN](LEFT-JOIN-y-RIGHT-JOIN) · [🏠 Inicio](Home) · [UNION: Combinar resultados →](UNION)
