> 🗄️ **Base de datos:** `liceo_sin_normalizar` (Módulo 3 — Normalización) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo3/liceo_sin_normalizar.sql)

## ¿Qué es la segunda forma normal?

En la planilla, el nombre "Lucía" aparece en cada fila de Lucía, sin importar la asignatura. Eso pasa porque el nombre depende solo del estudiante, que es **una parte** de la clave primaria. Una tabla está en **segunda forma normal (2FN)** si está en 1FN y todas las columnas que no son clave dependen de la clave primaria **completa**, no de una parte.

**Características principales:**

- Solo tiene sentido revisarla cuando la clave primaria es **compuesta**.
- Si la clave primaria es una sola columna y la tabla está en 1FN, ya está en 2FN.
- Elimina las **dependencias parciales**.
- Es la forma normal que más reduce la repetición en tablas que salieron de una planilla.

## ¿Qué problema resuelve?

**Antes** (en 1FN)

| id_estudiante | id_asignatura | nombre_estudiante | grupo | nombre_asignatura | id_docente | nombre_docente | nota |
| - | - | - | - | - | - | - | - |
| 1 | 10 | Lucía | 3ºA | Matemática | 1 | Ana | 9.50 |
| 1 | 11 | Lucía | 3ºA | Física | 2 | Carlos | 7.00 |
| 2 | 10 | Mateo | 3ºB | Matemática | 1 | Ana | 8.00 |
| 3 | 10 | Valentina | 3ºA | Matemática | 1 | Ana | 6.50 |
| 3 | 12 | Valentina | 3ºA | Historia | 3 | Laura | 10.00 |

(Se omiten los apellidos para que la tabla entre en pantalla.)

## Paso 1 — Preguntar de qué depende cada columna

| Columna | Depende de | ¿De toda la clave? |
| ------- | ---------- | ------------------ |
| `nombre_estudiante`, `apellido_estudiante`, `grupo` | `id_estudiante` | ❌ Parcial |
| `nombre_asignatura`, `id_docente`, `nombre_docente`, `apellido_docente` | `id_asignatura` | ❌ Parcial |
| `nota` | `id_estudiante` + `id_asignatura` | ✅ Completa |

## Paso 2 — Una tabla por cada determinante

Cada parte de la clave que determina columnas por su cuenta se lleva esas columnas a una tabla propia, donde pasa a ser la clave primaria.

**Tabla `estudiante`**

| id_estudiante | nombre | apellido | grupo |
| ------------- | ------ | -------- | ----- |
| 1 | Lucía | Fernández | 3ºA |
| 2 | Mateo | Silva | 3ºB |
| 3 | Valentina | Rodríguez | 3ºA |

**Tabla `asignatura`** (todavía con los datos del docente)

| id_asignatura | nombre | id_docente | nombre_docente | apellido_docente |
| ------------- | ------ | ---------- | -------------- | ---------------- |
| 10 | Matemática | 1 | Ana | Pereira |
| 11 | Física | 2 | Carlos | Méndez |
| 12 | Historia | 3 | Laura | Sosa |

**Tabla `inscripcion`**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 10 | 9.50 |
| 1 | 11 | 7.00 |
| 2 | 10 | 8.00 |
| 3 | 10 | 6.50 |
| 3 | 12 | 10.00 |

**¿Qué hace exactamente?**

- "Lucía Fernández, 3ºA" está escrito **una vez**. "Matemática" también.
- En `inscripcion` quedaron la clave completa y lo único que depende de ella: la `nota`.
- Las columnas `id_estudiante` e `id_asignatura` de `inscripcion` pasan a ser claves foráneas.
- No se perdió nada: uniendo las tres tablas se reconstruye la planilla original.

## Paso 3 — El esquema en 2FN

```text
estudiante(id_estudiante PK, nombre, apellido, grupo)
telefono_estudiante(id_estudiante PK/FK → estudiante, telefono PK)
asignatura(id_asignatura PK, nombre, id_docente, nombre_docente, apellido_docente)
inscripcion(id_estudiante PK/FK → estudiante, id_asignatura PK/FK → asignatura, nota)
```

## ¿Y las anomalías?

| Anomalía | ¿Resuelta? | Por qué |
| -------- | ---------- | ------- |
| Inserción: Química sin inscriptos | ✅ | Se agrega una fila en `asignatura` |
| Borrado: se va Valentina | ✅ | Historia sigue en `asignatura` |
| Modificación: cambia el apellido de Ana | ⚠️ Solo si dicta una sola asignatura | Si Ana dictara dos, su nombre estaría en dos filas |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| Se "arregla" agregando un `id_inscripcion` autonumérico | Con clave simple no hay dependencias parciales, pero la repetición sigue: ahora es transitiva | Separar igual las tablas |
| Se llevó la `nota` a `estudiante` | Se confundió de qué depende | La nota depende del estudiante **y** de la asignatura |
| Se borró `id_estudiante` de `inscripcion` | Se movió la clave en lugar de copiarla | La parte de la clave queda en las dos tablas: PK en una, FK en la otra |

Falta un detalle: en `asignatura`, el nombre del docente no depende de la asignatura sino del docente. Continuamos por las dependencias transitivas → [Tercera forma normal (3FN)](Tercera-forma-normal)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** `empleado_departamento(codigo_empleado, codigo_departamento, plus)` tiene como clave primaria las dos primeras columnas. El `plus` es un monto fijo por departamento. ¿Está en 2FN?

<details>
<summary>Ver solución</summary>

No: `codigo_departamento → plus` es una dependencia parcial.

```text
departamento(codigo PK, nombre, plus)
empleado_departamento(codigo_empleado PK/FK, codigo_departamento PK/FK)
```

💡 Si el plus fuera distinto para cada empleado en cada departamento, dependería de toda la clave y la tabla original sí estaría en 2FN.
</details>

**2.** `producto(id_producto, nombre, precio)` con clave primaria `id_producto` está en 1FN. ¿Está en 2FN?

<details>
<summary>Ver solución</summary>

Sí. Con clave primaria de una sola columna no puede haber dependencias parciales.

💡 No hay "parte" de una clave que tiene una sola columna.
</details>

**3.** Llevá a 2FN: `pedido_detalle(id_pedido PK, id_producto PK, cantidad, nombre_producto, fecha_pedido)`.

<details>
<summary>Ver solución</summary>

```text
pedido(id_pedido PK, fecha_pedido)
producto(id_producto PK, nombre_producto)
pedido_detalle(id_pedido PK/FK → pedido, id_producto PK/FK → producto, cantidad)
```

💡 Es la misma forma que el liceo: dos tablas "de cosas" y una intermedia con lo que pertenece a la pareja.
</details>

---

## 📋 Palabras clave

`segunda forma normal` · `2FN` · `dependencia parcial` · `dependencia completa` · `clave primaria compuesta` · `determinante` · `estudiante` · `asignatura` · `inscripcion` · `clave foránea` · `descomposición` · `sin pérdida de información`

---

🧠 **[Autoevaluación — Módulo 3](auto-modulo3)**

---

← [Primera forma normal (1FN)](Primera-forma-normal) · [🏠 Inicio](Home) · [Tercera forma normal (3FN) →](Tercera-forma-normal)
