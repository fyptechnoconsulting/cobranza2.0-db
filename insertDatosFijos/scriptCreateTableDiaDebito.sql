--
-- PostgreSQL database dump
--

-- Dumped from database version 10.12 (Ubuntu 10.12-2.pgdg18.04+1)
-- Dumped by pg_dump version 12.2 (Ubuntu 12.2-2.pgdg18.04+1)

-- Started on 2020-04-05 17:39:06 -03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- TOC entry 209 (class 1259 OID 16428)
-- Name: dia_debito; Type: TABLE; Schema: cobros; Owner: cobros_apl
--

CREATE TABLE cobros.dia_debito (
    co_dia_debito numeric(2,0) NOT NULL,
    de_dia_debito character varying(50) NOT NULL,
    in_activo boolean DEFAULT true
);


ALTER TABLE cobros.dia_debito OWNER TO cobros_apl;

--
-- TOC entry 3020 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE dia_debito; Type: COMMENT; Schema: cobros; Owner: cobros_apl
--

COMMENT ON TABLE cobros.dia_debito IS 'frecuencia de cobros para generar cuotas';


--
-- TOC entry 3014 (class 0 OID 16428)
-- Dependencies: 209
-- Data for Name: dia_debito; Type: TABLE DATA; Schema: cobros; Owner: cobros_apl
--

INSERT INTO cobros.dia_debito VALUES (0, '15 y 30', true);
INSERT INTO cobros.dia_debito VALUES (1, '15 Unico', true);
INSERT INTO cobros.dia_debito VALUES (2, '30 Unico', true);
INSERT INTO cobros.dia_debito VALUES (3, '8 y 22', true);
INSERT INTO cobros.dia_debito VALUES (4, '8 unico', true);
INSERT INTO cobros.dia_debito VALUES (5, '22 unico', true);
INSERT INTO cobros.dia_debito VALUES (6, '10 y 25', true);
INSERT INTO cobros.dia_debito VALUES (7, '10 unico', true);
INSERT INTO cobros.dia_debito VALUES (8, '25 unico', true);
INSERT INTO cobros.dia_debito VALUES (9, '13 y 27', true);
INSERT INTO cobros.dia_debito VALUES (10, '13 unico', true);
INSERT INTO cobros.dia_debito VALUES (11, '27 unico', true);
INSERT INTO cobros.dia_debito VALUES (12, 'Semanal Viernes', true);


--
-- TOC entry 2892 (class 2606 OID 24814)
-- Name: dia_debito pk_dia_debito; Type: CONSTRAINT; Schema: cobros; Owner: cobros_apl
--

ALTER TABLE ONLY cobros.dia_debito
    ADD CONSTRAINT pk_dia_debito PRIMARY KEY (co_dia_debito);


-- Completed on 2020-04-05 17:39:07 -03

--
-- PostgreSQL database dump complete
--

