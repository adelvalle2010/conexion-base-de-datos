/********************************/
/* proyecto_integrador.sql                                              */
/* Módulo 12 — Proyecto Integrador: la biblioteca del liceo.            */
/* Crea la base biblioteca_liceo: las tablas del liceo que se reutilizan*/
/* (grupo, estudiante) más el subsistema de biblioteca (categoría,      */
/* autor, libro, libro_autor, ejemplar, préstamo), con datos de prueba, */
/* una vista, un procedimiento y un trigger.                            */
/* Se puede ejecutar todas las veces que haga falta: borra y recrea.    */
/********************************/

DROP DATABASE IF EXISTS biblioteca_liceo;
CREATE DATABASE biblioteca_liceo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE biblioteca_liceo;

-- =============================================================
-- Tablas reutilizadas del liceo (los estudiantes son los socios)
-- =============================================================

CREATE TABLE grupo (
    id_grupo INT         NOT NULL AUTO_INCREMENT,
    nombre   VARCHAR(10) NOT NULL,
    turno    VARCHAR(10) NOT NULL DEFAULT 'matutino',
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT uq_grupo_nombre UNIQUE (nombre)
);

CREATE TABLE estudiante (
    id_estudiante INT         NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(50) NOT NULL,
    apellido      VARCHAR(50) NOT NULL,
    id_grupo      INT         NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT fk_estudiante_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
);

-- =============================================================
-- Subsistema de biblioteca
-- =============================================================

CREATE TABLE categoria (
    id_categoria INT         NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(50) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
);

CREATE TABLE autor (
    id_autor INT         NOT NULL AUTO_INCREMENT,
    nombre   VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    CONSTRAINT pk_autor PRIMARY KEY (id_autor)
);

CREATE TABLE libro (
    id_libro     INT         NOT NULL AUTO_INCREMENT,
    titulo       VARCHAR(120) NOT NULL,
    anio         INT,
    id_categoria INT         NOT NULL,
    CONSTRAINT pk_libro PRIMARY KEY (id_libro),
    CONSTRAINT fk_libro_categoria FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria),
    CONSTRAINT chk_libro_anio CHECK (anio BETWEEN 1400 AND 2100)
);

-- Relación N:M entre libro y autor
CREATE TABLE libro_autor (
    id_libro INT NOT NULL,
    id_autor INT NOT NULL,
    CONSTRAINT pk_libro_autor PRIMARY KEY (id_libro, id_autor),
    CONSTRAINT fk_la_libro FOREIGN KEY (id_libro) REFERENCES libro (id_libro) ON DELETE CASCADE,
    CONSTRAINT fk_la_autor FOREIGN KEY (id_autor) REFERENCES autor (id_autor)
);

CREATE TABLE ejemplar (
    id_ejemplar INT         NOT NULL AUTO_INCREMENT,
    id_libro    INT         NOT NULL,
    estado      VARCHAR(12) NOT NULL DEFAULT 'disponible',
    CONSTRAINT pk_ejemplar PRIMARY KEY (id_ejemplar),
    CONSTRAINT fk_ejemplar_libro FOREIGN KEY (id_libro) REFERENCES libro (id_libro),
    CONSTRAINT chk_ejemplar_estado CHECK (estado IN ('disponible', 'prestado', 'baja'))
);

CREATE TABLE prestamo (
    id_prestamo              INT  NOT NULL AUTO_INCREMENT,
    id_ejemplar              INT  NOT NULL,
    id_estudiante            INT  NOT NULL,
    fecha_prestamo           DATE NOT NULL,
    fecha_devolucion_pactada DATE NOT NULL,
    fecha_devolucion_real    DATE,
    CONSTRAINT pk_prestamo PRIMARY KEY (id_prestamo),
    CONSTRAINT fk_prestamo_ejemplar FOREIGN KEY (id_ejemplar) REFERENCES ejemplar (id_ejemplar),
    CONSTRAINT fk_prestamo_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante (id_estudiante),
    CONSTRAINT chk_prestamo_fechas CHECK (fecha_devolucion_pactada >= fecha_prestamo)
);

-- =============================================================
-- Datos de prueba
-- =============================================================

INSERT INTO grupo (id_grupo, nombre, turno) VALUES
    (1, '3ºA', 'matutino'), (2, '3ºB', 'vespertino'), (3, '2ºA', 'matutino');

