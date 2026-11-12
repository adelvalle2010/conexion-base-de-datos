> 🗄️ **Base de datos:** `liceo` (Módulo 10 — Programación en el Servidor) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🧩 Funciones almacenadas

Esta página parte otra vez de la base `liceo` original. Si hiciste los ejercicios de la página anterior, ejecutá `liceo.sql` antes de seguir (los procedimientos se borran con la base; están todos en `liceo_programado.sql`).

## ¿Por qué lo necesitamos?

En las listas del liceo, los estudiantes se muestran como "Apellido, Nombre", y las notas, con una calificación en palabras. Con lo que sabemos, esa lógica hay que copiarla en cada consulta:

```sql
-- ❌ La misma expresión, repetida en cada consulta que la necesite
SELECT CONCAT(e.apellido, ', ', e.nombre) AS estudiante,
       i.nota,
       CASE
           WHEN i.nota IS NULL THEN 'Sin nota'
           WHEN i.nota < 6     THEN 'No aprobado'
           WHEN i.nota < 9     THEN 'Aprobado'
           ELSE 'Destacado'
       END AS calificacion
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
WHERE i.id_asignatura = 12;
```

`CASE … WHEN … THEN … END` es la forma de escribir un "si… si no…" dentro de una consulta. Funciona, pero es largo.

Si mañana el liceo decide que "Destacado" es a partir de 10, hay que encontrar y corregir todas las consultas. Con **funciones almacenadas**, la regla vive en un solo lugar:

```sql
-- ✅ Las creamos en los Pasos 1 y 2
SELECT fn_nombre_completo(e.nombre, e.apellido) AS estudiante,
       i.nota,
       fn_calificacion(i.nota) AS calificacion
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
WHERE i.id_asignatura = 12;
```

> **¿Qué es una función almacenada?** Es una rutina guardada en la base que recibe parámetros y **devuelve un único valor**. Se usa dentro de una expresión, igual que las funciones propias de MySQL (`ROUND`, `YEAR`, `CONCAT`): en el `SELECT`, en el `WHERE`, en el `ORDER BY`.

**Características principales:**

- Siempre devuelve **un** valor, con `RETURN`.
- Todos sus parámetros son de entrada (no existen `OUT` ni `INOUT`).
- No se ejecuta con `CALL`: se la **usa** en una sentencia.

---

## Sintaxis

```sql
DELIMITER $$

CREATE FUNCTION <nombre>(<parámetros>)
RETURNS <tipo>
<característica>
BEGIN
    <sentencias>;
    RETURN <valor>;
END$$

DELIMITER ;
```

| Parte | Descripción |
| ----- | ----------- |
| `RETURNS tipo` | El tipo de dato del valor que devuelve (con **S**) |
| Característica | Le dice a MySQL cómo se comporta la función; ver la tabla siguiente |
| `RETURN valor` | Devuelve el valor y termina la función (sin **S**) |

| Característica | Significa | Ejemplo |
| -------------- | --------- | ------- |
| `DETERMINISTIC` | Con los mismos parámetros devuelve **siempre** lo mismo | Armar un texto, clasificar una nota |
| `READS SQL DATA` | Lee tablas; el resultado depende de los datos del momento | Calcular un promedio |
| `NO SQL` | No toca tablas, pero el resultado puede variar | Algo que depende de la fecha de hoy |
| `MODIFIES SQL DATA` | Modifica tablas | Poco recomendable en una función |

> 📌 **Nota:** en este curso las funciones llevan el prefijo `fn_`.

---

## Paso 1 — Una función que arma un texto

```sql
DELIMITER $$

CREATE FUNCTION fn_nombre_completo(
    p_nombre   VARCHAR(50),
    p_apellido VARCHAR(50)
)
RETURNS VARCHAR(102)
DETERMINISTIC
BEGIN
    RETURN CONCAT(p_apellido, ', ', p_nombre);
END$$

DELIMITER ;
```

Se prueba con un `SELECT` sin tabla:

```sql
SELECT fn_nombre_completo('Lucía', 'Fernández') AS resultado;
```

**Resultado:**

| resultado |
| --------- |
| Fernández, Lucía |

