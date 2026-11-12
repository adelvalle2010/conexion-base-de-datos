> 🗄️ **Base de datos:** `liceo` (Módulo 11 — Administración) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo11/liceo.sql)

# 👥 Usuarios y permisos

Con este módulo entramos en la **administración** de la base: ya no se trata de diseñar o consultar, sino de decidir **quién** puede hacer **qué**, y de poder **recuperar** los datos si algo sale mal. Empezamos por los usuarios. Partimos de la base `liceo` original.

## ¿Por qué lo necesitamos?

En todo el curso trabajamos como **`root`**, el superusuario que puede hacer **absolutamente todo**: crear y borrar bases, cambiar datos, eliminar tablas, crear otros usuarios. Está bien para aprender, pero en un sistema real es peligroso:

```sql
-- ❌ Si la aplicación del liceo se conecta como root y tiene un error (o la atacan),
--    quien esté del otro lado puede borrar TODA la base.
DROP DATABASE liceo;
```

La adscripta que carga las notas necesita **leer** y **modificar inscripciones**, nada más. No necesita poder eliminar la tabla `estudiante` ni crear bases nuevas. Darle solo lo que necesita es el **principio de menor privilegio**: cada usuario recibe los permisos mínimos para su tarea, y ninguno más.

> **¿Qué es un usuario?** En MySQL, un usuario se identifica por **dos** partes: el nombre y el **host** desde el que se conecta, escritas `'nombre'@'host'`. Así, `'ana'@'localhost'` (Ana conectándose desde la misma máquina) es distinto de `'ana'@'%'` (Ana desde cualquier lugar).

> **¿Qué es un privilegio?** Es un permiso para realizar una acción concreta (`SELECT`, `INSERT`, `DROP`…) sobre un alcance concreto (todo el servidor, una base, una tabla o una columna).

---

## Sintaxis

| Sentencia | Para qué sirve |
| --------- | -------------- |
| `CREATE USER 'u'@'host' IDENTIFIED BY 'clave'` | Crea un usuario con contraseña |
| `GRANT <privilegios> ON <alcance> TO 'u'@'host'` | Otorga permisos |
| `REVOKE <privilegios> ON <alcance> FROM 'u'@'host'` | Quita permisos |
| `SHOW GRANTS FOR 'u'@'host'` | Muestra qué puede hacer un usuario |
| `ALTER USER 'u'@'host' IDENTIFIED BY 'nueva'` | Cambia la contraseña |
| `DROP USER 'u'@'host'` | Elimina el usuario |
| `CREATE ROLE 'rol'` | Crea un rol (conjunto de permisos reutilizable) |

> 📌 **Nota:** estas sentencias las ejecuta un usuario administrador (como `root`). Un usuario común no puede crear otros usuarios ni darse permisos a sí mismo.

---

## Paso 1 — Crear un usuario

Creamos la cuenta de la adscripta de biblioteca, que se conecta desde la misma máquina del servidor:

```sql
CREATE USER 'bibliotecario'@'localhost' IDENTIFIED BY 'Biblio2026';
```

```text
Query OK, 0 rows affected
```

El usuario ya existe, pero **todavía no puede hacer nada** con los datos: recién tiene permiso para conectarse.

> ⚠️ **La contraseña es un ejemplo.** En un sistema real usá contraseñas largas y difíciles de adivinar, y nunca las dejes escritas en el código de la aplicación.

---

## Paso 2 — Otorgar privilegios

Le damos permiso para **leer** toda la base y para **cargar y corregir inscripciones** (pero no para tocar el resto):

```sql
GRANT SELECT ON liceo.* TO 'bibliotecario'@'localhost';
GRANT INSERT, UPDATE ON liceo.inscripcion TO 'bibliotecario'@'localhost';
```

**Elementos clave:**

- `SELECT`, `INSERT`, `UPDATE`: las acciones permitidas.
- `liceo.*`: el alcance "todas las tablas de la base `liceo`".
- `liceo.inscripcion`: el alcance "solo la tabla `inscripcion`".

Se puede dar y quitar permisos en cualquier momento; tienen efecto la próxima vez que el usuario se conecta.

---

## Paso 3 — Los niveles de un privilegio

El alcance (el `ON …`) define **sobre qué** se aplica el permiso. De más amplio a más acotado:

| Nivel | Se escribe | Ejemplo | Alcanza a… |
| ----- | ---------- | ------- | ---------- |
| Global | `*.*` | `GRANT SELECT ON *.* …` | Todas las bases del servidor |
| Base de datos | `base.*` | `GRANT SELECT ON liceo.* …` | Todas las tablas de `liceo` |
| Tabla | `base.tabla` | `GRANT UPDATE ON liceo.inscripcion …` | Solo esa tabla |
| Columna | `base.tabla (col)` | `GRANT UPDATE (nota) ON liceo.inscripcion …` | Solo esa columna |

> 💡 **Regla práctica:** empezá por el nivel más acotado que sirva. Es más fácil agregar un permiso que lamentar haber dado uno de más.

