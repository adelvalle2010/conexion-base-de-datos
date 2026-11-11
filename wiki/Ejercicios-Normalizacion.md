## Ejercicios: Normalización

En estos ejercicios vas a practicar el recorrido completo: encontrar las dependencias funcionales, decir en qué forma normal está cada tabla y llevarla hasta 3FN.

**Datos de partida:** cada ejercicio trae su propia tabla. Para que practiques sin copiar el ejemplo de clase, ninguno usa el liceo.

En todos, seguí siempre el mismo orden:

1. Escribí las **dependencias funcionales**.
2. Indicá **qué forma normal no cumple** y por qué.
3. Escribí el **esquema final** con PK y FK.

---

### Ejercicio 1 ★

**Tabla `empleado`** (clave primaria: `codigo`)

| codigo | nombre | telefonos |
| ------ | ------ | --------- |
| 1 | Fernando | 654 654 654, 654 321 432 |
| 2 | Manuel | 926 123 123 |

---

### Ejercicio 2 ★

Un club anota las altas de sus socios en actividades. Clave primaria: (`id_socio`, `id_actividad`).

| id_socio | id_actividad | nombre_socio | nombre_actividad | horario | fecha_alta |
| -------- | ------------ | ------------ | ---------------- | ------- | ---------- |
| 1 | 5 | Paula | Natación | Lunes 18:00 | 2026-03-02 |
| 1 | 7 | Paula | Básquet | Jueves 19:00 | 2026-03-10 |
| 2 | 5 | Bruno | Natación | Lunes 18:00 | 2026-04-01 |

---

### Ejercicio 3 ★★

**Tabla `oficina`** (clave primaria: `codigo`). Cada código postal corresponde a una única ciudad.

| codigo | direccion | ciudad | cod_postal |
| ------ | --------- | ------ | ---------- |
| 1 | Av. Italia 3100 | Montevideo | 11600 |
| 2 | Av. Italia 4500 | Montevideo | 11600 |
| 3 | Sarandí 520 | Maldonado | 20000 |

---

### Ejercicio 4 ★★

Una biblioteca registra cada préstamo (un libro por préstamo). Clave primaria: `id_prestamo`.

| id_prestamo | fecha | id_socio | nombre_socio | telefonos_socio | id_libro | titulo | id_editorial | nombre_editorial |
| - | - | - | - | - | - | - | - | - |
| 1 | 2026-05-04 | 20 | Sofía | 099 000 111, 2900 1234 | 300 | Rayuela | 8 | Sudamericana |
| 2 | 2026-05-04 | 21 | Tomás | 098 222 333 | 301 | Ficciones | 8 | Sudamericana |
| 3 | 2026-05-11 | 20 | Sofía | 099 000 111, 2900 1234 | 301 | Ficciones | 8 | Sudamericana |

---

### Ejercicio 5 ★★★

Un comercio guarda sus facturas en una sola tabla. Clave primaria: (`nro_factura`, `id_producto`).

| nro_factura | fecha | id_cliente | nombre_cliente | ciudad_cliente | id_producto | nombre_producto | precio_unitario | cantidad |
| - | - | - | - | - | - | - | - | - |
| 1001 | 2026-06-01 | 7 | Ferretería Sur | Canelones | 50 | Martillo | 450.00 | 2 |
| 1001 | 2026-06-01 | 7 | Ferretería Sur | Canelones | 51 | Pinza | 380.00 | 1 |
| 1002 | 2026-06-03 | 9 | Barraca Este | Pando | 50 | Martillo | 450.00 | 5 |

Describí además una anomalía de inserción, una de modificación y una de borrado que tenga esta tabla.

<details>
<summary><strong>Pista</strong></summary>

Hay dependencias parciales de las **dos** partes de la clave, y una transitiva escondida dentro de una de ellas.

</details>

---

👉 Cuando termines, compará con la [Solución: Normalización](Solucion-Normalizacion).

---

🧠 **[Autoevaluación — Módulo 3](auto-modulo3)**

---

← [Forma normal de Boyce-Codd (BCNF)](Forma-normal-de-Boyce-Codd) · [🏠 Inicio](Home) · [Solución: Normalización →](Solucion-Normalizacion)
