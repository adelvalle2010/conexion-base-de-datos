> 🗄️ **Base de datos:** `liceo` (Módulo 9 — Rendimiento y Transacciones) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo7/liceo.sql)

# 🚦 Concurrencia, bloqueos y niveles de aislamiento

## ¿Qué es la concurrencia?

**Concurrencia** es que varias sesiones trabajen sobre la misma base **al mismo tiempo**. Hasta ahora fuimos los únicos usuarios de `liceo`. En un sistema real hay decenas de personas y programas conectados a la vez: la adscripta que inscribe, tres docentes que pasan notas, la web donde las familias consultan.

Esta página corresponde a la **I** de ACID, el aislamiento: qué ve cada sesión de lo que están haciendo las demás, y qué pasa cuando dos quieren modificar lo mismo.

**Características principales:**

- Cada conexión a MySQL es una **sesión** independiente, con sus propias transacciones.
- MySQL usa **bloqueos** para que dos sesiones no modifiquen la misma fila a la vez.
- El **nivel de aislamiento** define cuánto de lo que hacen las demás puede ver una transacción.

## ¿Qué problema resuelve?

Santiago Pérez tiene un 4 en Matemática. Dos docentes le suben un punto por trabajos distintos, casi en el mismo instante, cada uno desde su programa:

```text
 Tiempo   Sesión A (docente 1)                 Sesión B (docente 2)
 ──────   ──────────────────────────────────   ──────────────────────────────────
   1      lee la nota: 4
   2                                           lee la nota: 4
   3      calcula 4 + 1 y guarda 5
   4                                           calcula 4 + 1 y guarda 5      -- ❌

 Resultado: 5. Debería ser 6: una de las dos subidas se perdió.
```

Se llama **actualización perdida**. Nadie recibió un error y la base respeta todas sus restricciones; simplemente, el dato está mal. Los mecanismos de esta página existen para que eso no ocurra.

---

## Cómo practicar: dos sesiones en Workbench

Para ver la concurrencia hacen falta **dos conexiones**. Dos pestañas de consulta dentro de la misma conexión **no sirven**: comparten la sesión.

## Paso 1 — Abrir dos sesiones

1. En Workbench, ir a la pantalla de inicio (ícono de la casita, arriba a la izquierda).
2. Hacer clic otra vez en la misma conexión. Se abre una segunda pestaña grande, con su propia sesión.
3. En las dos, ejecutar `USE liceo;`. Llamamos **Sesión A** a la primera y **Sesión B** a la segunda.

Para comprobar que son sesiones diferentes, ejecutar en cada una:

```sql
SELECT CONNECTION_ID();
```

Tienen que dar números distintos.

> ⚠️ **Esta página modifica datos.** Antes de empezar y al terminar, ejecutá `liceo.sql`.

---

## Paso 2 — Lo que no está confirmado, los demás no lo ven

| Orden | Sesión A | Sesión B |
| ----- | -------- | -------- |
| 1 | `START TRANSACTION;` | |
| 2 | `UPDATE inscripcion SET nota = 10 WHERE id_estudiante = 4 AND id_asignatura = 10;` | |
| 3 | `SELECT nota …` → **10.00** | |
| 4 | | `SELECT nota …` → **4.00** |
| 5 | `COMMIT;` | |
| 6 | | `SELECT nota …` → **10.00** |

El `SELECT` de las dos sesiones es el mismo:

```sql
SELECT nota
FROM inscripcion
WHERE id_estudiante = 4
  AND id_asignatura = 10;
```

En el momento 4, la Sesión B sigue viendo el 4: el cambio de A es provisorio y podría terminar en `ROLLBACK`. MySQL le muestra a B la última versión **confirmada** de la fila, y B no tiene que esperar para leer.

---

## Paso 3 — Bloqueos: dos sesiones quieren modificar la misma fila

Volvé a poner la nota en 4 (`UPDATE … SET nota = 4 …` en cualquiera de las dos) y probá:

| Orden | Sesión A | Sesión B |
| ----- | -------- | -------- |
| 1 | `START TRANSACTION;` | |
| 2 | `UPDATE inscripcion SET nota = 10 WHERE id_estudiante = 4 AND id_asignatura = 10;` | |
| 3 | | `UPDATE inscripcion SET nota = 5 WHERE id_estudiante = 4 AND id_asignatura = 10;` |
| 4 | | ⏳ *queda esperando…* |
| 5 | `COMMIT;` | |
| 6 | | ✔ el `UPDATE` termina en ese instante |

Al modificar la fila, A le puso un **bloqueo**. B puede leerla, pero para modificarla tiene que esperar a que A termine. Cuando A confirma, el bloqueo se libera y B continúa. El valor final es 5: B escribió último.

> **¿Qué es un bloqueo?** Es una marca que una transacción pone sobre una fila para avisar "la estoy modificando". Se libera solo con el `COMMIT` o el `ROLLBACK`. InnoDB bloquea **filas**, no tablas enteras: mientras A modifica la nota de Santiago, B puede modificar la de Lucía sin esperar.

¿Y si A nunca confirma? B no espera para siempre. Pasados 50 segundos (el valor de `innodb_lock_wait_timeout`):

```text
Error Code: 1205. Lock wait timeout exceeded; try restarting transaction
```

Por eso la regla de la página anterior: **transacciones cortas**. Una transacción abierta que alguien dejó olvidada antes de ir a almorzar frena a todos los que necesiten esas filas.

---

## Paso 4 — Leer para modificar: SELECT … FOR UPDATE

Volvamos al problema del principio. Los dos docentes hacen "leer, calcular, guardar". Con un `SELECT` común, los dos leen 4. La solución es bloquear la fila **desde la lectura**:

| Orden | Sesión A | Sesión B |
| ----- | -------- | -------- |
| 1 | `START TRANSACTION;` | `START TRANSACTION;` |
| 2 | `SELECT nota … FOR UPDATE;` → **4.00** | |
| 3 | | `SELECT nota … FOR UPDATE;` ⏳ *espera* |
| 4 | `UPDATE … SET nota = 5 …;` | |
| 5 | `COMMIT;` | |
| 6 | | → **5.00** (lee el valor ya actualizado) |
| 7 | | `UPDATE … SET nota = 6 …;` |
| 8 | | `COMMIT;` |

```sql
SELECT nota
FROM inscripcion
WHERE id_estudiante = 4
  AND id_asignatura = 10
FOR UPDATE;
```

`FOR UPDATE` significa "leo esta fila porque la voy a modificar": la bloquea igual que un `UPDATE`. B recién puede leer cuando A terminó, y lee el 5. Resultado final: **6**, el correcto.

> 💡 Cuando el nuevo valor se puede calcular en la misma sentencia, es más simple todavía: `UPDATE inscripcion SET nota = nota + 1 WHERE …`. Lee y escribe en un solo paso, con la fila bloqueada.

---

## Los tres problemas de lectura

Además de la actualización perdida, hay tres situaciones clásicas en las que una transacción **lee** algo inconveniente por culpa de otra:

| Problema | Qué pasa | Ejemplo |
| -------- | -------- | ------- |
| **Lectura sucia** | Se lee un dato que otra transacción modificó y **todavía no confirmó** | B lee que Santiago tiene 10; A hace `ROLLBACK`. B trabajó con una nota que nunca existió |
| **Lectura no repetible** | Dentro de la misma transacción, se lee dos veces la misma fila y da **valores distintos** | B lee un 4, A confirma un 6, B vuelve a leer y encuentra 6 |
| **Lectura fantasma** | Dentro de la misma transacción, se repite una consulta y aparecen **filas nuevas** | B cuenta 0 inscriptos en Filosofía, A inscribe a uno y confirma, B vuelve a contar y da 1 |

¿Por qué importa? Pensemos en un informe de fin de año que calcula promedios en varias consultas. Si los datos cambian entre una consulta y la siguiente, el informe sale con números que no cierran entre sí.

---

## Niveles de aislamiento

El estándar SQL define cuatro niveles. Cuanto más alto, menos problemas y más esperas.

