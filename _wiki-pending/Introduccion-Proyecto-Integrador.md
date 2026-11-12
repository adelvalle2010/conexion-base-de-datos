> 🗄️ **Base de datos:** `biblioteca_liceo` (Módulo 12 — Proyecto Integrador) — [⬇️ Descargar script SQL](https://github.com/adelvalle2010/conexion-base-de-datos/blob/main/scripts-sql/modulo12/proyecto_integrador.sql)

# 🎓 Módulo 12 — Proyecto Integrador: la biblioteca del liceo

Llegamos al final del curso. Durante los módulos anteriores aprendimos, por separado, a diseñar un modelo, crear tablas, cargar datos, consultarlos, normalizar, crear vistas, índices, transacciones, usuarios, procedimientos y triggers. **Este módulo junta todo en un solo proyecto.**

## El caso

Seguimos con el **liceo** que venimos usando en todo el curso, pero lo ampliamos con algo que todo liceo tiene: **la biblioteca**. Los mismos **estudiantes** que ya estaban en nuestra base ahora también son los **socios** que piden libros prestados.

La biblioteca necesita una base de datos que responda preguntas como:

- ¿Qué libros hay y de qué categoría son?
- ¿Qué ejemplares de un libro están disponibles para prestar?
- ¿Quién tiene un libro y desde cuándo?
- ¿Quién devolvió tarde?
- ¿Cuáles son los libros más pedidos?

Y además que **automatice** el préstamo: que al registrar un préstamo, el ejemplar quede marcado como prestado sin que nadie tenga que acordarse de hacerlo, y que **no deje** prestar un ejemplar que no está disponible.

## Las tres fases

El proyecto se trabaja en tres fases, igual que un proyecto real:

| Fase | Qué hacemos | Módulos que usamos |
| ---- | ----------- | ------------------ |
| **[Fase 1 — Diseño](Proyecto-Fase-1-Diseno)** | Modelo Entidad-Relación (MER) y pasaje a tablas | Módulos 1–3 (ER, relacional, normalización) |
| **[Fase 2 — Implementación](Proyecto-Fase-2-Implementacion)** | Crear la base con `CREATE TABLE`, restricciones y datos | Módulos 4–5 (DDL, DML) |
| **[Fase 3 — Consultas y automatización](Proyecto-Fase-3-Consultas)** | `JOIN`, vistas, procedimientos y triggers | Módulos 8–11 |

## Lo que vamos a construir

Una base llamada `biblioteca_liceo` con **8 tablas**:

- `grupo` y `estudiante` → reutilizadas del liceo (el estudiante es el socio).
- `categoria`, `autor`, `libro`, `libro_autor`, `ejemplar`, `prestamo` → el subsistema de biblioteca.

Más una **vista** (`v_ejemplares_disponibles`), un **procedimiento** (`sp_prestar`) y un **trigger** (`trg_prestamo_after_insert`).

> 💡 **Importante:** no hay un caso nuevo que aprender. Es el mismo liceo de siempre, con una parte nueva. Por eso se llama *integrador*: integra lo conocido con lo nuevo.

---

## Cómo trabajar este módulo

1. Leé primero la **Fase 1** y tratá de dibujar vos el MER antes de ver el nuestro.
2. En la **Fase 2**, descargá el script y cargalo en MySQL Workbench o por consola:
   ```bash
   mysql -u root -p < proyecto_integrador.sql
   ```
3. En la **Fase 3**, ejecutá cada consulta vos mismo y compará con el resultado que mostramos.
4. Al final, resolvé los **ejercicios** y la **autoevaluación**.

El script se puede ejecutar todas las veces que haga falta: empieza con `DROP DATABASE IF EXISTS` y vuelve a crear todo desde cero.

---

Empezamos por el diseño → [Fase 1: Diseño del MER](Proyecto-Fase-1-Diseno)

---

## 📋 Palabras clave

`proyecto integrador` · `biblioteca_liceo` · `socio` · `ejemplar` · `préstamo` · `relación N:M` · `vista` · `procedimiento` · `trigger` · `diseño` · `implementación` · `consulta`

---

🧠 **[Autoevaluación — Módulo 12](auto-modulo12)**

---

[🏠 Inicio](Home) · [Fase 1: Diseño →](Proyecto-Fase-1-Diseno)
