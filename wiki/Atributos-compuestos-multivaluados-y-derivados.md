## ¿Qué tipos de atributos existen?

En [Entidad-Relación](Entidad-Relacion) todos los atributos eran simples: un estudiante tiene **un** nombre, **un** apellido, **una** fecha de nacimiento. Pero cuando la secretaría del liceo pide guardar la dirección, los teléfonos y la edad de cada estudiante, aparecen tres situaciones nuevas. Un **atributo** puede ser **compuesto** (está formado por otros), **multivaluado** (admite varios valores) o **derivado** (se calcula a partir de otro dato).

**Características principales:**

- Son decisiones de **diseño conceptual**: se toman en el diagrama, antes de pensar en tablas.
- Cada tipo tiene su propio símbolo en el dibujo.
- Cada tipo se traduce de forma distinta al pasar a tablas, como verás en [Pasaje a tablas: casos especiales](Pasaje-a-tablas-casos-especiales).
- Detectarlos a tiempo evita columnas repetidas (`telefono1`, `telefono2`...) y datos que quedan viejos.

## Los tres tipos

| Tipo | Idea | Ejemplo en el liceo | Símbolo (notación de Chen) |
| ---- | ---- | ------------------- | -------------------------- |
| Simple | Un solo valor que no se divide | `nombre` | Óvalo |
| Compuesto | Se divide en partes más chicas | `direccion` = calle + número + ciudad | Óvalo del que salen otros óvalos |
| Multivaluado | Puede tener varios valores a la vez | `telefono` | Óvalo de doble línea |
| Derivado (o calculado) | Se obtiene a partir de otros datos | `edad`, a partir de `fecha_nacimiento` | Óvalo de línea punteada |

### 1. Atributos compuestos

Un **atributo compuesto** está formado por otros atributos. Sirve para organizar: en lugar de un texto largo como "Av. Garzón 1234, Montevideo", separamos las partes.

```text
ESTUDIANTE
 ├─ id_estudiante
 ├─ nombre
 └─ direccion
      ├─ calle
      ├─ numero
      └─ ciudad
```

**¿Cuándo usar?**

- Cuando vas a necesitar las partes por separado: "¿cuántos estudiantes viven en Las Piedras?" solo se puede responder bien si `ciudad` es un dato aparte.
- Si la dirección solo se va a mostrar tal cual, alcanza con un atributo simple.

### 2. Atributos multivaluados

Un **atributo multivaluado** puede tener más de un valor para el mismo ejemplar. Lucía puede tener su celular, el de su madre y el fijo de la casa: son tres teléfonos para una sola estudiante.

| id_estudiante | nombre | telefono |
| ------------- | ------ | -------- |
| 1 | Lucía | 099 111 222, 098 333 444, 2222 5555 |
| 2 | Mateo | 091 555 666 |

**¿Qué hace exactamente?**

- La tabla de arriba muestra el **problema**: tres valores apretados en una celda. No se puede buscar un teléfono ni saber cuántos tiene cada estudiante sin "cortar" el texto.
- En el diagrama alcanza con marcar `telefono` como multivaluado. La solución (una tabla aparte) llega al pasar a tablas.

### 3. Atributos derivados

Un **atributo derivado** se calcula a partir de otros datos. La `edad` sale de `fecha_nacimiento` y de la fecha de hoy; el `promedio` de un estudiante sale de sus notas.

**Elementos clave:**

- Se dibujan para dejar constancia de que el sistema los va a mostrar.
- **No se guardan**: si guardáramos `edad = 16`, el día del cumpleaños el dato quedaría mal sin que nadie lo toque.
- Se calculan en el momento de consultar. Lo vas a hacer con SQL en [Funciones de Agrupación (SUM, COUNT, AVG)](Funciones-de-agrupacion).

## ¿Cómo me doy cuenta de qué tipo es?

Tres preguntas, en este orden:

1. **¿Se puede calcular con datos que ya tengo?** → derivado.
2. **¿Un mismo estudiante puede tener varios?** → multivaluado.
3. **¿Tiene partes que voy a usar por separado?** → compuesto.

Si las tres respuestas son "no", es un atributo simple.

## Diferencia clave: Compuesto vs Multivaluado

| Aspecto | Compuesto | Multivaluado |
| ------- | --------- | ------------ |
| Qué es | Un valor con varias partes | Varios valores del mismo tipo |
| Ejemplo | Una dirección: calle, número, ciudad | Varios teléfonos |
| Cantidad de partes | Fija y conocida | Variable: 0, 1, 2, 5... |
| Las partes son... | Distintas entre sí | Iguales entre sí |
| Al pasar a tablas | Más columnas en la misma tabla | Una tabla nueva |

---

## 📋 Palabras clave

`atributo simple` · `atributo compuesto` · `atributo multivaluado` · `atributo derivado` · `atributo calculado` · `notación de Chen` · `redundancia` · `dato obsoleto` · `dirección` · `teléfono` · `edad` · `diseño conceptual`

---

🧠 **[Autoevaluación — Módulo 2](auto-modulo2)**

---

← [Resumen del Módulo 1](Resumen-Modulo1) · [🏠 Inicio](Home) · [Entidades débiles →](Entidades-debiles)
