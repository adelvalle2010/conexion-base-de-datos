> 🗄️ **Base de datos:** `liceo_sin_normalizar` (Módulo 3 — Normalización) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo3/liceo_sin_normalizar.sql)

## ¿Qué es una dependencia funcional?

Si te digo "el estudiante número 1", ya sabés que se llama Lucía Fernández y que está en 3ºA. No hay otra posibilidad: a cada `id_estudiante` le corresponde un único nombre. Una **dependencia funcional** es justamente eso: una relación entre columnas en la que, conociendo el valor de una, queda **determinado** el valor de la otra. Es la herramienta con la que se justifican todas las formas normales.

**Características principales:**

- Se escribe con una flecha: `id_estudiante → nombre_estudiante` y se lee "`id_estudiante` determina a `nombre_estudiante`".
- La columna de la izquierda se llama **determinante**.
- No se deducen mirando los datos: salen de las **reglas del liceo** ("cada asignatura la dicta un solo docente").
- Funcionan en un solo sentido: `id_estudiante → grupo`, pero `grupo` no determina al estudiante (en 3ºA hay varios).

## Cómo encontrarlas

Para cada par de columnas, hacete esta pregunta:

> 💡 "Si dos filas tienen el mismo valor en A, ¿están **obligadas** a tener el mismo valor en B?"

| Pregunta | Respuesta | Dependencia |
| -------- | --------- | ----------- |
| Mismo `id_estudiante`, ¿mismo nombre? | Sí | `id_estudiante → nombre_estudiante` |
| Mismo `id_asignatura`, ¿mismo docente? | Sí, cada asignatura tiene un solo docente | `id_asignatura → id_docente` |
| Mismo `id_estudiante`, ¿misma nota? | No: Lucía tiene 9.50 y 7.00 | No hay dependencia |
| Mismo estudiante **y** misma asignatura, ¿misma nota? | Sí | `(id_estudiante, id_asignatura) → nota` |

## Las dependencias de la planilla

```text
id_estudiante                  → nombre_estudiante, apellido_estudiante, grupo, telefonos
id_asignatura                  → nombre_asignatura, id_docente
id_docente                     → nombre_docente, apellido_docente
(id_estudiante, id_asignatura) → nota
```

**Elementos clave:**

- Solo `nota` necesita las dos columnas de la clave primaria para quedar determinada.
- Todo lo demás depende de **una parte** de la clave, o de una columna que ni siquiera es clave (`id_docente`).
- Esas son exactamente las columnas que se repetían en la planilla.

## Tres tipos que hay que reconocer

### 1. Dependencia completa

La columna necesita **toda** la clave primaria.

```text
(id_estudiante, id_asignatura) → nota
```

Es la dependencia "sana": la nota es de esa estudiante en esa asignatura.

### 2. Dependencia parcial

La columna depende de **solo una parte** de una clave primaria compuesta.

```text
(id_estudiante, id_asignatura) → nombre_estudiante     -- ❌ alcanza con id_estudiante
```

Solo puede existir si la clave primaria tiene más de una columna. La elimina la [Segunda forma normal (2FN)](Segunda-forma-normal).

### 3. Dependencia transitiva

La columna depende de la clave **a través de otra** columna que no es clave.

```text
id_asignatura → id_docente → nombre_docente            -- ❌ el nombre depende del docente, no de la asignatura
```

La elimina la [Tercera forma normal (3FN)](Tercera-forma-normal).

## Claves candidatas

Una **clave candidata** es un conjunto mínimo de columnas que determina a todas las demás. En `planilla_notas` hay una sola: (`id_estudiante`, `id_asignatura`).

**¿Cuándo usar cada uno?**

- Una tabla puede tener varias claves candidatas. En una tabla `docente` con cédula, tanto `id_docente` como `cedula` identifican a cada fila.
- De las candidatas se elige una como **clave primaria**; las otras quedan como claves alternativas.
- Tener más de una clave candidata es lo que hace falta para entender la [Forma normal de Boyce-Codd (BCNF)](Forma-normal-de-Boyce-Codd).

## Diferencia clave: Dependencia parcial vs Dependencia transitiva

| Aspecto | Parcial | Transitiva |
| ------- | ------- | ---------- |
| De qué depende la columna | De una parte de la clave | De otra columna que no es clave |
| Ejemplo | `id_estudiante → grupo` | `id_docente → nombre_docente` |
| ¿Requiere clave compuesta? | Sí | No |
| Forma normal que la elimina | 2FN | 3FN |
| Solución | Tabla nueva cuya PK es esa parte de la clave | Tabla nueva cuya PK es la columna intermedia |

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** En una tabla `libro(isbn, titulo, editorial, pais_editorial)`, cada editorial tiene un único país. Escribí las dependencias funcionales.

<details>
<summary>Ver solución</summary>

```text
isbn      → titulo, editorial
editorial → pais_editorial
```

💡 `pais_editorial` depende del ISBN solo a través de la editorial: es una dependencia transitiva.
</details>

**2.** En `planilla_notas`, ¿existe la dependencia `grupo → id_estudiante`? Justificá con los datos.

<details>
<summary>Ver solución</summary>

No. Lucía (1) y Valentina (3) están las dos en 3ºA: el mismo grupo tiene estudiantes distintos.

💡 Que A determine a B no significa que B determine a A.
</details>

**3.** En `pedido_detalle(id_pedido, id_producto, cantidad, nombre_producto, fecha_pedido)`, con clave primaria (`id_pedido`, `id_producto`), clasificá cada dependencia como completa o parcial.

<details>
<summary>Ver solución</summary>

```text
(id_pedido, id_producto) → cantidad          completa
id_producto              → nombre_producto   parcial
id_pedido                → fecha_pedido      parcial
```

💡 La cantidad es de ese producto en ese pedido; el nombre es solo del producto y la fecha, solo del pedido.
</details>

---

## 📋 Palabras clave

`dependencia funcional` · `determinante` · `dependencia completa` · `dependencia parcial` · `dependencia transitiva` · `clave candidata` · `clave primaria` · `clave alternativa` · `regla de negocio` · `A → B` · `clave compuesta` · `atributo no clave`

---

🧠 **[Autoevaluación — Módulo 3](auto-modulo3)**

---

← [¿Por qué normalizar? Anomalías y redundancia](Introduccion-Normalizacion) · [🏠 Inicio](Home) · [Primera forma normal (1FN) →](Primera-forma-normal)
