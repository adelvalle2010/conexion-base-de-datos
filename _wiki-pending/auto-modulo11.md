# 🧠 Autoevaluación — Módulo 11

Responde cada pregunta antes de ver la respuesta.

---

### Pregunta 1

En MySQL, ¿qué identifica de forma única a un usuario?

- A) El nombre y el host desde el que se conecta
- B) Solo el nombre
- C) El nombre y la contraseña
- D) El número de id

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) El nombre y el host desde el que se conecta**

💡 Por eso `'ana'@'localhost'` y `'ana'@'%'` son usuarios distintos, aunque compartan el nombre.

</details>

---

### Pregunta 2

Se quiere que la adscripta solo pueda **leer** la base `liceo`. ¿Cuál es el `GRANT` correcto, siguiendo el principio de menor privilegio?

- A) `GRANT ALL PRIVILEGES ON *.* TO 'adscripta'@'localhost';`
- B) `GRANT SELECT ON liceo.* TO 'adscripta'@'localhost';`
- C) `GRANT SELECT ON *.* TO 'adscripta'@'localhost';`
- D) `GRANT SELECT, INSERT, UPDATE, DELETE ON liceo.* TO 'adscripta'@'localhost';`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) `GRANT SELECT ON liceo.* TO 'adscripta'@'localhost';`**

💡 Solo `SELECT` (leer) y solo sobre `liceo` (no todo el servidor). La A y la C dan permisos de más; la D agrega escritura que no pidió.

</details>

---

### Pregunta 3

Al hacer `SHOW GRANTS`, un usuario muestra como única línea `GRANT USAGE ON *.*`. ¿Qué puede hacer?

- A) Leer todas las bases
- B) Conectarse al servidor, pero nada con los datos
- C) Administrar el servidor
- D) Nada, ni siquiera conectarse

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) Conectarse al servidor, pero nada con los datos**

💡 `USAGE` es el permiso mínimo: existir y conectarse. Aparece siempre, aunque no tenga ningún otro privilegio.

</details>

---

### Pregunta 4

Un usuario con solo `GRANT SELECT ON liceo.*` ejecuta `DELETE FROM estudiante WHERE id_estudiante = 1;`. ¿Qué pasa?

- A) Borra la fila
- B) Borra toda la tabla
- C) Se queda esperando
- D) MySQL lo rechaza con un error de permisos (1142)

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) MySQL lo rechaza con un error de permisos (1142)**

💡 `DELETE command denied to user … for table 'estudiante'`. MySQL revisa los permisos en **cada** sentencia; sin `DELETE`, no lo deja.

</details>

---

### Pregunta 5

¿Para qué sirven los **roles** en MySQL 8?

- A) Para cifrar las contraseñas
- B) Para respaldar la base
- C) Para agrupar permisos y asignarlos de una vez a varios usuarios
- D) Para conectarse sin contraseña

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **C) Para agrupar permisos y asignarlos de una vez a varios usuarios**

💡 Se define un rol con sus permisos una vez, y se asigna a cuantos usuarios haga falta. Si el rol cambia, el cambio lo heredan todos.

</details>

---

### Pregunta 6

¿Dónde se ejecuta el comando `mysqldump`?

- A) En la terminal del sistema operativo
- B) Dentro de MySQL Workbench, en la pestaña de consultas
- C) En el cliente `mysql>`, como una sentencia SQL
- D) En el navegador

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **A) En la terminal del sistema operativo**

💡 `mysqldump` es un programa aparte, no una sentencia SQL. Se corre en la consola, no dentro de `mysql>` ni en el editor de Workbench.

</details>

---

### Pregunta 7

¿Cuál de estos comandos **restaura** la base `liceo` desde un archivo de respaldo?

- A) `mysqldump -u root -p liceo > liceo.sql`
- B) `mysql -u root -p liceo < liceo.sql`
- C) `mysqldump -u root -p liceo < liceo.sql`
- D) `mysql -u root -p liceo > liceo.sql`

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **B) `mysql -u root -p liceo < liceo.sql`**

💡 Restaurar usa `mysql` (no `mysqldump`) y `<` (alimenta el archivo a la base). La A es un respaldo; la C y la D mezclan mal el programa y la dirección.

</details>

---

### Pregunta 8

¿Por qué conviene usar `--single-transaction` al respaldar una base InnoDB en uso?

- A) Porque hace el archivo más chico
- B) Porque cifra el respaldo
- C) Porque incluye a los usuarios y sus permisos
- D) Porque toma una foto consistente sin bloquear a los demás usuarios

<details>
<summary><strong>Ver respuesta</strong></summary>

✅ **D) Porque toma una foto consistente sin bloquear a los demás usuarios**

💡 Sin esa opción, si la base cambia durante el volcado, el respaldo puede quedar incoherente. `--single-transaction` garantiza que todo el respaldo corresponde al mismo instante.

</details>

---

🏠 [Volver al índice](Home)

---

← [Volver a Resumen del Módulo 11](Resumen-Modulo11)
