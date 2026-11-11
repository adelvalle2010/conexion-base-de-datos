## Resumen

En este módulo hemos visto cómo representar situaciones que el diagrama básico no alcanzaba a mostrar, y cómo llevar cada una a tablas. Los conceptos principales que trabajamos fueron:

- **Atributo compuesto**: tiene partes (dirección = calle, número, ciudad). Cada parte pasa a ser una columna.
- **Atributo multivaluado**: admite varios valores (teléfonos). Pasa a ser una tabla nueva.
- **Atributo derivado**: se calcula a partir de otros datos (edad). No se guarda.
- **Entidad débil**: depende de una entidad fuerte para existir (carné) o para identificarse (evaluación).
- **Relación reflexiva**: une a una entidad consigo misma, con dos roles (coordinador y coordinado).
- **Generalización / especialización**: un supertipo reúne lo común y los subtipos lo particular; puede ser exclusiva o solapada, total o parcial.

## 🧾 Reglas de un vistazo

| En el diagrama | En las tablas | Ejemplo |
| -------------- | ------------- | ------- |
| Atributo compuesto | Una columna por parte | `calle`, `numero`, `ciudad` |
| Atributo multivaluado | Tabla nueva con FK | `telefono_estudiante` |
| Atributo derivado | Nada: se calcula | `edad` |
| Débil por existencia | FK a la fuerte | `carne.id_estudiante` |
| Débil por identificación | FK dentro de la PK compuesta | `evaluacion(id_asignatura, nro_evaluacion)` |
| Reflexiva 1:N | FK a la misma tabla | `docente.id_coordinador` |
| Reflexiva N:M | Tabla intermedia con dos FK a la misma tabla | `previatura` |
| Generalización | Supertipo + subtipos, solo subtipos, o una sola tabla | `estudiante` y `docente` |

## 🎯 Dónde estamos en el proceso

| Etapa | Qué hicimos | Resultado |
| ----- | ----------- | --------- |
| Diseño conceptual | Diagrama E-R con todas sus piezas | Módulos 1 y 2 ✅ |
| Diseño lógico | Pasaje a tablas, PK y FK | Módulos 1 y 2 ✅ |
| Revisión del diseño | Comprobar que las tablas no repitan datos | Módulo 3 |
| Implementación | Crear la base en MySQL | Módulos 4 a 6 |
| Consulta | Preguntarle cosas a la base | Módulos 7 y 8 |

De esta manera, el diseño del liceo creció de cuatro a ocho tablas sin que cambiaran las reglas de fondo: todo se sigue resolviendo con tablas, claves primarias y claves foráneas. Lo que todavía no sabemos es si un diseño está **bien hecho**. Para eso existe un método que revisa las tablas una por una: la normalización, que es el tema del próximo módulo.

---

## 📋 Palabras clave

`atributo compuesto` · `atributo multivaluado` · `atributo derivado` · `entidad débil` · `clave parcial` · `relación reflexiva` · `rol` · `supertipo` · `subtipo` · `exclusiva / solapada` · `total / parcial` · `clave primaria compuesta` · `FK reflexiva`

---

🧠 **[Autoevaluación — Módulo 2](auto-modulo2)**

---

← [Solución: Diseño avanzado](Solucion-Diseno-avanzado) · [🏠 Inicio](Home) · [¿Por qué normalizar? Anomalías y redundancia →](Introduccion-Normalizacion)
