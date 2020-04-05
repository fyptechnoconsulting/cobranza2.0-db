--
-- PostgreSQL database dump
--

-- Dumped from database version 10.12 (Ubuntu 10.12-2.pgdg18.04+1)
-- Dumped by pg_dump version 12.2 (Ubuntu 12.2-2.pgdg18.04+1)

-- Started on 2020-04-05 17:27:48 -03

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

--
-- TOC entry 8 (class 2615 OID 16385)
-- Name: cobros; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA cobros;


ALTER SCHEMA cobros OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 16386)
-- Name: genera_datos_archivo_cobro(character varying, date, numeric, character varying); Type: FUNCTION; Schema: cobros; Owner: cobros_apl
--

CREATE FUNCTION cobros.genera_datos_archivo_cobro(co_banco character varying DEFAULT '0116'::character varying, fe_cobro date DEFAULT ('now'::text)::date, co_frecuencia_pago numeric DEFAULT 0, nu_cuenta_abadia character varying DEFAULT 'XXXXXXXXXXXXXXXX'::character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$begin

--CREA REGISTRO IDENTICADOR DE ARCHIVO
insert into cobros.archivo(co_banco,fe_cobro) values($1,$2);

--INICIA SECUENCIA DE NUMERACION PARA LOS REGISTROS DEL ARCHIVO
ALTER SEQUENCE cobros.archivo_detalle_nu_regstro_seq RESTART WITH 2;


--INSERTA REGISTRO RESUMEN --VERIFICAR, REQUIERE RECÁLCULO
insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,
       --row_number() over(order by ar.co_archivo),
       trim('02'||'DB'||'00'||        
       substring(tc.co_cuenta,2,3) || 
       $4  || --numero de cuenta abadia
       '000000' || '0000000' ||
       substring(replace(replace(to_char(sum(tc.monto_cuota),'9999999999999999.99'), ' ', '0'),'.',''),5,15)||
       to_char($2, 'yy') || to_char($2, 'mm') || '15'),
       ar.co_banco,        
       sum(tc.monto_cuota)
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta),cobros.archivo ar
where tc.co_cuota = (select min(tc2.co_cuota) from cobros.tmp_cuota tc2 where tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
and ti.co_dia_debito = $3
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
group by ar.co_archivo,substring(tc.co_cuenta,2,3),ar.co_banco;


--INSERTA CUOTAS CORRESPONDIENTES, EXCLUYENDO CUENTAS CON CONVENIOS

/*insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,     
       trim('02'||'DB'||'00'||
       substring(tc.co_cuenta,2,3)|| 
       substring(tc.co_cuenta,5)
       ||'000000' || '0000000' ||
       substring(replace(replace(to_char(tc.monto_cuota,'9999999999999999.99'), ' ', '0'),'.',''),5,15) ||
       to_char(current_date, 'yy') || to_char($2, 'mm') || '15'),
       ar.co_banco,        
       tc.monto_cuota
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta), 
     cobros.archivo ar 
where tc.co_cuota = (select min(tc2.co_cuota) from cobros.tmp_cuota tc2 where tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
and ti.co_dia_debito = $3 
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1);*/

insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,     
       trim('02'||'DB'||'00'||
       substring(tc.co_cuenta,2,3)|| 
       substring(tc.co_cuenta,5)
       ||'000000' || '0000000' ||
       substring(replace(replace(to_char(tc.monto_cuota,'9999999999999999.99'), ' ', '0'),'.',''),5,15) ||
       to_char($2, 'yy') || to_char($2, 'mm') || '15'),
       ar.co_banco,        
       tc.monto_cuota
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta)
     left outer join cobros.convenio co on (tc.co_cuenta = co.nu_cuenta), 
     cobros.archivo ar 
where tc.co_cuota = (select min(tc2.co_cuota) from cobros.tmp_cuota tc2 where tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
and ti.co_dia_debito = $3 
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
and co.nu_cuenta is null;



--INSERTA CUOTAS  CORRESPONDIENTES A CONVENIO DE PAGO

/*insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,     
       trim('02'||'DB'||'00'||substring(tc.co_cuenta,2,3)|| substring(tc.co_cuenta,5)||'000000' || '0000000' || 
       substring(replace(replace(to_char(tc.monto_cuota,'9999999999999999.99'), ' ', '0'),'.',''),5,15) ||
       to_char(current_date, 'yy') || to_char($2, 'mm') || '15'),
       ar.co_banco,       
       tc.monto_cuota
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta) join cobros.convenio co on (tc.co_cuenta = co.nu_cuenta),cobros.archivo ar
where tc.co_cuota = (select min(tc2.co_cuota) from cobros.tmp_cuota tc2 where tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
and ti.co_dia_debito = $3 
and current_date between co.fe_inicio and co.fe_fin
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1); */

insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,     
       trim('02'||'DB'||'00'||
       substring(tc.co_cuenta,2,3)|| 
       substring(tc.co_cuenta,5)
       ||'000000' || '0000000' ||
       substring(replace(replace(to_char(tc.monto_cuota,'9999999999999999.99'), ' ', '0'),'.',''),5,15) ||
       to_char($2, 'yy') || to_char($2, 'mm') || '15'),
       ar.co_banco,        
       tc.monto_cuota
from cobros.tmp_cuota tc join cobros.titular ti on (tc.co_cuenta = ti.nu_cuenta)
     join (select co.nu_cuenta,min(tc2.co_cuota) as menor_cuota,min(tc2.co_cuota) + co.nu_cantidad_cuotas as mayor_cuota  
           from cobros.tmp_cuota tc2 join cobros.convenio co on (tc2.co_cuenta = co.nu_cuenta) 
	   where tc2.valor_pago = 0  and tc2.co_cuenta in (select nu_cuenta from cobros.convenio co 
                                                           where $2 between co.fe_inicio and co.fe_fin )
           group by co.nu_cuenta, co.nu_cantidad_cuotas) as cuotas_convenio on (tc.co_cuenta =  cuotas_convenio.nu_cuenta), 	
     cobros.archivo ar 
where tc.co_cuota between cuotas_convenio.menor_cuota and cuotas_convenio.mayor_cuota
and ti.co_dia_debito = $3 
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1);

