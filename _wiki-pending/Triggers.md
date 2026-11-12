> 🗄️ **Base de datos:** `liceo` (Módulo 10 — Programación en el Servidor) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🎯 Triggers

Esta página también parte de la base `liceo` original: ejecutá `liceo.sql` antes de empezar.

## ¿Por qué lo necesitamos?

A fin de año, una familia reclama: "mi hija tenía un 8 en Matemática y ahora figura un 5". ¿Quién cambió la nota, y cuándo? La tabla `inscripcion` guarda la nota actual y nada más: el valor anterior se perdió en el momento del `UPDATE`.

La solución es una tabla de **auditoría** donde se anota cada cambio. El problema es quién escribe en ella:

```sql
-- ❌ Depende de que TODOS se acuerden SIEMPRE de escribir las dos sentencias
UPDATE inscripcion
SET nota = 5
WHERE id_estudiante = 2
  AND id_asignatura = 10;

INSERT INTO auditoria_nota (id_estudiante, id_asignatura, nota_anterior, nota_nueva)
VALUES (2, 10, 8, 5);
```

Alcanza con que una persona, un programa o un procedimiento se saltee el `INSERT` para que la auditoría no sirva. Con un **trigger**, el registro se hace solo:

```sql
-- ✅ El trigger escribe en la auditoría, lo ejecute quien lo ejecute
UPDATE inscripcion
SET nota = 5
WHERE id_estudiante = 2
  AND id_asignatura = 10;
```

> **¿Qué es un trigger?** Es un bloque de código asociado a una **tabla**, que MySQL ejecuta automáticamente cuando ocurre un `INSERT`, un `UPDATE` o un `DELETE` sobre ella. No se lo llama: se **dispara**. En español también se le dice disparador.

**Características principales:**

- Pertenece a una tabla y a un evento (`INSERT`, `UPDATE` o `DELETE`).
- Se ejecuta **antes** (`BEFORE`) o **después** (`AFTER`) del cambio.
- Se ejecuta **una vez por cada fila** afectada.
- No se puede evitar: se dispara siempre, venga el cambio de Workbench, de una aplicación o de un procedimiento.

---

## Sintaxis

```sql
DELIMITER $$

CREATE TRIGGER <nombre>
{BEFORE | AFTER} {INSERT | UPDATE | DELETE} ON <tabla>
FOR EACH ROW
BEGIN
    <sentencias>;
END$$

DELIMITER ;
```

### Anatomía de un trigger

```text
                         UPDATE inscripcion SET nota = 5 WHERE …
                                          │
              ┌───────────────────────────┼───────────────────────────┐
              ▼                           ▼                           ▼
     BEFORE UPDATE                 se modifica                 AFTER UPDATE
  (puede corregir NEW            la fila en la tabla        (registrar, avisar,
   o rechazar el cambio)                                     actualizar otra tabla)

                    todo se repite para cada fila afectada
```

Dentro del trigger hay dos "filas" especiales para leer los datos:

| | `OLD` (la fila **antes** del cambio) | `NEW` (la fila **después** del cambio) |
| --- | --- | --- |
| `INSERT` | No existe | ✅ Los valores que se van a insertar |
| `UPDATE` | ✅ Los valores anteriores | ✅ Los valores nuevos |
| `DELETE` | ✅ Los valores que se eliminan | No existe |

Se usan como `OLD.nota` y `NEW.nota`.

> 📌 **Nota:** en este curso los triggers se llaman `trg_<tabla>_<momento>_<evento>`, por ejemplo `trg_inscripcion_after_update`.

---

## Paso 1 — La tabla de auditoría

```sql
CREATE TABLE auditoria_nota (
    id_auditoria  INT          NOT NULL AUTO_INCREMENT,
    operacion     VARCHAR(10)  NOT NULL,
    id_estudiante INT          NOT NULL,
    id_asignatura INT          NOT NULL,
    nota_anterior DECIMAL(4,2),
    nota_nueva    DECIMAL(4,2),
    usuario       VARCHAR(100) NOT NULL,
    fecha         DATETIME     NOT NULL,
    CONSTRAINT pk_auditoria_nota PRIMARY KEY (id_auditoria)
);
```

