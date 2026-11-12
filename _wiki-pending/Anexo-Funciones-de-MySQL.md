# 🧮 Anexo: Funciones de texto, número y fecha

MySQL trae funciones que transforman valores dentro de una consulta: recortar un texto, redondear un número, calcular días entre fechas. Esta página reúne las más útiles del curso, cada una con un ejemplo real.

> 🗒️ Chuleta de referencia. Las funciones se usan dentro de un `SELECT`, un `WHERE` o un `ORDER BY`.

---

## Funciones de texto

| Función | Qué hace | Ejemplo | Resultado |
| ------- | -------- | ------- | --------- |

```sql
SELECT
    UPPER('biblioteca')        AS mayusc,
    LOWER('BIBLIOTECA')        AS minusc,
    LENGTH('liceo')            AS largo,
    CONCAT('La', ' ', 'tregua') AS unido,
    SUBSTRING('Benedetti', 1, 4) AS trozo,
    TRIM('  hola  ')           AS sin_espacios;
```

**Resultado:**

| mayusc | minusc | largo | unido | trozo | sin_espacios |
| ------ | ------ | ----- | ----- | ----- | ------------ |
| BIBLIOTECA | biblioteca | 5 | La tregua | Bene | hola |

Un uso típico: juntar nombre y apellido de los estudiantes en una sola columna.

```sql
SELECT CONCAT(apellido, ', ', nombre) AS estudiante
FROM estudiante
ORDER BY apellido
LIMIT 4;
```

**Resultado:**

| estudiante |
| ---------- |
| Castro, Benjamín |
| Fernández, Lucía |
| González, Camila |
| López, Sofía |

---

## Funciones de número

```sql
SELECT
    ROUND(3.14159, 2)  AS redondeado,
    CEIL(4.1)          AS techo,
    FLOOR(4.9)         AS piso,
    ABS(-7)            AS valor_absoluto,
    MOD(10, 3)         AS resto;
```

**Resultado:**

| redondeado | techo | piso | valor_absoluto | resto |
| ---------- | ----- | ---- | -------------- | ----- |
| 3.14 | 5 | 4 | 7 | 1 |

> 💡 `ROUND`, `CEIL` y `FLOOR` sirven para promedios y conteos. `MOD` (el resto de una división) es útil para saber si un número es par.

---

## Funciones de fecha

Las más usadas en la biblioteca, porque los préstamos tienen fechas:

```sql
SELECT
    CURDATE()                              AS hoy,
    YEAR('2026-04-19')                     AS anio,
    MONTH('2026-04-19')                    AS mes,
    DAY('2026-04-19')                      AS dia,
    DATEDIFF('2026-04-20', '2026-04-16')   AS dias_diferencia,
    DATE_ADD('2026-04-10', INTERVAL 14 DAY) AS vencimiento;
```

**Resultado:**

| hoy | anio | mes | dia | dias_diferencia | vencimiento |
| --- | ---- | --- | --- | --------------- | ----------- |
| 2026-11-12 | 2026 | 4 | 19 | 4 | 2026-04-24 |

Aplicado a los datos reales: cuántos días pasaron entre el préstamo y la devolución pactada de cada préstamo devuelto.

```sql
SELECT id_prestamo,
       fecha_prestamo,
       fecha_devolucion_pactada,
       DATEDIFF(fecha_devolucion_pactada, fecha_prestamo) AS dias_de_plazo
FROM prestamo
ORDER BY id_prestamo
LIMIT 4;
```

**Resultado:**

| id_prestamo | fecha_prestamo | fecha_devolucion_pactada | dias_de_plazo |
| ----------- | -------------- | ------------------------ | ------------- |
| 1 | 2026-03-10 | 2026-03-24 | 14 |
| 2 | 2026-04-02 | 2026-04-16 | 14 |
| 3 | 2026-04-05 | 2026-04-19 | 14 |
| 4 | 2026-04-08 | 2026-04-22 | 14 |

---

## Funciones útiles para agrupar textos

`GROUP_CONCAT` junta en una sola celda los valores de un grupo. Lo usamos para listar los autores de cada libro (relación N:M):

```sql
SELECT l.titulo,
       GROUP_CONCAT(CONCAT(a.nombre, ' ', a.apellido) SEPARATOR ', ') AS autores
FROM libro AS l
INNER JOIN libro_autor AS la ON la.id_libro = l.id_libro
INNER JOIN autor       AS a  ON a.id_autor = la.id_autor
GROUP BY l.id_libro, l.titulo
ORDER BY l.titulo
LIMIT 4;
```

**Resultado:**

| titulo | autores |
| ------ | ------- |
| Cosmos | Carl Sagan |
| Ficciones | Jorge Luis Borges |
| La casa de los espíritus | Isabel Allende |
| La tregua | Mario Benedetti |

---

## Manejo de nulos

| Función | Qué hace |
| ------- | -------- |
| `IFNULL(valor, reemplazo)` | si el valor es `NULL`, devuelve el reemplazo |
| `COALESCE(a, b, c)` | devuelve el primero que no sea `NULL` |

```sql
SELECT id_prestamo,
       IFNULL(fecha_devolucion_real, 'sin devolver') AS devolucion
FROM prestamo
ORDER BY id_prestamo
LIMIT 4;
```

**Resultado:**

| id_prestamo | devolucion |
| ----------- | ---------- |
| 1 | 2026-03-22 |
| 2 | 2026-04-20 |
| 3 | sin devolver |
| 4 | sin devolver |

---

← [Chuleta de SQL](Anexo-Chuleta-SQL) · [🏠 Inicio](Home) · [Errores frecuentes →](Anexo-Errores-frecuentes-de-MySQL)
