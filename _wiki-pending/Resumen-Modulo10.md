> 🗄️ **Base de datos:** `liceo_programado` (Módulo 10 — Programación en el Servidor) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo10/liceo_programado.sql)

## Resumen

En este módulo hemos visto cómo guardar lógica dentro de la base de datos, para que las operaciones, los cálculos y las reglas del liceo estén escritos una sola vez. Los conceptos principales que trabajamos fueron:

- **Procedimiento almacenado**: sentencias guardadas con un nombre, que se ejecutan con `CALL`. Reciben parámetros `IN` y devuelven datos por parámetros `OUT` o mostrando resultados.
- **Función almacenada**: rutina que devuelve **un valor** y se usa dentro de las consultas.
- **Trigger**: código que MySQL ejecuta solo, antes o después de un `INSERT`, `UPDATE` o `DELETE` sobre una tabla.
- **`DELIMITER`**: instrucción para Workbench que permite escribir cuerpos con varios `;`.
- **Variables**: locales (`DECLARE v_x`), de usuario (`@x`) y parámetros (`p_x`).
- **Control de flujo**: `IF … ELSEIF … ELSE … END IF` y `WHILE … DO … END WHILE`.
- **Errores**: `SIGNAL` para lanzar un error propio y `DECLARE … HANDLER` para reaccionar ante uno.
- **`OLD` y `NEW`**: la fila antes y después del cambio, dentro de un trigger.

El script `liceo_programado.sql` crea una base con todo lo construido en las tres páginas:

| Tipo | Objetos |
| ---- | ------- |
| Tabla | `auditoria_nota` |
| Procedimientos | `sp_listar_grupos` · `sp_notas_estudiante` · `sp_promedio_estudiante` · `sp_inscribir` · `sp_cambiar_asignatura` · `sp_crear_grupos` |
| Funciones | `fn_nombre_completo` · `fn_calificacion` · `fn_edad_al` · `fn_promedio_estudiante` |
| Triggers | `trg_inscripcion_after_update` · `trg_estudiante_before_insert` · `trg_inscripcion_before_insert` · `trg_inscripcion_after_delete` |

## 🧾 Sintaxis de un vistazo

| Sentencia / Cláusula | Para qué sirve | Ejemplo |
| -------------------- | -------------- | ------- |
| `DELIMITER` | Cambiar el terminador en el cliente | `DELIMITER $$` … `END$$` … `DELIMITER ;` |
| `CREATE PROCEDURE` | Crear un procedimiento | `CREATE PROCEDURE sp_inscribir(IN p_id INT, …) BEGIN … END` |
| `CALL` | Ejecutar un procedimiento | `CALL sp_cambiar_asignatura(2, 13, 11);` |
| `CREATE FUNCTION` | Crear una función | `CREATE FUNCTION fn_calificacion(p_nota DECIMAL(4,2)) RETURNS VARCHAR(15) DETERMINISTIC BEGIN … END` |
| `RETURN` | Devolver el valor de la función | `RETURN CONCAT(p_apellido, ', ', p_nombre);` |
| `CREATE TRIGGER` | Crear un trigger | `CREATE TRIGGER trg_… AFTER UPDATE ON inscripcion FOR EACH ROW BEGIN … END` |
| `DECLARE` / `SET` | Variable local y asignación | `DECLARE v_i INT DEFAULT 1;` · `SET v_i = v_i + 1;` |
| `SELECT … INTO` | Guardar el resultado de una consulta | `SELECT COUNT(*) INTO v_cantidad FROM …;` |
| `IF` | Decidir | `IF v_cantidad >= 4 THEN … END IF;` |
| `WHILE` | Repetir | `WHILE v_i <= p_cantidad DO … END WHILE;` |
| `SIGNAL` | Lanzar un error propio | `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '…';` |
| `HANDLER` | Reaccionar ante un error | `DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;` |
| `SHOW … STATUS` / `SHOW TRIGGERS` | Listar | `SHOW PROCEDURE STATUS WHERE Db = 'liceo';` |
| `DROP … IF EXISTS` | Eliminar | `DROP FUNCTION IF EXISTS fn_edad_al;` |

## ¿Qué herramienta para qué necesidad?

| Necesito… | Herramienta | Ejemplo del módulo |
| --------- | ----------- | ------------------ |
| Ejecutar una operación de varios pasos, con transacción | Procedimiento | `sp_cambiar_asignatura` |
| Devolver una lista según parámetros | Procedimiento | `sp_notas_estudiante` |
| Un cálculo o un formato que se repite en muchas consultas | Función | `fn_nombre_completo`, `fn_calificacion` |
| Guardar automáticamente quién cambió qué | Trigger `AFTER` | `trg_inscripcion_after_update` |
| Corregir los datos al entrar | Trigger `BEFORE` | `trg_estudiante_before_insert` |
| Una regla que un `CHECK` no puede expresar | Trigger `BEFORE` con `SIGNAL` | `trg_inscripcion_before_insert` |
| Que una columna no quede vacía, repetida o fuera de rango | Restricción, **no** trigger | `NOT NULL`, `UNIQUE`, `CHECK` |

## Reglas prácticas

1. Prefijos: `sp_` procedimientos, `fn_` funciones, `trg_` triggers, `p_` parámetros, `v_` variables. Un parámetro **nunca** se llama igual que una columna.
2. Todo script empieza con `DROP … IF EXISTS` y se guarda en un archivo `.sql`: el código que solo vive en el servidor se pierde.
3. En un procedimiento con transacción, siempre un `HANDLER` que haga `ROLLBACK`.
4. Las funciones que leen tablas se ejecutan una vez por fila: con cuidado en consultas grandes.
5. Los triggers, pocos y simples. Lo que hacen no se ve desde afuera.

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño | Diagrama E-R, tablas y normalización | Módulos 1 a 3 ✅ |
| Implementación | Base `liceo` con estructura y datos | Módulos 4 a 6 ✅ |
| Consulta | De una tabla a `JOIN`, subconsultas y vistas | Módulos 7 y 8 ✅ |
| Rendimiento e integridad | Índices, `EXPLAIN`, transacciones y concurrencia | Módulo 9 ✅ |
| Programación en el servidor | Procedimientos, funciones y triggers | Módulo 10 ✅ |
| Administración | Usuarios, permisos, respaldo y restauración | Módulo 11 |

De esta manera, la base del liceo ya sabe **hacer** cosas, no solo guardarlas. Pero hasta ahora trabajamos siempre como `root`, el usuario que puede todo, y con una única copia de los datos. En el próximo módulo vemos cómo decidir **quién** puede hacer **qué**, y cómo recuperar la base si algo sale mal.

---

## 📋 Palabras clave

`procedimiento almacenado` · `función almacenada` · `trigger` · `DELIMITER` · `CALL` · `RETURNS` · `IN / OUT` · `DECLARE` · `IF` · `WHILE` · `SIGNAL` · `HANDLER` · `OLD / NEW` · `BEFORE / AFTER` · `auditoría`

---

🧠 **[Autoevaluación — Módulo 10](auto-modulo10)**

---

← [Triggers](Triggers) · [🏠 Inicio](Home) · [Usuarios y permisos →](Usuarios-y-permisos)
