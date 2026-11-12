> 🗄️ **Base de datos:** `liceo` (Módulo 11 — Administración) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo11/liceo.sql)

# 💾 Respaldo y restauración

## ¿Por qué lo necesitamos?

Toda la información del liceo —estudiantes, notas, inscripciones— vive en un solo lugar. Un `DROP` accidental, un disco que falla, una actualización que sale mal, y se pierde **todo**:

```sql
-- ❌ Un error de un segundo...
DROP DATABASE liceo;
```

No hay `ROLLBACK` que valga: `DROP DATABASE` no se deshace. La única red de seguridad es tener una **copia** hecha de antemano. Hacer respaldos no es opcional en un sistema real: es la diferencia entre "perdimos una hora" y "perdimos el año".

> **¿Qué es un respaldo?** Es una copia de la base que permite volver a un estado anterior. El tipo más común es el **respaldo lógico**: un archivo de texto con las sentencias SQL (`CREATE TABLE`, `INSERT`…) necesarias para **reconstruir** la base desde cero. La herramienta de MySQL para hacerlo se llama **`mysqldump`**.

> 📌 **Nota:** `mysqldump` **no** se ejecuta dentro de MySQL (no es una sentencia SQL). Es un programa aparte que se corre en la **terminal** del sistema operativo (la consola de Windows, la Terminal de Linux/Mac), no en Workbench ni en `mysql>`.

---

## Sintaxis

```bash
mysqldump -u <usuario> -p <base>  >  <archivo.sql>     # respaldar
mysql     -u <usuario> -p <base>  <  <archivo.sql>     # restaurar
```

| Parte | Significa |
| ----- | --------- |
| `mysqldump` | El programa que genera el respaldo |
| `-u root` | Usuario con permiso de lectura sobre la base |
| `-p` | Pide la contraseña (la escribís a continuación) |
| `liceo` | La base a respaldar |
| `>` `archivo.sql` | Guarda la salida en ese archivo |
| `<` `archivo.sql` | Alimenta el archivo a MySQL (restaurar) |

> ⚠️ El `>` (respaldar) y el `<` (restaurar) son opuestos. Confundirlos es peligroso: `mysql base < archivo` **escribe** sobre la base.

---

## Paso 1 — Respaldar toda la base

En la terminal del sistema (no en MySQL):

```bash
mysqldump -u root -p liceo > liceo_backup.sql
```

MySQL pide la contraseña y, en un instante, crea el archivo `liceo_backup.sql`. No muestra nada por pantalla si todo salió bien: el resultado **es el archivo**.

> 📌 **Nota:** conviene incluir la fecha en el nombre, por ejemplo `liceo_2026-11-12.sql`, para no pisar respaldos anteriores y saber de cuándo es cada uno.

---

## Paso 2 — Qué hay adentro del archivo

El respaldo es texto plano: se puede abrir con cualquier editor. Arriba lleva una cabecera con datos del volcado y algunos ajustes:

```sql
-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: liceo
-- ------------------------------------------------------
-- Server version	8.0.46
```

Después, **por cada tabla**, trae la sentencia para recrearla (precedida de un `DROP TABLE IF EXISTS`, para que la restauración funcione aunque la tabla ya exista) y los datos:

```sql
DROP TABLE IF EXISTS `grupo`;
CREATE TABLE `grupo` (
  `id_grupo` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `turno` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'matutino',
  PRIMARY KEY (`id_grupo`),
  UNIQUE KEY `uq_grupo_nombre` (`nombre`),
  CONSTRAINT `chk_grupo_turno` CHECK ((`turno` in (_utf8mb4'matutino',_utf8mb4'vespertino',_utf8mb4'nocturno')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

Y los datos como un `INSERT`:

```sql
INSERT INTO `docente` VALUES (1,'Ana','Pereira'),(2,'Carlos','Méndez'),(3,'Laura','Sosa'),(4,'Diego','Olivera'),(5,'Marta','Giménez');
```

Es exactamente lo que haría falta tipear para reconstruir la base entera. Por eso un respaldo lógico sirve también para **llevar la base a otra computadora**.

---

## Paso 3 — Restaurar

Si la base se perdió o se dañó, se reconstruye alimentando el archivo a MySQL. Primero, si la base no existe, se la crea vacía:

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS liceo;"
mysql -u root -p liceo < liceo_backup.sql
```

