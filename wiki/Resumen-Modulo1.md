## Resumen

En este módulo hemos visto cómo pasar de una idea ("necesito guardar los datos del liceo") a un diseño de base de datos listo para crearse en MySQL. Los conceptos principales que trabajamos fueron:

- **Base de datos**: conjunto organizado de datos relacionados entre sí, guardados en tablas para poder consultarlos y modificarlos.
- **SGBD**: el programa que administra la base de datos (en esta wiki, MySQL); recibe consultas y mantiene la integridad de los datos.
- **Modelo Entidad-Relación**: diagrama con entidades, atributos y relaciones; incluye la cardinalidad (1:1, 1:N, N:M) de cada vínculo.
- **Modelo relacional**: traducción del diagrama a tablas conectadas por claves primarias (PK) y foráneas (FK); las relaciones N:M se resuelven con una tabla intermedia.
- **Tipos de datos**: la clase de valor que admite cada columna (`INT`, `DECIMAL`, `VARCHAR`, `DATE`...).

La ventaja de diseñar antes de programar es que cada etapa responde una pregunta distinta:

- **Diagrama E-R**: ¿qué cosas existen y cómo se relacionan?
- **Modelo relacional**: ¿qué tablas y qué claves necesito para guardarlas sin repetir datos?
- **Tipos de datos**: ¿qué clase de valor guarda cada columna?

De esta manera, el ejemplo guía del liceo quedó definido por completo (`docente`, `estudiante`, `asignatura` e `inscripcion`) sin haber escrito todavía una sola línea de SQL. Eso es justamente lo que haremos en el próximo módulo: instalar MySQL y empezar a trabajar con él.

---

## 📋 Palabras clave

`base de datos` · `SGBD` · `MySQL` · `entidad` · `atributo` · `relación` · `cardinalidad` · `modelo relacional` · `clave primaria (PK)` · `clave foránea (FK)` · `tabla intermedia` · `tipo de dato` · `integridad`

---

🧠 **[Autoevaluación — Módulo 1](auto-modulo1)**

---

← [Tipos de Datos en MySQL](Tipos-de-datos-en-MySQL) · [🏠 Inicio](Home) · [Instalación de MySQL y Workbench →](Instalacion-de-MySQL-y-Workbench)
