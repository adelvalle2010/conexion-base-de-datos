> 🗄️ **Base de datos:** `liceo` (Módulo 5 — Definición de Datos) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo5/liceo_ddl.sql)

## Resumen

En este módulo hemos visto cómo pasar del diseño en papel a una base de datos real, usando el lenguaje de definición de datos (DDL). Los conceptos principales que trabajamos fueron:

- **`CREATE DATABASE` y `CREATE TABLE`**: crean la base y la estructura de cada tabla, con sus columnas y tipos.
- **Clave primaria**: identifica cada fila; no se repite ni admite `NULL`. Puede ser compuesta.
- **Clave foránea**: obliga a que un valor exista en otra tabla; con `ON DELETE` se decide qué pasa al borrar la fila referenciada.
- **Restricciones**: `NOT NULL` (obligatorio), `UNIQUE` (sin repetidos), `DEFAULT` (valor si no se indica) y `CHECK` (cumple una condición).
- **`ALTER TABLE`**: cambia una tabla que ya existe.
- **`TRUNCATE` y `DROP`**: vacían o eliminan una tabla, sin vuelta atrás.

## 🧾 Sintaxis de un vistazo

| Sentencia / Cláusula | Para qué sirve | Ejemplo |
| -------------------- | -------------- | ------- |
| `CREATE DATABASE` | Crear una base | `CREATE DATABASE liceo;` |
| `USE` | Elegir la base activa | `USE liceo;` |
| `CREATE TABLE` | Crear una tabla | `CREATE TABLE grupo ( ... );` |
| `DESCRIBE` | Ver la estructura de una tabla | `DESCRIBE estudiante;` |
| `PRIMARY KEY` | Identificar cada fila | `CONSTRAINT pk_grupo PRIMARY KEY (id_grupo)` |
| `FOREIGN KEY … REFERENCES` | Relacionar con otra tabla | `FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)` |
| `NOT NULL` | Dato obligatorio | `nombre VARCHAR(50) NOT NULL` |
| `UNIQUE` | Sin repetidos | `CONSTRAINT uq_grupo_nombre UNIQUE (nombre)` |
| `DEFAULT` | Valor por defecto | `turno VARCHAR(10) NOT NULL DEFAULT 'matutino'` |
| `CHECK` | Condición sobre el valor | `CHECK (nota BETWEEN 1 AND 12)` |
| `ALTER TABLE … ADD COLUMN` | Agregar una columna | `ALTER TABLE estudiante ADD COLUMN id_grupo INT NOT NULL;` |
| `ALTER TABLE … DROP COLUMN` | Eliminar una columna | `ALTER TABLE estudiante DROP COLUMN grupo;` |
| `TRUNCATE TABLE` | Vaciar una tabla | `TRUNCATE TABLE prueba;` |
| `DROP TABLE` | Eliminar una tabla | `DROP TABLE IF EXISTS prueba;` |

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño | Diagrama E-R, tablas y normalización | Módulos 1 a 3 ✅ |
| Entorno | Servidor y Workbench funcionando | Módulo 4 ✅ |
| Implementación: estructura | Base `liceo` con 5 tablas y sus restricciones | Módulo 5 ✅ |
| Implementación: datos | Cargar, modificar y borrar filas | Módulo 6 |
| Consulta | Preguntarle cosas a la base | Módulos 7 y 8 |

La base quedó así:

```text
docente(id_docente PK, nombre, apellido)
grupo(id_grupo PK, nombre, turno)
estudiante(id_estudiante PK, nombre, apellido, fecha_nacimiento, id_grupo FK → grupo)
asignatura(id_asignatura PK, nombre, id_docente FK → docente)
inscripcion(id_estudiante PK/FK → estudiante, id_asignatura PK/FK → asignatura, nota)
```

De esta manera, hemos construido las cinco tablas del liceo con reglas que impiden guardar datos incoherentes. Pero siguen vacías: en el próximo módulo empezamos a cargar grupos, docentes, estudiantes y notas con `INSERT`.

---

## 📋 Palabras clave

`DDL` · `CREATE` · `ALTER` · `DROP` · `TRUNCATE` · `PRIMARY KEY` · `FOREIGN KEY` · `NOT NULL` · `UNIQUE` · `DEFAULT` · `CHECK` · `AUTO_INCREMENT` · `integridad referencial` · `DESCRIBE`

---

🧠 **[Autoevaluación — Módulo 5](auto-modulo5)**

---

← [ALTER, DROP y TRUNCATE](ALTER-DROP-y-TRUNCATE) · [🏠 Inicio](Home) · [INSERT: Insertar registros →](INSERT-insertar-registros)
