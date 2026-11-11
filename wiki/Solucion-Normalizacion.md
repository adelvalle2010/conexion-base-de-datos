## Solución: Normalización

> ⚠️ Intentá resolver los ejercicios antes de mirar esta página.

---

### Ejercicio 1

```text
codigo → nombre, telefonos
```

No cumple **1FN**: `telefonos` guarda una lista.

```text
empleado(codigo PK, nombre)
empleado_telefono(codigo_empleado PK/FK → empleado, telefono PK)
```

**Explicación:** una fila por teléfono. La clave primaria de la tabla nueva es la pareja, para que el mismo número no se repita en el mismo empleado.

**Error común:** crear `telefono1` y `telefono2`. Sigue sin estar en 1FN: es un grupo repetitivo.

---

### Ejercicio 2

```text
id_socio                 → nombre_socio
id_actividad             → nombre_actividad, horario
(id_socio, id_actividad) → fecha_alta
```

Está en 1FN. No cumple **2FN**: `nombre_socio`, `nombre_actividad` y `horario` dependen de una parte de la clave.

```text
socio(id_socio PK, nombre)
actividad(id_actividad PK, nombre, horario)
socio_actividad(id_socio PK/FK → socio, id_actividad PK/FK → actividad, fecha_alta)
```

**Explicación:** solo `fecha_alta` necesita la clave completa, porque es de ese socio en esa actividad.

**Error común:** llevar `horario` a la tabla intermedia. El horario es de la actividad, igual para todos los socios.

---

### Ejercicio 3

```text
codigo     → direccion, cod_postal
cod_postal → ciudad
```

Está en 2FN (clave simple). No cumple **3FN**: `codigo → cod_postal → ciudad` es transitiva.

```text
localidad(cod_postal PK, ciudad)
oficina(codigo PK, direccion, cod_postal FK → localidad)
```

**Explicación:** "Montevideo" estaba escrito dos veces para el mismo código postal. Ahora está una vez en `localidad`.

**Error común:** separar también `direccion`. La dirección depende directamente de la oficina: no hay nada que corregir ahí.

---

### Ejercicio 4

```text
id_prestamo  → fecha, id_socio, id_libro
id_socio     → nombre_socio, telefonos_socio
id_libro     → titulo, id_editorial
id_editorial → nombre_editorial
```

- No cumple **1FN**: `telefonos_socio` es una lista.
- La clave es simple, así que una vez en 1FN está en 2FN.
- No cumple **3FN**: hay tres cadenas transitivas (por socio, por libro y por editorial).

```text
socio(id_socio PK, nombre)
telefono_socio(id_socio PK/FK → socio, telefono PK)
editorial(id_editorial PK, nombre)
libro(id_libro PK, titulo, id_editorial FK → editorial)
prestamo(id_prestamo PK, fecha, id_socio FK → socio, id_libro FK → libro)
```

**Explicación:** `prestamo` quedó con lo que es propio del préstamo (la fecha) y dos FK. La editorial se separa de `libro` por la cadena `id_libro → id_editorial → nombre_editorial`.

**Error común:** dejar `id_editorial` en `prestamo`. La editorial es del libro, no del préstamo.

---

### Ejercicio 5

```text
nro_factura                → fecha, id_cliente
id_cliente                 → nombre_cliente, ciudad_cliente
id_producto                → nombre_producto, precio_unitario
(nro_factura, id_producto) → cantidad
```

- Está en 1FN.
- No cumple **2FN**: `fecha` e `id_cliente` dependen solo de `nro_factura`; `nombre_producto` y `precio_unitario`, solo de `id_producto`.
- Al separar la factura aparece una transitiva: `nro_factura → id_cliente → nombre_cliente, ciudad_cliente` (**3FN**).

```text
cliente(id_cliente PK, nombre, ciudad)
producto(id_producto PK, nombre, precio_unitario)
factura(nro_factura PK, fecha, id_cliente FK → cliente)
factura_detalle(nro_factura PK/FK → factura, id_producto PK/FK → producto, cantidad)
```

Anomalías de la tabla original:

- **Inserción:** no se puede cargar un producto nuevo hasta que alguien lo compre, porque falta `nro_factura`.
- **Modificación:** si Ferretería Sur se muda, hay que cambiar la ciudad en todas las filas de todas sus facturas.
- **Borrado:** si se anula la factura 1002, se pierden los datos de Barraca Este.

**Explicación:** es la misma estructura que el liceo: dos tablas "de cosas", una intermedia con lo que pertenece a la pareja y una tabla más que sale de la dependencia transitiva.

> 📌 **Nota:** en un sistema real, `factura_detalle` suele guardar también el precio **cobrado**. No es redundancia: el precio del producto puede cambiar mañana, y la factura tiene que conservar el de ese día. Son dos datos distintos.

---

🧠 **[Autoevaluación — Módulo 3](auto-modulo3)**

---

← [Ejercicios: Normalización](Ejercicios-Normalizacion) · [🏠 Inicio](Home) · [Resumen del Módulo 3 →](Resumen-Modulo3)