Y se usa sobre una tabla: MySQL la ejecuta **una vez por cada fila**.

```sql
SELECT id_estudiante,
       fn_nombre_completo(nombre, apellido) AS estudiante
FROM estudiante
WHERE id_grupo = 1
ORDER BY estudiante;
```

**Resultado:**

| id_estudiante | estudiante |
| ------------- | ---------- |
| 1 | Fernández, Lucía |
| 4 | Pérez, Santiago |
| 3 | Rodríguez, Valentina |

El tipo de retorno es `VARCHAR(102)`: 50 del apellido, 50 del nombre, y 2 de la coma y el espacio.

---

## Paso 2 — Una función con lógica

```sql
DELIMITER $$

CREATE FUNCTION fn_calificacion(p_nota DECIMAL(4,2))
RETURNS VARCHAR(15)
DETERMINISTIC
BEGIN
    DECLARE v_texto VARCHAR(15);

    IF p_nota IS NULL THEN
        SET v_texto = 'Sin nota';
    ELSEIF p_nota < 6 THEN
        SET v_texto = 'No aprobado';
    ELSEIF p_nota < 9 THEN
        SET v_texto = 'Aprobado';
    ELSE
        SET v_texto = 'Destacado';
    END IF;

    RETURN v_texto;
END$$

DELIMITER ;
```

Ahora sí, la consulta del principio:

```sql
SELECT fn_nombre_completo(e.nombre, e.apellido) AS estudiante,
       i.nota,
       fn_calificacion(i.nota) AS calificacion
FROM inscripcion AS i
INNER JOIN estudiante AS e ON e.id_estudiante = i.id_estudiante
WHERE i.id_asignatura = 12
ORDER BY i.nota DESC;
```

**Resultado:**

| estudiante | nota | calificacion |
| ---------- | ---- | ------------ |
| Rodríguez, Valentina | 10.00 | Destacado |
| González, Camila | 9.00 | Destacado |
| Castro, Benjamín | 6.00 | Aprobado |
| Martínez, Joaquín | NULL | Sin nota |

Una función se puede usar en cualquier cláusula. ¿Cuántas inscripciones hay de cada calificación?

```sql
SELECT fn_calificacion(nota) AS calificacion,
       COUNT(*)              AS cantidad
FROM inscripcion
GROUP BY fn_calificacion(nota)
ORDER BY cantidad DESC, calificacion;
```

**Resultado:**

| calificacion | cantidad |
| ------------ | -------- |
| Aprobado | 8 |
| Destacado | 7 |
| No aprobado | 3 |
| Sin nota | 3 |

---

## Paso 3 — Una función de cálculo

¿Qué edad tiene cada estudiante al 1.º de marzo de 2026, cuando empiezan los cursos?

```sql
DELIMITER $$

CREATE FUNCTION fn_edad_al(
    p_nacimiento DATE,
    p_dia        DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_nacimiento, p_dia);
END$$

DELIMITER ;
```

```sql
SELECT nombre, apellido, fecha_nacimiento,
       fn_edad_al(fecha_nacimiento, '2026-03-01') AS edad
FROM estudiante
WHERE id_grupo = 3
ORDER BY fecha_nacimiento;
```

**Resultado:**

| nombre | apellido | fecha_nacimiento | edad |
| ------ | -------- | ---------------- | ---- |
| Sofía | López | 2010-02-03 | 16 |
| Joaquín | Martínez | 2010-05-17 | 15 |
| Benjamín | Castro | 2010-12-25 | 15 |

Sofía cumple en febrero y ya tiene 16; Joaquín y Benjamín cumplen después del 1.º de marzo y todavía tienen 15. `TIMESTAMPDIFF(YEAR, …)` cuenta años **cumplidos**, que es lo que queremos para una edad.

> 📌 **Nota:** la función recibe el día como parámetro, y por eso es `DETERMINISTIC`. Una versión que usara `CURDATE()` (la fecha de hoy) devolvería valores distintos según el día en que se ejecute: habría que declararla `NO SQL`.

---

## Paso 4 — Una función que lee tablas

