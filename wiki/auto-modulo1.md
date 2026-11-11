# 🧠 Autoevaluación — Módulo 1

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

¿Qué es una base de datos?

- A) Un programa que sirve para hacer cálculos con planillas de números
- B) Un archivo de texto donde los datos se anotan sin ningún orden en particular
- C) Un conjunto organizado de datos relacionados, guardado para consultarlo y modificarlo
- D) Un lenguaje de programación pensado para crear páginas web

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Un conjunto organizado de datos relacionados, guardado para consultarlo y modificarlo**

💡 Es como una biblioteca con fichas y estantes: lo importante es que los datos estén ordenados y relacionados, para encontrarlos y cambiarlos fácilmente. Una planilla o un archivo suelto no ofrecen esa organización ni esos controles.

</details>

---

### Pregunta 2

¿Qué función cumple un SGBD como MySQL?

- A) Administra la base de datos: guarda los datos, controla el acceso y atiende las consultas
- B) Es el diagrama que se dibuja con las entidades antes de crear la base
- C) Es el lenguaje con el que se escriben los pedidos a la base de datos
- D) Es la copia de seguridad que se guarda al final de cada día

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Administra la base de datos: guarda los datos, controla el acceso y atiende las consultas**

💡 El SGBD es el "bibliotecario": recibe los pedidos y busca o guarda los datos. El diagrama es el modelo E-R y el lenguaje de los pedidos es SQL; son cosas distintas.

</details>

---

### Pregunta 3

Estás diseñando la base de un gimnasio. ¿Cuál de estos elementos es el mejor candidato a **atributo** y no a entidad?

- A) Socio
- B) Clase de spinning
- C) Entrenador
- D) Fecha de nacimiento del socio

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Fecha de nacimiento del socio**

💡 La fecha de nacimiento es un dato suelto que describe al socio. Socio, clase y entrenador son "cosas" sobre las que se guardan varios datos, así que son entidades.

</details>

---

### Pregunta 4

En el liceo, un docente dicta varias asignaturas, pero cada asignatura la dicta un solo docente. ¿Qué cardinalidad tiene la relación docente–asignatura?

- A) Uno a uno (1:1)
- B) Uno a muchos (1:N)
- C) Muchos a muchos (N:M)
- D) No hay relación: son entidades independientes

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Uno a muchos (1:N)**

💡 Para decidir, preguntá en las dos direcciones: un docente puede dictar muchas asignaturas (muchos), pero una asignatura tiene un solo docente (uno). Eso es 1:N.

</details>

---

### Pregunta 5

¿Cuál es el orden correcto del diseño de una base de datos, según lo visto en el módulo?

- A) Crear las tablas en MySQL → dibujar el diagrama E-R → pasar al modelo relacional
- B) Elegir los tipos de datos → dibujar el diagrama E-R → cargar los datos
- C) Dibujar el diagrama E-R → pasar a tablas con PK y FK → elegir tipos de datos y crear las tablas
- D) Cargar los datos → dibujar el diagrama E-R → armar las tablas

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Dibujar el diagrama E-R → pasar a tablas con PK y FK → elegir tipos de datos y crear las tablas**

💡 Es como construir una casa: primero el plano (E-R), después la estructura (tablas y claves), y recién al final los detalles de cada ambiente (tipos de datos) cuando se construye en MySQL.

</details>

---

### Pregunta 6

Un estudiante se inscribe en varias asignaturas y cada asignatura tiene varios estudiantes. En el modelo relacional, ¿cómo se resuelve esta relación N:M?

- A) Agregando en `estudiante` las columnas `asignatura1`, `asignatura2` y `asignatura3`
- B) Con una tabla intermedia (`inscripcion`) que tiene una FK hacia cada tabla
- C) Repitiendo la fila del estudiante una vez por cada asignatura que cursa
- D) Guardando la clave primaria del estudiante dentro de la tabla `asignatura`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Con una tabla intermedia (`inscripcion`) que tiene una FK hacia cada tabla**

💡 Cada fila de `inscripcion` representa una pareja (estudiante, asignatura) y puede guardar la `nota`. Las otras opciones obligan a repetir datos, limitan la cantidad de asignaturas o solo sirven para una relación 1:N.

</details>

---

### Pregunta 7

¿Qué pasaría si se eligiera `nombre` como clave primaria de la tabla `estudiante`?

- A) Nada: el nombre es siempre único en un grupo
- B) MySQL lo convertiría automáticamente en un número
- C) Las asignaturas quedarían sin docente
- D) No se podrían guardar dos estudiantes con el mismo nombre, porque una PK no puede repetirse

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) No se podrían guardar dos estudiantes con el mismo nombre, porque una PK no puede repetirse**

💡 La PK debe identificar de forma única a cada fila. Como puede haber dos "Mateo Silva", el nombre no sirve; por eso se usa un identificador numérico como `id_estudiante`.

</details>

---

### Pregunta 8

¿Qué tipo de dato conviene para la columna `nota` si se quieren guardar valores como 8.50 y después calcular promedios?

- A) `DECIMAL(4,2)`
- B) `VARCHAR(5)`
- C) `DATE`
- D) `CHAR(4)`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) `DECIMAL(4,2)`**

💡 `DECIMAL` guarda números con decimales exactos y permite operar con ellos. `VARCHAR` y `CHAR` guardan texto (aceptarían "muy bueno") y `DATE` es solo para fechas.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 1](Resumen-Modulo1)
