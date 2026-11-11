/********************************/
/* liceo_sin_normalizar.sql                                        */
/* Módulo 3 — Normalización                                        */
/* Parte A: la planilla única, tal como la llevaba la secretaría.  */
/* Parte B: las mismas notas después de aplicar 1FN, 2FN y 3FN.    */
/********************************/

DROP DATABASE IF EXISTS liceo_sin_normalizar;
CREATE DATABASE liceo_sin_normalizar CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE liceo_sin_normalizar;

-- =============================================================
-- PARTE A: la planilla sin normalizar
-- =============================================================

CREATE TABLE planilla_notas (
    id_estudiante       INT          NOT NULL,
    nombre_estudiante   VARCHAR(50)  NOT NULL,
    apellido_estudiante VARCHAR(50)  NOT NULL,
    grupo               VARCHAR(10)  NOT NULL,
    telefonos           VARCHAR(100),             -- ❌ varios valores en una celda
    id_asignatura       INT          NOT NULL,
    nombre_asignatura   VARCHAR(60)  NOT NULL,
    id_docente          INT          NOT NULL,
    nombre_docente      VARCHAR(50)  NOT NULL,
    apellido_docente    VARCHAR(50)  NOT NULL,
    nota                DECIMAL(4,2),
    CONSTRAINT pk_planilla_notas PRIMARY KEY (id_estudiante, id_asignatura)
);

INSERT INTO planilla_notas VALUES
(1, 'Lucía',     'Fernández', '3ºA', '099 111 222, 098 333 444', 10, 'Matemática', 1, 'Ana',    'Pereira',  9.50),
(1, 'Lucía',     'Fernández', '3ºA', '099 111 222, 098 333 444', 11, 'Física',     2, 'Carlos', 'Méndez',   7.00),
(2, 'Mateo',     'Silva',     '3ºB', '091 555 666',              10, 'Matemática', 1, 'Ana',    'Pereira',  8.00),
(3, 'Valentina', 'Rodríguez', '3ºA', NULL,                       10, 'Matemática', 1, 'Ana',    'Pereira',  6.50),
(3, 'Valentina', 'Rodríguez', '3ºA', NULL,                       12, 'Historia',   3, 'Laura',  'Sosa',    10.00);

-- =============================================================
-- PARTE B: el resultado de normalizar (hasta 3FN)
-- =============================================================

CREATE TABLE docente (
    id_docente INT         NOT NULL,
    nombre     VARCHAR(50) NOT NULL,
    apellido   VARCHAR(50) NOT NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_docente)
);

CREATE TABLE estudiante (
    id_estudiante INT         NOT NULL,
    nombre        VARCHAR(50) NOT NULL,
    apellido      VARCHAR(50) NOT NULL,
    grupo         VARCHAR(10) NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante)
);

CREATE TABLE telefono_estudiante (
    id_estudiante INT         NOT NULL,
    telefono      VARCHAR(20) NOT NULL,
    CONSTRAINT pk_telefono_estudiante PRIMARY KEY (id_estudiante, telefono),
    CONSTRAINT fk_telefono_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante (id_estudiante)
);

CREATE TABLE asignatura (
    id_asignatura INT         NOT NULL,
    nombre        VARCHAR(60) NOT NULL,
    id_docente    INT         NOT NULL,
    CONSTRAINT pk_asignatura PRIMARY KEY (id_asignatura),
    CONSTRAINT fk_asignatura_docente FOREIGN KEY (id_docente) REFERENCES docente (id_docente)
);

CREATE TABLE inscripcion (
    id_estudiante INT NOT NULL,
    id_asignatura INT NOT NULL,
    nota          DECIMAL(4,2),
    CONSTRAINT pk_inscripcion PRIMARY KEY (id_estudiante, id_asignatura),
    CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante (id_estudiante),
    CONSTRAINT fk_inscripcion_asignatura FOREIGN KEY (id_asignatura) REFERENCES asignatura (id_asignatura)
);

INSERT INTO docente (id_docente, nombre, apellido) VALUES
(1, 'Ana',    'Pereira'),
(2, 'Carlos', 'Méndez'),
(3, 'Laura',  'Sosa');

INSERT INTO estudiante (id_estudiante, nombre, apellido, grupo) VALUES
(1, 'Lucía',     'Fernández', '3ºA'),
(2, 'Mateo',     'Silva',     '3ºB'),
(3, 'Valentina', 'Rodríguez', '3ºA');

INSERT INTO telefono_estudiante (id_estudiante, telefono) VALUES
(1, '099 111 222'),
(1, '098 333 444'),
(2, '091 555 666');

INSERT INTO asignatura (id_asignatura, nombre, id_docente) VALUES
(10, 'Matemática', 1),
(11, 'Física',     2),
(12, 'Historia',   3);

INSERT INTO inscripcion (id_estudiante, id_asignatura, nota) VALUES
(1, 10,  9.50),
(1, 11,  7.00),
(2, 10,  8.00),
(3, 10,  6.50),
(3, 12, 10.00);
/********************************/
