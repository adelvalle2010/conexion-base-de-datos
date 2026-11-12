/********************************/
/* liceo_programado.sql                                            */
/* La base del liceo con todo lo creado en el Módulo 10:           */
/* tabla de auditoría, procedimientos, funciones y triggers.       */
/* Crea una base aparte (liceo_programado) para no pisar a liceo.  */
/* Se puede ejecutar todas las veces que haga falta: borra la base */
/* y la vuelve a crear.                                            */
/********************************/

DROP DATABASE IF EXISTS liceo_programado;
CREATE DATABASE liceo_programado CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE liceo_programado;

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

-- =============================================================
-- Tabla de auditoría
-- =============================================================

CREATE TABLE auditoria_nota (
    id_auditoria  INT          NOT NULL AUTO_INCREMENT,
    operacion     VARCHAR(10)  NOT NULL,
    id_estudiante INT          NOT NULL,
    id_asignatura INT          NOT NULL,
    nota_anterior DECIMAL(4,2),
    nota_nueva    DECIMAL(4,2),
    usuario       VARCHAR(100) NOT NULL,
    fecha         DATETIME     NOT NULL,
    CONSTRAINT pk_auditoria_nota PRIMARY KEY (id_auditoria)
);

DELIMITER $$

-- =============================================================
-- Procedimientos almacenados
-- =============================================================

CREATE PROCEDURE sp_listar_grupos()
BEGIN
    SELECT id_grupo, nombre, turno
    FROM grupo
    ORDER BY turno, nombre;
END$$

CREATE PROCEDURE sp_notas_estudiante(IN p_id_estudiante INT)
BEGIN
    SELECT a.nombre AS asignatura, i.nota
    FROM inscripcion AS i
    INNER JOIN asignatura AS a ON a.id_asignatura = i.id_asignatura
    WHERE i.id_estudiante = p_id_estudiante
    ORDER BY a.nombre;
END$$

CREATE PROCEDURE sp_promedio_estudiante(
    IN  p_id_estudiante INT,
    OUT p_promedio      DECIMAL(4,2)
)
BEGIN
    SELECT ROUND(AVG(nota), 2)
    INTO p_promedio
    FROM inscripcion
    WHERE id_estudiante = p_id_estudiante;
END$$

CREATE PROCEDURE sp_inscribir(
    IN p_id_estudiante INT,
    IN p_id_asignatura INT
)
BEGIN
    DECLARE v_existe_estudiante INT;
    DECLARE v_existe_asignatura INT;
    DECLARE v_ya_inscripto      INT;

    SELECT COUNT(*) INTO v_existe_estudiante
    FROM estudiante
    WHERE id_estudiante = p_id_estudiante;

    SELECT COUNT(*) INTO v_existe_asignatura
    FROM asignatura
    WHERE id_asignatura = p_id_asignatura;

    SELECT COUNT(*) INTO v_ya_inscripto
    FROM inscripcion
    WHERE id_estudiante = p_id_estudiante
      AND id_asignatura = p_id_asignatura;

    IF v_existe_estudiante = 0 THEN
        SELECT 'Error: el estudiante no existe' AS resultado;
    ELSEIF v_existe_asignatura = 0 THEN
        SELECT 'Error: la asignatura no existe' AS resultado;
    ELSEIF v_ya_inscripto > 0 THEN
        SELECT 'Error: ya estaba inscripto' AS resultado;
    ELSE
        INSERT INTO inscripcion (id_estudiante, id_asignatura)
        VALUES (p_id_estudiante, p_id_asignatura);

        SELECT 'Inscripción realizada' AS resultado;
    END IF;
END$$

CREATE PROCEDURE sp_cambiar_asignatura(
    IN p_id_estudiante INT,
    IN p_desde         INT,
    IN p_hacia         INT
)
BEGIN
    -- Si ocurre cualquier error: deshacer y volver a lanzar el error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    DELETE FROM inscripcion
    WHERE id_estudiante = p_id_estudiante
      AND id_asignatura = p_desde;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El estudiante no está inscripto en la asignatura de origen';
    END IF;

    INSERT INTO inscripcion (id_estudiante, id_asignatura)
    VALUES (p_id_estudiante, p_hacia);

    COMMIT;
END$$