No tiene claves foráneas, a propósito: el historial tiene que seguir existiendo aunque después se elimine al estudiante o la asignatura.

---

## Paso 2 — AFTER UPDATE: registrar cada cambio de nota

```sql
DELIMITER $$

CREATE TRIGGER trg_inscripcion_after_update
AFTER UPDATE ON inscripcion
FOR EACH ROW
BEGIN
    IF NOT (OLD.nota <=> NEW.nota) THEN
        INSERT INTO auditoria_nota
            (operacion, id_estudiante, id_asignatura, nota_anterior, nota_nueva, usuario, fecha)
        VALUES
            ('UPDATE', OLD.id_estudiante, OLD.id_asignatura, OLD.nota, NEW.nota, CURRENT_USER(), NOW());
    END IF;
END$$

DELIMITER ;
```

Probamos con una nota:

```sql
UPDATE inscripcion
SET nota = 6
WHERE id_estudiante = 4
  AND id_asignatura = 10;
```

Y con varias a la vez: les ponemos 7 a los dos inscriptos de Programación que no tenían nota.

```sql
UPDATE inscripcion
SET nota = 7
WHERE id_asignatura = 14
  AND nota IS NULL;
```

```sql
SELECT id_auditoria, operacion, id_estudiante, id_asignatura, nota_anterior, nota_nueva
FROM auditoria_nota
ORDER BY id_auditoria;
```

**Resultado:**

| id_auditoria | operacion | id_estudiante | id_asignatura | nota_anterior | nota_nueva |
| ------------ | --------- | ------------- | ------------- | ------------- | ---------- |
| 1 | UPDATE | 4 | 10 | 4.00 | 6.00 |
| 2 | UPDATE | 4 | 14 | NULL | 7.00 |
| 3 | UPDATE | 9 | 14 | NULL | 7.00 |

Tres filas de auditoría, sin haber escrito ningún `INSERT`. El segundo `UPDATE` modificó dos filas y el trigger se disparó dos veces: eso significa `FOR EACH ROW`. Las columnas `usuario` y `fecha`, que no mostramos, guardan quién lo hizo (por ejemplo `root@localhost`) y en qué momento.

**Elementos clave:**

- `AFTER`: el registro se hace cuando el cambio ya pasó todas las validaciones.
- `OLD.nota` y `NEW.nota`: el valor de antes y el de después, de **esa** fila.
- `<=>` es la igualdad que funciona con `NULL`: `NULL <=> NULL` es verdadero y `NULL <=> 7` es falso, mientras que con `=` los dos darían `NULL`. El `IF` evita registrar los `UPDATE` que no cambian la nota.
- `CURRENT_USER()` y `NOW()`: el usuario conectado y la fecha y hora del momento.

---

## Paso 3 — BEFORE INSERT: corregir los datos antes de guardarlos

En un trigger `BEFORE` se puede **modificar** `NEW`: lo que se guarde será lo que el trigger deje ahí. Sirve para normalizar datos que llegan desprolijos.

```sql
DELIMITER $$

CREATE TRIGGER trg_estudiante_before_insert
BEFORE INSERT ON estudiante
FOR EACH ROW
BEGIN
    -- Sin espacios sobrantes
    SET NEW.nombre   = TRIM(NEW.nombre);
    SET NEW.apellido = TRIM(NEW.apellido);

    -- Primera letra en mayúscula
    SET NEW.nombre   = CONCAT(UPPER(LEFT(NEW.nombre, 1)),   SUBSTRING(NEW.nombre, 2));
    SET NEW.apellido = CONCAT(UPPER(LEFT(NEW.apellido, 1)), SUBSTRING(NEW.apellido, 2));
END$$

DELIMITER ;
```

```sql
INSERT INTO estudiante (nombre, apellido, fecha_nacimiento, id_grupo)
VALUES ('   emilia', 'vidal  ', '2010-08-08', 3);

SELECT id_estudiante, nombre, apellido
FROM estudiante
WHERE id_estudiante > 10;
```

**Resultado:**

