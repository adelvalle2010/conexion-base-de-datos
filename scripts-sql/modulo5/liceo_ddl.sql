/********************************/
/* liceo_ddl.sql                                                   */
/* Módulo 5 — Definición de Datos (DDL)                            */
/* Crea la estructura de la base del liceo siguiendo el módulo:    */
/*   Parte A: CREATE DATABASE y CREATE TABLE                       */
/*   Parte B: claves primarias y foráneas                          */
/*   Parte C: restricciones (tabla grupo)                          */
/*   Parte D: ALTER TABLE para llegar al diseño final              */
/* No carga datos: eso se hace en el Módulo 6 (liceo_dml.sql).     */
/********************************/

DROP DATABASE IF EXISTS liceo;
CREATE DATABASE liceo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE liceo;

-- =============================================================
-- PARTE A: las primeras tablas
-- =============================================================

CREATE TABLE docente (
    id_docente INT         NOT NULL AUTO_INCREMENT,
    nombre     VARCHAR(50) NOT NULL,
    apellido   VARCHAR(50) NOT NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_docente)
);

CREATE TABLE estudiante (
    id_estudiante    INT         NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(50) NOT NULL,
    apellido         VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE        NOT NULL,
    grupo            VARCHAR(10) NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante)
);

-- =============================================================
-- PARTE B: tablas con claves foráneas
-- =============================================================

CREATE TABLE asignatura (
    id_asignatura INT         NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(60) NOT NULL,
    id_docente    INT         NOT NULL,
    CONSTRAINT pk_asignatura PRIMARY KEY (id_asignatura),
    CONSTRAINT fk_asignatura_docente FOREIGN KEY (id_docente)
        REFERENCES docente (id_docente)
);

CREATE TABLE inscripcion (
    id_estudiante INT          NOT NULL,
    id_asignatura INT          NOT NULL,
    nota          DECIMAL(4,2),
    CONSTRAINT pk_inscripcion PRIMARY KEY (id_estudiante, id_asignatura),
    CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES estudiante (id_estudiante)
        ON DELETE CASCADE,
    CONSTRAINT fk_inscripcion_asignatura FOREIGN KEY (id_asignatura)
        REFERENCES asignatura (id_asignatura)
);

-- =============================================================
-- PARTE C: una tabla con todas las restricciones
-- =============================================================

CREATE TABLE grupo (
    id_grupo INT         NOT NULL AUTO_INCREMENT,
    nombre   VARCHAR(10) NOT NULL,
    turno    VARCHAR(10) NOT NULL DEFAULT 'matutino',
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT uq_grupo_nombre UNIQUE (nombre),
    CONSTRAINT chk_grupo_turno CHECK (turno IN ('matutino', 'vespertino', 'nocturno'))
);

-- =============================================================
-- PARTE D: cambios sobre tablas que ya existen
-- =============================================================

-- El grupo deja de ser un texto y pasa a ser una clave foránea
ALTER TABLE estudiante
    ADD COLUMN id_grupo INT NOT NULL;

ALTER TABLE estudiante
    ADD CONSTRAINT fk_estudiante_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo);

ALTER TABLE estudiante
    DROP COLUMN grupo;

-- No puede haber dos asignaturas con el mismo nombre
ALTER TABLE asignatura
    ADD CONSTRAINT uq_asignatura_nombre UNIQUE (nombre);

-- La nota va de 1 a 12
ALTER TABLE inscripcion
    ADD CONSTRAINT chk_inscripcion_nota CHECK (nota BETWEEN 1 AND 12);
/********************************/
