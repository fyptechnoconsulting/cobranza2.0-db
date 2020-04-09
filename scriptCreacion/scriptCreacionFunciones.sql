-- FUNCTION: cobros.genera_datos_archivo_cobro_bod(character varying, date, date, numeric, character varying)

-- DROP FUNCTION cobros.genera_datos_archivo_cobro_bod(character varying, date, date, numeric, character varying);

CREATE OR REPLACE FUNCTION cobros.genera_datos_archivo_cobro_bod(
	co_banco character varying DEFAULT '0116'::character varying,
	fe_cobro date DEFAULT (
	'now'::text)::date,
	fe_envio date DEFAULT (
	'now'::text)::date,
	co_frecuencia_pago numeric DEFAULT 0,
	nu_cuenta_abadia character varying DEFAULT 'XXXXXXXXXXXXXX'::character varying)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
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
select (CASE WHEN sum(tc.monto_cuota) is null THEN 0
        ELSE sum(tc.monto_cuota) END), count(tc.co_cuota)  into total_cuotas, registros_cuotas
from cobros.tmp_cuota tc join cobros.titular ti on (co_cuenta = nu_cuenta)
	left outer join cobros.convenio co on (tc.co_cuenta = co.nu_cuenta),
	cobros.archivo ar 
where to_date(tc.fe_cobro,'dd-mm-yyyy') between to_date(fe_ini_busq,'dd-mm-yyyy') and to_date(fe_fin_busq,'dd-mm-yyyy')
and substring(tc.co_cuenta,1,4) = $1 and ti.co_dia_debito = $4 and tc.valor_pago = 0 
and ar.co_archivo = (select max(ar2.co_archivo) from cobros.archivo ar2 where ar2.co_banco = $1)
--and co.nu_cuenta is null;
and ti.nu_contrato not in (select nu_contrato from cobros.convenio co where $2 between co.fe_inicio and co.fe_fin);

--OBTIENE EL MONTO TOTAL DE CONVENIOS PARA SER INCLUIDO EN EL REGISTRO RESUMEN
select (CASE WHEN sum(totales.monto_cuota) is null THEN 0
        ELSE sum(totales.monto_cuota) END), count(totales.co_cuota) into total_convenios, registros_convenios
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
$BODY$;

ALTER FUNCTION cobros.genera_datos_archivo_cobro_bod(character varying, date, date, numeric, character varying)
    OWNER TO postgres;