| id_estudiante | nombre | apellido |
| ------------- | ------ | -------- |
| 11 | Emilia | Vidal |

Se insertó `'   emilia'` y quedó guardado `Emilia`.

---

## Paso 4 — BEFORE INSERT: rechazar un cambio

Regla del liceo: un estudiante puede cursar **como máximo cuatro asignaturas**. Una restricción `CHECK` no puede expresarla, porque solo mira la fila que se está guardando y acá hay que contar **otras** filas. Un trigger sí puede, y con `SIGNAL` cancela la operación:

```sql
DELIMITER $$

CREATE TRIGGER trg_inscripcion_before_insert
BEFORE INSERT ON inscripcion
FOR EACH ROW
BEGIN
    DECLARE v_cantidad INT;

    SELECT COUNT(*)
    INTO v_cantidad
    FROM inscripcion
    WHERE id_estudiante = NEW.id_estudiante;

    IF v_cantidad >= 4 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un estudiante no puede tener más de 4 inscripciones';
    END IF;
END$$

DELIMITER ;
```

Lucía Fernández (1) tiene tres inscripciones. La cuarta entra:

```sql
INSERT INTO inscripcion (id_estudiante, id_asignatura)
VALUES (1, 12);
```

La quinta, no:

```sql
INSERT INTO inscripcion (id_estudiante, id_asignatura)
VALUES (1, 13);
```

```text
Error Code: 1644. Un estudiante no puede tener más de 4 inscripciones
```

```sql
SELECT COUNT(*) AS inscripciones_de_lucia
FROM inscripcion
WHERE id_estudiante = 1;
```

**Resultado:**

| inscripciones_de_lucia |
| ---------------------- |
| 4 |

Cuando un trigger `BEFORE` produce un error, la sentencia que lo disparó **no se ejecuta**.

---

## Paso 5 — AFTER DELETE: registrar lo que se elimina

```sql
DELIMITER $$

CREATE TRIGGER trg_inscripcion_after_delete
AFTER DELETE ON inscripcion
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_nota
        (operacion, id_estudiante, id_asignatura, nota_anterior, nota_nueva, usuario, fecha)
    VALUES
        ('DELETE', OLD.id_estudiante, OLD.id_asignatura, OLD.nota, NULL, CURRENT_USER(), NOW());
END$$

DELIMITER ;
```

```sql
DELETE FROM inscripcion
WHERE id_estudiante = 8
  AND id_asignatura = 11;

SELECT id_auditoria, operacion, id_estudiante, id_asignatura, nota_anterior, nota_nueva
FROM auditoria_nota
ORDER BY id_auditoria;
```

**Resultado:**

| id_auditoria | operacion | id_estudiante | id_asignatura | nota_anterior | nota_nueva |
| ------------ | --------- | ------------- | ------------- | ------------- | ---------- |
| 1 | UPDATE | 4 | 10 | 4.00 | 6.00 |
| 2 | UPDATE | 4 | 14 | NULL | 7.00 |
| 3 | UPDATE | 9 | 14 | NULL | 7.00 |
| 4 | DELETE | 8 | 11 | 3.00 | NULL |

En un `DELETE` solo existe `OLD`: es la última oportunidad de guardar lo que había.

### Una excepción importante: los borrados en cascada

La clave foránea de `inscripcion` hacia `estudiante` es `ON DELETE CASCADE`: al eliminar un estudiante, MySQL elimina sus inscripciones. Probemos con Joaquín Martínez (6), que tiene dos:

```sql
DELETE FROM estudiante
WHERE id_estudiante = 6;

SELECT COUNT(*) AS inscripciones_de_joaquin
FROM inscripcion
WHERE id_estudiante = 6;
```

**Resultado:**

| inscripciones_de_joaquin |
| ------------------------ |
| 0 |

```sql
SELECT COUNT(*) AS filas_en_auditoria
FROM auditoria_nota;
```

**Resultado:**

| filas_en_auditoria |
| ------------------ |
| 4 |

Las inscripciones se eliminaron, pero la auditoría sigue con las mismas cuatro filas.