end;
$_$;


ALTER FUNCTION cobros.genera_datos_archivo_cobro(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying) OWNER TO cobros_apl;

--
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 230
-- Name: FUNCTION genera_datos_archivo_cobro(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying); Type: COMMENT; Schema: cobros; Owner: cobros_apl
--

COMMENT ON FUNCTION cobros.genera_datos_archivo_cobro(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying) IS 'procedimiento que genera los datos requeidos para la impresion del archivo de cobro';


--
-- TOC entry 231 (class 1255 OID 16387)
-- Name: genera_datos_archivo_cobro_bod(character varying, date, numeric, character varying); Type: FUNCTION; Schema: cobros; Owner: cobros_apl
--

CREATE FUNCTION cobros.genera_datos_archivo_cobro_bod(co_banco character varying DEFAULT '0116'::character varying, fe_cobro date DEFAULT ('now'::text)::date, co_frecuencia_pago numeric DEFAULT 0, nu_cuenta_abadia character varying DEFAULT 'XXXXXXXXXXXXXXXX'::character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare
  total_cuotas numeric; --ACUMULADOR DE MONTO TOTAL DE CUOTAS SIN CONVENIO
  total_convenios numeric; --ACUMULADOR DE MONTO TOTAL DE CUOTAS CON CONVENIO
begin

--CREA REGISTRO IDENTICADOR DE ARCHIVO
insert into cobros.archivo(co_banco,fe_cobro) values($1,$2);

--OBTIENE EL MONTO TOTAL DE CUOTAS PARA SER INCLUIDO EN EL REGISTRO RESUMEN
select sum(tc.monto_cuota) into total_cuotas
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta)
     left outer join cobros.convenio co on (tc.co_cuenta = co.nu_cuenta), 
     cobros.archivo ar 