```sql
DELIMITER $$

CREATE FUNCTION fn_promedio_estudiante(p_id_estudiante INT)
RETURNS DECIMAL(4,2)
READS SQL DATA
BEGIN
    DECLARE v_promedio DECIMAL(4,2);

    SELECT ROUND(AVG(nota), 2)
    INTO v_promedio
    FROM inscripcion
    WHERE id_estudiante = p_id_estudiante;

    RETURN v_promedio;
END$$

DELIMITER ;
```

Dentro de una función, toda consulta debe guardar su resultado con `INTO`. Y ahora el promedio es una columna más, sin `JOIN` ni `GROUP BY`:

```sql
SELECT fn_nombre_completo(nombre, apellido)  AS estudiante,
       fn_promedio_estudiante(id_estudiante) AS promedio
FROM estudiante
WHERE fn_promedio_estudiante(id_estudiante) >= 9
ORDER BY promedio DESC;
```

**Resultado:**

| estudiante | promedio |
| ---------- | -------- |
| González, Camila | 9.83 |
| López, Sofía | 9.50 |
| Fernández, Lucía | 9.17 |

Comparala con la tabla derivada que necesitamos para la misma pregunta en [Subconsultas](Subconsultas).

> ⚠️ **El costo oculto:** esta función ejecuta una consulta **por cada fila** de `estudiante`. Con 10 estudiantes no se nota; con 100.000 son 100.000 consultas. Además, una función sobre una columna en el `WHERE` impide usar índices, como vimos en el [Módulo 9](Indices). Para informes sobre muchas filas, el `JOIN` con `GROUP BY` sigue siendo la herramienta correcta.

---

## Paso 5 — Lo que MySQL no permite en una función

**Falta la característica.** Si no se indica ninguna, MySQL rechaza la función:

```sql
DELIMITER $$

CREATE FUNCTION fn_doble(p_numero INT)
RETURNS INT
BEGIN
    RETURN p_numero * 2;
END$$

DELIMITER ;
```

```text
Error Code: 1418. This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA in its declaration and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)
```

MySQL necesita saber si la función es segura para copiarla a otros servidores (replicación). La solución es declarar `DETERMINISTIC`, `NO SQL` o `READS SQL DATA`, según corresponda.

**Devolver un conjunto de filas.** Una función devuelve un valor, no una tabla:

```sql
DELIMITER $$

CREATE FUNCTION fn_listar_grupos()
RETURNS INT
READS SQL DATA
BEGIN
    SELECT nombre FROM grupo;
    RETURN 1;
END$$

DELIMITER ;
```

```text
Error Code: 1415. Not allowed to return a result set from a function
```

Para devolver filas está el procedimiento almacenado. Tampoco se permiten, dentro de una función, `START TRANSACTION`, `COMMIT` ni `ROLLBACK` (`Error 1422`).

---

## Paso 6 — Listar y eliminar

```sql
SHOW FUNCTION STATUS
WHERE Db = 'liceo';
```

**Resultado** (columnas principales):

| Db | Name | Type |
| --- | ---- | ---- |
| liceo | fn_calificacion | FUNCTION |
| liceo | fn_edad_al | FUNCTION |
| liceo | fn_nombre_completo | FUNCTION |
| liceo | fn_promedio_estudiante | FUNCTION |

Igual que los procedimientos, las funciones no se modifican: se eliminan y se vuelven a crear.

```sql
DROP FUNCTION IF EXISTS fn_edad_al;
```

> ⚠️ **Atención:** si una vista o un procedimiento usan la función eliminada, dejan de funcionar hasta que se la vuelva a crear.

---

## Diferencia clave: procedimiento vs función

| Aspecto | Procedimiento | Función |
| ------- | ------------- | ------- |
| Se crea con | `CREATE PROCEDURE` | `CREATE FUNCTION` |
| Se ejecuta con | `CALL sp_nombre(…)` | Dentro de una expresión: `SELECT fn_nombre(…)` |
| Devuelve | Nada, parámetros `OUT`, o tablas de resultados | Exactamente un valor |
| Parámetros | `IN`, `OUT`, `INOUT` | Solo de entrada |
| Puede mostrar un `SELECT` | Sí | No |
| Transacciones adentro | Sí | No |
| Modificar datos | Sí, es su uso típico | Posible, pero no recomendable |
| Uso típico | **Hacer** algo: inscribir, cambiar, dar de baja | **Calcular** algo: un texto, una edad, un promedio |

