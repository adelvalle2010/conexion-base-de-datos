> 🗄️ **Base de datos:** `liceo` (Módulo 8 — Consultas Avanzadas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🪟 Vistas

## ¿Por qué lo necesitamos?

Cada vez que queremos ver notas con nombres hay que volver a escribir los mismos `JOIN`:

```sql
-- ❌ Las mismas líneas de JOIN en cada consulta
SELECT e.nombre, e.apellido, i.nota
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
WHERE a.nombre = 'Física'
ORDER BY i.nota DESC;
```

Una **vista** guarda esa consulta con un nombre. Después se usa como si fuera una tabla:

```sql
-- ✅ La consulta larga se escribe una sola vez (la creamos en el Paso 1)
SELECT nombre, apellido, nota
FROM v_notas
WHERE asignatura = 'Física'
ORDER BY nota DESC;
```

> **¿Qué es una vista?** Es una consulta `SELECT` guardada en la base con un nombre. No guarda datos: guarda **la consulta**. Cada vez que se la usa, MySQL la ejecuta sobre las tablas reales, así que siempre muestra los datos del momento. Por eso también se la llama tabla virtual.

**Ventajas:**

- **Simplicidad**: las consultas complejas se escriben y se corrigen en un solo lugar.
- **Consistencia**: todos calculan "el promedio" de la misma manera.
- **Seguridad**: se puede dar acceso a una vista que muestra solo algunas columnas, sin dar acceso a la tabla (lo vemos en [Usuarios y permisos](Usuarios-y-permisos)).

---

## Sintaxis

```sql
CREATE VIEW <nombre_vista> AS
SELECT <columnas>
FROM <tablas>
WHERE <condición>;
```

| Sentencia | Para qué sirve |
| --------- | -------------- |
| `CREATE VIEW nombre AS SELECT …` | Crea la vista |
| `CREATE OR REPLACE VIEW nombre AS SELECT …` | La crea o, si ya existe, la reemplaza |
| `DROP VIEW nombre` | La elimina (los datos de las tablas no se tocan) |
| `SHOW CREATE VIEW nombre` | Muestra la consulta guardada |
| `SHOW FULL TABLES` | Lista tablas y vistas, indicando cuál es cuál |

> 📌 **Nota:** en este curso las vistas llevan el prefijo `v_`. No es obligatorio, pero deja claro a simple vista que no es una tabla.

---

## Paso 1 — Crear una vista

```sql
CREATE VIEW v_notas AS
SELECT e.id_estudiante,
       e.nombre,
       e.apellido,
       a.nombre   AS asignatura,
       d.apellido AS docente,
       i.nota
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
INNER JOIN docente    AS d ON d.id_docente = a.id_docente;
```


Workbench responde `0 row(s) affected`: no se movió ningún dato, solo se guardó la definición. La vista aparece en el panel **Schemas**, dentro de `liceo` → **Views**.

**Elementos clave:**

- Las columnas de la vista se llaman como las columnas (o los alias) del `SELECT`.
- No puede haber dos columnas con el mismo nombre: por eso `a.nombre AS asignatura` y `d.apellido AS docente`.

---

## Paso 2 — Consultar la vista como una tabla

```sql
SELECT nombre, apellido, nota
FROM v_notas
WHERE asignatura = 'Física'
ORDER BY nota DESC;
```

**Resultado:**

| nombre | apellido | nota |
| ------ | -------- | ---- |
| Lucía | Fernández | 7.00 |
| Santiago | Pérez | 6.00 |
| Benjamín | Castro | 3.00 |

Sobre una vista vale todo lo aprendido: `WHERE`, `ORDER BY`, `GROUP BY`, funciones de agrupación.

```sql
SELECT docente,
       COUNT(*)            AS inscripciones,
       ROUND(AVG(nota), 2) AS promedio
FROM v_notas
GROUP BY docente
ORDER BY promedio DESC;
```

**Resultado:**

| docente | inscripciones | promedio |
| ------- | ------------- | -------- |
| Sosa | 4 | 8.33 |
| Pereira | 7 | 8.21 |
| Olivera | 7 | 8.10 |
| Méndez | 3 | 5.33 |

---

## Paso 3 — Una vista con resumen

```sql
CREATE VIEW v_promedio_estudiante AS
SELECT e.id_estudiante,
       e.nombre,
       e.apellido,
       g.nombre                AS grupo,
       COUNT(i.id_asignatura) AS asignaturas,
       ROUND(AVG(i.nota), 2)  AS promedio
FROM estudiante AS e
INNER JOIN grupo      AS g ON g.id_grupo = e.id_grupo
LEFT JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
GROUP BY e.id_estudiante, e.nombre, e.apellido, g.nombre;
```


```sql
SELECT nombre, apellido, grupo, asignaturas, promedio
FROM v_promedio_estudiante
WHERE grupo = '3ºB'
ORDER BY apellido;
```

**Resultado:**

| nombre | apellido | grupo | asignaturas | promedio |
| ------ | -------- | ----- | ----------- | -------- |
| Camila | González | 3ºB | 3 | 9.83 |
| Agustín | Núñez | 3ºB | 0 | NULL |
| Mateo | Silva | 3ºB | 2 | 6.50 |
| Martina | Suárez | 3ºB | 2 | 7.00 |

Y la pregunta que antes pedía una tabla derivada, ahora en tres líneas:

```sql
SELECT nombre, apellido, promedio
FROM v_promedio_estudiante
WHERE promedio >= 9
ORDER BY promedio DESC;
```

**Resultado:**

| nombre | apellido | promedio |
| ------ | -------- | -------- |
| Camila | González | 9.83 |
| Sofía | López | 9.50 |
| Lucía | Fernández | 9.17 |

---

## Paso 4 — La vista siempre está al día

La vista no guarda una copia. Si cambian las tablas, cambia lo que muestra:

```text
┌────────────┐   SELECT … FROM v_notas    ┌───────────────────┐   lee    ┌─────────────┐
│  Usuario   │ ─────────────────────────▶ │ Vista: v_notas    │ ───────▶ │ inscripcion │
│            │ ◀───────────────────────── │ (consulta guarda- │ ◀─────── │ estudiante  │
└────────────┘      datos de este momento │  da, sin datos)   │          │ asignatura  │
                                          └───────────────────┘          │ docente     │
                                                                         └─────────────┘
```

Si mañana se le pone la nota de Programación a Martina Suárez con un `UPDATE` sobre `inscripcion`, la próxima consulta a `v_promedio_estudiante` ya muestra su promedio nuevo, sin hacer nada más.

---

## Paso 5 — Unir vistas con tablas y con otras vistas

Una vista se puede usar en un `JOIN`. ¿Quién tiene el mejor promedio de cada grupo?

```sql
SELECT p.grupo, p.nombre, p.apellido, p.promedio
FROM v_promedio_estudiante AS p
WHERE p.promedio = (SELECT MAX(p2.promedio)
                    FROM v_promedio_estudiante AS p2
                    WHERE p2.grupo = p.grupo)
ORDER BY p.grupo;
```

**Resultado:**

| grupo | nombre | apellido | promedio |
| ----- | ------ | -------- | -------- |
| 2ºA | Sofía | López | 9.50 |
| 3ºA | Lucía | Fernández | 9.17 |
| 3ºB | Camila | González | 9.83 |

También se puede crear una vista **a partir de otra**:

```sql
CREATE VIEW v_cuadro_de_honor AS
SELECT nombre, apellido, grupo, promedio
FROM v_promedio_estudiante
WHERE promedio >= 9;
```


```sql
SELECT *
FROM v_cuadro_de_honor
ORDER BY promedio DESC;
```

**Resultado:**

| nombre | apellido | grupo | promedio |
| ------ | -------- | ----- | -------- |
| Camila | González | 3ºB | 9.83 |
| Sofía | López | 2ºA | 9.50 |
| Lucía | Fernández | 3ºA | 9.17 |

> ⚠️ **Sin abusar:** una vista sobre una vista sobre otra vista es difícil de entender y puede ser lenta, porque MySQL tiene que resolver todas las consultas encadenadas. Dos niveles suele ser un buen límite.

---

## Paso 6 — Modificar y eliminar una vista

Para cambiar la definición, `CREATE OR REPLACE VIEW` con la consulta completa. Agregamos el turno al cuadro de honor:

```sql
CREATE OR REPLACE VIEW v_cuadro_de_honor AS
SELECT p.nombre, p.apellido, p.grupo, g.turno, p.promedio
FROM v_promedio_estudiante AS p
INNER JOIN grupo AS g ON g.nombre = p.grupo
WHERE p.promedio >= 9;
```


```sql
SELECT *
FROM v_cuadro_de_honor
ORDER BY promedio DESC;
```

**Resultado:**

| nombre | apellido | grupo | turno | promedio |
| ------ | -------- | ----- | ----- | -------- |
| Camila | González | 3ºB | vespertino | 9.83 |
| Sofía | López | 2ºA | matutino | 9.50 |
| Lucía | Fernández | 3ºA | matutino | 9.17 |

Para ver qué vistas existen:

```sql
SHOW FULL TABLES
WHERE Table_type = 'VIEW';
```

**Resultado:**

| Tables_in_liceo | Table_type |
| --------------- | ---------- |
| v_cuadro_de_honor | VIEW |
| v_notas | VIEW |
| v_promedio_estudiante | VIEW |

Y para eliminar una:

```sql
DROP VIEW v_cuadro_de_honor;
```

> ⚠️ **Atención:** `DROP VIEW` borra solo la definición; las tablas y sus datos quedan intactos. Pero si otra vista dependía de la eliminada, esa otra deja de funcionar (`Error 1356`).

---

## ¿Se pueden modificar datos a través de una vista?

A veces. Una vista es **actualizable** cuando cada fila suya corresponde a una sola fila de una tabla.

| La vista tiene… | ¿Admite `INSERT` / `UPDATE` / `DELETE`? |
| --------------- | --------------------------------------- |
| Columnas de una sola tabla, con `WHERE` | Sí |
| `JOIN` | `UPDATE` sobre columnas de una tabla por vez; con limitaciones |
| `GROUP BY`, `HAVING` o funciones de agrupación | No |
| `DISTINCT` o `UNION` | No |
| Columnas calculadas (`ROUND(…)`, `CONCAT(…)`) | Esas columnas, no |

De nuestras vistas, `v_promedio_estudiante` no es actualizable: ¿qué significaría cambiar un promedio?

> 💡 En este curso usamos las vistas **para leer**. Los cambios se hacen sobre las tablas, con las sentencias del Módulo 6.

## Diferencia clave: tabla vs vista

| Aspecto | Tabla | Vista |
| ------- | ----- | ----- |
| Guarda | Datos | Una consulta |
| Ocupa espacio en disco | Sí | Casi nada |
| Se crea con | `CREATE TABLE` | `CREATE VIEW … AS SELECT` |
| Sus datos | Los que se insertaron | Los que devuelve la consulta en ese momento |
| Se puede consultar con `SELECT` | Sí | Sí |
| Se puede modificar con `INSERT` / `UPDATE` | Sí | Solo en casos simples |
| Si se elimina | Se pierden los datos | No se pierde ningún dato |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1050`: *Table 'v_notas' already exists* | Ya hay una vista (o tabla) con ese nombre | `CREATE OR REPLACE VIEW`, o elegir otro nombre |
| `Error 1060`: *Duplicate column name 'nombre'* | Dos columnas del `SELECT` se llaman igual | Poner alias: `a.nombre AS asignatura` |
| `Error 1356`: *View references invalid table(s) or column(s)* | Se eliminó o renombró una tabla, columna o vista de la que dependía | Recrear la vista con la definición corregida |
| `Error 1288`: *The target table … is not updatable* | `UPDATE` o `INSERT` sobre una vista con `GROUP BY`, `DISTINCT` o funciones | Modificar la tabla original |
| `Error 1051`: *Unknown table* al hacer `DROP TABLE v_notas` | Las vistas se eliminan con otra sentencia | `DROP VIEW v_notas` |
| La vista no muestra una columna nueva de la tabla | Se creó con `SELECT *`, que se "congela" con las columnas de ese momento | Listar las columnas a mano y recrear la vista |

---

Continuamos por el repaso del módulo → [Resumen del Módulo 8](Resumen-Modulo8)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Los ejercicios 2, 4 y 6 usan las vistas creadas en los anteriores.

**1.** Creá la vista `v_estudiante_grupo` con el `id_estudiante`, nombre y apellido de cada estudiante, el nombre de su grupo (como `grupo`) y el turno.

<details>
<summary>Ver solución</summary>

```sql
CREATE VIEW v_estudiante_grupo AS
SELECT e.id_estudiante,
       e.nombre,
       e.apellido,
       g.nombre AS grupo,
       g.turno
FROM estudiante AS e
INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo;
```


💡 Sin el alias `grupo` habría dos columnas `nombre` y MySQL daría `Error 1060`.
</details>

**2.** Usando `v_estudiante_grupo`, mostrá cuántos estudiantes hay en cada turno.

<details>
<summary>Ver solución</summary>

```sql
SELECT turno,
       COUNT(*) AS estudiantes
FROM v_estudiante_grupo
GROUP BY turno
ORDER BY estudiantes DESC;
```

| turno | estudiantes |
| ----- | ----------- |
| matutino | 6 |
| vespertino | 4 |

💡 El turno nocturno no aparece: su único grupo no tiene estudiantes y la vista usa `INNER JOIN`.
</details>

**3.** Creá la vista `v_resumen_asignatura` con el nombre de cada asignatura, el apellido de su docente, la cantidad de inscriptos y el promedio con dos decimales. Deben figurar todas las asignaturas.

<details>
<summary>Ver solución</summary>

```sql
CREATE VIEW v_resumen_asignatura AS
SELECT a.nombre               AS asignatura,
       d.apellido             AS docente,
       COUNT(i.id_estudiante) AS inscriptos,
       ROUND(AVG(i.nota), 2)  AS promedio
FROM asignatura AS a
INNER JOIN docente    AS d ON d.id_docente = a.id_docente
LEFT JOIN inscripcion AS i ON i.id_asignatura = a.id_asignatura
GROUP BY a.id_asignatura, a.nombre, d.apellido;
```


💡 "Todas las asignaturas" pide `LEFT JOIN` y `COUNT` sobre una columna de `inscripcion`.
</details>

**4.** Usando `v_resumen_asignatura`, mostrá las asignaturas con promedio menor que 7 o sin inscriptos.

<details>
<summary>Ver solución</summary>

```sql
SELECT asignatura, docente, inscriptos, promedio
FROM v_resumen_asignatura
WHERE promedio < 7
   OR inscriptos = 0
ORDER BY asignatura;
```

| asignatura | docente | inscriptos | promedio |
| ---------- | ------- | ---------- | -------- |
| Filosofía | Sosa | 0 | NULL |
| Física | Méndez | 3 | 5.33 |
| Química | Olivera | 3 | 6.83 |

💡 `promedio < 7` solo no trae a Filosofía: su promedio es `NULL` y ninguna comparación con `NULL` es verdadera.
</details>

**5.** Creá la vista `v_pendientes` con nombre y apellido del estudiante y nombre de la asignatura de todas las inscripciones que todavía no tienen nota. Reutilizá `v_notas`.

<details>
<summary>Ver solución</summary>

```sql
CREATE VIEW v_pendientes AS
SELECT nombre, apellido, asignatura
FROM v_notas
WHERE nota IS NULL;
```


💡 Una vista puede apoyarse en otra. Con un nivel de anidamiento sigue siendo fácil de leer.
</details>

**6.** Consultá `v_pendientes` ordenada por asignatura y apellido.

<details>
<summary>Ver solución</summary>

```sql
SELECT asignatura, nombre, apellido
FROM v_pendientes
ORDER BY asignatura, apellido;
```

| asignatura | nombre | apellido |
| ---------- | ------ | -------- |
| Historia | Joaquín | Martínez |
| Programación | Santiago | Pérez |
| Programación | Martina | Suárez |

💡 Cuando se cargue una de esas notas, la fila desaparece sola de la vista.
</details>

**7.** Eliminá las tres vistas creadas en estos ejercicios.

<details>
<summary>Ver solución</summary>

```sql
DROP VIEW v_estudiante_grupo, v_resumen_asignatura, v_pendientes;
```

💡 `DROP VIEW` acepta varias vistas separadas por coma. Las tablas no se modifican.
</details>

---

## 📋 Palabras clave

`vista` · `tabla virtual` · `CREATE VIEW` · `CREATE OR REPLACE VIEW` · `DROP VIEW` · `SHOW FULL TABLES` · `consulta guardada` · `vista actualizable` · `alias de columna` · `reutilización` · `seguridad` · `Error 1356` · `Error 1288`

---

🧠 **[Autoevaluación — Módulo 8](auto-modulo8)**

---

← [UNION: Combinar resultados](UNION) · [🏠 Inicio](Home) · [Resumen del Módulo 8 →](Resumen-Modulo8)
