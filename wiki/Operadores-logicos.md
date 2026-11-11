> 🗄️ **Base de datos:** `liceo` (Módulo 7 — Consultas Básicas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🔀 Operadores Lógicos (AND, OR, NOT)

## ¿Por qué lo necesitamos?

Las preguntas reales rara vez tienen una sola condición:

- "Estudiantes del grupo 1 **y** nacidos después de marzo de 2009."
- "Notas menores que 6 **o** mayores que 10."
- "Inscripciones que **no** son de Matemática."

Los **operadores lógicos** combinan condiciones simples para armar una más compleja.

| Operador | La fila pasa el filtro si... | En palabras |
| -------- | ---------------------------- | ----------- |
| `AND` | Se cumplen **las dos** condiciones | "y además" |
| `OR` | Se cumple **al menos una** | "o bien" |
| `NOT` | La condición **no** se cumple | "no" |

---

## Sintaxis

```sql
SELECT <columnas>
FROM <tabla>
WHERE <condición_1> AND <condición_2>;

WHERE <condición_1> OR <condición_2>;

WHERE NOT <condición>;
```

### Tabla de verdad

| A | B | A `AND` B | A `OR` B | `NOT` A |
| - | - | --------- | -------- | ------- |
| ✅ | ✅ | ✅ | ✅ | ❌ |
| ✅ | ❌ | ❌ | ✅ | ❌ |
| ❌ | ✅ | ❌ | ✅ | ✅ |
| ❌ | ❌ | ❌ | ❌ | ✅ |

---

## Paso 1 — AND: las dos a la vez

Estudiantes del grupo 1 nacidos después del 1.º de marzo de 2009:

```sql
SELECT nombre, apellido, fecha_nacimiento, id_grupo
FROM estudiante
WHERE id_grupo = 1
  AND fecha_nacimiento > '2009-03-01';
```

**Resultado:**

| nombre | apellido | fecha_nacimiento | id_grupo |
| ------ | -------- | ---------------- | -------- |
| Lucía | Fernández | 2009-03-14 | 1 |
| Valentina | Rodríguez | 2009-07-21 | 1 |

Santiago también es del grupo 1, pero nació en enero: cumple una condición y no la otra, así que queda afuera. Cada `AND` que se agrega **achica** el resultado.

---

## Paso 2 — OR: alcanza con una

Notas muy bajas o muy altas:

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE nota < 5
   OR nota > 10;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 14 | 11.00 |
| 4 | 10 | 4.00 |
| 5 | 10 | 12.00 |
| 8 | 11 | 3.00 |

Cada `OR` que se agrega **agranda** el resultado.

> 💡 En el habla cotidiana decimos "los de 3ºA **y** los de 3ºB", pero en SQL es `id_grupo = 1 OR id_grupo = 2`. Ningún estudiante está en los dos grupos a la vez: con `AND`, el resultado sería vacío.

---

## Paso 3 — NOT: lo contrario

Inscripciones que no son de Matemática (asignatura 10), con nota de 9 o más:

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE NOT id_asignatura = 10
  AND nota >= 9;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 14 | 11.00 |
| 3 | 12 | 10.00 |
| 5 | 12 | 9.00 |
| 7 | 14 | 9.00 |

`NOT id_asignatura = 10` es lo mismo que `id_asignatura <> 10`. `NOT` resulta más útil delante de otros operadores (`NOT IN`, `NOT LIKE`, `NOT BETWEEN`), que veremos en la página siguiente.

---

## Paso 4 — La trampa: AND se evalúa antes que OR

Queremos las inscripciones de Matemática (10) o Física (11) que tengan nota de 9 o más:

```sql
-- ❌ No hace lo que parece
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE id_asignatura = 10
   OR id_asignatura = 11
  AND nota >= 9;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 10 | 9.50 |
| 2 | 10 | 8.00 |
| 3 | 10 | 6.50 |
| 4 | 10 | 4.00 |
| 5 | 10 | 12.00 |
| 6 | 10 | 7.50 |
| 7 | 10 | 10.00 |

Aparecen notas de 4.00 y de 6.50. ¿Por qué? Igual que en matemática la multiplicación se hace antes que la suma, en SQL **`AND` se evalúa antes que `OR`**. MySQL entendió esto:

```text
id_asignatura = 10   OR   (id_asignatura = 11 AND nota >= 9)
└─ toda Matemática ─┘     └─ Física con 9 o más (no hay ninguna) ─┘
```

La solución son los paréntesis:

```sql
-- ✅ Con paréntesis
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE (id_asignatura = 10 OR id_asignatura = 11)
  AND nota >= 9;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 10 | 9.50 |
| 5 | 10 | 12.00 |
| 7 | 10 | 10.00 |

**Elementos clave:**

- Orden de evaluación: primero `NOT`, después `AND`, al final `OR`.
- Los paréntesis cambian ese orden: lo que está adentro se resuelve primero.
- Regla práctica: **si en un `WHERE` hay `AND` y `OR` mezclados, poné paréntesis siempre**, aunque no hagan falta. Se lee mejor y evita sorpresas.

---

## Paso 5 — Varias condiciones encadenadas

Estudiantes de los grupos 1 o 2 nacidos en 2009:

```sql
SELECT nombre, apellido, fecha_nacimiento, id_grupo
FROM estudiante
WHERE (id_grupo = 1 OR id_grupo = 2)
  AND fecha_nacimiento >= '2009-01-01'
  AND fecha_nacimiento <= '2009-12-31';
```

**Resultado:**

| nombre | apellido | fecha_nacimiento | id_grupo |
| ------ | -------- | ---------------- | -------- |
| Lucía | Fernández | 2009-03-14 | 1 |
| Valentina | Rodríguez | 2009-07-21 | 1 |
| Santiago | Pérez | 2009-01-30 | 1 |
| Martina | Suárez | 2009-06-06 | 2 |

---

## Diferencia clave: AND vs OR

| Aspecto | `AND` | `OR` |
| ------- | ----- | ---- |
| La fila pasa si... | Cumple todas las condiciones | Cumple alguna |
| Al agregar condiciones | El resultado se achica | El resultado se agranda |
| Se evalúa | Antes | Después |
| Sobre la misma columna | `nota >= 6 AND nota <= 9` (un rango) | `id_grupo = 1 OR id_grupo = 2` (una lista) |
| Error típico | Usarlo para "los de A y los de B" | Olvidar los paréntesis al mezclarlo con `AND` |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| El resultado trae filas que no deberían estar | `AND` y `OR` mezclados sin paréntesis | Agrupar los `OR` entre paréntesis |
| El resultado está vacío | Dos condiciones con `AND` que no se pueden cumplir a la vez (`id_grupo = 1 AND id_grupo = 2`) | Usar `OR` |
| `Error 1064` en `WHERE id_grupo = 1 OR 2` | La segunda parte no es una condición completa | Repetir la columna: `id_grupo = 1 OR id_grupo = 2` |
| `WHERE id_grupo = 1 OR 2` devuelve todo | En algunas formas, MySQL interpreta `2` como "verdadero" | Igual que arriba: escribir la condición completa |
| `WHERE nota > 6 AND < 9` da error | Falta la columna en la segunda comparación | `nota > 6 AND nota < 9` |

---

Continuamos por operadores que abrevian estas condiciones → [LIKE, IN, BETWEEN e IS NULL](LIKE-IN-BETWEEN-e-IS-NULL)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Mostrá los estudiantes del grupo 2 nacidos antes de 2009.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido, fecha_nacimiento
FROM estudiante
WHERE id_grupo = 2
  AND fecha_nacimiento < '2009-01-01';
```

| nombre | apellido | fecha_nacimiento |
| ------ | -------- | ---------------- |
| Mateo | Silva | 2008-11-02 |
| Camila | González | 2008-09-09 |
| Agustín | Núñez | 2008-04-18 |

💡 Martina también es del grupo 2, pero nació en 2009.
</details>

**2.** Mostrá las asignaturas que dictan el docente 3 o el docente 4.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, id_docente
FROM asignatura
WHERE id_docente = 3
   OR id_docente = 4;
```

| nombre | id_docente |
| ------ | ---------- |
| Historia | 3 |
| Química | 4 |
| Programación | 4 |
| Filosofía | 3 |

💡 "El 3 o el 4" es un `OR`: ninguna asignatura tiene dos docentes.
</details>

**3.** Mostrá las inscripciones de Programación (14) o Química (13) con nota mayor que 8.

<details>
<summary>Ver solución</summary>

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE (id_asignatura = 14 OR id_asignatura = 13)
  AND nota > 8;
```

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 14 | 11.00 |
| 5 | 13 | 8.50 |
| 7 | 14 | 9.00 |

💡 Sin los paréntesis aparecerían todas las de Programación, con cualquier nota.
</details>

**4.** Mostrá los estudiantes que no son del grupo 3 y nacieron en 2009 o después.

<details>
<summary>Ver solución</summary>

```sql
SELECT nombre, apellido, fecha_nacimiento, id_grupo
FROM estudiante
WHERE id_grupo <> 3
  AND fecha_nacimiento >= '2009-01-01';
```

| nombre | apellido | fecha_nacimiento | id_grupo |
| ------ | -------- | ---------------- | -------- |
| Lucía | Fernández | 2009-03-14 | 1 |
| Valentina | Rodríguez | 2009-07-21 | 1 |
| Santiago | Pérez | 2009-01-30 | 1 |
| Martina | Suárez | 2009-06-06 | 2 |

💡 `id_grupo <> 3` y `NOT id_grupo = 3` son equivalentes.
</details>

---

## 📋 Palabras clave

`AND` · `OR` · `NOT` · `operador lógico` · `condición compuesta` · `tabla de verdad` · `precedencia` · `paréntesis` · `verdadero` · `falso` · `rango` · `lista de valores` · `WHERE` · `filtro`

---

🧠 **[Autoevaluación — Módulo 7](auto-modulo7)**

---

← [WHERE: Filtrado de datos](WHERE-filtrado-de-datos) · [🏠 Inicio](Home) · [LIKE, IN, BETWEEN e IS NULL →](LIKE-IN-BETWEEN-e-IS-NULL)
