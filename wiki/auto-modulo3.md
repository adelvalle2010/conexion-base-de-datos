# 🧠 Autoevaluación — Módulo 3

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

¿Cuál es el objetivo principal de la normalización?

- A) Que la base ocupe la menor cantidad posible de tablas
- B) Que las consultas se escriban con menos líneas
- C) Encriptar los datos para que sean más seguros
- D) Eliminar la redundancia y las anomalías al insertar, modificar y borrar

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Eliminar la redundancia y las anomalías al insertar, modificar y borrar**

💡 Normalizar suele **aumentar** la cantidad de tablas: la planilla del liceo pasó de una a cinco. Lo que se gana es que cada dato esté escrito una sola vez.

</details>

---

### Pregunta 2

En `planilla_notas`, al borrar las filas de Valentina se pierde que Historia la dicta Laura Sosa. ¿Qué tipo de anomalía es?

- A) De inserción
- B) De borrado
- C) De modificación
- D) De dependencia

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) De borrado**

💡 Se quiso eliminar un dato (la estudiante) y se perdieron otros que nadie quería borrar. La de inserción es el caso inverso: no poder cargar Química porque todavía no tiene inscriptos.

</details>

---

### Pregunta 3

¿Qué significa la dependencia funcional `id_asignatura → id_docente`?

- A) Que conociendo la asignatura queda determinado un único docente
- B) Que cada docente dicta una sola asignatura
- C) Que `id_docente` es la clave primaria de la tabla
- D) Que las dos columnas siempre tienen el mismo valor

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Que conociendo la asignatura queda determinado un único docente**

💡 La flecha se lee en un solo sentido: una asignatura, un docente. No dice nada sobre el camino inverso: Ana puede dictar varias asignaturas.

</details>

---

### Pregunta 4

La tabla `docente(id_docente, nombre, asignatura1, asignatura2, asignatura3)` tiene un solo valor en cada celda. ¿En qué forma normal está?

- A) En 1FN, porque cada celda tiene un único valor
- B) En 2FN, porque la clave es simple
- C) No llega a 1FN, porque tiene un grupo repetitivo de columnas
- D) En 3FN, porque no hay dependencias transitivas

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) No llega a 1FN, porque tiene un grupo repetitivo de columnas**

💡 Las columnas numeradas son la misma lista disfrazada: ¿dónde va la cuarta asignatura? La solución es la misma que para una lista: una tabla aparte con una fila por valor.

</details>

---

### Pregunta 5

`socio_actividad(id_socio, id_actividad, nombre_actividad, fecha_alta)` tiene clave primaria (`id_socio`, `id_actividad`) y está en 1FN. ¿En qué forma normal está?

- A) En 3FN
- B) En 2FN, pero no en 3FN
- C) En BCNF
- D) En 1FN, pero no en 2FN

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) En 1FN, pero no en 2FN**

💡 `nombre_actividad` depende solo de `id_actividad`, una parte de la clave: es una dependencia parcial. `fecha_alta` sí depende de la pareja completa.

</details>

---

### Pregunta 6

`oficina(codigo, direccion, cod_postal, ciudad)` tiene clave primaria `codigo`, y cada código postal corresponde a una sola ciudad. ¿Qué forma normal **no** cumple y por qué?

- A) 2FN, porque `ciudad` depende de una parte de la clave
- B) 3FN, porque `ciudad` depende de `cod_postal`, que no es clave
- C) 1FN, porque la dirección tiene calle y número
- D) Ninguna: está en 3FN

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) 3FN, porque `ciudad` depende de `cod_postal`, que no es clave**

💡 Con clave de una sola columna no puede haber dependencias parciales, así que está en 2FN. El problema es la cadena `codigo → cod_postal → ciudad`.

</details>

---

### Pregunta 7

Una tabla en 1FN tiene como clave primaria una sola columna. ¿Qué se puede afirmar?

- A) Que está en 2FN
- B) Que está en 3FN
- C) Que está en BCNF
- D) Que no está normalizada

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Que está en 2FN**

💡 La 2FN prohíbe depender de *una parte* de la clave, y una clave de una columna no tiene partes. Todavía puede tener dependencias transitivas, así que no se puede asegurar la 3FN.

</details>

---

### Pregunta 8

Al pasar `asignatura` a 3FN se creó la tabla `docente`, y en `asignatura` quedó la columna `id_docente`, que se repite cuando un docente dicta varias asignaturas. ¿Eso es redundancia?

- A) Sí, y habría que eliminar la columna
- B) Sí, pero es inevitable en MySQL
- C) No: es una clave foránea, y repetirla es la forma de relacionar las tablas
- D) No, porque los números no cuentan como datos

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) No: es una clave foránea, y repetirla es la forma de relacionar las tablas**

💡 Redundancia es repetir un dato que podría cambiar de forma incoherente, como el apellido. La clave foránea solo apunta a la fila donde ese dato está escrito una única vez.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 3](Resumen-Modulo3)