CREATE PROCEDURE sp_crear_grupos(
    IN p_nivel    INT,
    IN p_cantidad INT,
    IN p_turno    VARCHAR(10)
)
BEGIN
    DECLARE v_i INT DEFAULT 1;

    WHILE v_i <= p_cantidad DO
        INSERT INTO grupo (nombre, turno)
        VALUES (CONCAT(p_nivel, 'º', CHAR(64 + v_i USING utf8mb4)), p_turno);

        SET v_i = v_i + 1;
    END WHILE;
END$$

-- =============================================================
-- Funciones almacenadas
-- =============================================================

CREATE FUNCTION fn_nombre_completo(
    p_nombre   VARCHAR(50),
    p_apellido VARCHAR(50)
)
RETURNS VARCHAR(102)
DETERMINISTIC
BEGIN
    RETURN CONCAT(p_apellido, ', ', p_nombre);
END$$

CREATE FUNCTION fn_calificacion(p_nota DECIMAL(4,2))
RETURNS VARCHAR(15)
DETERMINISTIC
BEGIN
    DECLARE v_texto VARCHAR(15);

    IF p_nota IS NULL THEN
        SET v_texto = 'Sin nota';
    ELSEIF p_nota < 6 THEN
        SET v_texto = 'No aprobado';
    ELSEIF p_nota < 9 THEN
        SET v_texto = 'Aprobado';
    ELSE
        SET v_texto = 'Destacado';
    END IF;

    RETURN v_texto;
END$$

CREATE FUNCTION fn_edad_al(
    p_nacimiento DATE,
    p_dia        DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_nacimiento, p_dia);
END$$

CREATE FUNCTION fn_promedio_estudiante(p_id_estudiante INT)
RETURNS DECIMAL(4,2)
READS SQL DATA
BEGIN
    DECLARE v_promedio DECIMAL(4,2);

    SELECT ROUND(AVG(nota), 2)
    INTO v_promedio
    FROM inscripcion
    WHERE id_estudiante = p_id_estudiante;

    RETURN v_promedio;
END$$

-- =============================================================
-- Triggers
-- (se crean al final, para que la carga de datos no los dispare)
-- =============================================================

CREATE TRIGGER trg_inscripcion_after_update
AFTER UPDATE ON inscripcion
FOR EACH ROW
BEGIN
    IF NOT (OLD.nota <=> NEW.nota) THEN
        INSERT INTO auditoria_nota
            (operacion, id_estudiante, id_asignatura, nota_anterior, nota_nueva, usuario, fecha)
        VALUES
            ('UPDATE', OLD.id_estudiante, OLD.id_asignatura, OLD.nota, NEW.nota, CURRENT_USER(), NOW());
    END IF;
END$$

CREATE TRIGGER trg_estudiante_before_insert
BEFORE INSERT ON estudiante
FOR EACH ROW
BEGIN
    -- Sin espacios sobrantes
    SET NEW.nombre   = TRIM(NEW.nombre);
    SET NEW.apellido = TRIM(NEW.apellido);

    -- Primera letra en mayúscula
    SET NEW.nombre   = CONCAT(UPPER(LEFT(NEW.nombre, 1)),   SUBSTRING(NEW.nombre, 2));
    SET NEW.apellido = CONCAT(UPPER(LEFT(NEW.apellido, 1)), SUBSTRING(NEW.apellido, 2));
END$$

CREATE TRIGGER trg_inscripcion_before_insert
BEFORE INSERT ON inscripcion
FOR EACH ROW
BEGIN
    DECLARE v_cantidad INT;

    SELECT COUNT(*)
    INTO v_cantidad
    FROM inscripcion
    WHERE id_estudiante = NEW.id_estudiante;

    IF v_cantidad >= 4 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un estudiante no puede tener más de 4 inscripciones';
    END IF;
END$$

CREATE TRIGGER trg_inscripcion_after_delete
AFTER DELETE ON inscripcion
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_nota
        (operacion, id_estudiante, id_asignatura, nota_anterior, nota_nueva, usuario, fecha)
    VALUES
        ('DELETE', OLD.id_estudiante, OLD.id_asignatura, OLD.nota, NULL, CURRENT_USER(), NOW());
END$$

DELIMITER ;
/********************************/
