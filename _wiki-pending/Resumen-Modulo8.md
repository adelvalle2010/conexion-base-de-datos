> 🗄️ **Base de datos:** `liceo` (Módulo 8 — Consultas Avanzadas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

## Resumen

En este módulo hemos visto cómo obtener información que no está escrita en ninguna fila: resúmenes, combinaciones de tablas y consultas que se apoyan en otras consultas. Los conceptos principales que trabajamos fueron:

- **Funciones de agrupación**: `COUNT`, `SUM`, `AVG`, `MAX` y `MIN` convierten muchas filas en un valor. Todas ignoran los `NULL`, salvo `COUNT(*)`.
- **`GROUP BY`**: calcula el resumen una vez por cada grupo. En el `SELECT` solo van las columnas de agrupación y las funciones.
- **`HAVING`**: filtra grupos ya armados; `WHERE` filtra filas antes de agrupar.
- **`INNER JOIN`**: une tablas por FK = PK y devuelve solo las filas con coincidencia.
- **`LEFT JOIN` / `RIGHT JOIN`**: conservan también las filas sin pareja de un lado, completando con `NULL`.
- **Subconsultas**: un `SELECT` dentro de otro; puede devolver un valor, una lista o una tabla.
- **`UNION`**: apila los resultados de varias consultas; `UNION ALL` conserva los repetidos.
- **Vistas**: consultas guardadas con nombre, que se usan como tablas y siempre están al día.

## 🧾 Sintaxis de un vistazo

| Sentencia / Cláusula | Para qué sirve | Ejemplo |
| -------------------- | -------------- | ------- |
| `COUNT(*)` | Contar filas | `SELECT COUNT(*) FROM estudiante;` |
| `COUNT(columna)` | Contar valores no nulos | `SELECT COUNT(nota) FROM inscripcion;` |
| `COUNT(DISTINCT columna)` | Contar valores diferentes | `COUNT(DISTINCT id_estudiante)` |
| `SUM` / `AVG` | Suma y promedio | `ROUND(AVG(nota), 2)` |
| `MAX` / `MIN` | Mayor y menor | `MAX(nota)`, `MIN(fecha_nacimiento)` |
| `GROUP BY` | Un resumen por grupo | `GROUP BY id_asignatura` |
| `HAVING` | Filtrar grupos | `HAVING AVG(nota) >= 8` |
| `INNER JOIN … ON` | Unir tablas (solo coincidencias) | `INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo` |
| `LEFT JOIN … ON` | Unir conservando la tabla izquierda | `LEFT JOIN inscripcion AS i ON …` |
| `LEFT JOIN … IS NULL` | Los que no tienen pareja | `WHERE i.id_estudiante IS NULL` |
| Subconsulta escalar | Comparar con un valor calculado | `WHERE nota > (SELECT AVG(nota) FROM inscripcion)` |
| `IN (SELECT …)` | Comparar con una lista calculada | `WHERE id_estudiante IN (SELECT …)` |
| `EXISTS (SELECT …)` | ¿Hay alguna fila relacionada? | `WHERE NOT EXISTS (SELECT 1 FROM …)` |
| Tabla derivada | Consultar el resultado de una consulta | `FROM (SELECT …) AS t` |
| `UNION` / `UNION ALL` | Apilar resultados | `SELECT … UNION ALL SELECT …` |
| `CREATE VIEW` | Guardar una consulta | `CREATE VIEW v_notas AS SELECT …;` |

## El orden de las cláusulas

```text
Se escribe:   SELECT ─▶ FROM/JOIN ─▶ WHERE ─▶ GROUP BY ─▶ HAVING ─▶ ORDER BY ─▶ LIMIT
Se ejecuta:   FROM/JOIN ─▶ WHERE ─▶ GROUP BY ─▶ HAVING ─▶ SELECT ─▶ ORDER BY ─▶ LIMIT
```

## ¿Qué herramienta para qué pregunta?

| La consigna dice… | Herramienta |
| ----------------- | ----------- |
| "cuántos", "promedio", "total", "el mayor" | Función de agrupación |
| "por cada", "de cada", "por grupo" | `GROUP BY` |
| "los grupos que tienen más de…" | `HAVING` |
| "con el nombre de…" (dato de otra tabla) | `INNER JOIN` |
| "todos, aunque no tengan…" | `LEFT JOIN` |
| "los que no tienen…", "sin…" | `LEFT JOIN … IS NULL` o `NOT EXISTS` |
| "mayor que el promedio", "igual al máximo" | Subconsulta |
| "en una sola lista" (tablas sin relación) | `UNION` |
| "esto lo consulto todos los días" | Vista |

Una consulta que usa casi todo lo del módulo. Los estudiantes con promedio mayor que el promedio general del liceo, con su grupo:

```sql
SELECT e.nombre, e.apellido,
       g.nombre              AS grupo,
       COUNT(i.nota)         AS notas,
       ROUND(AVG(i.nota), 2) AS promedio
FROM estudiante AS e
INNER JOIN grupo       AS g ON g.id_grupo = e.id_grupo
INNER JOIN inscripcion AS i ON i.id_estudiante = e.id_estudiante
GROUP BY e.id_estudiante, e.nombre, e.apellido, g.nombre
HAVING AVG(i.nota) > (SELECT AVG(nota)
                      FROM inscripcion)
ORDER BY promedio DESC;
```

**Resultado:**

| nombre | apellido | grupo | notas | promedio |
| ------ | -------- | ----- | ----- | -------- |
| Camila | González | 3ºB | 3 | 9.83 |
| Sofía | López | 2ºA | 2 | 9.50 |
| Lucía | Fernández | 3ºA | 3 | 9.17 |
| Valentina | Rodríguez | 3ºA | 2 | 8.25 |

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño | Diagrama E-R, tablas y normalización | Módulos 1 a 3 ✅ |
| Implementación | Base `liceo` con estructura y datos | Módulos 4 a 6 ✅ |
| Consulta de una tabla | Elegir, filtrar, ordenar y recortar | Módulo 7 ✅ |
| Consulta avanzada | Resumir, unir tablas, subconsultas y vistas | Módulo 8 ✅ |
| Rendimiento y seguridad de los datos | Índices, `EXPLAIN` y transacciones | Módulo 9 |

De esta manera, cerramos la **Parte 2**: ya podemos responder prácticamente cualquier pregunta sobre los datos del liceo. Todas nuestras consultas son instantáneas porque la base tiene 10 estudiantes. Con 100.000, algunas tardarían segundos o minutos. En el próximo módulo vemos cómo hace MySQL para encontrar una fila sin recorrer toda la tabla, y qué pasa cuando dos personas modifican los mismos datos a la vez.

---

## 📋 Palabras clave

`COUNT` · `SUM` · `AVG` · `MAX` · `MIN` · `GROUP BY` · `HAVING` · `INNER JOIN` · `LEFT JOIN` · `RIGHT JOIN` · `subconsulta` · `EXISTS` · `tabla derivada` · `UNION` · `vista` · `orden de ejecución`

---

🧠 **[Autoevaluación — Módulo 8](auto-modulo8)**

---

← [Vistas](Vistas) · [🏠 Inicio](Home) · [Índices →](Indices)
