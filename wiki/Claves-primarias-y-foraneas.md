> 🗄️ **Base de datos:** `liceo` (Módulo 5 — Definición de Datos) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo5/liceo_ddl.sql)

# 🔑 Claves Primarias (PK) y Foráneas (FK)

## ¿Por qué lo necesitamos?

Sin claves, una tabla es una planilla: nada impide cargar dos veces al mismo estudiante, ni anotar una asignatura dictada por el "docente 99" cuando ese docente no existe.

```sql
-- ❌ Sin claves, MySQL aceptaría las dos cosas
-- dos filas idénticas para Lucía
-- una asignatura con id_docente = 99, que no está en la tabla docente
```

Con claves, MySQL **se niega** a guardar datos incoherentes. Eso se llama **integridad**:

- La **clave primaria (PK)** garantiza que cada fila se pueda identificar: no se repite y no queda vacía (*integridad de entidad*).
- La **clave foránea (FK)** garantiza que un valor que apunta a otra tabla exista en ella (*integridad referencial*).

---

## Sintaxis

```sql
CONSTRAINT <nombre> PRIMARY KEY (<columna>, ...)

CONSTRAINT <nombre> FOREIGN KEY (<columna>)
    REFERENCES <tabla_referenciada> (<columna_referenciada>)
    ON DELETE <acción>
    ON UPDATE <acción>
```

| Parte | Descripción |
| ----- | ----------- |
| `CONSTRAINT <nombre>` | Nombre de la restricción. En esta wiki: `pk_<tabla>` y `fk_<tabla>_<tabla referenciada>` |
| `PRIMARY KEY (...)` | Columna o columnas que identifican a la fila |
| `FOREIGN KEY (...)` | Columna de **esta** tabla que apunta a otra |
| `REFERENCES tabla (columna)` | A qué tabla y a qué columna apunta |
| `ON DELETE` / `ON UPDATE` | Qué hacer si se borra o cambia la fila referenciada (opcional) |

> 💡 Ponerle nombre a las restricciones es opcional, pero conviene: cuando algo falla, el mensaje de error nombra la restricción, y `fk_asignatura_docente` se entiende mucho mejor que `asignatura_ibfk_1`.

---

## Paso 1 — La clave primaria

Ya la escribimos en la página anterior:

```sql
CREATE TABLE docente (
    id_docente INT         NOT NULL AUTO_INCREMENT,
    nombre     VARCHAR(50) NOT NULL,
    apellido   VARCHAR(50) NOT NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_docente)
);
```

**Elementos clave:**

- Una tabla tiene **una sola** clave primaria.
- La columna de la PK no admite `NULL` ni valores repetidos.
- `AUTO_INCREMENT` hace que MySQL asigne solo el número siguiente (1, 2, 3...) a cada fila nueva.

> 📌 **Nota:** `AUTO_INCREMENT` es propio de MySQL. Otros motores logran lo mismo con otra sintaxis (`SERIAL` o `GENERATED AS IDENTITY` en PostgreSQL, `IDENTITY` en SQL Server).

---

## Paso 2 — La clave foránea

Cada asignatura la dicta un docente: relación 1:N, FK del lado "muchos".

```sql
CREATE TABLE asignatura (
    id_asignatura INT         NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(60) NOT NULL,
    id_docente    INT         NOT NULL,
    CONSTRAINT pk_asignatura PRIMARY KEY (id_asignatura),
    CONSTRAINT fk_asignatura_docente FOREIGN KEY (id_docente)
        REFERENCES docente (id_docente)
);
```

```sql
DESCRIBE asignatura;
```

**Resultado:**

| Field | Type | Null | Key | Default | Extra |
| ----- | ---- | ---- | --- | ------- | ----- |
| id_asignatura | int | NO | PRI | NULL | auto_increment |
| nombre | varchar(60) | NO | | NULL | |
| id_docente | int | NO | MUL | NULL | |

**¿Qué hace exactamente?**

- `Key = MUL` indica que la columna tiene un índice y admite valores repetidos: el mismo docente puede aparecer en varias asignaturas.
- La columna de la FK debe tener **el mismo tipo** que la PK a la que apunta: `INT` con `INT`.
- La tabla referenciada (`docente`) tiene que **existir antes**. Por eso las tablas se crean en orden de dependencia.

Probemos la integridad referencial. La tabla `docente` todavía está vacía:

