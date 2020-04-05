--
-- PostgreSQL database dump
--

-- Dumped from database version 10.12 (Ubuntu 10.12-2.pgdg18.04+1)
-- Dumped by pg_dump version 12.2 (Ubuntu 12.2-2.pgdg18.04+1)

-- Started on 2020-04-05 17:32:49 -03

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
-- TOC entry 202 (class 1259 OID 16403)
-- Name: banco; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.banco (
    co_banco character varying(4) NOT NULL,
    ibp character varying(100) NOT NULL,
    in_activo boolean DEFAULT true
);


ALTER TABLE cobros.banco OWNER TO cobros;

--
-- TOC entry 3014 (class 0 OID 16403)
-- Dependencies: 202
-- Data for Name: banco; Type: TABLE DATA; Schema: cobros; Owner: cobros
--

INSERT INTO cobros.banco VALUES ('0001', 'Banco Central de Venezuela ', true);
INSERT INTO cobros.banco VALUES ('0002', 'Banco Industrial de Venezuela, C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0003', 'Banco de Venezuela S.A.C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0004', 'Venezolano de Crédito, S.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0005', 'Banco Mercantil, C.A S.A.C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0006', 'Banco Provincial, S.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0007', 'Bancaribe C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0008', 'Banco Exterior C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0009', 'Banco Occidental de Descuento, Banco Universal C.A. ', true);
INSERT INTO cobros.banco VALUES ('0010', 'Banco Caroní C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0011', 'Banesco Banco Universal S.A.C.A. ', true);
INSERT INTO cobros.banco VALUES ('0012', 'Banco Sofitasa Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0013', 'Banco Plaza Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0014', 'Banco de la Gente Emprendedora C.A. ', true);
INSERT INTO cobros.banco VALUES ('0015', 'Banco del Pueblo Soberano, C.A. Banco de Desarrollo ', true);
INSERT INTO cobros.banco VALUES ('0016', 'BFC Banco Fondo Común C.A Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0017', '100% Banco, Banco Universal C.A. ', true);
INSERT INTO cobros.banco VALUES ('0018', 'DelSur Banco Universal, C.A. ', true);
INSERT INTO cobros.banco VALUES ('0019', 'Banco del Tesoro, C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0020', 'Banco Agrícola de Venezuela, C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0021', 'Bancrecer, S.A. Banco Microfinanciero ', true);
INSERT INTO cobros.banco VALUES ('0022', 'Mi Banco Banco Microfinanciero C.A. ', true);
INSERT INTO cobros.banco VALUES ('0023', 'Banco Activo, C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0024', 'Bancamiga Banco Microfinanciero C.A. ', true);
INSERT INTO cobros.banco VALUES ('0025', 'Banco Internacional de Desarrollo, C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0026', 'Banplus Banco Universal, C.A. ', true);
INSERT INTO cobros.banco VALUES ('0027', 'Banco Bicentenario Banco Universal C.A. ', true);
INSERT INTO cobros.banco VALUES ('0028', 'Banco Espirito Santo, S.A. Sucursal Venezuela B.U. ', true);
INSERT INTO cobros.banco VALUES ('0029', 'Banco de la Fuerza Armada Nacional Bolivariana, B.U. ', true);
INSERT INTO cobros.banco VALUES ('0030', 'Citibank N.A. ', true);
INSERT INTO cobros.banco VALUES ('0031', 'Banco Nacional de Crédito, C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0032', 'Instituto Municipal de Crédito Popular ', true);
INSERT INTO cobros.banco VALUES ('0134', 'Banesco Banco Universal S.A.C.A.  ', true);
INSERT INTO cobros.banco VALUES ('0137', 'Banco Sofitasa, Banco Universal   ', true);
INSERT INTO cobros.banco VALUES ('0138', 'Banco Plaza, Banco Universal', true);
INSERT INTO cobros.banco VALUES ('0146', 'Banco de la Gente Emprendedora C.A', true);
INSERT INTO cobros.banco VALUES ('0151', 'BFC Banco Fondo Común C.A. Banco Universal ', true);
INSERT INTO cobros.banco VALUES ('0156', '100% Banco, Banco Universal C.A.', true);
INSERT INTO cobros.banco VALUES ('0157', 'DelSur Banco Universal C.A.', true);
INSERT INTO cobros.banco VALUES ('0163', 'Banco del Tesoro, C.A. Banco Universal', true);
INSERT INTO cobros.banco VALUES ('0166', 'Banco Agrícola de Venezuela, C.A. Banco Universal  ', true);
INSERT INTO cobros.banco VALUES ('0168', 'Bancrecer, S.A. Banco Microfinanciero   ', true);
INSERT INTO cobros.banco VALUES ('0169', 'Mi Banco, Banco Microfinanciero C.A.  ', true);
INSERT INTO cobros.banco VALUES ('0171', 'Banco Activo, Banco Universal  ', true);
INSERT INTO cobros.banco VALUES ('0172', 'Bancamica, Banco Microfinanciero C.A.', true);
INSERT INTO cobros.banco VALUES ('0173', 'Banco Internacional de Desarrollo, C.A. Banco Universal  ', true);
INSERT INTO cobros.banco VALUES ('0174', 'Banplus Banco Universal, C.A', true);
INSERT INTO cobros.banco VALUES ('0175', 'Banco Bicentenario del Pueblo de la Clase Obrera, Mujer y Comunas B.U.', true);
INSERT INTO cobros.banco VALUES ('0176', 'Novo Banco, S.A. Sucursal Venezuela Banco Universal    ', true);
INSERT INTO cobros.banco VALUES ('0177', 'Banco de la Fuerza Armada Nacional Bolivariana, B.U.', true);
INSERT INTO cobros.banco VALUES ('0190', 'Citibank N.A.', true);
INSERT INTO cobros.banco VALUES ('0191', 'Banco Nacional de Crédito, C.A. Banco Universal', true);
INSERT INTO cobros.banco VALUES ('0601', 'Instituto Municipal de Crédito Popular', true);
INSERT INTO cobros.banco VALUES ('0116', 'Banco Occidental de Descuento, C.A ', true);


--
-- TOC entry 2892 (class 2606 OID 24812)
-- Name: banco pk_banco; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.banco
    ADD CONSTRAINT pk_banco PRIMARY KEY (co_banco);


--
-- TOC entry 3020 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE banco; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.banco TO cobros_apl;


-- Completed on 2020-04-05 17:32:49 -03

--
-- PostgreSQL database dump complete
--

