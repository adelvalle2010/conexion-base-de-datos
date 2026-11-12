# 📑 Anexo: Chuleta de SQL — referencia rápida

Una sola página con la sintaxis que más se usa en el curso. Las explicaciones a fondo están en los módulos; esto es para tener a mano mientras escribís consultas.

> 🗒️ Todos los ejemplos usan el caso del **liceo** (tablas `estudiante`, `grupo`, `libro`, `ejemplar`, `prestamo`…).

---

## DDL — definir la estructura

| Para… | Sentencia |
| ----- | --------- |
| Crear base | `CREATE DATABASE liceo;` |
| Usar base | `USE liceo;` |
| Borrar base | `DROP DATABASE liceo;` ⚠️ |
| Crear tabla | `CREATE TABLE grupo ( id_grupo INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(10) );` |
| Agregar columna | `ALTER TABLE grupo ADD turno VARCHAR(10);` |
| Cambiar columna | `ALTER TABLE grupo MODIFY nombre VARCHAR(20);` |
| Borrar columna | `ALTER TABLE grupo DROP COLUMN turno;` |
| Borrar tabla | `DROP TABLE grupo;` ⚠️ |
| Vaciar tabla | `TRUNCATE TABLE prestamo;` ⚠️ |

### Restricciones
```sql
CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante)
CONSTRAINT fk_est_grupo  FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
CONSTRAINT uq_grupo_nom  UNIQUE (nombre)
CONSTRAINT chk_anio      CHECK (anio BETWEEN 1400 AND 2100)
    nombre VARCHAR(50) NOT NULL
    turno  VARCHAR(10) DEFAULT 'matutino'
```

---

## DML — mover datos

```sql
INSERT INTO grupo (nombre, turno) VALUES ('3ºA', 'matutino');

UPDATE estudiante SET id_grupo = 2 WHERE id_estudiante = 5;      -- ⚠️ siempre con WHERE

DELETE FROM prestamo WHERE id_prestamo = 10;                     -- ⚠️ siempre con WHERE
```

---

## DQL — consultar (`SELECT`)

```sql
SELECT columna1, columna2
FROM tabla
WHERE condicion
GROUP BY columna
HAVING condicion_de_grupo
ORDER BY columna ASC|DESC
LIMIT n;
```

El **orden en que MySQL ejecuta** (no el de escritura):
```text
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

### Filtros en el `WHERE`
| Operador | Ejemplo |
| -------- | ------- |
| Comparación | `anio >= 2000` |
| Rango | `anio BETWEEN 2000 AND 2010` |
| Lista | `id_categoria IN (1, 3, 5)` |
| Patrón | `titulo LIKE 'La %'` |
| Nulo | `fecha_devolucion_real IS NULL` |
| Combinados | `anio > 2000 AND id_categoria = 1` |

> 📌 Para comparar con nulo se usa `IS NULL` / `IS NOT NULL`, **nunca** `= NULL`.

---

## Funciones de agregación

```sql
SELECT COUNT(*)          FROM estudiante;              -- cuántas filas
SELECT AVG(anio)         FROM libro;                   -- promedio
SELECT MIN(anio), MAX(anio) FROM libro;                -- menor y mayor
SELECT id_grupo, COUNT(*) FROM estudiante GROUP BY id_grupo;   -- por grupo
```

`WHERE` filtra **filas**; `HAVING` filtra **grupos** (va después de `GROUP BY`).

---

## JOIN — combinar tablas

```sql
SELECT e.nombre, g.nombre AS grupo
FROM estudiante AS e
INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo;
```

| JOIN | Devuelve |
| ---- | -------- |
| `INNER JOIN` | solo las filas que coinciden en ambas tablas |
| `LEFT JOIN` | todas las de la izquierda + las que coincidan a la derecha (lo demás `NULL`) |
| `RIGHT JOIN` | todas las de la derecha + las que coincidan a la izquierda |

---

## Subconsultas y vistas

```sql
-- Subconsulta
SELECT titulo FROM libro
WHERE id_libro NOT IN (SELECT id_libro FROM ejemplar WHERE estado = 'disponible');

-- Vista (consulta guardada)
CREATE VIEW v_disponibles AS
SELECT id_ejemplar, id_libro FROM ejemplar WHERE estado = 'disponible';
```

---

## Avanzado (Módulos 9–11)

```sql
-- Transacción
START TRANSACTION;
  UPDATE ejemplar SET estado = 'prestado' WHERE id_ejemplar = 2;
COMMIT;      -- o ROLLBACK para deshacer

-- Índice
CREATE INDEX idx_libro_titulo ON libro (titulo);

-- Usuario y permisos
CREATE USER 'biblio'@'localhost' IDENTIFIED BY 'clave';
GRANT SELECT ON liceo.* TO 'biblio'@'localhost';

-- Respaldo (desde la terminal, no desde SQL)
-- mysqldump -u root -p liceo > respaldo.sql
```

---

← [🏠 Inicio](Home) · [Funciones de MySQL →](Anexo-Funciones-de-MySQL)
