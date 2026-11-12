> 🗄️ **Base de datos:** `biblioteca_liceo` (Módulo 12 — Proyecto Integrador) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo12/proyecto_integrador.sql)

# 🔎 Fase 3 — Consultas, vistas y automatización

Con la base creada y poblada (Fase 2), llega lo que la biblioteca necesita todos los días: **responder preguntas** y **automatizar tareas**. Acá se junta todo lo del curso: `JOIN`, agrupación, subconsultas (Módulo 8), vistas, procedimientos y triggers (Módulos 9 y 10).

## Paso 1 — El informe principal: libros con su categoría y sus autores

Es una consulta con la relación **N:M**: cada libro puede tener varios autores. Se recorren las tres tablas y se juntan los autores de cada libro con `GROUP_CONCAT`:

```sql
SELECT l.titulo,
       c.nombre AS categoria,
       GROUP_CONCAT(CONCAT(a.nombre, ' ', a.apellido) SEPARATOR ', ') AS autores
FROM libro AS l
INNER JOIN categoria   AS c  ON c.id_categoria = l.id_categoria
INNER JOIN libro_autor AS la ON la.id_libro = l.id_libro
INNER JOIN autor       AS a  ON a.id_autor = la.id_autor
GROUP BY l.id_libro, l.titulo, c.nombre
ORDER BY l.titulo;
```

**Resultado:**

| titulo | categoria | autores |
| ------ | --------- | ------- |
| Cosmos | Ciencia | Carl Sagan |
| Ficciones | Novela | Jorge Luis Borges |
| La casa de los espíritus | Novela | Isabel Allende |
| La tregua | Novela | Mario Benedetti |
| Las venas abiertas de América Latina | Historia | Eduardo Galeano |
| Poemas de amor | Poesía | Mario Benedetti, Idea Vilariño |

"Poemas de amor" aparece con **dos autores**: así se ve en una consulta una relación N:M resuelta con la tabla intermedia `libro_autor`.

---

## Paso 2 — Qué hay para prestar: usar la vista

La pregunta "¿qué puedo llevarme?" se hace tan seguido que conviene guardarla como **vista** (creada en el script):

```sql
CREATE VIEW v_ejemplares_disponibles AS
SELECT e.id_ejemplar, l.titulo, c.nombre AS categoria
FROM ejemplar AS e
INNER JOIN libro     AS l ON l.id_libro = e.id_libro
INNER JOIN categoria AS c ON c.id_categoria = l.id_categoria
WHERE e.estado = 'disponible';
```

Y la bibliotecaria consulta, sin escribir los `JOIN`, cuántos ejemplares disponibles hay de cada título:

```sql
SELECT titulo, categoria, COUNT(*) AS disponibles
FROM v_ejemplares_disponibles
GROUP BY titulo, categoria
ORDER BY titulo;
```

**Resultado:**

| titulo | categoria | disponibles |
| ------ | --------- | ----------- |
| Cosmos | Ciencia | 1 |
| Ficciones | Novela | 1 |
| Introducción a las bases de datos | Informática | 2 |
| La tregua | Novela | 2 |
| Las venas abiertas de América Latina | Historia | 1 |
| Poemas de amor | Poesía | 1 |

---

## Paso 3 — Préstamos vigentes

Los libros que **todavía no fueron devueltos** son los que tienen `fecha_devolucion_real` en `NULL`:

```sql
SELECT e.nombre, e.apellido, l.titulo,
       p.fecha_prestamo, p.fecha_devolucion_pactada
FROM prestamo AS p
INNER JOIN ejemplar    AS ej ON ej.id_ejemplar = p.id_ejemplar
INNER JOIN libro       AS l  ON l.id_libro = ej.id_libro
INNER JOIN estudiante  AS e  ON e.id_estudiante = p.id_estudiante
WHERE p.fecha_devolucion_real IS NULL
ORDER BY p.fecha_devolucion_pactada;
```

**Resultado:**

| nombre | apellido | titulo | fecha_prestamo | fecha_devolucion_pactada |
| ------ | -------- | ------ | -------------- | ------------------------ |
| Mateo | Silva | Las venas abiertas de América Latina | 2026-04-05 | 2026-04-19 |
| Camila | González | Cosmos | 2026-04-08 | 2026-04-22 |
| Lucía | Fernández | La casa de los espíritus | 2026-04-12 | 2026-04-26 |

---

## Paso 4 — Devoluciones con atraso

