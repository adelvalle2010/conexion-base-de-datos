> 🗄️ **Base de datos:** `liceo` (Módulo 5 — Definición de Datos) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo5/liceo_ddl.sql)

# 🛡️ Restricciones: NOT NULL, UNIQUE, DEFAULT y CHECK

## ¿Por qué lo necesitamos?

Las claves controlan que las filas se identifiquen y se relacionen bien. Pero dentro de cada columna todavía puede entrar cualquier cosa del tipo correcto:

```sql
-- ❌ Todo esto es "válido" si la tabla no tiene restricciones
-- un grupo sin nombre
-- dos grupos llamados '3ºA'
-- un grupo con turno 'tarde', 'Tarde', 'vesp.' o 'TARDE'
```

Una **restricción** (*constraint*) es una regla que MySQL comprueba cada vez que se inserta o modifica una fila. Si la fila no la cumple, la rechaza.

**Ventajas:**

- La regla está en **un solo lugar**: la base. Vale para Workbench, para una aplicación Java y para cualquier otro programa que se conecte.
- Los errores se detectan al cargar el dato, no meses después.
- La estructura documenta las reglas del liceo.

---

## Sintaxis

| Restricción | Qué garantiza | Dónde se escribe |
| ----------- | ------------- | ---------------- |
| `NOT NULL` | La columna no queda vacía | Al lado de la columna |
| `UNIQUE` | El valor no se repite en la tabla | Al lado de la columna, o como `CONSTRAINT` |
| `DEFAULT <valor>` | Si no se indica un valor, se usa este | Al lado de la columna |
| `CHECK (<condición>)` | El valor cumple una condición | Como `CONSTRAINT` |

En esta página creamos una tabla nueva, `grupo`, que usa las cuatro. En el liceo, los grupos (3ºA, 3ºB...) tienen un turno, y hasta ahora el grupo era solo un texto en `estudiante`.

```sql
CREATE TABLE grupo (
    id_grupo INT         NOT NULL AUTO_INCREMENT,
    nombre   VARCHAR(10) NOT NULL,
    turno    VARCHAR(10) NOT NULL DEFAULT 'matutino',
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT uq_grupo_nombre UNIQUE (nombre),
    CONSTRAINT chk_grupo_turno CHECK (turno IN ('matutino', 'vespertino', 'nocturno'))
);
```

```sql
DESCRIBE grupo;
```

**Resultado:**

| Field | Type | Null | Key | Default | Extra |
| ----- | ---- | ---- | --- | ------- | ----- |
| id_grupo | int | NO | PRI | NULL | auto_increment |
| nombre | varchar(10) | NO | UNI | NULL | |
| turno | varchar(10) | NO | | matutino | |

Vamos una por una. Para probarlas usamos `INSERT`, que estudiaremos en [INSERT: Insertar registros](INSERT-insertar-registros).

---

## Paso 1 — NOT NULL: el dato es obligatorio

```sql
-- ❌ Falta el nombre, que es obligatorio y no tiene valor por defecto
INSERT INTO grupo (turno)
VALUES ('matutino');
```

```text
Error 1364: Field 'nombre' doesn't have a default value
```

**Elementos clave:**

- `NULL` significa "no hay dato". No es lo mismo que un cero ni que un texto vacío `''`.
- Sin `NOT NULL`, una columna admite `NULL`.
- Regla práctica: toda columna es `NOT NULL` salvo que haya un motivo para que falte el dato, como la `nota` de alguien que todavía no rindió.

---

## Paso 2 — DEFAULT: un valor cuando no se dice nada

```sql
-- ✅ No indicamos el turno: MySQL usa el valor por defecto
INSERT INTO grupo (nombre)
VALUES ('3ºA');

SELECT *
FROM grupo;
```

**Resultado:**

| id_grupo | nombre | turno |
| -------- | ------ | ----- |
| 1 | 3ºA | matutino |

**¿Qué hace exactamente?**

- No escribimos ni `id_grupo` ni `turno`. El primero lo completó `AUTO_INCREMENT` y el segundo, `DEFAULT`.
- `DEFAULT` no impide poner otro valor: solo actúa cuando la columna **no se menciona**.

---

## Paso 3 — UNIQUE: sin repetidos

```sql
-- ❌ Ya existe un grupo llamado '3ºA'
INSERT INTO grupo (nombre, turno)
VALUES ('3ºA', 'vespertino');
```

```text
Error 1062: Duplicate entry '3ºA' for key 'grupo.uq_grupo_nombre'
```

**Elementos clave:**

- En `DESCRIBE` aparece como `Key = UNI`.
- Una tabla puede tener **varias** restricciones `UNIQUE`, pero una sola clave primaria.
- `UNIQUE` es la forma de declarar una **clave alternativa**: un dato que también identifica, aunque no sea la PK (la cédula, el correo, el nombre del grupo).

---

## Paso 4 — CHECK: el valor cumple una condición

```sql
-- ❌ 'tarde' no está en la lista de turnos permitidos
INSERT INTO grupo (nombre, turno)
VALUES ('3ºB', 'tarde');
```

```text
Error 3819: Check constraint 'chk_grupo_turno' is violated.
```

Algunas condiciones habituales:

| Condición | Ejemplo |
| --------- | ------- |
| Lista de valores | `CHECK (turno IN ('matutino', 'vespertino', 'nocturno'))` |
| Rango | `CHECK (nota BETWEEN 1 AND 12)` |
| Comparación | `CHECK (precio > 0)` |
| Entre columnas de la misma fila | `CHECK (fecha_fin >= fecha_inicio)` |