---

## Paso 4 — Ver qué puede hacer un usuario

```sql
SHOW GRANTS FOR 'bibliotecario'@'localhost';
```

**Resultado:**

```text
GRANT USAGE ON *.* TO `bibliotecario`@`localhost`
GRANT SELECT ON `liceo`.* TO `bibliotecario`@`localhost`
GRANT INSERT, UPDATE ON `liceo`.`inscripcion` TO `bibliotecario`@`localhost`
```

Las tres líneas son los permisos acumulados. La primera, `USAGE ON *.*`, aparece siempre: significa **"puede conectarse, y nada más"**. Es el permiso con el que nace todo usuario; los otros dos son los que le agregamos.

---

## Paso 5 — Probar el usuario limitado

Nos conectamos **como la adscripta** (en la consola: `mysql -u bibliotecario -p liceo`) y probamos.

**Lo permitido** — leer estudiantes:

```sql
SELECT nombre, apellido FROM estudiante LIMIT 3;
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Lucía | Fernández |
| Mateo | Silva |
| Valentina | Rodríguez |

**Lo prohibido** — borrar un estudiante:

```sql
DELETE FROM estudiante WHERE id_estudiante = 1;
```

```text
ERROR 1142 (42000): DELETE command denied to user 'bibliotecario'@'localhost' for table 'estudiante'
```

**Lo prohibido** — crear una base nueva:

```sql
CREATE DATABASE prueba_x;
```

```text
ERROR 1044 (42000): Access denied for user 'bibliotecario'@'localhost' to database 'prueba_x'
```

MySQL no solo confía en que el usuario "se porte bien": **revisa los permisos en cada sentencia** y rechaza lo que no está autorizado. Exactamente lo que queríamos.

---

## Paso 6 — Quitar privilegios

La adscripta deja de cargar notas y pasa a solo consultar. Le sacamos los permisos de escritura:

```sql
REVOKE INSERT, UPDATE ON liceo.inscripcion FROM 'bibliotecario'@'localhost';
```

```sql
SHOW GRANTS FOR 'bibliotecario'@'localhost';
```

**Resultado:**

```text
GRANT USAGE ON *.* TO `bibliotecario`@`localhost`
GRANT SELECT ON `liceo`.* TO `bibliotecario`@`localhost`
```

`REVOKE` es el espejo de `GRANT`: mismas palabras, pero `FROM` en lugar de `TO`. Quedó solo con lectura.

---

## Paso 7 — Roles: permisos reutilizables (MySQL 8)

Si hay diez docentes que necesitan **los mismos permisos**, darlos de a uno es tedioso y fácil de equivocar. Un **rol** es un paquete de permisos con nombre, que se asigna de una vez.

```sql
-- 1. Crear el rol y darle permisos
CREATE ROLE 'rol_consulta';
GRANT SELECT ON liceo.* TO 'rol_consulta';

-- 2. Crear el usuario y asignarle el rol
CREATE USER 'docente_ana'@'localhost' IDENTIFIED BY 'Ana2026';
GRANT 'rol_consulta' TO 'docente_ana'@'localhost';

-- 3. Activar el rol por defecto al conectarse
SET DEFAULT ROLE ALL TO 'docente_ana'@'localhost';
```

Ahora, para que todos los docentes puedan consultar, basta con asignarles `rol_consulta`. Y si mañana el rol necesita un permiso más, se agrega **una vez** al rol y lo heredan todos.

> 📌 **Nota:** el `SET DEFAULT ROLE` es necesario en MySQL: sin él, el usuario tiene el rol pero "apagado", y debería activarlo con `SET ROLE` en cada sesión.

---

## Paso 8 — Cambiar la contraseña y eliminar un usuario

```sql
-- Cambiar la contraseña
ALTER USER 'bibliotecario'@'localhost' IDENTIFIED BY 'NuevaClave2026';