Cruzando las dos fechas de devolución se detecta quién entregó **tarde**, y cuántos días:

```sql
SELECT e.apellido, l.titulo,
       p.fecha_devolucion_pactada,
       p.fecha_devolucion_real,
       DATEDIFF(p.fecha_devolucion_real, p.fecha_devolucion_pactada) AS dias_atraso
FROM prestamo AS p
INNER JOIN ejemplar   AS ej ON ej.id_ejemplar = p.id_ejemplar
INNER JOIN libro      AS l  ON l.id_libro = ej.id_libro
INNER JOIN estudiante AS e  ON e.id_estudiante = p.id_estudiante
WHERE p.fecha_devolucion_real > p.fecha_devolucion_pactada
ORDER BY dias_atraso DESC;
```

**Resultado:**

| apellido | titulo | fecha_devolucion_pactada | fecha_devolucion_real | dias_atraso |
| -------- | ------ | ------------------------ | --------------------- | ----------- |
| Pérez | Ficciones | 2026-04-16 | 2026-04-20 | 4 |

---

## Paso 5 — Ranking: los libros más prestados

```sql
SELECT l.titulo,
       COUNT(*) AS veces_prestado
FROM prestamo AS p
INNER JOIN ejemplar AS ej ON ej.id_ejemplar = p.id_ejemplar
INNER JOIN libro    AS l  ON l.id_libro = ej.id_libro
GROUP BY l.id_libro, l.titulo
ORDER BY veces_prestado DESC, l.titulo;
```

**Resultado:**

| titulo | veces_prestado |
| ------ | -------------- |
| Cosmos | 1 |
| Ficciones | 1 |
| Introducción a las bases de datos | 1 |
| La casa de los espíritus | 1 |
| La tregua | 1 |
| Las venas abiertas de América Latina | 1 |

---

## Paso 6 — Automatizar el préstamo: trigger + procedimiento

Prestar un ejemplar son **dos** cosas: registrar el préstamo y marcar el ejemplar como `prestado`. Para que nunca se olvide la segunda, un **trigger** la hace sola cada vez que se inserta un préstamo:

```sql
CREATE TRIGGER trg_prestamo_after_insert
AFTER INSERT ON prestamo
FOR EACH ROW
BEGIN
    UPDATE ejemplar SET estado = 'prestado' WHERE id_ejemplar = NEW.id_ejemplar;
END
```

Y un **procedimiento** envuelve toda la operación con sus controles (que el ejemplar exista y esté disponible) y una transacción:

```sql
CREATE PROCEDURE sp_prestar(IN p_id_ejemplar INT, IN p_id_estudiante INT, IN p_dias INT)
BEGIN
    DECLARE v_estado VARCHAR(12);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    SELECT estado INTO v_estado FROM ejemplar WHERE id_ejemplar = p_id_ejemplar;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ejemplar no existe';
    ELSEIF v_estado <> 'disponible' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ejemplar no está disponible';
    END IF;

    START TRANSACTION;
    INSERT INTO prestamo (id_ejemplar, id_estudiante, fecha_prestamo, fecha_devolucion_pactada)
    VALUES (p_id_ejemplar, p_id_estudiante, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_dias DAY));
    COMMIT;
END
```

**Prestamos en acción.** El ejemplar 2 ("La tregua") está disponible. Lo prestamos a Valentina (estudiante 3) por 14 días:

```sql
CALL sp_prestar(2, 3, 14);
```

El procedimiento insertó el préstamo y el trigger marcó el ejemplar. Lo comprobamos:

```sql
SELECT id_ejemplar, estado FROM ejemplar WHERE id_ejemplar = 2;
```

**Resultado:**

| id_ejemplar | estado |
| ----------- | ------ |
| 2 | prestado |

**El control funciona.** Si ahora alguien intenta prestar **el mismo ejemplar** (que ya no está disponible), el procedimiento lo rechaza:

```sql
CALL sp_prestar(2, 5, 14);
```

```text
Error Code: 1644. El ejemplar no está disponible
```

En una sola llamada, `sp_prestar` registra el préstamo, actualiza el estado y se niega a prestar algo que no está disponible. Esa es la idea de todo el curso: una base que **guarda** los datos, los **consulta** y además **se protege sola**.

---

## Lo que usamos de cada módulo

