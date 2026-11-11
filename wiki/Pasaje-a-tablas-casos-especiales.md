## ¿Cómo se pasan a tablas los casos especiales?

En [Modelo Relacional](Modelo-Relacional) aprendiste las reglas básicas: cada entidad es una tabla, la relación 1:N se resuelve con una FK del lado "muchos" y la N:M con una tabla intermedia. Ahora el diagrama del liceo tiene piezas nuevas: teléfonos, direcciones, edades, evaluaciones, coordinadores, previaturas. El **pasaje a tablas** de estos casos sigue reglas igual de fijas; solo hay que saber cuál aplicar.

**Características principales:**

- Cada símbolo del diagrama tiene **una regla** de traducción.
- El resultado son siempre tablas, claves primarias (PK) y claves foráneas (FK): no aparece nada nuevo.
- Las reglas se aplican en orden: primero entidades fuertes, después débiles, después relaciones.
- La generalización es el único caso con **varias opciones** válidas.

## Tabla de reglas

| En el diagrama | Regla | Ejemplo en el liceo |
| -------------- | ----- | ------------------- |
| Atributo compuesto | Una columna por cada parte; el "padre" desaparece | `calle`, `numero`, `ciudad` |
| Atributo multivaluado | Tabla nueva con FK a la entidad | `telefono_estudiante` |
| Atributo derivado | No se guarda | `edad` no es columna |
| Entidad débil (existencia) | Tabla con su PK + FK a la fuerte | `carne` |
| Entidad débil (identificación) | PK compuesta: FK a la fuerte + clave parcial | `evaluacion` |
| Reflexiva 1:1 o 1:N | FK que apunta a la **misma** tabla | `id_coordinador` en `docente` |
| Reflexiva N:M | Tabla intermedia con dos FK a la misma tabla | `previatura` |
| Generalización | Tres estrategias (ver más abajo) | `persona` / `estudiante` / `docente` |

## Paso 1 — Atributos

```text
estudiante(id_estudiante PK, nombre, apellido, fecha_nacimiento, grupo, calle, numero, ciudad)
telefono_estudiante(id_estudiante PK/FK → estudiante, telefono PK)
```

**Tabla `telefono_estudiante`**

| id_estudiante | telefono |
| ------------- | -------- |
| 1 | 099 111 222 |
| 1 | 098 333 444 |
| 1 | 2222 5555 |
| 2 | 091 555 666 |

**¿Qué hace exactamente?**

- **Compuesto**: `direccion` no existe como columna; existen sus partes.
- **Multivaluado**: una fila por cada teléfono. La PK es la pareja (`id_estudiante`, `telefono`), así el mismo número no se carga dos veces para la misma persona.
- **Derivado**: `edad` no aparece. Se calcula al consultar.

## Paso 2 — Entidades débiles

```text
carne(nro_carne PK, fecha_emision, id_estudiante FK → estudiante)
evaluacion(id_asignatura PK/FK → asignatura, nro_evaluacion PK, fecha, tema)
```

**Elementos clave:**

- En `carne`, la FK es una columna más. Como la relación es 1:1, esa FK no se puede repetir: se declara **única** (lo verás como `UNIQUE` en [Restricciones: NOT NULL, UNIQUE, DEFAULT y CHECK](Restricciones)).
- En `evaluacion`, la FK `id_asignatura` **forma parte de la PK**. "Evaluación 1" se repite; (10, 1) no.
- En los dos casos la FK es obligatoria: una entidad débil nunca queda sin su fuerte.

## Paso 3 — Relaciones reflexivas

```text
docente(id_docente PK, nombre, apellido, id_coordinador* FK → docente)
previatura(id_asignatura PK/FK → asignatura, id_previa PK/FK → asignatura)
```

**Tabla `docente`**

| id_docente | nombre | apellido | id_coordinador |
| ---------- | ------ | -------- | -------------- |
| 1 | Ana | Pereira | NULL |
| 2 | Carlos | Méndez | 1 |
| 3 | Laura | Sosa | 1 |
| 4 | Diego | Olivera | NULL |

**¿Qué hace exactamente?**

