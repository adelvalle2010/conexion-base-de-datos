## Resumen

En este módulo hemos visto cómo preparar el entorno de trabajo y dar los primeros pasos con el lenguaje. Los conceptos principales que trabajamos fueron:

- **MySQL Server**: el SGBD; guarda los datos y responde las consultas. Funciona como un servicio, sin ventanas.
- **MySQL Workbench**: el cliente gráfico desde el que escribimos SQL. No guarda datos.
- **Conexión**: se define con hostname (`localhost`), puerto (`3306`), usuario (`root`) y contraseña.
- **Script**: archivo `.sql` con varias sentencias que se ejecutan juntas.
- **SQL**: lenguaje declarativo y estándar; se dice qué se quiere, no cómo obtenerlo.
- **Familias de SQL**: DDL (estructura), DML (filas), DQL (consultas), TCL (transacciones) y DCL (permisos).

## 🧾 Sintaxis de un vistazo

| Sentencia | Para qué sirve | Ejemplo |
| --------- | -------------- | ------- |
| `SELECT VERSION();` | Ver la versión del servidor | `SELECT VERSION();` |
| `SHOW DATABASES;` | Listar las bases de datos | `SHOW DATABASES;` |
| `USE` | Elegir la base activa | `USE liceo_sin_normalizar;` |
| `SHOW TABLES;` | Listar las tablas de la base activa | `SHOW TABLES;` |
| `SELECT * FROM` | Ver todo el contenido de una tabla | `SELECT * FROM docente;` |
| `-- comentario` | Anotar sin que se ejecute | `-- esto no se ejecuta` |

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño conceptual y lógico | Diagrama E-R y tablas | Módulos 1 y 2 ✅ |
| Revisión del diseño | Normalización | Módulo 3 ✅ |
| Entorno | Servidor instalado, conexión funcionando | Módulo 4 ✅ |
| Implementación | Crear la base del liceo | Módulos 5 y 6 |
| Consulta | Preguntarle cosas a la base | Módulos 7 y 8 |

De esta manera, ya tenemos un servidor funcionando, un cliente conectado y una idea general del lenguaje. Hasta acá usamos una base que venía hecha en un script; en el próximo módulo la construimos nosotros desde cero, empezando por `CREATE DATABASE`.

---

## 📋 Palabras clave

`MySQL Server` · `MySQL Workbench` · `cliente` · `servidor` · `conexión` · `localhost` · `root` · `script` · `SQL` · `DDL` · `DML` · `DQL` · `USE` · `SHOW TABLES`

---

🧠 **[Autoevaluación — Módulo 4](auto-modulo4)**

---

← [¿Qué es SQL? El mapa del lenguaje](Que-es-SQL) · [🏠 Inicio](Home) · [CREATE: Crear Bases de Datos y Tablas →](CREATE-bases-de-datos-y-tablas)
