# ✅ Anexo: Buenas prácticas de nombres y estilo

Una base bien escrita se entiende sola y da menos errores. Estas son las convenciones que seguimos en todo el curso. No son leyes de MySQL, son acuerdos para que el código sea claro y parejo.

> 🗒️ Chuleta de referencia. Si tenés dudas de cómo nombrar algo, mirá acá.

---

## 1. Nombres de tablas y columnas

| Regla | ✅ Bien | ❌ Evitar |
| ----- | ------ | --------- |
| Tablas en **singular** | `estudiante`, `libro` | `estudiantes`, `Libros` |
| Minúsculas y `snake_case` | `fecha_prestamo` | `FechaPrestamo`, `fecha prestamo` |
| Sin tildes ni ñ en los nombres | `anio`, `id_nino` | `año`, `niño` |
| Nombres descriptivos | `fecha_devolucion_real` | `fdr`, `campo3` |
| Sin espacios ni palabras reservadas | `grupo` | `order`, `group`, `desc` |

> 📌 Las tildes y la ñ en los **datos** (el valor "Núñez") están perfectas; lo que evitamos es ponerlas en los **nombres** de tablas y columnas.

---

## 2. Claves

| Elemento | Convención | Ejemplo |
| -------- | ---------- | ------- |
| Clave primaria | `id_` + nombre de la tabla | `id_estudiante` |
| Clave foránea | **el mismo nombre** que la PK que referencia | `id_grupo` en `estudiante` |
| PK numérica | `INT AUTO_INCREMENT` | — |

Que la FK se llame igual que la PK a la que apunta hace que los `JOIN` se lean solos:
```sql
... ON g.id_grupo = e.id_grupo
```

---

## 3. Restricciones con nombre

Siempre poner nombre a las restricciones (`CONSTRAINT nombre ...`). Así, cuando fallan, el error dice **cuál** falló.

| Tipo | Prefijo | Ejemplo |
| ---- | ------- | ------- |
| Primary key | `pk_` | `pk_estudiante` |
| Foreign key | `fk_` | `fk_estudiante_grupo` |
| Unique | `uq_` | `uq_grupo_nombre` |
| Check | `chk_` | `chk_libro_anio` |

```sql
-- ✅ con nombre: el error dirá "fk_estudiante_grupo"
CONSTRAINT fk_estudiante_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)

-- ❌ sin nombre: MySQL inventa uno tipo "estudiante_ibfk_1", ilegible
FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
```

---

## 4. Estilo del SQL

- Palabras reservadas en **MAYÚSCULA**: `SELECT`, `FROM`, `WHERE`.
- Una **cláusula por línea**:
  ```sql
  SELECT e.nombre, g.nombre
  FROM estudiante AS e
  INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo
  WHERE g.turno = 'matutino'
  ORDER BY e.apellido;
  ```
- **Alias cortos** y claros con `AS` (`estudiante AS e`).
- **Punto y coma** al final de cada sentencia, siempre.
- **Comentar** lo que no es obvio con `-- ...`.

---

## 5. Seguridad al modificar datos

| Regla | Por qué |
| ----- | ------- |
| Nunca `UPDATE` o `DELETE` sin `WHERE` | borra o cambia **toda** la tabla |
| Probar primero con un `SELECT` | ver qué filas afecta antes de tocarlas |
| `DROP` y `TRUNCATE` con cuidado | no se pueden deshacer |
| Usar transacciones para cambios grandes | `START TRANSACTION` … `COMMIT` / `ROLLBACK` |

```sql
-- Antes de borrar, mirá qué vas a borrar:
SELECT * FROM prestamo WHERE id_estudiante = 5;   -- ✅ primero esto
DELETE     FROM prestamo WHERE id_estudiante = 5;   -- después esto
```

---

## 6. Orden al crear una base

1. Pensar el **MER** y normalizar (no empezar tipeando `CREATE TABLE`).
2. Crear primero las tablas **sin** claves foráneas.
3. Después las que **dependen** de ellas.
4. Cargar los datos en el mismo orden.
5. Al final, vistas, procedimientos y triggers.

---

← [Notaciones de diagramas](Anexo-Notaciones-de-diagramas) · [🏠 Inicio](Home) · [Glosario →](Anexo-Glosario)