--where tc.co_cuota = (select min(tc2.co_cuota) from cobros.tmp_cuota tc2 where tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
where tc.co_cuota = (select tc2.co_cuota from cobros.tmp_cuota tc2 where tc2.fe_cobro = to_char($2,'dd-mm-yyyy') and tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
and ti.co_dia_debito = $3 
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
and co.nu_cuenta is null;


--OBTIENE EL MONTO TOTAL DE CONVENIOS PARA SER INCLUIDO EN EL REGISTRO RESUMEN
select sum(tc.monto_cuota) into total_convenios   
from cobros.tmp_cuota tc join cobros.titular ti on (tc.co_cuenta = ti.nu_cuenta)
     join (select co.nu_cuenta,min(tc2.co_cuota) as menor_cuota,min(tc2.co_cuota) + co.nu_cantidad_cuotas as mayor_cuota  
           from cobros.tmp_cuota tc2 join cobros.convenio co on (tc2.co_cuenta = co.nu_cuenta) 
	   where tc2.valor_pago = 0  and tc2.co_cuenta in (select nu_cuenta from cobros.convenio co 
                                                           where $2 between co.fe_inicio and co.fe_fin )
           group by co.nu_cuenta, co.nu_cantidad_cuotas) as cuotas_convenio on (tc.co_cuenta =  cuotas_convenio.nu_cuenta), 	
     cobros.archivo ar 
where tc.co_cuota between cuotas_convenio.menor_cuota and cuotas_convenio.mayor_cuota
and ti.co_dia_debito = $3 
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1);



--INICIA SECUENCIA DE NUMERACION PARA LOS REGISTROS DEL ARCHIVO (DETALLE)
ALTER SEQUENCE cobros.archivo_detalle_nu_regstro_seq RESTART WITH 1;

--INSERTA REGISTRO RESUMEN 
insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,
       --row_number() over(order by ar.co_archivo),
       trim('02'||'DB'||'00'||        
       substring(tc.co_cuenta,2,3) || 
       $4  || --numero de cuenta abadia
       '000000' || '0000000' ||
       substring(replace(replace(to_char((total_cuotas + total_convenios),'9999999999999999.99'), ' ', '0'),'.',''),5,15)||
       to_char($2, 'yy') || to_char($2, 'mm') || to_char($2, 'dd')),
       ar.co_banco,        
       total_cuotas + total_convenios
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta),cobros.archivo ar
--where tc.co_cuota = (select min(tc2.co_cuota) from cobros.tmp_cuota tc2 where tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
where tc.co_cuota = (select tc2.co_cuota from cobros.tmp_cuota tc2 where tc2.fe_cobro = to_char($2,'dd-mm-yyyy') and tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
and ti.co_dia_debito = $3
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
group by ar.co_archivo,substring(tc.co_cuenta,2,3),ar.co_banco;

--INSERTA CUOTAS CORRESPONDIENTES, EXCLUYENDO CUENTAS CON CONVENIOS

insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,     
       trim('02'||'DB'||'00'||
       substring(tc.co_cuenta,2,3)|| 
       substring(tc.co_cuenta,5)
       ||'000000' || '0000000' ||
       substring(replace(replace(to_char(tc.monto_cuota,'9999999999999999.99'), ' ', '0'),'.',''),5,15) ||
       to_char($2, 'yy') || to_char($2, 'mm') ||  to_char($2, 'dd')),
       ar.co_banco,        
       tc.monto_cuota
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta)
     left outer join cobros.convenio co on (tc.co_cuenta = co.nu_cuenta), 
     cobros.archivo ar 
--where tc.co_cuota = (select min(tc2.co_cuota) from cobros.tmp_cuota tc2 where tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
where tc.co_cuota = (select tc2.co_cuota from cobros.tmp_cuota tc2 where tc2.fe_cobro = to_char($2,'dd-mm-yyyy') and tc2.valor_pago = 0  and tc2.co_cuenta = tc.co_cuenta) 
and ti.co_dia_debito = $3 
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
and co.nu_cuenta is null;


--INSERTA CUOTAS  CORRESPONDIENTES A CONVENIO DE PAGO

insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,     
       trim('02'||'DB'||'00'||
       substring(tc.co_cuenta,2,3)|| 
       substring(tc.co_cuenta,5)
       ||'000000' || '0000000' ||
       substring(replace(replace(to_char(tc.monto_cuota,'9999999999999999.99'), ' ', '0'),'.',''),5,15) ||
       to_char($2, 'yy') || to_char($2, 'mm') || '15'),
       ar.co_banco,        
       tc.monto_cuota
from cobros.tmp_cuota tc join cobros.titular ti on (tc.co_cuenta = ti.nu_cuenta)
     join (select co.nu_cuenta,min(tc2.co_cuota) as menor_cuota,min(tc2.co_cuota) + co.nu_cantidad_cuotas as mayor_cuota  
           from cobros.tmp_cuota tc2 join cobros.convenio co on (tc2.co_cuenta = co.nu_cuenta) 
	   where tc2.valor_pago = 0  and tc2.co_cuenta in (select nu_cuenta from cobros.convenio co 
                                                           where $2 between co.fe_inicio and co.fe_fin )
           group by co.nu_cuenta, co.nu_cantidad_cuotas) as cuotas_convenio on (tc.co_cuenta =  cuotas_convenio.nu_cuenta), 	
     cobros.archivo ar 
where tc.co_cuota between cuotas_convenio.menor_cuota and cuotas_convenio.mayor_cuota
and ti.co_dia_debito = $3 
and substring(tc.co_cuenta,1,4) = $1
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1);

end;
$_$;


ALTER FUNCTION cobros.genera_datos_archivo_cobro_bod(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying) OWNER TO cobros_apl;

--
-- TOC entry 3075 (class 0 OID 0)
-- Dependencies: 231
-- Name: FUNCTION genera_datos_archivo_cobro_bod(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying); Type: COMMENT; Schema: cobros; Owner: cobros_apl
--

COMMENT ON FUNCTION cobros.genera_datos_archivo_cobro_bod(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying) IS 'procedimiento que genera los datos requeidos para la impresion del archivo de cobro del banco bod';


--
-- TOC entry 232 (class 1255 OID 65774)
-- Name: genera_datos_archivo_cobro_bod(character varying, date, date, numeric, character varying); Type: FUNCTION; Schema: cobros; Owner: postgres
--

CREATE FUNCTION cobros.genera_datos_archivo_cobro_bod(co_banco character varying DEFAULT '0116'::character varying, fe_cobro date DEFAULT ('now'::text)::date, fe_envio date DEFAULT ('now'::text)::date, co_frecuencia_pago numeric DEFAULT 0, nu_cuenta_abadia character varying DEFAULT 'XXXXXXXXXXXXXX'::character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare
  total_cuotas        numeric; --ACUMULADOR DE MONTO TOTAL DE CUOTAS SIN CONVENIO
  total_convenios     numeric; --ACUMULADOR DE MONTO TOTAL DE CUOTAS CON CONVENIO
  registros_cuotas    numeric; --ACUMULADOR DE NUMEROS DE REGISTROS DE CUOTAS SIN CONVENIO
  registros_convenios numeric; --ACUMULADOR DE NUMEROS DE REGISTROS DE CUOTAS CON CONVENIO
  fe_ini_busq	      varchar; --FECHA DE INICIO PARA LA BUSQUEDA DE CUOTAS
  fe_fin_busq	      varchar; --FECHA DE INICIO PARA LA BUSQUEDA DE CUOTAS
  dia_cobro	      float; -- DIA DE COBRO
  --co_archivo	      integer;
begin

--CREA REGISTRO IDENTICADOR DE ARCHIVO
insert into cobros.archivo(co_banco,fe_cobro,fe_insert) values($1,$2,'now()');

--CONSTRUYE RANGO DE FECHA PARA LA BUSQUEDA DE CUOTAS
select extract(day from  to_date(to_char($2,'dd-mm-yyyy'),'dd-mm-yyyy')) into dia_cobro;

if dia_cobro <= 15 then
   fe_ini_busq := '01-'||to_char($2,'mm')||'-'||to_char($2,'yyyy');
   fe_fin_busq := '15-'||to_char($2,'mm')||'-'||to_char($2,'yyyy');
else
   fe_ini_busq := '16-'||to_char($2,'mm')||'-'||to_char($2,'yyyy');
   SELECT to_char( (date_trunc('MONTH', ($2)::date) + INTERVAL '1 MONTH - 1 day')::DATE ,'dd-mm-yyyy') into fe_fin_busq; 
end if;

--OBTIENE EL MONTO TOTAL DE CUOTAS PARA SER INCLUIDO EN EL REGISTRO RESUMEN
select sum(tc.monto_cuota), count(tc.co_cuota) into total_cuotas,registros_cuotas
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta)
	left outer join cobros.convenio co on (tc.co_cuenta = co.nu_cuenta),
	cobros.archivo ar 
where to_date(tc.fe_cobro,'dd-mm-yyyy') between to_date(fe_ini_busq,'dd-mm-yyyy') and to_date(fe_fin_busq,'dd-mm-yyyy')
and substring(tc.co_cuenta,1,4) = $1 and ti.co_dia_debito = $4 and tc.valor_pago = 0 
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
--and co.nu_cuenta is null;
and ti.nu_contrato not in (select nu_contrato from cobros.convenio co where $2 between co.fe_inicio and co.fe_fin);


--OBTIENE EL MONTO TOTAL DE CONVENIOS PARA SER INCLUIDO EN EL REGISTRO RESUMEN
select sum(totales.monto_cuota), count(totales.co_cuota) into total_convenios, registros_convenios
from(
     select co_cuota,co_cuenta, monto_cuota, tc.fe_cobro, ti.id_titular , ti.nu_contrato 
     from cobros.tmp_cuota tc join cobros.titular ti on (tc.co_cuenta = ti.nu_cuenta)
       join (select co.nu_contrato,co.nu_cuenta,min(tc2.co_cuota) as menor_cuota,min(tc2.co_cuota) + (co.nu_cantidad_cuotas-1) as mayor_cuota  
             from cobros.tmp_cuota tc2 join cobros.convenio co on (tc2.co_cuenta = co.nu_cuenta) 
	     where tc2.valor_pago = 0  and tc2.co_cuenta in (select nu_cuenta from cobros.convenio co 
                                                             where $2 between co.fe_inicio and co.fe_fin )
             group by co.nu_contrato,co.nu_cuenta, co.nu_cantidad_cuotas) as cuotas_convenio on (tc.co_cuenta =  cuotas_convenio.nu_cuenta), 	
       cobros.archivo ar 
     where tc.co_cuota between cuotas_convenio.menor_cuota and cuotas_convenio.mayor_cuota
     and ti.co_dia_debito = $4 and ti.nu_contrato = cuotas_convenio.nu_contrato
     and substring(tc.co_cuenta,1,4) = $1
     and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
     union all
     select co_cuota,co_cuenta, monto_cuota, tc.fe_cobro, ti.id_titular,ti.nu_contrato 
     from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta )
	left outer join cobros.convenio co on (tc.co_cuenta = co.nu_cuenta ),
	cobros.archivo ar 
     where to_date(tc.fe_cobro,'dd-mm-yyyy') between to_date(fe_ini_busq,'dd-mm-yyyy') and to_date(fe_fin_busq,'dd-mm-yyyy')
     and substring(tc.co_cuenta,1,4) = $1 and ti.co_dia_debito = $4 and tc.valor_pago = 0
     and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
     and ti.nu_contrato in (select nu_contrato from cobros.convenio co where $2 between co.fe_inicio and co.fe_fin )
    ) as totales;


