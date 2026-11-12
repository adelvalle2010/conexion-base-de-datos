> 🗄️ **Base de datos:** `liceo` (Módulo 9 — Rendimiento y Transacciones) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🔐 Transacciones y propiedades ACID

Dejamos por un momento `liceo_grande` y volvemos a la base chica, `liceo`: para ver qué pasa con cada fila conviene tener pocas. Antes de empezar, ejecutá de nuevo `liceo.sql` para tener los datos originales.

> ⚠️ **Esta página modifica datos.** Al terminarla, volvé a ejecutar `liceo.sql` para dejar la base como la esperan las demás páginas.

## ¿Por qué lo necesitamos?

Mateo Silva (estudiante 2) quiere cambiar Química (13) por Física (11). Son dos sentencias:

```sql
-- ❌ Dos sentencias sueltas
DELETE FROM inscripcion
WHERE id_estudiante = 2
  AND id_asignatura = 13;

INSERT INTO inscripcion (id_estudiante, id_asignatura)
VALUES (2, 11);
```

¿Qué pasa si después del `DELETE` se corta la luz, se cae la conexión o el `INSERT` da error? Mateo queda **sin Química y sin Física**. La base no está rota, pero dice algo que no es cierto, y nadie se entera.

El cambio de asignatura es **una sola operación** para el liceo, aunque para SQL sean dos sentencias. Una transacción permite decirle eso a MySQL:

```sql
-- ✅ Las dos, o ninguna
START TRANSACTION;

DELETE FROM inscripcion
WHERE id_estudiante = 2
  AND id_asignatura = 13;

INSERT INTO inscripcion (id_estudiante, id_asignatura)
VALUES (2, 11);

COMMIT;
```

> **¿Qué es una transacción?** Es un grupo de sentencias que MySQL trata como **una unidad**: o se aplican todas, o no se aplica ninguna. Mientras está abierta, los cambios son provisorios; al final se **confirman** (`COMMIT`) o se **deshacen** (`ROLLBACK`).

---

## Sintaxis

```sql
START TRANSACTION;
    <sentencias INSERT, UPDATE, DELETE>
COMMIT;      -- o ROLLBACK;
```

| Sentencia | Para qué sirve |
| --------- | -------------- |
| `START TRANSACTION` | Abre una transacción (también se puede escribir `BEGIN`) |
| `COMMIT` | Confirma todos los cambios y cierra la transacción |
| `ROLLBACK` | Deshace todos los cambios y cierra la transacción |
| `SAVEPOINT nombre` | Marca un punto intermedio |
| `ROLLBACK TO nombre` | Deshace hasta ese punto, sin cerrar la transacción |
| `SET autocommit = 0` | Desactiva la confirmación automática en la sesión |

### Anatomía de una transacción

```text
                              ┌──────────▶ COMMIT   ──▶ cambios definitivos
 START TRANSACTION ──▶ sentencias
   (estado A)          (cambios provisorios)
                              └──────────▶ ROLLBACK ──▶ todo vuelve al estado A
```

---

## Paso 1 — El modo autocommit

```sql
SELECT @@autocommit;
```

**Resultado:**

| @@autocommit |
| ------------ |
| 1 |

El valor `1` significa que MySQL trabaja en modo **autocommit**: cada sentencia es una transacción de una sola sentencia, que se confirma sola apenas termina. Así trabajamos en todo el curso, y por eso en el [Módulo 6](DELETE-eliminar-registros) un `DELETE` sin `WHERE` no tenía vuelta atrás.

`START TRANSACTION` suspende el autocommit hasta el próximo `COMMIT` o `ROLLBACK`.

---

## Paso 2 — ROLLBACK: deshacer

Vamos a cometer el error más temido, a propósito y con red:

```sql
START TRANSACTION;

UPDATE inscripcion
SET nota = 1;
```

Nos olvidamos el `WHERE`. Workbench informa `21 row(s) affected`:

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE id_estudiante <= 2
ORDER BY id_estudiante, id_asignatura;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 10 | 1.00 |
| 1 | 11 | 1.00 |
| 1 | 14 | 1.00 |
| 2 | 10 | 1.00 |
| 2 | 13 | 1.00 |

Todas las notas del liceo valen 1. Pero la transacción sigue abierta:

```sql
ROLLBACK;
```

```sql
SELECT id_estudiante, id_asignatura, nota
FROM inscripcion
WHERE id_estudiante <= 2
ORDER BY id_estudiante, id_asignatura;
```