> 📌 **Nota:** MySQL comprueba los `CHECK` desde la versión 8.0.16. En versiones anteriores se podían escribir, pero se ignoraban.

> 💡 Un `CHECK` solo mira **la fila que se está guardando**. No puede consultar otras filas ni otras tablas: para eso están las FK y, más adelante, los [Triggers](Triggers).

Para dejar la tabla vacía antes de seguir:

```sql
DELETE FROM grupo;
ALTER TABLE grupo AUTO_INCREMENT = 1;
```

> ⚠️ **`DELETE` sin `WHERE` borra todas las filas.** Acá es lo que queremos, porque eran datos de prueba. Lo vemos en [DELETE: Eliminar registros](DELETE-eliminar-registros).

---

## ¿Y las tablas que ya creamos?

`asignatura` e `inscripcion` ya existen, y también les faltan reglas: no debería haber dos asignaturas con el mismo nombre, ni una nota de 15. Para agregar una restricción a una tabla existente hace falta `ALTER TABLE`, que es el tema de la página siguiente.

## Diferencia clave: PRIMARY KEY vs UNIQUE

| Aspecto | `PRIMARY KEY` | `UNIQUE` |
| ------- | ------------- | -------- |
| ¿Admite repetidos? | No | No |
| ¿Admite `NULL`? | No | Sí (y puede haber varios `NULL`) |
| ¿Cuántas por tabla? | Una | Varias |
| Uso típico | El identificador de la fila | Otro dato que tampoco debe repetirse |
| Las FK suelen apuntar a... | Ella | Rara vez |

---

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1364: Field '…' doesn't have a default value` | Se omitió una columna `NOT NULL` sin `DEFAULT` | Indicar el valor o definir un `DEFAULT` |
| `Error 1048: Column '…' cannot be null` | Se escribió `NULL` de forma explícita en una columna `NOT NULL` | Dar un valor |
| `Error 1062: Duplicate entry '…' for key '…'` | El valor ya existe en una columna `UNIQUE` o PK | Usar otro valor, o revisar si la fila ya estaba cargada |
| `Error 3819: Check constraint '…' is violated` | El valor no cumple la condición | Corregir el valor; el nombre de la restricción indica cuál es la regla |
| Se cargó `'Matutino'` y el `CHECK` lo aceptó | La comparación de textos no distingue mayúsculas (colación `_ci`) | Es el comportamiento esperado; si importa, normalizar el texto antes de guardar |
| Se guarda `''` en una columna `NOT NULL` | Un texto vacío no es `NULL` | Agregar `CHECK (nombre <> '')` si no se quiere permitir |

---

Continuamos por cómo cambiar lo que ya está creado → [ALTER, DROP y TRUNCATE](ALTER-DROP-y-TRUNCATE)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Usá la base `practica`.

**1.** Creá la tabla `categoria` con identificador autonumérico y un nombre obligatorio de hasta 40 caracteres que no se pueda repetir.

<details>
<summary>Ver solución</summary>

```sql
CREATE TABLE categoria (
    id_categoria INT         NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(40) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
);
```

💡 `NOT NULL` y `UNIQUE` juntos: el nombre es obligatorio **y** no se repite.
</details>

**2.** Creá la tabla `multa` con identificador autonumérico, un monto con dos decimales que debe ser mayor que cero, y una columna `pagada` que vale 0 si no se indica nada y solo admite 0 o 1.

<details>
<summary>Ver solución</summary>

```sql
CREATE TABLE multa (
    id_multa INT          NOT NULL AUTO_INCREMENT,
    monto    DECIMAL(8,2) NOT NULL,
    pagada   TINYINT      NOT NULL DEFAULT 0,
    CONSTRAINT pk_multa PRIMARY KEY (id_multa),
    CONSTRAINT chk_multa_monto CHECK (monto > 0),
    CONSTRAINT chk_multa_pagada CHECK (pagada IN (0, 1))
);
```

💡 MySQL no tiene un tipo booleano propio: `BOOLEAN` es un sinónimo de `TINYINT(1)`.
</details>

**3.** ¿Qué error da cada sentencia sobre la tabla `multa`?

```sql
INSERT INTO multa (monto) VALUES (-50);
INSERT INTO multa (pagada) VALUES (1);
```

<details>
<summary>Ver solución</summary>

- La primera: `Error 3819`, porque viola `chk_multa_monto`.
- La segunda: `Error 1364`, porque `monto` es `NOT NULL` y no tiene `DEFAULT`.

💡 El mensaje de un `CHECK` nombra la restricción: por eso conviene ponerles nombres claros.
</details>

---

## 📋 Palabras clave

`restricción` · `constraint` · `NOT NULL` · `NULL` · `UNIQUE` · `DEFAULT` · `CHECK` · `clave alternativa` · `IN` · `BETWEEN` · `Error 1062` · `Error 3819` · `Error 1364` · `integridad`

---

🧠 **[Autoevaluación — Módulo 5](auto-modulo5)**

---

← [Claves Primarias (PK) y Foráneas (FK)](Claves-primarias-y-foraneas) · [🏠 Inicio](Home) · [ALTER, DROP y TRUNCATE →](ALTER-DROP-y-TRUNCATE)
