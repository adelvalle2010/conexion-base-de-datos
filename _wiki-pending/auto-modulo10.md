# 🧠 Autoevaluación — Módulo 10

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

¿Para qué se escribe `DELIMITER $$` antes de crear un procedimiento en Workbench?

- A) Para que el procedimiento se ejecute más rápido
- B) Para que los `;` del cuerpo no corten la sentencia `CREATE PROCEDURE` antes de tiempo
- C) Para indicar que el procedimiento recibe parámetros
- D) Para abrir una transacción

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Para que los `;` del cuerpo no corten la sentencia `CREATE PROCEDURE` antes de tiempo**

💡 `DELIMITER` es una instrucción para el programa cliente: le dice dónde termina lo que tiene que enviar al servidor. Al final se vuelve a `DELIMITER ;`.

</details>

---

### Pregunta 2

Dado este procedimiento, ¿cuál es la forma correcta de usarlo y ver el resultado?

```sql
CREATE PROCEDURE sp_promedio_estudiante(
    IN  p_id_estudiante INT,
    OUT p_promedio      DECIMAL(4,2)
)
```

- A) `SELECT sp_promedio_estudiante(5);`
- B) `CALL sp_promedio_estudiante(5);`
- C) `CALL sp_promedio_estudiante(5, promedio); SELECT promedio;`
- D) `CALL sp_promedio_estudiante(5, @promedio); SELECT @promedio;`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) `CALL sp_promedio_estudiante(5, @promedio); SELECT @promedio;`**

💡 Un procedimiento se ejecuta con `CALL`, con tantos argumentos como parámetros tiene. El parámetro `OUT` necesita una variable de usuario (`@`) donde dejar el valor.

</details>

---

### Pregunta 3

¿Qué hace este procedimiento al ejecutar `CALL sp_baja(3);`?

```sql
CREATE PROCEDURE sp_baja(IN id_estudiante INT)
BEGIN
    DELETE FROM inscripcion
    WHERE id_estudiante = id_estudiante;
END
```

- A) Elimina todas las inscripciones de la tabla
- B) Elimina las inscripciones del estudiante 3
- C) No elimina nada
- D) Da error porque falta un `COMMIT`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) Elimina todas las inscripciones de la tabla**

💡 El parámetro se llama igual que la columna, y dentro del procedimiento gana el parámetro: la condición compara `3 = 3`, verdadera para todas las filas. Por eso los parámetros llevan el prefijo `p_`.

</details>

---

### Pregunta 4

¿Cuál es una diferencia real entre un procedimiento y una función almacenada?

- A) Las funciones se ejecutan con `CALL` y los procedimientos dentro de un `SELECT`
- B) Los procedimientos no pueden recibir parámetros
- C) Una función devuelve siempre un único valor y se usa dentro de una expresión; un procedimiento se ejecuta con `CALL`
- D) Las funciones pueden hacer `COMMIT` y los procedimientos no

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Una función devuelve siempre un único valor y se usa dentro de una expresión; un procedimiento se ejecuta con `CALL`**

💡 Es exactamente al revés de lo que dicen A y D: las funciones no admiten transacciones ni devuelven tablas de resultados.

</details>

---

### Pregunta 5

¿Por qué MySQL rechaza esta función con `Error 1418`?

```sql
CREATE FUNCTION fn_doble(p_numero INT)
RETURNS INT
BEGIN
    RETURN p_numero * 2;
END
```

- A) Porque falta el `CALL`
- B) Porque no declara ninguna característica, como `DETERMINISTIC`
- C) Porque una función no puede multiplicar
- D) Porque `RETURNS` debería decir `RETURN`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Porque no declara ninguna característica, como `DETERMINISTIC`**

💡 MySQL exige indicar si la función es `DETERMINISTIC`, `NO SQL` o `READS SQL DATA`. Esta devuelve siempre lo mismo para el mismo número: es `DETERMINISTIC`.

</details>

---

### Pregunta 6

En un trigger `AFTER DELETE`, ¿qué se puede usar para leer los datos de la fila?

- A) Solo `NEW`
- B) `OLD` y `NEW`
- C) Ninguno de los dos
- D) Solo `OLD`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Solo `OLD`**

💡 En un `DELETE` hay fila "de antes" y no hay fila "de después". En un `INSERT` es al revés (solo `NEW`), y en un `UPDATE` existen las dos.

</details>

---

### Pregunta 7

La tabla `inscripcion` tiene un trigger `AFTER UPDATE … FOR EACH ROW` que inserta una fila en `auditoria_nota`. Se ejecuta un `UPDATE` que modifica 7 inscripciones. ¿Cuántas filas se agregan a la auditoría?

- A) 7, una por cada fila modificada
- B) 1, una por sentencia
- C) 0, hasta que se haga `COMMIT`
- D) 14, una por `OLD` y otra por `NEW`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) 7, una por cada fila modificada**

💡 `FOR EACH ROW` significa que el trigger se dispara una vez por cada fila afectada, cada vez con sus propios `OLD` y `NEW`.

</details>

---

### Pregunta 8

Se necesita que los nombres de los estudiantes se guarden siempre sin espacios al principio ni al final, los inserte quien los inserte. ¿Qué conviene usar?

- A) Un trigger `AFTER INSERT` que haga `SET NEW.nombre = TRIM(NEW.nombre)`
- B) Una función `fn_limpiar`, y confiar en que todos la usen
- C) Un trigger `BEFORE INSERT` que haga `SET NEW.nombre = TRIM(NEW.nombre)`
- D) Un procedimiento `sp_limpiar` que se ejecute una vez por semana

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Un trigger `BEFORE INSERT` que haga `SET NEW.nombre = TRIM(NEW.nombre)`**

💡 `NEW` solo se puede modificar **antes** de guardar la fila; en un `AFTER` da `Error 1362`. Y el trigger es lo único que se ejecuta siempre, sin depender de que alguien se acuerde.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 10](Resumen-Modulo10)