**Resultado:**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1 | 10 | 9.50 |
| 1 | 11 | 7.00 |
| 1 | 14 | 11.00 |
| 2 | 10 | 8.00 |
| 2 | 13 | 5.00 |

Las notas originales están de vuelta.

> 💡 Una buena costumbre antes de un `UPDATE` o `DELETE` delicado: abrir una transacción, ejecutarlo, revisar el resultado con un `SELECT` y recién entonces decidir entre `COMMIT` y `ROLLBACK`.

---

## Paso 3 — COMMIT: confirmar

Ahora sí, el cambio de asignatura de Mateo:

```sql
START TRANSACTION;

DELETE FROM inscripcion
WHERE id_estudiante = 2
  AND id_asignatura = 13;

INSERT INTO inscripcion (id_estudiante, id_asignatura)
VALUES (2, 11);

COMMIT;
```

```sql
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

> ⚠️ **Después del `COMMIT` no hay vuelta atrás.** Un `ROLLBACK` posterior no da error, pero no deshace nada: ya no hay transacción abierta.

---

## Paso 4 — Cuando una sentencia falla a mitad de camino

Martina Suárez (9) quiere cambiar Química (13) por la asignatura 99, que no existe.

```sql
START TRANSACTION;

DELETE FROM inscripcion
WHERE id_estudiante = 9
  AND id_asignatura = 13;
```

```sql
INSERT INTO inscripcion (id_estudiante, id_asignatura)
VALUES (9, 99);
```

```text
Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails
```

El `INSERT` falló. ¿Y el `DELETE`?

```sql
SELECT id_asignatura, nota
FROM inscripcion
WHERE id_estudiante = 9
ORDER BY id_asignatura;
```

**Resultado:**

| id_asignatura | nota |
| ------------- | ---- |
| 14 | NULL |

Química ya no está. **MySQL no deshace la transacción por su cuenta cuando una sentencia da error**: anula solo esa sentencia y deja la transacción abierta, esperando nuestra decisión. Si ahora hiciéramos `COMMIT`, quedaría confirmado el trabajo a medias. Lo correcto es:

```sql
ROLLBACK;
```

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

> 📌 **Nota:** cuando las transacciones las ejecuta un programa (lo vamos a hacer con procedimientos almacenados en el [Módulo 10](Procedimientos-almacenados) y se hace igual desde Java), el código detecta el error y ejecuta el `ROLLBACK` automáticamente.

---

## Paso 5 — SAVEPOINT: deshacer solo una parte

Un `SAVEPOINT` es un marcador dentro de la transacción al que se puede volver.

```sql
START TRANSACTION;

-- Bien: la nota de Programación de Santiago Pérez
UPDATE inscripcion
SET nota = 9.00
WHERE id_estudiante = 4
  AND id_asignatura = 14;

SAVEPOINT nota_santiago;

-- Mal: faltó el estudiante en el WHERE
UPDATE inscripcion
SET nota = 2.00
WHERE id_asignatura = 14;
```

```sql
SELECT id_estudiante, nota
FROM inscripcion
WHERE id_asignatura = 14
ORDER BY id_estudiante;
```

**Resultado:**

| id_estudiante | nota |
| ------------- | ---- |
| 1 | 2.00 |
| 4 | 2.00 |
| 7 | 2.00 |
| 9 | 2.00 |

Volvemos al marcador. Se deshace el segundo `UPDATE`, se conserva el primero:

```sql
ROLLBACK TO nota_santiago;
```

```sql
SELECT id_estudiante, nota
FROM inscripcion
WHERE id_asignatura = 14
ORDER BY id_estudiante;
```

**Resultado:**

| id_estudiante | nota |
| ------------- | ---- |
| 1 | 11.00 |
| 4 | 9.00 |
| 7 | 9.00 |
| 9 | NULL |

La transacción **sigue abierta**. Para que la nota de Santiago quede guardada falta confirmar:

```sql
COMMIT;
```

---

## Paso 6 — Lo que una transacción no puede deshacer

Las sentencias que cambian la **estructura** de la base hacen un `COMMIT` automático antes de ejecutarse. Se llama **commit implícito**.

| Sentencias | ¿Se pueden deshacer con `ROLLBACK`? |
| ---------- | ----------------------------------- |
| `INSERT`, `UPDATE`, `DELETE` | Sí |
| `CREATE`, `ALTER`, `DROP` (tablas, índices, vistas) | No, y además confirman todo lo anterior |
| `TRUNCATE TABLE` | No, y además confirma todo lo anterior |
| `START TRANSACTION` con otra transacción ya abierta | Confirma la anterior y abre una nueva |

```sql
START TRANSACTION;

