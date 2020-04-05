-- Table: cobros.archivo

-- DROP TABLE cobros.archivo;

CREATE TABLE cobros.archivo
(
  co_archivo integer NOT NULL DEFAULT nextval('cobros.archivo_co_archivo_seq'::regclass),
  co_banco character varying(4) NOT NULL,
  fe_cobro date NOT NULL,
  fe_insert date,
  CONSTRAINT pk_archivo PRIMARY KEY (co_archivo)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cobros.archivo
  OWNER TO cobros;
GRANT ALL ON TABLE cobros.archivo TO cobros;
GRANT ALL ON TABLE cobros.archivo TO cobros_apl;

-- Table: cobros.archivo_detalle

-- DROP TABLE cobros.archivo_detalle;

CREATE TABLE cobros.archivo_detalle
(
  co_archivo integer NOT NULL,
  nu_registro integer NOT NULL DEFAULT nextval('cobros.archivo_detalle_nu_regstro_seq'::regclass),
  tx_registro_cobro character varying(100),
  co_banco character varying(4),
  monto_cuota numeric(18,2),
  CONSTRAINT pk_archivo_detalle PRIMARY KEY (co_archivo, nu_registro),
  CONSTRAINT fk_archivodetalle_archivo FOREIGN KEY (co_archivo)
      REFERENCES cobros.archivo (co_archivo) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_archivodetalle_banco FOREIGN KEY (co_banco)
      REFERENCES cobros.banco (co_banco) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cobros.archivo_detalle
  OWNER TO cobros;
GRANT ALL ON TABLE cobros.archivo_detalle TO cobros;
GRANT ALL ON TABLE cobros.archivo_detalle TO cobros_apl;


-- Table: cobros.banco

-- DROP TABLE cobros.banco;

CREATE TABLE cobros.banco
(
  co_banco character varying(4) NOT NULL,
  ibp character varying(100) NOT NULL,
  in_activo boolean DEFAULT true,
  CONSTRAINT pk_banco PRIMARY KEY (co_banco)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cobros.banco
  OWNER TO cobros;
GRANT ALL ON TABLE cobros.banco TO cobros;
GRANT ALL ON TABLE cobros.banco TO cobros_apl;

-- Table: cobros.banco

-- DROP TABLE cobros.banco;

CREATE TABLE cobros.banco
(
  co_banco character varying(4) NOT NULL,
  ibp character varying(100) NOT NULL,
  in_activo boolean DEFAULT true,
  CONSTRAINT pk_banco PRIMARY KEY (co_banco)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cobros.banco
  OWNER TO cobros;
GRANT ALL ON TABLE cobros.banco TO cobros;
GRANT ALL ON TABLE cobros.banco TO cobros_apl;

-- Table: cobros.dia_debito

-- DROP TABLE cobros.dia_debito;

CREATE TABLE cobros.dia_debito
(
  co_dia_debito numeric(1,0) NOT NULL,
  de_dia_debito character varying(50) NOT NULL,
  in_activo boolean DEFAULT true,
  CONSTRAINT pk_dia_debito PRIMARY KEY (co_dia_debito)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cobros.dia_debito
  OWNER TO cobros_apl;
GRANT ALL ON TABLE cobros.dia_debito TO cobros_apl;
COMMENT ON TABLE cobros.dia_debito
  IS 'frecuencia de cobros para generar cuotas';

-- Table: cobros.dia_debito

-- DROP TABLE cobros.dia_debito;

CREATE TABLE cobros.dia_debito
(
  co_dia_debito numeric(1,0) NOT NULL,
  de_dia_debito character varying(50) NOT NULL,
  in_activo boolean DEFAULT true,
  CONSTRAINT pk_dia_debito PRIMARY KEY (co_dia_debito)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cobros.dia_debito
  OWNER TO cobros_apl;
GRANT ALL ON TABLE cobros.dia_debito TO cobros_apl;
COMMENT ON TABLE cobros.dia_debito
  IS 'frecuencia de cobros para generar cuotas';

-- Table: cobros.dia_debito

-- DROP TABLE cobros.dia_debito;

CREATE TABLE cobros.dia_debito
(
  co_dia_debito numeric(2,0) NOT NULL,
  de_dia_debito character varying(50) NOT NULL,
  in_activo boolean DEFAULT true,
  CONSTRAINT pk_dia_debito PRIMARY KEY (co_dia_debito)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cobros.dia_debito
  OWNER TO cobros_apl;
GRANT ALL ON TABLE cobros.dia_debito TO cobros_apl;
COMMENT ON TABLE cobros.dia_debito
  IS 'frecuencia de cobros para generar cuotas';