| De… | Usamos en la biblioteca |
| --- | ----------------------- |
| Módulo 8 | `INNER JOIN`, `GROUP BY`, `GROUP_CONCAT`, ranking de libros |
| Módulo 8 | Vista `v_ejemplares_disponibles` |
| Módulo 9 | Una transacción dentro de `sp_prestar` |
| Módulo 10 | Procedimiento `sp_prestar` y trigger `trg_prestamo_after_insert` |
| Módulo 11 | Un usuario `bibliotecario` con permiso de `SELECT` y de ejecutar el procedimiento |

---

Continuamos por el cierre del curso → [Resumen final del curso](Resumen-Modulo12)

---

## ✍️ Ejercicios finales

Resolvé cada uno antes de mirar la solución. Son sobre la base `biblioteca_liceo`.

**1.** Listá los títulos de la categoría "Novela", ordenados alfabéticamente.

<details>
<summary>Ver solución</summary>

```sql
SELECT l.titulo
FROM libro AS l
INNER JOIN categoria AS c ON c.id_categoria = l.id_categoria
WHERE c.nombre = 'Novela'
ORDER BY l.titulo;
```

| titulo |
| ------ |
| Ficciones |
| La casa de los espíritus |
| La tregua |

💡 Un `JOIN` simple con filtro por el nombre de la categoría.
</details>

**2.** ¿Cuántos préstamos hizo cada estudiante? Mostrá nombre, apellido y cantidad, de mayor a menor.

<details>
<summary>Ver solución</summary>

```sql
SELECT e.nombre, e.apellido, COUNT(*) AS prestamos
FROM prestamo AS p
INNER JOIN estudiante AS e ON e.id_estudiante = p.id_estudiante
GROUP BY e.id_estudiante, e.nombre, e.apellido
ORDER BY prestamos DESC, e.apellido;
```

| nombre | apellido | prestamos |
| ------ | -------- | --------- |
| Lucía | Fernández | 2 |
| Camila | González | 1 |
| Sofía | López | 1 |
| Santiago | Pérez | 1 |
| Valentina | Rodríguez | 1 |
| Mateo | Silva | 1 |

💡 Lucía figura con dos préstamos; el resto con uno.
</details>

**3.** Mostrá los libros que **no tienen ningún ejemplar disponible** (todos prestados o de baja).

<details>
<summary>Ver solución</summary>

```sql
SELECT l.titulo
FROM libro AS l
WHERE l.id_libro NOT IN (
    SELECT e.id_libro
    FROM ejemplar AS e
    WHERE e.estado = 'disponible'
)
ORDER BY l.titulo;
```

| titulo |
| ------ |
| La casa de los espíritus |

💡 Subconsulta con `NOT IN`: los libros cuyo id no aparece entre los que tienen algún ejemplar disponible.
</details>

**4.** Creá una vista `v_prestamos_vigentes` con el apellido del estudiante, el título y la fecha pactada de devolución de los préstamos sin devolver.

<details>
<summary>Ver solución</summary>

```sql
CREATE VIEW v_prestamos_vigentes AS
SELECT e.apellido, l.titulo, p.fecha_devolucion_pactada
FROM prestamo AS p
INNER JOIN ejemplar   AS ej ON ej.id_ejemplar = p.id_ejemplar
INNER JOIN libro      AS l  ON l.id_libro = ej.id_libro
INNER JOIN estudiante AS e  ON e.id_estudiante = p.id_estudiante
WHERE p.fecha_devolucion_real IS NULL;
```

```sql
SELECT * FROM v_prestamos_vigentes ORDER BY fecha_devolucion_pactada;
```

| apellido | titulo | fecha_devolucion_pactada |
| -------- | ------ | ------------------------ |
| Silva | Las venas abiertas de América Latina | 2026-04-19 |
| González | Cosmos | 2026-04-22 |
| Fernández | La casa de los espíritus | 2026-04-26 |
| Rodríguez | La tregua | 2026-11-26 |

💡 Guardar la consulta como vista permite reusarla sin reescribir los `JOIN`.
</details>

---

## 📋 Palabras clave

`proyecto integrador` · `JOIN` · `GROUP_CONCAT` · `vista` · `v_ejemplares_disponibles` · `procedimiento` · `sp_prestar` · `trigger` · `transacción` · `SIGNAL` · `relación N:M` · `NOT IN` · `DATEDIFF`

---

🧠 **[Autoevaluación — Módulo 12](auto-modulo12)**

---

← [Fase 2: Crear y poblar la base](Proyecto-Fase-2-Implementacion) · [🏠 Inicio](Home) · [Resumen final del curso →](Resumen-Modulo12)
