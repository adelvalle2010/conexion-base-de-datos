# 🏁 Resumen final del curso

Con el Proyecto Integrador cerramos el recorrido. Esta página repasa **todo lo que aprendimos**, de principio a fin, y para qué sirve cada cosa.

## El camino que hicimos

Empezamos sin saber qué era una base de datos y terminamos construyendo una que se diseña, se implementa, se consulta y se protege sola.

| Módulo | Tema | Qué aprendimos a hacer |
| ------ | ---- | ---------------------- |
| **1** | Modelo Entidad-Relación | Identificar entidades, atributos y relaciones; dibujar un MER |
| **2** | Modelo relacional | Pasar el MER a tablas; claves primarias y foráneas |
| **3** | Normalización | Evitar datos repetidos; 1FN, 2FN, 3FN (y BCNF) |
| **4** | DDL | `CREATE`, `ALTER`, `DROP`; restricciones (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`) |
| **5** | DML | `INSERT`, `UPDATE`, `DELETE`; cuidar el `WHERE` |
| **6** | Consultas `SELECT` | `WHERE`, `ORDER BY`, `LIMIT`, operadores y patrones |
| **7** | Funciones y agrupación | `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING` |
| **8** | `JOIN` y subconsultas | Combinar tablas; consultas dentro de consultas; vistas |
| **9** | Índices y transacciones | Acelerar búsquedas; `COMMIT` / `ROLLBACK` |
| **10** | Procedimientos y triggers | Guardar lógica en la base; automatizar con disparadores |
| **11** | Usuarios y respaldo | `GRANT` / `REVOKE`; `mysqldump` y restauración |
| **12** | Proyecto Integrador | Juntar todo en la biblioteca del liceo |

## Las tres grandes etapas

Todo proyecto de base de datos pasa por lo mismo, y lo vivimos en el Módulo 12:

```text
    DISEÑO            IMPLEMENTACIÓN           USO
  (pensar)            (construir)          (consultar y proteger)
     │                     │                      │
  MER + pasaje        CREATE TABLE          SELECT / JOIN
  a tablas +          + restricciones       + vistas
  normalización       + INSERT              + procedimientos
                                            + triggers + usuarios
```

> 💡 El orden importa: una base mal diseñada no se arregla con consultas ingeniosas. **Primero se piensa, después se construye.**

## Lo que te llevás

Si entendés estos cinco puntos, entendiste el curso:

1. **Una base guarda datos sin repetirlos**, repartidos en tablas conectadas por claves.
2. **El diseño se piensa antes de escribir SQL**, con un MER y normalizando.
3. **Las restricciones protegen los datos** desde la propia base (`FOREIGN KEY`, `CHECK`, `UNIQUE`).
4. **Las consultas combinan tablas** con `JOIN` y responden preguntas con agrupación y subconsultas.
5. **La base puede automatizarse y protegerse** con vistas, procedimientos, triggers, usuarios y respaldos.

## ¿Y ahora?

Algunas direcciones para seguir, si querés ir más allá del curso:

- Conectar la base a una aplicación (por ejemplo desde Java, PHP o Python).
- Aprender **optimización de consultas** leyendo planes de ejecución (`EXPLAIN`).
- Ver otros motores: PostgreSQL, SQLite, o bases NoSQL como MongoDB.
- Practicar con bases más grandes y datos reales.

Pero lo esencial ya está. **Felicitaciones por llegar hasta acá.** 🎓

---

## 📋 Palabras clave

`diseño` · `implementación` · `consulta` · `MER` · `normalización` · `JOIN` · `vista` · `procedimiento` · `trigger` · `transacción` · `respaldo` · `proyecto integrador`

---

🧠 **[Autoevaluación — Módulo 12](auto-modulo12)**

---

← [Fase 3: Consultas](Proyecto-Fase-3-Consultas) · [🏠 Inicio](Home)
