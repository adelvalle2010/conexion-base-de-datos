## ¿Qué es la forma normal de Boyce-Codd?

El liceo organiza clases de apoyo y las anota en una tabla. La tabla está en 3FN, pero tiene un dato repetido. ¿Cómo puede ser? La **forma normal de Boyce-Codd (BCNF)** es una versión más estricta de la 3FN: exige que **todo determinante sea una clave candidata**. Cubre un caso poco frecuente que la 3FN deja pasar: tablas con varias claves candidatas compuestas que comparten columnas.

**Características principales:**

- Toda tabla en BCNF está en 3FN, pero no al revés.
- Si la tabla tiene una sola clave candidata, 3FN y BCNF son lo mismo.
- Se revisa mirando los **determinantes**: el lado izquierdo de cada dependencia funcional.
- En la práctica aparece poco, pero es pregunta habitual de examen.

## El caso: las clases de apoyo

Reglas del liceo:

1. Cada docente da apoyo en **una sola** asignatura.
2. Una asignatura puede tener **varios** docentes de apoyo.
3. Un estudiante, para cada asignatura, tiene **un solo** docente de apoyo.

**Tabla `apoyo`**

| id_estudiante | id_asignatura | id_docente |
| ------------- | ------------- | ---------- |
| 1 (Lucía) | 10 (Matemática) | 1 (Ana) |
| 2 (Mateo) | 10 (Matemática) | 4 (Diego) |
| 3 (Valentina) | 10 (Matemática) | 1 (Ana) |
| 1 (Lucía) | 11 (Física) | 2 (Carlos) |

## Paso 1 — Dependencias y claves candidatas

```text
(id_estudiante, id_asignatura) → id_docente      regla 3
id_docente                     → id_asignatura   regla 1
```

Claves candidatas (conjuntos que identifican a cada fila):

- (`id_estudiante`, `id_asignatura`)
- (`id_estudiante`, `id_docente`), porque sabiendo el docente ya se sabe la asignatura.

## Paso 2 — ¿3FN? Sí. ¿BCNF? No

**¿Qué hace exactamente?**

- Las tres columnas forman parte de alguna clave candidata: no hay columnas "no clave", así que no puede haber dependencias parciales ni transitivas de las que revisan la 2FN y la 3FN. La tabla **está en 3FN**.
- Pero `id_docente` es un determinante (`id_docente → id_asignatura`) y **no** es una clave candidata por sí solo. La tabla **no está en BCNF**.
- La consecuencia se ve en los datos: "Ana da apoyo en Matemática" está escrito dos veces.

## Paso 3 — Descomponer

El determinante que no es clave se lleva lo que determina a una tabla propia.

**Tabla `docente_apoyo`**

| id_docente | id_asignatura |
| ---------- | ------------- |
| 1 (Ana) | 10 (Matemática) |
| 2 (Carlos) | 11 (Física) |
| 4 (Diego) | 10 (Matemática) |

**Tabla `apoyo`**

| id_estudiante | id_docente |
| ------------- | ---------- |
| 1 | 1 |
| 2 | 4 |
| 3 | 1 |
| 1 | 2 |

```text
docente_apoyo(id_docente PK/FK → docente, id_asignatura FK → asignatura)
apoyo(id_estudiante PK/FK → estudiante, id_docente PK/FK → docente_apoyo)
```

> ⚠️ **Lo que se pierde:** con estas tablas, la regla 3 ("un solo docente de apoyo por asignatura") ya no la garantiza ninguna clave. Nada impide cargar a Lucía con Ana y también con Diego, los dos de Matemática. Habría que controlarlo de otra forma, por ejemplo con un [trigger](Triggers). Por eso a veces se decide quedarse en 3FN.

## ¿Hasta dónde normalizar?

| Nivel | Qué elimina | ¿Cuándo se aplica? |
| ----- | ----------- | ------------------ |
| 1FN | Listas y grupos repetidos | Siempre |
| 2FN | Dependencias parciales | Siempre |
| 3FN | Dependencias transitivas | Siempre: es el estándar |
| BCNF | Determinantes que no son clave candidata | Cuando aparece el caso y no se pierde una regla importante |
| 4FN, 5FN | Dependencias multivaluadas y de unión | Casos muy puntuales; quedan fuera de este curso |

A veces se hace lo contrario: **desnormalizar**, es decir, repetir un dato a propósito para que ciertas consultas sean más rápidas (por ejemplo en reportes). Es una decisión que se toma **después** de tener un diseño normalizado y sabiendo qué se sacrifica.

## Diferencia clave: 3FN vs BCNF

| Aspecto | 3FN | BCNF |
| ------- | --- | ---- |
| Regla | Ninguna columna no clave depende de otra no clave | Todo determinante es clave candidata |
| Mira | Las columnas que no son clave | Todas las dependencias |
| Con una sola clave candidata | Equivalentes | Equivalentes |
| Caso que las distingue | Lo deja pasar | Lo detecta: claves candidatas compuestas que comparten columnas |
| ¿Conserva siempre todas las reglas? | Sí | No siempre |

---

## ✍️ Ejercicios

Resolvé cada uno antes de mirar la solución.

**1.** `asignatura(id_asignatura PK, nombre, id_docente)` tiene una sola clave candidata. ¿Está en BCNF?

<details>
<summary>Ver solución</summary>

Sí. El único determinante es `id_asignatura`, que es la clave.

💡 Con una sola clave candidata, estar en 3FN alcanza para estar en BCNF.
</details>

**2.** En una academia: `curso(id_alumno, idioma, id_profesor)`. Cada profesor enseña un solo idioma; un alumno tiene un solo profesor por idioma. Indicá por qué no está en BCNF y descomponela.

<details>
<summary>Ver solución</summary>

`id_profesor → idioma`, y `id_profesor` no es clave candidata.

```text
profesor_idioma(id_profesor PK, idioma)
curso(id_alumno PK, id_profesor PK/FK → profesor_idioma)
```

💡 Es el mismo patrón que las clases de apoyo: tres columnas, dos claves candidatas que comparten una.
</details>

---

## 📋 Palabras clave

`forma normal de Boyce-Codd` · `BCNF` · `determinante` · `clave candidata` · `clave candidata compuesta` · `atributo primo` · `3FN` · `descomposición` · `pérdida de dependencias` · `desnormalización` · `4FN` · `clases de apoyo`

---

🧠 **[Autoevaluación — Módulo 3](auto-modulo3)**

---

← [Tercera forma normal (3FN)](Tercera-forma-normal) · [🏠 Inicio](Home) · [Ejercicios: Normalización →](Ejercicios-Normalizacion)
