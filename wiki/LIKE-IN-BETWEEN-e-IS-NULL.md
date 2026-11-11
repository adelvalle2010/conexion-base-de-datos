> 🗄️ **Base de datos:** `liceo` (Módulo 7 — Consultas Básicas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🧩 LIKE, IN, BETWEEN e IS NULL

## ¿Por qué lo necesitamos?

Con `=`, `<`, `>`, `AND` y `OR` se puede escribir casi cualquier filtro, pero algunos quedan largos y otros directamente no se pueden hacer:

| Quiero... | Con lo que sabemos | Operador nuevo |
| --------- | ------------------ | -------------- |
| Apellidos que terminan en "ez" | No se puede | `LIKE` |
| Asignaturas 10, 12 o 14 | `id = 10 OR id = 12 OR id = 14` | `IN` |
| Notas entre 6 y 9 | `nota >= 6 AND nota <= 9` | `BETWEEN` |
| Inscripciones sin nota | `nota = NULL` **no funciona** | `IS NULL` |

---

## Paso 1 — LIKE: buscar por una parte del texto

`LIKE` compara un texto con un **patrón**. El patrón usa dos comodines:

| Comodín | Reemplaza a... | Ejemplo | Coincide con |
| ------- | -------------- | ------- | ------------ |
| `%` | Cualquier cantidad de caracteres (también cero) | `'M%'` | Mateo, Martina, M |
| `_` | Exactamente un carácter | `'_a%'` | Mateo, Camila, Valentina |

Nombres que empiezan con "M":

```sql
SELECT nombre, apellido
FROM estudiante
WHERE nombre LIKE 'M%';
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Mateo | Silva |
| Martina | Suárez |

Apellidos que terminan en "ez":

```sql
SELECT nombre, apellido
FROM estudiante
WHERE apellido LIKE '%ez';
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Lucía | Fernández |
| Valentina | Rodríguez |
| Santiago | Pérez |
| Camila | González |
| Joaquín | Martínez |
| Sofía | López |
| Martina | Suárez |
| Agustín | Núñez |

Asignaturas que contienen "ica" en cualquier parte:

```sql
SELECT nombre
FROM asignatura
WHERE nombre LIKE '%ica%';
```

**Resultado:**

| nombre |
| ------ |
| Física |
| Matemática |
| Química |

Nombres de exactamente cinco letras:

```sql
SELECT nombre
FROM estudiante
WHERE nombre LIKE '_____';
```

**Resultado:**

| nombre |
| ------ |
| Lucía |
| Mateo |
| Sofía |

**Elementos clave:**

- Sin comodines, `LIKE` se comporta como `=`.
- `NOT LIKE` devuelve lo contrario.
- Igual que `=`, con nuestra colación no distingue mayúsculas ni tildes: `LIKE 'm%'` también encuentra a Mateo.

---

## Paso 2 — IN: uno de una lista

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE id_asignatura IN (12, 13);
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 2 | 13 | 5.00 |
| 3 | 12 | 10.00 |
| 5 | 12 | 9.00 |
| 5 | 13 | 8.50 |
| 6 | 12 | NULL |
| 8 | 12 | 6.00 |
| 9 | 13 | 7.00 |

Es lo mismo que `id_asignatura = 12 OR id_asignatura = 13`, pero más corto y sin riesgo de olvidar paréntesis. Sirve también con textos:

```sql
SELECT nombre, turno
FROM grupo
WHERE turno IN ('vespertino', 'nocturno');
```

**Resultado:**

| nombre | turno |
| ------ | ----- |
| 3ºB | vespertino |
| 2ºB | nocturno |

Con `NOT IN` se excluye la lista:

```sql
SELECT nombre
FROM asignatura
WHERE id_docente NOT IN (3, 4);
```

**Resultado:**

| nombre |
| ------ |
| Matemática |
| Física |

---

## Paso 3 — BETWEEN: dentro de un rango

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE nota BETWEEN 6 AND 7;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 11 | 7.00 |
| 3 | 10 | 6.50 |
| 4 | 11 | 6.00 |
| 8 | 12 | 6.00 |
| 9 | 13 | 7.00 |

**¿Qué hace exactamente?**

- `BETWEEN 6 AND 7` equivale a `nota >= 6 AND nota <= 7`: **incluye los dos extremos**.
- El menor va primero: `BETWEEN 7 AND 6` no devuelve nada.

Con fechas es donde más se usa. Estudiantes nacidos en 2009:

```sql
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
WHERE fecha_nacimiento BETWEEN '2009-01-01' AND '2009-12-31';
```

**Resultado:**

| nombre | apellido | fecha_nacimiento |
| ------ | -------- | ---------------- |
| Lucía | Fernández | 2009-03-14 |
| Valentina | Rodríguez | 2009-07-21 |
| Santiago | Pérez | 2009-01-30 |
| Martina | Suárez | 2009-06-06 |

---

## Paso 4 — IS NULL: el dato que falta

¿Qué inscripciones todavía no tienen nota?

```sql
-- ❌ Parece lógico, pero no devuelve nada
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE nota = NULL;
```

**Resultado:**

*(ninguna fila)*

```sql
-- ✅ La forma correcta
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE nota IS NULL;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 4 | 14 | NULL |
| 6 | 12 | NULL |
| 9 | 14 | NULL |

**¿Qué hace exactamente?**

- `NULL` significa "valor desconocido". Preguntar si algo **es igual** a un valor desconocido no da verdadero ni falso: da desconocido, y el `WHERE` solo deja pasar lo que es verdadero.
- Por eso existen dos operadores especiales: `IS NULL` e `IS NOT NULL`.
- Lo mismo pasa con `<>`, `<` y `>`: ninguna comparación común funciona con `NULL`.

Inscripciones de Programación (14) que ya tienen nota:

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE id_asignatura = 14
  AND nota IS NOT NULL;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 14 | 11.00 |
| 7 | 14 | 9.00 |

> ⚠️ **Los `NULL` desaparecen sin avisar.** `WHERE nota < 6` no incluye las inscripciones sin nota, y `WHERE nota >= 6` tampoco. Entre las dos consultas suman 18 filas, no 21. Si importa contarlas, hay que pedirlas aparte con `IS NULL`.

---

## Diferencia clave: = vs LIKE

| Aspecto | `=` | `LIKE` |
| ------- | --- | ------ |
| Compara | El valor completo | Un patrón |
| Comodines `%` y `_` | Son caracteres comunes | Tienen significado especial |
| `nombre = 'M%'` | Busca a alguien llamado literalmente "M%" | — |
| `nombre LIKE 'M%'` | — | Busca nombres que empiezan con M |
| Velocidad | Más rápido | Más lento, sobre todo si el patrón empieza con `%` |
| Cuándo usar | Se conoce el valor exacto | Se conoce una parte |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `WHERE nombre = 'M%'` no devuelve nada | Los comodines solo funcionan con `LIKE` | Cambiar `=` por `LIKE` |
| `WHERE nota = NULL` no devuelve nada | `NULL` no se compara con `=` | `WHERE nota IS NULL` |
| `LIKE '%ez'` no encuentra "Pérez " | Hay un espacio al final del dato | `LIKE '%ez%'`, o limpiar el dato con `TRIM` |
| `BETWEEN 9 AND 6` no devuelve nada | Los extremos están al revés | Primero el menor |
| `IN (12 13)` da `Error 1064` | Falta la coma entre los valores | `IN (12, 13)` |
| Faltan filas al sumar "menores que 6" y "6 o más" | Las que tienen `NULL` no entran en ninguna | Agregar `OR nota IS NULL` si corresponde |
| `NOT IN (3, NULL)` no devuelve nada | Un `NULL` dentro de la lista vuelve desconocida toda la comparación | No poner `NULL` en una lista de `NOT IN` |

---

Continuamos por cómo ordenar y recortar el resultado → [ORDER BY y LIMIT](ORDER-BY-y-LIMIT)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Mostrá los docentes cuyo apellido empieza con "S" o con "P".

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido
FROM docente
WHERE apellido LIKE 'S%'
   OR apellido LIKE 'P%';
```

| nombre | apellido |
| ------ | -------- |
| Ana | Pereira |
| Laura | Sosa |

💡 `LIKE` admite un solo patrón; para dos, se unen con `OR`.
</details>

**2.** Mostrá los estudiantes cuyo nombre contiene la letra "t".

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido
FROM estudiante
WHERE nombre LIKE '%t%';
```

| nombre | apellido |
| ------ | -------- |
| Mateo | Silva |
| Valentina | Rodríguez |
| Santiago | Pérez |
| Martina | Suárez |
| Agustín | Núñez |

💡 Un `%` a cada lado: la letra puede estar en cualquier posición.
</details>

**3.** Mostrá las inscripciones de las asignaturas 10, 11 y 14 con nota entre 9 y 12.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE id_asignatura IN (10, 11, 14)
  AND nota BETWEEN 9 AND 12;
```

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 10 | 9.50 |
| 1 | 14 | 11.00 |
| 5 | 10 | 12.00 |
| 7 | 10 | 10.00 |
| 7 | 14 | 9.00 |

💡 Con `IN` no hacen falta paréntesis extra: la lista ya es una sola condición.
</details>

**4.** Mostrá los estudiantes que **no** nacieron en 2009.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
WHERE fecha_nacimiento NOT BETWEEN '2009-01-01' AND '2009-12-31';
```

| nombre | apellido | fecha_nacimiento |
| ------ | -------- | ---------------- |
| Mateo | Silva | 2008-11-02 |
| Camila | González | 2008-09-09 |
| Joaquín | Martínez | 2010-05-17 |
| Sofía | López | 2010-02-03 |
| Benjamín | Castro | 2010-12-25 |
| Agustín | Núñez | 2008-04-18 |

💡 `NOT BETWEEN` devuelve lo que queda fuera del rango, por los dos lados.
</details>

**5.** ¿De qué asignaturas hay inscripciones sin nota? Mostrá cada número de asignatura una sola vez.

<details>
<summary>Ver solución</summary>

```sql
SELECT DISTINCT id_asignatura
FROM inscripcion
WHERE nota IS NULL;
```

| id_asignatura |
| ------------- |
| 12 |
| 14 |

💡 Hay tres inscripciones sin nota, pero dos son de la misma asignatura.
</details>

---

## 📋 Palabras clave

`LIKE` · `comodín` · `%` · `_` · `patrón` · `IN` · `NOT IN` · `BETWEEN` · `rango inclusivo` · `IS NULL` · `IS NOT NULL` · `NULL` · `valor desconocido` · `NOT LIKE`

---

🧠 **[Autoevaluación — Módulo 7](auto-modulo7)**

---

← [Operadores Lógicos (AND, OR, NOT)](Operadores-logicos) · [🏠 Inicio](Home) · [ORDER BY y LIMIT →](ORDER-BY-y-LIMIT)