En segundos, `liceo` vuelve a tener todas sus tablas y datos tal como estaban al momento del respaldo.

> ⚠️ **La restauración sobrescribe.** Como el archivo trae `DROP TABLE IF EXISTS` antes de cada tabla, restaurar **reemplaza** las tablas actuales por las del respaldo. Lo que se haya cargado *después* del respaldo y no esté en el archivo, se pierde.

---

## Paso 4 — Respaldar solo la estructura o solo los datos

A veces no se quiere todo:

```bash
# Solo la estructura (tablas vacías), para crear una base "molde"
mysqldump -u root -p --no-data liceo > liceo_estructura.sql

# Solo los datos (sin CREATE TABLE), para recargar sobre una estructura que ya existe
mysqldump -u root -p --no-create-info liceo > liceo_datos.sql
```

Con `--no-data`, el archivo tiene los `CREATE TABLE` pero ningún `INSERT`:

```text
CREATE TABLE `asignatura` ( ...
CREATE TABLE `docente` ( ...
CREATE TABLE `estudiante` ( ...
CREATE TABLE `grupo` ( ...
CREATE TABLE `inscripcion` ( ...
```

---

## Paso 5 — Respaldar varias bases o el servidor entero

```bash
# Varias bases a la vez (el archivo incluye el CREATE DATABASE de cada una)
mysqldump -u root -p --databases liceo liceo_programado > varias.sql

# Absolutamente todo el servidor (todas las bases y los usuarios)
mysqldump -u root -p --all-databases > servidor_completo.sql
```

---

## Paso 6 — Respaldo consistente: --single-transaction

Si se respalda una base **mientras se está usando**, las tablas pueden cambiar a mitad del volcado y el respaldo queda incoherente (una tabla de las 10:00 y otra de las 10:01). Para tablas InnoDB —las de todo el curso— la opción `--single-transaction` toma una **foto** instantánea y consistente, **sin bloquear** a los demás usuarios:

```bash
mysqldump -u root -p --single-transaction liceo > liceo_backup.sql
```

> 💡 Para una base InnoDB en producción, `--single-transaction` es prácticamente obligatorio: respalda sin interrumpir el servicio.

---

## Paso 7 — Desde MySQL Workbench

Si preferís no usar la terminal, Workbench trae la misma funcionalidad con botones:

- **Respaldar:** menú **Server → Data Export**. Se eligen las bases y tablas, y si se quiere estructura, datos o ambos. Genera un `.sql` (o una carpeta de archivos).
- **Restaurar:** menú **Server → Data Import**. Se elige el archivo o carpeta y la base de destino.

Por detrás, Workbench ejecuta `mysqldump` y `mysql`: es la misma herramienta con otra cara.

---

## Paso 8 — Que el respaldo no dependa de acordarse

Un respaldo que hay que recordar hacer a mano tarde o temprano no se hace. Por eso se **programan** para que corran solos:

- En **Linux/Mac**, con `cron` (una línea que ejecuta el `mysqldump` todas las noches).
- En **Windows**, con el **Programador de tareas**.

La idea es siempre la misma: un `mysqldump` automático, a una hora de poco uso, que guarde el archivo con la fecha.

## Buenas prácticas

| Práctica | Por qué |
| -------- | ------- |
| **Regla 3-2-1** | 3 copias, en 2 medios distintos, 1 fuera del lugar. Un respaldo en el mismo disco que la base no sirve si el disco falla. |
| **Respaldos con fecha** | Para poder volver a un día concreto y no pisar copias viejas. |
| **Probar la restauración** | Un respaldo que nunca se probó restaurar puede estar roto sin que lo sepas. Probalo de vez en cuando. |
| **Automatizar** | Lo que depende de la memoria humana, falla. |
| **`--single-transaction` en InnoDB** | Respaldo consistente y sin cortar el servicio. |

## Diferencia clave: respaldo lógico vs físico

| Aspecto | Lógico (`mysqldump`) | Físico (copiar archivos del servidor) |
| ------- | -------------------- | ------------------------------------- |
| Qué guarda | Sentencias SQL (texto) | Los archivos de datos de MySQL |
| Tamaño | Más chico | Más grande |
| Velocidad en bases enormes | Más lento | Más rápido |
| Sirve para cambiar de versión/servidor | Sí | No siempre |
| Legible y editable | Sí | No |
| Ideal para | La mayoría de los casos; bases chicas y medianas | Bases muy grandes |