| Nivel | Lectura sucia | Lectura no repetible | Lectura fantasma |
| ----- | ------------- | -------------------- | ---------------- |
| `READ UNCOMMITTED` | Puede ocurrir | Puede ocurrir | Puede ocurrir |
| `READ COMMITTED` | No | Puede ocurrir | Puede ocurrir |
| `REPEATABLE READ` *(por defecto en MySQL)* | No | No | No, en InnoDB |
| `SERIALIZABLE` | No | No | No |

```sql
SELECT @@transaction_isolation;
```

**Resultado:**

| @@transaction_isolation |
| ----------------------- |
| REPEATABLE-READ |

Para cambiarlo en la sesión actual (vale para las transacciones que se abran después):

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

> 📌 **Nota:** el estándar permite las lecturas fantasma en `REPEATABLE READ`. InnoDB va más allá y también las evita en las lecturas comunes. Otros motores, como PostgreSQL, Oracle y SQL Server, usan `READ COMMITTED` por defecto.

---

## Paso 5 — Ver la diferencia entre dos niveles

La misma secuencia, con la Sesión B en dos niveles distintos. La nota de Santiago empieza en 4 y Filosofía (15) no tiene inscriptos.

| Orden | Sesión A | Sesión B | B en `READ COMMITTED` | B en `REPEATABLE READ` |
| ----- | -------- | -------- | --------------------- | ---------------------- |
| 1 | | `START TRANSACTION;` | | |
| 2 | | Lee la nota de Santiago | 4.00 | 4.00 |
| 3 | `UPDATE … SET nota = 6 …` (autocommit) | | | |
| 4 | | Lee la nota de Santiago | **6.00** | **4.00** |
| 5 | | Cuenta inscriptos en Filosofía | 0 | 0 |
| 6 | `INSERT INTO inscripcion VALUES (10, 15, NULL);` | | | |
| 7 | | Cuenta inscriptos en Filosofía | **1** | **0** |
| 8 | | `COMMIT;` | | |
| 9 | | Lee y cuenta de nuevo | 6.00 y 1 | 6.00 y 1 |

En `REPEATABLE READ`, la transacción de B trabaja sobre una **foto** de la base tomada en su primera lectura. Todo lo que confirmen los demás después queda fuera de la foto hasta que B termine su transacción. En `READ COMMITTED`, cada consulta saca una foto nueva.

**¿Cuándo usar cada uno?**

- **`REPEATABLE READ`**: el valor por defecto; adecuado para casi todo. Indispensable en informes que hacen varias consultas y necesitan que los números coincidan entre sí.
- **`READ COMMITTED`**: cuando se prefiere ver siempre lo último confirmado y hay muchas escrituras simultáneas.
- **`SERIALIZABLE`**: operaciones críticas (dinero, cupos), aceptando que las sesiones se esperen mucho más.
- **`READ UNCOMMITTED`**: casi nunca. Leer datos que pueden no llegar a existir es un riesgo que rara vez se justifica.

---

## Paso 6 — Interbloqueo (deadlock)

Dos transacciones pueden quedar esperándose **mutuamente**:

| Orden | Sesión A | Sesión B |
| ----- | -------- | -------- |
| 1 | `START TRANSACTION;` | `START TRANSACTION;` |
| 2 | Modifica la nota de Lucía (estudiante 1) | |
| 3 | | Modifica la nota de Mateo (estudiante 2) |
| 4 | Quiere modificar la de Mateo ⏳ *espera a B* | |
| 5 | | Quiere modificar la de Lucía ⏳ *espera a A* |

```text
        tiene bloqueada a Lucía                 tiene bloqueado a Mateo
            ┌───────────┐     espera a Mateo     ┌───────────┐
            │ Sesión A  │ ─────────────────────▶ │ Sesión B  │
            │           │ ◀───────────────────── │           │
            └───────────┘     espera a Lucía     └───────────┘
```

Ninguna puede avanzar, y esperar no lo resuelve. InnoDB detecta el ciclo al instante, elige una de las dos como víctima y le **deshace la transacción**:

```text
Error Code: 1213. Deadlock found when trying to get lock; try restarting transaction
```

La otra sesión continúa normalmente. La víctima tiene que **volver a intentar** la transacción completa desde el principio.

**Cómo evitarlos:**