INSERT INTO estudiante (id_estudiante, nombre, apellido, id_grupo) VALUES
    (1,'Lucía','Fernández',1), (2,'Mateo','Silva',2), (3,'Valentina','Rodríguez',1),
    (4,'Santiago','Pérez',1), (5,'Camila','González',3), (6,'Joaquín','Martínez',3),
    (7,'Sofía','López',2), (8,'Benjamín','Castro',1), (9,'Martina','Suárez',2),
    (10,'Agustín','Núñez',2);

INSERT INTO categoria (id_categoria, nombre) VALUES
    (1,'Novela'), (2,'Informática'), (3,'Historia'), (4,'Ciencia'), (5,'Poesía');

INSERT INTO autor (id_autor, nombre, apellido) VALUES
    (1,'Mario','Benedetti'), (2,'Jorge','Luis Borges'), (3,'Eduardo','Galeano'),
    (4,'Isabel','Allende'), (5,'Carl','Sagan'), (6,'Idea','Vilariño');

INSERT INTO libro (id_libro, titulo, anio, id_categoria) VALUES
    (1,'La tregua',1960,1),
    (2,'Ficciones',1944,1),
    (3,'Las venas abiertas de América Latina',1971,3),
    (4,'La casa de los espíritus',1982,1),
    (5,'Cosmos',1980,4),
    (6,'Poemas de amor',1957,5),
    (7,'Introducción a las bases de datos',2018,2);

-- Un libro puede tener varios autores y un autor varios libros (N:M)
INSERT INTO libro_autor (id_libro, id_autor) VALUES
    (1,1), (2,2), (3,3), (4,4), (5,5), (6,6),
    (6,1);   -- "Poemas de amor" figura con dos autores (ejemplo N:M)

-- Varios ejemplares por libro
INSERT INTO ejemplar (id_ejemplar, id_libro, estado) VALUES
    (1,1,'disponible'), (2,1,'disponible'),
    (3,2,'disponible'),
    (4,3,'disponible'), (5,3,'disponible'),
    (6,4,'disponible'),
    (7,5,'disponible'), (8,5,'disponible'),
    (9,6,'disponible'),
    (10,7,'disponible'), (11,7,'disponible'), (12,7,'baja');

-- Préstamos: algunos devueltos, otros vigentes
INSERT INTO prestamo (id_prestamo, id_ejemplar, id_estudiante, fecha_prestamo, fecha_devolucion_pactada, fecha_devolucion_real) VALUES
    (1, 1, 1, '2026-03-10', '2026-03-24', '2026-03-22'),
    (2, 3, 4, '2026-04-02', '2026-04-16', '2026-04-20'),
    (3, 4, 2, '2026-04-05', '2026-04-19', NULL),
    (4, 7, 5, '2026-04-08', '2026-04-22', NULL),
    (5, 10, 7, '2026-04-10', '2026-04-24', '2026-04-23'),
    (6, 6, 1, '2026-04-12', '2026-04-26', NULL);

-- Poner en estado 'prestado' los ejemplares con préstamo vigente (sin devolución real)
UPDATE ejemplar SET estado = 'prestado'
WHERE id_ejemplar IN (SELECT id_ejemplar FROM prestamo WHERE fecha_devolucion_real IS NULL);

-- =============================================================
-- Fase 3: vista, procedimiento y trigger
-- =============================================================

CREATE VIEW v_ejemplares_disponibles AS
SELECT e.id_ejemplar, l.titulo, c.nombre AS categoria
FROM ejemplar AS e
INNER JOIN libro     AS l ON l.id_libro = e.id_libro
INNER JOIN categoria AS c ON c.id_categoria = l.id_categoria
WHERE e.estado = 'disponible';

DELIMITER $$

CREATE TRIGGER trg_prestamo_after_insert
AFTER INSERT ON prestamo
FOR EACH ROW
BEGIN
    UPDATE ejemplar SET estado = 'prestado' WHERE id_ejemplar = NEW.id_ejemplar;
END$$

CREATE PROCEDURE sp_prestar(
    IN p_id_ejemplar   INT,
    IN p_id_estudiante INT,
    IN p_dias          INT
)
BEGIN
    DECLARE v_estado VARCHAR(12);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT estado INTO v_estado FROM ejemplar WHERE id_ejemplar = p_id_ejemplar;

    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ejemplar no existe';
    ELSEIF v_estado <> 'disponible' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ejemplar no está disponible';
    END IF;

    START TRANSACTION;
    INSERT INTO prestamo (id_ejemplar, id_estudiante, fecha_prestamo, fecha_devolucion_pactada)
    VALUES (p_id_ejemplar, p_id_estudiante, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_dias DAY));
    COMMIT;  -- el trigger ya marcó el ejemplar como 'prestado'
END$$

DELIMITER ;
/********************************/
