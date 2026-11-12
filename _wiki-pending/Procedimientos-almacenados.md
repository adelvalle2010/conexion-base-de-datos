> 🗄️ **Base de datos:** `liceo` (Módulo 10 — Programación en el Servidor) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# ⚙️ Procedimientos almacenados

En este módulo vamos a guardar **lógica** dentro de la base, además de datos: operaciones con nombre que se ejecutan con una línea, cálculos reutilizables y reglas que se disparan solas. Partimos de la base `liceo` original: ejecutá `liceo.sql` antes de empezar.

> 📌 **Nota:** todo lo que se crea en las tres páginas del módulo está reunido en [`liceo_programado.sql`](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo10/liceo_programado.sql), que crea una base aparte llamada `liceo_programado`.

## ¿Por qué lo necesitamos?

En el módulo anterior, cambiar a un estudiante de asignatura requería escribir esto, sin equivocarse, **cada vez**:

```sql
-- ❌ Cuatro sentencias que hay que recordar y repetir
START TRANSACTION;

DELETE FROM inscripcion
WHERE id_estudiante = 2
  AND id_asignatura = 13;

INSERT INTO inscripcion (id_estudiante, id_asignatura)
VALUES (2, 11);

COMMIT;
```

Y si alguien se olvida del `START TRANSACTION`, o del `ROLLBACK` cuando algo falla, volvemos a tener inscripciones a medias. Con un **procedimiento almacenado**, la operación se escribe bien una vez y después se usa así:

```sql
-- ✅ Una línea, siempre igual
CALL sp_cambiar_asignatura(2, 13, 11);
```

> **¿Qué es un procedimiento almacenado?** Es un conjunto de sentencias SQL guardado en la base con un nombre. Puede recibir datos (**parámetros**), tomar decisiones con `IF`, repetir con bucles y manejar errores. Se ejecuta con `CALL`.

**Ventajas:**

- **Reutilización**: la lógica está en un solo lugar; si cambia, se corrige ahí.
- **Seguridad**: se puede permitir que un usuario ejecute el procedimiento sin darle permiso para modificar las tablas directamente ([Usuarios y permisos](Usuarios-y-permisos)).
- **Consistencia**: la aplicación web, el programa de escritorio y quien trabaje en Workbench hacen la operación exactamente igual.

**Desventajas:**

- La lógica queda "escondida" en la base: quien lee el código de la aplicación no la ve.
- El lenguaje es propio de cada motor: un procedimiento de MySQL no funciona tal cual en PostgreSQL ni en SQL Server.

---

## Sintaxis

```sql
DELIMITER $$

CREATE PROCEDURE <nombre>(<parámetros>)
BEGIN
    <sentencias>;
END$$

DELIMITER ;
```

### ¿Para qué es DELIMITER?

El cuerpo de un procedimiento tiene varias sentencias, cada una terminada en `;`. Pero el `;` es también la señal que usa Workbench para decir "acá termina, enviá esto al servidor". Sin avisarle nada, cortaría el `CREATE PROCEDURE` en el primer `;` que encuentre y MySQL recibiría un procedimiento por la mitad.

```text
DELIMITER $$        ← "desde ahora, lo que envío termina en $$"
CREATE PROCEDURE …
BEGIN
    …;              ← estos ; ya no cortan nada
    …;
END$$               ← acá termina: se envía todo junto
DELIMITER ;         ← "volvemos al ; de siempre"
```

`DELIMITER` no es una sentencia SQL: es una instrucción para el programa cliente (Workbench o la consola).

| Sentencia | Para qué sirve |
| --------- | -------------- |
| `CREATE PROCEDURE nombre(…) BEGIN … END` | Crea el procedimiento |
| `CALL nombre(…)` | Lo ejecuta |
| `DROP PROCEDURE IF EXISTS nombre` | Lo elimina |
| `SHOW PROCEDURE STATUS WHERE Db = 'liceo'` | Lista los procedimientos de la base |
| `SHOW CREATE PROCEDURE nombre` | Muestra su código |

> 📌 **Nota:** en este curso los procedimientos llevan el prefijo `sp_` (*stored procedure*), los parámetros `p_` y las variables locales `v_`. En el Paso 2 vemos por qué eso último importa.