--INICIA SECUENCIA DE NUMERACION PARA LOS REGISTROS DEL ARCHIVO (DETALLE)
ALTER SEQUENCE cobros.archivo_detalle_nu_regstro_seq RESTART WITH 1;

--INSERTA REGISTRO RESUMEN 
insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,
       --row_number() over(order by ar.co_archivo),
       '01'|| to_char($3, 'ddmmyyyy') || 
	substring(replace(replace(to_char((registros_cuotas + registros_convenios),'99999999'), ' ', '0'),'.',''),5,5)||
	substring(replace(replace(to_char((total_cuotas + total_convenios),'9999999999999999.99'), ' ', '0'),'.',''),5,15)||
        '0'|| $5 || --numero de cuenta abadia
        'CR' || '0000000000000000',
       ar.co_banco,        
       total_cuotas + total_convenios
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta),cobros.archivo ar
where to_date(tc.fe_cobro,'dd-mm-yyyy') between to_date(fe_ini_busq,'dd-mm-yyyy') and to_date(fe_fin_busq,'dd-mm-yyyy')
and substring(tc.co_cuenta,1,4) = $1 and ti.co_dia_debito = $4 and tc.valor_pago = 0 
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
group by ar.co_archivo,substring(tc.co_cuenta,2,3),ar.co_banco;

--INSERTA CUOTAS CORRESPONDIENTES, EXCLUYENDO CUENTAS CON CONVENIOS
insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
select ar.co_archivo,     
       trim('02'||'DB'||'00'||
       substring(tc.co_cuenta,2,3)|| 
       substring(tc.co_cuenta,5,16)||
       '00000000'||  --- NUMERO DE FACTURA
       '0000000' ||  -- DISPONIBLE
       substring(replace(replace(to_char(tc.monto_cuota,'9999999999999999.99'), ' ', '0'),'.',''),5,15) ||
       to_char($2, 'dd') || to_char($2, 'mm') ||  to_char($2, 'yy')),
       ar.co_banco,        
       tc.monto_cuota
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta)
     left outer join cobros.convenio co on (tc.co_cuenta = co.nu_cuenta), 
     cobros.archivo ar 
where to_date(tc.fe_cobro,'dd-mm-yyyy') between to_date(fe_ini_busq,'dd-mm-yyyy') and to_date(fe_fin_busq,'dd-mm-yyyy')
and substring(tc.co_cuenta,1,4) = $1 and ti.co_dia_debito = $4 and tc.valor_pago = 0 
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
--and co.nu_cuenta is null;
and ti.nu_contrato not in (select nu_contrato from cobros.convenio co where $2 between co.fe_inicio and co.fe_fin);


