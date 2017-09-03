

set serveroutput on
set lines 200 long 990099 pages 999
cl scr
spool c:\mview.log

begin

for x in (SELECT owner, object_name, object_type, dbms_metadata.get_ddl(replace(OBJECT_TYPE, ' ', '_'), OBJECT_NAME,OWNER) metadata FROM DBA_OBJECTS
 WHERE OBJECT_TYPE = 'MATERIALIZED VIEW'
 and object_name in ('GA_PROPRIETARIO','GA_CLASSE_FUN','GA_EMPR','GA_SAFRAS','GA_EMPREIT','GA_ROTA','GA_CONF_CPC','GA_TURNO_TRABALHO','GA_ESTAG_USINA','GA_FRE_PS_EQP','GA_TEMP_MEDIA_PRA','GA_VARIE_USINA','GA_FRENT_TRABA','GA_FUNCIONARIO','GA_CARAC_CANA','GA_ESTIM_DIVI4','GA_CPMIS_SUBCL_EQUIP','GA_VARIE_DIVI4','GA_DIVI1','GA_DIVI3','GA_CONF_CLASSEBAL_EQUIP','GA_ROTA_CANA','GA_DIVI4','GA_FRE_PS_FUNC','GA_PONTO_DESCA','GA_TIPO_CORTE','GA_ESTIM_AGRUP','GA_CPMIS_CLAS_EQUIP','GA_LIBERACAO','GA_AREA_LIBER','GA_TABGR_PROP_EQUIP','GA_AGREG_TP_CORTE','GA_FUNDO_AGRIC')) loop

 dbms_output.put_line('OWNER:............... '||x.owner);
 dbms_output.put_line('OBJECT NAME:......... '||x.object_name);
 dbms_output.put_line('OBJECT TYPE:......... '||x.object_type);
 dbms_output.put_line('DDL: ');
 dbms_output.put_line(x.metadata);
 

end loop;

end;
/

spool off;

