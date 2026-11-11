> 🗄️ **Base de datos:** `liceo` (Módulo 7 — Consultas Básicas) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

## Resumen

En este módulo hemos visto cómo consultar una tabla: elegir columnas, filtrar filas, ordenar el resultado y recortarlo. Los conceptos principales que trabajamos fueron:

- **`SELECT … FROM`**: elige qué columnas mostrar y de qué tabla. Con `AS` se les pone alias y con `DISTINCT` se quitan los repetidos.
- **`WHERE`**: deja pasar solo las filas que cumplen una condición.
- **Operadores lógicos**: `AND` (todas), `OR` (alguna), `NOT` (lo contrario). `AND` se evalúa antes que `OR`; los paréntesis mandan.
- **Operadores especiales**: `LIKE` (patrones), `IN` (listas), `BETWEEN` (rangos, con los extremos incluidos), `IS NULL` (dato faltante).
- **`ORDER BY`**: ordena el resultado; sin él, el orden no está garantizado.
- **`LIMIT`**: se queda con las primeras filas; con `OFFSET` se pagina.

## 🧾 Sintaxis de un vistazo

| Sentencia / Cláusula | Para qué sirve | Ejemplo |
| -------------------- | -------------- | ------- |
| `SELECT *` | Todas las columnas | `SELECT * FROM grupo;` |
| `SELECT a, b` | Algunas columnas | `SELECT nombre, apellido FROM estudiante;` |
| `AS` | Alias de columna | `SELECT nombre AS asignatura FROM asignatura;` |
| `DISTINCT` | Sin repetidos | `SELECT DISTINCT turno FROM grupo;` |
| `WHERE` | Filtrar filas | `WHERE id_grupo = 1` |
| `AND` / `OR` / `NOT` | Combinar condiciones | `WHERE (id_grupo = 1 OR id_grupo = 2) AND …` |
| `LIKE` | Patrón de texto | `WHERE apellido LIKE '%ez'` |
| `IN` | Uno de una lista | `WHERE id_asignatura IN (12, 13)` |
| `BETWEEN` | Dentro de un rango | `WHERE nota BETWEEN 6 AND 9` |
| `IS NULL` | Dato faltante | `WHERE nota IS NULL` |
| `ORDER BY` | Ordenar | `ORDER BY apellido, nombre DESC` |
| `LIMIT` / `OFFSET` | Recortar y paginar | `LIMIT 3` · `LIMIT 4 OFFSET 4` |

## El orden de las cláusulas

```text
Se escribe:   SELECT ─▶ FROM ─▶ WHERE ─▶ ORDER BY ─▶ LIMIT
Se ejecuta:   FROM ─▶ WHERE ─▶ SELECT ─▶ ORDER BY ─▶ LIMIT
```

Una consulta que usa todo lo del módulo. Las tres mejores notas de Matemática y Programación:

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE id_asignatura IN (10, 14)
  AND nota IS NOT NULL
ORDER BY nota DESC, id_estudiante
LIMIT 3;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 5 | 10 | 12.00 |
| 1 | 14 | 11.00 |
| 7 | 10 | 10.00 |

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño | Diagrama E-R, tablas y normalización | Módulos 1 a 3 ✅ |
| Implementación | Base `liceo` con estructura y datos | Módulos 4 a 6 ✅ |
| Consulta de una tabla | Elegir, filtrar, ordenar y recortar | Módulo 7 ✅ |
| Consulta avanzada | Resumir datos y combinar tablas | Módulo 8 |

De esta manera, ya podemos responder cualquier pregunta que se conteste **mirando una sola tabla, fila por fila**. Pero el resultado de arriba muestra el límite: dice "estudiante 5", no "Camila González", y no sabemos el promedio de nadie. En el próximo módulo aprendemos a **resumir** muchas filas en un número y a **unir** tablas para ver nombres en lugar de identificadores.

---

## 📋 Palabras clave

`SELECT` · `FROM` · `WHERE` · `AND` · `OR` · `LIKE` · `IN` · `BETWEEN` · `IS NULL` · `ORDER BY` · `LIMIT` · `DISTINCT` · `alias` · `orden de ejecución`

---

🧠 **[Autoevaluación — Módulo 7](auto-modulo7)**

---

← [ORDER BY y LIMIT](ORDER-BY-y-LIMIT) · [🏠 Inicio](Home) · [Funciones de Agrupación (SUM, COUNT, AVG) →](Funciones-de-agrupacion)