--INSERTA CUOTAS  CORRESPONDIENTES A CONVENIO DE PAGO
insert into cobros.archivo_detalle(co_archivo,tx_registro_cobro,co_banco,monto_cuota)
   select ar.co_archivo,     
       trim('02'||'DB'||'00'||
       substring(tc.co_cuenta,2,3)|| 
       substring(tc.co_cuenta,5,16)||
       '00000000'||  --- NUMERO DE FACTURA
       '0000000' ||  -- DISPONIBLE
       substring(replace(replace(to_char(tc.monto_cuota,'9999999999999999.99'), ' ', '0'),'.',''),5,15) ||
       to_char($2, 'dd') || to_char($2, 'mm') ||  to_char($2, 'yy')),
       ar.co_banco,        
       tc.monto_cuota
   from cobros.tmp_cuota tc join cobros.titular ti on (tc.co_cuenta = ti.nu_cuenta)
       join (select co.nu_contrato,co.nu_cuenta,min(tc2.co_cuota) as menor_cuota,min(tc2.co_cuota) + (co.nu_cantidad_cuotas-1) as mayor_cuota  
             from cobros.tmp_cuota tc2 join cobros.convenio co on (tc2.co_cuenta = co.nu_cuenta) 
	     where tc2.valor_pago = 0  and tc2.co_cuenta in (select nu_cuenta from cobros.convenio co 
                                                             where $2 between co.fe_inicio and co.fe_fin )
             group by co.nu_contrato,co.nu_cuenta, co.nu_cantidad_cuotas) as cuotas_convenio on (tc.co_cuenta =  cuotas_convenio.nu_cuenta), 	
       cobros.archivo ar 
   where tc.co_cuota between cuotas_convenio.menor_cuota and cuotas_convenio.mayor_cuota
     and ti.co_dia_debito = $4 and ti.nu_contrato = cuotas_convenio.nu_contrato
     and substring(tc.co_cuenta,1,4) = $1
     and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
   union all
   select ar.co_archivo,     
       trim('02'||'DB'||'00'||
       substring(tc.co_cuenta,2,3)|| 
       substring(tc.co_cuenta,5,16)||
       '00000000'||  --- NUMERO DE FACTURA
       '0000000' ||  -- DISPONIBLE
       substring(replace(replace(to_char(tc.monto_cuota,'9999999999999999.99'), ' ', '0'),'.',''),5,15) ||
       to_char($2, 'dd') || to_char($2, 'mm') ||  to_char($2, 'yy')),
       ar.co_banco,        
       tc.monto_cuota
   from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta )
	left outer join cobros.convenio co on (tc.co_cuenta = co.nu_cuenta ),
	cobros.archivo ar 
   where to_date(tc.fe_cobro,'dd-mm-yyyy') between to_date(fe_ini_busq,'dd-mm-yyyy') and to_date(fe_fin_busq,'dd-mm-yyyy')
     and substring(tc.co_cuenta,1,4) = $1 and ti.co_dia_debito = $4 and tc.valor_pago = 0
     and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
     and ti.nu_contrato in (select nu_contrato from cobros.convenio co where $2 between co.fe_inicio and co.fe_fin);

--select co_archivo into co_archivo from cobros.archivo where co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1);
--return (co_archivo);
end;
$_$;


ALTER FUNCTION cobros.genera_datos_archivo_cobro_bod(co_banco character varying, fe_cobro date, fe_envio date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying) OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 16388)
-- Name: archivo_co_archivo_seq; Type: SEQUENCE; Schema: cobros; Owner: cobros
--

CREATE SEQUENCE cobros.archivo_co_archivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cobros.archivo_co_archivo_seq OWNER TO cobros;

SET default_tablespace = '';

--
-- TOC entry 198 (class 1259 OID 16390)
-- Name: archivo; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.archivo (
    co_archivo integer DEFAULT nextval('cobros.archivo_co_archivo_seq'::regclass) NOT NULL,
    co_banco character varying(4) NOT NULL,
    fe_cobro date NOT NULL,
    fe_insert date
);


ALTER TABLE cobros.archivo OWNER TO cobros;

--
-- TOC entry 199 (class 1259 OID 16394)
-- Name: archivo_detalle_nu_regstro_seq; Type: SEQUENCE; Schema: cobros; Owner: cobros_apl
--

CREATE SEQUENCE cobros.archivo_detalle_nu_regstro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1;


ALTER TABLE cobros.archivo_detalle_nu_regstro_seq OWNER TO cobros_apl;

--
-- TOC entry 200 (class 1259 OID 16396)
-- Name: archivo_detalle; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.archivo_detalle (
    co_archivo integer NOT NULL,
    nu_registro integer DEFAULT nextval('cobros.archivo_detalle_nu_regstro_seq'::regclass) NOT NULL,
    tx_registro_cobro character varying(100),
    co_banco character varying(4),
    monto_cuota numeric(18,2)
);


ALTER TABLE cobros.archivo_detalle OWNER TO cobros;

--
-- TOC entry 201 (class 1259 OID 16400)
-- Name: archivo_estructura; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.archivo_estructura (
    co_banco character varying(4) NOT NULL,
    co_campo integer NOT NULL,
    nu_orden_campo integer NOT NULL,
    nu_longitud_campo integer NOT NULL,
    tx_descripcion character varying(50) NOT NULL,
    tx_valor_defecto character varying(20)
);