-- Eliminar un usuario (sus permisos se van con él)
DROP USER 'docente_ana'@'localhost';
```

> ⚠️ **`DROP USER` no se puede deshacer.** El usuario y todos sus permisos desaparecen. Los **datos** de las tablas no se tocan: borrar al usuario no borra lo que ese usuario cargó.

---

## Privilegios más comunes

| Privilegio | Permite |
| ---------- | ------- |
| `SELECT` | Leer datos |
| `INSERT` | Agregar filas |
| `UPDATE` | Modificar filas |
| `DELETE` | Borrar filas |
| `CREATE` | Crear bases y tablas |
| `DROP` | Eliminar bases y tablas |
| `ALTER` | Modificar la estructura de tablas |
| `EXECUTE` | Ejecutar procedimientos y funciones |
| `ALL PRIVILEGES` | Todos los anteriores (sobre el alcance indicado) |
| `GRANT OPTION` | Poder dar a otros los permisos que uno tiene |

> ⚠️ **`GRANT ALL PRIVILEGES ON *.*`** convierte a un usuario casi en otro `root`. Se usa muy pocas veces y con mucho cuidado.

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `Error 1044`: *Access denied for user … to database* | El usuario no tiene permiso sobre esa base | Darle el `GRANT` correspondiente |
| `Error 1142`: *command denied to user … for table* | Le falta ese privilegio sobre esa tabla | `GRANT <privilegio> ON base.tabla` |
| `Error 1396`: *Operation CREATE USER failed* | El usuario ya existe (o se intenta borrar uno que no existe) | `CREATE USER IF NOT EXISTS`, o revisar el nombre y el host |
| `Error 1064` cerca de `@` | Faltan las comillas: debe ser `'nombre'@'host'` | Escribir cada parte entre comillas simples |
| El usuario no puede conectarse desde otra PC | Se creó como `@'localhost'` | Crear `'u'@'%'` o el host específico |
| Cambié permisos y el usuario no los ve | Tenía la sesión abierta de antes | Los cambios aplican al reconectarse |

> 📌 **Nota sobre `FLUSH PRIVILEGES`:** los comandos `CREATE USER`, `GRANT` y `REVOKE` aplican los cambios al instante. `FLUSH PRIVILEGES` solo hace falta si se tocan **a mano** las tablas del sistema (`mysql.user`), algo que casi nunca conviene hacer.

---

Continuamos por cómo proteger los datos de un accidente o una falla → [Respaldo y restauración](Respaldo-y-restauracion)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** Creá un usuario `'director'@'localhost'` con contraseña, que pueda **leer** toda la base `liceo` pero nada más.

<details>
<summary>Ver solución</summary>

```sql
CREATE USER 'director'@'localhost' IDENTIFIED BY 'Dir2026';
GRANT SELECT ON liceo.* TO 'director'@'localhost';
```

💡 Con `SELECT ON liceo.*` alcanza. No hace falta ningún otro permiso para solo consultar.
</details>

**2.** Un usuario `'secretaria'@'localhost'` ya existe. Dale permiso para **cargar y modificar notas**, pero que solo pueda tocar la columna `nota` de `inscripcion`.

<details>
<summary>Ver solución</summary>

```sql
GRANT UPDATE (nota) ON liceo.inscripcion TO 'secretaria'@'localhost';
```

💡 El permiso a nivel de **columna** se escribe con la columna entre paréntesis después de la tabla. Así puede cambiar la nota pero no, por ejemplo, el `id_estudiante`.
</details>

**3.** Mostrá los permisos del usuario `'bibliotecario'@'localhost'` y explicá qué significa la línea `USAGE`.

<details>
<summary>Ver solución</summary>

```sql
SHOW GRANTS FOR 'bibliotecario'@'localhost';
```

💡 `USAGE ON *.*` significa "puede conectarse al servidor, sin ningún permiso sobre los datos". Aparece siempre, aunque al usuario se le quiten todos los demás permisos.
</details>

**4.** Al usuario `'director'@'localhost'` del ejercicio 1 se le quiere dar también permiso para **borrar** inscripciones. Escribí la sentencia.

<details>
<summary>Ver solución</summary>

```sql
GRANT DELETE ON liceo.inscripcion TO 'director'@'localhost';
```

💡 Se pueden sumar permisos con sucesivos `GRANT`; se van acumulando.
</details>

**5.** Creá un rol `'rol_carga'` que permita `SELECT`, `INSERT` y `UPDATE` sobre `liceo.inscripcion`, y asignáselo a `'secretaria'@'localhost'`.

<details>
<summary>Ver solución</summary>

```sql
CREATE ROLE 'rol_carga';
GRANT SELECT, INSERT, UPDATE ON liceo.inscripcion TO 'rol_carga';

GRANT 'rol_carga' TO 'secretaria'@'localhost';
SET DEFAULT ROLE ALL TO 'secretaria'@'localhost';
```

💡 Si mañana diez secretarias necesitan lo mismo, se les asigna el rol y listo.
</details>

**6.** El usuario `'bibliotecario'@'localhost'` ya no trabaja en el liceo. Quitale todos sus accesos de la forma más simple.

<details>
<summary>Ver solución</summary>

```sql
DROP USER 'bibliotecario'@'localhost';
```

💡 Borrar el usuario se lleva todos sus permisos de una vez. No hace falta ir revocando de a uno.
</details>

---

## 📋 Palabras clave

`usuario` · `host` · `privilegio` · `CREATE USER` · `GRANT` · `REVOKE` · `SHOW GRANTS` · `DROP USER` · `principio de menor privilegio` · `USAGE` · `rol` · `CREATE ROLE` · `nivel global/base/tabla/columna` · `Error 1142` · `Error 1044`

---

🧠 **[Autoevaluación — Módulo 11](auto-modulo11)**

---

← [Resumen del Módulo 10](Resumen-Modulo10) · [🏠 Inicio](Home) · [Respaldo y restauración →](Respaldo-y-restauracion)