> 💡 Una forma de recordarlo: los procedimientos se nombran con verbos (`sp_inscribir`); las funciones, con lo que devuelven (`fn_promedio_estudiante`).

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1418`: *This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA…* | Falta la característica | Agregar la que corresponda después de `RETURNS` |
| `Error 1415`: *Not allowed to return a result set from a function* | Un `SELECT` sin `INTO` dentro de la función | `SELECT … INTO variable` |
| `Error 1320`: *No RETURN found in FUNCTION* | La función no tiene ningún `RETURN` | Toda función termina devolviendo un valor |
| `Error 1064` cerca de `RETURN` | Se escribió `RETURN tipo` en la cabecera, o `RETURNS valor` en el cuerpo | Cabecera: `RETURNS` + tipo. Cuerpo: `RETURN` + valor |
| `Error 1305`: *FUNCTION liceo.fn_… does not exist* | Nombre mal escrito, o se está en otra base | `SHOW FUNCTION STATUS` y `USE liceo` |
| `Error 1422`: *Explicit or implicit commit is not allowed in stored function or trigger* | Hay un `COMMIT`, un `START TRANSACTION` o una sentencia de estructura dentro de la función | Pasar esa lógica a un procedimiento |
| El texto sale cortado | El tipo de `RETURNS` es más corto que el valor | Agrandar el `VARCHAR` |
| La consulta se volvió lenta | La función lee tablas y se ejecuta una vez por fila | Reemplazar por `JOIN` + `GROUP BY` |

---

Continuamos por código que no hay que llamar: se ejecuta solo cuando cambian los datos → [Triggers](Triggers)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Creá `fn_iniciales`, que recibe nombre y apellido y devuelve las iniciales con puntos (`L.F.`). Usala para mostrar las iniciales de los docentes.

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE FUNCTION fn_iniciales(
    p_nombre   VARCHAR(50),
    p_apellido VARCHAR(50)
)
RETURNS VARCHAR(4)
DETERMINISTIC
BEGIN
    RETURN CONCAT(LEFT(p_nombre, 1), '.', LEFT(p_apellido, 1), '.');
END$$

DELIMITER ;

SELECT nombre, apellido,
       fn_iniciales(nombre, apellido) AS iniciales
FROM docente
ORDER BY id_docente;
```

| nombre | apellido | iniciales |
| ------ | -------- | --------- |
| Ana | Pereira | A.P. |
| Carlos | Méndez | C.M. |
| Laura | Sosa | L.S. |
| Diego | Olivera | D.O. |
| Marta | Giménez | M.G. |

💡 `LEFT(texto, 1)` devuelve el primer carácter. El resultado siempre mide 4.
</details>