```sql
-- ❌ No existe ningún docente con id 99
INSERT INTO asignatura (nombre, id_docente)
VALUES ('Matemática', 99);
```

```text
Error 1452: Cannot add or update a child row: a foreign key constraint fails
(`liceo`.`asignatura`, CONSTRAINT `fk_asignatura_docente` FOREIGN KEY (`id_docente`)
REFERENCES `docente` (`id_docente`))
```

MySQL rechazó la fila, y el mensaje dice qué restricción falló. La sentencia `INSERT` la estudiaremos en [INSERT: Insertar registros](INSERT-insertar-registros).

---

## Paso 3 — Clave primaria compuesta y dos FK

La tabla `inscripcion` resuelve la relación N:M entre estudiantes y asignaturas. Su clave primaria es la **pareja**.

```sql
CREATE TABLE inscripcion (
    id_estudiante INT          NOT NULL,
    id_asignatura INT          NOT NULL,
    nota          DECIMAL(4,2),
    CONSTRAINT pk_inscripcion PRIMARY KEY (id_estudiante, id_asignatura),
    CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES estudiante (id_estudiante)
        ON DELETE CASCADE,
    CONSTRAINT fk_inscripcion_asignatura FOREIGN KEY (id_asignatura)
        REFERENCES asignatura (id_asignatura)
);
```

```sql
DESCRIBE inscripcion;
```

**Resultado:**

| Field | Type | Null | Key | Default | Extra |
| ----- | ---- | ---- | --- | ------- | ----- |
| id_estudiante | int | NO | PRI | NULL | |
| id_asignatura | int | NO | PRI | NULL | |
| nota | decimal(4,2) | YES | | NULL | |

**Elementos clave:**

- Las dos columnas dicen `PRI`: sigue siendo **una** clave primaria, formada por dos columnas.
- `id_estudiante` se puede repetir y `id_asignatura` también; lo que no se puede repetir es la combinación.
- Acá no hay `AUTO_INCREMENT`: los valores vienen de las otras tablas.
- `nota` admite `NULL`: un estudiante se inscribe antes de tener nota.

---

## Paso 4 — ¿Qué pasa si se borra la fila referenciada?

Si se intenta borrar un docente que dicta asignaturas, esas asignaturas quedarían apuntando a alguien que no existe. Con `ON DELETE` se decide qué hacer:

| Acción | Qué hace al borrar la fila "padre" | Ejemplo en el liceo |
| ------ | ---------------------------------- | ------------------- |
| `RESTRICT` (por defecto) | Rechaza el borrado mientras haya filas que la referencien | No se puede borrar un docente que dicta asignaturas |
| `CASCADE` | Borra también las filas "hijas" | Al borrar un estudiante se borran sus inscripciones |
| `SET NULL` | Deja la FK en `NULL` (la columna debe admitirlo) | La asignatura quedaría "sin docente asignado" |

**¿Cuándo usar cada uno?**

- **`RESTRICT`**: la opción segura. Si no se escribe nada, es la que se aplica.
- **`CASCADE`**: solo cuando las filas hijas no tienen sentido sin el padre, como las inscripciones de un estudiante.
- **`SET NULL`**: cuando la fila hija puede seguir existiendo sin el padre.

> ⚠️ **`ON DELETE CASCADE` borra sin avisar.** Un solo `DELETE` sobre `estudiante` puede eliminar decenas de filas de `inscripcion`. Usalo solo donde estés seguro de que eso es lo que se quiere.

`ON UPDATE` funciona igual, para el caso en que cambie el valor de la clave referenciada. Como las claves autonuméricas no se modifican, casi nunca hace falta.

---

## El orden importa

```text
Crear:   docente ──▶ asignatura ──┐
         estudiante ──────────────┴──▶ inscripcion

Borrar:  el camino inverso (primero inscripcion, al final docente y estudiante)
```

Primero se crean las tablas que no tienen FK; después, las que apuntan a ellas.

## Diferencia clave: Clave primaria vs Clave foránea

| Aspecto | Clave primaria (PK) | Clave foránea (FK) |
| ------- | ------------------- | ------------------ |
| Para qué sirve | Identificar cada fila | Relacionar con otra tabla |
| ¿Cuántas por tabla? | Una sola | Las que hagan falta |
| ¿Admite repetidos? | No | Sí |
| ¿Admite `NULL`? | No | Sí, si la relación es opcional |
| Integridad que garantiza | De entidad | Referencial |
| En `DESCRIBE` | `PRI` | `MUL` |

