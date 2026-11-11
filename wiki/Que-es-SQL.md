## ¿Cómo se le habla a una base de datos?

Cuando usás una aplicación, tocás botones: "guardar", "buscar", "eliminar". Con una base de datos no hay botones: se le **escribe**. En la página anterior escribiste `SHOW DATABASES;` y el servidor respondió. Eso que escribiste no es un comando suelto de MySQL: es parte de un lenguaje completo.

Pensá en pedir en una panadería: "Deme dos bizcochos de los que están en la bandeja de la izquierda". No explicás **cómo** caminar hasta la bandeja ni cómo agarrarlos; decís **qué** querés. Un lenguaje que funciona así, donde se describe el resultado y no los pasos, se conoce como lenguaje **declarativo**. El de las bases de datos relacionales se llama **SQL** (*Structured Query Language*, lenguaje de consulta estructurado).

```sql
SELECT nombre, apellido
FROM estudiante
WHERE grupo = '3ºA';
```

**Resultado:**

| nombre | apellido |
| ------ | -------- |
| Lucía | Fernández |
| Valentina | Rodríguez |

No le dijimos a MySQL cómo recorrer la tabla. Le dijimos qué columnas queremos, de qué tabla y con qué condición.

## 📍 Un lenguaje, varios motores

SQL es un **estándar**: lo entienden MySQL, PostgreSQL, SQL Server, Oracle y SQLite, entre muchos otros. Lo que aprendas acá te sirve en cualquiera de ellos, con pequeñas diferencias.

| | SQL | MySQL |
| - | --- | ----- |
| Qué es | Un lenguaje | Un programa (SGBD) |
| Quién lo define | Un estándar internacional | Oracle |
| Se instala | No | Sí |
| Relación | Es lo que se escribe | Es quien lo entiende y lo ejecuta |

> 📌 Cuando algo de esta wiki sea propio de MySQL y no del estándar (por ejemplo `AUTO_INCREMENT` o `LIMIT`), lo vamos a avisar.

## 🧩 El mapa: las familias de sentencias

Las sentencias de SQL se agrupan según lo que hacen. Este es el mapa del resto del curso:

| Familia | Nombre | Qué hace | Sentencias | Dónde lo vemos |
| ------- | ------ | -------- | ---------- | -------------- |
| **DDL** | Lenguaje de definición de datos | Crea y cambia la **estructura** | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` | [Módulo 5](CREATE-bases-de-datos-y-tablas) |
| **DML** | Lenguaje de manipulación de datos | Agrega, cambia y borra **filas** | `INSERT`, `UPDATE`, `DELETE` | [Módulo 6](INSERT-insertar-registros) |
| **DQL** | Lenguaje de consulta de datos | **Lee** datos | `SELECT` | [Módulos 7](SELECT-sintaxis-basica) y [8](Funciones-de-agrupacion) |
| **TCL** | Lenguaje de control de transacciones | Confirma o deshace cambios | `COMMIT`, `ROLLBACK` | [Transacciones y propiedades ACID](Transacciones) |
| **DCL** | Lenguaje de control de datos | Define **quién** puede hacer qué | `GRANT`, `REVOKE` | [Usuarios y permisos](Usuarios-y-permisos) |

Una forma de recordarlo es pensar en una casa: con DDL se **construyen** las habitaciones, con DML se **meten y sacan** los muebles, con DQL se **mira** qué hay adentro, y con DCL se reparten las **llaves**.

Para hacerse una idea de la escala: en una aplicación real, el DDL se ejecuta unas pocas veces (cuando se crea o se cambia la base), mientras que las consultas y los cambios de datos se ejecutan miles de veces por día.

## ⚙️ Cómo se escribe una sentencia

```text
SELECT nombre, apellido      ← cláusula: qué columnas
FROM estudiante              ← cláusula: de qué tabla
WHERE grupo = '3ºA';         ← cláusula: con qué condición, y el punto y coma que cierra
```

| Regla | Ejemplo | Detalle |
| ----- | ------- | ------- |
| Termina con punto y coma | `SHOW TABLES;` | Sin él, MySQL no sabe dónde termina |
| Las palabras reservadas no distinguen mayúsculas | `select` = `SELECT` | En esta wiki van siempre en MAYÚSCULA para distinguirlas |
| Los textos y las fechas van entre comillas simples | `'3ºA'`, `'2026-04-15'` | Los números no llevan comillas |
| Los espacios y saltos de línea no importan | Una cláusula por línea | Se escribe así para que se pueda leer |
| Comentarios | `-- hasta el fin de la línea` | También `/* varias líneas */` |

```sql
-- ❌ Funciona, pero cuesta leerlo y corregirlo
select nombre,apellido from estudiante where grupo='3ºA';

-- ✅ Lo mismo, con el estilo de esta wiki
SELECT nombre, apellido
FROM estudiante
WHERE grupo = '3ºA';
```

> 📌 **Nota:** los nombres de tablas sí pueden distinguir mayúsculas según el sistema operativo (en Linux, `Estudiante` y `estudiante` son tablas distintas). Por eso usamos siempre minúsculas: las convenciones completas están en [Anexo: Buenas prácticas de nombres y estilo](Anexo-Buenas-practicas).

## ¿Qué es el script `liceo`?

A partir del próximo módulo dejamos la planilla de práctica y construimos la base definitiva del liceo, paso a paso:

- Creamos la base y sus tablas con DDL, en [CREATE: Crear Bases de Datos y Tablas](CREATE-bases-de-datos-y-tablas) y [Claves Primarias (PK) y Foráneas (FK)](Claves-primarias-y-foraneas).
- Cargamos estudiantes, docentes y notas con DML, desde [INSERT: Insertar registros](INSERT-insertar-registros).
- Le hacemos preguntas con DQL, desde [SELECT: Sintaxis básica](SELECT-sintaxis-basica).

---

## 📋 Palabras clave

`SQL` · `lenguaje declarativo` · `estándar` · `sentencia` · `cláusula` · `palabra reservada` · `DDL` · `DML` · `DQL` · `TCL` · `DCL` · `punto y coma` · `comentario` · `comillas simples`

---

🧠 **[Autoevaluación — Módulo 4](auto-modulo4)**

---

← [Conexión al servidor y primeros pasos](Conexion-al-servidor-y-primeros-pasos) · [🏠 Inicio](Home) · [Resumen del Módulo 4 →](Resumen-Modulo4)
