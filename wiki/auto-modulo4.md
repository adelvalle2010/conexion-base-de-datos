# 🧠 Autoevaluación — Módulo 4

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

¿Cuál es la diferencia entre MySQL Server y MySQL Workbench?

- A) Son dos nombres del mismo programa
- B) Workbench guarda los datos y Server los muestra en pantalla
- C) Server es el SGBD que guarda los datos; Workbench es un cliente para enviarle sentencias
- D) Server es la versión paga y Workbench la gratuita

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Server es el SGBD que guarda los datos; Workbench es un cliente para enviarle sentencias**

💡 El servidor es la cocina y Workbench es el mozo: si desinstalás Workbench, los datos siguen en el servidor.

</details>

---

### Pregunta 2

Al conectarte, Workbench muestra `Error 2003: Can't connect to MySQL server on 'localhost'`. ¿Cuál es la causa más probable?

- A) El servicio de MySQL está detenido o el puerto es incorrecto
- B) La contraseña de root es incorrecta
- C) La base de datos no existe
- D) Falta un punto y coma

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) El servicio de MySQL está detenido o el puerto es incorrecto**

💡 El error 2003 significa que no hubo con quién hablar. Una contraseña mal escrita da otro error, el 1045 (*Access denied*), porque ahí el servidor sí respondió.

</details>

---

### Pregunta 3

En la conexión, ¿qué significa `localhost`?

- A) El nombre del usuario administrador
- B) El nombre de la base de datos por defecto
- C) El puerto por el que escucha MySQL
- D) Que el servidor está en la misma computadora desde la que nos conectamos

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Que el servidor está en la misma computadora desde la que nos conectamos**

💡 `localhost` es "esta misma máquina". El usuario administrador es `root` y el puerto habitual es `3306`.

</details>

---

### Pregunta 4

Ejecutás `SELECT * FROM estudiante;` y aparece `Error 1046: No database selected`. ¿Qué faltó?

- A) Crear la tabla `estudiante`
- B) Elegir la base con `USE nombre_base;`
- C) Escribir `SELECT` en minúscula
- D) Reiniciar el servidor

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Elegir la base con `USE nombre_base;`**

💡 El servidor puede tener muchas bases, y puede haber una tabla `estudiante` en varias. Hay que decirle en cuál buscar.

</details>

---

### Pregunta 5

¿Qué quiere decir que SQL es un lenguaje **declarativo**?

- A) Que solo sirve para declarar variables
- B) Que cada sentencia debe ocupar una sola línea
- C) Que se indica qué resultado se quiere, y no los pasos para obtenerlo
- D) Que solo funciona en MySQL

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Que se indica qué resultado se quiere, y no los pasos para obtenerlo**

💡 Como en la panadería: pedís dos bizcochos, no explicás cómo caminar hasta la bandeja. El SGBD decide cómo buscar.

</details>

---

### Pregunta 6

¿A qué familia de SQL pertenece `CREATE TABLE`?

- A) DDL, porque define la estructura
- B) DML, porque crea datos
- C) DQL, porque consulta
- D) DCL, porque controla el acceso

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) DDL, porque define la estructura**

💡 `CREATE` construye la "habitación" (DDL). Meter filas adentro es `INSERT`, que es DML. La confusión típica es pensar que crear una tabla es "manipular datos".

</details>

---

### Pregunta 7

¿Qué devuelve esta sentencia?

```sql
SELECT 10 - 4 AS resultado;
```

- A) Un error, porque no se indicó una tabla
- B) Una columna llamada `10 - 4` con el valor 6
- C) Seis filas vacías
- D) Una columna llamada `resultado` con el valor 6

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Una columna llamada `resultado` con el valor 6**

💡 Un `SELECT` puede calcular sin usar ninguna tabla, y `AS` le pone nombre a la columna del resultado.

</details>

---

### Pregunta 8

¿Cuál de estas afirmaciones sobre la escritura de SQL en MySQL es correcta?

- A) `select` y `SELECT` son sentencias distintas
- B) Las sentencias terminan con punto y coma, y los textos van entre comillas simples
- C) Cada cláusula debe ir obligatoriamente en una línea aparte
- D) Los comentarios se escriben entre comillas dobles

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Las sentencias terminan con punto y coma, y los textos van entre comillas simples**

💡 Las palabras reservadas no distinguen mayúsculas y los saltos de línea son solo para leer mejor. Los comentarios se escriben con `--` o entre `/* */`.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 4](Resumen-Modulo4)
