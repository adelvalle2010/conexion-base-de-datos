> 🗄️ **Base de datos:** `liceo_sin_normalizar` (Módulo 3 — Normalización) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo3/liceo_sin_normalizar.sql)

## Resumen

En este módulo hemos visto cómo revisar un diseño y corregirlo paso a paso, partiendo de la planilla única de la secretaría. Los conceptos principales que trabajamos fueron:

- **Redundancia**: el mismo dato escrito en más de un lugar.
- **Anomalías**: los problemas que causa la redundancia al insertar, modificar o borrar.
- **Dependencia funcional**: `A → B`, conocer A determina B. Puede ser completa, parcial o transitiva.
- **1FN**: un valor por celda y clave primaria.
- **2FN**: nada depende de solo una parte de la clave.
- **3FN**: nada depende de otra columna que no sea clave.
- **BCNF**: todo determinante es clave candidata.

## 🧾 Las formas normales de un vistazo

| Forma normal | Pregunta que hay que hacerse | Si la respuesta es sí… | En el liceo |
| ------------ | ---------------------------- | ---------------------- | ----------- |
| 1FN | ¿Hay celdas con listas o columnas numeradas? | Tabla nueva, una fila por valor | `telefono_estudiante` |
| 2FN | ¿Alguna columna depende de solo una parte de la clave? | Tabla nueva con esa parte como PK | `estudiante`, `asignatura` |
| 3FN | ¿Alguna columna no clave determina a otra? | Tabla nueva con esa columna como PK | `docente` |
| BCNF | ¿Hay un determinante que no es clave candidata? | Tabla nueva con ese determinante como PK | `docente_apoyo` |

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño conceptual | Diagrama E-R | Módulos 1 y 2 ✅ |
| Diseño lógico | Pasaje a tablas | Módulos 1 y 2 ✅ |
| Revisión del diseño | Normalización hasta 3FN | Módulo 3 ✅ |
| Implementación | Crear la base en MySQL | Módulos 4 a 6 |
| Consulta | Preguntarle cosas a la base | Módulos 7 y 8 |

La planilla de una tabla terminó en cinco:

```text
docente(id_docente PK, nombre, apellido)
estudiante(id_estudiante PK, nombre, apellido, grupo)
telefono_estudiante(id_estudiante PK/FK → estudiante, telefono PK)
asignatura(id_asignatura PK, nombre, id_docente FK → docente)
inscripcion(id_estudiante PK/FK → estudiante, id_asignatura PK/FK → asignatura, nota)
```

De esta manera, hemos llegado por otro camino al mismo diseño del Módulo 1, y ahora sabemos **por qué** es correcto. Con esto termina la parte de diseño: en el próximo módulo instalamos MySQL y empezamos a construir estas tablas de verdad.

---

## 📋 Palabras clave

`normalización` · `redundancia` · `anomalía` · `dependencia funcional` · `dependencia parcial` · `dependencia transitiva` · `1FN` · `2FN` · `3FN` · `BCNF` · `clave candidata` · `determinante` · `desnormalización`

---

🧠 **[Autoevaluación — Módulo 3](auto-modulo3)**

---

← [Solución: Normalización](Solucion-Normalizacion) · [🏠 Inicio](Home) · [Instalación de MySQL y Workbench →](Instalacion-de-MySQL-y-Workbench)