- Modificar las filas **siempre en el mismo orden** (por ejemplo, de menor a mayor `id_estudiante`). Si A y B hubieran empezado las dos por Lucía, B habría esperado y no habría interbloqueo.
- Transacciones cortas: cuanto menos dura un bloqueo, menos chance de cruzarse.
- No esperar una respuesta del usuario con la transacción abierta.

---

## Diferencia clave: espera por bloqueo vs interbloqueo

| Aspecto | Espera por bloqueo | Interbloqueo |
| ------- | ------------------ | ------------ |
| Quién espera a quién | B espera a A | A espera a B **y** B espera a A |
| ¿Se resuelve esperando? | Sí, cuando A termina | No, nunca |
| Qué hace MySQL | Espera hasta 50 segundos | Lo detecta enseguida y deshace una de las dos |
| Error | `1205` *Lock wait timeout exceeded* | `1213` *Deadlock found* |
| Qué se deshace | Solo la sentencia que esperaba | La transacción completa de la víctima |
| Qué hacer | Buscar quién dejó la transacción abierta | Reintentar; revisar el orden de las modificaciones |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| Un `UPDATE` queda "colgado" sin terminar | Otra sesión tiene bloqueada esa fila en una transacción abierta | Confirmar o deshacer en la otra sesión |
| `Error 1205`: *Lock wait timeout exceeded* | La espera superó los 50 segundos | Lo mismo; después, repetir la sentencia |
| `Error 1213`: *Deadlock found* | Dos transacciones se bloquearon entre sí | Reintentar la transacción; unificar el orden en que se modifican las filas |
| "No veo los cambios que hizo mi compañero" | Él no hizo `COMMIT`, o mi transacción sigue abierta con su foto vieja (`REPEATABLE READ`) | Que confirme; cerrar mi transacción con `COMMIT` |
| En la práctica, las dos sesiones ven lo mismo al instante | Son dos pestañas de la misma conexión | Abrir una segunda conexión desde la pantalla de inicio |
| Se pierde una actualización, sin ningún error | Se leyó con `SELECT` común, se calculó aparte y se guardó | `SELECT … FOR UPDATE`, o calcular dentro del `UPDATE` |

---

Continuamos por el repaso del módulo → [Resumen del Módulo 9](Resumen-Modulo9)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Conviene comprobarlos con dos sesiones.

**1.** La nota de Lucía en Matemática es 9.50. ¿Qué valor ve la Sesión B en el momento 3? ¿Y en el 5?

| Orden | Sesión A | Sesión B |
| ----- | -------- | -------- |
| 1 | `START TRANSACTION;` | |
| 2 | `UPDATE inscripcion SET nota = 12 WHERE id_estudiante = 1 AND id_asignatura = 10;` | |
| 3 | | `SELECT nota …` |
| 4 | `ROLLBACK;` | |
| 5 | | `SELECT nota …` |

<details>
<summary>Ver solución</summary>

**9.50 las dos veces.**

💡 En el momento 3, el cambio de A no está confirmado y B no lo ve (no hay lectura sucia en el nivel por defecto). En el 5, A deshizo el cambio: el 12 nunca existió para nadie más.
</details>

**2.** ¿Qué pasa en el momento 3? ¿Y en el 4?

| Orden | Sesión A | Sesión B |
| ----- | -------- | -------- |
| 1 | `START TRANSACTION;` | |
| 2 | `DELETE FROM inscripcion WHERE id_estudiante = 8;` | |
| 3 | | `UPDATE inscripcion SET nota = 7 WHERE id_estudiante = 8 AND id_asignatura = 11;` |
| 4 | | `UPDATE inscripcion SET nota = 7 WHERE id_estudiante = 3 AND id_asignatura = 10;` *(suponiendo que la anterior no se hubiera ejecutado)* |

<details>
<summary>Ver solución</summary>

En el momento 3, B **queda esperando**: las filas del estudiante 8 están bloqueadas por el `DELETE` de A. Si A confirma, el `UPDATE` de B termina con `0 row(s) affected` (la fila ya no existe); si A deshace, B modifica la nota.

La sentencia del momento 4 se ejecutaría **sin esperar**: la fila del estudiante 3 no la tocó nadie.

