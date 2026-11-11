> 🗄️ **Base de datos:** `liceo_sin_normalizar` (Módulo 3 — Normalización) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo3/liceo_sin_normalizar.sql)

# ¿Por qué normalizar? Anomalías y redundancia

En este módulo vamos a aprender a **revisar** un diseño: tomar una tabla, detectar qué tiene mal y corregirla paso a paso hasta que cada dato esté guardado una sola vez.

## Introducción

Antes de tener una base de datos, la secretaría del liceo llevaba las notas en una sola planilla: una fila por cada estudiante en cada asignatura, con todos los datos al lado. Funciona, y de hecho se puede cargar tal cual en MySQL. El problema aparece cuando hay que **cambiar** algo.

> **¿Qué es normalizar?** Es aplicar una serie de reglas, llamadas **formas normales**, para repartir los datos en varias tablas de modo que no haya repeticiones innecesarias ni datos que se contradigan.

## Requisitos que vamos a necesitar

1. Saber qué son la clave primaria y la clave foránea: [Modelo Relacional](Modelo-Relacional).
2. Reconocer un atributo multivaluado: [Atributos compuestos, multivaluados y derivados](Atributos-compuestos-multivaluados-y-derivados).
3. Para este módulo **no** hace falta tener MySQL instalado: el script es opcional y lo vas a poder ejecutar después del [Módulo 4](Instalacion-de-MySQL-y-Workbench).

## La planilla del liceo

**Tabla `planilla_notas`**

| id_estudiante | nombre_estudiante | apellido_estudiante | grupo | telefonos | id_asignatura | nombre_asignatura | id_docente | nombre_docente | apellido_docente | nota |
| - | - | - | - | - | - | - | - | - | - | - |
| 1 | Lucía | Fernández | 3ºA | 099 111 222, 098 333 444 | 10 | Matemática | 1 | Ana | Pereira | 9.50 |
| 1 | Lucía | Fernández | 3ºA | 099 111 222, 098 333 444 | 11 | Física | 2 | Carlos | Méndez | 7.00 |
| 2 | Mateo | Silva | 3ºB | 091 555 666 | 10 | Matemática | 1 | Ana | Pereira | 8.00 |
| 3 | Valentina | Rodríguez | 3ºA | NULL | 10 | Matemática | 1 | Ana | Pereira | 6.50 |
| 3 | Valentina | Rodríguez | 3ºA | NULL | 12 | Historia | 3 | Laura | Sosa | 10.00 |

La clave primaria es la pareja (`id_estudiante`, `id_asignatura`): no hay dos filas con el mismo estudiante en la misma asignatura.

Mirá cuántas veces está escrito cada dato:

| Dato | Veces que aparece | Veces que debería |
| ---- | ----------------- | ----------------- |
| "Lucía Fernández, 3ºA" | 2 | 1 |
| "Matemática" | 3 | 1 |
| "Ana Pereira" | 3 | 1 |

Esa repetición se llama **redundancia**. No es solo espacio desperdiciado: es la causa de tres problemas concretos.

## ⚠️ Las tres anomalías

### 1. Anomalía de modificación

Ana Pereira se casa y pasa a firmar como Ana Pereira Díaz. Hay que cambiar **tres** filas. Si alguien corrige solo dos, la base dice dos cosas distintas sobre la misma persona.

```sql
-- ❌ Corrige una sola de las tres filas: el docente 1 queda con dos apellidos
UPDATE planilla_notas
SET apellido_docente = 'Pereira Díaz'
WHERE id_estudiante = 1
  AND id_asignatura = 10;
```

> ⚠️ **Cuidado:** este `UPDATE` se muestra como ejemplo de lo que sale mal. La sentencia la estudiaremos en [UPDATE: Actualizar datos](UPDATE-actualizar-datos).

### 2. Anomalía de inserción

El liceo incorpora la asignatura Química, que dictará Diego Olivera. Todavía no hay inscriptos. ¿Qué fila agregamos? No se puede: la clave primaria necesita un `id_estudiante`, y no existe ninguno.

**¿Qué hace exactamente?** La planilla obliga a tener un estudiante para poder guardar una asignatura. Dos cosas que no tienen nada que ver quedaron atadas.

### 3. Anomalía de borrado

Valentina se cambia de liceo y se borran sus dos filas. Con ellas desaparece el único lugar donde decía que existe Historia y que la dicta Laura Sosa.

**¿Qué hace exactamente?** Borrar un dato (una estudiante) hizo perder otros que nadie quería borrar (una asignatura y una docente).

## Lo que vamos a construir

Partimos de `planilla_notas`. Vamos a:

1. **Descubrir** qué datos dependen de cuáles: [Dependencias funcionales](Dependencias-funcionales).
2. **Separar** los valores múltiples: [Primera forma normal (1FN)](Primera-forma-normal).
3. **Separar** lo que depende de solo una parte de la clave: [Segunda forma normal (2FN)](Segunda-forma-normal).
4. **Separar** lo que depende de otro dato que no es la clave: [Tercera forma normal (3FN)](Tercera-forma-normal).

```text
planilla_notas ──1FN──▶ sin listas ──2FN──▶ sin dependencias parciales ──3FN──▶ sin dependencias transitivas
   1 tabla                2 tablas              4 tablas                          5 tablas
```

Al final vamos a llegar, por otro camino, al mismo esquema que dibujamos en el Módulo 1. No es casualidad: un buen diagrama E-R suele dar tablas ya normalizadas, y la normalización es la forma de **comprobarlo**.

## El script del módulo

El script crea la planilla (parte A) y las tablas normalizadas con los mismos datos (parte B). Esta es la parte A:

```sql
/********************************/
DROP DATABASE IF EXISTS liceo_sin_normalizar;
CREATE DATABASE liceo_sin_normalizar CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE liceo_sin_normalizar;

CREATE TABLE planilla_notas (
    id_estudiante       INT          NOT NULL,
    nombre_estudiante   VARCHAR(50)  NOT NULL,
    apellido_estudiante VARCHAR(50)  NOT NULL,
    grupo               VARCHAR(10)  NOT NULL,
    telefonos           VARCHAR(100),             -- ❌ varios valores en una celda
    id_asignatura       INT          NOT NULL,
    nombre_asignatura   VARCHAR(60)  NOT NULL,
    id_docente          INT          NOT NULL,
    nombre_docente      VARCHAR(50)  NOT NULL,
    apellido_docente    VARCHAR(50)  NOT NULL,
    nota                DECIMAL(4,2),
    CONSTRAINT pk_planilla_notas PRIMARY KEY (id_estudiante, id_asignatura)
);
/********************************/
```

> 📌 **Nota:** si todavía no entendés el script, no importa. Lo vas a poder leer completo después de [CREATE: Crear Bases de Datos y Tablas](CREATE-bases-de-datos-y-tablas).

Continuamos por las dependencias entre los datos → [Dependencias funcionales](Dependencias-funcionales)

---

## 📋 Palabras clave

`normalización` · `forma normal` · `redundancia` · `anomalía de modificación` · `anomalía de inserción` · `anomalía de borrado` · `integridad` · `planilla` · `clave primaria compuesta` · `dato repetido` · `1FN` · `2FN` · `3FN`

---

🧠 **[Autoevaluación — Módulo 3](auto-modulo3)**

---

← [Resumen del Módulo 2](Resumen-Modulo2) · [🏠 Inicio](Home) · [Dependencias funcionales →](Dependencias-funcionales)