ALTER TABLE cobros.archivo_estructura OWNER TO cobros;

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
-- TOC entry 203 (class 1259 OID 16407)
-- Name: convenio_co_convenio_seq; Type: SEQUENCE; Schema: cobros; Owner: cobros_apl
--

CREATE SEQUENCE cobros.convenio_co_convenio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999
    CACHE 1;


ALTER TABLE cobros.convenio_co_convenio_seq OWNER TO cobros_apl;

--
-- TOC entry 204 (class 1259 OID 16409)
-- Name: convenio; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.convenio (
    co_convenio integer DEFAULT nextval('cobros.convenio_co_convenio_seq'::regclass) NOT NULL,
    nu_cuenta character varying(20) NOT NULL,
    nu_monto_deuda integer NOT NULL,
    nu_cantidad_cuotas integer NOT NULL,
    fe_inicio date NOT NULL,
    fe_fin date,
    co_accion numeric(1,0) DEFAULT 1 NOT NULL,
    nu_contrato character varying(60)
);


ALTER TABLE cobros.convenio OWNER TO cobros;

--
-- TOC entry 3082 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN convenio.co_accion; Type: COMMENT; Schema: cobros; Owner: cobros
--

COMMENT ON COLUMN cobros.convenio.co_accion IS 'define la accion a acometer en el convenio, 1=cobrar, 2=no cobrar';


--
-- TOC entry 205 (class 1259 OID 16414)
-- Name: cuenta; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.cuenta (
    co_cuenta character varying(20) NOT NULL,
    co_banco character varying(4) NOT NULL,
    id_titular character varying(15)
);


ALTER TABLE cobros.cuenta OWNER TO cobros;

--
-- TOC entry 206 (class 1259 OID 16417)
-- Name: cuota; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.cuota (
    co_cuota integer NOT NULL,
    co_banco character varying(4) NOT NULL,
    co_cuenta character varying(20) NOT NULL,
    fe_cobro date NOT NULL,
    tipo_pago numeric NOT NULL,
    monto_cuota numeric(16,2)
);


ALTER TABLE cobros.cuota OWNER TO cobros;

--
-- TOC entry 207 (class 1259 OID 16423)
-- Name: cuota_co_cuota_seq; Type: SEQUENCE; Schema: cobros; Owner: cobros
--

CREATE SEQUENCE cobros.cuota_co_cuota_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cobros.cuota_co_cuota_seq OWNER TO cobros;

--
-- TOC entry 208 (class 1259 OID 16425)
-- Name: cuota_convenio; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.cuota_convenio (
    co_cuota_convenio integer NOT NULL,
    co_convenio integer NOT NULL,
    monto_cuota character varying(20) NOT NULL,
    co_banco character varying(4) NOT NULL,
    co_cuenta character varying(20) NOT NULL,
    fe_cobro timestamp without time zone NOT NULL,
    in_cobrada boolean
);


ALTER TABLE cobros.cuota_convenio OWNER TO cobros;

--
-- TOC entry 209 (class 1259 OID 16428)
-- Name: dia_debito; Type: TABLE; Schema: cobros; Owner: cobros_apl
--

CREATE TABLE cobros.dia_debito (
    co_dia_debito numeric(1,0) NOT NULL,
    de_dia_debito character varying(50) NOT NULL,
    in_activo boolean DEFAULT true
);


ALTER TABLE cobros.dia_debito OWNER TO cobros_apl;

--
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE dia_debito; Type: COMMENT; Schema: cobros; Owner: cobros_apl
--

COMMENT ON TABLE cobros.dia_debito IS 'frecuencia de cobros para generar cuotas';


--
-- TOC entry 210 (class 1259 OID 16432)
-- Name: titular; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.titular (
    id_titular character varying(15) NOT NULL,
    nombre_titular character varying(60) NOT NULL,
    nu_contrato character varying(10) NOT NULL,
    nu_cuenta character varying(20) NOT NULL,
    co_dia_debito numeric(5,0) DEFAULT 0,
    co_estado_contrato numeric(1,0),
    fe_ingreso_contrato character varying(10)
);


ALTER TABLE cobros.titular OWNER TO cobros;

--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN titular.nu_cuenta; Type: COMMENT; Schema: cobros; Owner: cobros
--

COMMENT ON COLUMN cobros.titular.nu_cuenta IS 'número de cuenta del titular';


--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN titular.co_dia_debito; Type: COMMENT; Schema: cobros; Owner: cobros
--

COMMENT ON COLUMN cobros.titular.co_dia_debito IS '0 15 y 30 de cada mes
1 13 y 27 de cada mes
2 10 y 25 de cada mes
3 8 y  22 de cada mes
4 semanal
5 mensual';


--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN titular.co_estado_contrato; Type: COMMENT; Schema: cobros; Owner: cobros
--

COMMENT ON COLUMN cobros.titular.co_estado_contrato IS 'Indica si el contrato esa activo (1) o inactivo (2)';


--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN titular.fe_ingreso_contrato; Type: COMMENT; Schema: cobros; Owner: cobros
--

COMMENT ON COLUMN cobros.titular.fe_ingreso_contrato IS 'Fecha de creación del contrato';


--
-- TOC entry 211 (class 1259 OID 16436)
-- Name: titular_co_titular_seq; Type: SEQUENCE; Schema: cobros; Owner: cobros
--

CREATE SEQUENCE cobros.titular_co_titular_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1;


ALTER TABLE cobros.titular_co_titular_seq OWNER TO cobros;

--
-- TOC entry 212 (class 1259 OID 16438)
-- Name: tmp_cuota; Type: TABLE; Schema: cobros; Owner: cobros
--

