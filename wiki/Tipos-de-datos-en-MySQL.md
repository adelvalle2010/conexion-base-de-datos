## ¿Qué es un tipo de dato?

Un **tipo de dato** indica qué clase de valor puede guardar una columna: un número entero, un texto, una fecha. Se elige para cada columna al crear la tabla, y es el último paso del diseño antes de empezar a escribir SQL.

**Características principales:**

- Cada columna tiene un único tipo, y todos sus valores deben respetarlo.
- Evita errores: no se puede guardar el texto "hola" en una columna de fechas.
- Permite operar con sentido: se pueden sumar números y ordenar fechas.
- Ahorra espacio: un tipo bien elegido ocupa solo lo necesario.

Los tipos de MySQL se agrupan en familias: números, texto, fechas y algunos valores especiales.

## Las familias de tipos

### 1. Números: enteros y decimales

| Tipo           | Guarda                                         | Ejemplo en el liceo |
| -------------- | ---------------------------------------------- | ------------------- |
| `INT`          | Números enteros (hasta unos 2.100 millones)    | `id_estudiante`     |
| `DECIMAL(p,s)` | Números con decimales exactos                  | `nota`              |

**Elementos clave:**

- `DECIMAL(4,2)` significa **4 dígitos en total, 2 de ellos después del punto**: admite valores desde `0.00` hasta `99.99`.
- La **precisión** (`p`) es la cantidad total de dígitos; la **escala** (`s`) es la cantidad de decimales.
- Existen `FLOAT` y `DOUBLE`, que guardan decimales de forma aproximada. No se recomiendan para notas ni para dinero, donde importa que el valor sea exacto.

### 2. Texto

| Tipo         | Guarda                                      | Ejemplo en el liceo       |
| ------------ | ------------------------------------------- | ------------------------- |
| `CHAR(n)`    | Texto de largo fijo, siempre `n` caracteres | Un código de país: `UY`   |
| `VARCHAR(n)` | Texto de largo variable, hasta `n`          | `nombre`, `apellido`      |
| `TEXT`       | Texto largo                                 | Observaciones de un docente |

**¿Cuándo usar cada uno?**

- **`VARCHAR(n)`**: la opción habitual para nombres, apellidos, correos, direcciones.
- **`CHAR(n)`**: cuando todos los valores miden exactamente lo mismo (códigos fijos).
- **`TEXT`**: cuando el contenido puede ser muy largo (comentarios, descripciones).

### 3. Fechas y horas

| Tipo       | Guarda                  | Ejemplo de valor        | Ejemplo en el liceo   |
| ---------- | ----------------------- | ----------------------- | --------------------- |
| `DATE`     | Solo la fecha           | `2008-03-15`            | `fecha_nacimiento`    |
| `TIME`     | Solo la hora            | `14:30:00`              | Hora de inicio de una clase |
| `DATETIME` | Fecha y hora juntas     | `2026-03-15 14:30:00`   | Momento de un examen  |

**¿Qué hace exactamente?**

- MySQL escribe las fechas como **año-mes-día**, al revés de como se escriben a diario (15/03/2008).
- Guardar una fecha como texto `'15/03/2008'` se puede, pero se pierde la capacidad de ordenarla correctamente o calcular cuántos días pasaron entre dos fechas.

### 4. Valores especiales: NULL y booleanos

- **`NULL`** significa "sin valor" o "desconocido". No es lo mismo que `0` ni que un texto vacío. Una clave primaria nunca puede ser `NULL`.
- **`BOOLEAN`** guarda verdadero o falso. En MySQL funciona como un número pequeño: `0` es falso y `1` es verdadero.

## Los tipos del liceo

Con lo que vimos, así quedan los tipos de las columnas de nuestro ejemplo guía:

| Tabla         | Columna                       | Tipo            | Por qué                                        |
| ------------- | ----------------------------- | --------------- | ---------------------------------------------- |
| `estudiante`  | `id_estudiante`               | `INT`           | Número entero que identifica                   |
| `estudiante`  | `nombre`, `apellido`          | `VARCHAR(50)`   | Texto de largo variable                        |
| `estudiante`  | `fecha_nacimiento`            | `DATE`          | Una fecha, sin hora                            |
| `estudiante`  | `grupo`                       | `VARCHAR(10)`   | Texto corto, como `3ºA`                        |
| `docente`     | `id_docente`                  | `INT`           | Número entero que identifica                   |
| `asignatura`  | `nombre`                      | `VARCHAR(60)`   | Texto de largo variable                        |
| `inscripcion` | `nota`                        | `DECIMAL(4,2)`  | Decimales exactos con los que se puede promediar |

**¿Qué hace exactamente?**

- Si `nota` fuera `VARCHAR`, MySQL aceptaría tanto `9.5` como `"muy bueno"`, y después no se podría calcular un promedio. Más adelante lo vas a necesitar en [Funciones de Agrupación (SUM, COUNT, AVG)](Funciones-de-agrupacion).
- Con `DECIMAL(4,2)`, MySQL rechaza cualquier valor que no sea un número dentro de ese rango.

Cómo se declaran estos tipos al crear una tabla se explica en [CREATE: Crear Bases de Datos y Tablas](CREATE-bases-de-datos-y-tablas).

## Diferencia clave: CHAR vs VARCHAR

Son los dos tipos de texto más usados y los más confundidos.

| Aspecto             | `CHAR(n)`                                   | `VARCHAR(n)`                                    |
| ------------------- | ------------------------------------------- | ----------------------------------------------- |
| Longitud            | Fija: siempre `n` caracteres                | Variable: hasta `n` caracteres                  |
| Espacio             | Reserva siempre `n` (rellena con espacios)  | Ocupa lo que mide el texto, más un pequeño control de longitud |
| Ejemplo de valor    | `UY`, `M`                                   | `Valentina`, `3ºA`                              |
| Conviene cuando     | Todos los valores miden lo mismo            | Los valores tienen largos distintos             |
| Riesgo              | Desperdicia espacio si el largo varía       | Elegir un `n` tan chico que no entre el texto   |
| Uso típico          | Códigos de largo fijo                       | Nombres, apellidos, direcciones                 |

---

## 📋 Palabras clave

`tipo de dato` · `INT` · `DECIMAL` · `precisión` · `escala` · `CHAR` · `VARCHAR` · `TEXT` · `DATE` · `TIME` · `DATETIME` · `NULL` · `BOOLEAN`

---

🧠 **[Autoevaluación — Módulo 1](auto-modulo1)**

---

← [Solución: Modelo Relacional](Solucion-Modelo-Relacional) · [🏠 Inicio](Home) · [Resumen del Módulo 1 →](Resumen-Modulo1)