> ⚠️ **En MySQL, los cambios hechos por una clave foránea en cascada no disparan triggers.** Si la auditoría de esos borrados es importante, hay que registrarlos con un trigger `BEFORE DELETE` sobre `estudiante`, o no usar `CASCADE` y eliminar las inscripciones explícitamente.

---

## Paso 6 — Triggers y transacciones

Lo que hace un trigger forma parte de la **misma transacción** que la sentencia que lo disparó. Si esa transacción se deshace, lo del trigger también.

```sql
START TRANSACTION;

UPDATE inscripcion
SET nota = 1
WHERE id_asignatura = 10;

SELECT COUNT(*) AS filas_en_auditoria
FROM auditoria_nota;
```

**Resultado:**

| filas_en_auditoria |
| ------------------ |
| 10 |

```sql
ROLLBACK;

SELECT COUNT(*) AS filas_en_auditoria
FROM auditoria_nota;
```

**Resultado:**

| filas_en_auditoria |
| ------------------ |
| 4 |

Es lo correcto: si el cambio de notas nunca ocurrió, tampoco tiene que figurar en el historial.

---

## Paso 7 — Listar y eliminar

```sql
SHOW TRIGGERS;
```

**Resultado** (columnas principales):

| Trigger | Event | Table | Timing |
| ------- | ----- | ----- | ------ |
| trg_estudiante_before_insert | INSERT | estudiante | BEFORE |
| trg_inscripcion_before_insert | INSERT | inscripcion | BEFORE |
| trg_inscripcion_after_update | UPDATE | inscripcion | AFTER |
| trg_inscripcion_after_delete | DELETE | inscripcion | AFTER |

Los triggers no se modifican: se eliminan y se vuelven a crear.

```sql
DROP TRIGGER IF EXISTS trg_estudiante_before_insert;
```

> ⚠️ **Atención:** al eliminar una tabla con `DROP TABLE`, sus triggers se eliminan con ella, sin aviso.

---

## Cuándo usar un trigger (y cuándo no)

Los triggers son potentes y, justamente por eso, hay que usarlos con cuidado: ejecutan código que nadie ve.

| Buen uso | Mal uso |
| -------- | ------- |
| Auditoría: quién cambió qué y cuándo | Lógica de negocio compleja (mejor un procedimiento, que se ve y se llama) |
| Normalizar datos al entrar (espacios, mayúsculas) | Reemplazar restricciones que ya existen (`NOT NULL`, `CHECK`, `UNIQUE`, FK) |
| Reglas que una restricción no puede expresar | Triggers que modifican tablas que disparan otros triggers, en cadena |
| Mantener un dato calculado (un contador, un total) | Operaciones lentas: se pagan en **cada** fila de cada sentencia |

> 💡 Cuando algo "pasa solo" en una base y nadie entiende por qué, lo primero que se revisa es `SHOW TRIGGERS`.

## Diferencia clave: BEFORE vs AFTER

| Aspecto | `BEFORE` | `AFTER` |
| ------- | -------- | ------- |
| Se ejecuta | Antes de modificar la fila | Después de modificarla |
| ¿Puede cambiar `NEW`? | Sí (`SET NEW.columna = …`) | No |
| Si da error | La sentencia no se ejecuta | La sentencia se deshace |
| Uso típico | Validar, corregir, rechazar | Auditar, actualizar otras tablas |
| Ejemplo | `trg_estudiante_before_insert` | `trg_inscripcion_after_update` |

## Diferencia clave: procedimiento vs función vs trigger