CREATE TABLE cobros.tmp_cuota (
    co_cuota numeric(4,0) NOT NULL,
    co_cuenta character varying(20) NOT NULL,
    valor_pago numeric(18,2),
    tipo_pago character varying(1) NOT NULL,
    monto_cuota numeric(18,2),
    fe_cobro character varying(10),
    fe_updat character varying(20),
    fe_delete character varying(20),
    fe_insert character varying(20)
);


ALTER TABLE cobros.tmp_cuota OWNER TO cobros;

--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN tmp_cuota.fe_cobro; Type: COMMENT; Schema: cobros; Owner: cobros
--

COMMENT ON COLUMN cobros.tmp_cuota.fe_cobro IS 'Campo con fecha propuesta de cobro, requerido para la generación del archivo de cobro del BOD';


--
-- TOC entry 2909 (class 2606 OID 24806)
-- Name: archivo pk_archivo; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.archivo
    ADD CONSTRAINT pk_archivo PRIMARY KEY (co_archivo);


--
-- TOC entry 2911 (class 2606 OID 24808)
-- Name: archivo_detalle pk_archivo_detalle; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.archivo_detalle
    ADD CONSTRAINT pk_archivo_detalle PRIMARY KEY (co_archivo, nu_registro);


--
-- TOC entry 2913 (class 2606 OID 16473)
-- Name: archivo_estructura pk_archivo_estructura; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.archivo_estructura
    ADD CONSTRAINT pk_archivo_estructura PRIMARY KEY (co_banco, co_campo);


--
-- TOC entry 2915 (class 2606 OID 24812)
-- Name: banco pk_banco; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.banco
    ADD CONSTRAINT pk_banco PRIMARY KEY (co_banco);


--
-- TOC entry 2918 (class 2606 OID 24804)
-- Name: convenio pk_convenio; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.convenio
    ADD CONSTRAINT pk_convenio PRIMARY KEY (co_convenio);


--
-- TOC entry 2921 (class 2606 OID 16479)
-- Name: cuenta pk_cuenta; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.cuenta
    ADD CONSTRAINT pk_cuenta PRIMARY KEY (co_cuenta);


--
-- TOC entry 2925 (class 2606 OID 16481)
-- Name: cuota pk_cuota; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.cuota
    ADD CONSTRAINT pk_cuota PRIMARY KEY (co_cuota, co_cuenta);


--
-- TOC entry 2930 (class 2606 OID 16483)
-- Name: cuota_convenio pk_cuota_convenio; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.cuota_convenio
    ADD CONSTRAINT pk_cuota_convenio PRIMARY KEY (co_cuota_convenio);


--
-- TOC entry 2932 (class 2606 OID 24814)
-- Name: dia_debito pk_dia_debito; Type: CONSTRAINT; Schema: cobros; Owner: cobros_apl
--

ALTER TABLE ONLY cobros.dia_debito
    ADD CONSTRAINT pk_dia_debito PRIMARY KEY (co_dia_debito);


--
-- TOC entry 2934 (class 2606 OID 24820)
-- Name: titular pk_titular; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.titular
    ADD CONSTRAINT pk_titular PRIMARY KEY (id_titular, nu_contrato, nu_cuenta);


--
-- TOC entry 2937 (class 2606 OID 33067)
-- Name: tmp_cuota pk_tmp_cuota; Type: CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.tmp_cuota
    ADD CONSTRAINT pk_tmp_cuota PRIMARY KEY (co_cuota, co_cuenta);


--
-- TOC entry 2916 (class 1259 OID 33016)
-- Name: fki_convenio_cuenta; Type: INDEX; Schema: cobros; Owner: cobros
--

CREATE INDEX fki_convenio_cuenta ON cobros.convenio USING btree (nu_cuenta);


--
-- TOC entry 2919 (class 1259 OID 33010)
-- Name: fki_cuenta_banco; Type: INDEX; Schema: cobros; Owner: cobros
--

CREATE INDEX fki_cuenta_banco ON cobros.cuenta USING btree (co_banco);


--
-- TOC entry 2922 (class 1259 OID 32998)
-- Name: fki_cuota_banco; Type: INDEX; Schema: cobros; Owner: cobros
--

CREATE INDEX fki_cuota_banco ON cobros.cuota USING btree (co_banco);


--
-- TOC entry 2923 (class 1259 OID 33004)
-- Name: fki_cuota_cuenta; Type: INDEX; Schema: cobros; Owner: cobros
--

CREATE INDEX fki_cuota_cuenta ON cobros.cuota USING btree (co_cuenta);


--
-- TOC entry 2926 (class 1259 OID 33028)
-- Name: fki_cuotaconvenio_banco; Type: INDEX; Schema: cobros; Owner: cobros
--

CREATE INDEX fki_cuotaconvenio_banco ON cobros.cuota_convenio USING btree (co_banco);


--
-- TOC entry 2927 (class 1259 OID 33022)
-- Name: fki_cuotaconvenio_convenio; Type: INDEX; Schema: cobros; Owner: cobros
--

CREATE INDEX fki_cuotaconvenio_convenio ON cobros.cuota_convenio USING btree (co_convenio);


--
-- TOC entry 2928 (class 1259 OID 33034)
-- Name: fki_cuotaconvenio_cuenta; Type: INDEX; Schema: cobros; Owner: cobros
--

CREATE INDEX fki_cuotaconvenio_cuenta ON cobros.cuota_convenio USING btree (co_cuenta);


--
-- TOC entry 2935 (class 1259 OID 16490)
-- Name: i_tmp_cuota_co_cuenta; Type: INDEX; Schema: cobros; Owner: cobros
--