- `id_coordinador` guarda un `id_docente` de **la misma tabla**. Carlos y Laura apuntan a la fila 1, Ana.
- El asterisco indica que la columna puede quedar vacía (`NULL`): Ana y Diego no tienen coordinador.
- La FK se llama distinto que la PK (`id_coordinador`, no `id_docente`) porque una tabla no puede tener dos columnas con el mismo nombre. El nombre, además, cuenta el rol.
- En `previatura` las dos columnas apuntan a `asignatura`: una es la asignatura que se quiere cursar y la otra, la que hay que tener aprobada.

## Paso 4 — Generalización

Hay tres estrategias. Todas son correctas; cambia qué se gana y qué se pierde.

### 1. Una tabla para el supertipo y una por subtipo

```text
persona(id_persona PK, nombre, apellido, fecha_nacimiento)
estudiante(id_persona PK/FK → persona, grupo)
docente(id_persona PK/FK → persona, fecha_ingreso)
```

### 2. Solo tablas para los subtipos

```text
estudiante(id_estudiante PK, nombre, apellido, fecha_nacimiento, grupo)
docente(id_docente PK, nombre, apellido, fecha_ingreso)
```

### 3. Una sola tabla con una columna "tipo"

```text
persona(id_persona PK, nombre, apellido, fecha_nacimiento, tipo, grupo*, fecha_ingreso*)
```

**¿Cuándo usar cada uno?**

| Estrategia | Sirve para | Ventaja | Costo |
| ---------- | ---------- | ------- | ----- |
| 1. Supertipo + subtipos | Cualquier tipo de especialización | No repite columnas ni deja vacíos | Para ver un estudiante completo hay que unir dos tablas |
| 2. Solo subtipos | **Exclusiva y total** | Tablas simples y completas | Los atributos comunes se definen dos veces |
| 3. Una sola tabla | Subtipos con pocos atributos propios | Una única tabla | Muchas columnas en `NULL`; nada impide cargar `grupo` a un docente |

> 💡 El liceo de esta wiki usa la **estrategia 2**: como la especialización es exclusiva y total, `estudiante` y `docente` quedan como tablas independientes. Por eso no vas a ver una tabla `persona` en los próximos módulos.

## El esquema del liceo, ampliado

```text
docente(id_docente PK, nombre, apellido, id_coordinador* FK → docente)
estudiante(id_estudiante PK, nombre, apellido, fecha_nacimiento, grupo, calle, numero, ciudad)
telefono_estudiante(id_estudiante PK/FK → estudiante, telefono PK)
carne(nro_carne PK, fecha_emision, id_estudiante FK → estudiante)
asignatura(id_asignatura PK, nombre, id_docente FK → docente)
previatura(id_asignatura PK/FK → asignatura, id_previa PK/FK → asignatura)
evaluacion(id_asignatura PK/FK → asignatura, nro_evaluacion PK, fecha, tema)
inscripcion(id_estudiante PK/FK → estudiante, id_asignatura PK/FK → asignatura, nota)
```

> 📌 **Nota:** este es el diseño "completo". Para aprender SQL vamos a empezar con las cuatro tablas del [Modelo Relacional](Modelo-Relacional) y a sumar las demás a medida que hagan falta.

## Diferencia clave: FK común vs FK que es parte de la PK

| Aspecto | FK común | FK dentro de la PK |
| ------- | -------- | ------------------ |
| Ejemplo | `id_estudiante` en `carne` | `id_asignatura` en `evaluacion` |
| Viene de | Relación 1:N, 1:1 o débil por existencia | Débil por identificación, multivaluado, N:M |
| ¿Identifica a la fila? | No | Sí, junto con otra columna |
| ¿Puede ser `NULL`? | Solo si la relación es opcional | Nunca |
| ¿Se puede repetir? | Sí (salvo que sea única) | Sí, pero no la combinación completa |

---

## 📋 Palabras clave

`pasaje a tablas` · `clave primaria compuesta` · `clave foránea` · `FK reflexiva` · `tabla intermedia` · `clave parcial` · `NULL` · `UNIQUE` · `supertipo` · `subtipo` · `columna tipo` · `telefono_estudiante` · `previatura` · `esquema relacional`

---

🧠 **[Autoevaluación — Módulo 2](auto-modulo2)**

---

← [Generalización y especialización](Generalizacion-y-especializacion) · [🏠 Inicio](Home) · [Ejercicios: Diseño avanzado →](Ejercicios-Diseno-avanzado)
