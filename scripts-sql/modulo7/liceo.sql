/********************************/
/* liceo.sql                                                       */
/* Base de datos del liceo, completa: estructura y datos.          */
/* Es el punto de partida de los módulos de consultas (7 y 8).     */
/* Se puede ejecutar todas las veces que haga falta: borra la base */
/* y la vuelve a crear.                                            */
/********************************/

DROP DATABASE IF EXISTS liceo;
CREATE DATABASE liceo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE liceo;

-- =============================================================
-- Estructura
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
-- Datos de prueba
-- =============================================================

INSERT INTO grupo (id_grupo, nombre, turno)
VALUES (1, '3ºA', 'matutino'),
       (2, '3ºB', 'vespertino'),
       (3, '2ºA', 'matutino'),
       (4, '2ºB', 'nocturno');

INSERT INTO docente (id_docente, nombre, apellido)
VALUES (1, 'Ana',    'Pereira'),
       (2, 'Carlos', 'Méndez'),
       (3, 'Laura',  'Sosa'),
       (4, 'Diego',  'Olivera'),
       (5, 'Marta',  'Giménez');

INSERT INTO asignatura (id_asignatura, nombre, id_docente)
VALUES (10, 'Matemática',   1),
       (11, 'Física',       2),
       (12, 'Historia',     3),
       (13, 'Química',      4),
       (14, 'Programación', 4),
       (15, 'Filosofía',    3);

INSERT INTO estudiante (id_estudiante, nombre, apellido, fecha_nacimiento, id_grupo)
VALUES (1,  'Lucía',     'Fernández', '2009-03-14', 1),
       (2,  'Mateo',     'Silva',     '2008-11-02', 2),
       (3,  'Valentina', 'Rodríguez', '2009-07-21', 1),
       (4,  'Santiago',  'Pérez',     '2009-01-30', 1),
       (5,  'Camila',    'González',  '2008-09-09', 2),
       (6,  'Joaquín',   'Martínez',  '2010-05-17', 3),
       (7,  'Sofía',     'López',     '2010-02-03', 3),
       (8,  'Benjamín',  'Castro',    '2010-12-25', 3),
       (9,  'Martina',   'Suárez',    '2009-06-06', 2),
       (10, 'Agustín',   'Núñez',     '2008-04-18', 2);

INSERT INTO inscripcion (id_estudiante, id_asignatura, nota)
VALUES (1, 10,  9.50), (1, 11,  7.00), (1, 14, 11.00),
       (2, 10,  8.00), (2, 13,  5.00),
       (3, 10,  6.50), (3, 12, 10.00),
       (4, 10,  4.00), (4, 11,  6.00), (4, 14, NULL),
       (5, 10, 12.00), (5, 12,  9.00), (5, 13,  8.50),
       (6, 10,  7.50), (6, 12, NULL),
       (7, 10, 10.00), (7, 14,  9.00),
       (8, 11,  3.00), (8, 12,  6.00),
       (9, 13,  7.00), (9, 14, NULL);
/********************************/