DELETE FROM inscripcion
WHERE id_asignatura = 12;

CREATE TABLE prueba (id INT);   -- ⚠️ commit implícito: el DELETE quedó confirmado

ROLLBACK;                       -- ya no hay nada que deshacer
```

> ⚠️ **Otra diferencia entre `DELETE` y `TRUNCATE`:** un `DELETE` sin `WHERE` dentro de una transacción se puede deshacer; un `TRUNCATE`, nunca.

---

## Las propiedades ACID

Un motor de base de datos que soporta transacciones garantiza cuatro propiedades. Sus iniciales forman la sigla **ACID**.

| Propiedad | Garantiza que… | En el liceo |
| --------- | -------------- | ----------- |
| **A**tomicidad | La transacción se aplica entera o no se aplica | Mateo nunca queda sin las dos asignaturas |
| **C**onsistencia | La base pasa de un estado válido a otro estado válido, respetando todas las restricciones | No puede quedar una inscripción a la asignatura 99 ni una nota 15 |
| A**i**slamiento (*Isolation*) | Las transacciones simultáneas no se interfieren | Mientras se cambian las notas, otro usuario no ve valores a medio cambiar |
| **D**urabilidad | Lo confirmado no se pierde, aunque se apague el servidor un segundo después | Tras el `COMMIT`, la inscripción a Física está guardada en disco |

De las cuatro, el aislamiento es la que tiene más matices. Le dedicamos la página siguiente.

> 📌 **Nota:** en MySQL, las transacciones dependen del **motor de almacenamiento** de la tabla. InnoDB, el motor por defecto y el que usamos en todo el curso, las soporta. El viejo motor MyISAM no: en una tabla MyISAM, `ROLLBACK` no deshace nada.

## Transacciones en Workbench

- En la barra del editor hay un botón de **autocommit** (junto a los rayos). Si lo desactivás, toda sentencia queda pendiente hasta que presiones los botones de **Commit** (✔) o **Rollback** (✖) que están al lado.
- Si cerrás la conexión con una transacción abierta, MySQL hace `ROLLBACK`: los cambios sin confirmar **se pierden**.

## Diferencia clave: COMMIT vs ROLLBACK

| Aspecto | `COMMIT` | `ROLLBACK` |
| ------- | -------- | ---------- |
| Qué hace con los cambios | Los vuelve definitivos | Los descarta |
| Cierra la transacción | Sí | Sí (`ROLLBACK TO` no) |
| Los demás usuarios ven los cambios | A partir de ese momento | Nunca |
| ¿Se puede deshacer? | No | No hace falta: no cambió nada |
| Cuándo se usa | Todas las sentencias salieron bien | Hubo un error o el resultado no es el esperado |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| Los cambios "desaparecen" al reabrir Workbench | Se cerró la conexión con la transacción abierta, sin `COMMIT` | Confirmar antes de cerrar |
| Quedó aplicada la mitad de la operación | Una sentencia dio error y después se hizo `COMMIT` | Ante un error dentro de una transacción, `ROLLBACK` |
| `ROLLBACK` no deshace un `UPDATE` | No había transacción abierta: el autocommit ya lo confirmó | Escribir `START TRANSACTION` **antes** |
| `ROLLBACK` no deshace lo anterior a un `CREATE` o `ALTER` | Commit implícito | No mezclar cambios de estructura dentro de una transacción |
| `Error 1305`: *SAVEPOINT … does not exist* | El nombre está mal escrito, o la transacción ya se cerró | Los `SAVEPOINT` desaparecen con el `COMMIT` o el `ROLLBACK` |
| Otros usuarios quedan "colgados" esperando | Una transacción quedó abierta mucho tiempo y bloquea filas | Transacciones cortas: abrir, modificar, confirmar |

---

Continuamos por lo que pasa cuando dos transacciones trabajan al mismo tiempo sobre los mismos datos → [Concurrencia, bloqueos y niveles de aislamiento](Concurrencia-y-bloqueos)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Dentro de una transacción, eliminá todas las inscripciones de Matemática (10), contá cuántas inscripciones quedan, deshacé el cambio y volvé a contar.

<details>
<summary>Ver solución</summary>

```sql
START TRANSACTION;

