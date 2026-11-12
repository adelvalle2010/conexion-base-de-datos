> 🗄️ **Base de datos:** `liceo` (Módulo 11 — Administración) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo11/liceo.sql)

## Resumen

En este módulo dejamos de mirar los datos para ocuparnos de administrarlos: quién puede acceder y cómo protegerlos. Los conceptos principales que trabajamos fueron:

- **Usuario**: identificado por nombre **y** host (`'ana'@'localhost'`). Se crea con `CREATE USER … IDENTIFIED BY`.
- **Privilegio**: permiso para una acción (`SELECT`, `INSERT`…) sobre un alcance (global, base, tabla o columna).
- **`GRANT` / `REVOKE`**: dar y quitar permisos.
- **Principio de menor privilegio**: cada usuario recibe solo lo que necesita.
- **`SHOW GRANTS`**: ver qué puede hacer un usuario. `USAGE` = solo conectarse.
- **Roles** (MySQL 8): paquetes de permisos reutilizables, con `CREATE ROLE` y `SET DEFAULT ROLE`.
- **Respaldo lógico** (`mysqldump`): archivo SQL que reconstruye la base. Se ejecuta en la **terminal**, no en MySQL.
- **Restauración**: `mysql base < archivo.sql`.
- **`--single-transaction`**: respaldo consistente de InnoDB sin bloquear.

## 🧾 Sintaxis de un vistazo

| Sentencia / Comando | Para qué sirve | Ejemplo |
| ------------------- | -------------- | ------- |
| `CREATE USER` | Crear un usuario | `CREATE USER 'ana'@'localhost' IDENTIFIED BY 'clave';` |
| `GRANT` | Dar permisos | `GRANT SELECT ON liceo.* TO 'ana'@'localhost';` |
| `REVOKE` | Quitar permisos | `REVOKE INSERT ON liceo.inscripcion FROM 'ana'@'localhost';` |
| `SHOW GRANTS` | Ver permisos | `SHOW GRANTS FOR 'ana'@'localhost';` |
| `ALTER USER` | Cambiar contraseña | `ALTER USER 'ana'@'localhost' IDENTIFIED BY 'nueva';` |
| `DROP USER` | Eliminar usuario | `DROP USER 'ana'@'localhost';` |
| `CREATE ROLE` / `GRANT rol` | Crear y asignar un rol | `GRANT 'rol_consulta' TO 'ana'@'localhost';` |
| `mysqldump` | Respaldar | `mysqldump -u root -p liceo > liceo.sql` |
| `mysql <` | Restaurar | `mysql -u root -p liceo < liceo.sql` |
| `--no-data` | Respaldar solo estructura | `mysqldump -u root -p --no-data liceo > e.sql` |
| `--single-transaction` | Respaldo consistente InnoDB | `mysqldump -u root -p --single-transaction liceo > liceo.sql` |

## Niveles de un privilegio

| Nivel | Alcance | Ejemplo |
| ----- | ------- | ------- |
| Global | Todo el servidor | `ON *.*` |
| Base | Una base entera | `ON liceo.*` |
| Tabla | Una tabla | `ON liceo.inscripcion` |
| Columna | Una columna | `ON liceo.inscripcion (nota)` |

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño | Diagrama E-R, tablas y normalización | Módulos 1 a 3 ✅ |
| Implementación | Base `liceo` con estructura y datos | Módulos 4 a 6 ✅ |
| Consulta | De una tabla a `JOIN`, subconsultas y vistas | Módulos 7 y 8 ✅ |
| Rendimiento e integridad | Índices, `EXPLAIN`, transacciones | Módulo 9 ✅ |
| Programación en el servidor | Procedimientos, funciones y triggers | Módulo 10 ✅ |
| Administración | Usuarios, permisos, respaldo y restauración | Módulo 11 ✅ |
| Proyecto integrador | Aplicar todo de punta a punta | Módulo 12 |

De esta manera, cerramos la **Parte 3**. Ya sabés diseñar una base, implementarla, consultarla, hacerla rápida y confiable, programarla y administrarla. Solo queda juntar todo: en el próximo módulo armamos un **proyecto completo** desde el enunciado hasta las consultas, aplicando cada cosa que vimos.

---

## 📋 Palabras clave

`usuario` · `privilegio` · `GRANT` · `REVOKE` · `SHOW GRANTS` · `rol` · `menor privilegio` · `mysqldump` · `respaldo` · `restauración` · `--single-transaction` · `regla 3-2-1`

---

🧠 **[Autoevaluación — Módulo 11](auto-modulo11)**

---

← [Respaldo y restauración](Respaldo-y-restauracion) · [🏠 Inicio](Home) · [Introducción al Proyecto Integrador →](Introduccion-Proyecto-Integrador)
