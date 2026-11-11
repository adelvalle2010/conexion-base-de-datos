> 🗄️ **Base de datos:** `liceo_sin_normalizar` (Módulo 3 — Normalización) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo3/liceo_sin_normalizar.sql)

## ¿Qué es la tercera forma normal?

Después de la 2FN, la tabla `asignatura` guarda el nombre y el apellido de quien la dicta. Pero esos datos no describen a la asignatura: describen al **docente**. Una tabla está en **tercera forma normal (3FN)** si está en 2FN y ninguna columna que no es clave depende de otra columna que tampoco es clave. Dicho de otro modo: cada columna depende de la clave, de toda la clave y de nada más que la clave.

**Características principales:**

- Elimina las **dependencias transitivas**.
- Se revisa en todas las tablas, tengan clave simple o compuesta.
- Es el nivel que se considera suficiente para la mayoría de las bases de datos.
- Suele hacer aparecer tablas de "catálogo": docentes, ciudades, categorías.

## ¿Qué problema resuelve?

Supongamos que Ana Pereira empieza a dictar también Estadística:

**Antes** (en 2FN)

| id_asignatura | nombre | id_docente | nombre_docente | apellido_docente |
| ------------- | ------ | ---------- | -------------- | ---------------- |
| 10 | Matemática | 1 | Ana | Pereira |
| 11 | Física | 2 | Carlos | Méndez |
| 12 | Historia | 3 | Laura | Sosa |
| 13 | Estadística | 1 | Ana | Pereira |

"Ana Pereira" vuelve a estar dos veces, y con ella vuelven las anomalías: si cambia su apellido hay que tocar dos filas, y un docente nuevo que todavía no tiene asignatura no se puede registrar.

## Paso 1 — Buscar la cadena

```text
id_asignatura → id_docente → nombre_docente, apellido_docente
```

**¿Qué hace exactamente?**

- La asignatura determina a su docente (cada asignatura tiene uno solo).
- El docente determina su propio nombre.
- Por lo tanto la asignatura determina el nombre del docente, pero **de rebote**. Eso es una dependencia transitiva.

> 💡 Prueba rápida: tapá la clave primaria. Si entre las columnas que quedan alguna "explica" a otra, hay una dependencia transitiva. Acá `id_docente` explica a `nombre_docente`.

## Paso 2 — La columna intermedia se lleva lo suyo

La columna del medio (`id_docente`) pasa a ser la clave primaria de una tabla nueva, y se lleva las columnas que dependen de ella. En la tabla original queda como clave foránea.

**Después: tabla `docente`**

| id_docente | nombre | apellido |
| ---------- | ------ | -------- |
| 1 | Ana | Pereira |
| 2 | Carlos | Méndez |
| 3 | Laura | Sosa |

**Después: tabla `asignatura`**

| id_asignatura | nombre | id_docente |
| ------------- | ------ | ---------- |
| 10 | Matemática | 1 |
| 11 | Física | 2 |
| 12 | Historia | 3 |

**Elementos clave:**

- Si Ana dicta otra asignatura, se repite solo el número `1`. Repetir una clave foránea no es redundancia: es la forma de relacionar.
- Cambiar el apellido de Ana es tocar **una** fila de `docente`.
- Un docente sin asignaturas se puede registrar.

## Paso 3 — El esquema en 3FN

```text
docente(id_docente PK, nombre, apellido)
estudiante(id_estudiante PK, nombre, apellido, grupo)
telefono_estudiante(id_estudiante PK/FK → estudiante, telefono PK)
asignatura(id_asignatura PK, nombre, id_docente FK → docente)
inscripcion(id_estudiante PK/FK → estudiante, id_asignatura PK/FK → asignatura, nota)
```

Es el esquema del [Modelo Relacional](Modelo-Relacional) del Módulo 1, más la tabla de teléfonos. Para comprobar que no se perdió nada, unimos las tablas y volvemos a ver la planilla:

```sql
SELECT e.nombre, a.nombre AS asignatura, d.apellido AS docente, i.nota
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
INNER JOIN docente AS d ON d.id_docente = a.id_docente
ORDER BY e.nombre, a.nombre;
```

**Resultado:**

| nombre | asignatura | docente | nota |
| ------ | ---------- | ------- | ---- |
| Lucía | Física | Méndez | 7.00 |
| Lucía | Matemática | Pereira | 9.50 |
| Mateo | Matemática | Pereira | 8.00 |
| Valentina | Historia | Sosa | 10.00 |
| Valentina | Matemática | Pereira | 6.50 |

> 📌 **Nota:** esta consulta usa `INNER JOIN`, que estudiaremos en [INNER JOIN: Uniendo tablas](INNER-JOIN). Por ahora alcanza con ver que los datos originales siguen ahí.

## Otro caso en el liceo: el turno del grupo

Si en `estudiante` guardáramos también el turno, tendríamos `id_estudiante → grupo → turno`: todos los de 3ºA van de mañana. Es otra dependencia transitiva, y la solución es la misma: una tabla `grupo`. La vamos a crear en [ALTER, DROP y TRUNCATE](ALTER-DROP-y-TRUNCATE).

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| Se guarda `nombre_docente` como FK en lugar de un código | Se usó un texto para relacionar | Usar un código: "Ana Pereira" y "ana pereira" no coinciden |
| Se separa `nombre` y `apellido` del estudiante en otra tabla | Se confundió "columna no clave" con "dependencia transitiva" | Solo se separa si una columna no clave **determina** a otra |
| Se elimina `id_docente` de `asignatura` | Se movió la columna en lugar de copiarla | Queda como FK: sin ella no se sabe quién dicta qué |

Continuamos por un caso poco frecuente que la 3FN deja pasar → [Forma normal de Boyce-Codd (BCNF)](Forma-normal-de-Boyce-Codd)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** `oficina(codigo PK, direccion, ciudad, cod_postal)`: cada código postal corresponde a una sola ciudad. Llevala a 3FN.

<details>
<summary>Ver solución</summary>

```text
oficina(codigo PK, direccion, cod_postal FK → localidad)
localidad(cod_postal PK, ciudad)
```

💡 `codigo → cod_postal → ciudad`: la ciudad depende del código postal, no de la oficina.
</details>

**2.** `empleado(codigo PK, nombre, empresa, empresa_pais)`. Llevala a 3FN y proponé una mejora.

<details>
<summary>Ver solución</summary>

```text
empleado(codigo PK, nombre, codigo_empresa FK → empresa)
empresa(codigo PK, nombre, pais)
```

💡 Se podría usar el nombre de la empresa como clave, pero un código propio evita que "TechNova S.A." y "TechNova sa" queden como empresas distintas.
</details>

**3.** ¿Está en 3FN `inscripcion(id_estudiante PK, id_asignatura PK, nota)`?

<details>
<summary>Ver solución</summary>

Sí. Tiene una sola columna no clave, así que no hay otra columna no clave de la que pueda depender.

💡 Para que exista una dependencia transitiva hacen falta al menos dos columnas que no sean clave.
</details>

---

## 📋 Palabras clave

`tercera forma normal` · `3FN` · `dependencia transitiva` · `atributo no clave` · `tabla de catálogo` · `docente` · `clave foránea` · `código vs texto` · `INNER JOIN` · `descomposición` · `grupo y turno` · `redundancia`

---

🧠 **[Autoevaluación — Módulo 3](auto-modulo3)**

---

← [Segunda forma normal (2FN)](Segunda-forma-normal) · [🏠 Inicio](Home) · [Forma normal de Boyce-Codd (BCNF) →](Forma-normal-de-Boyce-Codd)
