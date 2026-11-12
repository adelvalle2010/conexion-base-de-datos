# 🚨 Anexo: Errores frecuentes de MySQL

Casi todos los errores de MySQL traen un **número** y un **mensaje** que dicen exactamente qué pasó. Esta página junta los que más aparecen en el curso, con el error **real** que devuelve el motor y cómo resolverlo.

> 🗒️ Consejo general: leé siempre el **número de error** y la **línea** que marca Workbench. El mensaje casi siempre nombra la tabla, la columna o la restricción que falló.

---

## Tabla resumen

| Código | Síntoma | Causa | Solución |
| ------ | ------- | ----- | -------- |
| **1146** | *Table doesn't exist* | Nombre de tabla mal escrito o base equivocada | Revisar el nombre y haber hecho `USE liceo;` |
| **1054** | *Unknown column* | Columna mal escrita o alias inexistente | Revisar el nombre de la columna |
| **1062** | *Duplicate entry* | Valor repetido en una `PRIMARY KEY` o `UNIQUE` | Usar un valor distinto |
| **1452** | *Cannot add or update a child row* | FK que apunta a una fila que no existe | Insertar primero la fila "padre" |
| **1364** | *Field doesn't have a default value* | Falta un campo `NOT NULL` en el `INSERT` | Incluir todas las columnas obligatorias |
| **3819** | *Check constraint is violated* | Un valor rompe un `CHECK` | Usar un valor dentro del rango permitido |
| **1064** | *Syntax error* | Error de escritura en la sentencia | Revisar palabras reservadas, comas y `;` |

---

## Los errores, en vivo

### 1146 — la tabla no existe
```sql
SELECT * FROM estudiantes;   -- la tabla se llama "estudiante", en singular
```
```text
Error Code: 1146. Table 'biblioteca_liceo.estudiantes' doesn't exist
```

> 📌 En este curso las tablas van **en singular**: `estudiante`, `libro`, `prestamo`.

### 1054 — columna desconocida
```sql
SELECT titulo, año FROM libro;   -- la columna es "anio", sin ñ
```
```text
Error Code: 1054. Unknown column 'año' in 'field list'
```

### 1062 — valor duplicado
```sql
INSERT INTO categoria (nombre) VALUES ('Novela');   -- 'Novela' ya existe (UNIQUE)
```
```text
Error Code: 1062. Duplicate entry 'Novela' for key 'categoria.uq_categoria_nombre'
```

La categoría *Novela* ya estaba y `nombre` tiene una restricción `UNIQUE`.

### 1452 — clave foránea sin padre
```sql
INSERT INTO prestamo (id_ejemplar, id_estudiante, fecha_prestamo, fecha_devolucion_pactada)
VALUES (1, 999, '2026-05-01', '2026-05-15');   -- no existe el estudiante 999
```
```text
Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`biblioteca_liceo`.`prestamo`, CONSTRAINT `fk_prestamo_estudiante` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiante` (`id_estudiante`))
```

No se puede prestar a un estudiante que no existe: la FK `fk_prestamo_estudiante` lo impide.

### 1364 — falta un campo obligatorio
```sql
INSERT INTO estudiante (nombre, apellido) VALUES ('Juan', 'Pérez');   -- falta id_grupo (NOT NULL)
```
```text
Error Code: 1364. Field 'id_grupo' doesn't have a default value
```

### 3819 — se viola un CHECK
```sql
INSERT INTO libro (titulo, anio, id_categoria) VALUES ('Libro raro', 3000, 1);   -- anio fuera de rango
```
```text
Error Code: 3819. Check constraint 'chk_libro_anio' is violated.
```

La restricción `chk_libro_anio CHECK (anio BETWEEN 1400 AND 2100)` protege de años imposibles.

### 1064 — error de sintaxis
```sql
SELECT FROM libro;   -- falta decir qué columnas
```
```text
Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'FROM libro;   -- falta decir qué columnas' at line 1
```

El *1064* es el más común: casi siempre es una coma, un paréntesis o una palabra reservada mal escrita. El mensaje muestra **dónde** se confundió el motor (`near ...`).

---

## Cómo leer un error

1. **El número** te dice el tipo de problema (buscalo en la tabla de arriba).
2. **El texto** nombra la tabla, columna o restricción culpable.
3. En un `1064`, mirá lo que dice después de `near`: ahí está el punto exacto.
4. En Workbench, el panel de abajo marca la **línea** que falló.

---

← [Funciones de MySQL](Anexo-Funciones-de-MySQL) · [🏠 Inicio](Home) · [Notaciones de diagramas →](Anexo-Notaciones-de-diagramas)
