# 🧠 Autoevaluación — Módulo 2

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

De un estudiante se quiere guardar la dirección, separada en calle, número y ciudad. ¿Qué tipo de atributo es `direccion`?

- A) Multivaluado, porque tiene tres valores
- B) Derivado, porque se arma a partir de otros datos
- C) Compuesto, porque es un solo valor formado por partes distintas
- D) Clave parcial, porque depende del estudiante

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Compuesto, porque es un solo valor formado por partes distintas**

💡 Una dirección es **una** sola, con partes diferentes entre sí (calle, número, ciudad). Multivaluado sería tener varias direcciones; ahí se repetiría el mismo tipo de dato.

</details>

---

### Pregunta 2

¿Qué pasa con un atributo derivado, como `edad`, al pasar el diagrama a tablas?

- A) No se guarda: se calcula al consultar
- B) Se convierte en una tabla aparte con una FK
- C) Se guarda como columna y se actualiza a mano cada año
- D) Se convierte en parte de la clave primaria

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) No se guarda: se calcula al consultar**

💡 Si se guardara, quedaría viejo el día del cumpleaños. Es como la antigüedad de un auto: no la anotás, la calculás con el año de fabricación.

</details>

---

### Pregunta 3

Un estudiante puede tener varios teléfonos. ¿Cuál es la forma correcta de llevarlo a tablas?

- A) Agregar las columnas `telefono1`, `telefono2` y `telefono3` en `estudiante`
- B) Guardar todos los teléfonos en una sola columna, separados por comas
- C) No guardarlos, porque es un atributo derivado
- D) Crear la tabla `telefono_estudiante` con una fila por teléfono y una FK a `estudiante`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Crear la tabla `telefono_estudiante` con una fila por teléfono y una FK a `estudiante`**

💡 Un atributo multivaluado se resuelve con una tabla nueva. Con columnas numeradas, ¿qué hacés con el cuarto teléfono? Y con comas no se puede buscar un número en particular.

</details>

---

### Pregunta 4

Cada asignatura numera sus evaluaciones 1, 2, 3... ¿Cuál es la clave primaria de la tabla `evaluacion`?

- A) `nro_evaluacion`
- B) La pareja (`id_asignatura`, `nro_evaluacion`)
- C) `id_asignatura`
- D) `fecha`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) La pareja (`id_asignatura`, `nro_evaluacion`)**

💡 EVALUACION es débil por identificación: el número se repite entre asignaturas, así que solo identifica junto con la asignatura. Es como el número de puerta: necesitás también la calle.

</details>

---

### Pregunta 5

En el liceo, algunos docentes coordinan a otros docentes y cada docente tiene a lo sumo un coordinador. ¿Cómo se resuelve en tablas?

- A) Con una tabla `coordinador` que copia los datos del docente
- B) Con una columna `id_coordinador` en `docente`, que es FK a la misma tabla `docente`
- C) Con una tabla intermedia `docente_docente`, porque toda relación reflexiva la necesita
- D) No se puede: una tabla no puede relacionarse consigo misma

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Con una columna `id_coordinador` en `docente`, que es FK a la misma tabla `docente`**

💡 Es una reflexiva 1:N: alcanza con una FK que apunta a la propia tabla. La tabla intermedia hace falta solo cuando la reflexiva es N:M, como en las previaturas.

</details>

---

### Pregunta 6

En la tabla `docente`, ¿por qué la columna `id_coordinador` debe admitir `NULL`?

- A) Porque todas las claves foráneas admiten `NULL`
- B) Porque es un atributo derivado
- C) Porque forma parte de la clave primaria
- D) Porque hay docentes que no tienen coordinador

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Porque hay docentes que no tienen coordinador**

💡 La participación es opcional: quien está en lo más alto de la jerarquía no tiene a nadie arriba. Una FK que forma parte de una PK, en cambio, nunca puede ser `NULL`.

</details>

---

### Pregunta 7

En un club, una misma persona puede ser socio y también entrenador, y hay personas registradas que no son ninguna de las dos cosas. ¿Qué tipo de especialización es?

- A) Solapada y parcial
- B) Exclusiva y total
- C) Exclusiva y parcial
- D) Solapada y total

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Solapada y parcial**

💡 Solapada porque se puede pertenecer a dos subtipos a la vez; parcial porque hay personas que no están en ninguno. Son dos preguntas independientes: ¿puede repetirse? y ¿están todos?

</details>

---

### Pregunta 8

El liceo de la wiki tiene las tablas `estudiante` y `docente`, pero no tiene una tabla `persona`. ¿Por qué ese diseño es válido?

- A) Porque la generalización nunca se pasa a tablas
- B) Porque `persona` es un atributo derivado
- C) Porque la especialización es exclusiva y total, y en ese caso alcanza con una tabla por subtipo
- D) Porque MySQL no permite tablas para supertipos

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Porque la especialización es exclusiva y total, y en ese caso alcanza con una tabla por subtipo**

💡 Si todos son de exactamente un subtipo, ninguna persona queda afuera ni repetida al guardar solo los subtipos. Si fuera parcial, las personas "sueltas" no tendrían tabla donde ir.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 2](Resumen-Modulo2)
