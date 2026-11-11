> 🗄️ **Base de datos:** `liceo_sin_normalizar` (Módulo 3 — Normalización) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo3/liceo_sin_normalizar.sql)

## ¿Qué es la primera forma normal?

En la planilla, la columna `telefonos` de Lucía dice "099 111 222, 098 333 444": dos datos en una celda. La **primera forma normal (1FN)** exige que cada celda guarde **un solo valor** y que cada fila se pueda identificar con una clave primaria. Es el primer escalón de la normalización: sin él, las demás formas normales no se pueden aplicar.

**Características principales:**

- Cada celda contiene un valor **atómico**: que no sea una lista ni un conjunto.
- No hay grupos de columnas repetidas (`telefono1`, `telefono2`, `telefono3`).
- La tabla tiene clave primaria: no hay dos filas iguales.
- El orden de las filas y de las columnas no cambia el significado.

## ¿Qué problema resuelve?

```sql
-- ❌ ¿De quién es el 098 333 444? Hay que buscar "dentro" del texto
SELECT nombre_estudiante, telefonos
FROM planilla_notas
WHERE telefonos LIKE '%098 333 444%';
```

**Resultado:**

| nombre_estudiante | telefonos |
| ----------------- | --------- |
| Lucía | 099 111 222, 098 333 444 |
| Lucía | 099 111 222, 098 333 444 |

Con una lista en la celda no se puede contar cuántos teléfonos tiene cada estudiante, ni borrar uno sin reescribir todo el texto, ni evitar que el mismo número se cargue dos veces.

## Paso 1 — Detectar lo que no es atómico

| Columna | ¿Atómica? | Por qué |
| ------- | --------- | ------- |
| `nombre_estudiante` | Sí | Un nombre por celda |
| `telefonos` | **No** | Lista separada por comas |
| `nota` | Sí | Un número |

> 📌 "Atómico" depende del uso. `grupo` vale "3ºA": si nunca vamos a buscar por año o por letra separados, es atómico.

## Paso 2 — Llevar la lista a una tabla nueva

Es la misma regla del atributo multivaluado que viste en [Pasaje a tablas: casos especiales](Pasaje-a-tablas-casos-especiales): una fila por valor, con una FK a quien pertenece.

**Antes**

| id_estudiante | nombre_estudiante | telefonos |
| ------------- | ----------------- | --------- |
| 1 | Lucía | 099 111 222, 098 333 444 |
| 2 | Mateo | 091 555 666 |
| 3 | Valentina | NULL |

**Después: tabla `telefono_estudiante`**

| id_estudiante | telefono |
| ------------- | -------- |
| 1 | 099 111 222 |
| 1 | 098 333 444 |
| 2 | 091 555 666 |

**¿Qué hace exactamente?**

- Lucía tiene dos filas, Mateo una y Valentina ninguna: ya no hace falta un `NULL`.
- La clave primaria es (`id_estudiante`, `telefono`).
- La columna `telefonos` **se elimina** de la planilla.

## Paso 3 — El esquema en 1FN

```text
planilla_notas(id_estudiante PK, id_asignatura PK, nombre_estudiante, apellido_estudiante, grupo,
               nombre_asignatura, id_docente, nombre_docente, apellido_docente, nota)
telefono_estudiante(id_estudiante PK, telefono PK)
```

```sql
-- ✅ Ahora la pregunta es directa
SELECT id_estudiante
FROM telefono_estudiante
WHERE telefono = '098 333 444';
```

**Resultado:**

| id_estudiante |
| ------------- |
| 1 |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| Columnas `telefono1`, `telefono2`, `telefono3` | Se "resolvió" la lista con columnas numeradas | Tabla aparte: admite 0, 1 o 20 teléfonos |
| Filas duplicadas del estudiante, una por teléfono, en la misma tabla | Se separó la lista sin crear tabla nueva | Mover el teléfono a `telefono_estudiante` |
| Nombres cargados como "Fernández, Lucía" en una columna | Dos datos en una celda | Columnas `nombre` y `apellido` |

La tabla ya está en 1FN, pero "Lucía Fernández" y "Ana Pereira" siguen repetidos. Continuamos por las dependencias parciales → [Segunda forma normal (2FN)](Segunda-forma-normal)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** La tabla `empleado(codigo, nombre, habilidades)` guarda en `habilidades` textos como "liderazgo, comunicación". Llevala a 1FN.

<details>
<summary>Ver solución</summary>

```text
empleado(codigo PK, nombre)
empleado_habilidad(codigo_empleado PK/FK → empleado, habilidad PK)
```

💡 Como la misma habilidad se repite entre empleados y es un texto fácil de escribir distinto, conviene además una tabla `habilidad(codigo PK, nombre)` y guardar el código.
</details>

**2.** ¿Está en 1FN `docente(id_docente, nombre, asignatura1, asignatura2, asignatura3)`?

<details>
<summary>Ver solución</summary>

No: es un grupo repetitivo. Cada celda tiene un solo valor, pero las tres columnas guardan lo mismo.

💡 La pista es el número en el nombre de la columna.
</details>

---

## 📋 Palabras clave

`primera forma normal` · `1FN` · `valor atómico` · `lista de valores` · `grupo repetitivo` · `atributo multivaluado` · `clave primaria` · `telefono_estudiante` · `LIKE` · `fila duplicada` · `tabla nueva` · `NULL`

---

🧠 **[Autoevaluación — Módulo 3](auto-modulo3)**

---

← [Dependencias funcionales](Dependencias-funcionales) · [🏠 Inicio](Home) · [Segunda forma normal (2FN) →](Segunda-forma-normal)
