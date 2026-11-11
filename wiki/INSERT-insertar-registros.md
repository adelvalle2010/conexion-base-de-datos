> 🗄️ **Base de datos:** `liceo` (Módulo 6 — Manipulación de Datos) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo6/liceo_dml.sql)

# ➕ INSERT: Insertar registros

En este módulo vamos a darle vida a la base del liceo: cargar grupos, docentes, estudiantes y notas, corregir los errores de carga y dar de baja lo que sobra. Partimos de las cinco tablas vacías del Módulo 5.

## ¿Por qué lo necesitamos?

`CREATE TABLE` construyó las tablas, pero no tienen ninguna fila. El **DML** (lenguaje de manipulación de datos) es el que trabaja con las filas:

| Sentencia | Qué hace | Página |
| --------- | -------- | ------ |
| `INSERT` | Agrega filas nuevas | Esta |
| `UPDATE` | Cambia valores de filas que ya existen | [UPDATE: Actualizar datos](UPDATE-actualizar-datos) |
| `DELETE` | Elimina filas | [DELETE: Eliminar registros](DELETE-eliminar-registros) |

## Requisitos que vamos a necesitar

1. La base `liceo` con sus cinco tablas: es el resultado de [ALTER, DROP y TRUNCATE](ALTER-DROP-y-TRUNCATE).
2. Si no la tenés, ejecutá solo la **Parte A** del script de este módulo, que la crea desde cero.

---

## Sintaxis

```sql
INSERT INTO <tabla> (<columna_1>, <columna_2>, ...)
VALUES (<valor_1>, <valor_2>, ...);
```

### Anatomía de la sentencia

```text
INSERT INTO grupo (nombre, turno)      ← en qué tabla y en qué columnas
VALUES ('3ºA', 'matutino');            ← los valores, en el mismo orden
            │        │
            │        └── va a la columna turno
            └─────────── va a la columna nombre
```

| Regla | Detalle |
| ----- | ------- |
| El orden manda | El primer valor va a la primera columna de la lista, el segundo a la segunda... |
| Textos y fechas entre comillas simples | `'Lucía'`, `'2009-03-14'` |
| Números sin comillas | `1`, `9.50` |
| Las fechas se escriben `'AAAA-MM-DD'` | Año, mes y día, separados por guiones |
| `NULL` sin comillas | `'NULL'` entre comillas sería un texto de cuatro letras |

---

## Paso 1 — Insertar una fila

Empezamos por `grupo`, que no depende de ninguna otra tabla.

```sql
INSERT INTO grupo (nombre, turno)
VALUES ('3ºA', 'matutino');
```

En el panel **Output** de Workbench aparece `1 row(s) affected`. No escribimos `id_grupo`: lo completa `AUTO_INCREMENT`.

---

## Paso 2 — Insertar varias filas a la vez

```sql
INSERT INTO grupo (nombre, turno)
VALUES ('3ºB', 'vespertino'),
       ('2ºA', 'matutino');
```

Cada fila va entre paréntesis y se separan con comas. Es más rápido y más corto que dos sentencias.

---

## Paso 3 — Omitir columnas

```sql
-- No indicamos el turno: se usa el DEFAULT
INSERT INTO grupo (nombre)
VALUES ('2ºB');

SELECT *
FROM grupo;
```

**Resultado:**

| id_grupo | nombre | turno |
| -------- | ------ | ----- |
| 1 | 3ºA | matutino |
| 2 | 3ºB | vespertino |
| 3 | 2ºA | matutino |
| 4 | 2ºB | matutino |

**¿Qué hace exactamente?**

Cuando una columna no aparece en la lista, MySQL decide así:

| La columna... | Valor que recibe |
| ------------- | ---------------- |
| Es `AUTO_INCREMENT` | El número siguiente |
| Tiene `DEFAULT` | Ese valor |
| Admite `NULL` | `NULL` |
| Es `NOT NULL` sin `DEFAULT` | Ninguno: da `Error 1364` |

> 📌 El grupo 2ºB quedó como `matutino`, pero en realidad funciona de noche. Lo corregimos en la página de `UPDATE`.

---

## Paso 4 — Cargar los docentes

```sql
INSERT INTO docente (nombre, apellido)
VALUES ('Ana',    'Pereira'),
       ('Carlos', 'Méndez'),
       ('Laura',  'Sosa'),
       ('Diego',  'Olivera'),
       ('Marta',  'Gimenez');

SELECT *
FROM docente;
```

**Resultado:**

| id_docente | nombre | apellido |
| ---------- | ------ | -------- |
| 1 | Ana | Pereira |
| 2 | Carlos | Méndez |
| 3 | Laura | Sosa |
| 4 | Diego | Olivera |
| 5 | Marta | Gimenez |

