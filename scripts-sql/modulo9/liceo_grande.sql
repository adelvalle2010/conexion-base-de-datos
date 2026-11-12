/********************************/
/* liceo_grande.sql                                                */
/* La misma estructura de la base liceo, con datos generados:      */
/* 120 grupos, 30 docentes, 12 asignaturas, 100.000 estudiantes    */
/* y 400.000 inscripciones.                                        */
/* Se usa en el Módulo 9 para ver el efecto de los índices.        */
/* Los datos no son al azar: se calculan con fórmulas, así todos   */
/* obtenemos exactamente las mismas filas.                         */
/* Tarda unos segundos. Se puede ejecutar todas las veces que haga */
/* falta: borra la base y la vuelve a crear.                       */
/********************************/

DROP DATABASE IF EXISTS liceo_grande;
CREATE DATABASE liceo_grande CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE liceo_grande;

-- Permite que la "serie" de números de más abajo llegue hasta 100.000
SET SESSION cte_max_recursion_depth = 200000;

-- =============================================================
-- Estructura (igual a la de liceo.sql)
-- =============================================================

CREATE TABLE docente (
    id_docente INT         NOT NULL AUTO_INCREMENT,
    nombre     VARCHAR(50) NOT NULL,
    apellido   VARCHAR(50) NOT NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_docente)
);

CREATE TABLE grupo (
    id_grupo INT         NOT NULL AUTO_INCREMENT,
    nombre   VARCHAR(10) NOT NULL,
    turno    VARCHAR(10) NOT NULL DEFAULT 'matutino',
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT uq_grupo_nombre UNIQUE (nombre),
    CONSTRAINT chk_grupo_turno CHECK (turno IN ('matutino', 'vespertino', 'nocturno'))
);

CREATE TABLE estudiante (
    id_estudiante    INT         NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(50) NOT NULL,
    apellido         VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE        NOT NULL,
    id_grupo         INT         NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT fk_estudiante_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo)
);

CREATE TABLE asignatura (
    id_asignatura INT         NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(60) NOT NULL,
    id_docente    INT         NOT NULL,
    CONSTRAINT pk_asignatura PRIMARY KEY (id_asignatura),
    CONSTRAINT uq_asignatura_nombre UNIQUE (nombre),
    CONSTRAINT fk_asignatura_docente FOREIGN KEY (id_docente)
        REFERENCES docente (id_docente)
);

CREATE TABLE inscripcion (
    id_estudiante INT          NOT NULL,
    id_asignatura INT          NOT NULL,
    nota          DECIMAL(4,2),
    CONSTRAINT pk_inscripcion PRIMARY KEY (id_estudiante, id_asignatura),
    CONSTRAINT chk_inscripcion_nota CHECK (nota BETWEEN 1 AND 12),
    CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES estudiante (id_estudiante)
        ON DELETE CASCADE,
    CONSTRAINT fk_inscripcion_asignatura FOREIGN KEY (id_asignatura)
        REFERENCES asignatura (id_asignatura)
);

-- =============================================================
-- Datos generados
-- =============================================================

-- 120 grupos: 1ºA ... 6ºT
INSERT INTO grupo (id_grupo, nombre, turno)
WITH RECURSIVE serie (n) AS (
    SELECT 0
    UNION ALL
    SELECT n + 1 FROM serie WHERE n < 119
)
SELECT n + 1,
       CONCAT(n DIV 20 + 1, 'º', CHAR(65 + n MOD 20 USING utf8mb4)),
       ELT(n MOD 3 + 1, 'matutino', 'vespertino', 'nocturno')
FROM serie;

-- 30 docentes
INSERT INTO docente (id_docente, nombre, apellido)
WITH RECURSIVE serie (n) AS (
    SELECT 0
    UNION ALL
    SELECT n + 1 FROM serie WHERE n < 29
)
SELECT n + 1,
       ELT(n MOD 10 + 1, 'Ana', 'Carlos', 'Laura', 'Diego', 'Marta',
                         'Pablo', 'Rosa', 'Jorge', 'Elena', 'Raúl'),
       ELT(n MOD 6 + 1, 'Pereira', 'Méndez', 'Sosa', 'Olivera', 'Giménez', 'Acosta')
FROM serie;

-- 12 asignaturas
INSERT INTO asignatura (id_asignatura, nombre, id_docente)
VALUES (1,  'Matemática',   1),  (2,  'Física',      2),
       (3,  'Historia',     3),  (4,  'Química',     4),
       (5,  'Programación', 5),  (6,  'Filosofía',   6),
       (7,  'Literatura',   7),  (8,  'Biología',    8),
       (9,  'Geografía',    9),  (10, 'Inglés',      10),
       (11, 'Dibujo',       11), (12, 'Astronomía',  12);

-- 100.000 estudiantes
INSERT INTO estudiante (id_estudiante, nombre, apellido, fecha_nacimiento, id_grupo)
WITH RECURSIVE serie (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM serie WHERE n < 100000
)
SELECT n,
       ELT((n DIV 50 + n) MOD 40 + 1,
           'Lucía', 'Mateo', 'Valentina', 'Santiago', 'Camila', 'Joaquín', 'Sofía', 'Benjamín',
           'Martina', 'Agustín', 'Emma', 'Thiago', 'Isabella', 'Bruno', 'Julieta', 'Felipe',
           'Catalina', 'Facundo', 'Renata', 'Nicolás', 'Florencia', 'Tomás', 'Antonella', 'Lautaro',
           'Victoria', 'Ignacio', 'Micaela', 'Gonzalo', 'Paula', 'Rodrigo', 'Abril', 'Franco',
           'Carolina', 'Emiliano', 'Agustina', 'Maximiliano', 'Rocío', 'Sebastián', 'Belén', 'Federico'),
       ELT(n * 7 MOD 50 + 1,
           'Fernández', 'Silva', 'Rodríguez', 'Pérez', 'González', 'Martínez', 'López', 'Castro',
           'Suárez', 'Núñez', 'García', 'Díaz', 'Álvarez', 'Romero', 'Sánchez', 'Torres',
           'Ramírez', 'Flores', 'Benítez', 'Acosta', 'Medina', 'Herrera', 'Cabrera', 'Vázquez',
           'Rojas', 'Molina', 'Ortiz', 'Luna', 'Ríos', 'Correa', 'Machado', 'Viera',
           'Cardozo', 'Techera', 'Píriz', 'Barrios', 'Ferreira', 'Da Silva', 'De León', 'Olivera',
           'Bentancor', 'Costa', 'Lima', 'Morales', 'Vega', 'Duarte', 'Franco', 'Aguirre',
           'Borges', 'Varela'),
       DATE_ADD('2006-01-01', INTERVAL n * 37 MOD 2190 DAY),
       n * 11 MOD 120 + 1
FROM serie;

-- 400.000 inscripciones: cada estudiante en 4 asignaturas
INSERT INTO inscripcion (id_estudiante, id_asignatura, nota)
SELECT e.id_estudiante,
       (e.id_estudiante + k.k * 3) MOD 12 + 1,
       IF((e.id_estudiante + k.k) MOD 25 = 0,
          NULL,
          (e.id_estudiante * 7 + k.k * 5) MOD 12 + 1)
FROM estudiante AS e
CROSS JOIN (SELECT 0 AS k UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) AS k;

-- Actualiza las estadísticas que usa MySQL para planificar las consultas
ANALYZE TABLE grupo, docente, asignatura, estudiante, inscripcion;
/********************************/