| Aspecto | Procedimiento | Función | Trigger |
| ------- | ------------- | ------- | ------- |
| Cómo se ejecuta | `CALL` | Dentro de una expresión | Solo, ante un cambio en la tabla |
| Parámetros | `IN`, `OUT`, `INOUT` | De entrada | No tiene; usa `OLD` y `NEW` |
| Devuelve | Opcional | Un valor | Nada |
| Transacciones propias | Sí | No | No |
| Para qué | Hacer una operación | Calcular un valor | Reaccionar a un cambio |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1359`: *Trigger already exists* | Ya hay un trigger con ese nombre | `DROP TRIGGER IF EXISTS` antes del `CREATE` |
| `Error 1363`: *There is no OLD row in on INSERT trigger* | Se usó `OLD` en un `INSERT` (o `NEW` en un `DELETE`) | Revisar la tabla de `OLD` y `NEW` |
| `Error 1362`: *Updating of NEW row is not allowed in after trigger* | `SET NEW.columna = …` en un trigger `AFTER` | Los datos se corrigen en un `BEFORE` |
| `Error 1442`: *Can't update table … because it is already used by statement which invoked this …* | El trigger intenta modificar con `UPDATE` o `DELETE` la misma tabla que lo disparó | Para cambiar la fila en curso, `SET NEW.columna` en un `BEFORE` |
| `Error 1422`: *Explicit or implicit commit is not allowed…* | Hay un `COMMIT`, `ROLLBACK` o sentencia de estructura en el trigger | Los triggers no manejan transacciones |
| `Error 1644` con un mensaje en español | Es un `SIGNAL` de un trigger o procedimiento propio | Leer el mensaje: la regla la escribimos nosotros |
| Un borrado no quedó en la auditoría | Lo hizo una clave foránea `ON DELETE CASCADE` | Ver el Paso 5 |
| Una carga masiva se volvió muy lenta | El trigger se ejecuta una vez por cada fila | Simplificar el trigger, o cargar los datos antes de crearlo |

---

Continuamos por el repaso del módulo → [Resumen del Módulo 10](Resumen-Modulo10)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Siguen sobre la base como quedó al final de la página.

**1.** Creá `trg_inscripcion_after_insert`, que registre en `auditoria_nota` cada inscripción nueva, con la operación `'INSERT'`. Probalo inscribiendo a Agustín Núñez (10) en Matemática (10).

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE TRIGGER trg_inscripcion_after_insert
AFTER INSERT ON inscripcion
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_nota
        (operacion, id_estudiante, id_asignatura, nota_anterior, nota_nueva, usuario, fecha)
    VALUES
        ('INSERT', NEW.id_estudiante, NEW.id_asignatura, NULL, NEW.nota, CURRENT_USER(), NOW());
END$$

DELIMITER ;

INSERT INTO inscripcion (id_estudiante, id_asignatura)
VALUES (10, 10);

SELECT operacion, id_estudiante, id_asignatura, nota_anterior, nota_nueva
FROM auditoria_nota
WHERE operacion = 'INSERT';
```

| operacion | id_estudiante | id_asignatura | nota_anterior | nota_nueva |
| --------- | ------------- | ------------- | ------------- | ---------- |
| INSERT | 10 | 10 | NULL | NULL |

💡 En un `INSERT` no hay `OLD`: la nota anterior se registra como `NULL`. La tabla `inscripcion` ahora tiene dos triggers de `INSERT`, uno `BEFORE` y otro `AFTER`; no se molestan.
</details>

**2.** Creá un trigger que impida **borrar una nota ya puesta**, es decir, cambiarla de un valor a `NULL`. Probalo con la nota de Lucía en Matemática.

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE TRIGGER trg_inscripcion_before_update
BEFORE UPDATE ON inscripcion
FOR EACH ROW
BEGIN
    IF OLD.nota IS NOT NULL AND NEW.nota IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede dejar sin nota una inscripción ya calificada';
    END IF;
END$$

DELIMITER ;

UPDATE inscripcion
SET nota = NULL
WHERE id_estudiante = 1
  AND id_asignatura = 10;
```

```text
Error Code: 1644. No se puede dejar sin nota una inscripción ya calificada
```

💡 Es una regla sobre el **cambio** (de qué valor a qué valor), y por eso necesita `OLD` y `NEW`. Un `CHECK` solo ve el valor nuevo.
</details>

**3.** Creá un trigger que rechace el alta de un estudiante con fecha de nacimiento **posterior a hoy**. ¿Por qué no se puede resolver con un `CHECK`?

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE TRIGGER trg_estudiante_before_insert_fecha
BEFORE INSERT ON estudiante
FOR EACH ROW
BEGIN
    IF NEW.fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de nacimiento no puede ser futura';
    END IF;
END$$

DELIMITER ;

INSERT INTO estudiante (nombre, apellido, fecha_nacimiento, id_grupo)
VALUES ('Pedro', 'Lasa', '2099-01-01', 1);
```

