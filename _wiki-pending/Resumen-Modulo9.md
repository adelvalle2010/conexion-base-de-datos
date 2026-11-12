> 🗄️ **Base de datos:** `liceo_grande` (Módulo 9 — Rendimiento y Transacciones) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo9/liceo_grande.sql)

## Resumen

En este módulo hemos visto cómo lograr que una base siga respondiendo rápido cuando crece y siga diciendo la verdad cuando la usan muchos a la vez. Los conceptos principales que trabajamos fueron:

- **Índice**: copia ordenada de una o más columnas, con la ubicación de cada fila. Evita recorrer toda la tabla.
- **Índice compuesto**: sobre varias columnas; sirve para condiciones que empiezan por la primera (prefijo izquierdo).
- **Selectividad**: un índice rinde cuando la condición deja pasar pocas filas.
- **`EXPLAIN`**: muestra el plan de ejecución sin ejecutar la consulta. Las columnas que más importan son `type`, `key`, `rows` y `Extra`.
- **Transacción**: grupo de sentencias que se aplican todas (`COMMIT`) o ninguna (`ROLLBACK`).
- **ACID**: atomicidad, consistencia, aislamiento y durabilidad.
- **Bloqueo**: marca sobre una fila que hace esperar a las demás transacciones que quieran modificarla.
- **Nivel de aislamiento**: cuánto ve una transacción de lo que confirman las demás. En MySQL, `REPEATABLE READ` por defecto.
- **Interbloqueo**: dos transacciones que se esperan mutuamente; MySQL deshace una.

## 🧾 Sintaxis de un vistazo

| Sentencia / Cláusula | Para qué sirve | Ejemplo |
| -------------------- | -------------- | ------- |
| `CREATE INDEX` | Crear un índice | `CREATE INDEX idx_estudiante_fecha ON estudiante (fecha_nacimiento);` |
| Índice compuesto | Indexar varias columnas | `CREATE INDEX idx_estudiante_apellido_nombre ON estudiante (apellido, nombre);` |
| `CREATE UNIQUE INDEX` | Índice sin repetidos | `CREATE UNIQUE INDEX uq_docente_nombre_apellido ON docente (nombre, apellido);` |
| `SHOW INDEX` | Listar índices | `SHOW INDEX FROM estudiante;` |
| `DROP INDEX` | Eliminar un índice | `DROP INDEX idx_estudiante_fecha ON estudiante;` |
| `EXPLAIN` | Ver el plan, sin ejecutar | `EXPLAIN SELECT * FROM estudiante WHERE apellido = 'Núñez';` |
| `EXPLAIN ANALYZE` | Ejecutar y ver filas y tiempos reales | `EXPLAIN ANALYZE SELECT …;` |
| `ANALYZE TABLE` | Actualizar las estadísticas | `ANALYZE TABLE estudiante;` |
| `START TRANSACTION` | Abrir una transacción | `START TRANSACTION;` |
| `COMMIT` / `ROLLBACK` | Confirmar / deshacer | `COMMIT;` |
| `SAVEPOINT` / `ROLLBACK TO` | Punto intermedio / volver a él | `SAVEPOINT uno;` · `ROLLBACK TO uno;` |
| `SELECT … FOR UPDATE` | Leer bloqueando, para modificar después | `SELECT nota FROM inscripcion WHERE … FOR UPDATE;` |
| `SET … ISOLATION LEVEL` | Cambiar el nivel de aislamiento | `SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;` |

## Cómo leer un EXPLAIN en 20 segundos

| Mirar | Buena señal | Señal de alerta |
| ----- | ----------- | --------------- |
| `type` | `const`, `eq_ref`, `ref`, `range` | `ALL` en una tabla grande |
| `key` | El nombre de un índice | `NULL` |
| `rows` | Parecido a la cantidad de filas que devuelve la consulta | Miles de veces más |
| `Extra` | `Using index` | `Using filesort` o `Using temporary` con muchas filas |

## Por qué un índice puede no usarse

| Situación | Ejemplo | Alternativa |
| --------- | ------- | ----------- |
| Función sobre la columna | `WHERE YEAR(fecha_nacimiento) = 2009` | `WHERE fecha_nacimiento BETWEEN '2009-01-01' AND '2009-12-31'` |
| `LIKE` que empieza con `%` | `WHERE apellido LIKE '%ez'` | `LIKE 'Nú%'`, si la búsqueda lo permite |
| Falta la primera columna del índice | `WHERE nombre = 'Sofía'` con índice `(apellido, nombre)` | Un índice que empiece por `nombre` |
| Condición poco selectiva | Trae la sexta parte de la tabla | Ninguna: recorrer la tabla es lo correcto |

## Transacciones: reglas prácticas

1. **Cortas**: abrir, modificar, confirmar. Nunca esperar al usuario con la transacción abierta.
2. Ante un error dentro de la transacción, **`ROLLBACK`**: MySQL no lo hace solo.
3. No mezclar `CREATE`, `ALTER`, `DROP` ni `TRUNCATE`: confirman todo lo anterior.
4. Para "leer, calcular y guardar": `SELECT … FOR UPDATE`, o hacer el cálculo dentro del `UPDATE`.
5. Modificar las filas **siempre en el mismo orden** para evitar interbloqueos.

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño | Diagrama E-R, tablas y normalización | Módulos 1 a 3 ✅ |
| Implementación | Base `liceo` con estructura y datos | Módulos 4 a 6 ✅ |
| Consulta | De una tabla a `JOIN`, subconsultas y vistas | Módulos 7 y 8 ✅ |
| Rendimiento e integridad | Índices, `EXPLAIN`, transacciones y concurrencia | Módulo 9 ✅ |
| Programación en el servidor | Procedimientos, funciones y triggers | Módulo 10 |

De esta manera, la base del liceo ya es rápida y confiable. Pero operaciones como el cambio de asignatura siguen dependiendo de que alguien escriba bien, cada vez, las cuatro sentencias de la transacción. En el próximo módulo guardamos esa lógica **dentro de la base**, con un nombre, para ejecutarla con una sola línea.

---

## 📋 Palabras clave

`índice` · `índice compuesto` · `prefijo izquierdo` · `selectividad` · `EXPLAIN` · `plan de ejecución` · `type` · `transacción` · `COMMIT` · `ROLLBACK` · `ACID` · `bloqueo` · `nivel de aislamiento` · `REPEATABLE READ` · `interbloqueo` · `FOR UPDATE`

---

🧠 **[Autoevaluación — Módulo 9](auto-modulo9)**

---

← [Concurrencia y bloqueos](Concurrencia-y-bloqueos) · [🏠 Inicio](Home) · [Procedimientos almacenados →](Procedimientos-almacenados)
