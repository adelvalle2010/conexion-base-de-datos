## ¿Qué es el modelo relacional?

El **modelo relacional** organiza los datos en **tablas** (formadas por filas y columnas) que se conectan entre sí mediante **claves**. Es el segundo paso del diseño: toma el diagrama de [Entidad-Relación](Entidad-Relacion) y lo convierte en las tablas que MySQL va a poder crear.

**Características principales:**

- Todo se guarda en tablas; no existe otra estructura.
- Cada fila se identifica con una **clave primaria**.
- Las tablas se vinculan con **claves foráneas**, en lugar de repetir datos.
- El orden de las filas no importa: lo que identifica a una fila es su clave, no su posición.
- Es el modelo que usan MySQL, PostgreSQL, Oracle y SQL Server, entre otros SGBD relacionales.

El nombre "relacional" viene de que, en la teoría, a cada tabla se la llama *relación*. No hay que confundirla con las relaciones del diagrama E-R, que son los vínculos entre entidades.

## Las piezas del modelo

### 1. Tabla, fila y columna

Esta es la tabla `estudiante` del liceo:

| id_estudiante | nombre    | apellido  | fecha_nacimiento | grupo |
| ------------- | --------- | --------- | ---------------- | ----- |
| 1             | Lucía     | Fernández | 2008-03-15       | 3ºA   |
| 2             | Mateo     | Silva     | 2008-07-02       | 3ºB   |
| 3             | Valentina | Rodríguez | 2007-11-20       | 3ºA   |

**Elementos clave:**

- **Tabla**: representa una entidad del diagrama E-R (`estudiante`).
- **Columna**: representa un atributo (`nombre`, `grupo`...).
- **Fila**: representa un ejemplar concreto de la entidad (Lucía Fernández).

### 2. Clave primaria (PK)

La **clave primaria** (PK, por *primary key*) es la columna, o el conjunto de columnas, que identifica de forma única a cada fila. En `estudiante` es `id_estudiante`.

**Elementos clave:**

- **Única**: no puede haber dos filas con la misma clave.
- **Nunca vacía**: toda fila tiene que tener su clave (no admite valores `NULL`, que significa "sin valor").
- **Estable**: no debería cambiar con el tiempo.
- No sirve el nombre ni el apellido: puede haber dos Mateo Silva.

**¿Qué hace exactamente?**

- Garantiza que "el estudiante 2" sea siempre la misma persona, aunque cambie de grupo o de apellido.
- Permite que otras tablas apunten a esa fila sin ambigüedad.
- Cómo se declara en MySQL se ve en [Claves Primarias (PK) y Foráneas (FK)](Claves-primarias-y-foraneas).

### 3. Clave foránea (FK)

La **clave foránea** (FK, por *foreign key*) es una columna que guarda la clave primaria de otra tabla. Así se vinculan las tablas. Mirá cómo `asignatura` apunta a `docente`:

**Tabla `docente`**

| id_docente | nombre | apellido |
| ---------- | ------ | -------- |
| 1          | Marta  | Pereira  |
| 2          | Julio  | Acosta   |

**Tabla `asignatura`**

| id_asignatura | nombre     | id_docente |
| ------------- | ---------- | ---------- |
| 10            | Matemática | 1          |
| 11            | Física     | 1          |
| 12            | Historia   | 2          |

**¿Qué hace exactamente?**

- La columna `id_docente` de `asignatura` es una FK: Matemática y Física apuntan al docente 1, es decir, a Marta Pereira.
- Los datos de Marta se guardan **una sola vez**. Si cambia su apellido, se corrige en un único lugar.
- La FK obliga a que el docente exista: no se podría crear una asignatura con `id_docente = 99` si no hay un docente 99. Esa garantía se llama **integridad referencial**.

## Del diagrama E-R a las tablas

Pasar del diagrama a las tablas es una traducción con reglas fijas:

| Elemento del diagrama E-R       | Se convierte en…                                           | Ejemplo en el liceo                                  |
| ------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------- |
| Entidad                         | Una tabla                                                  | ESTUDIANTE → `estudiante`                            |
| Atributo                        | Una columna                                                | `nombre` → columna `nombre`                          |
| Identificador                   | La clave primaria (PK)                                     | `id_estudiante`                                      |
| Relación 1:N                    | Una FK en la tabla del lado "muchos"                       | `id_docente` dentro de `asignatura`                  |
| Relación N:M                    | Una tabla intermedia con una FK hacia cada tabla           | `inscripcion`                                        |
| Atributo de una relación N:M    | Una columna de la tabla intermedia                         | `nota` dentro de `inscripcion`                       |
| Relación 1:1                    | Una FK (en una de las dos tablas)                          | carné → columna `id_estudiante` en la tabla del carné |

**Cuándo usar cada regla:**

- **FK en el lado "muchos"**: el que tiene "muchos" es el que guarda la clave del "uno". Una asignatura guarda a su docente; el docente no guarda una lista de asignaturas.
- **Tabla intermedia**: siempre que haya una relación N:M.

### Resolver la relación N:M

¿Cómo se guarda que un estudiante cursa varias asignaturas y que cada asignatura tiene varios estudiantes? La tentación es agregar columnas `asignatura1`, `asignatura2`, `asignatura3` en la tabla `estudiante`. Es una mala idea:

- ¿Y si un estudiante cursa cuatro asignaturas?
- ¿Dónde se guarda la nota de cada una?
- Muchas columnas quedarían vacías para los estudiantes que cursan menos.

La solución es una **tabla intermedia** que guarda una fila por cada pareja (estudiante, asignatura):

**Tabla `inscripcion`**

| id_estudiante | id_asignatura | nota |
| ------------- | ------------- | ---- |
| 1             | 10            | 9.5  |
| 1             | 11            | 7.0  |
| 2             | 10            | 8.0  |

**¿Qué hace exactamente?**

- Lucía (estudiante 1) cursa Matemática y Física; Matemática (asignatura 10) tiene a Lucía y a Mateo.
- `id_estudiante` e `id_asignatura` son dos FK, cada una hacia su tabla.
- Juntas forman una **clave primaria compuesta**: la pareja (estudiante, asignatura) no se puede repetir, así que nadie se inscribe dos veces en la misma asignatura.
- La `nota` vive acá, porque pertenece a la pareja y no a cada una por separado.

## El esquema completo del liceo

Esta es la forma habitual de escribir un esquema relacional. Las FK indican a qué tabla apuntan con una flecha:

```text
docente(id_docente PK, nombre, apellido)
estudiante(id_estudiante PK, nombre, apellido, fecha_nacimiento, grupo)
asignatura(id_asignatura PK, nombre, id_docente FK → docente)
inscripcion(id_estudiante PK/FK → estudiante, id_asignatura PK/FK → asignatura, nota)
```

**Elementos clave:**

- Cuatro tablas: tres vienen de las entidades y una de la relación N:M.
- La FK `id_docente` en `asignatura` resuelve la relación 1:N.
- `inscripcion` tiene una clave primaria compuesta formada por dos FK.

## Diferencia clave: Modelo E-R vs Modelo relacional

| Aspecto               | Modelo E-R                                  | Modelo relacional                              |
| --------------------- | ------------------------------------------- | ---------------------------------------------- |
| Qué es                | Un diagrama de la realidad                  | Un conjunto de tablas                          |
| Para qué sirve        | Pensar y conversar el diseño                | Preparar lo que se va a crear en el SGBD       |
| Elementos             | Entidades, atributos, relaciones            | Tablas, columnas, claves                       |
| Relaciones N:M        | Se dibujan directamente                     | Se resuelven con una tabla intermedia          |
| Cuándo se hace        | Primero                                     | Después del diagrama E-R                       |
| Depende del SGBD      | No                                          | Sí, es la base para crear las tablas en SQL    |

---

## 📋 Palabras clave

`modelo relacional` · `tabla` · `fila` · `columna` · `clave primaria (PK)` · `clave foránea (FK)` · `clave compuesta` · `tabla intermedia` · `integridad referencial` · `NULL` · `esquema relacional` · `N:M`

---

← [Solución: Entidad-Relación](Solucion-Entidad-Relacion) · [🏠 Inicio](Home) · [Ejercicios: Modelo Relacional →](Ejercicios-Modelo-Relacional)
