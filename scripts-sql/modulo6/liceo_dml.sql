/********************************/
/* liceo_dml.sql                                                   */
/* Módulo 6 — Manipulación de Datos (DML)                          */
/*   Parte A: estructura final de la base (resultado del Módulo 5) */
/*   Parte B: INSERT — carga de datos                              */
/*   Parte C: UPDATE — correcciones                                */
/*   Parte D: DELETE — bajas                                       */
/* Al terminar, la base queda con los datos que usan los módulos   */
/* de consultas.                                                   */
/********************************/

DROP DATABASE IF EXISTS liceo;
CREATE DATABASE liceo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE liceo;

-- =============================================================
-- PARTE A: la estructura
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
-- PARTE B: INSERT — cargar los datos
-- =============================================================

-- Una fila, indicando todas las columnas
INSERT INTO grupo (nombre, turno)
VALUES ('3ºA', 'matutino');

-- Varias filas en una sola sentencia
INSERT INTO grupo (nombre, turno)
VALUES ('3ºB', 'vespertino'),
       ('2ºA', 'matutino');

-- Sin indicar el turno: se usa el DEFAULT ('matutino')
INSERT INTO grupo (nombre)
VALUES ('2ºB');

INSERT INTO docente (nombre, apellido)
VALUES ('Ana',    'Pereira'),
       ('Carlos', 'Méndez'),
       ('Laura',  'Sosa'),
       ('Diego',  'Olivera'),
       ('Marta',  'Gimenez');          -- error de tipeo a propósito: se corrige con UPDATE

-- Indicando el identificador: las asignaturas del liceo se numeran desde el 10
INSERT INTO asignatura (id_asignatura, nombre, id_docente)
VALUES (10, 'Matemática',   1),
       (11, 'Física',       2),
       (12, 'Historia',     3),
       (13, 'Química',      4),
       (14, 'Programación', 4),
       (15, 'Filosofía',    3),
       (16, 'Taller',       2);        -- asignatura de prueba: se elimina con DELETE

INSERT INTO estudiante (nombre, apellido, fecha_nacimiento, id_grupo)
VALUES ('Lucía',     'Fernández', '2009-03-14', 1),
       ('Mateo',     'Silva',     '2008-11-02', 2),
       ('Valentina', 'Rodríguez', '2009-07-21', 1),
       ('Santiago',  'Pérez',     '2009-01-30', 1),
       ('Camila',    'González',  '2008-09-09', 2),
       ('Joaquín',   'Martínez',  '2010-05-17', 3),
       ('Sofía',     'López',     '2010-02-03', 3),
       ('Benjamín',  'Castro',    '2010-12-25', 3),
       ('Martina',   'Suárez',    '2009-06-06', 2),
       ('Agustín',   'Núñez',     '2008-04-18', 1),   -- grupo equivocado: se corrige con UPDATE
       ('Prueba',    'Prueba',    '2010-01-01', 3);   -- estudiante de prueba: se elimina con DELETE

INSERT INTO inscripcion (id_estudiante, id_asignatura, nota)
VALUES (1, 10,  9.50), (1, 11,  7.00), (1, 14, 11.00),
       (2, 10,  8.00), (2, 13,  5.00),
       (3, 10,  6.50), (3, 12, 10.00),
       (4, 10,  4.00), (4, 11,  6.00), (4, 14, NULL),
       (5, 10, 11.00), (5, 12,  9.00), (5, 13,  8.50),   -- la nota de (5, 10) se corrige con UPDATE
       (6, 10,  7.50), (6, 12, NULL),
       (7, 10, 10.00), (7, 14,  9.00),
       (8, 11,  3.00), (8, 12,  6.00),
       (9, 13,  7.00), (9, 14, NULL),
       (10, 10, NULL),                                   -- inscripción que se da de baja con DELETE
       (11, 10,  1.00), (11, 11,  1.00);                 -- inscripciones del estudiante de prueba

-- =============================================================
-- PARTE C: UPDATE — corregir datos
-- =============================================================

-- Un dato de una fila
UPDATE docente
SET apellido = 'Giménez'
WHERE id_docente = 5;

-- El grupo 2ºB funciona de noche
UPDATE grupo
SET turno = 'nocturno'
WHERE id_grupo = 4;

-- Agustín estaba anotado en el grupo equivocado
UPDATE estudiante
SET id_grupo = 2
WHERE id_estudiante = 10;

-- Se revisó la prueba de Camila en Matemática: la nota sube un punto
UPDATE inscripcion
SET nota = nota + 1
WHERE id_estudiante = 5
  AND id_asignatura = 10;

-- =============================================================
-- PARTE D: DELETE — eliminar filas
-- =============================================================

-- Agustín se da de baja de Matemática
DELETE FROM inscripcion
WHERE id_estudiante = 10
  AND id_asignatura = 10;

-- El estudiante de prueba: sus inscripciones se borran solas (ON DELETE CASCADE)
DELETE FROM estudiante
WHERE id_estudiante = 11;

-- La asignatura de prueba, que ya no tiene inscriptos
DELETE FROM asignatura
WHERE id_asignatura = 16;
/********************************/