**2.** Creá `fn_cantidad_asignaturas`, que recibe un `id_estudiante` y devuelve en cuántas asignaturas está inscripto. Usala para listar a los estudiantes del grupo 2 con su cantidad.

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE FUNCTION fn_cantidad_asignaturas(p_id_estudiante INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_cantidad INT;

    SELECT COUNT(*)
    INTO v_cantidad
    FROM inscripcion
    WHERE id_estudiante = p_id_estudiante;

    RETURN v_cantidad;
END$$

DELIMITER ;

SELECT nombre, apellido,
       fn_cantidad_asignaturas(id_estudiante) AS asignaturas
FROM estudiante
WHERE id_grupo = 2
ORDER BY apellido;
```

| nombre | apellido | asignaturas |
| ------ | -------- | ----------- |
| Camila | González | 3 |
| Agustín | Núñez | 0 |
| Mateo | Silva | 2 |
| Martina | Suárez | 2 |

💡 Agustín aparece con 0 sin necesidad de `LEFT JOIN`: la consulta recorre `estudiante` y la función cuenta para cada uno. Lee tablas, así que es `READS SQL DATA`.
</details>

**3.** Creá `fn_nombre_asignatura`, que recibe un `id_asignatura` y devuelve su nombre. Usala para mostrar las inscripciones del estudiante 5 sin escribir ningún `JOIN`.

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE FUNCTION fn_nombre_asignatura(p_id_asignatura INT)
RETURNS VARCHAR(60)
READS SQL DATA
BEGIN
    DECLARE v_nombre VARCHAR(60);

    SELECT nombre
    INTO v_nombre
    FROM asignatura
    WHERE id_asignatura = p_id_asignatura;

    RETURN v_nombre;
END$$

DELIMITER ;

SELECT fn_nombre_asignatura(id_asignatura) AS asignatura,
       nota,
       fn_calificacion(nota) AS calificacion
FROM inscripcion
WHERE id_estudiante = 5
ORDER BY asignatura;
```

| asignatura | nota | calificacion |
| ---------- | ---- | ------------ |
| Historia | 9.00 | Destacado |
| Matemática | 12.00 | Destacado |
| Química | 8.50 | Aprobado |

💡 Cómodo para pocas filas. Para listados grandes, el `JOIN` es más eficiente. Si el `id` no existe, la variable queda en `NULL` y eso es lo que devuelve.
</details>

**4.** Sin ejecutarlo: este código tiene tres errores. ¿Cuáles son?

```sql
CREATE FUNCTION fn_mejor_nota(p_id_asignatura INT)
RETURN DECIMAL(4,2)
BEGIN
    SELECT MAX(nota)
    FROM inscripcion
    WHERE id_asignatura = p_id_asignatura;
END
```

<details>
<summary>Ver solución</summary>

1. La cabecera dice `RETURN`; debe ser `RETURNS DECIMAL(4,2)`.
2. Falta la característica: como lee una tabla, `READS SQL DATA`.
3. El `SELECT` no tiene `INTO` y la función no tiene `RETURN`: intenta mostrar un resultado en lugar de devolver un valor.

```sql
DELIMITER $$

CREATE FUNCTION fn_mejor_nota(p_id_asignatura INT)
RETURNS DECIMAL(4,2)
READS SQL DATA
BEGIN
    DECLARE v_mejor DECIMAL(4,2);

    SELECT MAX(nota)
    INTO v_mejor
    FROM inscripcion
    WHERE id_asignatura = p_id_asignatura;

    RETURN v_mejor;
END$$

DELIMITER ;

SELECT fn_mejor_nota(10) AS mejor_nota_matematica;
```

| mejor_nota_matematica |
| --------------------- |
| 12.00 |

💡 Además, para ejecutarlo en Workbench hace falta envolverlo con `DELIMITER`.
</details>

**5.** Usando `fn_calificacion`, mostrá cuántos estudiantes tienen **promedio** de cada calificación. Podés usar también `fn_promedio_estudiante`.

<details>
<summary>Ver solución</summary>

```sql
SELECT fn_calificacion(fn_promedio_estudiante(id_estudiante)) AS calificacion,
       COUNT(*) AS estudiantes
FROM estudiante
GROUP BY fn_calificacion(fn_promedio_estudiante(id_estudiante))
ORDER BY estudiantes DESC, calificacion;
```

| calificacion | estudiantes |
| ------------ | ----------- |
| Aprobado | 4 |
| Destacado | 3 |
| No aprobado | 2 |
| Sin nota | 1 |

💡 Las funciones se pueden anidar: el resultado de una es el parámetro de la otra. El estudiante "Sin nota" es Agustín, que no tiene inscripciones y por eso su promedio es `NULL`.
</details>

---

## 📋 Palabras clave

`función almacenada` · `CREATE FUNCTION` · `RETURNS` · `RETURN` · `DETERMINISTIC` · `READS SQL DATA` · `NO SQL` · `SELECT … INTO` · `DECLARE` · `TIMESTAMPDIFF` · `CONCAT` · `DROP FUNCTION` · `Error 1418` · `Error 1415`

---

🧠 **[Autoevaluación — Módulo 10](auto-modulo10)**

---

← [Procedimientos almacenados](Procedimientos-almacenados) · [🏠 Inicio](Home) · [Triggers →](Triggers)