DELETE FROM inscripcion
WHERE id_asignatura = 10;

SELECT COUNT(*) AS inscripciones
FROM inscripcion;
```

| inscripciones |
| ------------- |
| 14 |

```sql
ROLLBACK;

SELECT COUNT(*) AS inscripciones
FROM inscripcion;
```

| inscripciones |
| ------------- |
| 21 |

💡 Dentro de la transacción, nuestra propia sesión ve los cambios provisorios. Después del `ROLLBACK`, es como si nunca hubieran ocurrido.
</details>

**2.** En una sola transacción, creá el grupo `1ºA` (id 5, turno vespertino) y pasá a Agustín Núñez (estudiante 10) a ese grupo. Confirmá y comprobá el resultado.

<details>
<summary>Ver solución</summary>

```sql
START TRANSACTION;

INSERT INTO grupo (id_grupo, nombre, turno)
VALUES (5, '1ºA', 'vespertino');

UPDATE estudiante
SET id_grupo = 5
WHERE id_estudiante = 10;

COMMIT;
```

```sql
SELECT e.nombre, e.apellido, g.nombre AS grupo, g.turno
FROM estudiante AS e
INNER JOIN grupo AS g ON g.id_grupo = e.id_grupo
WHERE e.id_estudiante = 10;
```

| nombre | apellido | grupo | turno |
| ------ | -------- | ----- | ----- |
| Agustín | Núñez | 1ºA | vespertino |

💡 El orden importa por la clave foránea: primero tiene que existir el grupo. Si el `UPDATE` fallara, con un `ROLLBACK` tampoco quedaría un grupo vacío creado.
</details>

**3.** Sin ejecutarlo: ¿qué docentes nuevos quedan en la tabla al terminar?

```sql
START TRANSACTION;

INSERT INTO docente (id_docente, nombre, apellido) VALUES (6, 'Pablo', 'Rivas');

SAVEPOINT uno;

INSERT INTO docente (id_docente, nombre, apellido) VALUES (7, 'Rosa', 'Lema');

ROLLBACK TO uno;

INSERT INTO docente (id_docente, nombre, apellido) VALUES (8, 'Jorge', 'Viera');

COMMIT;
```

<details>
<summary>Ver solución</summary>

```sql
SELECT id_docente, nombre, apellido
FROM docente
WHERE id_docente > 5
ORDER BY id_docente;
```

| id_docente | nombre | apellido |
| ---------- | ------ | -------- |
| 6 | Pablo | Rivas |
| 8 | Jorge | Viera |

💡 `ROLLBACK TO uno` deshace solo lo que vino después del marcador (Rosa Lema). La transacción sigue, se inserta a Jorge Viera y el `COMMIT` confirma lo que quedó.
</details>

**4.** Sin ejecutarlo: ¿cuántas inscripciones tiene la tabla al final?

```sql
START TRANSACTION;

DELETE FROM inscripcion;

ALTER TABLE docente ADD COLUMN telefono VARCHAR(20);

ROLLBACK;
```

<details>
<summary>Ver solución</summary>

**Cero.**

💡 El `ALTER TABLE` hace un commit implícito, que confirma el `DELETE`. Cuando llega el `ROLLBACK` ya no hay transacción abierta. Si lo probaste, volvé a ejecutar `liceo.sql`.
</details>

**5.** Un compañero ejecuta `SET autocommit = 0;`, después un `UPDATE` que corrige diez notas, ve el resultado correcto con un `SELECT` y cierra Workbench. Al otro día las notas están como antes. ¿Qué pasó?

<details>
<summary>Ver solución</summary>

Con el autocommit desactivado, el `UPDATE` abrió una transacción que nunca se confirmó. El `SELECT` mostraba los cambios porque la propia sesión siempre ve lo suyo. Al cerrar la conexión, MySQL hizo `ROLLBACK`.

💡 Faltó un `COMMIT` antes de cerrar.
</details>

---

## 📋 Palabras clave

`transacción` · `START TRANSACTION` · `COMMIT` · `ROLLBACK` · `SAVEPOINT` · `ROLLBACK TO` · `autocommit` · `commit implícito` · `ACID` · `atomicidad` · `consistencia` · `aislamiento` · `durabilidad` · `InnoDB`

---

🧠 **[Autoevaluación — Módulo 9](auto-modulo9)**

---

← [EXPLAIN](EXPLAIN) · [🏠 Inicio](Home) · [Concurrencia y bloqueos →](Concurrencia-y-bloqueos)