## ⚠️ Errores frecuentes

| Síntoma | Causa | Solución |
| ------- | ----- | -------- |
| `mysqldump: command not found` | MySQL no está en el PATH del sistema | Usar la ruta completa, o abrir la consola desde la carpeta `bin` de MySQL |
| `Access denied` al respaldar | El usuario no tiene permiso de lectura sobre la base | Respaldar con `root` o un usuario con `SELECT` |
| `Unknown database` al restaurar | La base de destino no existe | Crearla antes: `CREATE DATABASE liceo;` |
| El archivo de respaldo está vacío (0 KB) | Error que se escribió en pantalla, no en el archivo; o base mal escrita | Revisar el nombre de la base y el mensaje de error |
| Se restauró y faltan datos recientes | El respaldo era anterior a esos datos | Es lo esperado: un respaldo guarda el estado de *ese* momento |
| Acentos o ñ se ven mal tras restaurar | Diferencia de codificación | Asegurar `utf8mb4` en el volcado y en la base destino |
| Ejecuté `mysqldump` dentro de `mysql>` y da error de sintaxis | `mysqldump` va en la terminal, no en el cliente MySQL | Salir de `mysql>` y ejecutarlo en la consola del sistema |

---

Continuamos por el repaso del módulo → [Resumen del Módulo 11](Resumen-Modulo11)

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución. Son comandos de terminal.

**1.** Escribí el comando para respaldar la base `liceo` en un archivo llamado `liceo_2026-11-12.sql`.

<details>
<summary>Ver solución</summary>

```bash
mysqldump -u root -p liceo > liceo_2026-11-12.sql
```

💡 El `>` manda la salida al archivo. La fecha en el nombre evita pisar respaldos anteriores.
</details>

**2.** Alguien ejecutó `DROP DATABASE liceo;` por error. Tenés el archivo del ejercicio 1. Escribí los dos comandos para recuperarla.

<details>
<summary>Ver solución</summary>

```bash
mysql -u root -p -e "CREATE DATABASE liceo;"
mysql -u root -p liceo < liceo_2026-11-12.sql
```

💡 Primero la base vacía, después se le vuelca el respaldo con `<`. Se recupera el estado del momento en que se hizo la copia.
</details>

**3.** Querés armar una base "molde" con la misma estructura que `liceo` pero **sin datos**. ¿Qué comando usás?

<details>
<summary>Ver solución</summary>

```bash
mysqldump -u root -p --no-data liceo > liceo_estructura.sql
```

💡 `--no-data` incluye los `CREATE TABLE` pero ningún `INSERT`.
</details>

**4.** El servidor del liceo está en uso durante el día y las tablas son InnoDB. ¿Qué opción agregás para que el respaldo sea consistente y no bloquee a los usuarios?

<details>
<summary>Ver solución</summary>

```bash
mysqldump -u root -p --single-transaction liceo > liceo_backup.sql
```

💡 `--single-transaction` toma una foto consistente de InnoDB sin frenar el trabajo de los demás.
</details>

**5.** Verdadero o falso: "Como tengo un respaldo de hace un mes guardado en el mismo disco donde está la base, estoy cubierto". Justificá.

<details>
<summary>Ver solución</summary>

**Falso**, por dos motivos:

1. Si falla el disco, se pierden **la base y el respaldo** juntos (viola la regla 3-2-1: una copia debe estar en otro lugar).
2. Un respaldo de hace un mes pierde todo lo cargado en el último mes.

💡 El respaldo tiene que estar en **otro medio/lugar** y hacerse **seguido**.
</details>

---

## 📋 Palabras clave

`respaldo` · `backup` · `restauración` · `mysqldump` · `respaldo lógico` · `respaldo físico` · `--no-data` · `--no-create-info` · `--databases` · `--all-databases` · `--single-transaction` · `regla 3-2-1` · `Data Export` · `Data Import`

---

🧠 **[Autoevaluación — Módulo 11](auto-modulo11)**

---

← [Usuarios y permisos](Usuarios-y-permisos) · [🏠 Inicio](Home) · [Resumen del Módulo 11 →](Resumen-Modulo11)