CREATE INDEX i_tmp_cuota_co_cuenta ON cobros.tmp_cuota USING btree (co_cuenta);


--
-- TOC entry 2945 (class 2606 OID 65816)
-- Name: cuota_convenio cuotaconvenio_cuenta; Type: FK CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.cuota_convenio
    ADD CONSTRAINT cuotaconvenio_cuenta FOREIGN KEY (co_cuenta) REFERENCES cobros.cuenta(co_cuenta);


--
-- TOC entry 2939 (class 2606 OID 65831)
-- Name: archivo_detalle fk_archivodetalle_archivo; Type: FK CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.archivo_detalle
    ADD CONSTRAINT fk_archivodetalle_archivo FOREIGN KEY (co_archivo) REFERENCES cobros.archivo(co_archivo) MATCH FULL;


--
-- TOC entry 2938 (class 2606 OID 33118)
-- Name: archivo_detalle fk_archivodetalle_banco; Type: FK CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.archivo_detalle
    ADD CONSTRAINT fk_archivodetalle_banco FOREIGN KEY (co_banco) REFERENCES cobros.banco(co_banco) MATCH FULL;


--
-- TOC entry 2940 (class 2606 OID 65801)
-- Name: cuenta fk_cuenta_banco; Type: FK CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.cuenta
    ADD CONSTRAINT fk_cuenta_banco FOREIGN KEY (co_banco) REFERENCES cobros.banco(co_banco) MATCH FULL;


--
-- TOC entry 2941 (class 2606 OID 65821)
-- Name: cuota fk_cuota_banco; Type: FK CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.cuota
    ADD CONSTRAINT fk_cuota_banco FOREIGN KEY (co_banco) REFERENCES cobros.banco(co_banco) MATCH FULL;


--
-- TOC entry 2942 (class 2606 OID 65826)
-- Name: cuota fk_cuota_cuenta; Type: FK CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.cuota
    ADD CONSTRAINT fk_cuota_cuenta FOREIGN KEY (co_cuenta) REFERENCES cobros.cuenta(co_cuenta) MATCH FULL;


--
-- TOC entry 2944 (class 2606 OID 65811)
-- Name: cuota_convenio fk_cuotaconvenio_banco; Type: FK CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.cuota_convenio
    ADD CONSTRAINT fk_cuotaconvenio_banco FOREIGN KEY (co_banco) REFERENCES cobros.banco(co_banco) MATCH FULL;


--
-- TOC entry 2943 (class 2606 OID 65806)
-- Name: cuota_convenio fk_cuotaconvenio_convenio; Type: FK CONSTRAINT; Schema: cobros; Owner: cobros
--

ALTER TABLE ONLY cobros.cuota_convenio
    ADD CONSTRAINT fk_cuotaconvenio_convenio FOREIGN KEY (co_convenio) REFERENCES cobros.convenio(co_convenio) MATCH FULL;


--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA cobros; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA cobros TO PUBLIC;


--
-- TOC entry 3074 (class 0 OID 0)
-- Dependencies: 230
-- Name: FUNCTION genera_datos_archivo_cobro(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying); Type: ACL; Schema: cobros; Owner: cobros_apl
--

REVOKE ALL ON FUNCTION cobros.genera_datos_archivo_cobro(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying) FROM PUBLIC;


--
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 231
-- Name: FUNCTION genera_datos_archivo_cobro_bod(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying); Type: ACL; Schema: cobros; Owner: cobros_apl
--

REVOKE ALL ON FUNCTION cobros.genera_datos_archivo_cobro_bod(co_banco character varying, fe_cobro date, co_frecuencia_pago numeric, nu_cuenta_abadia character varying) FROM PUBLIC;


--
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 197
-- Name: SEQUENCE archivo_co_archivo_seq; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON SEQUENCE cobros.archivo_co_archivo_seq TO cobros_apl;


--
-- TOC entry 3078 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE archivo; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.archivo TO cobros_apl;


--
-- TOC entry 3079 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE archivo_detalle; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.archivo_detalle TO cobros_apl;


--
-- TOC entry 3080 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE archivo_estructura; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.archivo_estructura TO cobros_apl;


--
-- TOC entry 3081 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE banco; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.banco TO cobros_apl;


--
-- TOC entry 3083 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE convenio; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.convenio TO cobros_apl;


--
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN convenio.co_convenio; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT SELECT(co_convenio),INSERT(co_convenio),UPDATE(co_convenio) ON TABLE cobros.convenio TO cobros_apl;


--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE cuenta; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.cuenta TO cobros_apl;


--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE cuota; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.cuota TO cobros_apl;


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 207
-- Name: SEQUENCE cuota_co_cuota_seq; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON SEQUENCE cobros.cuota_co_cuota_seq TO cobros_apl;


--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE cuota_convenio; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.cuota_convenio TO cobros_apl;


--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE titular; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.titular TO cobros_apl;


--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 211
-- Name: SEQUENCE titular_co_titular_seq; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON SEQUENCE cobros.titular_co_titular_seq TO cobros_apl;


--
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE tmp_cuota; Type: ACL; Schema: cobros; Owner: cobros
--

GRANT ALL ON TABLE cobros.tmp_cuota TO cobros_apl;


--
-- TOC entry 1741 (class 826 OID 16577)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: cobros; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA cobros REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA cobros GRANT SELECT,INSERT,DELETE,TRIGGER,UPDATE ON TABLES  TO cobros_apl;


-- Completed on 2020-04-05 17:27:49 -03

--
-- PostgreSQL database dump complete
--

