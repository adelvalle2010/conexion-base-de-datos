## Solución: Modelo Relacional

> ⚠️ Intentá resolver los ejercicios antes de mirar esta página.

---

### Ejercicio 1

```text
libro(id_libro PK, titulo, autor)
socio(id_socio PK, nombre, apellido)
prestamo(id_prestamo PK, id_libro FK → libro, id_socio FK → socio, fecha_prestamo, fecha_devolucion)
```

**Explicación:** cada entidad pasa a ser una tabla. La relación N:M se resuelve con una tabla intermedia, `prestamo`, que lleva una FK hacia cada tabla y las dos fechas, que son atributos de la relación.

**Error común:** usar como clave primaria la pareja (`id_libro`, `id_socio`), como en una inscripción. Eso impediría que un socio pida el mismo libro dos veces, algo totalmente normal en una biblioteca. Por eso se agrega `id_prestamo`, una clave propia para cada préstamo. (Otra alternativa válida es incluir `fecha_prestamo` en la clave compuesta, pero una clave propia es más clara.)

---

### Ejercicio 2

**a)** Claves primarias:

```text
cliente(id_cliente PK, nombre, telefono)
bicicleta(id_bicicleta PK, marca, modelo, id_cliente)
reparacion(id_reparacion PK, descripcion, fecha, id_bicicleta)
```

**b)** Claves foráneas:

```text
bicicleta.id_cliente    FK → cliente
reparacion.id_bicicleta FK → bicicleta
```

**c)** Cliente–bicicleta es **1:N**: un cliente puede tener muchas bicicletas y cada bicicleta es de un cliente. Bicicleta–reparación también es **1:N**.

**Explicación:** la FK siempre está del lado "muchos": cada bicicleta guarda a su dueño, y cada reparación guarda su bicicleta.

**Error común:** marcar `nombre` como clave primaria (puede haber dos clientes con el mismo nombre) o poner la FK en el lado equivocado (por ejemplo `id_bicicleta` dentro de `cliente`, que obligaría a que cada cliente tenga una sola bicicleta).

---

### Ejercicio 3

```text
socio(id_socio PK, nombre, apellido)
actividad(id_actividad PK, nombre, horario)
alta_actividad(id_socio PK/FK → socio, id_actividad PK/FK → actividad, fecha_alta)
```

**Explicación:** la relación N:M se resuelve con la tabla intermedia `alta_actividad`. Su clave primaria es compuesta por las dos FK: no tiene sentido que un mismo socio esté dado de alta dos veces en la misma actividad. La `fecha_alta` es un atributo de la relación, por eso vive en la tabla intermedia.

**Error común:** poner `fecha_alta` en la tabla `socio`. Solo podría guardarse una fecha por socio, aunque esté anotado en varias actividades.

---

### Ejercicio 4

**a)** Se repiten el nombre del proveedor y su teléfono en cada compra de Papelería Sur.

**b)** Hay que modificar el teléfono en **3 filas**. Si te olvidás de una, la base queda con dos teléfonos distintos para el mismo proveedor y no sabés cuál es el correcto: es una **inconsistencia**.

**c)** Esquema separado:

```text
proveedor(id_proveedor PK, nombre, telefono)
compra(id_compra PK, producto, id_proveedor FK → proveedor)
```

**Explicación:** ahora el teléfono de cada proveedor se guarda una sola vez. Si cambia, se corrige en un único lugar y todas las compras quedan al día, porque apuntan al proveedor mediante la FK.

**Error común:** separar las tablas pero seguir copiando el nombre del proveedor dentro de `compra`. La FK debe reemplazar los datos repetidos, no sumarse a ellos.

---

### Ejercicio 5

```text
artista(id_artista PK, nombre_artistico, genero)
escenario(id_escenario PK, nombre, capacidad)
presentacion(id_presentacion PK, id_artista FK → artista, id_escenario FK → escenario, fecha_hora)
```

**Explicación:** como un artista puede presentarse varias veces en el mismo escenario, la pareja (`id_artista`, `id_escenario`) **no** identifica una presentación: se repetiría. Por eso `presentacion` tiene su propia clave, `id_presentacion`. La `fecha_hora` es un atributo de la relación.

**Error común:** copiar el patrón de la inscripción del liceo (clave compuesta por las dos FK) sin revisar si en este problema la pareja puede repetirse. Antes de elegir la clave primaria, hay que preguntarse siempre: "¿puede repetirse esta combinación?".

**Alternativa:** otra solución válida es una clave compuesta por las tres columnas (`id_artista`, `id_escenario`, `fecha_hora`). Se muestra la anterior por ser la más simple de usar.

---

← [Ejercicios: Modelo Relacional](Ejercicios-Modelo-Relacional) · [🏠 Inicio](Home) · [Tipos de Datos en MySQL →](Tipos-de-datos-en-MySQL)