---

## Paso 1 — Un procedimiento sin parámetros

```sql
DELIMITER $$

CREATE PROCEDURE sp_listar_grupos()
BEGIN
    SELECT id_grupo, nombre, turno
    FROM grupo
    ORDER BY nombre;
END$$

DELIMITER ;
```

En Workbench aparece en el panel **Schemas**, dentro de `liceo` → **Stored Procedures**. Para ejecutarlo:

```sql
CALL sp_listar_grupos();
```

**Resultado:**

| id_grupo | nombre | turno |
| -------- | ------ | ----- |
| 3 | 2ºA | matutino |
| 4 | 2ºB | nocturno |
| 1 | 3ºA | matutino |
| 2 | 3ºB | vespertino |

---

## Paso 2 — Parámetros de entrada (IN)

Un parámetro `IN` es un dato que el procedimiento **recibe**. Las notas de un estudiante cualquiera:

```sql
DELIMITER $$

CREATE PROCEDURE sp_notas_estudiante(IN p_id_estudiante INT)
BEGIN
    SELECT a.nombre AS asignatura, i.nota
    FROM inscripcion AS i
    INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
    WHERE i.id_estudiante = p_id_estudiante
    ORDER BY a.nombre;
END$$

DELIMITER ;
```

```sql
CALL sp_notas_estudiante(1);
```

**Resultado:**

| asignatura | nota |
| ---------- | ---- |
| Física | 7.00 |
| Matemática | 9.50 |
| Programación | 11.00 |

```sql
CALL sp_notas_estudiante(5);
```

**Resultado:**

| asignatura | nota |
| ---------- | ---- |
| Historia | 9.00 |
| Matemática | 12.00 |
| Química | 8.50 |

> ⚠️ **Nunca llamar a un parámetro igual que una columna.** Si el parámetro se llamara `id_estudiante`, la condición `WHERE id_estudiante = id_estudiante` compararía el parámetro consigo mismo: siempre verdadera, para todas las filas. En un `SELECT` devuelve de más; en un `DELETE`, borra la tabla entera. Por eso el prefijo `p_`.

---

## Paso 3 — Parámetros de salida (OUT)

Un parámetro `OUT` es un dato que el procedimiento **devuelve**. Dentro del procedimiento se carga con `SELECT … INTO`:

```sql
DELIMITER $$

CREATE PROCEDURE sp_promedio_estudiante(
    IN  p_id_estudiante INT,
    OUT p_promedio      DECIMAL(4,2)
)
BEGIN
    SELECT ROUND(AVG(nota), 2)
    INTO p_promedio
    FROM inscripcion
    WHERE id_estudiante = p_id_estudiante;
END$$

DELIMITER ;
```

Para recibir el valor hace falta una **variable de usuario**, que se escribe con `@`:

```sql
CALL sp_promedio_estudiante(5, @promedio);

SELECT @promedio AS promedio;
```

**Resultado:**

| promedio |
| -------- |
| 9.83 |

**Elementos clave:**

- `SELECT … INTO variable`: en lugar de mostrar el resultado, lo guarda. La consulta debe devolver **una sola fila**.
- `@promedio`: variable de la sesión. No se declara; existe desde que se usa y hasta que se cierra la conexión.
- El valor queda disponible para la sentencia siguiente, por ejemplo para compararlo con otro.

---

## Paso 4 — Variables locales y decisiones: DECLARE, SET, IF

Un procedimiento para inscribir, que **revisa antes de insertar**:

```sql
DELIMITER $$

CREATE PROCEDURE sp_inscribir(
    IN p_id_estudiante INT,
    IN p_id_asignatura INT
)
BEGIN
    DECLARE v_existe_estudiante INT;
    DECLARE v_existe_asignatura INT;
    DECLARE v_ya_inscripto      INT;

    SELECT COUNT(*) INTO v_existe_estudiante
    FROM estudiante
    WHERE id_estudiante = p_id_estudiante;

    SELECT COUNT(*) INTO v_existe_asignatura
    FROM asignatura
    WHERE id_asignatura = p_id_asignatura;

    SELECT COUNT(*) INTO v_ya_inscripto
    FROM inscripcion
    WHERE id_estudiante = p_id_estudiante
      AND id_asignatura = p_id_asignatura;

    IF v_existe_estudiante = 0 THEN
        SELECT 'Error: el estudiante no existe' AS resultado;
    ELSEIF v_existe_asignatura = 0 THEN
        SELECT 'Error: la asignatura no existe' AS resultado;
    ELSEIF v_ya_inscripto > 0 THEN
        SELECT 'Error: ya estaba inscripto' AS resultado;
    ELSE
        INSERT INTO inscripcion (id_estudiante, id_asignatura)
        VALUES (p_id_estudiante, p_id_asignatura);

        SELECT 'Inscripción realizada' AS resultado;
    END IF;
END$$

DELIMITER ;
```

Inscribimos a Agustín Núñez (10) en Filosofía (15):

```sql
CALL sp_inscribir(10, 15);
```

**Resultado:**

| resultado |
| --------- |
| Inscripción realizada |

La misma llamada, otra vez:

```sql
CALL sp_inscribir(10, 15);
```

**Resultado:**

| resultado |
| --------- |
| Error: ya estaba inscripto |

```sql
CALL sp_inscribir(99, 15);
```

**Resultado:**

| resultado |
| --------- |
| Error: el estudiante no existe |

**Elementos clave:**

- `DECLARE v_nombre TIPO;`: crea una variable **local**. Solo existe dentro del procedimiento. Los `DECLARE` van al principio del bloque, antes de cualquier otra sentencia.
- `SET v_nombre = valor;`: le asigna un valor (acá usamos `SELECT … INTO`, que hace lo mismo desde una consulta).
- `IF … THEN … ELSEIF … THEN … ELSE … END IF;`: la estructura de decisión. Cierra con `END IF` y punto y coma.

| Tipo de variable | Se escribe | Se crea con | Vive |
| ---------------- | ---------- | ----------- | ---- |
| Local | `v_total` | `DECLARE` | Mientras se ejecuta el procedimiento |
| De usuario | `@total` | Al asignarla | Hasta cerrar la conexión |
| Parámetro | `p_total` | En la definición | Mientras se ejecuta el procedimiento |

---

## Paso 5 — Errores propios y transacciones: SIGNAL y HANDLER

`sp_inscribir` informa los problemas con un texto, pero para MySQL la llamada "salió bien". Un programa que la invoque no se entera de que falló. Lo correcto es producir un **error de verdad**, con `SIGNAL`.

Además, queremos que si algo falla dentro de una transacción, el `ROLLBACK` se haga solo. Eso se declara con un **manejador** (*handler*).

```sql
DELIMITER $$

CREATE PROCEDURE sp_cambiar_asignatura(
    IN p_id_estudiante INT,
    IN p_desde         INT,
    IN p_hacia         INT
)
BEGIN
    -- Si ocurre cualquier error: deshacer y volver a lanzar el error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    DELETE FROM inscripcion
    WHERE id_estudiante = p_id_estudiante
      AND id_asignatura = p_desde;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El estudiante no está inscripto en la asignatura de origen';
    END IF;

    INSERT INTO inscripcion (id_estudiante, id_asignatura)
    VALUES (p_id_estudiante, p_hacia);

    COMMIT;
END$$

DELIMITER ;
```

**Caso 1: todo sale bien.** Mateo Silva cambia Química (13) por Física (11):

```sql
CALL sp_cambiar_asignatura(2, 13, 11);

SELECT a.nombre AS asignatura, i.nota
FROM inscripcion AS i
INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
WHERE i.id_estudiante = 2
ORDER BY a.nombre;
```

**Resultado:**

| asignatura | nota |
| ---------- | ---- |
| Física | NULL |
| Matemática | 8.00 |

**Caso 2: falla el `INSERT`.** Martina Suárez (9) quiere cambiar Química por la asignatura 99, que no existe:

```sql
CALL sp_cambiar_asignatura(9, 13, 99);
```

```text
Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`liceo`.`inscripcion`, CONSTRAINT `fk_inscripcion_asignatura` FOREIGN KEY (`id_asignatura`) REFERENCES `asignatura` (`id_asignatura`))
```

