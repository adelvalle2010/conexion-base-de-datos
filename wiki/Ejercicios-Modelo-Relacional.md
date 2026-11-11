## Ejercicios: Modelo Relacional

Estos ejercicios practican el paso del diagrama E-R a las tablas. Escribí tus esquemas con la notación que viste en [Modelo Relacional](Modelo-Relacional), por ejemplo `tabla(columna PK, otra, id_otra FK → otra_tabla)`.

**Datos de partida:** cada ejercicio trae su propio enunciado. Como en los ejercicios de E-R, ninguno usa el liceo.

---

### Ejercicio 1 ★

Pasá a tablas este diagrama de una biblioteca:

- Entidad LIBRO: `id_libro` (identificador), `titulo`, `autor`.
- Entidad SOCIO: `id_socio` (identificador), `nombre`, `apellido`.
- Relación N:M "es prestado a", con los atributos `fecha_prestamo` y `fecha_devolucion`.

Escribí el esquema relacional completo, marcando claves primarias y foráneas.

<details>
<summary>💡 Pista</summary>

Un socio puede pedir el mismo libro en fechas distintas. Pensá si una clave compuesta por (libro, socio) alcanza para identificar cada préstamo.

</details>

---

### Ejercicio 2 ★

Un taller de bicicletas guarda estas tablas, que todavía no tienen las claves marcadas:

```text
cliente(id_cliente, nombre, telefono)
bicicleta(id_bicicleta, marca, modelo, id_cliente)
reparacion(id_reparacion, descripcion, fecha, id_bicicleta)
```

**a)** Marcá la clave primaria de cada tabla.

**b)** Marcá las claves foráneas e indicá a qué tabla apunta cada una.

**c)** Decí qué cardinalidad tienen las relaciones cliente–bicicleta y bicicleta–reparación.

---

### Ejercicio 3 ★★

Un club deportivo tiene socios y actividades, con una relación N:M. Los datos son:

- SOCIO: `id_socio` (identificador), `nombre`, `apellido`.
- ACTIVIDAD: `id_actividad` (identificador), `nombre`, `horario`.
- Atributo de la relación: `fecha_alta` (cuándo se anotó el socio en la actividad).

Escribí el esquema relacional resolviendo la relación N:M con una tabla intermedia. Decidí cuál es su clave primaria y justificá tu elección.

<details>
<summary>💡 Pista</summary>

La tabla intermedia lleva dos FK. Preguntate si un mismo socio podría estar dado de alta dos veces en la misma actividad.

</details>

---

### Ejercicio 4 ★★

Una papelería guarda todas sus compras en una única tabla:

| id_compra | producto | proveedor      | telefono_proveedor |
| --------- | -------- | -------------- | ------------------ |
| 1         | Cuaderno | Papelería Sur  | 2111 1111          |
| 2         | Lápiz    | Papelería Sur  | 2111 1111          |
| 3         | Regla    | Papelería Sur  | 2111 1111          |
| 4         | Mochila  | Bolsos Uy      | 2222 2222          |

**a)** Detección: ¿qué datos se repiten sin necesidad?

**b)** Predicción: si Papelería Sur cambia su teléfono, ¿en cuántos lugares hay que modificarlo? ¿Qué pasaría si te olvidás de uno?

**c)** Separá la tabla en dos, con sus claves primarias y foráneas.

<details>
<summary>💡 Pista</summary>

El proveedor es una "cosa" distinta de la compra: merece su propia tabla.

</details>

---

### Ejercicio 5 ★★★

Un festival de música tiene artistas y escenarios. De cada artista se guarda el nombre artístico y el género; de cada escenario, el nombre y la capacidad. Un artista puede presentarse en varios escenarios y un escenario recibe a varios artistas. Cada presentación tiene una fecha y hora. **Un mismo artista puede presentarse más de una vez en el mismo escenario, en horarios distintos.**

Escribí el esquema relacional completo. Prestá especial atención a la clave primaria de la tabla intermedia.

<details>
<summary>💡 Pista</summary>

Si la clave primaria fuera solo (artista, escenario), ¿se podría guardar la segunda presentación del mismo artista en el mismo escenario?

</details>

---

👉 Cuando termines, compará con la [Solución: Modelo Relacional](Solucion-Modelo-Relacional).

---

← [Modelo Relacional](Modelo-Relacional) · [🏠 Inicio](Home) · [Solución: Modelo Relacional →](Solucion-Modelo-Relacional)
