-- SEQUENCE: cobros.archivo_co_archivo_seq

-- DROP SEQUENCE cobros.archivo_co_archivo_seq;

CREATE SEQUENCE cobros.archivo_co_archivo_seq
    INCREMENT 1
    START 126
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE cobros.archivo_co_archivo_seq
    OWNER TO cobros;

GRANT ALL ON SEQUENCE cobros.archivo_co_archivo_seq TO cobros;

GRANT ALL ON SEQUENCE cobros.archivo_co_archivo_seq TO cobros_apl;

-- SEQUENCE: cobros.archivo_detalle_nu_regstro_seq

-- DROP SEQUENCE cobros.archivo_detalle_nu_regstro_seq;

CREATE SEQUENCE cobros.archivo_detalle_nu_regstro_seq
    INCREMENT 1
    START 2414
    MINVALUE 1
    MAXVALUE 999999999
    CACHE 1;

ALTER SEQUENCE cobros.archivo_detalle_nu_regstro_seq
    OWNER TO cobros_apl;

GRANT ALL ON SEQUENCE cobros.archivo_detalle_nu_regstro_seq TO cobros_apl;

-- SEQUENCE: cobros.convenio_co_convenio_seq

-- DROP SEQUENCE cobros.convenio_co_convenio_seq;

CREATE SEQUENCE cobros.convenio_co_convenio_seq
    INCREMENT 1
    START 11
    MINVALUE 1
    MAXVALUE 99999
    CACHE 1;

ALTER SEQUENCE cobros.convenio_co_convenio_seq
    OWNER TO cobros_apl;

GRANT ALL ON SEQUENCE cobros.convenio_co_convenio_seq TO cobros_apl;

-- SEQUENCE: cobros.cuota_co_cuota_seq

-- DROP SEQUENCE cobros.cuota_co_cuota_seq;

CREATE SEQUENCE cobros.cuota_co_cuota_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE cobros.cuota_co_cuota_seq
    OWNER TO cobros;

GRANT ALL ON SEQUENCE cobros.cuota_co_cuota_seq TO cobros;

GRANT ALL ON SEQUENCE cobros.cuota_co_cuota_seq TO cobros_apl;

-- SEQUENCE: cobros.titular_co_titular_seq

-- DROP SEQUENCE cobros.titular_co_titular_seq;

CREATE SEQUENCE cobros.titular_co_titular_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9999999999
    CACHE 1;

ALTER SEQUENCE cobros.titular_co_titular_seq
    OWNER TO cobros;

GRANT ALL ON SEQUENCE cobros.titular_co_titular_seq TO cobros;

GRANT ALL ON SEQUENCE cobros.titular_co_titular_seq TO cobros_apl;
