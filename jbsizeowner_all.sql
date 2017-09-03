#-- -----------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer usuario(s) e seu tamanho
#-- Nome do arquivo     : jbsizeowner_all.sql
#-- Data de criação     : 15/07/2014
#-- Data de atualização : 27/08/2014
#-- -----------------------------------------------------------------------------------------#
#-- http://www.idevelopment.info/data/Oracle/DBA_tips/Database_Administration/DBA_26.shtml

#--------------------------------------------------------------------------------------------#
#- TRAZER TODOS USUARIOS COM SEU TAMANHO ----------------------------------------------------#
#--------------------------------------------------------------------------------------------#


set serveroutput on
set feedback off

declare
	JBQB VARCHAR2(2) := CHR(13) || CHR(10);
	v_size varchar2(90);
	v_sum varchar2(20);
	v_owner varchar2(50);
	v_instance varchar2(20);
begin

	dbms_output.put_line(JBQB||JBQB||JBQB);

	select instance_name into v_instance from v$instance;
	dbms_output.put_line('NOME DA INSTANCIA:......................... ' || upper(v_instance));

	for x in (SELECT OWNER, SUM(BYTES) sum FROM DBA_SEGMENTS WHERE
		OWNER NOT IN ('SYS','SYSTEM','OUTLN','SCOTT','ANONYMOUS','AURORA$ORB$UNAUTHENTICATED','AWR_STAGE','CSMIG','CTXSYS','DBSNMP','DIP','DMSYS','DSSYS','EXFSYS','LBACSYS','MDSYS','ORACLE_OCM','ORDPLUGINS','ORDSYS','TRACESVR','TSMSYS','XDB','SYSMAN','WKSYS','WKPROXY','OLAPSYS','OWBSYS','MGMT_VIEW','SI_INFORMTN_SCHEMA','WMSYS')
		GROUP BY OWNER order by sum desc) loop

		v_sum:=x.sum;
		v_owner:=x.owner;


		dbms_output.put_line('NOME DO USUARIO:........... ' || v_owner);

		v_size:=substr(v_sum /1024/1024/1024,1,(INSTR(v_sum /1024/1024/1024,'.'))-1); v_size:=rtrim( ltrim( v_size ) );

		if v_size = '' or v_size is null then
			v_size:=v_sum /1024/1024/1024;
		end if;

		if v_size >= 1 then
			v_size:=substr(v_sum /1024/1024/1024,1,(INSTR(v_sum /1024/1024/1024,'.'))+3);
			select replace(v_size,'.',',') into v_size from dual;
			dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_size || ' GB' || JBQB );

		else
			v_size:=substr(v_sum /1024/1024,1,(INSTR(v_sum /1024/1024,'.'))-1); v_size:=rtrim( ltrim( v_size ) );

			if v_size = '' or v_size is null then
				v_size:=v_sum /1024/1024;
			end if;

			if v_size >= 1 then
				select replace(v_size,'.',',') into v_size from dual;
				dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_size || ' MB' || JBQB);

			else
				v_size:=substr(v_sum /1024,1,(INSTR(v_sum /1024,'.'))-1); v_size:=rtrim( ltrim( v_size ) );

				if v_size = '' or v_size is null then
					v_size:=v_sum /1024;
				end if;

				if v_size >= 1 then
					dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_size || ' KB' || JBQB);
				else
					dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_sum || ' BYTES' || JBQB);
				end if;
			end if;
		end if;

	end loop;

end;
/