```text
Error Code: 1644. La fecha de nacimiento no puede ser futura
```

💡 MySQL no permite `CURDATE()` dentro de un `CHECK`: el resultado de la restricción cambiaría con el paso de los días. Una tabla puede tener varios triggers para el mismo momento y evento (acá, dos `BEFORE INSERT` sobre `estudiante`): se ejecutan en el orden en que se crearon, salvo que se indique otro con `FOLLOWS` o `PRECEDES`.
</details>

**4.** Sin ejecutarlo: ¿qué error da cada uno de estos triggers al crearlo, y por qué?

```sql
-- a)
CREATE TRIGGER trg_a
AFTER INSERT ON docente
FOR EACH ROW
SET NEW.apellido = UPPER(NEW.apellido);

-- b)
CREATE TRIGGER trg_b
BEFORE INSERT ON docente
FOR EACH ROW
SET NEW.apellido = OLD.apellido;
```

<details>
<summary>Ver solución</summary>

- **a)** `Error 1362`: en un trigger `AFTER` la fila ya se guardó y `NEW` no se puede modificar. Tiene que ser `BEFORE INSERT`.
- **b)** `Error 1363`: en un `INSERT` no existe `OLD`, porque antes no había fila.

💡 Cuando el cuerpo es una sola sentencia, se puede escribir sin `BEGIN … END` y sin `DELIMITER`.
</details>

**5.** Un compañero quiere que, al cambiar una nota, la nota quede redondeada sin decimales, y escribe este trigger. Al hacer un `UPDATE` recibe `Error 1442`. ¿Por qué? ¿Cómo se arregla?

```sql
CREATE TRIGGER trg_redondear
AFTER UPDATE ON inscripcion
FOR EACH ROW
UPDATE inscripcion
SET nota = ROUND(nota)
WHERE id_estudiante = NEW.id_estudiante
  AND id_asignatura = NEW.id_asignatura;
```

<details>
<summary>Ver solución</summary>

Un trigger no puede ejecutar un `UPDATE` sobre la **misma tabla** que lo disparó (además, ese `UPDATE` volvería a disparar el trigger, sin fin). Para cambiar la fila en curso se modifica `NEW` en un trigger `BEFORE`:

```sql
CREATE TRIGGER trg_redondear
BEFORE UPDATE ON inscripcion
FOR EACH ROW
SET NEW.nota = ROUND(NEW.nota);
```

💡 No hace falta `WHERE`: `NEW` ya **es** la fila que se está modificando.
</details>

**6.** Listá los triggers de la tabla `inscripcion` y eliminá el del ejercicio 2.

<details>
<summary>Ver solución</summary>

```sql
SHOW TRIGGERS
WHERE `Table` = 'inscripcion';
```

| Trigger | Event | Timing |
| ------- | ----- | ------ |
| trg_inscripcion_before_insert | INSERT | BEFORE |
| trg_inscripcion_after_insert | INSERT | AFTER |
| trg_inscripcion_before_update | UPDATE | BEFORE |
| trg_inscripcion_after_update | UPDATE | AFTER |
| trg_inscripcion_after_delete | DELETE | AFTER |

```sql
DROP TRIGGER trg_inscripcion_before_update;
```

💡 `Table` es una palabra reservada: en el `WHERE` de `SHOW TRIGGERS` va entre acentos graves.
</details>

---

## 📋 Palabras clave

`trigger` · `disparador` · `CREATE TRIGGER` · `BEFORE` · `AFTER` · `FOR EACH ROW` · `OLD` · `NEW` · `auditoría` · `SIGNAL` · `<=>` · `CURRENT_USER()` · `NOW()` · `SHOW TRIGGERS` · `DROP TRIGGER` · `FOLLOWS`

---

🧠 **[Autoevaluación — Módulo 10](auto-modulo10)**

---

← [Funciones almacenadas](Funciones-almacenadas) · [🏠 Inicio](Home) · [Resumen del Módulo 10 →](Resumen-Modulo10)