> 📌 "Gimenez" quedó sin tilde: otro error de carga para corregir después.

---

## Paso 5 — Indicar el identificador a mano

En el liceo, las asignaturas se numeran a partir del 10. Aunque la columna sea `AUTO_INCREMENT`, se le puede dar el valor:

```sql
INSERT INTO asignatura (id_asignatura, nombre, id_docente)
VALUES (10, 'Matemática',   1),
       (11, 'Física',       2),
       (12, 'Historia',     3),
       (13, 'Química',      4),
       (14, 'Programación', 4),
       (15, 'Filosofía',    3),
       (16, 'Taller',       2);
```

**Elementos clave:**

- `id_docente` es una clave foránea: el `1` de Matemática tiene que existir en `docente`. Por eso los docentes se cargaron **antes**.
- Diego (4) dicta dos asignaturas y Marta (5), ninguna.
- El contador de `AUTO_INCREMENT` sigue a partir del mayor valor usado: la próxima asignatura sin número indicado sería la 17.

---

## Paso 6 — Fechas y claves foráneas

```sql
INSERT INTO estudiante (nombre, apellido, fecha_nacimiento, id_grupo)
VALUES ('Lucía',     'Fernández', '2009-03-14', 1),
       ('Mateo',     'Silva',     '2008-11-02', 2),
       ('Valentina', 'Rodríguez', '2009-07-21', 1),
       ('Santiago',  'Pérez',     '2009-01-30', 1),
       ('Camila',    'González',  '2008-09-09', 2),
       ('Joaquín',   'Martínez',  '2010-05-17', 3),
       ('Sofía',     'López',     '2010-02-03', 3),
       ('Benjamín',  'Castro',    '2010-12-25', 3),
       ('Martina',   'Suárez',    '2009-06-06', 2),
       ('Agustín',   'Núñez',     '2008-04-18', 1),
       ('Prueba',    'Prueba',    '2010-01-01', 3);
```

Son 11 filas: diez estudiantes y uno "de prueba", que eliminaremos en la página de `DELETE`. Agustín quedó en el grupo 1, pero va en el 2.

---

## Paso 7 — La tabla intermedia y los NULL

```sql
INSERT INTO inscripcion (id_estudiante, id_asignatura, nota)
VALUES (1, 10,  9.50), (1, 11,  7.00), (1, 14, 11.00),
       (2, 10,  8.00), (2, 13,  5.00),
       (3, 10,  6.50), (3, 12, 10.00),
       (4, 10,  4.00), (4, 11,  6.00), (4, 14, NULL),
       (5, 10, 11.00), (5, 12,  9.00), (5, 13,  8.50),
       (6, 10,  7.50), (6, 12, NULL),
       (7, 10, 10.00), (7, 14,  9.00),
       (8, 11,  3.00), (8, 12,  6.00),
       (9, 13,  7.00), (9, 14, NULL),
       (10, 10, NULL),
       (11, 10,  1.00), (11, 11,  1.00);
```

**Elementos clave:**

- Acá no hay `AUTO_INCREMENT`: las dos columnas de la clave se escriben siempre, y las dos tienen que existir en sus tablas.
- `NULL` en la nota significa "todavía no tiene nota". No es un cero.
- Son 24 filas. Nadie está inscripto en Filosofía (15).

---

## Paso 8 — MySQL cuida los datos

Todas las restricciones del Módulo 5 se comprueban en cada `INSERT`:

```sql
-- ❌ Lucía ya está inscripta en Matemática
INSERT INTO inscripcion (id_estudiante, id_asignatura, nota)
VALUES (1, 10, 8.00);
```

```text
Error 1062: Duplicate entry '1-10' for key 'inscripcion.PRIMARY'
```

```sql
-- ❌ La nota máxima es 12
INSERT INTO inscripcion (id_estudiante, id_asignatura, nota)
VALUES (2, 11, 15);
```

```text
Error 3819: Check constraint 'chk_inscripcion_nota' is violated.
```

```sql
-- ❌ No existe el grupo 9
INSERT INTO estudiante (nombre, apellido, fecha_nacimiento, id_grupo)
VALUES ('Nico', 'Rey', '2009-01-01', 9);
```

```text
Error 1452: Cannot add or update a child row: a foreign key constraint fails
(`liceo`.`estudiante`, CONSTRAINT `fk_estudiante_grupo` FOREIGN KEY (`id_grupo`)
REFERENCES `grupo` (`id_grupo`))
```

Ninguna de las tres filas se guardó. Cuando un `INSERT` de varias filas tiene **una** fila inválida, no se guarda **ninguna**.

---

## El orden de carga