💡 InnoDB bloquea filas, no la tabla completa.
</details>

**3.** La Sesión B está en `REPEATABLE READ`. Programación tiene dos inscripciones sin nota. ¿Qué devuelve B en los momentos 2, 4 y 6?

| Orden | Sesión A | Sesión B |
| ----- | -------- | -------- |
| 1 | | `START TRANSACTION;` |
| 2 | | `SELECT COUNT(*) FROM inscripcion WHERE nota IS NULL AND id_asignatura = 14;` |
| 3 | `UPDATE inscripcion SET nota = 8 WHERE id_estudiante = 9 AND id_asignatura = 14;` | |
| 4 | | *(la misma consulta)* |
| 5 | | `COMMIT;` |
| 6 | | *(la misma consulta)* |

<details>
<summary>Ver solución</summary>

**2, 2 y 1.**

💡 Dentro de su transacción, B sigue viendo la foto del momento 2, aunque A ya confirmó (autocommit). Al cerrar la transacción, la siguiente lectura ve el estado actual. En `READ COMMITTED` habría dado 2, 1 y 1.
</details>

**4.** Dos sesiones ejecutan estas transacciones al mismo tiempo. ¿Puede haber un interbloqueo? ¿Cómo se evita?

```sql
-- Sesión A
START TRANSACTION;
UPDATE estudiante SET id_grupo = 2 WHERE id_estudiante = 6;
UPDATE estudiante SET id_grupo = 3 WHERE id_estudiante = 9;
COMMIT;

-- Sesión B
START TRANSACTION;
UPDATE estudiante SET id_grupo = 1 WHERE id_estudiante = 9;
UPDATE estudiante SET id_grupo = 1 WHERE id_estudiante = 6;
COMMIT;
```

<details>
<summary>Ver solución</summary>

**Sí.** Si A alcanza a bloquear al estudiante 6 y B al 9, cada una queda esperando la fila que tiene la otra. MySQL deshará una de las dos con `Error 1213`.

Se evita haciendo que las dos modifiquen en el mismo orden, por ejemplo siempre de menor a mayor `id_estudiante`:

```sql
-- Sesión B, corregida
START TRANSACTION;
UPDATE estudiante SET id_grupo = 1 WHERE id_estudiante = 6;
UPDATE estudiante SET id_grupo = 1 WHERE id_estudiante = 9;
COMMIT;
```

💡 Con el mismo orden, la que llega segunda espera en la primera fila y no llega a bloquear nada que la otra necesite.
</details>

**5.** Un sistema de inscripciones controla un cupo de 30 por asignatura así: cuenta los inscriptos con un `SELECT COUNT(*)`, y si son menos de 30, hace el `INSERT`. Quedan 29 inscriptos y dos estudiantes se anotan a la vez. ¿Qué puede salir mal?

<details>
<summary>Ver solución</summary>

Las dos sesiones cuentan 29, las dos concluyen que hay lugar y las dos insertan: quedan **31** inscriptos. Es el mismo patrón "leer, decidir, escribir" de la actualización perdida.

Una solución es bloquear, al principio de la transacción, la fila de la asignatura:

```sql
START TRANSACTION;

SELECT id_asignatura
FROM asignatura
WHERE id_asignatura = 10
FOR UPDATE;

-- contar, decidir e insertar

COMMIT;
```

💡 Las inscripciones a una misma asignatura pasan de a una: la segunda sesión espera en el `FOR UPDATE` y, cuando le toca, ya cuenta 30.
</details>

---

## 📋 Palabras clave

`concurrencia` · `sesión` · `bloqueo` · `bloqueo de fila` · `FOR UPDATE` · `actualización perdida` · `lectura sucia` · `lectura no repetible` · `lectura fantasma` · `nivel de aislamiento` · `REPEATABLE READ` · `READ COMMITTED` · `SERIALIZABLE` · `interbloqueo` · `Error 1205` · `Error 1213`

---

🧠 **[Autoevaluación — Módulo 9](auto-modulo9)**

---

← [Transacciones](Transacciones) · [🏠 Inicio](Home) · [Resumen del Módulo 9 →](Resumen-Modulo9)
