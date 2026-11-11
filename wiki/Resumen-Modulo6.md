> 🗄️ **Base de datos:** `liceo` (Módulo 6 — Manipulación de Datos) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo6/liceo_dml.sql)

## Resumen

En este módulo hemos visto cómo trabajar con las filas de una tabla usando el lenguaje de manipulación de datos (DML). Los conceptos principales que trabajamos fueron:

- **`INSERT`**: agrega filas. Conviene indicar siempre la lista de columnas; las que se omiten reciben su `AUTO_INCREMENT`, su `DEFAULT` o `NULL`.
- **`UPDATE`**: cambia valores de filas existentes. El `WHERE` decide cuáles.
- **`DELETE`**: elimina filas completas. El `WHERE` decide cuáles.
- **Restricciones en acción**: cada `INSERT`, `UPDATE` y `DELETE` se comprueba contra las PK, FK, `UNIQUE`, `NOT NULL` y `CHECK` definidas en el Módulo 5.
- **Orden**: se carga de las tablas padre a las hijas, y se borra en el sentido contrario.
- **Modo seguro**: Workbench rechaza los `UPDATE` y `DELETE` que no filtran por una columna clave.

## 🧾 Sintaxis de un vistazo

| Sentencia / Cláusula | Para qué sirve | Ejemplo |
| -------------------- | -------------- | ------- |
| `INSERT INTO … VALUES` | Agregar una fila | `INSERT INTO grupo (nombre, turno) VALUES ('3ºA', 'matutino');` |
| `VALUES (…), (…)` | Agregar varias filas | `INSERT INTO grupo (nombre) VALUES ('2ºA'), ('2ºB');` |
| `UPDATE … SET … WHERE` | Cambiar valores | `UPDATE grupo SET turno = 'nocturno' WHERE id_grupo = 4;` |
| `SET a = …, b = …` | Cambiar varias columnas | `UPDATE estudiante SET nombre = 'Agustín', apellido = 'Núñez' WHERE id_estudiante = 10;` |
| `SET col = col + 1` | Calcular sobre el valor actual | `UPDATE inscripcion SET nota = nota + 1 WHERE …;` |
| `DELETE FROM … WHERE` | Eliminar filas | `DELETE FROM asignatura WHERE id_asignatura = 16;` |
| `SET SQL_SAFE_UPDATES` | Activar o desactivar el modo seguro | `SET SQL_SAFE_UPDATES = 0;` |

## Las tres reglas de oro

1. **`UPDATE` y `DELETE` siempre llevan `WHERE`.** Sin él, afectan a toda la tabla.
2. **Primero `SELECT`, después cambiar.** El mismo `WHERE`, para ver qué filas se van a tocar.
3. **Filtrar por la clave primaria** siempre que se quiera afectar una sola fila.

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño | Diagrama E-R, tablas y normalización | Módulos 1 a 3 ✅ |
| Entorno | Servidor y Workbench funcionando | Módulo 4 ✅ |
| Implementación: estructura | Base `liceo` con 5 tablas | Módulo 5 ✅ |
| Implementación: datos | 4 grupos, 5 docentes, 6 asignaturas, 10 estudiantes, 21 inscripciones | Módulo 6 ✅ |
| Consulta | Preguntarle cosas a la base | Módulos 7 y 8 |

De esta manera, hemos dejado la base del liceo completa: con estructura, con reglas y con datos. Hasta ahora usamos `SELECT *` solo para espiar el resultado; en el próximo módulo lo estudiamos de verdad, porque consultar es lo que más se hace con una base de datos.

---

## 📋 Palabras clave

`DML` · `INSERT` · `UPDATE` · `DELETE` · `VALUES` · `SET` · `WHERE` · `AUTO_INCREMENT` · `DEFAULT` · `NULL` · `CASCADE` · `RESTRICT` · `modo seguro` · `integridad referencial`

---

🧠 **[Autoevaluación — Módulo 6](auto-modulo6)**

---

← [DELETE: Eliminar registros](DELETE-eliminar-registros) · [🏠 Inicio](Home) · [SELECT: Sintaxis básica →](SELECT-sintaxis-basica)