El `DELETE` ya se había ejecutado, pero el manejador hizo el `ROLLBACK`:

```sql
SELECT id_asignatura, nota
FROM inscripcion
WHERE id_estudiante = 9
ORDER BY id_asignatura;
```

**Resultado:**

| id_asignatura | nota |
| ------------- | ---- |
| 13 | 7.00 |
| 14 | NULL |

Martina conserva Química. En el módulo anterior, este mismo caso dependía de que nos acordáramos de escribir `ROLLBACK`.

**Caso 3: nuestro propio error.** Martina no cursa Matemática (10):

```sql
CALL sp_cambiar_asignatura(9, 10, 11);
```

```text
Error Code: 1644. El estudiante no está inscripto en la asignatura de origen
```

**Elementos clave:**

- `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '…'`: lanza un error definido por nosotros. `45000` es el código reservado para eso; MySQL lo muestra como `Error 1644`.
- `DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN … END;`: "si ocurre cualquier error, ejecutá este bloque y salí del procedimiento". Se declara después de las variables.
- `RESIGNAL`: vuelve a lanzar el error original, para que quien llamó se entere de **qué** falló.
- `ROW_COUNT()`: cantidad de filas que modificó la última sentencia.

---

## Paso 6 — Repetir: WHILE

Al empezar el año hay que crear varios grupos de un mismo nivel: `1ºA`, `1ºB`, `1ºC`…

```sql
DELIMITER $$

CREATE PROCEDURE sp_crear_grupos(
    IN p_nivel    INT,
    IN p_cantidad INT,
    IN p_turno    VARCHAR(10)
)
BEGIN
    DECLARE v_i INT DEFAULT 1;

    WHILE v_i <= p_cantidad DO
        INSERT INTO grupo (nombre, turno)
        VALUES (CONCAT(p_nivel, 'º', CHAR(64 + v_i USING utf8mb4)), p_turno);

        SET v_i = v_i + 1;
    END WHILE;
END$$

DELIMITER ;
```

```sql
CALL sp_crear_grupos(1, 3, 'vespertino');

SELECT id_grupo, nombre, turno
FROM grupo
ORDER BY id_grupo;
```

**Resultado:**

| id_grupo | nombre | turno |
| -------- | ------ | ----- |
| 1 | 3ºA | matutino |
| 2 | 3ºB | vespertino |
| 3 | 2ºA | matutino |
| 4 | 2ºB | nocturno |
| 5 | 1ºA | vespertino |
| 6 | 1ºB | vespertino |
| 7 | 1ºC | vespertino |

`CHAR(65)` es la letra `A`, `CHAR(66)` la `B`, y así. El bucle dio tres vueltas, con `v_i` valiendo 1, 2 y 3.

> ⚠️ **Cuidado con los bucles infinitos:** si falta el `SET v_i = v_i + 1`, la condición nunca deja de cumplirse y el procedimiento no termina. Se corta desde Workbench con el botón de **Stop** (el cuadrado rojo).

> 📌 **Nota:** MySQL tiene otros dos bucles, `REPEAT … UNTIL` y `LOOP`, y **cursores** para recorrer fila por fila el resultado de una consulta. Antes de usarlos conviene preguntarse si no alcanza con un solo `UPDATE` o `INSERT … SELECT`: trabajar con conjuntos casi siempre es más simple y mucho más rápido que ir fila por fila.

---

## Paso 7 — Listar, modificar y eliminar

```sql
SHOW PROCEDURE STATUS
WHERE Db = 'liceo';
```

**Resultado** (columnas principales):

| Db | Name | Type |
| --- | ---- | ---- |
| liceo | sp_cambiar_asignatura | PROCEDURE |
| liceo | sp_crear_grupos | PROCEDURE |
| liceo | sp_inscribir | PROCEDURE |
| liceo | sp_listar_grupos | PROCEDURE |
| liceo | sp_notas_estudiante | PROCEDURE |
| liceo | sp_promedio_estudiante | PROCEDURE |

El cuerpo de un procedimiento **no se puede modificar**: se elimina y se vuelve a crear. Por eso los scripts suelen empezar así:

```sql
DROP PROCEDURE IF EXISTS sp_listar_grupos;

DELIMITER $$

CREATE PROCEDURE sp_listar_grupos()
BEGIN
    SELECT id_grupo, nombre, turno
    FROM grupo
    ORDER BY turno, nombre;
END$$

DELIMITER ;
```

> ⚠️ **Atención:** `DROP PROCEDURE` no pide confirmación. Los datos de las tablas no se tocan, pero el código se pierde si no está guardado en un archivo `.sql`.

---

## Diferencia clave: parámetros IN vs OUT vs INOUT

| Aspecto | `IN` | `OUT` | `INOUT` |
| ------- | ---- | ----- | ------- |
| Dirección | Entra | Sale | Entra y sale |
| Al llamar se pasa | Un valor o una variable | Una variable (`@x`) | Una variable (`@x`) con valor |
| Valor inicial adentro | El que se pasó | `NULL` | El que se pasó |
| Si no se aclara | Es el tipo por defecto | — | — |
| Ejemplo | `p_id_estudiante` | `p_promedio` | Un contador que se incrementa |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1064` cerca de la primera línea del cuerpo | Falta el `DELIMITER $$`: el procedimiento se cortó en el primer `;` | Envolver el `CREATE` con `DELIMITER $$` … `DELIMITER ;` |
| Después de crear el procedimiento, nada más funciona | Faltó el `DELIMITER ;` final y Workbench sigue esperando `$$` | Ejecutar `DELIMITER ;` |
| `Error 1304`: *PROCEDURE … already exists* | Ya hay uno con ese nombre | `DROP PROCEDURE IF EXISTS` antes del `CREATE` |
| `Error 1305`: *PROCEDURE … does not exist* | Nombre mal escrito, o se está en otra base | Verificar con `SHOW PROCEDURE STATUS` y `USE liceo` |
| `Error 1318`: *Incorrect number of arguments* | Se llamó con más o menos parámetros de los definidos | Revisar la definición |
| `Error 1172`: *Result consisted of more than one row* | Un `SELECT … INTO` devolvió varias filas | Ajustar el `WHERE`, o usar una función de agrupación |
| `Error 1337`: *Variable or condition declaration after cursor or handler declaration* | Un `DECLARE` de variable quedó después del `HANDLER` | Orden: variables, después manejadores, después el resto |
| El procedimiento afecta todas las filas | Un parámetro se llama igual que una columna | Prefijo `p_` en los parámetros |

---

Continuamos por rutinas que devuelven un valor y se usan dentro de las consultas → [Funciones almacenadas](Funciones-almacenadas)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Creá `sp_estudiantes_grupo`, que recibe el **nombre** de un grupo y lista nombre y apellido de sus estudiantes, por apellido. Probalo con `3ºA`.

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE PROCEDURE sp_estudiantes_grupo(IN p_nombre_grupo VARCHAR(10))
BEGIN
    SELECT e.nombre, e.apellido
    FROM estudiante AS e
    INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo
    WHERE g.nombre = p_nombre_grupo
    ORDER BY e.apellido;
END$$

DELIMITER ;

CALL sp_estudiantes_grupo('3ºA');
```

| nombre | apellido |
| ------ | -------- |
| Lucía | Fernández |
| Santiago | Pérez |
| Valentina | Rodríguez |

💡 El tipo del parámetro coincide con el de la columna con la que se compara: `grupo.nombre` es `VARCHAR(10)`.
</details>

**2.** Creá `sp_cantidad_inscriptos`, que recibe un `id_asignatura` y devuelve la cantidad de inscriptos en un parámetro de salida. Probalo con Matemática (10).

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE PROCEDURE sp_cantidad_inscriptos(
    IN  p_id_asignatura INT,
    OUT p_cantidad      INT
)
BEGIN
    SELECT COUNT(*)
    INTO p_cantidad
    FROM inscripcion
    WHERE id_asignatura = p_id_asignatura;
END$$

DELIMITER ;

CALL sp_cantidad_inscriptos(10, @cantidad);