```text
grupo ──▶ estudiante ──┐
                        ├──▶ inscripcion
docente ──▶ asignatura ─┘
```

Primero las tablas que no tienen claves foráneas; después, las que apuntan a ellas. Es el mismo orden en que se crearon.

## Diferencia clave: Con lista de columnas vs Sin lista de columnas

```sql
-- ✅ Con lista: se ve qué valor va a cada columna
INSERT INTO docente (nombre, apellido)
VALUES ('Pablo', 'Ruiz');

-- ❌ Sin lista: hay que dar TODAS las columnas, en el orden de la tabla
INSERT INTO docente
VALUES ('Pablo', 'Ruiz');     -- Error 1136: faltó el id_docente
```

| Aspecto | Con lista de columnas | Sin lista de columnas |
| ------- | --------------------- | --------------------- |
| Valores a escribir | Solo los de las columnas nombradas | Todos, incluida la PK |
| Si se agrega una columna a la tabla | Sigue funcionando | Deja de funcionar |
| Legibilidad | Se entiende sin mirar la tabla | Hay que recordar el orden |
| Recomendación | Siempre | Solo para pruebas rápidas |

---

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1136: Column count doesn't match value count at row 1` | La cantidad de valores no coincide con la de columnas | Contar columnas y valores; revisar comas |
| `Error 1062: Duplicate entry '…' for key '…'` | Se repite una PK o un valor `UNIQUE` | La fila ya existe, o hay que usar otro valor |
| `Error 1452: Cannot add or update a child row` | La FK apunta a una fila que no existe | Cargar antes la tabla padre o corregir el número |
| `Error 1364: Field '…' doesn't have a default value` | Se omitió una columna obligatoria | Agregarla a la lista con su valor |
| `Error 1292: Incorrect date value: '2009-13-40'` | La fecha no existe o no está en formato `'AAAA-MM-DD'` | Escribir año-mes-día: `'2009-12-30'` |
| `Error 1406: Data too long for column 'nombre'` | El texto supera el largo del `VARCHAR` | Acortar el texto o agrandar la columna con `ALTER` |
| `Error 3819: Check constraint '…' is violated` | El valor no cumple un `CHECK` | Corregir el valor |
| Se cargó `14/03/2009` y dio error | Formato de fecha rioplatense | En SQL siempre `'2009-03-14'` |

---

Los datos están cargados, con cuatro errores a propósito. Continuamos por cómo corregirlos → [UPDATE: Actualizar datos](UPDATE-actualizar-datos)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Usá la base `practica`, con las tablas `socio`, `categoria` y `multa` que quedaron de los ejercicios del Módulo 5.

**1.** Cargá a la socia Paula Acosta, dada de alta el 2 de marzo de 2026, sin correo.

<details>
<summary>Ver solución</summary>

```sql
INSERT INTO socio (nombre, apellido, fecha_alta)
VALUES ('Paula', 'Acosta', '2026-03-02');
```

💡 `email` no está en la lista y admite `NULL`, así que queda vacío.
</details>

**2.** En una sola sentencia, cargá a Bruno Vera (alta 10 de marzo de 2026, `bruno@correo.uy`) y a Elena Rivas (alta 1.º de abril de 2026, `elena@correo.uy`).

<details>
<summary>Ver solución</summary>

```sql
INSERT INTO socio (nombre, apellido, fecha_alta, email)
VALUES ('Bruno', 'Vera',  '2026-03-10', 'bruno@correo.uy'),
       ('Elena', 'Rivas', '2026-04-01', 'elena@correo.uy');
```

💡 Si los dos tuvieran el mismo correo, la sentencia fallaría por la restricción `UNIQUE` y no se cargaría ninguno.
</details>

**3.** Cargá las categorías Novela, Poesía y Ciencia, y tres multas de 150.00, 80.50 y 300.00, todas sin pagar.

<details>
<summary>Ver solución</summary>

```sql
INSERT INTO categoria (nombre)
VALUES ('Novela'), ('Poesía'), ('Ciencia');

INSERT INTO multa (monto)
VALUES (150.00), (80.50), (300.00);
```

💡 No hace falta escribir `pagada`: su valor por defecto es 0.
</details>

---

## 📋 Palabras clave

`DML` · `INSERT INTO` · `VALUES` · `fila` · `AUTO_INCREMENT` · `DEFAULT` · `NULL` · `lista de columnas` · `formato de fecha` · `clave foránea` · `orden de carga` · `Error 1062` · `Error 1452` · `Error 1136`

---

🧠 **[Autoevaluación — Módulo 6](auto-modulo6)**

---

← [Resumen del Módulo 5](Resumen-Modulo5) · [🏠 Inicio](Home) · [UPDATE: Actualizar datos →](UPDATE-actualizar-datos)