---

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1824: Failed to open the referenced table 'docente'` | Se creó la tabla con FK antes que la tabla referenciada | Crear primero `docente` |
| `Error 3780: Referencing column … and referenced column … are incompatible` | La FK y la PK tienen tipos distintos (`INT` y `VARCHAR`, por ejemplo) | Usar exactamente el mismo tipo |
| `Error 1452: Cannot add or update a child row` | Se quiso guardar una FK con un valor que no existe en la tabla padre | Cargar antes la fila padre o corregir el valor |
| `Error 1451: Cannot delete or update a parent row` | Se quiso borrar una fila que otras referencian | Borrar antes las filas hijas, o definir `ON DELETE` |
| `Error 1068: Multiple primary key defined` | Se escribieron dos `PRIMARY KEY` | Para una clave compuesta: `PRIMARY KEY (col1, col2)` en una sola línea |
| `Error 1075: Incorrect table definition; there can be only one auto column and it must be defined as a key` | `AUTO_INCREMENT` en una columna que no es clave | Declarar esa columna como PK |

---

Continuamos por las reglas que se aplican a cada columna → [Restricciones: NOT NULL, UNIQUE, DEFAULT y CHECK](Restricciones)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Usá la base `practica`, con las tablas `libro` y `socio` de la página anterior.

**1.** Creá la tabla `editorial` (identificador autonumérico y nombre obligatorio de hasta 60 caracteres).

<details>
<summary>Ver solución</summary>

```sql
CREATE TABLE editorial (
    id_editorial INT         NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(60) NOT NULL,
    CONSTRAINT pk_editorial PRIMARY KEY (id_editorial)
);
```

💡 No tiene FK, así que se puede crear en cualquier momento.
</details>

**2.** Creá la tabla `ejemplar`: cada ejemplar tiene un identificador autonumérico, un estado de hasta 20 caracteres y pertenece a un libro. No se debe poder borrar un libro que tenga ejemplares.

<details>
<summary>Ver solución</summary>

```sql
CREATE TABLE ejemplar (
    id_ejemplar INT         NOT NULL AUTO_INCREMENT,
    estado      VARCHAR(20) NOT NULL,
    id_libro    INT         NOT NULL,
    CONSTRAINT pk_ejemplar PRIMARY KEY (id_ejemplar),
    CONSTRAINT fk_ejemplar_libro FOREIGN KEY (id_libro)
        REFERENCES libro (id_libro)
);
```

💡 No hace falta escribir `ON DELETE RESTRICT`: es el comportamiento por defecto.
</details>

**3.** Creá la tabla `prestamo`, que registra qué socio se llevó qué ejemplar y en qué fecha. La clave primaria es la combinación de socio, ejemplar y fecha de salida. Si se borra un socio, se deben borrar sus préstamos.

<details>
<summary>Ver solución</summary>

```sql
CREATE TABLE prestamo (
    id_socio     INT  NOT NULL,
    id_ejemplar  INT  NOT NULL,
    fecha_salida DATE NOT NULL,
    CONSTRAINT pk_prestamo PRIMARY KEY (id_socio, id_ejemplar, fecha_salida),
    CONSTRAINT fk_prestamo_socio FOREIGN KEY (id_socio)
        REFERENCES socio (id_socio)
        ON DELETE CASCADE,
    CONSTRAINT fk_prestamo_ejemplar FOREIGN KEY (id_ejemplar)
        REFERENCES ejemplar (id_ejemplar)
);
```

💡 La fecha entra en la clave porque el mismo socio puede llevarse el mismo ejemplar más de una vez, en días distintos.
</details>

---

## 📋 Palabras clave

`clave primaria` · `PRIMARY KEY` · `clave foránea` · `FOREIGN KEY` · `REFERENCES` · `CONSTRAINT` · `AUTO_INCREMENT` · `clave compuesta` · `integridad de entidad` · `integridad referencial` · `ON DELETE` · `CASCADE` · `RESTRICT` · `SET NULL` · `tabla padre` · `tabla hija`

---

🧠 **[Autoevaluación — Módulo 5](auto-modulo5)**

---

← [CREATE: Crear Bases de Datos y Tablas](CREATE-bases-de-datos-y-tablas) · [🏠 Inicio](Home) · [Restricciones: NOT NULL, UNIQUE, DEFAULT y CHECK →](Restricciones)