SELECT @cantidad AS inscriptos;
```

| inscriptos |
| ---------- |
| 7 |

💡 `COUNT(*)` siempre devuelve exactamente una fila, así que el `SELECT … INTO` nunca falla.
</details>

**3.** Creá `sp_poner_nota`, que recibe estudiante, asignatura y nota. Si la nota no está entre 1 y 12, o si la inscripción no existe, debe lanzar un error propio; si todo está bien, actualiza la nota. Probá ponerle un 8 y después un 15 a Santiago Pérez (4) en Programación (14).

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE PROCEDURE sp_poner_nota(
    IN p_id_estudiante INT,
    IN p_id_asignatura INT,
    IN p_nota          DECIMAL(4,2)
)
BEGIN
    DECLARE v_existe INT;

    IF p_nota < 1 OR p_nota > 12 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La nota debe estar entre 1 y 12';
    END IF;

    SELECT COUNT(*) INTO v_existe
    FROM inscripcion
    WHERE id_estudiante = p_id_estudiante
      AND id_asignatura = p_id_asignatura;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El estudiante no está inscripto en esa asignatura';
    END IF;

    UPDATE inscripcion
    SET nota = p_nota
    WHERE id_estudiante = p_id_estudiante
      AND id_asignatura = p_id_asignatura;
END$$

DELIMITER ;

CALL sp_poner_nota(4, 14, 8);

SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE id_estudiante = 4
  AND id_asignatura = 14;
```

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 4 | 14 | 8.00 |

```sql
CALL sp_poner_nota(4, 14, 15);
```

```text
Error Code: 1644. La nota debe estar entre 1 y 12
```

💡 Después de un `SIGNAL`, el procedimiento se interrumpe: no hace falta un `ELSE`. La restricción `CHECK` de la tabla también habría rechazado el 15, pero con un mensaje menos claro.
</details>

**4.** Sin ejecutarlo: ¿qué hace este procedimiento cuando se llama con `CALL sp_baja(3);`?

```sql
CREATE PROCEDURE sp_baja(IN id_estudiante INT)
BEGIN
    DELETE FROM inscripcion
    WHERE id_estudiante = id_estudiante;
END
```

<details>
<summary>Ver solución</summary>

**Elimina todas las inscripciones del liceo**, no solo las del estudiante 3.

💡 Dentro del procedimiento, `id_estudiante` es el parámetro, en los dos lados de la comparación. `3 = 3` es verdadero para todas las filas. Con el parámetro llamado `p_id_estudiante` el problema desaparece.
</details>

**5.** Creá `sp_mover_grupo`, que pasa a todos los estudiantes de un grupo a otro dentro de una transacción. Si el grupo de destino no existe, debe lanzar un error propio. Al final muestra cuántos estudiantes se movieron. Probalo pasando el grupo 3 al 4.

<details>
<summary>Ver solución</summary>

```sql
DELIMITER $$

CREATE PROCEDURE sp_mover_grupo(
    IN p_desde INT,
    IN p_hacia INT
)
BEGIN
    DECLARE v_existe  INT;
    DECLARE v_movidos INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*) INTO v_existe
    FROM grupo
    WHERE id_grupo = p_hacia;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El grupo de destino no existe';
    END IF;

    START TRANSACTION;

    UPDATE estudiante
    SET id_grupo = p_hacia
    WHERE id_grupo = p_desde;

    SET v_movidos = ROW_COUNT();

    COMMIT;

    SELECT v_movidos AS estudiantes_movidos;
END$$

DELIMITER ;

CALL sp_mover_grupo(3, 4);
```

| estudiantes_movidos |
| ------------------- |
| 3 |

💡 `ROW_COUNT()` hay que guardarlo enseguida: cada sentencia nueva (incluido el `COMMIT`) lo vuelve a calcular.
</details>

---

## 📋 Palabras clave

`procedimiento almacenado` · `CREATE PROCEDURE` · `CALL` · `DELIMITER` · `BEGIN … END` · `parámetro IN` · `parámetro OUT` · `DECLARE` · `SET` · `SELECT … INTO` · `IF` · `WHILE` · `SIGNAL` · `HANDLER` · `ROW_COUNT()` · `variable de usuario`

---

🧠 **[Autoevaluación — Módulo 10](auto-modulo10)**

---

← [Resumen del Módulo 9](Resumen-Modulo9) · [🏠 Inicio](Home) · [Funciones almacenadas →](Funciones-almacenadas)
