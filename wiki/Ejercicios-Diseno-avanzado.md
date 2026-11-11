## Ejercicios: Diseño avanzado

En estos ejercicios vas a practicar las piezas nuevas del módulo: atributos compuestos, multivaluados y derivados, entidades débiles, relaciones reflexivas y generalización. Necesitás lápiz y papel, o [draw.io](https://app.diagrams.net/) si preferís dibujar en la computadora.

**Datos de partida:** cada ejercicio trae su propio enunciado. Para que practiques sin copiar el ejemplo de clase, ninguno usa el liceo.

En todos, hacé dos cosas:

1. El **diagrama E-R**, marcando qué pieza especial aparece.
2. El **esquema relacional** (las tablas con sus PK y FK), aplicando las reglas de [Pasaje a tablas: casos especiales](Pasaje-a-tablas-casos-especiales).

---

### Ejercicio 1 ★

Un club deportivo quiere modernizar su registro de socios. De cada socio se guarda su número de socio (único), su nombre y su fecha de nacimiento. El sistema tiene que mostrar la edad actual del socio, pero ese dato debe calcularse automáticamente para que no quede viejo. Los socios practican deportes, identificados por un código y un nombre. Un socio puede practicar varios deportes y un deporte es practicado por varios socios.

¿Qué tipo de atributo es la edad? ¿Aparece en alguna tabla?

---

### Ejercicio 2 ★

En una empresa se necesita modelar al personal. De cada empleado se guarda un identificador único, el nombre y el departamento en el que trabaja. Un empleado puede ser jefe de otros empleados, y cada empleado responde a un único jefe, que también es un empleado. El gerente general no tiene jefe.

Modelá la jerarquía sin crear una entidad nueva para los jefes.

---

### Ejercicio 3 ★★

Un banco gestiona cuentas bancarias. Cada cuenta tiene un número de cuenta, único en todo el banco, y un saldo. En cada cuenta se registran transacciones (depósitos, retiros, transferencias). De cada transacción se guarda un número de secuencia (1, 2, 3... que vuelve a empezar para cada cuenta), la fecha y el monto. Una transacción no tiene sentido si no se sabe de qué cuenta es.

¿Cuál es la entidad débil? ¿De qué tipo es su dependencia? ¿Cuál es su clave primaria al pasar a tablas?

---

### Ejercicio 4 ★★

Una asociación civil quiere registrar a sus trabajadores. De todos se guarda la cédula, el nombre y la fecha de ingreso. Hay dos tipos de trabajadores: los **asalariados**, de los que interesa el cargo y el sueldo, y los **voluntarios**, de los que interesa la profesión y las horas semanales que dedican. Todo trabajador es de uno de los dos tipos y nadie puede ser de ambos. De cada trabajador se pueden guardar varios teléfonos de contacto.

Indicá el tipo de especialización (exclusiva o solapada, total o parcial) y elegí una estrategia de pasaje a tablas, justificando por qué.

---

### Ejercicio 5 ★★★

Una empresa de alquiler de automóviles quiere guardar sus reservas:

- De cada cliente se guarda un código único, la cédula, el nombre, la dirección (calle, número y ciudad) y el teléfono.
- Cada cliente puede ser **avalado** por otro cliente de la empresa. Un cliente puede avalar a varios.
- Un cliente puede tener varias reservas; cada reserva es de un único cliente y se realiza en una agencia.
- De cada reserva se guarda la fecha de inicio, la fecha de fin y el precio total, que es la suma del precio de alquiler de cada coche incluido.
- Una reserva puede incluir varios coches, y un coche participa en distintas reservas a lo largo del tiempo. Por cada coche de una reserva se anota el precio de alquiler y los litros de nafta en el tanque al entregarlo.
- De cada coche se guarda la matrícula, la marca, el modelo y el color. Todo coche tiene asignado un garaje, que no cambia.

Identificá todas las piezas especiales que aparezcan (hay por lo menos tres) y escribí el esquema relacional completo.

<details>
<summary><strong>Pista</strong></summary>

Buscá: un atributo que tiene partes, un dato que se puede calcular, y una relación en la que las dos puntas son el mismo tipo de cosa.

</details>

---

👉 Cuando termines, compará con la [Solución: Diseño avanzado](Solucion-Diseno-avanzado).

---

🧠 **[Autoevaluación — Módulo 2](auto-modulo2)**

---

← [Pasaje a tablas: casos especiales](Pasaje-a-tablas-casos-especiales) · [🏠 Inicio](Home) · [Solución: Diseño avanzado →](Solucion-Diseno-avanzado)
